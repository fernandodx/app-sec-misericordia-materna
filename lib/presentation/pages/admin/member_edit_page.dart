import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/cadastro_constants.dart';
import '../../../core/constants/localidades.dart';
import '../../../core/services/viacep_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/user_entity.dart';
import '../../signals/auth_signal.dart';
import '../../signals/member_search_signal.dart';
import '../../widgets/theme_selector_widget.dart';

class MemberEditPage extends StatefulWidget {
  final UserEntity member;

  const MemberEditPage({
    super.key,
    required this.member,
  });

  static Future<UserEntity?> navigate(BuildContext context, UserEntity member) {
    return Navigator.of(context).push<UserEntity>(
      MaterialPageRoute(
        builder: (_) => MemberEditPage(member: member),
      ),
    );
  }

  @override
  State<MemberEditPage> createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // 1. Pessoal
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _celularController;
  late final TextEditingController _dataNascimentoController;
  late final TextEditingController _cpfController;
  late final TextEditingController _rgController;
  late final TextEditingController _tituloEleitorController;
  late final TextEditingController _profissaoController;
  String? _escolaridade;
  late final TextEditingController _nomePaiController;
  late final TextEditingController _nomeMaeController;

  // 2. Endereço
  late final TextEditingController _cepController;
  late final TextEditingController _logradouroController;
  late final TextEditingController _numeroController;
  late final TextEditingController _complementoController;
  late final TextEditingController _bairroController;
  late final TextEditingController _cidadeController;
  String? _uf;
  late final TextEditingController _telefoneResidencialController;
  bool _isBuscandoCep = false;

  // 3. Família
  late bool _isCasado;
  late final TextEditingController _nomeConjugeController;
  late bool _possuiFilhos;
  late List<FilhoEntity> _filhos;
  late bool _possuiIrmaos;
  late List<String> _irmaos;
  final _novoIrmaoController = TextEditingController();

  // 4. Vivência Eclesial
  late final TextEditingController _paroquiaController;
  late final TextEditingController _paroquiaEnderecoController;
  late final TextEditingController _paroquiaCidadeUfController;
  late final TextEditingController _parocoController;
  late bool _participaPastoral;
  late final TextEditingController _qualPastoralController;

  // 5. Vocacional
  late final TextEditingController _anoProcessoVocacionalController;
  late bool _disponivelIniciarProcesso;
  late final TextEditingController _testemunhoController;
  late final TextEditingController _experienciaServicoController;
  late final TextEditingController _conhecimentoFraternidadeController;
  late final TextEditingController _pensamentoCarismaController;
  late final TextEditingController _chamadoComunidadeAliancaController;
  late final TextEditingController _disponibilidadeCasalController;
  late final TextEditingController _ondeMaisGostaTrabalharController;
  late final TextEditingController _autobiografiaHistoriaController;
  late final TextEditingController _autobiografiaFamiliaController;
  late final TextEditingController _autobiografiaIgrejaController;

  // 6. Institucional
  late TipoVida _tipoVida;
  late String _localidade;
  late String _etapaFraternidade;
  late AppRole _role;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    final m = widget.member;

    // Pessoal
    _nomeController = TextEditingController(text: m.nome);
    _emailController = TextEditingController(text: m.email);
    _telefoneController = TextEditingController(text: m.telefone);
    _celularController = TextEditingController(text: m.celular ?? '');
    _dataNascimentoController =
        TextEditingController(text: m.dataNascimento ?? '');
    _cpfController = TextEditingController(text: m.cpf ?? '');
    _rgController = TextEditingController(text: m.rg ?? '');
    _tituloEleitorController =
        TextEditingController(text: m.tituloEleitor ?? '');
    _profissaoController = TextEditingController(text: m.profissao ?? '');
    _escolaridade = m.escolaridade;
    _nomePaiController = TextEditingController(text: m.nomePai ?? '');
    _nomeMaeController = TextEditingController(text: m.nomeMae ?? '');

