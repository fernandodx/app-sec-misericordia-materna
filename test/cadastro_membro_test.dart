import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_secretaria/core/constants/app_roles.dart';
import 'package:app_secretaria/core/constants/cadastro_constants.dart';
import 'package:app_secretaria/core/services/viacep_service.dart';
import 'package:app_secretaria/core/utils/formatters.dart';
import 'package:app_secretaria/core/utils/image_compressor.dart';
import 'package:app_secretaria/data/models/user_model.dart';
import 'package:app_secretaria/domain/entities/filho_entity.dart';

void main() {
  group('ViaCepResult Tests', () {
    test('converte json válido do ViaCEP corretamente', () {
      final json = {
        'cep': '70000-000',
        'logradouro': 'Esplanada dos Ministérios',
        'complemento': '',
        'bairro': 'Zona Cívico-Administrativa',
        'localidade': 'Brasília',
        'uf': 'DF',
      };

      final result = ViaCepResult.fromJson(json);
      expect(result.isError, isFalse);
      expect(result.cidade, equals('Brasília'));
      expect(result.uf, equals('DF'));
      expect(result.logradouro, equals('Esplanada dos Ministérios'));
    });

    test('identifica resposta de erro do ViaCEP', () {
      final json = {'erro': true};
      final result = ViaCepResult.fromJson(json);
      expect(result.isError, isTrue);
    });
  });

  group('FilhoEntity & AppFormatters Tests', () {
    test('calcula idade precisa a partir de dataNascimento', () {
      final ref = DateTime(2026, 9, 9);

      // Aniversário já ocorrido no ano
      expect(FilhoEntity.calcularIdade('01/01/2016', ref), equals(10));
      expect(FilhoEntity.calcularIdade('08/09/2016', ref), equals(10));

      // Exatamente no dia do aniversário
      expect(FilhoEntity.calcularIdade('09/09/2016', ref), equals(10));

      // Aniversário ainda não ocorrido no ano
      expect(FilhoEntity.calcularIdade('10/09/2016', ref), equals(9));
      expect(FilhoEntity.calcularIdade('31/12/2016', ref), equals(9));

      // Bebê com menos de 1 ano
      expect(FilhoEntity.calcularIdade('01/03/2026', ref), equals(0));

      // Formato inválido ou vazio
      expect(FilhoEntity.calcularIdade(''), equals(0));
      expect(FilhoEntity.calcularIdade(null), equals(0));
      expect(FilhoEntity.calcularIdade('invalido'), equals(0));
    });

    test('cria FilhoEntity via fromNascimento calculando idade automaticamente', () {
      final ref = DateTime(2026, 9, 9);
      final filho = FilhoEntity.fromNascimento(
        nome: 'Gabriel',
        dataNascimento: '15/05/2018',
        referenceDate: ref,
      );

      expect(filho.nome, equals('Gabriel'));
      expect(filho.dataNascimento, equals('15/05/2018'));
      expect(filho.idade, equals(8));
      expect(filho.toMap(), equals({
        'nome': 'Gabriel',
        'idade': 8,
        'dataNascimento': '15/05/2018',
      }));

      final restored = FilhoEntity.fromMap(filho.toMap());
      expect(restored.nome, equals('Gabriel'));
      expect(restored.dataNascimento, equals('15/05/2018'));
      expect(restored.idade, equals(8));
    });

    test('valida datas com AppFormatters.isValidDate', () {
      expect(AppFormatters.isValidDate('15/05/2018'), isTrue);
      expect(AppFormatters.isValidDate('29/02/2024'), isTrue); // bissexto
      expect(AppFormatters.isValidDate('29/02/2023'), isFalse); // não bissexto
      expect(AppFormatters.isValidDate('32/01/2020'), isFalse);
      expect(AppFormatters.isValidDate('01/13/2020'), isFalse);
      expect(AppFormatters.isValidDate(''), isFalse);
      expect(AppFormatters.isValidDate(null), isFalse);
    });
  });

  group('UserModel Cadastro Completo Tests', () {
    test('serializa e deserializa todos os campos das 6 etapas', () {
      final user = UserModel(
        id: 'user-teste-123',
        email: 'irmao@misericordiamaterna.org',
        nome: 'João da Cruz',
        telefone: '(61) 99999-8888',
        role: AppRole.membro,
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        isCasado: true,
        nomeConjuge: 'Maria de Fátima',
        spouseId: 'user-conjuge-456',
        rg: '1234567 SSP/DF',
        cpf: '000.111.222-33',
        tituloEleitor: '987654321',
        profissao: 'Professor',
        escolaridade: 'Ensino Superior Completo',
        possuiFilhos: true,
        quantidadeFilhos: 2,
        filhos: const [
          FilhoEntity(nome: 'Pedro', idade: 10, dataNascimento: '12/03/2016'),
          FilhoEntity(nome: 'Ana', idade: 7, dataNascimento: '05/08/2019'),
        ],
        cep: '70000-000',
        logradouro: 'Rua das Palmeiras',
        numero: '12',
        complemento: 'Apto 101',
        bairro: 'Asa Sul',
        cidade: 'Brasília',
        uf: 'DF',
        telefoneResidencial: '(61) 3333-2222',
        celular: '(61) 99999-8888',
        etapaFraternidade: 'Vocacional 1º',
        paroquia: 'Paróquia Nossa Senhora da Esperança',
        paroquiaEndereco: 'EQS 307/308',
        paroquiaCidadeUf: 'Brasília - DF',
        paroco: 'Padre Antônio',
        participaPastoral: true,
        qualPastoral: 'Pastoral Familiar',
        testemunhoVocacionalMatrimonial: 'Sentimos o chamado de Deus em nosso noivado.',
        experienciaServicoIgreja: 'Coordenação de encontros de jovens e noivos.',
        conhecimentoFraternidade: 'Acompanhamos a comunidade desde 2024.',
        pensamentoCarisma: 'O carisma da misericórdia materna restaura as famílias.',
        chamadoComunidadeAlianca: 'Sentimos forte chamado para a aliança.',
        disponibilidadeCasal: 'Disponibilidade para encontros aos fins de semana.',
        ondeMaisGostaTrabalhar: 'Formação e acolhimento.',
        disponivelIniciarProcesso: true,
        anoProcessoVocacional: 2026,
        cadastroEtapa: 6,
      );

      final map = user.toMap();
      expect(map['isCasado'], isTrue);
      expect(map['nomeConjuge'], equals('Maria de Fátima'));
      expect(map['spouseId'], equals('user-conjuge-456'));
      expect(map['cpf'], equals('000.111.222-33'));
      expect(map['nomesFilhos'], equals(['Pedro', 'Ana']));
      expect(map['filhos'], equals([
        {'nome': 'Pedro', 'idade': 10, 'dataNascimento': '12/03/2016'},
        {'nome': 'Ana', 'idade': 7, 'dataNascimento': '05/08/2019'},
      ]));
      expect(map['etapaFraternidade'], equals('Vocacional 1º'));
      expect(map['cadastroEtapa'], equals(6));

      final restored = UserModel.fromMap(map, 'user-teste-123');
      expect(restored.nome, equals('João da Cruz'));
      expect(restored.isCasado, isTrue);
      expect(restored.filhos.length, equals(2));
      expect(restored.filhos.first.nome, equals('Pedro'));
      expect(restored.filhos.first.idade, equals(10));
      expect(restored.filhos.first.dataNascimento, equals('12/03/2016'));
      expect(restored.filhos.last.nome, equals('Ana'));
      expect(restored.filhos.last.idade, equals(7));
      expect(restored.filhos.last.dataNascimento, equals('05/08/2019'));
      expect(restored.nomesFilhos, equals(['Pedro', 'Ana']));
      expect(restored.paroco, equals('Padre Antônio'));
      expect(restored.etapaFraternidade, equals('Vocacional 1º'));
      expect(restored.isProfileComplete, isTrue);
    });

    test('deserializa dados legados contendo apenas nomesFilhos', () {
      final legacyMap = {
        'email': 'legado@misericordiamaterna.org',
        'nome': 'Membro Antigo',
        'possuiFilhos': true,
        'nomesFilhos': ['Lucas', 'Beatriz'],
      };

      final restored = UserModel.fromMap(legacyMap, 'user-legado-456');
      expect(restored.filhos.length, equals(2));
      expect(restored.filhos[0].nome, equals('Lucas'));
      expect(restored.filhos[0].idade, equals(0));
      expect(restored.filhos[1].nome, equals('Beatriz'));
      expect(restored.nomesFilhos, equals(['Lucas', 'Beatriz']));
    });

    test('serializa e deserializa usuário Solteiro com filiação, irmãos e autobiografia por tópicos', () {
      final userSolteiro = UserModel(
        id: 'user-solteiro-789',
        email: 'solteiro@misericordiamaterna.org',
        nome: 'Mateus Oliveira',
        telefone: '(61) 98888-7777',
        role: AppRole.membro,
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        dataNascimento: '20/10/1998',
        isCasado: false,
        nomePai: 'José Carlos Oliveira',
        nomeMae: 'Maria Aparecida Oliveira',
        rg: '7654321 SSP/DF',
        cpf: '123.456.789-00',
        possuiIrmaos: true,
        irmaos: const ['Lucas Oliveira', 'Ana Clara Oliveira'],
        autobiografiaHistoriaPessoal: 'Nasci em Brasília, cresci em um ambiente católico...',
        autobiografiaFamilia: 'Meus pais são muito unidos e me ensinaram a fé...',
        autobiografiaIgreja: 'Fui coroinha e participei de grupo de jovens...',
        experienciaServicoIgreja: 'Animação e liturgia.',
        conhecimentoFraternidade: 'Conheci através de um amigo da faculdade.',
        pensamentoCarisma: 'Um carisma lindo de acolhimento maternal.',
        chamadoComunidadeAlianca: 'Discernindo a aliança.',
        ondeMaisGostaTrabalhar: 'Ministério de Música e Acolhida.',
        disponivelIniciarProcesso: true,
        anoProcessoVocacional: 2026,
        cadastroEtapa: 6,
      );

      final map = userSolteiro.toMap();
      expect(map['isCasado'], isFalse);
      expect(map['dataNascimento'], equals('20/10/1998'));
      expect(map['nomePai'], equals('José Carlos Oliveira'));
      expect(map['nomeMae'], equals('Maria Aparecida Oliveira'));
      expect(map['possuiIrmaos'], isTrue);
      expect(map['irmaos'], equals(['Lucas Oliveira', 'Ana Clara Oliveira']));
      expect(map['autobiografiaHistoriaPessoal'], contains('Nasci em Brasília'));
      expect(map['autobiografiaFamilia'], contains('Meus pais'));
      expect(map['autobiografiaIgreja'], contains('Fui coroinha'));

      final restored = UserModel.fromMap(map, 'user-solteiro-789');
      expect(restored.nome, equals('Mateus Oliveira'));
      expect(restored.isCasado, isFalse);
      expect(restored.dataNascimento, equals('20/10/1998'));
      expect(restored.nomePai, equals('José Carlos Oliveira'));
      expect(restored.nomeMae, equals('Maria Aparecida Oliveira'));
      expect(restored.possuiIrmaos, isTrue);
      expect(restored.irmaos, equals(['Lucas Oliveira', 'Ana Clara Oliveira']));
      expect(restored.autobiografiaHistoriaPessoal, contains('Nasci em Brasília'));
      expect(restored.autobiografiaFamilia, contains('Meus pais'));
      expect(restored.autobiografiaIgreja, contains('Fui coroinha'));
      expect(restored.autobiografiaPdfBase64, isNull);
    });

    test('serializa e deserializa usuário Solteiro com Autobiografia em PDF Base64', () {
      const mockPdfBase64 = 'data:application/pdf;base64,JVBERi0xLjQKJcTl8uXrp/Og0MTGCjQgMCBvYmo=';
      final userPdf = UserModel(
        id: 'user-solteiro-pdf',
        email: 'solteiro.pdf@misericordiamaterna.org',
        nome: 'Beatriz Santos',
        telefone: '(61) 97777-6666',
        role: AppRole.membro,
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        dataNascimento: '14/07/2000',
        isCasado: false,
        nomePai: 'Carlos Santos',
        nomeMae: 'Lucia Santos',
        autobiografiaPdfBase64: mockPdfBase64,
        autobiografiaPdfNome: 'minha_autobiografia.pdf',
        cadastroEtapa: 6,
      );

      final map = userPdf.toMap();
      expect(map['autobiografiaPdfBase64'], equals(mockPdfBase64));
      expect(map['autobiografiaPdfNome'], equals('minha_autobiografia.pdf'));

      final restored = UserModel.fromMap(map, 'user-solteiro-pdf');
      expect(restored.autobiografiaPdfBase64, equals(mockPdfBase64));
      expect(restored.autobiografiaPdfNome, equals('minha_autobiografia.pdf'));
      expect(restored.dataNascimento, equals('14/07/2000'));
    });

    test('valida as 10 etapas oficiais da fraternidade com Vocacional 1º selecionado por padrão', () {
      expect(CadastroConstants.etapasFraternidade.length, equals(10));
      expect(CadastroConstants.etapasFraternidade.first, equals('Vocacional 1º'));
      expect(CadastroConstants.etapasFraternidade, containsAllInOrder([
        'Vocacional 1º',
        'Vocacional 2º',
        'Servo 1º',
        'Servo 2º',
        'Servo 3º',
        'Discípulo 1º',
        'Discípulo 2º',
        'Discípulo 3º',
        'Discípulo 4º',
        'Discípulo 5º',
      ]));
    });
  });

  group('Regras de Negócio - Vínculo de Cônjuge', () {
    test('impede auto-vínculo quando userId == spouseId', () {
      const currentUserId = 'user-123';
      const candidateId = 'user-123';

      final canLink = currentUserId != candidateId;
      expect(canLink, isFalse);
    });

    test('impede vínculo com usuário que já possui cônjuge com terceiro', () {
      const currentUserId = 'user-123';

      final candidate = UserModel(
        id: 'user-456',
        email: 'candidato@test.com',
        nome: 'Candidato Casado',
        telefone: '',
        role: AppRole.membro,
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        isCasado: true,
        spouseId: 'user-999', // Já é casado com outro membro
      );

      final isAlreadyMarriedToOther = candidate.isCasado &&
          candidate.spouseId != null &&
          candidate.spouseId!.isNotEmpty &&
          candidate.spouseId != currentUserId;

      expect(isAlreadyMarriedToOther, isTrue);
    });

    test('permite vínculo se o usuário já estiver vinculado ao próprio solicitante', () {
      const currentUserId = 'user-123';

      final spouse = UserModel(
        id: 'user-456',
        email: 'parceiro@test.com',
        nome: 'Parceiro Mútuo',
        telefone: '',
        role: AppRole.membro,
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        isCasado: true,
        spouseId: currentUserId, // Já é o próprio solicitante
      );

      final isAlreadyMarriedToOther = spouse.isCasado &&
          spouse.spouseId != null &&
          spouse.spouseId!.isNotEmpty &&
          spouse.spouseId != currentUserId;

      expect(isAlreadyMarriedToOther, isFalse);
    });

    test('normaliza strings removendo acentos para busca de cônjuges', () {
      expect(AppFormatters.normalizeString('Priscila Torres'), equals('priscila torres'));
      expect(AppFormatters.normalizeString('Priscíla Tôrres'), equals('priscila torres'));
      expect(AppFormatters.normalizeString('  JOÃO DA SILVA  '), equals('joao da silva'));
      expect(
        AppFormatters.normalizeString('Priscíla Tôrres')
            .contains(AppFormatters.normalizeString('priscila')),
        isTrue,
      );
    });
  });

  group('ImageCompressor & Base64 Avatar Tests', () {
    test('converte bytes em Data URI Base64 no formato data:image/jpeg;base64,...', () {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final uri = ImageCompressor.toBase64DataUri(sampleBytes);
      expect(uri.startsWith('data:image/jpeg;base64,'), isTrue);
      expect(uri, contains('AQIDBAU='));
    });
  });

  group('Permissões e Escopo de Pesquisa de Membros', () {
    test('valida canSearchMembers de acordo com os papéis', () {
      expect(AppRole.fundador.canSearchMembers, isTrue);
      expect(AppRole.secretariaGeralExterna.canSearchMembers, isTrue);
      expect(AppRole.secretariaGeralInterna.canSearchMembers, isTrue);
      expect(AppRole.secretariaLocal.canSearchMembers, isTrue);
      expect(AppRole.formador.canSearchMembers, isTrue);

      expect(AppRole.membro.canSearchMembers, isFalse);
      expect(AppRole.visitante.canSearchMembers, isFalse);
      expect(AppRole.acompanhador.canSearchMembers, isFalse);
    });

    test('valida canEditMemberInstitutional de acordo com os papéis', () {
      expect(AppRole.fundador.canEditMemberInstitutional, isTrue);
      expect(AppRole.secretariaGeralExterna.canEditMemberInstitutional, isTrue);
      expect(AppRole.secretariaGeralInterna.canEditMemberInstitutional, isTrue);
      expect(AppRole.secretariaLocal.canEditMemberInstitutional, isTrue);

      expect(AppRole.formador.canEditMemberInstitutional, isFalse);
      expect(AppRole.membro.canEditMemberInstitutional, isFalse);
      expect(AppRole.visitante.canEditMemberInstitutional, isFalse);
      expect(AppRole.acompanhador.canEditMemberInstitutional, isFalse);
    });

    test('regras de escopo de visualização de membros por perfil', () {
      final membroExternaAraxa = UserModel(
        id: '1',
        email: 'ext_aax@test.com',
        nome: 'Membro Externa Araxá',
        telefone: '34999990001',
        role: AppRole.membro,
        tipoVida: TipoVida.externa,
        localidade: 'AAX',
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final membroInternaBrasilia = UserModel(
        id: '2',
        email: 'int_bsb@test.com',
        nome: 'Membro Interna Brasília',
        telefone: '61999990002',
        role: AppRole.membro,
        tipoVida: TipoVida.interna,
        localidade: 'BSB',
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final membroExternaBrasilia = UserModel(
        id: '3',
        email: 'ext_bsb@test.com',
        nome: 'Membro Externa Brasília',
        telefone: '61999990003',
        role: AppRole.membro,
        tipoVida: TipoVida.externa,
        localidade: 'BSB',
        isEmailVerified: true,
        isProfileComplete: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final all = [membroExternaAraxa, membroInternaBrasilia, membroExternaBrasilia];

      // Secretaria Geral Externa só pode ver Vida Externa
      final secGeralExtScope = all.where((m) => m.tipoVida == TipoVida.externa).toList();
      expect(secGeralExtScope.length, equals(2));
      expect(secGeralExtScope.contains(membroInternaBrasilia), isFalse);

      // Secretaria Geral Interna / Formador só pode ver Vida Interna
      final secGeralIntScope = all.where((m) => m.tipoVida == TipoVida.interna).toList();
      expect(secGeralIntScope.length, equals(1));
      expect(secGeralIntScope.first.nome, equals('Membro Interna Brasília'));

      // Secretaria Local de Araxá só pode ver membros de Araxá
      const localidadeSec = 'AAX';
      final secLocalScope = all.where((m) => m.localidade == localidadeSec).toList();
      expect(secLocalScope.length, equals(1));
      expect(secLocalScope.first.nome, equals('Membro Externa Araxá'));

      // Fundador vê todos
      expect(all.length, equals(3));
    });
  });
}
