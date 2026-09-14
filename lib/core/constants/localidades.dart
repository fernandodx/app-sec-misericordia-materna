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

  /// Resolve de forma tolerante a localidade por sigla, nome ou variações
  static LocalidadeItem? resolver(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final clean = input.trim().toLowerCase();

    for (final l in todas) {
      if (l.sigla.toLowerCase() == clean || l.nome.toLowerCase() == clean) {
        return l;
      }
    }

    if (clean.contains('bsb') || clean.contains('brasilia') || clean.contains('brasília')) {
      return brasilia;
    }
    if (clean.contains('aax') || clean.contains('araxa') || clean.contains('araxá')) {
      return araxa;
    }
    if (clean.contains('udi') || clean.contains('uberlandia') || clean.contains('uberlândia')) {
      return uberlandia;
    }

    return null;
  }

  static LocalidadeItem? porSigla(String? sigla) => resolver(sigla);

  static LocalidadeItem? fromSigla(String? sigla) => resolver(sigla);

  static String nomePorSigla(String? sigla) {
    final item = resolver(sigla);
    return item?.rotuloCompleto ?? sigla ?? 'Sem Localidade';
  }
}
