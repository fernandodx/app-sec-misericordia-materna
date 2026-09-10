import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCepResult {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;
  final bool isError;

  const ViaCepResult({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.isError = false,
  });

  factory ViaCepResult.fromJson(Map<String, dynamic> json) {
    if (json['erro'] == true || json['erro'] == 'true') {
      return const ViaCepResult(
        cep: '',
        logradouro: '',
        complemento: '',
        bairro: '',
        cidade: '',
        uf: '',
        isError: true,
      );
    }

    return ViaCepResult(
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      complemento: json['complemento'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: json['localidade'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
      isError: false,
    );
  }
}

class ViaCepService {
  static Future<ViaCepResult?> fetchCep(String cepRaw) async {
    final cleanCep = cepRaw.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return null;

    try {
      final uri = Uri.parse('https://viacep.com.br/ws/$cleanCep/json/');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = ViaCepResult.fromJson(data);
        if (result.isError) return null;
        return result;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
