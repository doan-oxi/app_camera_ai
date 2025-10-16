import 'package:equatable/equatable.dart';

/// Base event for camera connection
abstract class CameraConnectionEvent extends Equatable {
  const CameraConnectionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to connect to a camera
class ConnectToCameraEvent extends CameraConnectionEvent {
  final String cameraId;

  const ConnectToCameraEvent(this.cameraId);

  @override
  List<Object?> get props => [cameraId];
}

/// Event to disconnect from camera
class DisconnectFromCameraEvent extends CameraConnectionEvent {
  final String cameraId;

  const DisconnectFromCameraEvent(this.cameraId);

  @override
  List<Object?> get props => [cameraId];
}
