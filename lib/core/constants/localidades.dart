class LocalidadeItem {
  final String sigla;
  final String nome;
  final String estado;

  const LocalidadeItem({
    required this.sigla,
    required this.nome,
    required this.estado,
  });

  String get rotuloCompleto => '$nome - $sigla';
}

class Localidades {
  static const LocalidadeItem brasilia = LocalidadeItem(
    sigla: 'BSB',
    nome: 'Brasília',
    estado: 'DF',
  );

  static const LocalidadeItem araxa = LocalidadeItem(
    sigla: 'AAX',
    nome: 'Araxá',
    estado: 'MG',
  );

  static const LocalidadeItem uberlandia = LocalidadeItem(
    sigla: 'UDI',
    nome: 'Uberlândia',
    estado: 'MG',
  );

  static const List<LocalidadeItem> todas = [
    brasilia,
    araxa,
    uberlandia,
  ];

  static LocalidadeItem? porSigla(String? sigla) {
    if (sigla == null) return null;
    try {
      return todas.firstWhere((l) => l.sigla.toUpperCase() == sigla.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  static LocalidadeItem? fromSigla(String? sigla) => porSigla(sigla);

  static String nomePorSigla(String? sigla) {
    final item = porSigla(sigla);
    return item?.rotuloCompleto ?? sigla ?? 'Sem Localidade';
  }
}
