import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    googleSignIn: GoogleSignIn(),
    localAuth: LocalAuthentication(),
    secureStorage: const FlutterSecureStorage(),
  ),
);

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  const AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
    required LocalAuthentication localAuth,
    required FlutterSecureStorage secureStorage,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn,
        _localAuth = localAuth,
        _secureStorage = secureStorage;

  // ── Stream ──────────────────────────────────────────────
  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) return Stream.value(null);
      
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) return null;
            return UserModel.fromFirestore(doc);
          });
    });
  }

  @override
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  // ── Email Sign In ────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _fetchUser(credential.user!.uid);
      await _cacheCredentials(email: email, password: password);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── Email Sign Up ────────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);

      final userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userModel.id)
          .set(userModel.toMap());

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── Google Sign In ───────────────────────────────────────
  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return Left(const AuthFailure('Sign in cancelled'));

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred =
          await _firebaseAuth.signInWithCredential(credential);
      final uid = userCred.user!.uid;

      // Upsert user doc
      final docRef = _firestore.collection(AppConstants.usersCollection).doc(uid);
      final snap = await docRef.get();
      if (!snap.exists) {
        final userModel = UserModel(
          id: uid,
          name: googleUser.displayName ?? '',
          email: googleUser.email,
          avatarUrl: googleUser.photoUrl,
          createdAt: DateTime.now(),
        );
        await docRef.set(userModel.toMap());
      }
      final user = await _fetchUser(uid);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── Phone OTP ────────────────────────────────────────────
  @override
  Future<Either<Failure, String>> sendPhoneOtp(String phoneNumber) async {
    try {
      final completer = Completer<String>();
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution handle here if needed
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError(_mapFirebaseError(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
      return Right(await completer.future);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyPhoneOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCred =
          await _firebaseAuth.signInWithCredential(credential);
      final uid = userCred.user!.uid;

      final docRef = _firestore.collection(AppConstants.usersCollection).doc(uid);
      final snap = await docRef.get();
      if (!snap.exists) {
        final userModel = UserModel(
          id: uid,
          name: userCred.user!.displayName ?? 'User',
          email: userCred.user!.email ?? '',
          phone: userCred.user!.phoneNumber,
          createdAt: DateTime.now(),
        );
        await docRef.set(userModel.toMap());
      }
      final user = await _fetchUser(uid);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── Password Reset ───────────────────────────────────────
  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseError(e.code)));
    }
  }

  // ── Sign Out ──────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        _secureStorage.deleteAll(),
      ]);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── Biometrics ────────────────────────────────────────────
  @override
  Future<Either<Failure, bool>> checkBiometricAvailability() async {
    try {
      final available = await _localAuth.canCheckBiometrics;
      return Right(available);
    } catch (e) {
      return Left(PermissionFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Vibora',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!authenticated) return Left(const AuthFailure('Biometric auth failed'));

      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');
      if (email == null || password == null) {
        return Left(const AuthFailure('No saved credentials'));
      }
      return signInWithEmail(email: email, password: password);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  Future<UserModel> _fetchUser(String uid) async {
    final snap = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!snap.exists) throw Exception('User not found');
    return UserModel.fromFirestore(snap);
  }

  Future<void> _cacheCredentials({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(model.toMap());
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(dynamic image) async {
    try {
      if (image is! File) return Left(ServerFailure('Invalid image file'));

      // Bypass Paid Storage: Save to Local App Directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${_firebaseAuth.currentUser!.uid}.jpg';
      final localPath = '${directory.path}/$fileName';
      
      final localFile = await image.copy(localPath);
      return Right('local://${localFile.path}');
    } catch (e) {
      return Left(ServerFailure('Local storage failed: ${e.toString()}'));
    }
  }
}

