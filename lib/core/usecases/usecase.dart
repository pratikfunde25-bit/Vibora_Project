import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base use case interface for all use cases with a parameter.
abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters.
abstract interface class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Synchronous use case.
abstract interface class SyncUseCase<Type, Params> {
  Either<Failure, Type> call(Params params);
}

/// Stream use case for real-time features.
abstract interface class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Marker class for use cases with no params.
class NoParams {
  const NoParams();
}
