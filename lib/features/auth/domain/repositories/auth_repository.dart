import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, String>> sendPhoneOtp(String phoneNumber);

  Future<Either<Failure, UserEntity>> verifyPhoneOtp({
    required String verificationId,
    required String otp,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, bool>> checkBiometricAvailability();

  Future<Either<Failure, UserEntity>> signInWithBiometric();

  Stream<UserEntity?> get authStateChanges;

  UserEntity? get currentUser;

  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user);

  Future<Either<Failure, String>> uploadProfileImage(dynamic image);
}
