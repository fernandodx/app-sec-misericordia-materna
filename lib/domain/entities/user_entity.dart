import '../../core/constants/app_roles.dart';
import 'filho_entity.dart';
export 'filho_entity.dart';

class UserEntity {
  final String id;
  final String email;
  final String nome;
  final String telefone;
  final String? fotoUrl;
  final AppRole role;
  final TipoVida? tipoVida;
  final String? localidade; // BSB, AAX, UDI
  final String? supervisorId; // Formador ou Acompanhador responsável
  final String? spouseId; // Vínculo de cônjuge (se casal)
  final bool isEmailVerified;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Etapa 1: Estado civil, data nascimento, filiação, cônjuge e documentos
  final String? dataNascimento;
  final bool isCasado;
  final String? nomeConjuge;
  final String? nomePai;
  final String? nomeMae;
  final String? rg;
  final String? cpf;
  final String? tituloEleitor;
  final String? profissao;
  final String? escolaridade;

  // Etapa 2: Filhos (Casados) & Irmãos (Solteiros)
  final bool possuiFilhos;
  final int quantidadeFilhos;
  final List<FilhoEntity> filhos;
  final List<String> nomesFilhos;
  final bool possuiIrmaos;
  final List<String> irmaos;

  // Etapa 3: Endereço Residencial
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? uf;
  final String? telefoneResidencial;
  final String? celular;

  // Etapa 4: Etapa do Caminho da Fraternidade
  final String? etapaFraternidade;

  // Etapa 5: Vivência Religiosa & Paroquial
  final String? paroquia;
  final String? paroquiaEndereco;
  final String? paroquiaCidadeUf;
  final String? paroco;
  final bool participaPastoral;
  final String? qualPastoral;

  // Etapa 6: Dados Vocacionais (Casados vs Solteiros)
  final String? testemunhoVocacionalMatrimonial;
  final String? experienciaServicoIgreja;
  final String? conhecimentoFraternidade;
  final String? pensamentoCarisma;
  final String? chamadoComunidadeAlianca;
  final String? disponibilidadeCasal;
  final String? ondeMaisGostaTrabalhar;
  final bool disponivelIniciarProcesso;
  final int? anoProcessoVocacional;

  // Autobiografia exclusiva para Solteiros
  final String? autobiografiaHistoriaPessoal;
  final String? autobiografiaFamilia;
  final String? autobiografiaIgreja;
  final String? autobiografiaPdfBase64;
  final String? autobiografiaPdfNome;

  // Controle do progresso do onboarding (1 a 6)
  final int cadastroEtapa;

