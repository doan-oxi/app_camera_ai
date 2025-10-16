import 'package:custom_camera_app/features/camera_connection/data/models/camera_model.dart';
import 'package:custom_camera_app/infrastructure/sdk/veepai/veepai_sdk_adapter.dart';

/// Remote data source interface (SDK calls)
abstract class VeepaiRemoteDataSource {
  Future<CameraModel> connectCamera(String cameraId, String password);
  Future<void> disconnectCamera(String cameraId);
  Future<CameraModel> getCameraStatus(String cameraId);
  Stream<CameraModel> watchConnectionState(String cameraId);
}

/// Implementation using Veepai SDK adapter
class VeepaiRemoteDataSourceImpl implements VeepaiRemoteDataSource {
  final VeepaiSdkAdapter _sdkAdapter;

  VeepaiRemoteDataSourceImpl(this._sdkAdapter);

  @override
  Future<CameraModel> connectCamera(String cameraId, String password) async {
    await _sdkAdapter.connect(deviceId: cameraId, password: password);

    return CameraModel(
      id: cameraId,
      name: cameraId, // Will be updated from SDK later
      status: _sdkAdapter.getConnectionStatus(),
    );
  }

  @override
  Future<void> disconnectCamera(String cameraId) async {
    await _sdkAdapter.disconnect();
  }

  @override
  Future<CameraModel> getCameraStatus(String cameraId) async {
    final status = _sdkAdapter.getConnectionStatus();

    return CameraModel(
      id: cameraId,
      name: cameraId,
      status: status,
    );
  }

  @override
  Stream<CameraModel> watchConnectionState(String cameraId) {
    return _sdkAdapter.connectionStateStream.map(
      (status) => CameraModel(
        id: cameraId,
        name: cameraId,
        status: status,
      ),
    );
  }
}
