import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}

class PaymentFailure extends Failure {
  const PaymentFailure([super.message = 'Payment failed.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
