import 'package:equatable/equatable.dart';
import '../entities/camera.dart';
import '../repositories/camera_repository.dart';

/// Use case for watching camera connection state stream
/// Returns a stream of camera state updates
class WatchConnectionState {
  final CameraRepository repository;

  WatchConnectionState(this.repository);

  Stream<Camera> call(WatchConnectionParams params) {
    return repository.watchConnectionState(params.cameraId);
  }
}

/// Parameters for WatchConnectionState use case
class WatchConnectionParams extends Equatable {
  final String cameraId;

  const WatchConnectionParams({required this.cameraId});

  @override
  List<Object> get props => [cameraId];
}
