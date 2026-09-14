import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_roles.dart';
import '../../core/constants/localidades.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.nome,
    required super.telefone,
    super.fotoUrl,
    required super.role,
    super.tipoVida,
    super.localidade,
    super.supervisorId,
    super.spouseId,
    required super.isEmailVerified,
    required super.isProfileComplete,
    required super.createdAt,
    required super.updatedAt,
    super.dataNascimento,
    super.isCasado,
    super.nomeConjuge,
    super.nomePai,
    super.nomeMae,
    super.rg,
    super.cpf,
    super.tituloEleitor,
    super.profissao,
    super.escolaridade,
    super.possuiFilhos,
    super.quantidadeFilhos,
    super.filhos,
    super.nomesFilhos,
    super.possuiIrmaos,
    super.irmaos,
    super.cep,
    super.logradouro,
    super.numero,
    super.complemento,
    super.bairro,
    super.cidade,
    super.uf,
    super.telefoneResidencial,
    super.celular,
    super.etapaFraternidade,
    super.paroquia,
    super.paroquiaEndereco,
    super.paroquiaCidadeUf,
    super.paroco,
    super.participaPastoral,
    super.qualPastoral,
    super.testemunhoVocacionalMatrimonial,
    super.experienciaServicoIgreja,
    super.conhecimentoFraternidade,
    super.pensamentoCarisma,
    super.chamadoComunidadeAlianca,
    super.disponibilidadeCasal,
    super.ondeMaisGostaTrabalhar,
    super.disponivelIniciarProcesso,
    super.anoProcessoVocacional,
    super.autobiografiaHistoriaPessoal,
    super.autobiografiaFamilia,
    super.autobiografiaIgreja,
    super.autobiografiaPdfBase64,
    super.autobiografiaPdfNome,
    super.cadastroEtapa,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      nome: entity.nome,
      telefone: entity.telefone,
      fotoUrl: entity.fotoUrl,
      role: entity.role,
      tipoVida: entity.tipoVida,
      localidade: entity.localidade,
      supervisorId: entity.supervisorId,
      spouseId: entity.spouseId,
      isEmailVerified: entity.isEmailVerified,
      isProfileComplete: entity.isProfileComplete,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      dataNascimento: entity.dataNascimento,
      isCasado: entity.isCasado,
      nomeConjuge: entity.nomeConjuge,
      nomePai: entity.nomePai,
      nomeMae: entity.nomeMae,
      rg: entity.rg,
      cpf: entity.cpf,
      tituloEleitor: entity.tituloEleitor,
      profissao: entity.profissao,
      escolaridade: entity.escolaridade,
      possuiFilhos: entity.possuiFilhos,
      quantidadeFilhos: entity.quantidadeFilhos,
      filhos: entity.filhos,
      nomesFilhos: entity.nomesFilhos,
      possuiIrmaos: entity.possuiIrmaos,
      irmaos: entity.irmaos,
      cep: entity.cep,
      logradouro: entity.logradouro,
      numero: entity.numero,
      complemento: entity.complemento,
      bairro: entity.bairro,
      cidade: entity.cidade,
      uf: entity.uf,
      telefoneResidencial: entity.telefoneResidencial,
      celular: entity.celular,
      etapaFraternidade: entity.etapaFraternidade,
      paroquia: entity.paroquia,
      paroquiaEndereco: entity.paroquiaEndereco,
      paroquiaCidadeUf: entity.paroquiaCidadeUf,
      paroco: entity.paroco,
      participaPastoral: entity.participaPastoral,
      qualPastoral: entity.qualPastoral,
      testemunhoVocacionalMatrimonial: entity.testemunhoVocacionalMatrimonial,
      experienciaServicoIgreja: entity.experienciaServicoIgreja,
      conhecimentoFraternidade: entity.conhecimentoFraternidade,
      pensamentoCarisma: entity.pensamentoCarisma,
      chamadoComunidadeAlianca: entity.chamadoComunidadeAlianca,
      disponibilidadeCasal: entity.disponibilidadeCasal,
      ondeMaisGostaTrabalhar: entity.ondeMaisGostaTrabalhar,
      disponivelIniciarProcesso: entity.disponivelIniciarProcesso,
      anoProcessoVocacional: entity.anoProcessoVocacional,
      autobiografiaHistoriaPessoal: entity.autobiografiaHistoriaPessoal,
      autobiografiaFamilia: entity.autobiografiaFamilia,
      autobiografiaIgreja: entity.autobiografiaIgreja,
      autobiografiaPdfBase64: entity.autobiografiaPdfBase64,
      autobiografiaPdfNome: entity.autobiografiaPdfNome,
      cadastroEtapa: entity.cadastroEtapa,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel.fromMap(data, doc.id);
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    AppRole parseRole(dynamic value) {
      if (value == null) return AppRole.visitante;
      final str = value.toString().trim();
      return AppRole.values.firstWhere(
        (r) => r.key == str || r.name == str,
        orElse: () => AppRole.visitante,
      );
    }

    TipoVida? parseTipoVida(dynamic value) {
      if (value == null) return null;
      if (value is TipoVida) return value;
      return TipoVida.fromKey(value.toString());
    }

    String? parseLocalidade(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      if (str.isEmpty) return null;
      final resolved = Localidades.resolver(str);
      return resolved?.sigla ?? str;
    }

    List<FilhoEntity> parsedFilhos = [];
    if (data['filhos'] is List) {
      parsedFilhos = (data['filhos'] as List)
          .map((item) => FilhoEntity.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else if (data['nomesFilhos'] is List) {
      parsedFilhos = (data['nomesFilhos'] as List)
          .map((n) => FilhoEntity(nome: n.toString(), idade: 0))
          .toList();
    }

    List<String> parsedIrmaos = [];
    if (data['irmaos'] is List) {
      parsedIrmaos = (data['irmaos'] as List).map((e) => e.toString()).toList();
    }

    return UserModel(
      id: id,
      email: data['email'] as String? ?? '',
      nome: data['nome'] as String? ?? '',
      telefone: data['telefone'] as String? ?? '',
      fotoUrl: data['fotoUrl'] as String?,
      role: parseRole(data['role']),
      tipoVida: parseTipoVida(data['tipoVida'] ?? data['tipo_vida']),
      localidade: parseLocalidade(data['localidade'] ?? data['fraternidade'] ?? data['localidadeFraternidade']),
      supervisorId: data['supervisorId'] as String?,
      spouseId: data['spouseId'] as String?,
      isEmailVerified: (data['isEmailVerified'] as bool?) ?? false,
      isProfileComplete: (data['isProfileComplete'] as bool?) ?? false,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
      dataNascimento: data['dataNascimento'] as String?,
      isCasado: (data['isCasado'] as bool?) ?? false,
      nomeConjuge: data['nomeConjuge'] as String?,
      nomePai: data['nomePai'] as String?,
      nomeMae: data['nomeMae'] as String?,
      rg: data['rg'] as String?,
      cpf: data['cpf'] as String?,
      tituloEleitor: data['tituloEleitor'] as String?,
      profissao: data['profissao'] as String?,
      escolaridade: data['escolaridade'] as String?,
      possuiFilhos: (data['possuiFilhos'] as bool?) ?? false,
      quantidadeFilhos: (data['quantidadeFilhos'] as num?)?.toInt() ?? parsedFilhos.length,
      filhos: parsedFilhos,
      nomesFilhos: parsedFilhos.map((f) => f.nome).toList(),
      possuiIrmaos: (data['possuiIrmaos'] as bool?) ?? false,
      irmaos: parsedIrmaos,
      cep: data['cep'] as String?,
      logradouro: data['logradouro'] as String?,
      numero: data['numero'] as String?,
      complemento: data['complemento'] as String?,
      bairro: data['bairro'] as String?,
      cidade: data['cidade'] as String?,
      uf: data['uf'] as String?,
      telefoneResidencial: data['telefoneResidencial'] as String?,
      celular: data['celular'] as String?,
      etapaFraternidade: data['etapaFraternidade'] as String?,
      paroquia: data['paroquia'] as String?,
      paroquiaEndereco: data['paroquiaEndereco'] as String?,
      paroquiaCidadeUf: data['paroquiaCidadeUf'] as String?,
      paroco: data['paroco'] as String?,
      participaPastoral: (data['participaPastoral'] as bool?) ?? false,
      qualPastoral: data['qualPastoral'] as String?,
      testemunhoVocacionalMatrimonial: data['testemunhoVocacionalMatrimonial'] as String?,
      experienciaServicoIgreja: data['experienciaServicoIgreja'] as String?,
      conhecimentoFraternidade: data['conhecimentoFraternidade'] as String?,
      pensamentoCarisma: data['pensamentoCarisma'] as String?,
      chamadoComunidadeAlianca: data['chamadoComunidadeAlianca'] as String?,
      disponibilidadeCasal: data['disponibilidadeCasal'] as String?,
      ondeMaisGostaTrabalhar: data['ondeMaisGostaTrabalhar'] as String?,
      disponivelIniciarProcesso: (data['disponivelIniciarProcesso'] as bool?) ?? true,
      anoProcessoVocacional: (data['anoProcessoVocacional'] as num?)?.toInt() ?? DateTime.now().year,
      autobiografiaHistoriaPessoal: data['autobiografiaHistoriaPessoal'] as String?,
      autobiografiaFamilia: data['autobiografiaFamilia'] as String?,
      autobiografiaIgreja: data['autobiografiaIgreja'] as String?,
      autobiografiaPdfBase64: data['autobiografiaPdfBase64'] as String?,
      autobiografiaPdfNome: data['autobiografiaPdfNome'] as String?,
      cadastroEtapa: (data['cadastroEtapa'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nome': nome,
      'telefone': telefone,
      'fotoUrl': fotoUrl,
      'role': role.key,
      'tipoVida': tipoVida?.key,
      'localidade': localidade,
      'supervisorId': supervisorId,
      'spouseId': spouseId,
      'isEmailVerified': isEmailVerified,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dataNascimento': dataNascimento,
      'isCasado': isCasado,
      'nomeConjuge': nomeConjuge,
      'nomePai': nomePai,
      'nomeMae': nomeMae,
      'rg': rg,
      'cpf': cpf,
      'tituloEleitor': tituloEleitor,
      'profissao': profissao,
      'escolaridade': escolaridade,
      'possuiFilhos': possuiFilhos,
      'quantidadeFilhos': filhos.length,
      'filhos': filhos.map((f) => f.toMap()).toList(),
      'nomesFilhos': filhos.map((f) => f.nome).toList(),
      'possuiIrmaos': possuiIrmaos,
      'irmaos': irmaos,
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'telefoneResidencial': telefoneResidencial,
      'celular': celular,
      'etapaFraternidade': etapaFraternidade,
      'paroquia': paroquia,
      'paroquiaEndereco': paroquiaEndereco,
      'paroquiaCidadeUf': paroquiaCidadeUf,
      'paroco': paroco,
      'participaPastoral': participaPastoral,
      'qualPastoral': qualPastoral,
      'testemunhoVocacionalMatrimonial': testemunhoVocacionalMatrimonial,
      'experienciaServicoIgreja': experienciaServicoIgreja,
      'conhecimentoFraternidade': conhecimentoFraternidade,
      'pensamentoCarisma': pensamentoCarisma,
      'chamadoComunidadeAlianca': chamadoComunidadeAlianca,
      'disponibilidadeCasal': disponibilidadeCasal,
      'ondeMaisGostaTrabalhar': ondeMaisGostaTrabalhar,
      'disponivelIniciarProcesso': disponivelIniciarProcesso,
      'anoProcessoVocacional': anoProcessoVocacional,
      'autobiografiaHistoriaPessoal': autobiografiaHistoriaPessoal,
      'autobiografiaFamilia': autobiografiaFamilia,
      'autobiografiaIgreja': autobiografiaIgreja,
      'autobiografiaPdfBase64': autobiografiaPdfBase64,
      'autobiografiaPdfNome': autobiografiaPdfNome,
      'cadastroEtapa': cadastroEtapa,
    };
  }
}
