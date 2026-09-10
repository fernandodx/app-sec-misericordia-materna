import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/errors/failures.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        throw const AuthFailure('Falha ao autenticar usuário.');
      }
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  Future<User> registerWithEmail(String email, String password, {String? nome}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user == null) {
        throw const AuthFailure('Falha ao registrar novo usuário.');
      }
      if (nome != null && nome.trim().isNotEmpty) {
        try {
          await credential.user!.updateDisplayName(nome.trim());
        } catch (_) {}
      }
      // Envia verificação de e-mail de forma resiliente
      try {
        await credential.user!.sendEmailVerification();
      } catch (_) {}

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e.code));
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        authProvider.addScope('email');
        authProvider.addScope('profile');
        final userCredential = await _firebaseAuth.signInWithPopup(authProvider);
        if (userCredential.user == null) {
          throw const AuthFailure('Falha ao autenticar usuário com Google.');
        }
        return userCredential.user!;
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw const AuthFailure('Login com Google cancelado pelo usuário.');
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        if (userCredential.user == null) {
          throw const AuthFailure('Não foi possível obter dados do usuário do Google.');
        }

        return userCredential.user!;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e.code));
    } catch (e) {
      if (e is Failure) rethrow;
      throw AuthFailure('Erro ao autenticar com Google: ${e.toString()}');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw AuthFailure('Erro ao enviar e-mail de verificação: $e');
    }
  }

  Future<bool> reloadAndCheckEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        return _firebaseAuth.currentUser?.emailVerified ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e.code));
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha informada é muito fraca (mínimo de 6 caracteres).';
      case 'invalid-email':
        return 'O endereço de e-mail informado é inválido.';
      case 'user-disabled':
        return 'Esta conta de usuário foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas sem sucesso. Aguarde alguns instantes.';
      case 'operation-not-allowed':
        return 'O login/cadastro por e-mail e senha não está ativado no Firebase Console. Habilite o provedor Email/Password.';
      case 'network-request-failed':
        return 'Falha de conexão com a rede. Verifique sua conexão com a internet.';
      case 'channel-error':
        return 'Por favor, preencha todos os campos obrigatórios.';
      default:
        return 'Erro de autenticação ($code). Tente novamente.';
    }
  }
}
