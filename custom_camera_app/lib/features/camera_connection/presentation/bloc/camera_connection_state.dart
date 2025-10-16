import 'package:equatable/equatable.dart';
import '../../domain/entities/camera.dart';

/// Base state for camera connection
abstract class CameraConnectionState extends Equatable {
  const CameraConnectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CameraConnectionInitial extends CameraConnectionState {}

/// Connecting state
class CameraConnectionConnecting extends CameraConnectionState {}

/// Connected state
class CameraConnectionConnected extends CameraConnectionState {
  final Camera camera;

  const CameraConnectionConnected(this.camera);

  @override
  List<Object?> get props => [camera];
}

/// Disconnected state
class CameraConnectionDisconnected extends CameraConnectionState {}

/// Error state
class CameraConnectionError extends CameraConnectionState {
  final String message;

  const CameraConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}