    // Endereço
    _cepController = TextEditingController(text: m.cep ?? '');
    _logradouroController = TextEditingController(text: m.logradouro ?? '');
    _numeroController = TextEditingController(text: m.numero ?? '');
    _complementoController = TextEditingController(text: m.complemento ?? '');
    _bairroController = TextEditingController(text: m.bairro ?? '');
    _cidadeController = TextEditingController(text: m.cidade ?? '');
    _uf = m.uf?.toUpperCase();
    _telefoneResidencialController =
        TextEditingController(text: m.telefoneResidencial ?? '');

    // Família
    _isCasado = m.isCasado;
    _nomeConjugeController = TextEditingController(text: m.nomeConjuge ?? '');
    _possuiFilhos = m.possuiFilhos || m.filhos.isNotEmpty;
    _filhos = List<FilhoEntity>.from(m.filhos);
    _possuiIrmaos = m.possuiIrmaos || m.irmaos.isNotEmpty;
    _irmaos = List<String>.from(m.irmaos);

    // Eclesial
    _paroquiaController = TextEditingController(text: m.paroquia ?? '');
    _paroquiaEnderecoController =
        TextEditingController(text: m.paroquiaEndereco ?? '');
    _paroquiaCidadeUfController =
        TextEditingController(text: m.paroquiaCidadeUf ?? '');
    _parocoController = TextEditingController(text: m.paroco ?? '');
    _participaPastoral = m.participaPastoral;
    _qualPastoralController =
        TextEditingController(text: m.qualPastoral ?? '');

    // Vocacional
    _anoProcessoVocacionalController = TextEditingController(
      text: m.anoProcessoVocacional?.toString() ??
          DateTime.now().year.toString(),
    );
    _disponivelIniciarProcesso = m.disponivelIniciarProcesso;
    _testemunhoController =
        TextEditingController(text: m.testemunhoVocacionalMatrimonial ?? '');
    _experienciaServicoController =
        TextEditingController(text: m.experienciaServicoIgreja ?? '');
    _conhecimentoFraternidadeController =
        TextEditingController(text: m.conhecimentoFraternidade ?? '');
    _pensamentoCarismaController =
        TextEditingController(text: m.pensamentoCarisma ?? '');
    _chamadoComunidadeAliancaController =
        TextEditingController(text: m.chamadoComunidadeAlianca ?? '');
    _disponibilidadeCasalController =
        TextEditingController(text: m.disponibilidadeCasal ?? '');
    _ondeMaisGostaTrabalharController =
        TextEditingController(text: m.ondeMaisGostaTrabalhar ?? '');
    _autobiografiaHistoriaController =
        TextEditingController(text: m.autobiografiaHistoriaPessoal ?? '');
    _autobiografiaFamiliaController =
        TextEditingController(text: m.autobiografiaFamilia ?? '');
    _autobiografiaIgrejaController =
        TextEditingController(text: m.autobiografiaIgreja ?? '');

    // Institucional
    _tipoVida = m.tipoVida ?? TipoVida.externa;
    _localidade = Localidades.resolver(m.localidade)?.sigla ??
        Localidades.brasilia.sigla;

    final etapasValidas = CadastroConstants.etapasPorTipoVida(_tipoVida);
    if (m.etapaFraternidade != null &&
        etapasValidas.contains(m.etapaFraternidade)) {
      _etapaFraternidade = m.etapaFraternidade!;
    } else {
      _etapaFraternidade = etapasValidas.first;
    }

