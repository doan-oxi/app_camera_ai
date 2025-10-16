// Domain Layer - Use Case
// Following Clean Architecture & Single Responsibility Principle

import '../../entities/camera/camera.dart';
import '../../repositories/camera_repository.dart';

/// Use case for connecting to a camera.
/// 
/// This use case encapsulates the business logic for establishing
/// a connection to a camera device.
/// 
/// Principles applied:
/// - Single Responsibility: Only handles camera connection logic
/// - Dependency Inversion: Depends on repository abstraction
/// - Clean Architecture: Pure business logic, no framework dependencies
/// 
/// Example usage:
/// ```dart
/// final useCase = ConnectCameraUseCase(repository);
/// final camera = await useCase.execute('camera-123');
/// ```
class ConnectCameraUseCase {
  const ConnectCameraUseCase(this._repository);

  final CameraRepository _repository;

  /// Execute the use case
  /// 
  /// Connects to the camera with the given [cameraId].
  /// 
  /// Throws:
  /// - [CameraNotFoundException] if camera doesn't exist
  /// - [CameraConnectionException] if connection fails
  /// - [NetworkException] if no internet connection
  /// 
  /// Returns the connected [Camera] instance.
  Future<Camera> execute(String cameraId) async {
    // 1. Validate input
    if (cameraId.isEmpty) {
      throw ArgumentError('Camera ID cannot be empty');
    }

    // 2. Get camera details
    final camera = await _repository.getCameraById(cameraId);

    // 3. Check if already connected
    if (camera.isOnline) {
      return camera;
    }

    // 4. Attempt connection
    final connectedCamera = await _repository.connect(cameraId);

    // 5. Return result
    return connectedCamera;
  }
}

/// Exception thrown when camera is not found
class CameraNotFoundException implements Exception {
  const CameraNotFoundException(this.cameraId);

  final String cameraId;

  @override
  String toString() => 'Camera not found: $cameraId';
}

/// Exception thrown when camera connection fails
class CameraConnectionException implements Exception {
  const CameraConnectionException(this.message);

  final String message;

  @override
  String toString() => 'Camera connection failed: $message';
}

/// Exception thrown when no network is available
class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => 'Network error: $message';
}

