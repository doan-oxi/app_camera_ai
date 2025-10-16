import 'package:custom_camera_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';
import '../repositories/camera_repository.dart';

/// Use case for disconnecting from a camera
class DisconnectCamera implements UseCase<void, DisconnectCameraParams> {
  final CameraRepository repository;

  DisconnectCamera(this.repository);

  @override
  Future<void> call(DisconnectCameraParams params) async {
    return await repository.disconnect(params.cameraId);
  }
}

/// Parameters for DisconnectCamera use case
class DisconnectCameraParams extends Equatable {
  final String cameraId;

  const DisconnectCameraParams({required this.cameraId});

  @override
  List<Object> get props => [cameraId];
}
