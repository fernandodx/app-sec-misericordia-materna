import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_secretaria/core/constants/app_roles.dart';
import 'package:app_secretaria/core/errors/failures.dart';
import 'package:app_secretaria/domain/entities/invite_entity.dart';
import 'package:app_secretaria/domain/entities/user_entity.dart';
import 'package:app_secretaria/domain/repositories/auth_repository.dart';
import 'package:app_secretaria/domain/repositories/invite_repository.dart';
import 'package:app_secretaria/domain/usecases/auth/sign_in_email_usecase.dart';
import 'package:app_secretaria/domain/usecases/invites/validate_invite_usecase.dart';
import 'package:app_secretaria/presentation/signals/theme_signal.dart';

// Mock simples para AuthRepository
class MockAuthRepository implements AuthRepository {
  final bool shouldFail;
  MockAuthRepository({this.shouldFail = false});

  @override
  Stream<UserEntity?> authStateChanges() => Stream.value(null);

  @override
  UserEntity? getCurrentUser() => null;

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    if (shouldFail) {
      throw Exception('Credenciais inválidas de teste.');
    }
    return UserEntity(
      id: 'usr_test_1',
      email: email,
      nome: 'Usuário Teste',
      telefone: '61999999999',
      role: AppRole.membro,
      isEmailVerified: true,
      isProfileComplete: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserEntity> registerWithEmail(String email, String password, {String? nome}) async =>
      signInWithEmail(email, password);

  @override
  Future<UserEntity> signInWithGoogle() async => signInWithEmail('google@test.com', '');

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<bool> reloadAndCheckEmailVerified() async => true;

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {}
}

// Mock simples para InviteRepository
class MockInviteRepository implements InviteRepository {
  final InviteEntity? inviteToReturn;
  MockInviteRepository(this.inviteToReturn);

  @override
  Future<void> createInvite(InviteEntity invite) async {}

  @override
  Future<InviteEntity?> getInviteByCode(String code) async => inviteToReturn;

  @override
  Future<void> acceptInvite(String code, String userId) async {}

  @override
  Future<void> revokeInvite(String code) async {}

  @override
  Future<List<InviteEntity>> listInvites() async => [];

  @override
  Future<InviteEntity?> findPendingInviteForEmail(String email) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeSignal Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('inicializa com ThemeMode.system como padrão', () async {
      final theme = ThemeSignal();
      await theme.init();
      expect(theme.themeMode.value, ThemeMode.system);
    });

    test('alterna para ThemeMode.dark e persiste no SharedPreferences', () async {
      final theme = ThemeSignal();
      await theme.init();

      await theme.setThemeMode(ThemeMode.dark);
      expect(theme.themeMode.value, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'dark');
    });

    test('alterna para ThemeMode.light e persiste no SharedPreferences', () async {
      final theme = ThemeSignal();
      await theme.init();

      await theme.setThemeMode(ThemeMode.light);
      expect(theme.themeMode.value, ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), 'light');
    });

    test('carrega valor previamente salvo do SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
      final theme = ThemeSignal();
      await theme.init();
      expect(theme.themeMode.value, ThemeMode.dark);
    });
  });

  group('Programação Funcional com fpdart (UseCases)', () {
    test('SignInEmailUseCase retorna Right(UserEntity) em caso de sucesso', () async {
      final repo = MockAuthRepository(shouldFail: false);
      final useCase = SignInEmailUseCase(repo);

      final result = await useCase.call('teste@email.com', '123456');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Não deveria falhar'),
        (user) {
          expect(user.email, 'teste@email.com');
          expect(user.id, 'usr_test_1');
        },
      );
    });

    test('SignInEmailUseCase captura exceção e retorna Left(Failure) sem quebrar o fluxo', () async {
      final repo = MockAuthRepository(shouldFail: true);
      final useCase = SignInEmailUseCase(repo);

      final result = await useCase.call('teste@email.com', 'errada');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, contains('Credenciais inválidas de teste.'));
        },
        (user) => fail('Deveria ter retornado Left'),
      );
    });

    test('ValidateInviteUseCase retorna Left(NotFoundFailure) quando convite não existe', () async {
      final repo = MockInviteRepository(null);
      final useCase = ValidateInviteUseCase(repo);

      final result = await useCase.call('COD_INEXISTENTE');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, contains('Convite não encontrado'));
        },
        (_) => fail('Não deveria encontrar convite'),
      );
    });

    test('ValidateInviteUseCase retorna Right(InviteEntity) quando convite é válido', () async {
      final validInvite = InviteEntity(
        id: 'CONV123',
        targetRole: AppRole.membro,
        createdByUid: 'admin-1',
        status: InviteStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 10)),
      );
      final repo = MockInviteRepository(validInvite);
      final useCase = ValidateInviteUseCase(repo);

      final result = await useCase.call('CONV123');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Deveria ser válido'),
        (invite) {
          expect(invite.id, 'CONV123');
          expect(invite.isValid, isTrue);
        },
      );
    });

    test('Failure.fromException mapeia mensagens de erro adequadamente', () {
      final f1 = Failure.fromException(Exception('Erro genérico customizado'));
      expect(f1, isA<ServerFailure>());
      expect(f1.message, 'Erro genérico customizado');
    });
  });
}
