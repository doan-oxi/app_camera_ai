// Domain Layer - Repository Interface
// Following Clean Architecture & Dependency Inversion Principle

import '../entities/camera/camera.dart';

/// Repository interface for camera operations.
/// 
/// This interface defines the contract for camera data access.
/// It resides in the domain layer and is implemented in the data layer.
/// 
/// Principles applied:
/// - Dependency Inversion: Domain depends on abstractions, not concretions
/// - Interface Segregation: Only methods related to camera operations
/// - Single Responsibility: Only handles camera data access
abstract class CameraRepository {
  /// Get list of all cameras
  /// 
  /// Returns a stream that emits the current camera list and updates
  /// whenever cameras are added, removed, or changed.
  Stream<List<Camera>> watchCameraList();

  /// Get a single camera by ID
  /// 
  /// Throws [CameraNotFoundException] if camera doesn't exist.
  Future<Camera> getCameraById(String id);

  /// Connect to a camera
  /// 
  /// Establishes P2P connection to the camera.
  /// Throws [CameraConnectionException] if connection fails.
  Future<Camera> connect(String cameraId);

  /// Disconnect from a camera
  /// 
  /// Gracefully closes the connection.
  Future<void> disconnect(String cameraId);

  /// Add a new camera
  /// 
  /// Adds camera to the local database and initiates binding process.
  Future<Camera> addCamera(Camera camera);

  /// Remove a camera
  /// 
  /// Removes camera from the system.
  Future<void> removeCamera(String cameraId);

  /// Update camera settings
  /// 
  /// Updates camera configuration and syncs with device.
  Future<Camera> updateCamera(Camera camera);

  /// Check if camera is reachable
  /// 
  /// Performs a quick health check without establishing full connection.
  Future<bool> isReachable(String cameraId);
}

