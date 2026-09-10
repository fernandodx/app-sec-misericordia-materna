import 'dart:async';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/entities/invite_entity.dart';
import '../../domain/entities/user_entity.dart';

class AuthSignal {
  final currentUser = signal<UserEntity?>(null);
  final isLoading = signal<bool>(false);
  final errorMessage = signal<String?>(null);
  final activeInvite = signal<InviteEntity?>(null);

  StreamSubscription<UserEntity?>? _authSubscription;

  void init() {
    _authSubscription?.cancel();
    _authSubscription = sl.checkAuthStateUseCase().listen(
      (user) {
        currentUser.value = user;
        errorMessage.value = null;
      },
      onError: (e) {
        errorMessage.value = e.toString();
      },
    );
  }

  void dispose() {
    _authSubscription?.cancel();
  }

  void clearError() {
    errorMessage.value = null;
  }

  void setActiveInvite(InviteEntity? invite) {
    activeInvite.value = invite;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final user = await sl.signInEmailUseCase(email, password);
      currentUser.value = user;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerWithEmail(String email, String password, {String? nome}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final user = await sl.registerEmailUseCase(email, password, nome: nome);
      currentUser.value = user;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final user = await sl.signInGoogleUseCase();
      currentUser.value = user;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await sl.authRepository.sendEmailVerification();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<bool> checkEmailVerified() async {
    try {
      final isVerified = await sl.authRepository.reloadAndCheckEmailVerified();
      if (isVerified && currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(isEmailVerified: true);
      }
      return isVerified;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await sl.signOutUseCase();
      currentUser.value = null;
      activeInvite.value = null;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void refreshUser(UserEntity updated) {
    currentUser.value = updated;
  }
}

final authSignal = AuthSignal();
