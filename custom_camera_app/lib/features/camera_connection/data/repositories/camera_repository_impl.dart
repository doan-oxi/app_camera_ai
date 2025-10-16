import 'package:custom_camera_app/core/errors/failure.dart';
import 'package:custom_camera_app/features/camera_connection/domain/entities/camera.dart';
import 'package:custom_camera_app/features/camera_connection/domain/repositories/camera_repository.dart';
import 'package:custom_camera_app/features/camera_connection/data/datasources/veepai_remote_datasource.dart';
import 'package:custom_camera_app/features/camera_connection/data/datasources/camera_local_datasource.dart';
import 'package:custom_camera_app/core/logging/app_logger.dart';

/// Repository implementation - orchestrates data sources
class CameraRepositoryImpl implements CameraRepository {
  final VeepaiRemoteDataSource _remoteDataSource;
  final CameraLocalDataSource _localDataSource;

  CameraRepositoryImpl({
    required VeepaiRemoteDataSource remoteDataSource,
    required CameraLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Camera> connect(String cameraId) async {
    try {
      AppLogger.info('Connecting to camera: $cameraId');

      // TODO: Get password from secure storage
      const password = ''; // Placeholder

      final cameraModel = await _remoteDataSource.connectCamera(
        cameraId,
        password,
      );

      // Cache the camera
      await _localDataSource.cacheCamera(cameraModel);

      return cameraModel.toEntity();
    } on TimeoutException catch (e, stackTrace) {
      AppLogger.error('Connection timeout', e, stackTrace);
      throw const TimeoutFailure(
        message: 'Connection timeout. Please check your network.',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to connect camera', e, stackTrace);
      throw ConnectionFailure(
        message: 'Failed to connect: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> disconnect(String cameraId) async {
    try {
      AppLogger.info('Disconnecting from camera: $cameraId');
      await _remoteDataSource.disconnectCamera(cameraId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to disconnect camera', e, stackTrace);
      throw ConnectionFailure(
        message: 'Failed to disconnect: ${e.toString()}',
      );
    }
  }

  @override
  Future<Camera> getCameraStatus(String cameraId) async {
    try {
      // Try cache first
      final cachedCamera = _localDataSource.getCachedCamera(cameraId);
      if (cachedCamera != null) {
        AppLogger.debug('Returning cached camera status');
        return cachedCamera.toEntity();
      }

      // Fetch from remote
      final cameraModel = await _remoteDataSource.getCameraStatus(cameraId);

      // Update cache
      await _localDataSource.cacheCamera(cameraModel);

      return cameraModel.toEntity();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get camera status', e, stackTrace);
      throw const UnknownFailure(
        message: 'Failed to get camera status',
      );
    }
  }

  @override
  Stream<Camera> watchConnectionState(String cameraId) {
    try {
      return _remoteDataSource
          .watchConnectionState(cameraId)
          .map((model) => model.toEntity());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to watch connection state', e, stackTrace);
      rethrow;
    }
  }
}
