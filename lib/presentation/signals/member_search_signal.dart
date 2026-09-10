import 'dart:math';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/constants/app_roles.dart';
import '../../core/di/dependency_injection.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_signal.dart';

class MemberSearchSignal {
  final members = signal<List<UserEntity>>([]);
  final isLoading = signal<bool>(false);
  final isSaving = signal<bool>(false);
  final errorMessage = signal<String?>(null);

  // Search and Filter controls
  final searchQuery = signal<String>('');
  final filterTipoVida = signal<TipoVida?>(null);
  final filterLocalidade = signal<String?>(null);
  final filterEtapa = signal<String?>(null);
  final filterCasado = signal<bool?>(null);
  final filterResidenciaUf = signal<String?>(null);

  // Pagination
  final currentPage = signal<int>(1);
  final itemsPerPage = signal<int>(10);

  MemberSearchSignal() {
    // Whenever filters or search query change, reset back to page 1
    searchQuery.subscribe((_) => currentPage.value = 1);
    filterTipoVida.subscribe((_) => currentPage.value = 1);
    filterLocalidade.subscribe((_) => currentPage.value = 1);
    filterEtapa.subscribe((_) => currentPage.value = 1);
    filterCasado.subscribe((_) => currentPage.value = 1);
    filterResidenciaUf.subscribe((_) => currentPage.value = 1);
    itemsPerPage.subscribe((_) => currentPage.value = 1);
  }

  void initializeUserScope(UserEntity currentUser) {
    // Pre-lock or preset filters based on the current user's role scope
    if (currentUser.role == AppRole.secretariaGeralExterna) {
      filterTipoVida.value = TipoVida.externa;
    } else if (currentUser.role == AppRole.secretariaGeralInterna ||
        currentUser.role == AppRole.formador) {
      filterTipoVida.value = TipoVida.interna;
    } else if (currentUser.role == AppRole.secretariaLocal) {
      if (currentUser.localidade != null && currentUser.localidade!.isNotEmpty) {
        filterLocalidade.value = currentUser.localidade;
      }
    }
  }

  Future<void> loadMembers() async {
    final current = authSignal.currentUser.value;
    if (current == null || !current.role.canSearchMembers) {
      errorMessage.value = 'Sem permissão para consultar membros.';
      members.value = [];
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      initializeUserScope(current);

      final all = await sl.userRepository.getAllUsers();
      members.value = all;
    } catch (e) {
      errorMessage.value = 'Erro ao carregar membros: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Members filtered according to the current user's permissions and active search filters
  List<UserEntity> get filteredMembers {
    final current = authSignal.currentUser.value;
    if (current == null || !current.role.canSearchMembers) return [];

    return members.value.where((m) {
      // 1. Role-based security scoping
      if (current.role == AppRole.secretariaGeralExterna) {
        if (m.tipoVida != TipoVida.externa) return false;
      } else if (current.role == AppRole.secretariaGeralInterna ||
          current.role == AppRole.formador) {
        if (m.tipoVida != TipoVida.interna) return false;
      } else if (current.role == AppRole.secretariaLocal) {
        if (m.localidade != current.localidade) return false;
      }

      // 2. Filter: Tipo de Vida
      if (filterTipoVida.value != null && m.tipoVida != filterTipoVida.value) {
        return false;
      }

      // 3. Filter: Localidade da Fraternidade
      if (filterLocalidade.value != null &&
          filterLocalidade.value!.isNotEmpty &&
          m.localidade != filterLocalidade.value) {
        return false;
      }

      // 4. Filter: Etapa do Caminho
      if (filterEtapa.value != null &&
          filterEtapa.value!.isNotEmpty &&
          m.etapaFraternidade != filterEtapa.value) {
        return false;
      }

      // 5. Filter: Casado / Solteiro
      if (filterCasado.value != null && m.isCasado != filterCasado.value) {
        return false;
      }

      // 6. Filter: UF de Residência
      if (filterResidenciaUf.value != null &&
          filterResidenciaUf.value!.isNotEmpty &&
          m.uf?.toUpperCase() != filterResidenciaUf.value?.toUpperCase()) {
        return false;
      }

      // 7. Search query (Nome, Email, Telefone, CPF)
      final q = searchQuery.value.trim().toLowerCase();
      if (q.isNotEmpty) {
        final nomeMatch = m.nome.toLowerCase().contains(q);
        final emailMatch = m.email.toLowerCase().contains(q);
        final cleanDigits = q.replaceAll(RegExp(r'\D'), '');
        final phoneDigits = m.telefone.replaceAll(RegExp(r'\D'), '');
        final cpfDigits = (m.cpf ?? '').replaceAll(RegExp(r'\D'), '');

        final phoneMatch = cleanDigits.isNotEmpty && phoneDigits.contains(cleanDigits);
        final cpfMatch = cleanDigits.isNotEmpty && cpfDigits.contains(cleanDigits);

        if (!nomeMatch && !emailMatch && !phoneMatch && !cpfMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get totalCount => filteredMembers.length;

  int get totalPages {
    final count = totalCount;
    if (count == 0) return 1;
    return (count / itemsPerPage.value).ceil().clamp(1, 999999);
  }

  List<UserEntity> get paginatedMembers {
    final list = filteredMembers;
    final total = list.length;
    if (total == 0) return [];

    final safePage = currentPage.value.clamp(1, totalPages);
    final startIndex = (safePage - 1) * itemsPerPage.value;
    if (startIndex >= total) return [];

    final endIndex = min(startIndex + itemsPerPage.value, total);
    return list.sublist(startIndex, endIndex);
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    final current = authSignal.currentUser.value;
    if (current != null) {
      // Don't reset role-locked filters
      if (current.role != AppRole.secretariaGeralExterna &&
          current.role != AppRole.secretariaGeralInterna &&
          current.role != AppRole.formador) {
        filterTipoVida.value = null;
      }
      if (current.role != AppRole.secretariaLocal) {
        filterLocalidade.value = null;
      }
    } else {
      filterTipoVida.value = null;
      filterLocalidade.value = null;
    }
    filterEtapa.value = null;
    filterCasado.value = null;
    filterResidenciaUf.value = null;
    currentPage.value = 1;
  }

  Future<bool> updateMemberInstitutional({
    required String userId,
    TipoVida? tipoVida,
    String? localidade,
    String? etapaFraternidade,
    AppRole? role,
  }) async {
    final current = authSignal.currentUser.value;
    if (current == null || !current.role.canEditMemberInstitutional) {
      errorMessage.value = 'Sem permissão para alterar dados institucionais.';
      return false;
    }

    try {
      isSaving.value = true;
      errorMessage.value = null;

      final data = <String, dynamic>{};
      if (tipoVida != null) data['tipoVida'] = tipoVida.name;
      if (localidade != null) data['localidade'] = localidade;
      if (etapaFraternidade != null) data['etapaFraternidade'] = etapaFraternidade;
      if (role != null) data['role'] = role.name;

      await sl.userRepository.saveUserPartial(userId, data);

      // Update local member in state
      final updatedList = members.value.map((m) {
        if (m.id == userId) {
          return m.copyWith(
            tipoVida: tipoVida ?? m.tipoVida,
            localidade: localidade ?? m.localidade,
            etapaFraternidade: etapaFraternidade ?? m.etapaFraternidade,
            role: role ?? m.role,
          );
        }
        return m;
      }).toList();

      members.value = updatedList;
      return true;
    } catch (e) {
      errorMessage.value = 'Erro ao atualizar membro: $e';
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}

final memberSearchSignal = MemberSearchSignal();
