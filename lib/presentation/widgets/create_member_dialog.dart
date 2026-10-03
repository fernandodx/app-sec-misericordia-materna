import 'package:flutter/material.dart';
import '../../core/constants/app_roles.dart';
import '../../core/constants/cadastro_constants.dart';
import '../../core/constants/localidades.dart';
import '../../domain/entities/user_entity.dart';
import '../signals/auth_signal.dart';
import '../signals/member_search_signal.dart';

class CreateMemberDialog extends StatefulWidget {
  const CreateMemberDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateMemberDialog(),
    );
  }

  @override
  State<CreateMemberDialog> createState() => _CreateMemberDialogState();
}

class _CreateMemberDialogState extends State<CreateMemberDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  late AppRole _selectedRole;
  late TipoVida _selectedTipoVida;
  String? _selectedLocalidade;
  late String _selectedEtapa;
  bool _isCasado = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentUser = authSignal.currentUser.value;
    final allowedRoles = currentUser?.role.rolesPermitidasParaAtribuir ?? [];

    _selectedRole = allowedRoles.contains(AppRole.membro)
        ? AppRole.membro
        : (allowedRoles.isNotEmpty ? allowedRoles.first : AppRole.membro);

    // Tipo de vida padrão
    if (currentUser?.role == AppRole.formador) {
      _selectedTipoVida = TipoVida.interna;
    } else {
      _selectedTipoVida = TipoVida.externa;
    }

    // Localidade padrão
    if (currentUser?.role == AppRole.secretariaLocal) {
      _selectedLocalidade = currentUser?.localidade ?? 'BSB';
    } else {
      _selectedLocalidade = 'BSB';
    }

    final etapas = CadastroConstants.etapasPorTipoVida(_selectedTipoVida);
    _selectedEtapa = etapas.first;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newMember = UserEntity(
      id: '', // Será atribuído pelo Firestore
      email: _emailController.text.trim().toLowerCase(),
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      role: _selectedRole,
      tipoVida: _selectedTipoVida,
      localidade: _selectedLocalidade,
      etapaFraternidade: _selectedEtapa,
      isCasado: _isCasado,
      isEmailVerified: false,
      isProfileComplete: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await memberSearchSignal.createDirectMember(newMember);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Membro "${_nomeController.text.trim()}" cadastrado com sucesso! Assim que fizer login com o e-mail, terá acesso imediato.',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      final error = memberSearchSignal.errorMessage.value ?? 'Erro ao cadastrar membro.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = authSignal.currentUser.value;

    final allowedRoles = currentUser?.role.rolesPermitidasParaAtribuir ?? [];
    final isLocalLocked = currentUser?.role == AppRole.secretariaLocal;
    final etapas = CadastroConstants.etapasPorTipoVida(_selectedTipoVida);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.person_add_alt_1, color: colorScheme.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cadastrar Novo Membro',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cadastro direto sem convite. Acesso imediato pelo e-mail.',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ao criar este membro, ele poderá fazer login no app com este e-mail e terá seu perfil vinculado automaticamente.',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Nome Completo
                TextFormField(
                  controller: _nomeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o nome do membro';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // E-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail de Acesso *',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                    helperText: 'O membro usará este e-mail para autenticar no aplicativo',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@') || !v.contains('.')) return 'Informe um e-mail válido';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Telefone / WhatsApp
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone / WhatsApp',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Perfil / Papel
                DropdownButtonFormField<AppRole>(
                  initialValue: allowedRoles.contains(_selectedRole) ? _selectedRole : allowedRoles.firstOrNull,
                  decoration: const InputDecoration(
                    labelText: 'Perfil de Acesso *',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(),
                  ),
                  items: allowedRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRole = val;
                        if (val == AppRole.formador) {
                          _selectedTipoVida = TipoVida.interna;
                          final novasEtapas = CadastroConstants.etapasPorTipoVida(_selectedTipoVida);
                          if (!novasEtapas.contains(_selectedEtapa)) {
                            _selectedEtapa = novasEtapas.first;
                          }
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Tipo de Vida
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipo de Vida *',
                            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          SegmentedButton<TipoVida>(
                            segments: const [
                              ButtonSegment(
                                value: TipoVida.externa,
                                icon: Icon(Icons.people_outline, size: 16),
                                label: Text('Vida Externa'),
                              ),
                              ButtonSegment(
                                value: TipoVida.interna,
                                icon: Icon(Icons.home_work_outlined, size: 16),
                                label: Text('Vida Interna'),
                              ),
                            ],
                            selected: {_selectedTipoVida},
                            onSelectionChanged: (set) {
                              setState(() {
                                _selectedTipoVida = set.first;
                                final novasEtapas = CadastroConstants.etapasPorTipoVida(_selectedTipoVida);
                                if (!novasEtapas.contains(_selectedEtapa)) {
                                  _selectedEtapa = novasEtapas.first;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Localidade
                DropdownButtonFormField<String>(
                  initialValue: _selectedLocalidade,
                  decoration: InputDecoration(
                    labelText: 'Fraternidade Local *',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: const OutlineInputBorder(),
                    helperText: isLocalLocked ? 'Fixado na sua localidade de gestão' : null,
                  ),
                  items: Localidades.todas.map((loc) {
                    return DropdownMenuItem(
                      value: loc.sigla,
                      child: Text(loc.rotuloCompleto),
                    );
                  }).toList(),
                  onChanged: isLocalLocked
                      ? null
                      : (val) {
                          if (val != null) setState(() => _selectedLocalidade = val);
                        },
                ),
                const SizedBox(height: 16),

                // Etapa Formativa (dinâmica por Tipo de Vida)
                DropdownButtonFormField<String>(
                  key: ValueKey('etapa_${_selectedTipoVida.key}_$_selectedEtapa'),
                  initialValue: etapas.contains(_selectedEtapa) ? _selectedEtapa : etapas.first,
                  decoration: InputDecoration(
                    labelText: 'Etapa Formativa (${_selectedTipoVida.label}) *',
                    prefixIcon: const Icon(Icons.school_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  items: etapas.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedEtapa = val);
                  },
                ),
                const SizedBox(height: 16),

                // Estado Civil
                Row(
                  children: [
                    Text(
                      'Estado Civil:',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Solteiro(a)'),
                      selected: !_isCasado,
                      onSelected: (sel) {
                        if (sel) setState(() => _isCasado = false);
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Casado(a)'),
                      selected: _isCasado,
                      onSelected: (sel) {
                        if (sel) setState(() => _isCasado = true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isLoading ? 'Cadastrando...' : 'Cadastrar Membro'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
