# Veepai SDK Integration Rules

**Purpose:** Wrap Veepai SDK properly in Infrastructure layer  
**Location:** `/flutter-sdk-demo/` contains the SDK source

---

## 🎯 Core Principle

**NEVER expose SDK classes to Domain layer!**

```
Domain (pure) ←  Data (implements) ← Infrastructure (wraps SDK)
```

---

## 📦 SDK Wrapper Pattern

### Structure
```dart
// Infrastructure Layer
class VeepaioSdkCameraAdapter {
  final CameraDevice _sdkDevice;  // SDK class
  
  VeepaioSdkCameraAdapter(this._sdkDevice);
  
  // Convert SDK streams to Domain streams
  Stream<CameraConnectionState> watchConnectionState() {
    return _sdkDevice.connectStateStream.map((sdkState) {
      return switch (sdkState) {
        ClientConnectState.CONNECT_STATE_SUCCEED => 
          CameraConnectionState.connected(),
        ClientConnectState.CONNECT_STATE_FAILED => 
          CameraConnectionState.failed(),
        _ => CameraConnectionState.connecting(),
      };
    });
  }
  
  // Wrap SDK commands with error handling
  Future<void> moveCamera(PTZDirection direction) async {
    try {
      await _sdkDevice.motor.motorStart(_mapDirection(direction));
    } catch (e) {
      throw CameraControlException('PTZ failed: $e');
    }
  }
}
```

---

## 🔗 P2P Connection Pattern

### Step-by-Step
```dart
class CameraConnectionService {
  final VeepaioSdkAdapter _sdk;
  
  Future<Camera> connect(String cameraId) async {
    // 1. Resolve VID to P2P address
    final p2pAddress = await _resolveVID(cameraId);
    
    // 2. Establish P2P connection
    final client = await _sdk.createP2PClient(p2pAddress);
    
    // 3. Login to camera
    await client.login(username: 'admin', password: '');
    
    // 4. Initialize video stream
    await client.startVideoStream();
    
    // 5. Return Domain entity
    return Camera(
      id: cameraId,
      status: CameraStatus.online,
      p2pClient: client,
    );
  }
  
  Future<String> _resolveVID(String cameraId) async {
    // Query vuid.eye4.cn for P2P address
    final response = await _dio.post(
      'https://vuid.eye4.cn/device/vuid/query',
      data: {'vuid': cameraId},
    );
    return response.data['p2pAddress'];
  }
}
```

---

## 🎥 Video Streaming with Isolates

### Pattern
```dart
class VideoStreamManager {
  Isolate? _decoderIsolate;
  SendPort? _sendPort;
  final _frameController = BehaviorSubject<VideoFrame>();
  
  Future<void> initialize(CameraDevice device) async {
    // Spawn long-lived isolate for decoding
    final receivePort = ReceivePort();
    _decoderIsolate = await Isolate.spawn(
      _videoDecoderIsolate,
      receivePort.sendPort,
    );
    
    _sendPort = await receivePort.first as SendPort;
    
    // Listen for decoded frames
    receivePort.listen((frame) {
      if (frame is VideoFrame) {
        _frameController.add(frame);
      }
    });
    
    // Send raw frames to isolate
    device.videoFrameStream.listen((rawFrame) {
      _sendPort!.send(rawFrame);
    });
  }
  
  Stream<VideoFrame> get videoStream => _frameController.stream
    .debounceTime(Duration(milliseconds: 33))  // 30 FPS
    .shareReplay(maxSize: 1);
  
  // Isolate entry point
  static void _videoDecoderIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    
    receivePort.listen((rawFrame) {
      // Heavy decoding work here
      final decoded = _decodeFrame(rawFrame);
      sendPort.send(decoded);
    });
  }
  
  void dispose() {
    _decoderIsolate?.kill();
    _frameController.close();
  }
}
```

---

## 🤖 AI Detection with SDK

### Pattern
```dart
class AIDetectionService {
  final CameraDevice _device;
  Isolate? _detectorIsolate;
  
  Future<void> enableHumanTracking() async {
    // Use SDK's built-in AI
    await _device.ai.humanTracking.setEnable(true);
    
    // Listen for detection events
    _device.ai.humanTracking.trackStatusStream.listen((status) {
      if (status == TrackStatus.tracking) {
        print('Human detected and tracking');
      }
    });
  }
  
  Future<void> configureCustomAI() async {
    // Custom AI config via CGI
    await _device.configAiDetectPlan(
      AiType.humanDetection,
      AiDetectPlan(
        enable: true,
        sensitivity: 5,
        detectionZone: [/* coordinates */],
      ),
    );
  }
  
  // Run custom ML model in isolate
  Future<List<Detection>> detectCustom(VideoFrame frame) async {
    return compute(_runTFLiteInference, frame);
  }
  
  static List<Detection> _runTFLiteInference(VideoFrame frame) {
    // Load TFLite model and run inference
    // Heavy operation - runs in isolate
  }
}
```

