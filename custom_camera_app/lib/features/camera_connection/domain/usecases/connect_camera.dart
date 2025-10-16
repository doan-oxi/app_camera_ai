import 'package:custom_camera_app/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';
import '../entities/camera.dart';
import '../repositories/camera_repository.dart';

/// Use case for connecting to a camera
/// Single responsibility: handle camera connection logic
class ConnectCamera implements UseCase<Camera, ConnectCameraParams> {
  final CameraRepository repository;

  ConnectCamera(this.repository);

  @override
  Future<Camera> call(ConnectCameraParams params) async {
    return await repository.connect(params.cameraId);
  }
}

/// Parameters for ConnectCamera use case
class ConnectCameraParams extends Equatable {
  final String cameraId;

  const ConnectCameraParams({required this.cameraId});

  @override
  List<Object> get props => [cameraId];
}