    _role = m.role;
  }

  @override
  void dispose() {
    _tabController.dispose();

    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _celularController.dispose();
    _dataNascimentoController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _tituloEleitorController.dispose();
    _profissaoController.dispose();
    _nomePaiController.dispose();
    _nomeMaeController.dispose();

    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _telefoneResidencialController.dispose();

    _nomeConjugeController.dispose();
    _novoIrmaoController.dispose();

    _paroquiaController.dispose();
    _paroquiaEnderecoController.dispose();
    _paroquiaCidadeUfController.dispose();
    _parocoController.dispose();
    _qualPastoralController.dispose();

    _anoProcessoVocacionalController.dispose();
    _testemunhoController.dispose();
    _experienciaServicoController.dispose();
    _conhecimentoFraternidadeController.dispose();
    _pensamentoCarismaController.dispose();
    _chamadoComunidadeAliancaController.dispose();
    _disponibilidadeCasalController.dispose();
    _ondeMaisGostaTrabalharController.dispose();
    _autobiografiaHistoriaController.dispose();
    _autobiografiaFamiliaController.dispose();
    _autobiografiaIgrejaController.dispose();

    super.dispose();
  }

  Future<void> _buscarCep() async {
    final rawCep = _cepController.text.trim();
    final cleanDigits = rawCep.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um CEP válido com 8 dígitos para buscar.'),
        ),
      );
      return;
    }

    setState(() => _isBuscandoCep = true);
    try {
      final result = await ViaCepService.fetchCep(cleanDigits);
      if (!mounted) return;

      if (result != null && !result.isError) {
        setState(() {
          if (result.logradouro.isNotEmpty) {
            _logradouroController.text = result.logradouro;
          }
          if (result.bairro.isNotEmpty) {
            _bairroController.text = result.bairro;
          }
          if (result.cidade.isNotEmpty) {
            _cidadeController.text = result.cidade;
          }
          if (result.uf.isNotEmpty &&
              CadastroConstants.estadosBrasil
                  .contains(result.uf.toUpperCase())) {
            _uf = result.uf.toUpperCase();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço localizado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CEP não encontrado ou serviço indisponível.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao consultar o CEP. Preencha manualmente.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBuscandoCep = false);
      }
    }
  }

  void _adicionarOuEditarFilho({FilhoEntity? filhoExistente, int? index}) {
    final nomeFilhoCtrl =
        TextEditingController(text: filhoExistente?.nome ?? '');
    final dataNascFilhoCtrl =
        TextEditingController(text: filhoExistente?.dataNascimento ?? '');
    final formFilhoKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            filhoExistente == null ? 'Adicionar Filho(a)' : 'Editar Filho(a)',
          ),
          content: Form(
            key: formFilhoKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeFilhoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo do filho(a) *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: dataNascFilhoCtrl,
                    inputFormatters: [AppFormatters.dateFormatter()],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento (DD/MM/AAAA) *',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: 15/04/2012',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Informe a data de nascimento';
                      }
                      if (!AppFormatters.isValidDate(val)) {
                        return 'Data inválida ou futura';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formFilhoKey.currentState?.validate() ?? false) {
                  final novoFilho = FilhoEntity.fromNascimento(
                    nome: nomeFilhoCtrl.text.trim(),
                    dataNascimento: dataNascFilhoCtrl.text.trim(),
                  );
                  setState(() {
                    if (index != null && index >= 0 && index < _filhos.length) {
                      _filhos[index] = novoFilho;
                    } else {
                      _filhos.add(novoFilho);
                    }
                    _possuiFilhos = true;
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Salvar Filho'),
            ),
          ],
        );
      },
    );
  }

  void _adicionarIrmao() {
    final nome = _novoIrmaoController.text.trim();
    if (nome.isEmpty) return;
    setState(() {
      _irmaos.add(nome);
      _novoIrmaoController.clear();
      _possuiIrmaos = true;
    });
  }

  Future<void> _salvarAlteracoes() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros destacados no formulário.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final currentUser = authSignal.currentUser.value;
    if (currentUser == null || !currentUser.role.canEditMemberInstitutional) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem permissão para alterar dados deste membro.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final anoVoc = int.tryParse(_anoProcessoVocacionalController.text.trim());

      final updated = widget.member.copyWith(
        // Pessoal
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        telefone: _telefoneController.text.trim(),
        celular: _celularController.text.trim().isNotEmpty
            ? _celularController.text.trim()
            : null,
        dataNascimento: _dataNascimentoController.text.trim().isNotEmpty
            ? _dataNascimentoController.text.trim()
            : null,
        cpf: _cpfController.text.trim().isNotEmpty
            ? _cpfController.text.trim()
            : null,
        rg: _rgController.text.trim().isNotEmpty
            ? _rgController.text.trim()
            : null,
        tituloEleitor: _tituloEleitorController.text.trim().isNotEmpty
            ? _tituloEleitorController.text.trim()
            : null,
        profissao: _profissaoController.text.trim().isNotEmpty
            ? _profissaoController.text.trim()
            : null,
        escolaridade: _escolaridade,
        nomePai: _nomePaiController.text.trim().isNotEmpty
            ? _nomePaiController.text.trim()
            : null,
        nomeMae: _nomeMaeController.text.trim().isNotEmpty
            ? _nomeMaeController.text.trim()
            : null,

        // Endereço
        cep: _cepController.text.trim().isNotEmpty
            ? _cepController.text.trim()
            : null,
        logradouro: _logradouroController.text.trim().isNotEmpty
            ? _logradouroController.text.trim()
            : null,
        numero: _numeroController.text.trim().isNotEmpty
            ? _numeroController.text.trim()
            : null,
        complemento: _complementoController.text.trim().isNotEmpty
            ? _complementoController.text.trim()
            : null,
        bairro: _bairroController.text.trim().isNotEmpty
            ? _bairroController.text.trim()
            : null,
        cidade: _cidadeController.text.trim().isNotEmpty
            ? _cidadeController.text.trim()
            : null,
        uf: _uf,
        telefoneResidencial: _telefoneResidencialController.text.trim().isNotEmpty
            ? _telefoneResidencialController.text.trim()
            : null,

        // Família
        isCasado: _isCasado,
        nomeConjuge: _isCasado && _nomeConjugeController.text.trim().isNotEmpty
            ? _nomeConjugeController.text.trim()
            : null,
        possuiFilhos: _isCasado && _possuiFilhos,
        filhos: _isCasado && _possuiFilhos ? _filhos : [],
        quantidadeFilhos: _isCasado && _possuiFilhos ? _filhos.length : 0,
        nomesFilhos:
            _isCasado && _possuiFilhos ? _filhos.map((f) => f.nome).toList() : [],
        possuiIrmaos: !_isCasado && _possuiIrmaos,
        irmaos: !_isCasado && _possuiIrmaos ? _irmaos : [],

        // Eclesial
        paroquia: _paroquiaController.text.trim().isNotEmpty
            ? _paroquiaController.text.trim()
            : null,
        paroquiaEndereco: _paroquiaEnderecoController.text.trim().isNotEmpty
            ? _paroquiaEnderecoController.text.trim()
            : null,
        paroquiaCidadeUf: _paroquiaCidadeUfController.text.trim().isNotEmpty
            ? _paroquiaCidadeUfController.text.trim()
            : null,
        paroco: _parocoController.text.trim().isNotEmpty
            ? _parocoController.text.trim()
            : null,
        participaPastoral: _participaPastoral,
        qualPastoral: _participaPastoral &&
                _qualPastoralController.text.trim().isNotEmpty
            ? _qualPastoralController.text.trim()
            : null,

        // Vocacional
        anoProcessoVocacional: anoVoc,
        disponivelIniciarProcesso: _disponivelIniciarProcesso,
        testemunhoVocacionalMatrimonial:
            _testemunhoController.text.trim().isNotEmpty
                ? _testemunhoController.text.trim()
                : null,
        experienciaServicoIgreja:
            _experienciaServicoController.text.trim().isNotEmpty
                ? _experienciaServicoController.text.trim()
                : null,
        conhecimentoFraternidade:
            _conhecimentoFraternidadeController.text.trim().isNotEmpty
                ? _conhecimentoFraternidadeController.text.trim()
                : null,
        pensamentoCarisma:
            _pensamentoCarismaController.text.trim().isNotEmpty
                ? _pensamentoCarismaController.text.trim()
                : null,
        chamadoComunidadeAlianca:
            _chamadoComunidadeAliancaController.text.trim().isNotEmpty
                ? _chamadoComunidadeAliancaController.text.trim()
                : null,
        disponibilidadeCasal:
            _disponibilidadeCasalController.text.trim().isNotEmpty
                ? _disponibilidadeCasalController.text.trim()
                : null,
        ondeMaisGostaTrabalhar:
            _ondeMaisGostaTrabalharController.text.trim().isNotEmpty
                ? _ondeMaisGostaTrabalharController.text.trim()
                : null,
        autobiografiaHistoriaPessoal:
            _autobiografiaHistoriaController.text.trim().isNotEmpty
                ? _autobiografiaHistoriaController.text.trim()
                : null,
        autobiografiaFamilia:
            _autobiografiaFamiliaController.text.trim().isNotEmpty
                ? _autobiografiaFamiliaController.text.trim()
                : null,
        autobiografiaIgreja:
            _autobiografiaIgrejaController.text.trim().isNotEmpty
                ? _autobiografiaIgrejaController.text.trim()
                : null,

        // Institucional
        tipoVida: _tipoVida,
        localidade: _localidade,
        etapaFraternidade: _etapaFraternidade,
        role: _role,
      );

      final success = await memberSearchSignal.saveFullMember(updated);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados do membro atualizados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updated);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              memberSearchSignal.errorMessage.value ??
                  'Erro ao salvar dados do membro.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alterar Cadastro de Membro',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.member.nome,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          const ThemeSelectorButton(),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _salvarAlteracoes,
              icon: _isSaving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar'),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Pessoal'),
            Tab(icon: Icon(Icons.home_outlined), text: 'Endereço'),
            Tab(icon: Icon(Icons.people_outline), text: 'Família'),
            Tab(icon: Icon(Icons.church_outlined), text: 'Igreja'),
            Tab(icon: Icon(Icons.lightbulb_outline), text: 'Vocacional'),
            Tab(icon: Icon(Icons.admin_panel_settings_outlined), text: 'Institucional'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContainer(colorScheme, _buildTabPessoal(colorScheme)),
            _buildTabContainer(colorScheme, _buildTabEndereco(colorScheme)),
            _buildTabContainer(colorScheme, _buildTabFamilia(colorScheme)),
            _buildTabContainer(colorScheme, _buildTabIgreja(colorScheme)),
            _buildTabContainer(colorScheme, _buildTabVocacional(colorScheme)),
            _buildTabContainer(colorScheme, _buildTabInstitucional(colorScheme)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _isSaving ? null : _salvarAlteracoes,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: _isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: Text(
                  _isSaving ? 'Salvando Alterações...' : 'Salvar Alterações',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContainer(ColorScheme colorScheme, Widget content) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: content,
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: DADOS PESSOAIS & DOCUMENTOS
  // ==========================================
  Widget _buildTabPessoal(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          colorScheme,
          Icons.badge_outlined,
          'Identificação & Contato',
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nomeController,
          decoration: const InputDecoration(
            labelText: 'Nome Completo *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (val) {
            if (val == null || val.trim().length < 3) {
              return 'Informe o nome completo (ao menos 3 letras)';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-mail Principal *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (val) {
            if (!AppFormatters.isValidEmail(val)) {
              return 'Informe um e-mail válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _telefoneController,
                inputFormatters: [AppFormatters.phoneFormatter()],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone / WhatsApp *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o telefone';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _celularController,
                inputFormatters: [AppFormatters.phoneFormatter()],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Celular Adicional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.smartphone_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          colorScheme,
          Icons.document_scanner_outlined,
          'Documentos & Nascimento',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _dataNascimentoController,
                inputFormatters: [AppFormatters.dateFormatter()],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(),
                  hintText: 'DD/MM/AAAA',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                validator: (val) {
                  if (val != null &&
                      val.trim().isNotEmpty &&
                      !AppFormatters.isValidDate(val)) {
                    return 'Data inválida';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cpfController,
                inputFormatters: [AppFormatters.cpfFormatter()],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fingerprint_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _rgController,
                decoration: const InputDecoration(
                  labelText: 'RG',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _tituloEleitorController,
                decoration: const InputDecoration(
                  labelText: 'Título de Eleitor',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          colorScheme,
          Icons.school_outlined,
          'Profissão & Filiação',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _profissaoController,
                decoration: const InputDecoration(
                  labelText: 'Profissão',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _escolaridade,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Escolaridade',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Não informada'),
                  ),
                  ...CadastroConstants.escolaridades.map(
                    (e) => DropdownMenuItem(value: e, child: Text(e)),
                  ),
                ],
                onChanged: (val) => setState(() => _escolaridade = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _nomePaiController,
          decoration: const InputDecoration(
            labelText: 'Nome do Pai',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.male),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _nomeMaeController,
          decoration: const InputDecoration(
            labelText: 'Nome da Mãe',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.female),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: ENDEREÇO RESIDENCIAL
  // ==========================================
  Widget _buildTabEndereco(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          colorScheme,
          Icons.location_on_outlined,
          'Endereço Residencial',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _cepController,
                inputFormatters: [AppFormatters.cepFormatter()],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  border: const OutlineInputBorder(),
                  hintText: '00000-000',
                  suffixIcon: _isBuscandoCep
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: 'Buscar CEP via ViaCEP',
                          onPressed: _buscarCep,
                        ),
                ),
                onFieldSubmitted: (_) => _buscarCep(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonalIcon(
              onPressed: _isBuscandoCep ? null : _buscarCep,
              icon: const Icon(Icons.travel_explore, size: 18),
              label: const Text('Buscar CEP'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _logradouroController,
                decoration: const InputDecoration(
                  labelText: 'Logradouro (Rua / Av / Quadra)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(
                  labelText: 'Número',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _complementoController,
                decoration: const InputDecoration(
                  labelText: 'Complemento / Apto',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(
                  labelText: 'Bairro',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(
                  labelText: 'Cidade',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                initialValue: _uf != null && CadastroConstants.estadosBrasil.contains(_uf)
                    ? _uf
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'UF',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('UF'),
                  ),
                  ...CadastroConstants.estadosBrasil.map(
                    (estado) => DropdownMenuItem(
                      value: estado,
                      child: Text(estado),
                    ),
                  ),
                ],
                onChanged: (val) => setState(() => _uf = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _telefoneResidencialController,
          inputFormatters: [AppFormatters.phoneFormatter()],
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefone Residencial / Fixo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_in_talk_outlined),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: FAMÍLIA & VÍNCULOS
  // ==========================================
  Widget _buildTabFamilia(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          colorScheme,
          Icons.favorite_outline,
          'Estado Civil & Cônjuge',
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _isCasado ? 'Casado(a)' : 'Solteiro(a)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _isCasado
                        ? 'Permite cadastrar cônjuge e filhos'
                        : 'Permite cadastrar informações de irmãos e autobiografia',
                  ),
                  value: _isCasado,
                  onChanged: (val) => setState(() => _isCasado = val),
                ),
                if (_isCasado) ...[
                  const Divider(height: 24),
                  TextFormField(
                    controller: _nomeConjugeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Cônjuge',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // SE CASADO: FILHOS
        if (_isCasado) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(
                colorScheme,
                Icons.child_care_outlined,
                'Filhos (${_filhos.length})',
              ),
              FilledButton.tonalIcon(
                onPressed: () => _adicionarOuEditarFilho(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar Filho'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Possui Filhos?'),
            value: _possuiFilhos,
            onChanged: (val) => setState(() => _possuiFilhos = val),
          ),
          if (_possuiFilhos && _filhos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Center(
                child: Text(
                  'Nenhum filho cadastrado ainda. Clique em "Adicionar Filho".',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else if (_possuiFilhos)
            ..._filhos.asMap().entries.map((entry) {
              final idx = entry.key;
              final f = entry.value;
              return Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      '${idx + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: Text(
                    f.nome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Idade: ${f.idade} anos'
                    '${f.dataNascimento != null ? ' • Nasc: ${f.dataNascimento}' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Editar',
                        onPressed: () => _adicionarOuEditarFilho(
                          filhoExistente: f,
                          index: idx,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: Colors.redAccent),
                        tooltip: 'Remover',
                        onPressed: () {
                          setState(() {
                            _filhos.removeAt(idx);
                            if (_filhos.isEmpty) _possuiFilhos = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
        ] else ...[
          // SE SOLTEIRO: IRMÃOS
          _buildSectionHeader(
            colorScheme,
            Icons.family_restroom_outlined,
            'Irmãos (${_irmaos.length})',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Possui Irmãos?'),
            value: _possuiIrmaos,
            onChanged: (val) => setState(() => _possuiIrmaos = val),
          ),
          if (_possuiIrmaos) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _novoIrmaoController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Irmão(ã)',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _adicionarIrmao(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: _adicionarIrmao,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _irmaos.asMap().entries.map((entry) {
                final idx = entry.key;
                final nome = entry.value;
                return Chip(
                  label: Text(nome),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _irmaos.removeAt(idx);
                      if (_irmaos.isEmpty) _possuiIrmaos = false;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ],
    );
  }

  // ==========================================
  // TAB 4: VIVÊNCIA ECLESIAL & PAROQUIAL
  // ==========================================
  Widget _buildTabIgreja(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          colorScheme,
          Icons.church_outlined,
          'Paróquia & Comunidade Eclesial',
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _paroquiaController,
          decoration: const InputDecoration(
            labelText: 'Nome da Paróquia onde congrega',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _paroquiaEnderecoController,
          decoration: const InputDecoration(
            labelText: 'Endereço da Paróquia',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.map_outlined),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _paroquiaCidadeUfController,
                decoration: const InputDecoration(
                  labelText: 'Cidade / UF da Paróquia',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _parocoController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Pároco',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_pin_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          colorScheme,
          Icons.volunteer_activism_outlined,
          'Engajamento Pastoral',
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Participa de alguma pastoral ou movimento?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: _participaPastoral,
                  onChanged: (val) => setState(() => _participaPastoral = val),
                ),
                if (_participaPastoral) ...[
                  const Divider(height: 24),
                  TextFormField(
                    controller: _qualPastoralController,
                    decoration: const InputDecoration(
                      labelText: 'Qual pastoral ou movimento?',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: Pastoral da Família, RCC, MECE, Liturgia...',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 5: DADOS VOCACIONAIS & AUTOBIOGRAFIA
  // ==========================================
  Widget _buildTabVocacional(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          colorScheme,
          Icons.explore_outlined,
          'Processo Vocacional',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _anoProcessoVocacionalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ano do Processo Vocacional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Disponível para Iniciar Processo?'),
                value: _disponivelIniciarProcesso,
                onChanged: (val) =>
                    setState(() => _disponivelIniciarProcesso = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          colorScheme,
          Icons.chat_bubble_outline,
          'Testemunho & Carisma',
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _testemunhoController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Testemunho Vocacional / Matrimonial',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _experienciaServicoController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Experiência de Serviço na Igreja',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _conhecimentoFraternidadeController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Como conheceu a Fraternidade Misericórdia Materna?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _pensamentoCarismaController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'O que pensa / sente em relação ao Carisma?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _chamadoComunidadeAliancaController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Chamado para a Comunidade de Aliança',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ondeMaisGostaTrabalharController,
                decoration: const InputDecoration(
                  labelText: 'Onde mais gosta de trabalhar / servir',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _disponibilidadeCasalController,
                decoration: const InputDecoration(
                  labelText: 'Disponibilidade de Tempo / Dias',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),

        // Autobiografia para Solteiros ou notas livres
        const SizedBox(height: 24),
        _buildSectionHeader(
          colorScheme,
          Icons.auto_stories_outlined,
          'Autobiografia & Notas Pessoais',
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _autobiografiaHistoriaController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'História Pessoal',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _autobiografiaFamiliaController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Família de Origem',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _autobiografiaIgrejaController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Caminhada na Igreja',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 6: GESTÃO INSTITUCIONAL & PAPEL
  // ==========================================
  Widget _buildTabInstitucional(ColorScheme colorScheme) {
    final currentUser = authSignal.currentUser.value;
    final currentUserRole = currentUser?.role ?? AppRole.visitante;

    // Regras de Papel
    final targetIsFundador = widget.member.role == AppRole.fundador;
    final currentUserIsFundador = currentUserRole.isFundador;
    final allowedRoles = currentUserRole.rolesPermitidasParaAtribuir;

    // Localidade restrita se Secretaria Local
    final isLocalidadeLocked = currentUserRole == AppRole.secretariaLocal;

    // Etapas disponíveis para o Tipo de Vida selecionado
    final etapas = CadastroConstants.etapasPorTipoVida(_tipoVida);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          colorScheme,
          Icons.admin_panel_settings_outlined,
          'Enquadramento Institucional',
        ),
        const SizedBox(height: 16),

        // 1. Tipo de Vida (SegmentedButton)
        Text(
          'Tipo de Vida',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<TipoVida>(
          segments: const [
            ButtonSegment(
              value: TipoVida.externa,
              label: Text('Vida Externa'),
              icon: Icon(Icons.people_outline),
            ),
            ButtonSegment(
              value: TipoVida.interna,
              label: Text('Vida Interna'),
              icon: Icon(Icons.apartment_outlined),
            ),
          ],
          selected: {_tipoVida},
          onSelectionChanged: (Set<TipoVida> newSelection) {
            setState(() {
              _tipoVida = newSelection.first;
              final novasEtapas = CadastroConstants.etapasPorTipoVida(_tipoVida);
              if (!novasEtapas.contains(_etapaFraternidade)) {
                _etapaFraternidade = novasEtapas.first;
              }
            });
          },
        ),
        const SizedBox(height: 20),

        // 2. Fraternidade / Localidade
        Text(
          'Fraternidade / Localidade',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('localidade_$_localidade'),
          initialValue: _localidade,
          isExpanded: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            enabled: !isLocalidadeLocked,
          ),
          items: Localidades.todas
              .map(
                (l) => DropdownMenuItem(
                  value: l.sigla,
                  child: Text('${l.nome} (${l.sigla})'),
                ),
              )
              .toList(),
          onChanged: isLocalidadeLocked
              ? null
              : (val) {
                  if (val != null) setState(() => _localidade = val);
                },
        ),
        const SizedBox(height: 20),

        // 3. Etapa do Caminho (Dinâmica)
        Text(
          'Etapa do Caminho (${_tipoVida.displayName})',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('etapa_${_tipoVida.key}_$_etapaFraternidade'),
          initialValue: etapas.contains(_etapaFraternidade)
              ? _etapaFraternidade
              : etapas.first,
          isExpanded: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
          ),
          items: etapas
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _etapaFraternidade = val);
          },
        ),
        const SizedBox(height: 20),

        // 4. Papel no Sistema (Role)
        Text(
          'Papel / Nível de Acesso no Sistema',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (targetIsFundador && !currentUserIsFundador) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline, size: 20, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Papel atual: Fundador.\nSomente outro Fundador possui autorização para alterar este papel.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (allowedRoles.isNotEmpty) ...[
          DropdownButtonFormField<AppRole>(
            key: ValueKey('role_combo_$_role'),
            initialValue: allowedRoles.contains(_role) ? _role : allowedRoles.first,
            isExpanded: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
            ),
            items: allowedRoles
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.displayName, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _role = val);
            },
          ),
        ] else ...[
          Text(
            'Seu perfil (${currentUserRole.displayName}) não tem permissão para alterar papéis de acesso.',
            style: TextStyle(color: colorScheme.error, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(ColorScheme colorScheme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
