import '../entities/camera.dart';

/// Camera repository interface - defines contract for data layer
/// This is pure Dart, no implementation details
abstract class CameraRepository {
  /// Connect to a camera by ID
  Future<Camera> connect(String cameraId);

  /// Disconnect from a camera
  Future<void> disconnect(String cameraId);

  /// Get current camera status
  Future<Camera> getCameraStatus(String cameraId);

  /// Watch connection state stream
  Stream<Camera> watchConnectionState(String cameraId);
}