---

## 🚨 Alarm Management

### Pattern
```dart
class AlarmService {
  final CameraDevice _device;
  
  Future<void> configureMotionDetection() async {
    // Configure via SDK
    await _device.alarm.setAlarmMotionDetection(
      enable: true,
      level: 5,  // Sensitivity
    );
    
    // Set detection zone
    await _device.alarm.setAlarmZone(
      AlarmZone(
        type: ZoneType.motion,
        points: [/* polygon points */],
      ),
    );
    
    // Set alarm schedule
    await _device.alarm.setAlarmPlan(
      AlarmPlan.from24Hours(enable: true),
    );
  }
  
  Stream<AlarmEvent> watchAlarms() {
    // SDK alarm stream + custom filtering
    return _device.alarmEventStream
      .asyncMap((event) => _enrichWithAI(event))
      .where((event) => _shouldNotify(event));
  }
  
  Future<AlarmEvent> _enrichWithAI(AlarmEvent event) async {
    // Add AI classification to alarm
    if (event.hasSnapshot) {
      final detections = await _aiService.detect(event.snapshot);
      return event.copyWith(detections: detections);
    }
    return event;
  }
  
  bool _shouldNotify(AlarmEvent event) {
    // Smart filtering - reduce false positives
    return event.confidence > 0.8 && 
           event.detections.any((d) => d.type == 'human');
  }
}
```

---

## 🎛️ PTZ Control

### Pattern
```dart
class PTZController {
  final CameraDevice _device;
  
  Future<void> moveUp() async {
    await _device.motor.motorStart(MotorDirection.up);
    await Future.delayed(Duration(seconds: 1));
    await _device.motor.motorStop();
  }
  
  Future<void> gotoPreset(int presetId) async {
    await _device.presetCruise.gotoPreset(presetId);
  }
  
  Future<void> setPreset(int presetId, String name) async {
    await _device.presetCruise.setPreset(presetId, name);
  }
  
  // For multi-sensor cameras
  Future<void> switchSensor(int sensorId) async {
    await _device.changeCameraLens(sensorId);
  }
}
```

---

## 💾 Resource Management

### ALWAYS Dispose!
```dart
class CameraConnectionManager {
  final List<StreamSubscription> _subscriptions = [];
  final List<Isolate> _isolates = [];
  
  Future<void> connect(String cameraId) async {
    final device = await _sdk.connect(cameraId);
    
    // Track subscriptions
    _subscriptions.add(
      device.videoFrameStream.listen(_onVideoFrame)
    );
    _subscriptions.add(
      device.alarmEventStream.listen(_onAlarm)
    );
  }
  
  @override
  Future<void> dispose() async {
    // Cancel all subscriptions
    for (var sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    
    // Kill all isolates
    for (var isolate in _isolates) {
      isolate.kill();
    }
    _isolates.clear();
    
    super.dispose();
  }
}
```

---

## 🚫 Common Pitfalls

### DON'T
```dart
// ❌ Expose SDK classes in Domain
class Camera {
  final CameraDevice sdkDevice;  // NO!
}

// ❌ Decode video on main thread
void onVideoFrame(RawFrame frame) {
  final decoded = decodeH264(frame);  // Blocks UI!
}

// ❌ Forget to dispose
class VideoPlayer {
  StreamSubscription? _sub;
  // No dispose() - MEMORY LEAK!
}
```

### DO
```dart
// ✅ Pure domain entity
class Camera {
  final String id;
  final CameraStatus status;
  // No SDK references
}

// ✅ Decode in isolate
Future<VideoFrame> onVideoFrame(RawFrame frame) {
  return compute(_decode, frame);
}

// ✅ Always dispose
class VideoPlayer {
  StreamSubscription? _sub;
  
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
```

---

## 📚 SDK Documentation

- **Source Code:** `/flutter-sdk-demo/lib/`
- **Comprehensive Docs:** `/DOCUMENTATION/`
- **AI Features:** `/DOCUMENTATION/06-AI-FEATURES.md`
- **PTZ Control:** `/DOCUMENTATION/07-PTZ-CONTROL.md`
- **Alarm Management:** `/DOCUMENTATION/08-ALARM-MANAGEMENT.md`
- **API Reference:** `/DOCUMENTATION/13-API-REFERENCE.md`

**Next:** Read `examples.md` for more code patterns

