import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/env_config.dart';
import '../../core/constants/app_roles.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/invite_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../models/invite_model.dart';
import '../models/user_model.dart';

class FirestoreRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _invitesCol =>
      _firestore.collection('invites');

  // ================= USERS =================

  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _usersCol.doc(id).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snap = await _usersCol
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return UserModel.fromFirestore(snap.docs.first);
    } catch (e) {
      throw ServerFailure('Erro ao buscar usuário por e-mail: $e');
    }
  }

  Stream<UserModel?> userStream(String id) {
    return _usersCol.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCol.doc(user.id).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw ServerFailure('Erro ao salvar informações do membro: $e');
    }
  }

  Future<void> saveUserPartial(String userId, Map<String, dynamic> data) async {
    try {
      final payload = Map<String, dynamic>.from(data);
      payload['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCol.doc(userId).set(payload, SetOptions(merge: true));
    } catch (e) {
      throw ServerFailure('Erro ao salvar etapa do cadastro: $e');
    }
  }

  Future<List<UserModel>> searchUsersByName(String query, {String? excludeUserId}) async {
    final cleanQuery = AppFormatters.normalizeString(query);
    if (cleanQuery.length < 2) return [];

    try {
      final snap = await _usersCol.limit(100).get();
      final results = <UserModel>[];
      for (final doc in snap.docs) {
        if (excludeUserId != null && doc.id == excludeUserId) continue;
        final user = UserModel.fromFirestore(doc);

        final name = AppFormatters.normalizeString(user.nome);
        final email = AppFormatters.normalizeString(user.email);
        if (name.contains(cleanQuery) || email.contains(cleanQuery)) {
          results.add(user);
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snap = await _usersCol.get();
      return snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerFailure('Erro ao carregar lista de membros: $e');
    }
  }

  Future<void> linkSpouse({required String userId, required String spouseId}) async {
    if (userId == spouseId) {
      throw ServerFailure('Não é possível vincular seu próprio perfil como cônjuge.');
    }

    try {
      // Regra de Negócio: Verifica se o parceiro já possui cônjuge vinculado com terceiro
      final spouseDoc = await _usersCol.doc(spouseId).get().timeout(const Duration(seconds: 8));
      if (spouseDoc.exists) {
        final data = spouseDoc.data();
        final existingSpouseId = data?['spouseId'] as String?;
        if (existingSpouseId != null &&
            existingSpouseId.isNotEmpty &&
            existingSpouseId != userId) {
          throw ServerFailure('Este membro já possui vínculo matrimonial ativo com outro perfil no sistema.');
        }
      }

      final batch = _firestore.batch();
      batch.set(_usersCol.doc(userId), {
        'spouseId': spouseId,
        'isCasado': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      batch.set(_usersCol.doc(spouseId), {
        'spouseId': userId,
        'isCasado': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit().timeout(const Duration(seconds: 10));
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Erro ao vincular cônjuge: $e');
    }
  }

  Future<UserModel> bootstrapOrCreateUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    bool isEmailVerified = false,
  }) async {
    try {
      final existing = await getUserById(uid);
      if (existing != null) {
        UserEntity updated = existing;
        bool needsUpdate = false;

        // Atualiza status de verificação de e-mail se mudou
        if (existing.isEmailVerified != isEmailVerified) {
          updated = updated.copyWith(isEmailVerified: isEmailVerified);
          needsUpdate = true;
        }

        // Se o usuário não tem foto, ou foto está vazia, ou a foto atual é inacessível/nula, e o Google forneceu photoUrl
        final currentPhoto = existing.fotoUrl?.trim() ?? '';
        final newPhoto = photoUrl?.trim() ?? '';
        if (newPhoto.isNotEmpty && (currentPhoto.isEmpty || currentPhoto != newPhoto)) {
          updated = updated.copyWith(fotoUrl: newPhoto);
          needsUpdate = true;
        }

        // Se o nome está vazio no Firestore e o Google/login forneceu displayName
        if (existing.nome.trim().isEmpty &&
            displayName != null &&
            displayName.trim().isNotEmpty) {
          updated = updated.copyWith(nome: displayName.trim());
          needsUpdate = true;
        }

        if (needsUpdate) {
          final model = UserModel.fromEntity(updated);
          await saveUser(model);
          return model;
        }
        return UserModel.fromEntity(existing);
      }

      final normalizedEmail = email.trim().toLowerCase();
      final adminBootstrapEmail = EnvConfig.initialAdminEmail;

      AppRole assignedRole = AppRole.visitante;

      // 1. Checagem de Bootstrap do Admin Mestre (nando.djx@gmail.com)
      if (normalizedEmail == adminBootstrapEmail) {
        assignedRole = AppRole.fundador;
      } else {
        // 2. Verifica se o e-mail possui um convite prévio emitido para ele
        final pendingInvite = await findPendingInviteForEmail(normalizedEmail);
        if (pendingInvite != null) {
          assignedRole = pendingInvite.targetRole;
        }
      }

      final now = DateTime.now();
      final newUser = UserModel(
        id: uid,
        email: normalizedEmail,
        nome: displayName ?? '',
        telefone: '',
        fotoUrl: photoUrl,
        role: assignedRole,
        isEmailVerified: isEmailVerified,
        isProfileComplete: (displayName != null && displayName.trim().isNotEmpty),
        createdAt: now,
        updatedAt: now,
      );

      await _usersCol.doc(uid).set(newUser.toMap());
      return newUser;
    } catch (e) {
      throw ServerFailure('Erro ao inicializar perfil de usuário: $e');
    }
  }

  // ================= INVITES =================

  Future<void> createInvite(InviteModel invite) async {
    try {
      await _invitesCol.doc(invite.id).set(invite.toMap());
    } catch (e) {
      throw ServerFailure('Erro ao criar convite no Firestore: $e');
    }
  }

  Future<InviteModel?> getInviteByCode(String code) async {
    try {
      final doc = await _invitesCol.doc(code.trim()).get();
      if (!doc.exists) return null;
      return InviteModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Erro ao consultar convite: $e');
    }
  }

  Future<void> acceptInvite(String code, String userId) async {
    try {
      await _invitesCol.doc(code.trim()).update({
        'status': InviteStatus.accepted.key,
        'acceptedByUid': userId,
        'acceptedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerFailure('Erro ao atualizar status do convite: $e');
    }
  }

  Future<void> revokeInvite(String code) async {
    try {
      await _invitesCol.doc(code.trim()).update({
        'status': InviteStatus.revoked.key,
      });
    } catch (e) {
      throw ServerFailure('Erro ao revogar convite: $e');
    }
  }

  Future<List<InviteModel>> listInvites() async {
    try {
      final snap = await _invitesCol
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snap.docs.map((d) => InviteModel.fromFirestore(d)).toList();
    } catch (e) {
      throw ServerFailure('Erro ao listar convites: $e');
    }
  }

  Future<InviteModel?> findPendingInviteForEmail(String email) async {
    try {
      final snap = await _invitesCol
          .where('targetEmail', isEqualTo: email.trim().toLowerCase())
          .where('status', isEqualTo: InviteStatus.pending.key)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return InviteModel.fromFirestore(snap.docs.first);
    } catch (e) {
      return null;
    }
  }
}
