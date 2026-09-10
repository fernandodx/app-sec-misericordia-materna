import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/services/viacep_service.dart';
import '../../domain/entities/invite_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_signal.dart';

class MemberFormSignal {
  final currentStep = signal<int>(1);
  final isLoading = signal<bool>(false);
  final isSavingStep = signal<bool>(false);
  final errorMessage = signal<String?>(null);
  final successMessage = signal<String?>(null);

  final selectedPhotoBytes = signal<Uint8List?>(null);
  final photoUrl = signal<String?>(null);

  // Cônjuge
  final isCasado = signal<bool>(false);
  final isSearchingSpouse = signal<bool>(false);
  final isLinkingSpouse = signal<bool>(false);
  final potentialSpouses = signal<List<UserEntity>>([]);
  final linkedSpouse = signal<UserEntity?>(null);

  // Filhos & Irmãos
  final possuiFilhos = signal<bool>(false);
  final filhos = signal<List<FilhoEntity>>([]);
  final nomesFilhos = signal<List<String>>([]);
  final possuiIrmaos = signal<bool>(false);
  final irmaos = signal<List<String>>([]);

  // Autobiografia (Solteiros)
  final autobiografiaPdfBase64 = signal<String?>(null);
  final autobiografiaPdfNome = signal<String?>(null);

  // CEP & Endereço
  final isFetchingCep = signal<bool>(false);
  final cepAddress = signal<ViaCepResult?>(null);

  // Vivência religiosa e vocacional
  final participaPastoral = signal<bool>(false);
  final disponivelIniciarProcesso = signal<bool>(true);

  final ImagePicker _picker = ImagePicker();

  void initFromUser(UserEntity? user) {
    errorMessage.value = null;
    successMessage.value = null;
    selectedPhotoBytes.value = null;
    photoUrl.value = user?.fotoUrl;

    if (user != null) {
      currentStep.value = (user.cadastroEtapa >= 1 && user.cadastroEtapa <= 6)
          ? user.cadastroEtapa
          : 1;

      isCasado.value = user.isCasado;
      possuiFilhos.value = user.possuiFilhos;
      filhos.value = List<FilhoEntity>.from(user.filhos);
      nomesFilhos.value = List<String>.from(user.nomesFilhos);
      possuiIrmaos.value = user.possuiIrmaos;
      irmaos.value = List<String>.from(user.irmaos);
      autobiografiaPdfBase64.value = user.autobiografiaPdfBase64;
      autobiografiaPdfNome.value = user.autobiografiaPdfNome;
      participaPastoral.value = user.participaPastoral;
      disponivelIniciarProcesso.value = user.disponivelIniciarProcesso;

      if (user.spouseId != null && user.spouseId!.isNotEmpty) {
        _loadLinkedSpouse(user.spouseId!);
      }
    } else {
      currentStep.value = 1;
    }
  }

  Future<void> _loadLinkedSpouse(String spouseId) async {
    try {
      final spouse = await sl.userRepository.getUserById(spouseId);
      if (spouse != null) {
        linkedSpouse.value = spouse;
        isCasado.value = true;
      }
    } catch (_) {}
  }

