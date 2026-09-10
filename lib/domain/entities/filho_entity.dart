class FilhoEntity {
  final String nome;
  final String? dataNascimento;
  final int idade;

  const FilhoEntity({
    required this.nome,
    required this.idade,
    this.dataNascimento,
  });

  /// Calcula a idade precisa em anos completos a partir de uma data no formato DD/MM/AAAA.
  static int calcularIdade(String? dataNascimentoStr, [DateTime? referenceDate]) {
    if (dataNascimentoStr == null || dataNascimentoStr.trim().isEmpty) return 0;
    try {
      final parts = dataNascimentoStr.trim().split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day == null || month == null || year == null) return 0;

        final birthDate = DateTime(year, month, day);
        final ref = referenceDate ?? DateTime.now();

        int age = ref.year - birthDate.year;
        if (ref.month < birthDate.month ||
            (ref.month == birthDate.month && ref.day < birthDate.day)) {
          age--;
        }
        return age >= 0 ? age : 0;
      }
    } catch (_) {}
    return 0;
  }

  factory FilhoEntity.fromNascimento({
    required String nome,
    required String dataNascimento,
    DateTime? referenceDate,
  }) {
    final cleanNome = nome.trim();
    final cleanData = dataNascimento.trim();
    final idade = calcularIdade(cleanData, referenceDate);
    return FilhoEntity(
      nome: cleanNome,
      dataNascimento: cleanData,
      idade: idade,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'idade': idade,
      if (dataNascimento != null && dataNascimento!.isNotEmpty)
        'dataNascimento': dataNascimento,
    };
  }

  factory FilhoEntity.fromMap(Map<String, dynamic> map) {
    final nome = (map['nome'] as String?)?.trim() ?? '';
    final dataNascimento = (map['dataNascimento'] as String?)?.trim();
    int idade = (map['idade'] as num?)?.toInt() ?? 0;

    if (dataNascimento != null && dataNascimento.isNotEmpty) {
      final calculada = calcularIdade(dataNascimento);
      if (calculada > 0 || idade == 0) {
        idade = calculada;
      }
    }

    return FilhoEntity(
      nome: nome,
      idade: idade,
      dataNascimento: dataNascimento,
    );
  }

  FilhoEntity copyWith({
    String? nome,
    int? idade,
    String? dataNascimento,
  }) {
    return FilhoEntity(
      nome: nome ?? this.nome,
      idade: idade ?? this.idade,
      dataNascimento: dataNascimento ?? this.dataNascimento,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilhoEntity &&
          runtimeType == other.runtimeType &&
          nome == other.nome &&
          idade == other.idade &&
          dataNascimento == other.dataNascimento;

  @override
  int get hashCode =>
      nome.hashCode ^ idade.hashCode ^ (dataNascimento?.hashCode ?? 0);

  @override
  String toString() {
    if (dataNascimento != null && dataNascimento!.isNotEmpty) {
      return '$nome ($idade anos • Nasc: $dataNascimento)';
    }
    return '$nome ($idade anos)';
  }
}
