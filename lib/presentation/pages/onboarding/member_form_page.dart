import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/cadastro_constants.dart';
import '../../../core/constants/localidades.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/user_entity.dart';
import '../../signals/auth_signal.dart';
import '../../signals/member_form_signal.dart';
import '../../widgets/theme_selector_widget.dart';

class MemberFormPage extends StatefulWidget {
  const MemberFormPage({super.key});

  @override
  State<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends State<MemberFormPage> {
  // Step 1 Controllers
  final _formKeyStep1 = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dataNascimentoController;
  late final TextEditingController _nomeConjugeController;
  late final TextEditingController _nomePaiController;
  late final TextEditingController _nomeMaeController;
  late final TextEditingController _rgController;
  late final TextEditingController _cpfController;
  late final TextEditingController _tituloEleitorController;
  late final TextEditingController _profissaoController;
  String _escolaridade = CadastroConstants.escolaridades.first;

  // Step 2 Controllers
  final _filhoNameController = TextEditingController();
  final _filhoDataNascimentoController = TextEditingController();
  final _filhoDialogFormKey = GlobalKey<FormState>();
  final _irmaoNameController = TextEditingController();
  final _irmaoDialogFormKey = GlobalKey<FormState>();

  // Step 3 Controllers
  final _formKeyStep3 = GlobalKey<FormState>();
  late final TextEditingController _cepController;
  late final TextEditingController _logradouroController;
  late final TextEditingController _numeroController;
  late final TextEditingController _complementoController;
  late final TextEditingController _bairroController;
  late final TextEditingController _cidadeController;
  String _uf = 'DF';
  late final TextEditingController _telResidencialController;
  late final TextEditingController _celularController;

  // Step 4 Selection
  String _etapaFraternidade = CadastroConstants.etapasFraternidade.first;
  TipoVida? _tipoVida;
  String? _localidade;

  // Step 5 Controllers
  final _formKeyStep5 = GlobalKey<FormState>();
  late final TextEditingController _paroquiaController;
  late final TextEditingController _paroquiaEnderecoController;
  late final TextEditingController _paroquiaCidadeController;
  String _paroquiaUf = 'DF';
  late final TextEditingController _parocoController;
  late final TextEditingController _qualPastoralController;

  // Step 6 Controllers
  final _formKeyStep6 = GlobalKey<FormState>();
  late final TextEditingController _testemunhoController;
  late final TextEditingController _experienciaController;
  late final TextEditingController _conhecimentoController;
  late final TextEditingController _carismaController;
  late final TextEditingController _comunidadeAliancaController;
  late final TextEditingController _disponibilidadeCasalController;
  late final TextEditingController _ondeGostaTrabalharController;
  late final TextEditingController _autobioHistoriaController;
  late final TextEditingController _autobioFamiliaController;
  late final TextEditingController _autobioIgrejaController;
  int _autobioMode = 0; // 0 = Texto por tópicos, 1 = Upload PDF

  late final phoneFormatter = AppFormatters.phoneFormatter();
  late final cpfFormatter = AppFormatters.cpfFormatter();
  late final cepFormatter = AppFormatters.cepFormatter();
  late final dateFormatter = AppFormatters.dateFormatter();

  @override
  void initState() {
    super.initState();
    final user = authSignal.currentUser.value;
    memberFormSignal.initFromUser(user);

    _nameController = TextEditingController(text: user?.nome ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.telefone ?? '');
    _dataNascimentoController = TextEditingController(text: user?.dataNascimento ?? '');
    _nomeConjugeController = TextEditingController(text: user?.nomeConjuge ?? '');
    _nomePaiController = TextEditingController(text: user?.nomePai ?? '');
    _nomeMaeController = TextEditingController(text: user?.nomeMae ?? '');
    _rgController = TextEditingController(text: user?.rg ?? '');
    _cpfController = TextEditingController(text: user?.cpf ?? '');
    _tituloEleitorController = TextEditingController(text: user?.tituloEleitor ?? '');
    _profissaoController = TextEditingController(text: user?.profissao ?? '');
    _escolaridade = user?.escolaridade ?? CadastroConstants.escolaridades.first;

    _cepController = TextEditingController(text: user?.cep ?? '');
    _logradouroController = TextEditingController(text: user?.logradouro ?? '');
    _numeroController = TextEditingController(text: user?.numero ?? '');
    _complementoController = TextEditingController(text: user?.complemento ?? '');
    _bairroController = TextEditingController(text: user?.bairro ?? '');
    _cidadeController = TextEditingController(text: user?.cidade ?? '');
    _uf = user?.uf ?? 'DF';
    _telResidencialController = TextEditingController(text: user?.telefoneResidencial ?? '');
    _celularController = TextEditingController(text: user?.celular ?? user?.telefone ?? '');

    final initialTipoVida = user?.tipoVida ?? authSignal.activeInvite.value?.tipoVida ?? TipoVida.externa;
    _tipoVida = initialTipoVida;
    _localidade = user?.localidade ?? authSignal.activeInvite.value?.localidade ?? 'BSB';

    final etapasValidas = CadastroConstants.etapasPorTipoVida(initialTipoVida);
    final initialEtapa = user?.etapaFraternidade;
    if (initialEtapa != null && etapasValidas.contains(initialEtapa)) {
      _etapaFraternidade = initialEtapa;
    } else {
      _etapaFraternidade = etapasValidas.first;
    }

    _paroquiaController = TextEditingController(text: user?.paroquia ?? '');
    _paroquiaEnderecoController = TextEditingController(text: user?.paroquiaEndereco ?? '');
    _paroquiaCidadeController = TextEditingController(text: user?.paroquiaCidadeUf ?? '');
    _parocoController = TextEditingController(text: user?.paroco ?? '');
    _qualPastoralController = TextEditingController(text: user?.qualPastoral ?? '');

    _testemunhoController = TextEditingController(text: user?.testemunhoVocacionalMatrimonial ?? '');
    _experienciaController = TextEditingController(text: user?.experienciaServicoIgreja ?? '');
    _conhecimentoController = TextEditingController(text: user?.conhecimentoFraternidade ?? '');
    _carismaController = TextEditingController(text: user?.pensamentoCarisma ?? '');
    _comunidadeAliancaController = TextEditingController(text: user?.chamadoComunidadeAlianca ?? '');
    _disponibilidadeCasalController = TextEditingController(text: user?.disponibilidadeCasal ?? '');
    _ondeGostaTrabalharController = TextEditingController(text: user?.ondeMaisGostaTrabalhar ?? '');

    _autobioHistoriaController = TextEditingController(text: user?.autobiografiaHistoriaPessoal ?? '');
    _autobioFamiliaController = TextEditingController(text: user?.autobiografiaFamilia ?? '');
    _autobioIgrejaController = TextEditingController(text: user?.autobiografiaIgreja ?? '');
    if (user?.autobiografiaPdfBase64 != null && user!.autobiografiaPdfBase64!.isNotEmpty) {
      _autobioMode = 1;
    }

    if (user?.spouseId != null && user!.spouseId!.isNotEmpty) {
      sl.userRepository.getUserById(user.spouseId!).then((sp) {
        if (sp != null && mounted) {
          _populateFromSpouse(sp, overwrite: false);
        }
      });
    }
  }

  void _populateFromSpouse(UserEntity spouse, {bool overwrite = true}) {
    // 1. Cônjuge
    if (overwrite || _nomeConjugeController.text.isEmpty) {
      _nomeConjugeController.text = spouse.nome;
    }

    // 2. Endereço Residencial (Etapa 3) - mora na mesma casa
    if (spouse.cep != null && spouse.cep!.isNotEmpty) {
      if (overwrite || _cepController.text.isEmpty) _cepController.text = spouse.cep!;
    }
    if (spouse.logradouro != null && spouse.logradouro!.isNotEmpty) {
      if (overwrite || _logradouroController.text.isEmpty) _logradouroController.text = spouse.logradouro!;
    }
    if (spouse.numero != null && spouse.numero!.isNotEmpty) {
      if (overwrite || _numeroController.text.isEmpty) _numeroController.text = spouse.numero!;
    }
    if (spouse.complemento != null && spouse.complemento!.isNotEmpty) {
      if (overwrite || _complementoController.text.isEmpty) _complementoController.text = spouse.complemento!;
    }
    if (spouse.bairro != null && spouse.bairro!.isNotEmpty) {
      if (overwrite || _bairroController.text.isEmpty) _bairroController.text = spouse.bairro!;
    }
    if (spouse.cidade != null && spouse.cidade!.isNotEmpty) {
      if (overwrite || _cidadeController.text.isEmpty) _cidadeController.text = spouse.cidade!;
    }
    if (spouse.uf != null && spouse.uf!.isNotEmpty) {
      if (overwrite || _uf.isEmpty) setState(() => _uf = spouse.uf!);
    }
    if (spouse.telefoneResidencial != null && spouse.telefoneResidencial!.isNotEmpty) {
      if (overwrite || _telResidencialController.text.isEmpty) {
        _telResidencialController.text = spouse.telefoneResidencial!;
      }
    }

    // 3. Etapa da Fraternidade (Etapa 4)
    final etapasValidas = CadastroConstants.etapasPorTipoVida(_tipoVida);
    if (spouse.etapaFraternidade != null &&
        etapasValidas.contains(spouse.etapaFraternidade)) {
      if (overwrite || _etapaFraternidade == etapasValidas.first) {
        setState(() => _etapaFraternidade = spouse.etapaFraternidade!);
      }
    }

    // 4. Paróquia e Pastoral (Etapa 5) - frequentam a mesma comunidade
    if (spouse.paroquia != null && spouse.paroquia!.isNotEmpty) {
      if (overwrite || _paroquiaController.text.isEmpty) _paroquiaController.text = spouse.paroquia!;
    }
    if (spouse.paroquiaEndereco != null && spouse.paroquiaEndereco!.isNotEmpty) {
      if (overwrite || _paroquiaEnderecoController.text.isEmpty) {
        _paroquiaEnderecoController.text = spouse.paroquiaEndereco!;
      }
    }
    if (spouse.paroquiaCidadeUf != null && spouse.paroquiaCidadeUf!.isNotEmpty) {
      if (overwrite || _paroquiaCidadeController.text.isEmpty) {
        _paroquiaCidadeController.text = spouse.paroquiaCidadeUf!;
      }
    }
    if (spouse.paroco != null && spouse.paroco!.isNotEmpty) {
      if (overwrite || _parocoController.text.isEmpty) _parocoController.text = spouse.paroco!;
    }
    if (spouse.qualPastoral != null && spouse.qualPastoral!.isNotEmpty) {
      if (overwrite || _qualPastoralController.text.isEmpty) {
        _qualPastoralController.text = spouse.qualPastoral!;
      }
    }
    memberFormSignal.participaPastoral.value = spouse.participaPastoral;

    // 5. Vocacional & Matrimonial (Etapa 6)
    if (spouse.chamadoComunidadeAlianca != null && spouse.chamadoComunidadeAlianca!.isNotEmpty) {
      if (overwrite || _comunidadeAliancaController.text.isEmpty) {
        _comunidadeAliancaController.text = spouse.chamadoComunidadeAlianca!;
      }
    }
    if (spouse.disponibilidadeCasal != null && spouse.disponibilidadeCasal!.isNotEmpty) {
      if (overwrite || _disponibilidadeCasalController.text.isEmpty) {
        _disponibilidadeCasalController.text = spouse.disponibilidadeCasal!;
      }
    }
    if (spouse.ondeMaisGostaTrabalhar != null && spouse.ondeMaisGostaTrabalhar!.isNotEmpty) {
      if (overwrite || _ondeGostaTrabalharController.text.isEmpty) {
        _ondeGostaTrabalharController.text = spouse.ondeMaisGostaTrabalhar!;
      }
    }
    memberFormSignal.disponivelIniciarProcesso.value = spouse.disponivelIniciarProcesso;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dataNascimentoController.dispose();
    _nomeConjugeController.dispose();
    _nomePaiController.dispose();
    _nomeMaeController.dispose();
    _rgController.dispose();
    _cpfController.dispose();
    _tituloEleitorController.dispose();
    _profissaoController.dispose();
    _filhoNameController.dispose();
    _filhoDataNascimentoController.dispose();
    _irmaoNameController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _telResidencialController.dispose();
    _celularController.dispose();
    _paroquiaController.dispose();
    _paroquiaEnderecoController.dispose();
    _paroquiaCidadeController.dispose();
    _parocoController.dispose();
    _qualPastoralController.dispose();
    _testemunhoController.dispose();
    _experienciaController.dispose();
    _conhecimentoController.dispose();
    _carismaController.dispose();
    _comunidadeAliancaController.dispose();
    _disponibilidadeCasalController.dispose();
    _ondeGostaTrabalharController.dispose();
    _autobioHistoriaController.dispose();
    _autobioFamiliaController.dispose();
    _autobioIgrejaController.dispose();
    super.dispose();
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da Galeria'),
              onTap: () {
                Navigator.pop(ctx);
                memberFormSignal.pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar Foto com Câmera'),
              onTap: () {
                Navigator.pop(ctx);
                memberFormSignal.pickPhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCepSearch() async {
    final cep = _cepController.text.trim();
    if (cep.length >= 8) {
      final res = await memberFormSignal.searchCep(cep);
      if (res != null && mounted) {
        if (res.logradouro.isNotEmpty) _logradouroController.text = res.logradouro;
        if (res.bairro.isNotEmpty) _bairroController.text = res.bairro;
        if (res.cidade.isNotEmpty) _cidadeController.text = res.cidade;
        if (res.uf.isNotEmpty && CadastroConstants.estadosBrasil.contains(res.uf.toUpperCase())) {
          setState(() => _uf = res.uf.toUpperCase());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço preenchido via CEP!')),
        );
      }
    }
  }

  Future<void> _handleNextStep() async {
    final step = memberFormSignal.currentStep.value;

    if (step == 1) {
      if (!_formKeyStep1.currentState!.validate()) return;
      final hasPhoto = memberFormSignal.selectedPhotoBytes.value != null ||
          (memberFormSignal.photoUrl.value != null &&
              memberFormSignal.photoUrl.value!.isNotEmpty);
      if (!hasPhoto) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor, adicione uma foto de perfil obrigatória.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      await memberFormSignal.saveStep(
        stepNumber: 1,
        stepData: {
          'nome': _nameController.text.trim(),
          'telefone': _phoneController.text.trim(),
          'dataNascimento': _dataNascimentoController.text.trim(),
          'isCasado': memberFormSignal.isCasado.value,
          'nomeConjuge': memberFormSignal.isCasado.value
              ? _nomeConjugeController.text.trim()
              : null,
          'spouseId': memberFormSignal.linkedSpouse.value?.id,
          'nomePai': !memberFormSignal.isCasado.value ? _nomePaiController.text.trim() : null,
          'nomeMae': !memberFormSignal.isCasado.value ? _nomeMaeController.text.trim() : null,
          'rg': _rgController.text.trim(),
          'cpf': _cpfController.text.trim(),
          'tituloEleitor': _tituloEleitorController.text.trim(),
          'profissao': _profissaoController.text.trim(),
          'escolaridade': _escolaridade,
        },
      );
    } else if (step == 2) {
      if (memberFormSignal.isCasado.value) {
        await memberFormSignal.saveStep(
          stepNumber: 2,
          stepData: {
            'possuiFilhos': memberFormSignal.possuiFilhos.value,
            'quantidadeFilhos': memberFormSignal.filhos.value.length,
            'filhos': memberFormSignal.filhos.value.map((f) => f.toMap()).toList(),
            'nomesFilhos': memberFormSignal.filhos.value.map((f) => f.nome).toList(),
          },
        );
      } else {
        await memberFormSignal.saveStep(
          stepNumber: 2,
          stepData: {
            'possuiIrmaos': memberFormSignal.possuiIrmaos.value,
            'irmaos': memberFormSignal.irmaos.value,
          },
        );
      }
    } else if (step == 3) {
      if (!_formKeyStep3.currentState!.validate()) return;
      await memberFormSignal.saveStep(
        stepNumber: 3,
        stepData: {
          'cep': _cepController.text.trim(),
          'logradouro': _logradouroController.text.trim(),
          'numero': _numeroController.text.trim(),
          'complemento': _complementoController.text.trim(),
          'bairro': _bairroController.text.trim(),
          'cidade': _cidadeController.text.trim(),
          'uf': _uf,
          'telefoneResidencial': _telResidencialController.text.trim(),
          'celular': _celularController.text.trim(),
        },
      );
    } else if (step == 4) {
      final stepData = <String, dynamic>{
        'etapaFraternidade': _etapaFraternidade,
      };
      if (_tipoVida != null) stepData['tipoVida'] = _tipoVida!.key;
      if (_localidade != null) stepData['localidade'] = _localidade;

      await memberFormSignal.saveStep(
        stepNumber: 4,
        stepData: stepData,
      );
    } else if (step == 5) {
      if (!_formKeyStep5.currentState!.validate()) return;
      await memberFormSignal.saveStep(
        stepNumber: 5,
        stepData: {
          'paroquia': _paroquiaController.text.trim(),
          'paroquiaEndereco': _paroquiaEnderecoController.text.trim(),
          'paroquiaCidadeUf': _paroquiaCidadeController.text.trim(),
          'paroco': _parocoController.text.trim(),
          'participaPastoral': memberFormSignal.participaPastoral.value,
          'qualPastoral': memberFormSignal.participaPastoral.value
              ? _qualPastoralController.text.trim()
              : null,
        },
      );
    } else if (step == 6) {
      if (!_formKeyStep6.currentState!.validate()) return;
      final isCasado = memberFormSignal.isCasado.value;

      if (!isCasado) {
        if (_autobioMode == 1 &&
            (memberFormSignal.autobiografiaPdfBase64.value == null ||
                memberFormSignal.autobiografiaPdfBase64.value!.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Por favor, anexe o arquivo PDF da sua autobiografia ou alterne para preenchimento por tópicos.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
      }

      final Map<String, dynamic> stepData = {
        'experienciaServicoIgreja': _experienciaController.text.trim(),
        'conhecimentoFraternidade': _conhecimentoController.text.trim(),
        'pensamentoCarisma': _carismaController.text.trim(),
        'chamadoComunidadeAlianca': _comunidadeAliancaController.text.trim(),
        'ondeMaisGostaTrabalhar': _ondeGostaTrabalharController.text.trim(),
        'disponivelIniciarProcesso': memberFormSignal.disponivelIniciarProcesso.value,
        'anoProcessoVocacional': DateTime.now().year,
      };

      if (isCasado) {
        stepData['testemunhoVocacionalMatrimonial'] = _testemunhoController.text.trim();
        stepData['disponibilidadeCasal'] = _disponibilidadeCasalController.text.trim();
      } else {
        if (_autobioMode == 0) {
          stepData['autobiografiaHistoriaPessoal'] = _autobioHistoriaController.text.trim();
          stepData['autobiografiaFamilia'] = _autobioFamiliaController.text.trim();
          stepData['autobiografiaIgreja'] = _autobioIgrejaController.text.trim();
          stepData['autobiografiaPdfBase64'] = null;
          stepData['autobiografiaPdfNome'] = null;
        } else {
          stepData['autobiografiaPdfBase64'] = memberFormSignal.autobiografiaPdfBase64.value;
          stepData['autobiografiaPdfNome'] = memberFormSignal.autobiografiaPdfNome.value;
          stepData['autobiografiaHistoriaPessoal'] = null;
          stepData['autobiografiaFamilia'] = null;
          stepData['autobiografiaIgreja'] = null;
        }
      }

      final invite = authSignal.activeInvite.value;
      final ok = await memberFormSignal.saveStep(
        stepNumber: 6,
        isFinal: true,
        invite: invite,
        stepData: stepData,
      );

      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ficha cadastral concluída com sucesso! Bem-vindo(a)!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRoutes.dashboard);
      }
    }
  }

  void _showFilhoDialog({int? editIndex}) {
    final isEditing = editIndex != null;
    if (isEditing) {
      final item = memberFormSignal.filhos.value[editIndex];
      _filhoNameController.text = item.nome;
      _filhoDataNascimentoController.text = item.dataNascimento ?? '';
    } else {
      _filhoNameController.clear();
      _filhoDataNascimentoController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dateText = _filhoDataNascimentoController.text.trim();
            final isValidDate = AppFormatters.isValidDate(dateText);
            final calculatedAge = isValidDate ? FilhoEntity.calcularIdade(dateText) : null;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_outlined : Icons.child_care_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(isEditing ? 'Editar Filho(a)' : 'Adicionar Filho(a)'),
                ],
              ),
              content: Form(
                key: _filhoDialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _filhoNameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome do filho(a)',
                        hintText: 'Ex: Maria de Fátima',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Informe o nome do filho(a)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (fieldCtx) {
                        Future<void> pickDate() async {
                          final now = DateTime.now();
                          DateTime initialDate = DateTime(now.year - 5, now.month, now.day);
                          if (isValidDate) {
                            try {
                              final parts = dateText.split('/');
                              initialDate = DateTime(
                                int.parse(parts[2]),
                                int.parse(parts[1]),
                                int.parse(parts[0]),
                              );
                            } catch (_) {}
                          }
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: initialDate.isAfter(now) ? now : initialDate,
                            firstDate: DateTime(now.year - 50),
                            lastDate: now,
                          );
                          if (picked != null) {
                            final d = picked.day.toString().padLeft(2, '0');
                            final m = picked.month.toString().padLeft(2, '0');
                            final y = picked.year.toString();
                            _filhoDataNascimentoController.text = '$d/$m/$y';
                            setDialogState(() {});
                          }
                        }

                        return TextFormField(
                          controller: _filhoDataNascimentoController,
                          readOnly: true,
                          onTap: pickDate,
                          decoration: InputDecoration(
                            labelText: 'Data de Nascimento *',
                            hintText: 'Toque para selecionar no calendário',
                            prefixIcon: const Icon(Icons.cake_outlined),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month_outlined),
                              tooltip: 'Selecionar no calendário',
                              onPressed: pickDate,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Informe a data de nascimento';
                            }
                            if (!AppFormatters.isValidDate(val.trim())) {
                              return 'Informe uma data válida (DD/MM/AAAA)';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    if (calculatedAge != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Idade calculada: ${calculatedAge == 0 ? "< 1 ano" : "$calculatedAge ${calculatedAge == 1 ? "ano" : "anos"}"}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (_filhoDialogFormKey.currentState?.validate() ?? false) {
                      final nome = _filhoNameController.text.trim();
                      final dataNasc = _filhoDataNascimentoController.text.trim();
                      final idade = FilhoEntity.calcularIdade(dataNasc);
                      if (isEditing) {
                        memberFormSignal.updateFilho(
                          editIndex,
                          nome,
                          dataNascimento: dataNasc,
                          idade: idade,
                        );
                      } else {
                        memberFormSignal.addFilho(
                          nome,
                          dataNascimento: dataNasc,
                          idade: idade,
                        );
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(isEditing ? 'Salvar' : 'Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showIrmaoDialog({int? editIndex}) {
    final isEditing = editIndex != null;
    if (isEditing) {
      _irmaoNameController.text = memberFormSignal.irmaos.value[editIndex];
    } else {
      _irmaoNameController.clear();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit_outlined : Icons.people_outline,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(isEditing ? 'Editar Irmão(ã)' : 'Adicionar Irmão(ã)'),
            ],
          ),
          content: Form(
            key: _irmaoDialogFormKey,
            child: TextFormField(
              controller: _irmaoNameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome do irmão(ã) *',
                hintText: 'Ex: Lucas Silva',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Informe o nome do irmão(ã)';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (_irmaoDialogFormKey.currentState?.validate() ?? false) {
                  final name = _irmaoNameController.text.trim();
                  if (isEditing) {
                    final list = List<String>.from(memberFormSignal.irmaos.value);
                    list[editIndex] = name;
                    memberFormSignal.irmaos.value = list;
                  } else {
                    memberFormSignal.addIrmao(name);
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(isEditing ? 'Salvar' : 'Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _showAutobiografiaInfoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Orientações da Formação',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Autobiografia Vocacional para Solteiros',
                  style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    'Para o desenvolvimento do trabalho da equipe de formação é necessário que conheçamos um pouco mais a sua história de vida, pois você demonstra querer seguir o caminho que leva a Cristo em nossa Comunidade. Assim peço que você redija uma autobiografia em forma de redação (texto corrido). A partir dela poderemos iniciar um processo que nos levará a um mútuo conhecimento e assim podermos ajudá-lo(a) no seu discernimento vocacional.\n\n'
                    'Lembre-se: não se trata de uma autobiografia para preencher requisitos burocráticos ou para demonstrar conhecimentos, mas sim de um instrumento de trabalho que nos ajudará a conhecê-lo(a) melhor. Portanto, seja sincero(a) e espontâneo(a).',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Estrutura Sugerida (3 Pontos Principais):',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  title: '1. História Pessoal',
                  icon: Icons.person_pin_rounded,
                  content: 'Onde e quando nasceu; infância; adolescência; juventude; estudos; trabalho; momentos marcantes da sua vida (alegrias, tristezas, perdas, conquistas).',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  title: '2. Família',
                  icon: Icons.family_restroom_rounded,
                  content: 'Como é a sua família; relacionamento com os pais e irmãos; valores transmitidos; momentos marcantes em família.',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildInfoSection(
                  title: '3. Participação na Igreja e Vida Espiritual',
                  icon: Icons.church_rounded,
                  content: 'Como foi o seu despertar religioso; sacramentos recebidos; participação em pastorais, movimentos ou grupos de jovens; vida de oração; o que o(a) atrai na Fraternidade e no nosso Carisma.',
                  colorScheme: colorScheme,
                  theme: theme,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Entendi, voltar ao formulário'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required String content,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAutobiografiaPdf() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (file != null) {
        final bytes = await file.readAsBytes();

        // 1MB = 1,048,576 bytes
        const maxBytes = 1048576;
        if (bytes.length > maxBytes) {
          final sizeMb = (bytes.length / (1024 * 1024)).toStringAsFixed(2);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'O arquivo possui $sizeMb MB e excede o limite máximo permitido de 1MB. Por favor, utilize uma versão comprimida.',
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
          return;
        }

        final base64String = 'data:application/pdf;base64,${base64Encode(bytes)}';
        memberFormSignal.setAutobiografiaPdf(
          base64: base64String,
          nome: file.name,
        );

        final sizeKb = (bytes.length / 1024).toStringAsFixed(1);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF "${file.name}" ($sizeKb KB) anexado com sucesso!'),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar arquivo PDF: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SignalBuilder(
      builder: (context) {
        final step = memberFormSignal.currentStep.value;
        final isSaving = memberFormSignal.isSavingStep.value;
        final err = memberFormSignal.errorMessage.value;
        final invite = authSignal.activeInvite.value;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Voltar ao Painel',
              onPressed: () => context.go(AppRoutes.dashboard),
            ),
            title: const Text('Ficha de Membro'),
            actions: [
              const ThemeSelectorButton(),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
                onPressed: () => authSignal.signOut(),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [
                    // Stepper Visual
                    _buildStepperHeader(context, step),
                    if (invite != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.card_membership_rounded, color: colorScheme.secondary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Convite Ativo: ${invite.targetRole.label}${invite.localidade != null ? " • ${invite.localidade}" : ""}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (err != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.error),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: colorScheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  err,
                                  style: TextStyle(color: colorScheme.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: _buildCurrentStepView(context, step),
                      ),
                    ),

                    // Rodapé com botões de navegação
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        border: Border(
                          top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (step > 1)
                            OutlinedButton.icon(
                              onPressed: isSaving ? null : () => memberFormSignal.goToStep(step - 1),
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Anterior'),
                            )
                          else
                            const SizedBox.shrink(),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: isSaving ? null : _handleNextStep,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(step == 6 ? Icons.check_circle : Icons.arrow_forward, size: 18),
                            label: Text(
                              step == 6
                                  ? (authSignal.currentUser.value?.isProfileComplete == true
                                      ? 'Salvar Alterações'
                                      : 'Finalizar Cadastro')
                                  : 'Salvar e Avançar',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepperHeader(BuildContext context, int currentStep) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = authSignal.currentUser.value;
    final isComplete = user?.isProfileComplete ?? false;
    final maxStepReached = isComplete ? 6 : (user?.cadastroEtapa ?? 1);

    final titles = [
      'Pessoal',
      memberFormSignal.isCasado.value ? 'Filhos' : 'Família',
      'Endereço',
      'Etapa',
      'Religião',
      'Vocacional',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final stepNum = index + 1;
          final isCurrent = stepNum == currentStep;
          final isDone = isComplete
              ? !isCurrent
              : (stepNum < currentStep || stepNum < maxStepReached);

          final canNavigate = isComplete || stepNum <= maxStepReached || stepNum <= currentStep;

          return InkWell(
            onTap: canNavigate
                ? () => memberFormSignal.goToStep(stepNum)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isDone || isCurrent
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    child: isDone
                        ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                        : Text(
                            '$stepNum',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCurrent
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    titles[index],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCurrent ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepView(BuildContext context, int step) {
    switch (step) {
      case 1:
        return _buildStep1(context);
      case 2:
        return _buildStep2(context);
      case 3:
        return _buildStep3(context);
      case 4:
        return _buildStep4(context);
      case 5:
        return _buildStep5(context);
      case 6:
        return _buildStep6(context);
      default:
        return _buildStep1(context);
    }
  }

  // ETAPA 1: Dados Pessoais & Cônjuge
  Widget _buildStep1(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedBytes = memberFormSignal.selectedPhotoBytes.value;
    final existingUrl = memberFormSignal.photoUrl.value;
    final isCasado = memberFormSignal.isCasado.value;
    final linkedSpouse = memberFormSignal.linkedSpouse.value;
    final potentialSpouses = memberFormSignal.potentialSpouses.value;
    final isSearching = memberFormSignal.isSearchingSpouse.value;

    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isCasado ? 'Etapa 1: Dados Pessoais & Cônjuge' : 'Etapa 1: Dados Pessoais & Filiação',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Informações básicas para emissão da sua ficha de membro.',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Foto de Perfil
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: Container(
                    width: 108,
                    height: 108,
                    color: colorScheme.surfaceContainerHighest,
                    child: selectedBytes != null
                        ? Image.memory(
                            selectedBytes,
                            fit: BoxFit.cover,
                            width: 108,
                            height: 108,
                          )
                        : (existingUrl != null && existingUrl.isNotEmpty)
                            ? Image.network(
                                existingUrl,
                                fit: BoxFit.cover,
                                width: 108,
                                height: 108,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Icon(Icons.person, size: 54, color: colorScheme.onSurfaceVariant),
                                ),
                              )
                            : Center(
                                child: Icon(Icons.person, size: 54, color: colorScheme.onSurfaceVariant),
                              ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: colorScheme.primary,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _showImagePickerModal,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nome Completo
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nome Completo *',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome completo' : null,
          ),
          const SizedBox(height: 14),

          // Data de Nascimento (Obrigatória para todos)
          Builder(
            builder: (ctx) {
              Future<void> pickBirthDate() async {
                final now = DateTime.now();
                DateTime initialDate = DateTime(now.year - 25, 1, 1);
                final currentText = _dataNascimentoController.text.trim();
                if (AppFormatters.isValidDate(currentText)) {
                  try {
                    final parts = currentText.split('/');
                    initialDate = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );
                  } catch (_) {}
                }
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate.isAfter(now) ? now : initialDate,
                  firstDate: DateTime(1920),
                  lastDate: now,
                );
                if (picked != null) {
                  final d = picked.day.toString().padLeft(2, '0');
                  final m = picked.month.toString().padLeft(2, '0');
                  final y = picked.year.toString();
                  setState(() {
                    _dataNascimentoController.text = '$d/$m/$y';
                  });
                }
              }

              return TextFormField(
                controller: _dataNascimentoController,
                readOnly: true,
                onTap: pickBirthDate,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento *',
                  hintText: 'Toque para selecionar no calendário',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    tooltip: 'Selecionar no calendário',
                    onPressed: pickBirthDate,
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe sua data de nascimento';
                  if (!AppFormatters.isValidDate(v.trim())) return 'Data de nascimento inválida (DD/MM/AAAA)';
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 14),

          // Celular
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [phoneFormatter],
            decoration: const InputDecoration(
              labelText: 'Celular (WhatsApp) *',
              hintText: '(61) 99999-9999',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().length < 14) ? 'Informe um telefone válido' : null,
          ),
          const SizedBox(height: 14),

          // RG & CPF
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rgController,
                  decoration: const InputDecoration(
                    labelText: 'RG *',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o RG' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [cpfFormatter],
                  decoration: const InputDecoration(
                    labelText: 'CPF *',
                    hintText: '000.000.000-00',
                    prefixIcon: Icon(Icons.assignment_ind_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 14) ? 'CPF incompleto' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Título Eleitor & Profissão
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tituloEleitorController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Título de Eleitor (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _profissaoController,
                  decoration: const InputDecoration(
                    labelText: 'Profissão (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Escolaridade
          DropdownButtonFormField<String>(
            initialValue: _escolaridade,
            decoration: const InputDecoration(
              labelText: 'Escolaridade',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(),
            ),
            items: CadastroConstants.escolaridades
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _escolaridade = v);
            },
          ),
          const SizedBox(height: 24),

          // Estado Civil: Casado Sim / Não
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'É casado(a)?',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Não')),
                        ButtonSegment(value: true, label: Text('Sim')),
                      ],
                      selected: {isCasado},
                      onSelectionChanged: (set) {
                        memberFormSignal.isCasado.value = set.first;
                      },
                    ),
                  ],
                ),
                if (isCasado) ...[
                  const SizedBox(height: 16),
                  if (linkedSpouse != null) ...[
                    // Card de Cônjuge Vinculado
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.favorite_rounded, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cônjuge Vinculado:',
                                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                                ),
                                Text(
                                  linkedSpouse.nome,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => memberFormSignal.unlinkSpouse(),
                            child: const Text('Alterar'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _nomeConjugeController,
                      decoration: InputDecoration(
                        labelText: 'Nome Completo do Cônjuge *',
                        prefixIcon: const Icon(Icons.favorite_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: isSearching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                          tooltip: 'Buscar Cônjuge no Sistema',
                          onPressed: () => memberFormSignal.searchSpouses(_nomeConjugeController.text),
                        ),
                      ),
                      validator: (v) {
                        if (isCasado && (v == null || v.trim().isEmpty)) {
                          return 'Informe o nome do cônjuge';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        if (val.trim().length >= 2) {
                          memberFormSignal.searchSpouses(val);
                        } else if (val.trim().isEmpty) {
                          memberFormSignal.searchSpouses('');
                        }
                      },
                    ),
                    if (potentialSpouses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Encontramos membros com este nome no sistema. Deseja vincular?',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                      ),
                      const SizedBox(height: 6),
                      ...potentialSpouses.map((s) {
                            final currentUid = authSignal.currentUser.value?.id;
                            final isSelf = s.id == currentUid;
                            final isAlreadyLinkedToOther = s.isCasado &&
                                s.spouseId != null &&
                                s.spouseId!.isNotEmpty &&
                                s.spouseId != currentUid;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(s.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  isSelf
                                      ? 'Seu próprio perfil (não é possível vincular)'
                                      : (isAlreadyLinkedToOther
                                          ? 'Já possui cônjuge vinculado no sistema'
                                          : s.email),
                                  style: TextStyle(
                                    color: (isSelf || isAlreadyLinkedToOther)
                                        ? colorScheme.error
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: (isSelf || isAlreadyLinkedToOther)
                                    ? Chip(
                                        label: const Text('Indisponível', style: TextStyle(fontSize: 11)),
                                        backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.5),
                                        visualDensity: VisualDensity.compact,
                                      )
                                    : memberFormSignal.isLinkingSpouse.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : FilledButton.tonal(
                                            onPressed: () async {
                                              _nomeConjugeController.text = s.nome;
                                              final ok = await memberFormSignal.linkWithSpouse(s);
                                              if (!context.mounted) return;
                                              if (ok) {
                                                _populateFromSpouse(s, overwrite: true);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Vínculo com ${s.nome} realizado com sucesso! Endereço, paróquia e vocação preenchidos automaticamente.'),
                                                    backgroundColor: Colors.green.shade700,
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(memberFormSignal.errorMessage.value ?? 'Erro ao vincular cônjuge'),
                                                    backgroundColor: Colors.red.shade700,
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text('Vincular'),
                                          ),
                              ),
                            );
                          }),
                    ],
                  ],
                ],
                if (!isCasado) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Filiação (Pais)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Informações sobre seus pais para seu registro comunitário.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomePaiController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Pai *',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (!memberFormSignal.isCasado.value && (v == null || v.trim().isEmpty)) {
                        return 'Informe o nome do seu pai';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomeMaeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Mãe *',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (!memberFormSignal.isCasado.value && (v == null || v.trim().isEmpty)) {
                        return 'Informe o nome da sua mãe';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ETAPA 2: Filhos & Família (Casados) / Família & Irmãos (Solteiros)
  Widget _buildStep2(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCasado = memberFormSignal.isCasado.value;
    final possuiFilhos = memberFormSignal.possuiFilhos.value;
    final filhos = memberFormSignal.filhos.value;
    final possuiIrmaos = memberFormSignal.possuiIrmaos.value;
    final irmaos = memberFormSignal.irmaos.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isCasado ? 'Etapa 2: Filhos & Família' : 'Etapa 2: Família & Irmãos',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isCasado
              ? 'Informações sobre seus filhos para a pastoral familiar.'
              : 'Informações sobre seus irmãos e estrutura familiar.',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),

        if (isCasado) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Possui filhos?',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Não')),
                        ButtonSegment(value: true, label: Text('Sim')),
                      ],
                      selected: {possuiFilhos},
                      onSelectionChanged: (set) {
                        memberFormSignal.possuiFilhos.value = set.first;
                      },
                    ),
                  ],
                ),
                if (possuiFilhos) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filhos cadastrados: ${filhos.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _showFilhoDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar Filho(a)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filhos.isEmpty)
                    Text(
                      'Nenhum filho adicionado ainda. Clique em "Adicionar Filho(a)".',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(filhos.length, (i) {
                        final filho = filhos[i];
                        final idadeDesc = filho.idade == 0
                            ? '< 1 ano'
                            : '${filho.idade} ${filho.idade == 1 ? "ano" : "anos"}';
                        final nascSuffix = (filho.dataNascimento != null && filho.dataNascimento!.isNotEmpty)
                            ? ' • Nasc: ${filho.dataNascimento}'
                            : '';
                        return InputChip(
                          avatar: const Icon(Icons.child_care_rounded, size: 18),
                          label: Text('${filho.nome} ($idadeDesc$nascSuffix)'),
                          tooltip: 'Toque para editar',
                          onPressed: () => _showFilhoDialog(editIndex: i),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => memberFormSignal.removeFilho(i),
                        );
                      }),
                    ),
                ],
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Possui irmãos?',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Não')),
                        ButtonSegment(value: true, label: Text('Sim')),
                      ],
                      selected: {possuiIrmaos},
                      onSelectionChanged: (set) {
                        memberFormSignal.possuiIrmaos.value = set.first;
                      },
                    ),
                  ],
                ),
                if (possuiIrmaos) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Irmãos cadastrados: ${irmaos.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _showIrmaoDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar Irmão(ã)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (irmaos.isEmpty)
                    Text(
                      'Nenhum irmão adicionado ainda. Clique em "Adicionar Irmão(ã)".',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(irmaos.length, (i) {
                        final irmao = irmaos[i];
                        return InputChip(
                          avatar: const Icon(Icons.person, size: 18),
                          label: Text(irmao),
                          tooltip: 'Toque para editar',
                          onPressed: () => _showIrmaoDialog(editIndex: i),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => memberFormSignal.removeIrmao(i),
                        );
                      }),
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ETAPA 3: Endereço Residencial
  Widget _buildStep3(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFetchingCep = memberFormSignal.isFetchingCep.value;

    return Form(
      key: _formKeyStep3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Etapa 3: Endereço Residencial',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Digite o CEP para preenchimento automático do endereço.',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // CEP
          TextFormField(
            controller: _cepController,
            keyboardType: TextInputType.number,
            inputFormatters: [cepFormatter],
            decoration: InputDecoration(
              labelText: 'CEP *',
              hintText: '00000-000',
              prefixIcon: const Icon(Icons.pin_drop_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: isFetchingCep
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                tooltip: 'Buscar CEP',
                onPressed: _handleCepSearch,
              ),
            ),
            validator: (v) => (v == null || v.trim().length < 9) ? 'CEP inválido' : null,
            onChanged: (val) {
              if (val.length == 9) _handleCepSearch();
            },
          ),
          const SizedBox(height: 14),

          // Logradouro e Número
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _logradouroController,
                  decoration: const InputDecoration(
                    labelText: 'Logradouro / Rua *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a rua' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _numeroController,
                  decoration: const InputDecoration(
                    labelText: 'Número *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nº' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Complemento e Bairro
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _complementoController,
                  decoration: const InputDecoration(
                    labelText: 'Complemento (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o bairro' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cidade e UF
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a cidade' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _uf,
                  decoration: const InputDecoration(
                    labelText: 'UF *',
                    border: OutlineInputBorder(),
                  ),
                  items: CadastroConstants.estadosBrasil
                      .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _uf = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Telefone Residencial & Celular
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _telResidencialController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [phoneFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Tel. Residencial (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _celularController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [phoneFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Celular Adicional',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ETAPA 4: Vínculo Comunitário & Caminho na Fraternidade
  Widget _buildStep4(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = authSignal.currentUser.value;
    final canEditInstitutional = currentUser?.role.canEditMemberInstitutional ?? false;
    final tipoVidaAtual = _tipoVida ?? TipoVida.externa;
    final localidadeAtual = _localidade ?? 'BSB';
    final localidadeNome = Localidades.nomePorSigla(localidadeAtual);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Etapa 4: Vínculo Comunitário & Caminho Vocacional',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Confira seu vínculo institucional e selecione sua etapa atual de formação.',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),

        // Cartão de Destaque: Vínculo Institucional (Tipo de Vida e Localidade)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Vínculo Institucional na Fraternidade',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                canEditInstitutional
                    ? 'Como administrador / secretaria, você pode alterar o Tipo de Vida e a Localidade deste membro.'
                    : 'Estes dados foram definidos institucionalmente no seu convite de ingresso.',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Campo 1: Tipo de Vida (Vida Interna vs Vida Externa)
              Text(
                'Tipo de Vida:',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (canEditInstitutional) ...[
                SegmentedButton<TipoVida>(
                  segments: const [
                    ButtonSegment(
                      value: TipoVida.externa,
                      icon: Icon(Icons.people_outline),
                      label: Text('Vida Externa'),
                    ),
                    ButtonSegment(
                      value: TipoVida.interna,
                      icon: Icon(Icons.home_work_outlined),
                      label: Text('Vida Interna'),
                    ),
                  ],
                  selected: {tipoVidaAtual},
                  onSelectionChanged: (set) {
                    setState(() {
                      _tipoVida = set.first;
                      final novasEtapas = CadastroConstants.etapasPorTipoVida(_tipoVida);
                      if (!novasEtapas.contains(_etapaFraternidade)) {
                        _etapaFraternidade = novasEtapas.first;
                      }
                    });
                  },
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tipoVidaAtual == TipoVida.interna
                            ? Icons.home_work_outlined
                            : Icons.people_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tipoVidaAtual.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const Tooltip(
                        message: 'Definido institucionalmente pelo convite. Apenas o Fundador ou a Secretaria podem alterar.',
                        child: Icon(Icons.lock_outline, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Campo 2: Localidade da Fraternidade
              Text(
                'Localidade da Fraternidade:',
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (canEditInstitutional) ...[
                DropdownButtonFormField<String>(
                  initialValue: Localidades.todas.any((l) => l.sigla == localidadeAtual)
                      ? localidadeAtual
                      : Localidades.brasilia.sigla,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: Localidades.todas.map((loc) {
                    return DropdownMenuItem<String>(
                      value: loc.sigla,
                      child: Text(loc.rotuloCompleto),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _localidade = val);
                  },
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: colorScheme.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$localidadeNome (${localidadeAtual.toUpperCase()})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const Tooltip(
                        message: 'Definido institucionalmente pelo convite. Apenas o Fundador ou a Secretaria podem alterar.',
                        child: Icon(Icons.lock_outline, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Etapa no Caminho da Fraternidade:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecione a etapa que melhor corresponde ao seu momento formativo atual.',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),

        Builder(
          builder: (context) {
            final etapas = CadastroConstants.etapasPorTipoVida(tipoVidaAtual);
            final valorSelecionado = etapas.contains(_etapaFraternidade)
                ? _etapaFraternidade
                : etapas.first;

            return DropdownButtonFormField<String>(
              key: ValueKey('etapa_${tipoVidaAtual.key}_$valorSelecionado'),
              initialValue: valorSelecionado,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Etapa Formativa (${tipoVidaAtual.label}) *',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                prefixIcon: const Icon(Icons.school_outlined),
              ),
              items: etapas
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _etapaFraternidade = val);
                }
              },
            );
          },
        ),
      ],
    );
  }

  // ETAPA 5: Vivência Religiosa & Paroquial
  Widget _buildStep5(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final participaPastoral = memberFormSignal.participaPastoral.value;

    return Form(
      key: _formKeyStep5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Etapa 5: Vivência Religiosa & Paroquial',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Informações sobre sua participação na paróquia e comunidade eclesial.',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // Paróquia
          TextFormField(
            controller: _paroquiaController,
            decoration: const InputDecoration(
              labelText: 'Paróquia que participa *',
              prefixIcon: Icon(Icons.church_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a paróquia' : null,
          ),
          const SizedBox(height: 14),

          // Endereço da Paróquia
          TextFormField(
            controller: _paroquiaEnderecoController,
            decoration: const InputDecoration(
              labelText: 'Endereço da Paróquia',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),

          // Cidade - UF da Paróquia
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _paroquiaCidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade da Paróquia',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _paroquiaUf,
                  decoration: const InputDecoration(
                    labelText: 'UF',
                    border: OutlineInputBorder(),
                  ),
                  items: CadastroConstants.estadosBrasil
                      .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _paroquiaUf = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pároco
          TextFormField(
            controller: _parocoController,
            decoration: const InputDecoration(
              labelText: 'Nome do Pároco',
              prefixIcon: Icon(Icons.person_pin_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Pastoral / Movimento
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Participa de algum movimento ou pastoral na paróquia?',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Não')),
                        ButtonSegment(value: true, label: Text('Sim')),
                      ],
                      selected: {participaPastoral},
                      onSelectionChanged: (set) {
                        memberFormSignal.participaPastoral.value = set.first;
                      },
                    ),
                  ],
                ),
                if (participaPastoral) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _qualPastoralController,
                    decoration: const InputDecoration(
                      labelText: 'Qual pastoral ou movimento? *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (participaPastoral && (v == null || v.trim().isEmpty)) {
                        return 'Informe o nome da pastoral ou movimento';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ETAPA 6: Dados Vocacionais & Matrimoniais (ou Autobiografia para Solteiros)
  Widget _buildStep6(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCasado = memberFormSignal.isCasado.value;
    final disponivel = memberFormSignal.disponivelIniciarProcesso.value;
    final pdfBase64 = memberFormSignal.autobiografiaPdfBase64.value;
    final pdfNome = memberFormSignal.autobiografiaPdfNome.value;
    final anoAtual = DateTime.now().year;

    return Form(
      key: _formKeyStep6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isCasado ? 'Etapa 6: Dados Vocacionais & Matrimoniais' : 'Etapa 6: Dados Vocacionais & Autobiografia',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCasado
                ? 'Partilhe sobre sua experiência, discernimento e disponibilidade vocacional da família.'
                : 'Partilhe sua caminhada, autobiografia e discernimento vocacional.',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          if (isCasado) ...[
            // Testemunho vocacional matrimonial
            TextFormField(
              controller: _testemunhoController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Testemunho vocacional matrimonial *',
                hintText: 'Comente sobre o chamado de Deus para sua família...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) => (isCasado && (v == null || v.trim().isEmpty)) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
          ] else ...[
            // Solteiro: Autobiografia Card & Modo de Envio
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Autobiografia Vocacional',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Para conhecermos melhor sua história de vida e caminhada vocacional, pedimos sua autobiografia sincera e espontânea.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _showAutobiografiaInfoModal,
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Ver Orientações e Roteiro da Formação'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Como prefere entregar sua autobiografia?',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        icon: Icon(Icons.edit_note_rounded),
                        label: Text('Digitar por Tópicos'),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: Icon(Icons.picture_as_pdf_outlined),
                        label: Text('Anexar PDF (até 1MB)'),
                      ),
                    ],
                    selected: {_autobioMode},
                    onSelectionChanged: (set) {
                      setState(() => _autobioMode = set.first);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_autobioMode == 0) ...[
              // 3 Text fields
              TextFormField(
                controller: _autobioHistoriaController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: '1. História Pessoal *',
                  hintText: 'Onde e quando nasceu, infância, adolescência, juventude, estudos, trabalho, momentos marcantes...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (!isCasado && _autobioMode == 0 && (v == null || v.trim().isEmpty)) {
                    return 'Por favor, compartilhe sua história pessoal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _autobioFamiliaController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '2. Família *',
                  hintText: 'Como é a sua família, relacionamento com pais e irmãos, valores transmitidos, momentos marcantes...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (!isCasado && _autobioMode == 0 && (v == null || v.trim().isEmpty)) {
                    return 'Por favor, compartilhe sobre sua família';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _autobioIgrejaController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '3. Participação na Igreja e Vida Espiritual *',
                  hintText: 'Despertar religioso, sacramentos, pastorais/movimentos, oração, o que atrai na Fraternidade...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (!isCasado && _autobioMode == 0 && (v == null || v.trim().isEmpty)) {
                    return 'Por favor, compartilhe sua vivência na Igreja';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Upload PDF
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red.shade700, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pdfBase64 != null
                                    ? (pdfNome ?? 'Arquivo PDF Anexado')
                                    : 'Nenhum arquivo PDF anexado',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: pdfBase64 != null ? Colors.green.shade800 : null,
                                ),
                              ),
                              Text(
                                pdfBase64 != null
                                    ? 'PDF pronto para envio (armazenamento otimizado)'
                                    : 'Formatos aceitos: PDF (máx. 1MB)',
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _pickAutobiografiaPdf,
                          icon: Icon(pdfBase64 != null ? Icons.refresh : Icons.upload_file),
                          label: Text(pdfBase64 != null ? 'Trocar PDF' : 'Selecionar Arquivo PDF'),
                        ),
                        if (pdfBase64 != null) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              memberFormSignal.setAutobiografiaPdf(base64: null, nome: null);
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Remover'),
                            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],

          // Experiência de serviço
          TextFormField(
            controller: _experienciaController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: isCasado
                  ? 'Experiência de serviço à Igreja e pastoral na vida familiar *'
                  : 'Experiência de serviço à Igreja e engajamento pastoral *',
              hintText: 'Comente sua vivência pastoral...',
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),

          // Conhecimento sobre a Fraternidade
          TextFormField(
            controller: _conhecimentoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Conhecimento sobre a Fraternidade *',
              hintText: 'Comente em poucas palavras o vosso conhecimento...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),

          // O que pensa sobre o Carisma
          TextFormField(
            controller: _carismaController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'O que pensa sobre o Carisma da Fraternidade? *',
              hintText: 'Compartilhe sua percepção sobre o carisma...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),

          // Comunidade ou Aliança
          TextFormField(
            controller: _comunidadeAliancaController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Chamado à vida em comunidade ou em aliança? Comente *',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),

          if (isCasado) ...[
            // Disponibilidade do casal
            TextFormField(
              controller: _disponibilidadeCasalController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Disponibilidade para exigências da comunidade *',
                hintText: 'Formações, missões, encontros e funções...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) => (isCasado && (v == null || v.trim().isEmpty)) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
          ],

          // Em que mais gosta de trabalhar
          TextFormField(
            controller: _ondeGostaTrabalharController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: isCasado
                  ? 'Em que mais gostam de trabalhar na Igreja? *'
                  : 'Em que mais gosta de trabalhar na Igreja? *',
              border: const OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 20),

          // Disponível a iniciar processo vocacional neste ano
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isCasado
                        ? 'Disponíveis a iniciar o processo Vocacional neste ano de $anoAtual?'
                        : 'Disponível a iniciar o processo Vocacional neste ano de $anoAtual?',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Não')),
                    ButtonSegment(value: true, label: Text('Sim')),
                  ],
                  selected: {disponivel},
                  onSelectionChanged: (set) {
                    memberFormSignal.disponivelIniciarProcesso.value = set.first;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
