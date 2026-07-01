import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(() => AuthController());

final userStreamProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authControllerProvider);
  final user = authState.value;
  if (user == null) return Stream.value(null);

  final db = FirebaseFirestore.instance;
  return db
      .collection('users')
      .doc(user.id)
      .snapshots()
      .map((snap) => snap.exists ? UserModel.fromFirestore(snap) : null);
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});

class AuthController extends AsyncNotifier<UserEntity?> {
  late final SignInWithEmailUseCase _signInEmail;
  late final SignUpWithEmailUseCase _signUpEmail;
  late final SignInWithGoogleUseCase _signInGoogle;
  late final SignOutUseCase _signOut;
  late final SendPasswordResetUseCase _sendReset;
  late final SendPhoneOtpUseCase _sendOtp;
  late final VerifyPhoneOtpUseCase _verifyOtp;

  @override
  Future<UserEntity?> build() async {
    final repo = ref.read(authRepositoryProvider);
    _signInEmail = SignInWithEmailUseCase(repo);
    _signUpEmail = SignUpWithEmailUseCase(repo);
    _signInGoogle = SignInWithGoogleUseCase(repo);
    _signOut = SignOutUseCase(repo);
    _sendReset = SendPasswordResetUseCase(repo);
    _sendOtp = SendPhoneOtpUseCase(repo);
    _verifyOtp = VerifyPhoneOtpUseCase(repo);

    // Stream state updates automatically
    repo.authStateChanges.listen((user) {
      state = AsyncData(user);
    });

    return repo.authStateChanges.first;
  }

  Future<String?> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    final result = await _signInEmail(SignInEmailParams(email: email, password: password));
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = AsyncData(user);
        return null;
      },
    );
  }

  Future<String?> signUpWithEmail(String name, String email, String password) async {
    state = const AsyncLoading();
    final result = await _signUpEmail(SignUpEmailParams(name: name, email: email, password: password));
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = AsyncData(user);
        return null;
      },
    );
  }

  Future<String?> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await _signInGoogle();
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = AsyncData(user);
        return null;
      },
    );
  }

  Future<String?> signOut() async {
    final result = await _signOut();
    return result.fold(
      (failure) => failure.message,
      (_) {
        state = const AsyncData(null);
        return null;
      },
    );
  }

  Future<String?> updateProfile({String? name, String? bio, String? avatarUrl}) async {
    final currentUser = state.value;
    if (currentUser == null) return 'Not logged in';

    final updatedUser = currentUser.copyWith(
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
    );

    // SILENT UPDATE: Don't set state to AsyncLoading to avoid router jitter
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.updateProfile(updatedUser);
    
    return result.fold(
      (failure) {
        // Only set error if it really fails, but keep the data
        state = AsyncData(currentUser); 
        return failure.message;
      },
      (user) {
        state = AsyncData(user);
        return null;
      },
    );
  }

  Future<String?> uploadAvatar(dynamic image) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.uploadProfileImage(image);
    return result.fold((f) => null, (url) => url);
  }

  Future<String?> sendPasswordReset(String email) async {
    final result = await _sendReset(email);
    return result.fold((f) => f.message, (_) => null);
  }

  Future<({String? error, String? verificationId})> sendOtp(String phone) async {
    final result = await _sendOtp(phone);
    return result.fold((f) => (error: f.message, verificationId: null), (vId) => (error: null, verificationId: vId));
  }

  Future<String?> verifyOtp({required String verificationId, required String otp}) async {
    state = const AsyncLoading();
    final result = await _verifyOtp(VerifyOtpParams(verificationId: verificationId, otp: otp));
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return failure.message;
      },
      (user) {
        state = AsyncData(user);
        return null;
      },
    );
  }
}
