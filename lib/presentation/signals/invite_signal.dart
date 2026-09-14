import 'package:signals_flutter/signals_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_roles.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/invite_entity.dart';
import 'auth_signal.dart';

class InviteSignal {
  final invites = signal<List<InviteEntity>>([]);
  final isLoading = signal<bool>(false);
  final isCreating = signal<bool>(false);
  final errorMessage = signal<String?>(null);
  final lastCreatedInvite = signal<InviteEntity?>(null);

  Future<void> loadInvites() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await sl.listInvitesUseCase();
      result.fold(
        (failure) {
          errorMessage.value = failure.message;
        },
        (list) {
          invites.value = list;
        },
      );
    } catch (e) {
      errorMessage.value = Failure.fromException(e).message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<InviteEntity?> createInvite({
    required AppRole targetRole,
    TipoVida? tipoVida,
    String? localidade,
    String? targetEmail,
    int? validadeDias = 15,
  }) async {
    try {
      isCreating.value = true;
      errorMessage.value = null;

      final current = authSignal.currentUser.value;
      if (current == null) {
        errorMessage.value = 'Usuário autenticado não encontrado para emitir convite.';
        return null;
      }

      // Gera token único e legível
      final token = const Uuid().v4().substring(0, 8).toUpperCase();
      final now = DateTime.now();
      final expiresAt = validadeDias != null ? now.add(Duration(days: validadeDias)) : null;

      final invite = InviteEntity(
        id: token,
        targetRole: targetRole,
        tipoVida: tipoVida,
        localidade: localidade,
        targetEmail: targetEmail?.trim().toLowerCase(),
        createdByUid: current.id,
        createdByName: current.nome.isNotEmpty ? current.nome : current.email,
        status: InviteStatus.pending,
        createdAt: now,
        expiresAt: expiresAt,
      );

      final result = await sl.createInviteUseCase(invite);
      return await result.fold(
        (failure) async {
          errorMessage.value = failure.message;
          return null;
        },
        (created) async {
          lastCreatedInvite.value = created;
          await loadInvites();
          return created;
        },
      );
    } catch (e) {
      errorMessage.value = Failure.fromException(e).message;
      return null;
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> revokeInvite(String code) async {
    try {
      await sl.inviteRepository.revokeInvite(code);
      await loadInvites();
    } catch (e) {
      errorMessage.value = Failure.fromException(e).message;
    }
  }

  void clearMessages() {
    errorMessage.value = null;
    lastCreatedInvite.value = null;
  }
}

final inviteSignal = InviteSignal();
