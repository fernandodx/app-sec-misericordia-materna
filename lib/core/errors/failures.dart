import 'package:firebase_core/firebase_core.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;

  /// Converte qualquer exceção em uma Failure tipada com mensagem amigável em PT-BR
  factory Failure.fromException(Object error) {
    if (error is Failure) return error;

    if (error is FirebaseException) {
      switch (error.code) {
        case 'user-not-found':
          return const AuthFailure('Nenhum usuário cadastrado com este e-mail.');
        case 'wrong-password':
        case 'invalid-credential':
          return const AuthFailure('E-mail ou senha incorretos. Verifique suas credenciais.');
        case 'email-already-in-use':
          return const AuthFailure('Este e-mail já está em uso por outra conta.');
        case 'weak-password':
          return const AuthFailure('A senha fornecida é muito fraca. Utilize pelo menos 6 caracteres.');
        case 'invalid-email':
          return const ValidationFailure('O formato do e-mail informado é inválido.');
        case 'user-disabled':
          return const AuthFailure('Esta conta de usuário foi desativada.');
        case 'too-many-requests':
          return const AuthFailure('Muitas tentativas sem sucesso. Aguarde alguns minutos antes de tentar novamente.');
        case 'network-request-failed':
          return const ServerFailure('Falha na conexão com a internet. Verifique sua rede.');
        case 'permission-denied':
          return const ServerFailure('Acesso negado pelas regras de segurança. Verifique suas permissões.');
        case 'unavailable':
          return const ServerFailure('Serviço temporariamente indisponível. Tente novamente em instantes.');
        default:
          return ServerFailure(error.message ?? 'Erro no serviço (${error.code}).');
      }
    }

    final str = error.toString();
    if (str.startsWith('Exception: ')) {
      return ServerFailure(str.replaceFirst('Exception: ', ''));
    }
    return ServerFailure(str);
  }
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
