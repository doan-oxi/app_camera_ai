import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:vsdk/camera_device/camera_device.dart';
import 'package:custom_camera_app/core/constants/camera_constants.dart';
import 'package:custom_camera_app/core/logging/app_logger.dart';

/// Adapter for Veepai SDK (vsdk package)
/// Wraps CameraDevice and provides clean interface for data layer
class VeepaiSdkAdapter {
  final CameraDevice _cameraDevice;
  final _connectionStateSubject = BehaviorSubject<String>();

  VeepaiSdkAdapter(this._cameraDevice) {
    _initializeListeners();
  }

  /// Stream of connection state changes
  Stream<String> get connectionStateStream => _connectionStateSubject.stream;

  /// Current connection state
  String get currentState => _cameraDevice.connectState;

  /// Initialize SDK listeners
  void _initializeListeners() {
    // Listen to connection state changes
    _cameraDevice.addListener<String>((state) {
      AppLogger.debug('Connection state changed: $state');
      _connectionStateSubject.add(state);
    });
  }

  /// Connect to camera
  Future<void> connect({
    required String deviceId,
    required String password,
    int timeout = CameraConstants.connectionTimeout,
  }) async {
    try {
      AppLogger.info('Connecting to camera: $deviceId');

      // Set connection parameters
      _cameraDevice.realdeviceid = deviceId;
      _cameraDevice.password = password;

      // Connect with timeout
      await _cameraDevice.connect(lanScan: true).timeout(
        Duration(milliseconds: timeout),
        onTimeout: () {
          throw TimeoutException('Connection timeout after ${timeout}ms');
        },
      );

      // Wait for connected state
      await _waitForState('connected', timeout: timeout);

      AppLogger.info('Successfully connected to camera: $deviceId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to connect to camera: $deviceId', e, stackTrace);
      rethrow;
    }
  }

  /// Disconnect from camera
  Future<void> disconnect() async {
    try {
      AppLogger.info('Disconnecting from camera');
      await _cameraDevice.disconnect();
      AppLogger.info('Successfully disconnected');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to disconnect', e, stackTrace);
      rethrow;
    }
  }

  /// Get current connection status
  String getConnectionStatus() {
    return _cameraDevice.connectState;
  }

  /// Check if camera is connected
  bool isConnected() {
    return _cameraDevice.connectState == 'connected';
  }

  /// Send CGI command
  Future<String> sendCgiCommand(
    String command, {
    int timeout = CameraConstants.commandTimeout,
  }) async {
    try {
      AppLogger.debug('Sending CGI command: $command');

      final result = await _cameraDevice
          .writeCgi(command)
          .timeout(Duration(milliseconds: timeout));

      AppLogger.debug('CGI command result: $result');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to send CGI command: $command', e, stackTrace);
      rethrow;
    }
  }

  /// Wait for specific connection state
  Future<void> _waitForState(
    String expectedState, {
    int timeout = CameraConstants.connectionTimeout,
  }) async {
    final completer = Completer<void>();
    late final StreamSubscription<String> subscription;

    // Create timeout timer
    final timer = Timer(Duration(milliseconds: timeout), () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(
          TimeoutException('Timeout waiting for state: $expectedState'),
        );
      }
    });

    // Listen for state changes
    subscription = _connectionStateSubject.listen((state) {
      if (state == expectedState) {
        timer.cancel();
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      } else if (state == 'timeout' || state == 'disconnect') {
        timer.cancel();
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.completeError(Exception('Connection failed: $state'));
        }
      }
    });

    // Check current state first
    if (_cameraDevice.connectState == expectedState) {
      timer.cancel();
      subscription.cancel();
      return;
    }

    return completer.future;
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await disconnect();
      await _connectionStateSubject.close();
      _cameraDevice.deviceDestroy();
      AppLogger.debug('VeepaiSdkAdapter disposed');
    } catch (e, stackTrace) {
      AppLogger.error('Error disposing VeepaiSdkAdapter', e, stackTrace);
    }
  }
}
