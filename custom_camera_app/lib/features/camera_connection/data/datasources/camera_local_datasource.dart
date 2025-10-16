import 'package:custom_camera_app/features/camera_connection/data/models/camera_model.dart';
import 'package:custom_camera_app/infrastructure/storage/hive_storage.dart';
import 'package:custom_camera_app/core/constants/camera_constants.dart';

/// Local data source interface (cache operations)
abstract class CameraLocalDataSource {
  Future<void> cacheCamera(CameraModel camera);
  CameraModel? getCachedCamera(String cameraId);
  Future<void> clearCache(String cameraId);
}

/// Implementation using Hive storage
class CameraLocalDataSourceImpl implements CameraLocalDataSource {
  final HiveStorage _storage;

  CameraLocalDataSourceImpl(this._storage);

  @override
  Future<void> cacheCamera(CameraModel camera) async {
    final key = CacheKeys.cameraDetails(camera.id);
    await _storage.put(key, camera.toJson());
  }

  @override
  CameraModel? getCachedCamera(String cameraId) {
    final key = CacheKeys.cameraDetails(cameraId);
    final data = _storage.get<Map<String, dynamic>>(
      key,
      ttlSeconds: CameraConstants.statusCacheDuration,
    );

    return data != null ? CameraModel.fromJson(data) : null;
  }

  @override
  Future<void> clearCache(String cameraId) async {
    final key = CacheKeys.cameraDetails(cameraId);
    await _storage.delete(key);
  }
}
