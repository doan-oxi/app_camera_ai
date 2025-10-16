import 'dart:ffi';

import 'dart:io';

import 'dart:isolate';

import 'app_player.dart';

class vp_dart_execute_args_t extends Struct {
  external Pointer<NativeFunction<Void Function(Pointer<Void>)>> function;

  external Pointer<Void> args;

  external Pointer<Void> sync_lock;
}

typedef ProgressListener<T> = void Function(T data);

typedef GPSListener<T> = void Function(T data);

typedef VideoHeadListener<T> = void Function(T data);

class AppDart {
  static final AppDart _instance = AppDart._internal();

  factory AppDart() => _instance;

  int Function(Pointer<NativeFunction<Void Function(Pointer<Void>)>>,
      Pointer<vp_dart_execute_args_t>)? _vp_dart_execute;
  int Function(Pointer<Void>, int)? _vp_dart_init;
  void Function(
      Pointer<
          NativeFunction<
              Void Function(Uint64, Uint32, Uint32, Uint32, Uint32, Uint32,
                  Uint32, Uint32, Uint64, Uint64)>>)? _app_player_listener;
  void Function(
          Pointer<
              NativeFunction<
                  Void Function(
                      Uint64, Uint32, Uint32, Float, Float, Float, Float)>>)?
      _app_player_gps_listener;
  void Function(
          Pointer<
              NativeFunction<Void Function(Uint64, Uint32, Uint32, Uint32)>>)?
      _app_player_head_listener;

  static void _playerCallback(
      int textureId,
      int total_duration,
      int play_duration,
      int cache_progress,
      int loading_status,
      int velocity,
      int focal,
      int version,
      int timestamp,
      int mainFrameCount) {
    List list = [
      textureId,
      total_duration,
      play_duration,
      cache_progress,
      loading_status,
      velocity,
      focal,
      version,
      timestamp,
      mainFrameCount
    ];
    _listeners.forEach((element) {
      if (element != null) element(list);
    });
  }

  static void _playerGPSCallback(
      int textureId,
      int fix_status,
      int satellites_inview,
      double latitude,
      double logitude,
      double speed,
      double coursel) {
    List list = [
      textureId,
      fix_status,
      satellites_inview,
      latitude,
      logitude,
      speed,
      coursel
    ];
    _gpsListeners.forEach((element) {
      if (element != null) element(list);
    });
  }

  static void _playerVideoHeadCallback(
      int textureId, int resolution, int channel, int type) {
    List list = [textureId, resolution, channel, type];
    _headListeners.forEach((element) {
      if (element != null) element(list);
    });
  }

  final ReceivePort receivePort = ReceivePort("vp_dart_port");

  void _receiveOnData(message) {
    if (message is int && _vp_dart_execute != null) {
      final args = Pointer<vp_dart_execute_args_t>.fromAddress(message);
      _vp_dart_execute!(args.ref.function, args);
    }
  }

  AppDart._internal() {
    _vp_dart_execute = AppPlayerController.playerLib
        .lookup<
            NativeFunction<
                Int32 Function(
                    Pointer<NativeFunction<Void Function(Pointer<Void>)>>,
                    Pointer<vp_dart_execute_args_t>)>>("vp_dart_execute")
        .asFunction();
    _vp_dart_init = AppPlayerController.playerLib
        .lookup<NativeFunction<Int32 Function(Pointer<Void>, Int64)>>(
            "vp_dart_init")
        .asFunction();
    _app_player_listener = AppPlayerController.playerLib
        .lookup<
            NativeFunction<
                Void Function(
                    Pointer<
                        NativeFunction<
                            Void Function(
                                Uint64,
                                Uint32,
                                Uint32,
                                Uint32,
                                Uint32,
                                Uint32,
                                Uint32,
                                Uint32,
                                Uint64,
                                Uint64)>>)>>("app_player_listener")
        .asFunction();
    _app_player_gps_listener = AppPlayerController.playerLib
        .lookup<
            NativeFunction<
                Void Function(
                    Pointer<
                        NativeFunction<
                            Void Function(Uint64, Uint32, Uint32, Float, Float,
                                Float, Float)>>)>>("app_player_gps_listener")
        .asFunction();
    _app_player_head_listener = AppPlayerController.playerLib
        .lookup<
            NativeFunction<
                Void Function(
                    Pointer<
                        NativeFunction<
                            Void Function(Uint64, Uint32, Uint32,
                                Uint32)>>)>>("app_player_head_listener")
        .asFunction();

    receivePort.listen(_receiveOnData, onDone: () {
      print("vp_dart_port done");
    }, onError: (error) {
      print("vp_dart_port error:$error");
    });
    print(
        "data:${NativeApi.initializeApiDLData} nativePort:${receivePort.sendPort.nativePort}");
    _vp_dart_init!(
        NativeApi.initializeApiDLData, receivePort.sendPort.nativePort);
    _app_player_listener!(Pointer.fromFunction(_playerCallback));
    _app_player_gps_listener!(Pointer.fromFunction(_playerGPSCallback));
    _app_player_head_listener!(Pointer.fromFunction(_playerVideoHeadCallback));
  }

  static List<ProgressListener> _listeners = [];

  void addListener(ProgressListener listener) {
    _listeners.add(listener);
  }

  void rmvListener(ProgressListener listener) {
    _listeners.remove(listener);
  }

  static List<GPSListener> _gpsListeners = [];

  void addGPSListener(GPSListener listener) {
    _gpsListeners.add(listener);
  }

  void rmvGPSListener(GPSListener listener) {
    _gpsListeners.remove(listener);
  }

  static List<VideoHeadListener> _headListeners = [];

  void addVideoHeadListener(VideoHeadListener listener) {
    _headListeners.add(listener);
  }

  void rmvVideoHeadListener(VideoHeadListener listener) {
    _headListeners.remove(listener);
  }
}
