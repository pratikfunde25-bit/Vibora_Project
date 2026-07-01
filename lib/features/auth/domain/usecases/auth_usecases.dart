import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// ─── Sign In With Email ───────────────────────────────────
class SignInWithEmailUseCase
    implements UseCase<UserEntity, SignInEmailParams> {
  final AuthRepository _repo;
  const SignInWithEmailUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(SignInEmailParams p) =>
      _repo.signInWithEmail(email: p.email, password: p.password);
}

class SignInEmailParams {
  final String email;
  final String password;
  const SignInEmailParams({required this.email, required this.password});
}

// ─── Sign Up With Email ───────────────────────────────────
class SignUpWithEmailUseCase
    implements UseCase<UserEntity, SignUpEmailParams> {
  final AuthRepository _repo;
  const SignUpWithEmailUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpEmailParams p) =>
      _repo.signUpWithEmail(
        email: p.email,
        password: p.password,
        name: p.name,
      );
}

class SignUpEmailParams {
  final String name;
  final String email;
  final String password;
  const SignUpEmailParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

// ─── Sign In With Google ──────────────────────────────────
class SignInWithGoogleUseCase implements NoParamsUseCase<UserEntity> {
  final AuthRepository _repo;
  const SignInWithGoogleUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call() => _repo.signInWithGoogle();
}

// ─── Sign Out ─────────────────────────────────────────────
class SignOutUseCase implements NoParamsUseCase<void> {
  final AuthRepository _repo;
  const SignOutUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call() => _repo.signOut();
}

// ─── Send Password Reset ──────────────────────────────────
class SendPasswordResetUseCase implements UseCase<void, String> {
  final AuthRepository _repo;
  const SendPasswordResetUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(String email) =>
      _repo.sendPasswordResetEmail(email);
}

// ─── Send Phone OTP ───────────────────────────────────────
class SendPhoneOtpUseCase implements UseCase<String, String> {
  final AuthRepository _repo;
  const SendPhoneOtpUseCase(this._repo);

  @override
  Future<Either<Failure, String>> call(String phone) =>
      _repo.sendPhoneOtp(phone);
}

// ─── Verify Phone OTP ────────────────────────────────────
class VerifyPhoneOtpUseCase
    implements UseCase<UserEntity, VerifyOtpParams> {
  final AuthRepository _repo;
  const VerifyPhoneOtpUseCase(this._repo);

  @override
  Future<Either<Failure, UserEntity>> call(VerifyOtpParams p) =>
      _repo.verifyPhoneOtp(verificationId: p.verificationId, otp: p.otp);
}

class VerifyOtpParams {
  final String verificationId;
  final String otp;
  const VerifyOtpParams({
    required this.verificationId,
    required this.otp,
  });
}