  Future<void> pickPhoto(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        selectedPhotoBytes.value = bytes;
      }
    } catch (e) {
      errorMessage.value = 'Erro ao selecionar imagem: $e';
    }
  }

  Future<void> searchSpouses(String query) async {
    final current = authSignal.currentUser.value;
    final clean = query.trim();
    if (clean.length < 2) {
      potentialSpouses.value = [];
      return;
    }

    try {
      isSearchingSpouse.value = true;
      final results = await sl.searchPotentialSpouseUseCase(
        clean,
        excludeUserId: current?.id,
      );
      potentialSpouses.value = results;
    } catch (_) {
      potentialSpouses.value = [];
    } finally {
      isSearchingSpouse.value = false;
    }
  }

  Future<bool> linkWithSpouse(UserEntity spouse) async {
    final current = authSignal.currentUser.value;
    if (current == null) {
      errorMessage.value = 'Nenhum usuário autenticado.';
      return false;
    }

    if (current.id == spouse.id) {
      errorMessage.value = 'Não é possível vincular seu próprio perfil como cônjuge.';
      return false;
    }

    if (spouse.isCasado &&
        spouse.spouseId != null &&
        spouse.spouseId!.isNotEmpty &&
        spouse.spouseId != current.id) {
      errorMessage.value = 'Este membro já possui vínculo matrimonial ativo com outro parceiro.';
      return false;
    }

    try {
      isLinkingSpouse.value = true;
      errorMessage.value = null;
      await sl.linkSpouseUseCase(userId: current.id, spouseId: spouse.id);
      linkedSpouse.value = spouse;
      isCasado.value = true;
      potentialSpouses.value = [];

      // Herança inteligente: se o cônjuge já tiver preenchido filhos, endereço ou paróquia, herda
      if (spouse.possuiFilhos && filhos.value.isEmpty) {
        possuiFilhos.value = true;
        filhos.value = List<FilhoEntity>.from(spouse.filhos);
        nomesFilhos.value = List<String>.from(spouse.nomesFilhos);
      }

      participaPastoral.value = spouse.participaPastoral;
      disponivelIniciarProcesso.value = spouse.disponivelIniciarProcesso;

      if (spouse.cep != null && spouse.cep!.isNotEmpty) {
        cepAddress.value = ViaCepResult(
          cep: spouse.cep ?? '',
          logradouro: spouse.logradouro ?? '',
          complemento: spouse.complemento ?? '',
          bairro: spouse.bairro ?? '',
          cidade: spouse.cidade ?? '',
          uf: spouse.uf ?? '',
        );
      }

      successMessage.value = 'Vínculo com ${spouse.nome} realizado com sucesso!';
      return true;
    } catch (e) {
      errorMessage.value = 'Erro ao vincular cônjuge: $e';
      return false;
    } finally {
      isLinkingSpouse.value = false;
    }
  }

  void unlinkSpouse() {
    linkedSpouse.value = null;
  }

  Future<ViaCepResult?> searchCep(String cep) async {
    try {
      isFetchingCep.value = true;
      final result = await ViaCepService.fetchCep(cep);
      cepAddress.value = result;
      return result;
    } finally {
      isFetchingCep.value = false;
    }
  }

  void addFilho(String nome, {String? dataNascimento, int? idade}) {
    final cleanNome = nome.trim();
    if (cleanNome.isNotEmpty) {
      final calculatedIdade = (dataNascimento != null && dataNascimento.isNotEmpty)
          ? FilhoEntity.calcularIdade(dataNascimento)
          : (idade ?? 0);
      final list = List<FilhoEntity>.from(filhos.value);
      list.add(FilhoEntity(
        nome: cleanNome,
        idade: calculatedIdade,
        dataNascimento: dataNascimento,
      ));
      filhos.value = list;
      nomesFilhos.value = list.map((f) => f.nome).toList();
    }
  }

  void updateFilho(int index, String nome, {String? dataNascimento, int? idade}) {
    if (index >= 0 && index < filhos.value.length) {
      final cleanNome = nome.trim();
      if (cleanNome.isNotEmpty) {
        final calculatedIdade = (dataNascimento != null && dataNascimento.isNotEmpty)
            ? FilhoEntity.calcularIdade(dataNascimento)
            : (idade ?? 0);
        final list = List<FilhoEntity>.from(filhos.value);
        list[index] = FilhoEntity(
          nome: cleanNome,
          idade: calculatedIdade,
          dataNascimento: dataNascimento,
        );
        filhos.value = list;
        nomesFilhos.value = list.map((f) => f.nome).toList();
      }
    }
  }

  void removeFilho(int index) {
    if (index >= 0 && index < filhos.value.length) {
      final list = List<FilhoEntity>.from(filhos.value);
      list.removeAt(index);
      filhos.value = list;
      nomesFilhos.value = list.map((f) => f.nome).toList();
    }
  }

  void addIrmao(String nome) {
    final clean = nome.trim();
    if (clean.isNotEmpty) {
      final list = List<String>.from(irmaos.value);
      list.add(clean);
      irmaos.value = list;
    }
  }

  void removeIrmao(int index) {
    if (index >= 0 && index < irmaos.value.length) {
      final list = List<String>.from(irmaos.value);
      list.removeAt(index);
      irmaos.value = list;
    }
  }

  void setAutobiografiaPdf({required String? base64, required String? nome}) {
    autobiografiaPdfBase64.value = base64;
    autobiografiaPdfNome.value = nome;
  }

  Future<bool> saveStep({
    required int stepNumber,
    required Map<String, dynamic> stepData,
    bool isFinal = false,
    InviteEntity? invite,
  }) async {
    final current = authSignal.currentUser.value;
    if (current == null) {
      errorMessage.value = 'Nenhum usuário autenticado.';
      return false;
    }

    try {
      isSavingStep.value = true;
      errorMessage.value = null;

      String? finalPhotoUrl = photoUrl.value;
      if (selectedPhotoBytes.value != null) {
        try {
          finalPhotoUrl = await sl.uploadMemberPhotoUseCase(
            userId: current.id,
            rawImageBytes: selectedPhotoBytes.value!,
          );
          photoUrl.value = finalPhotoUrl;
          selectedPhotoBytes.value = null;
        } catch (imgErr) {
          // ignore: avoid_print
          print('Erro ao processar e comprimir imagem: $imgErr');
        }
      }

      final payload = Map<String, dynamic>.from(stepData);
      if (finalPhotoUrl != null) {
        payload['fotoUrl'] = finalPhotoUrl;
      }

      final nextStep = isFinal ? 6 : (stepNumber < 6 ? stepNumber + 1 : 6);
      payload['cadastroEtapa'] = nextStep;

      if (isFinal) {
        payload['isProfileComplete'] = true;
        if (invite != null) {
          payload['role'] = invite.targetRole.key;
          if (invite.tipoVida != null) payload['tipoVida'] = invite.tipoVida!.key;
          if (invite.localidade != null) payload['localidade'] = invite.localidade;
        }
      }

      await sl.saveMemberStepUseCase(
        userId: current.id,
        stepData: payload,
      );

      if (isFinal && invite != null) {
        await sl.inviteRepository.acceptInvite(invite.id, current.id);
      }

      // Atualiza usuário no estado local
      final updated = current.copyWith(
        fotoUrl: finalPhotoUrl ?? current.fotoUrl,
        isProfileComplete: isFinal ? true : current.isProfileComplete,
        cadastroEtapa: nextStep,
        role: (isFinal && invite != null) ? invite.targetRole : current.role,
        tipoVida: (isFinal && invite?.tipoVida != null) ? invite!.tipoVida : current.tipoVida,
        localidade: (isFinal && invite?.localidade != null) ? invite!.localidade : current.localidade,
      );
      authSignal.refreshUser(updated);

      if (!isFinal) {
        currentStep.value = nextStep;
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Erro ao salvar etapa: $e';
      return false;
    } finally {
      isSavingStep.value = false;
    }
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 6) {
      currentStep.value = step;
    }
  }
}

final memberFormSignal = MemberFormSignal();
