import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
/// Follows Clean Architecture - keeps errors abstract in domain layer
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Connection failures (camera P2P)
class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message, super.code});
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, super.code});
}

/// Authentication/Authorization failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// SDK-specific failures
class SdkFailure extends Failure {
  const SdkFailure({required super.message, super.code});
}

/// Storage failures (cache, database)
class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.code});
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
