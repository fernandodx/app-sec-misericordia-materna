import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/firestore_remote_datasource.dart';
import '../../data/datasources/storage_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/invite_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/invite_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/auth/check_auth_state_usecase.dart';
import '../../domain/usecases/auth/register_email_usecase.dart';
import '../../domain/usecases/auth/sign_in_email_usecase.dart';
import '../../domain/usecases/auth/sign_in_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/invites/create_invite_usecase.dart';
import '../../domain/usecases/invites/list_invites_usecase.dart';
import '../../domain/usecases/invites/validate_invite_usecase.dart';
import '../../domain/usecases/members/link_spouse_usecase.dart';
import '../../domain/usecases/members/save_member_profile_usecase.dart';
import '../../domain/usecases/members/save_member_step_usecase.dart';
import '../../domain/usecases/members/search_potential_spouse_usecase.dart';
import '../../domain/usecases/members/upload_member_photo_usecase.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // DataSources
  late final AuthRemoteDataSource authRemoteDataSource;
  late final FirestoreRemoteDataSource firestoreRemoteDataSource;
  late final StorageRemoteDataSource storageRemoteDataSource;

  // Repositories
  late final AuthRepository authRepository;
  late final UserRepository userRepository;
  late final InviteRepository inviteRepository;
  late final StorageRepository storageRepository;

  // UseCases
  late final SignInEmailUseCase signInEmailUseCase;
  late final RegisterEmailUseCase registerEmailUseCase;
  late final SignInGoogleUseCase signInGoogleUseCase;
  late final SignOutUseCase signOutUseCase;
  late final CheckAuthStateUseCase checkAuthStateUseCase;

  late final CreateInviteUseCase createInviteUseCase;
  late final ValidateInviteUseCase validateInviteUseCase;
  late final ListInvitesUseCase listInvitesUseCase;

  late final SaveMemberProfileUseCase saveMemberProfileUseCase;
  late final UploadMemberPhotoUseCase uploadMemberPhotoUseCase;
  late final SearchPotentialSpouseUseCase searchPotentialSpouseUseCase;
  late final LinkSpouseUseCase linkSpouseUseCase;
  late final SaveMemberStepUseCase saveMemberStepUseCase;

  void setup() {
    // DataSources
    authRemoteDataSource = AuthRemoteDataSource();
    firestoreRemoteDataSource = FirestoreRemoteDataSource();
    storageRemoteDataSource = StorageRemoteDataSource();

    // Repositories
    authRepository = AuthRepositoryImpl(
      authRemoteDataSource: authRemoteDataSource,
      firestoreRemoteDataSource: firestoreRemoteDataSource,
    );
    userRepository = UserRepositoryImpl(firestoreRemoteDataSource);
    inviteRepository = InviteRepositoryImpl(firestoreRemoteDataSource);
    storageRepository = StorageRepositoryImpl(storageRemoteDataSource);

    // UseCases
    signInEmailUseCase = SignInEmailUseCase(authRepository);
    registerEmailUseCase = RegisterEmailUseCase(authRepository);
    signInGoogleUseCase = SignInGoogleUseCase(authRepository);
    signOutUseCase = SignOutUseCase(authRepository);
    checkAuthStateUseCase = CheckAuthStateUseCase(authRepository);

    createInviteUseCase = CreateInviteUseCase(inviteRepository);
    validateInviteUseCase = ValidateInviteUseCase(inviteRepository);
    listInvitesUseCase = ListInvitesUseCase(inviteRepository);

    saveMemberProfileUseCase = SaveMemberProfileUseCase(
      userRepository,
      inviteRepository,
    );
    uploadMemberPhotoUseCase = UploadMemberPhotoUseCase();
    searchPotentialSpouseUseCase = SearchPotentialSpouseUseCase(userRepository);
    linkSpouseUseCase = LinkSpouseUseCase(userRepository);
    saveMemberStepUseCase = SaveMemberStepUseCase(userRepository);
  }
}

final sl = ServiceLocator();
