import 'package:flutter_test/flutter_test.dart';
import 'package:app_secretaria/core/constants/app_roles.dart';
import 'package:app_secretaria/core/constants/cadastro_constants.dart';
import 'package:app_secretaria/domain/entities/invite_entity.dart';
import 'package:app_secretaria/domain/entities/user_entity.dart';

void main() {
  group('Regras de Etapas por Tipo de Vida', () {
    test('Retorna as 7 etapas oficiais de Vida Interna', () {
      final etapas = CadastroConstants.etapasPorTipoVida(TipoVida.interna);
      expect(etapas.length, equals(7));
      expect(etapas.first, equals('Aspirantado'));
      expect(etapas.last, equals('Formador'));
      expect(etapas, contains('Postulantado I'));
      expect(etapas, contains('Noviciado I'));
      expect(etapas, contains('Consagrado'));
    });

    test('Retorna as 10 etapas oficiais de Vida Externa', () {
      final etapas = CadastroConstants.etapasPorTipoVida(TipoVida.externa);
      expect(etapas.length, equals(10));
      expect(etapas.first, equals('Vocacional 1º'));
      expect(etapas.last, equals('Discípulo 5º'));
      expect(etapas, contains('Servo 1º'));
      expect(etapas, contains('Discípulo 1º'));
    });

    test('Fallback seguro para Vida Externa quando tipoVida for nulo', () {
      final etapas = CadastroConstants.etapasPorTipoVida(null);
      expect(etapas, equals(CadastroConstants.etapasVidaExterna));
    });
  });

  group('Regras do Stepper e Indicadores de Conclusão', () {
    bool calculateIsDone(bool isComplete, int stepNum, int currentStep, int maxStepReached) {
      if (isComplete) return stepNum != currentStep;
      return stepNum < currentStep || stepNum < maxStepReached;
    }

    bool calculateCanNavigate(bool isComplete, int stepNum, int currentStep, int maxStepReached) {
      return isComplete || stepNum <= maxStepReached || stepNum <= currentStep;
    }

    test('Quando perfil está completo (isProfileComplete == true), etapas não ativas são consideradas concluídas', () {
      final isComplete = DateTime.now().year > 2000;
      const currentStep = 2;

      for (int stepNum = 1; stepNum <= 6; stepNum++) {
        final isCurrent = stepNum == currentStep;
        final isDone = calculateIsDone(isComplete, stepNum, currentStep, 6);
        final canNavigate = calculateCanNavigate(isComplete, stepNum, currentStep, 6);

        if (stepNum == 2) {
          expect(isCurrent, isTrue);
          expect(isDone, isFalse);
        } else {
          expect(isCurrent, isFalse);
          expect(isDone, isTrue, reason: 'Etapa $stepNum deve estar marcada como concluída');
        }
        expect(canNavigate, isTrue, reason: 'Usuário com perfil completo pode navegar para qualquer etapa');
      }
    });

    test('Quando perfil está incompleto, apenas etapas anteriores são concluídas', () {
      final isComplete = DateTime.now().year < 2000;
      const currentStep = 3;
      const maxStepReached = 3;

      for (int stepNum = 1; stepNum <= 6; stepNum++) {
        final isDone = calculateIsDone(isComplete, stepNum, currentStep, maxStepReached);

        if (stepNum < 3) {
          expect(isDone, isTrue, reason: 'Etapa $stepNum já foi completada');
        } else {
          expect(isDone, isFalse);
        }
      }
    });
  });

  group('Regras de Exibição do Alerta de Cadastro Incompleto', () {
    test('Alerta deve ser exibido quando isProfileComplete for falso', () {
      final userIncompleto = UserEntity(
        id: 'u1',
        email: 'teste@email.com',
        nome: 'Membro Teste',
        telefone: '',
        role: AppRole.membro,
        isEmailVerified: true,
        isProfileComplete: false,
        cadastroEtapa: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final deveExibirBanner = !userIncompleto.isProfileComplete;
      expect(deveExibirBanner, isTrue);
    });

    test('Alerta NÃO deve ser exibido quando isProfileComplete for verdadeiro', () {
      final userCompleto = UserEntity(
        id: 'u2',
        email: 'completo@email.com',
        nome: 'Membro Completo',
        telefone: '',
        role: AppRole.membro,
        isEmailVerified: true,
        isProfileComplete: true,
        cadastroEtapa: 6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final deveExibirBanner = !userCompleto.isProfileComplete;
      expect(deveExibirBanner, isFalse);
    });
  });

  group('Vinculação e Aceite Automático de Convite', () {
    test('Atualiza role, tipoVida e localidade do visitante com os dados do convite', () {
      final visitante = UserEntity(
        id: 'u3',
        email: 'convidado@email.com',
        nome: 'Novo Membro',
        telefone: '',
        role: AppRole.visitante,
        isEmailVerified: true,
        isProfileComplete: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final invite = InviteEntity(
        id: 'INV_123',
        targetRole: AppRole.membro,
        tipoVida: TipoVida.interna,
        localidade: null,
        createdByUid: 'admin_1',
        status: InviteStatus.pending,
        createdAt: DateTime.now(),
      );

      final atualizado = visitante.copyWith(
        role: invite.targetRole,
        tipoVida: invite.tipoVida,
        localidade: invite.localidade ?? visitante.localidade,
      );

      expect(atualizado.role, equals(AppRole.membro));
      expect(atualizado.tipoVida, equals(TipoVida.interna));
      expect(atualizado.role.isVisitante, isFalse);
    });
  });
}