  const UserEntity({
    required this.id,
    required this.email,
    required this.nome,
    required this.telefone,
    this.fotoUrl,
    required this.role,
    this.tipoVida,
    this.localidade,
    this.supervisorId,
    this.spouseId,
    required this.isEmailVerified,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
    this.dataNascimento,
    this.isCasado = false,
    this.nomeConjuge,
    this.nomePai,
    this.nomeMae,
    this.rg,
    this.cpf,
    this.tituloEleitor,
    this.profissao,
    this.escolaridade,
    this.possuiFilhos = false,
    this.quantidadeFilhos = 0,
    this.filhos = const [],
    this.nomesFilhos = const [],
    this.possuiIrmaos = false,
    this.irmaos = const [],
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.uf,
    this.telefoneResidencial,
    this.celular,
    this.etapaFraternidade,
    this.paroquia,
    this.paroquiaEndereco,
    this.paroquiaCidadeUf,
    this.paroco,
    this.participaPastoral = false,
    this.qualPastoral,
    this.testemunhoVocacionalMatrimonial,
    this.experienciaServicoIgreja,
    this.conhecimentoFraternidade,
    this.pensamentoCarisma,
    this.chamadoComunidadeAlianca,
    this.disponibilidadeCasal,
    this.ondeMaisGostaTrabalhar,
    this.disponivelIniciarProcesso = true,
    this.anoProcessoVocacional,
    this.autobiografiaHistoriaPessoal,
    this.autobiografiaFamilia,
    this.autobiografiaIgreja,
    this.autobiografiaPdfBase64,
    this.autobiografiaPdfNome,
    this.cadastroEtapa = 1,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? nome,
    String? telefone,
    String? fotoUrl,
    AppRole? role,
    TipoVida? tipoVida,
    String? localidade,
    String? supervisorId,
    String? spouseId,
    bool? isEmailVerified,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? dataNascimento,
    bool? isCasado,
    String? nomeConjuge,
    String? nomePai,
    String? nomeMae,
    String? rg,
    String? cpf,
    String? tituloEleitor,
    String? profissao,
    String? escolaridade,
    bool? possuiFilhos,
    int? quantidadeFilhos,
    List<FilhoEntity>? filhos,
    List<String>? nomesFilhos,
    bool? possuiIrmaos,
    List<String>? irmaos,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
    String? telefoneResidencial,
    String? celular,
    String? etapaFraternidade,
    String? paroquia,
    String? paroquiaEndereco,
    String? paroquiaCidadeUf,
    String? paroco,
    bool? participaPastoral,
    String? qualPastoral,
    String? testemunhoVocacionalMatrimonial,
    String? experienciaServicoIgreja,
    String? conhecimentoFraternidade,
    String? pensamentoCarisma,
    String? chamadoComunidadeAlianca,
    String? disponibilidadeCasal,
    String? ondeMaisGostaTrabalhar,
    bool? disponivelIniciarProcesso,
    int? anoProcessoVocacional,
    String? autobiografiaHistoriaPessoal,
    String? autobiografiaFamilia,
    String? autobiografiaIgreja,
    String? autobiografiaPdfBase64,
    String? autobiografiaPdfNome,
    int? cadastroEtapa,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      role: role ?? this.role,
      tipoVida: tipoVida ?? this.tipoVida,
      localidade: localidade ?? this.localidade,
      supervisorId: supervisorId ?? this.supervisorId,
      spouseId: spouseId ?? this.spouseId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      isCasado: isCasado ?? this.isCasado,
      nomeConjuge: nomeConjuge ?? this.nomeConjuge,
      nomePai: nomePai ?? this.nomePai,
      nomeMae: nomeMae ?? this.nomeMae,
      rg: rg ?? this.rg,
      cpf: cpf ?? this.cpf,
      tituloEleitor: tituloEleitor ?? this.tituloEleitor,
      profissao: profissao ?? this.profissao,
      escolaridade: escolaridade ?? this.escolaridade,
      possuiFilhos: possuiFilhos ?? this.possuiFilhos,
      quantidadeFilhos: quantidadeFilhos ?? (filhos != null ? filhos.length : this.quantidadeFilhos),
      filhos: filhos ?? this.filhos,
      nomesFilhos: nomesFilhos ?? (filhos != null ? filhos.map((f) => f.nome).toList() : this.nomesFilhos),
      possuiIrmaos: possuiIrmaos ?? this.possuiIrmaos,
      irmaos: irmaos ?? this.irmaos,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      telefoneResidencial: telefoneResidencial ?? this.telefoneResidencial,
      celular: celular ?? this.celular,
      etapaFraternidade: etapaFraternidade ?? this.etapaFraternidade,
      paroquia: paroquia ?? this.paroquia,
      paroquiaEndereco: paroquiaEndereco ?? this.paroquiaEndereco,
      paroquiaCidadeUf: paroquiaCidadeUf ?? this.paroquiaCidadeUf,
      paroco: paroco ?? this.paroco,
      participaPastoral: participaPastoral ?? this.participaPastoral,
      qualPastoral: qualPastoral ?? this.qualPastoral,
      testemunhoVocacionalMatrimonial:
          testemunhoVocacionalMatrimonial ?? this.testemunhoVocacionalMatrimonial,
      experienciaServicoIgreja:
          experienciaServicoIgreja ?? this.experienciaServicoIgreja,
      conhecimentoFraternidade:
          conhecimentoFraternidade ?? this.conhecimentoFraternidade,
      pensamentoCarisma: pensamentoCarisma ?? this.pensamentoCarisma,
      chamadoComunidadeAlianca:
          chamadoComunidadeAlianca ?? this.chamadoComunidadeAlianca,
      disponibilidadeCasal: disponibilidadeCasal ?? this.disponibilidadeCasal,
      ondeMaisGostaTrabalhar:
          ondeMaisGostaTrabalhar ?? this.ondeMaisGostaTrabalhar,
      disponivelIniciarProcesso:
          disponivelIniciarProcesso ?? this.disponivelIniciarProcesso,
      anoProcessoVocacional:
          anoProcessoVocacional ?? this.anoProcessoVocacional,
      autobiografiaHistoriaPessoal:
          autobiografiaHistoriaPessoal ?? this.autobiografiaHistoriaPessoal,
      autobiografiaFamilia:
          autobiografiaFamilia ?? this.autobiografiaFamilia,
      autobiografiaIgreja:
          autobiografiaIgreja ?? this.autobiografiaIgreja,
      autobiografiaPdfBase64:
          autobiografiaPdfBase64 ?? this.autobiografiaPdfBase64,
      autobiografiaPdfNome:
          autobiografiaPdfNome ?? this.autobiografiaPdfNome,
      cadastroEtapa: cadastroEtapa ?? this.cadastroEtapa,
    );
  }
}
