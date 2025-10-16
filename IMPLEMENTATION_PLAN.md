# 🎯 Custom Camera App - Implementation Plan
**Created: October 16, 2025**  
**Status: Planning Phase**

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture Design](#architecture-design)
3. [Technology Stack](#technology-stack)
4. [Folder Structure](#folder-structure)
5. [Feature Breakdown](#feature-breakdown)
6. [Implementation Phases](#implementation-phases)
7. [Performance Optimization Strategy](#performance-optimization-strategy)
8. [Testing Strategy](#testing-strategy)
9. [Dependencies](#dependencies)
10. [Timeline & Milestones](#timeline--milestones)

---

## 🎯 Project Overview

### Vision
Build a production-ready, custom Flutter camera application that leverages the Veepai SDK to provide:
- **Real-time video streaming** from multiple cameras
- **Advanced AI detection** (human, vehicle, custom objects)
- **Smart alarm management** with ML-powered filtering
- **PTZ control** with preset positions and tours
- **Offline-first architecture** with seamless cloud sync
- **Multi-user collaboration** features

### Goals
- ✅ Clean Architecture with strict layer separation
- ✅ High performance (60 FPS video, < 100ms latency)
- ✅ Production-grade code quality (SOLID, KISS, OOP)
- ✅ Comprehensive test coverage (>80%)
- ✅ Scalable and maintainable codebase

### Non-Goals
- ❌ Over-engineering with unnecessary abstractions
- ❌ Premature optimization
- ❌ Complex patterns without clear benefit

---

## 🏗️ Architecture Design

### Clean Architecture Layers

```
┌───────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │   Widgets   │  │  State Management   │  │
│  │             │  │             │  │   (Riverpod/GetX)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬──────────────────────────────────┘
                             │ ViewModel/Controller
┌────────────────────────────▼──────────────────────────────────┐
│                        DOMAIN LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │  Entities   │  │  Use Cases  │  │  Repository          │ │
│  │   (Pure)    │  │   (Logic)   │  │   Interfaces         │ │
│  └─────────────┘  └─────────────┘  └──────────────────────┘ │
└────────────────────────────┬──────────────────────────────────┘
                             │ Repository Implementation
┌────────────────────────────▼──────────────────────────────────┐
│                         DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │  Repository │  │    Models   │  │   Data Sources       │ │
│  │     Impl    │  │    (DTOs)   │  │  (Remote/Local)      │ │
│  └─────────────┘  └─────────────┘  └──────────────────────┘ │
└────────────────────────────┬──────────────────────────────────┘
                             │ SDK/API Calls
┌────────────────────────────▼──────────────────────────────────┐
│                    INFRASTRUCTURE LAYER                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  Veepai SDK     │  │  AI/ML Services │  │   Platform   │ │
│  │   Wrapper       │  │   Integration   │  │   Services   │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

### Dependency Flow
- **Presentation** → **Domain** ← **Data** ← **Infrastructure**
- **Inner layers never depend on outer layers**
- **Use dependency injection** for cross-layer communication

---

## 💻 Technology Stack

### Flutter/Dart
```yaml
dependencies:
  # Core
  flutter_riverpod: ^2.4.0      # State management
  get_it: ^7.6.0                # Dependency injection
  freezed: ^2.4.0               # Immutable models
  
  # Reactive Programming
  rxdart: ^0.27.0               # Reactive streams
  
  # Network & Storage
  dio: ^5.3.0                   # HTTP client
  hive: ^2.2.3                  # Local database
  shared_preferences: ^2.2.0    # Simple storage
  
  # Video & Camera
  # Veepai SDK (local dependency)
  camera: ^0.10.5               # Camera access
  video_player: ^2.7.0          # Video playback
  
  # AI/ML
  tflite_flutter: ^0.10.0       # TensorFlow Lite
  image: ^4.0.0                 # Image processing
  
  # UI
  flutter_screenutil: ^5.9.0    # Responsive UI
  cached_network_image: ^3.3.0  # Image caching
  shimmer: ^3.0.0               # Loading effects
  
  # Utilities
  intl: ^0.18.0                 # Internationalization
  logger: ^2.0.0                # Logging
  equatable: ^2.0.5             # Value equality
  
dev_dependencies:
  # Testing
  mockito: ^5.4.0               # Mocking
  faker: ^2.1.0                 # Test data
  
  # Code Generation
  build_runner: ^2.4.0
  freezed_annotation: ^2.4.0
  json_serializable: ^6.7.0
```

### Native (Platform-Specific)

**Android (Kotlin)**
- Coroutines for async
- Jetpack components
- Veepai SDK integration

**iOS (Swift)**
- Async/await
- Combine framework
- Veepai SDK integration

---

## 📁 Folder Structure

```
custom_camera_app/
├── lib/
│   ├── core/                              # Core utilities
│   │   ├── di/                            # Dependency injection
│   │   │   ├── injection_container.dart   # GetIt setup
│   │   │   └── providers.dart             # Riverpod providers
│   │   ├── error/                         # Error handling
│   │   │   ├── exceptions.dart
│   │   │   ├── failures.dart
│   │   │   └── error_handler.dart
│   │   ├── network/                       # Network utilities
│   │   │   ├── api_client.dart
│   │   │   └── network_info.dart
│   │   ├── constants/                     # App constants
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   └── utils/                         # General utilities
│   │       ├── date_utils.dart
│   │       ├── logger.dart
│   │       └── validators.dart
│   │
│   ├── domain/                            # Business logic layer
│   │   ├── entities/                      # Domain entities
│   │   │   ├── camera/
│   │   │   │   ├── camera.dart
│   │   │   │   ├── camera_status.dart
│   │   │   │   └── ptz_position.dart
│   │   │   ├── alarm/
│   │   │   │   ├── alarm.dart
│   │   │   │   ├── alarm_rule.dart
│   │   │   │   └── detection_zone.dart
│   │   │   ├── video/
│   │   │   │   ├── video_stream.dart
│   │   │   │   ├── video_frame.dart
│   │   │   │   └── recording.dart
│   │   │   └── ai/
│   │   │       ├── detection_result.dart
│   │   │       ├── tracked_object.dart
│   │   │       └── ai_model.dart
│   │   │
│   │   ├── repositories/                  # Repository interfaces
│   │   │   ├── camera_repository.dart
│   │   │   ├── alarm_repository.dart
│   │   │   ├── video_repository.dart
│   │   │   └── ai_repository.dart
│   │   │
│   │   └── usecases/                      # Use cases
│   │       ├── camera/
│   │       │   ├── connect_camera.dart
│   │       │   ├── disconnect_camera.dart
│   │       │   ├── get_camera_list.dart
│   │       │   ├── control_ptz.dart
│   │       │   └── update_camera_settings.dart
│   │       ├── alarm/
│   │       │   ├── configure_alarm.dart
│   │       │   ├── get_alarm_history.dart
│   │       │   └── handle_alarm_event.dart
│   │       ├── video/
│   │       │   ├── start_live_stream.dart
│   │       │   ├── stop_live_stream.dart
│   │       │   ├── start_recording.dart
│   │       │   └── playback_recording.dart
│   │       └── ai/
│   │           ├── detect_objects.dart
│   │           ├── track_object.dart
│   │           └── classify_detection.dart
│   │
│   ├── data/                              # Data layer
│   │   ├── models/                        # Data models (DTOs)
│   │   │   ├── camera_model.dart
│   │   │   ├── alarm_model.dart
│   │   │   ├── video_model.dart
│   │   │   └── ai_model.dart
│   │   │
│   │   ├── repositories/                  # Repository implementations
│   │   │   ├── camera_repository_impl.dart
│   │   │   ├── alarm_repository_impl.dart
│   │   │   ├── video_repository_impl.dart
│   │   │   └── ai_repository_impl.dart
│   │   │
│   │   ├── datasources/                   # Data sources
│   │   │   ├── local/                     # Local storage
│   │   │   │   ├── camera_local_ds.dart
│   │   │   │   ├── alarm_local_ds.dart
│   │   │   │   └── database/
│   │   │   │       └── app_database.dart
│   │   │   └── remote/                    # Remote API
│   │   │       ├── camera_remote_ds.dart
│   │   │       └── alarm_remote_ds.dart
│   │   │
│   │   └── mappers/                       # Model <-> Entity mappers
│   │       ├── camera_mapper.dart
│   │       ├── alarm_mapper.dart
│   │       ├── video_mapper.dart
│   │       └── ai_mapper.dart
│   │
│   ├── infrastructure/                    # External integrations
│   │   ├── veepai_sdk/                    # Veepai SDK wrapper
│   │   │   ├── veepai_camera_adapter.dart
│   │   │   ├── veepai_alarm_adapter.dart
│   │   │   ├── veepai_video_adapter.dart
│   │   │   ├── veepai_ptz_adapter.dart
│   │   │   └── veepai_ai_adapter.dart
│   │   │
│   │   ├── ai/                            # AI/ML integrations
│   │   │   ├── detection/
│   │   │   │   ├── object_detector.dart
│   │   │   │   ├── human_detector.dart
│   │   │   │   └── vehicle_detector.dart
│   │   │   ├── tracking/
│   │   │   │   ├── object_tracker.dart
│   │   │   │   └── multi_object_tracker.dart
│   │   │   └── classification/
│   │   │       └── image_classifier.dart
│   │   │
│   │   ├── video_processing/              # Video processing
│   │   │   ├── frame_decoder.dart
│   │   │   ├── frame_encoder.dart
│   │   │   └── video_compressor.dart
│   │   │
│   │   └── platform/                      # Platform-specific code
│   │       ├── android/
│   │       │   └── camera_service.kt
│   │       └── ios/
│   │           └── CameraService.swift
│   │
│   ├── presentation/                      # UI layer
│   │   ├── camera/                        # Camera feature
│   │   │   ├── controllers/
│   │   │   │   ├── camera_list_controller.dart
│   │   │   │   └── camera_detail_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── camera_card.dart
│   │   │   │   ├── ptz_control_widget.dart
│   │   │   │   └── camera_status_indicator.dart
│   │   │   └── screens/
│   │   │       ├── camera_list_screen.dart
│   │   │       └── camera_detail_screen.dart
│   │   │
│   │   ├── video/                         # Video streaming feature
│   │   │   ├── controllers/
│   │   │   │   └── video_stream_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── video_player_widget.dart
│   │   │   │   └── video_controls.dart
│   │   │   └── screens/
│   │   │       ├── live_view_screen.dart
│   │   │       └── playback_screen.dart
│   │   │
│   │   ├── alarm/                         # Alarm feature
│   │   │   ├── controllers/
│   │   │   │   ├── alarm_config_controller.dart
│   │   │   │   └── alarm_history_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── alarm_card.dart
│   │   │   │   ├── detection_zone_editor.dart
│   │   │   │   └── alarm_settings_panel.dart
│   │   │   └── screens/
│   │   │       ├── alarm_config_screen.dart
│   │   │       └── alarm_history_screen.dart
│   │   │
│   │   ├── ai_detection/                  # AI Detection feature
│   │   │   ├── controllers/
│   │   │   │   └── ai_detection_controller.dart
│   │   │   ├── widgets/
│   │   │   │   ├── detection_overlay.dart
│   │   │   │   └── tracked_objects_list.dart
│   │   │   └── screens/
│   │   │       └── ai_detection_screen.dart
│   │   │
│   │   ├── settings/                      # Settings feature
│   │   │   ├── controllers/
│   │   │   │   └── settings_controller.dart
│   │   │   ├── widgets/
│   │   │   │   └── settings_tile.dart
│   │   │   └── screens/
│   │   │       └── settings_screen.dart
│   │   │
│   │   └── shared/                        # Shared UI components
│   │       ├── widgets/
│   │       │   ├── custom_button.dart
│   │       │   ├── loading_indicator.dart
│   │       │   ├── error_widget.dart
│   │       │   └── empty_state.dart
│   │       └── themes/
│   │           ├── app_theme.dart
│   │           └── app_colors.dart
│   │
│   └── main.dart                          # App entry point
│
├── test/                                  # Unit tests
│   ├── domain/
│   │   └── usecases/
│   ├── data/
│   │   └── repositories/
│   └── infrastructure/
│
├── integration_test/                      # Integration tests
│   ├── camera_flow_test.dart
│   ├── alarm_flow_test.dart
│   └── ai_detection_flow_test.dart
│
├── android/                               # Android project
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           └── kotlin/
│   │               └── com/example/app/
│   │                   └── CameraService.kt
│   └── build.gradle
│
├── ios/                                   # iOS project
│   ├── Runner/
│   │   └── Services/
│   │       └── CameraService.swift
│   └── Podfile
│
├── assets/                                # Assets
│   ├── images/
│   ├── icons/
│   └── ai_models/
│       └── object_detection.tflite
│
├── .cursorrules                           # Cursor AI rules
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 🎯 Feature Breakdown

### Phase 1: Core Camera Features (Week 1-2)

#### 1.1 Camera Connection & Management
**Use Cases:**
- `ConnectCameraUseCase` - Establish P2P connection
- `DisconnectCameraUseCase` - Close connection gracefully
- `GetCameraListUseCase` - Fetch all cameras
- `GetCameraStatusUseCase` - Get real-time status

**Technical Details:**
```dart
// Example: ConnectCameraUseCase
class ConnectCameraUseCase {
  final CameraRepository repository;
  
  Future<Camera> execute(String cameraId) async {
    // 1. Validate camera ID
    // 2. Check network connectivity
    // 3. Establish P2P connection via SDK
    // 4. Initialize video stream
    // 5. Return connected camera entity
  }
}
```

**Performance:**
- Use isolates for connection handshake
- Cache camera metadata locally
- Implement connection pooling

#### 1.2 Live Video Streaming
**Use Cases:**
- `StartLiveStreamUseCase` - Begin live video
- `StopLiveStreamUseCase` - End live video
- `AdjustVideoQualityUseCase` - Change quality

**Technical Details:**
```dart
// RxDart stream for video frames
Stream<VideoFrame> getLiveStream(String cameraId) {
  return _sdkAdapter.getRawFrameStream(cameraId)
    .asyncMap((raw) => compute(_decodeFrame, raw))  // Isolate
    .debounceTime(const Duration(milliseconds: 33)) // 30 FPS
    .shareReplay(maxSize: 1);
}
```

**Performance:**
- Decode frames in isolates
- Buffer management (max 3 frames)
- Adaptive bitrate streaming

#### 1.3 PTZ Control
**Use Cases:**
- `ControlPTZUseCase` - Move camera
- `SavePresetPositionUseCase` - Save position
- `GoToPresetUseCase` - Move to preset

**Technical Details:**
```dart
class ControlPTZUseCase {
  Future<void> execute(PTZCommand command) async {
    // Validate command
    // Send to SDK
    // Wait for completion
    // Update camera state
  }
}
```

### Phase 2: Alarm & Detection (Week 3-4)

#### 2.1 Alarm Configuration
**Use Cases:**
- `ConfigureAlarmUseCase` - Set alarm rules
- `DefineDetectionZoneUseCase` - Draw zones
- `SetAlarmScheduleUseCase` - Configure schedule

**Technical Details:**
```dart
class ConfigureAlarmUseCase {
  Future<void> execute(AlarmConfiguration config) async {
    // 1. Validate configuration
    // 2. Convert to SDK format
    // 3. Send to camera
    // 4. Persist locally
    // 5. Update UI state
  }
}
```

#### 2.2 Alarm Monitoring
**Use Cases:**
- `MonitorAlarmsUseCase` - Real-time alarm stream
- `GetAlarmHistoryUseCase` - Fetch past alarms
- `HandleAlarmEventUseCase` - Process alarm

**Technical Details:**
```dart
// RxDart stream for alarms
Stream<AlarmEvent> monitorAlarms() {
  return Rx.merge([
    _sdkAdapter.getAlarmStream(),
    _localAlarmStream(),
    _cloudAlarmStream(),
  ])
  .distinct((prev, next) => prev.id == next.id)
  .map(_enrichWithAI);  // Add AI classification
}
```

### Phase 3: AI Features (Week 5-6)

#### 3.1 Object Detection
**Use Cases:**
- `DetectObjectsUseCase` - Real-time detection
- `ClassifyDetectionUseCase` - Classify objects
- `FilterDetectionsUseCase` - Filter by confidence

**Technical Details:**
```dart
class DetectObjectsUseCase {
  Future<List<Detection>> execute(VideoFrame frame) async {
    // Run in isolate
    return compute(_detectInIsolate, frame);
  }
  
  static List<Detection> _detectInIsolate(VideoFrame frame) {
    // Load TFLite model
    // Run inference
    // Parse results
    // Return detections
  }
}
```

**Performance:**
- Run inference in dedicated isolate
- Model quantization (INT8)
- Frame skipping (process every 3rd frame)
- ROI (Region of Interest) optimization

#### 3.2 Object Tracking
**Use Cases:**
- `TrackObjectUseCase` - Track single object
- `TrackMultipleObjectsUseCase` - Track multiple
- `AnalyzeTrajectoryUseCase` - Analyze movement

**Technical Details:**
```dart
class MultiObjectTracker {
  final Map<String, TrackedObject> _trackedObjects = {};
  
  List<TrackedObject> update(List<Detection> detections) {
    // 1. Match detections with existing tracks
    // 2. Update tracked objects
    // 3. Create new tracks
    // 4. Remove stale tracks
    // 5. Return active tracks
  }
}
```

#### 3.3 Smart Notifications
**Use Cases:**
- `FilterNotificationUseCase` - ML-based filtering
- `PrioritizeNotificationUseCase` - Priority scoring
- `SendSmartNotificationUseCase` - Send notification

**Technical Details:**
```dart
class FilterNotificationUseCase {
  Future<bool> shouldNotify(AlarmEvent event) async {
    // 1. Check user preferences
    // 2. Run ML classifier (is this important?)
    // 3. Check notification history (avoid spam)
    // 4. Calculate priority score
    // 5. Return decision
  }
}
```

### Phase 4: Advanced Features (Week 7-8)

#### 4.1 Offline-First Architecture
- Local database with Hive
- Sync queue for offline actions
- Conflict resolution

#### 4.2 Multi-Camera Dashboard
- Grid view with up to 16 cameras
- Adaptive layout
- Smart resource management

#### 4.3 Cloud Recording Playback
- Timeline view
- Scrubbing
- Download recordings

#### 4.4 User Management
- Multi-user support
- Role-based access
- Sharing cameras

---

## ⚡ Performance Optimization Strategy

### Video Streaming Optimization

```dart
class OptimizedVideoStreamManager {
  // Dedicated isolate for video decoding
  late final Isolate _decoderIsolate;
  late final SendPort _decoderSendPort;
  late final ReceivePort _decoderReceivePort;
  
  // Frame buffer (circular buffer)
  final _frameBuffer = CircularBuffer<VideoFrame>(capacity: 3);
  
  // RxDart stream
  final _frameController = BehaviorSubject<VideoFrame>();
  
  Future<void> initialize() async {
    // Spawn long-lived isolate
    _decoderReceivePort = ReceivePort();
    _decoderIsolate = await Isolate.spawn(
      _videoDecoderIsolate,
      _decoderReceivePort.sendPort,
    );
    
    _decoderSendPort = await _decoderReceivePort.first;
    
    // Listen for decoded frames
    _decoderReceivePort.listen((frame) {
      _frameBuffer.add(frame);
      _frameController.add(frame);
    });
  }
  
  void processRawFrame(RawVideoFrame raw) {
    // Send to isolate for decoding
    _decoderSendPort.send(raw);
  }
  
  Stream<VideoFrame> get frameStream => _frameController.stream
    .debounceTime(const Duration(milliseconds: 33))  // 30 FPS
    .shareReplay(maxSize: 1);
}
```

### AI Detection Optimization

```dart
class OptimizedAIDetector {
  late final Isolate _detectorIsolate;
  late final SendPort _detectorSendPort;
  
  // Frame skipping for performance
  int _frameCounter = 0;
  static const _processEveryNthFrame = 3;
  
  Future<void> initialize() async {
    // Spawn isolate with loaded model
    _detectorIsolate = await Isolate.spawn(
      _aiDetectorIsolate,
      _receivePort.sendPort,
    );
  }
  
  Future<List<Detection>> detect(VideoFrame frame) async {
    // Skip frames
    if (_frameCounter++ % _processEveryNthFrame != 0) {
      return _lastDetections; // Return cached
    }
    
    // Send to isolate
    final completer = Completer<List<Detection>>();
    _detectorSendPort.send([frame, completer]);
    return completer.future;
  }
  
  static void _aiDetectorIsolate(SendPort sendPort) {
    // Load TFLite model once
    final interpreter = Interpreter.fromAsset('object_detection.tflite');
    
    ReceivePort().listen((message) {
      final frame = message[0] as VideoFrame;
      final completer = message[1] as Completer;
      
      // Run inference
      final detections = _runInference(interpreter, frame);
      completer.complete(detections);
    });
  }
}
```

### Memory Management

```dart
class MemoryManager {
  // Track active resources
  final _activeStreams = <String, StreamSubscription>{};
  final _activeIsolates = <String, Isolate>{};
  
  // Cleanup when memory pressure
  void handleMemoryPressure() {
    // Stop low-priority streams
    _stopBackgroundStreams();
    
    // Clear caches
    _imageCache.clear();
    
    // Request garbage collection
    // (Dart handles this automatically, but we can help)
  }
  
  // Resource tracking
  void registerStream(String id, StreamSubscription sub) {
    _activeStreams[id] = sub;
  }
  
  void unregisterStream(String id) {
    _activeStreams[id]?.cancel();
    _activeStreams.remove(id);
  }
  
  // Cleanup all
  Future<void> dispose() async {
    for (var sub in _activeStreams.values) {
      await sub.cancel();
    }
    
    for (var isolate in _activeIsolates.values) {
      isolate.kill();
    }
  }
}
```

---

## 🧪 Testing Strategy

### Unit Tests (Target: 80%+ coverage)

```dart
// Example: ConnectCameraUseCase test
void main() {
  group('ConnectCameraUseCase', () {
    late ConnectCameraUseCase useCase;
    late MockCameraRepository mockRepository;
    late MockNetworkInfo mockNetworkInfo;
    
    setUp(() {
      mockRepository = MockCameraRepository();
      mockNetworkInfo = MockNetworkInfo();
      useCase = ConnectCameraUseCase(
        repository: mockRepository,
        networkInfo: mockNetworkInfo,
      );
    });
    
    test('should connect to camera when network is available', () async {
      // Arrange
      const cameraId = 'test-camera-123';
      final expectedCamera = Camera(
        id: cameraId,
        name: 'Test Camera',
        status: CameraStatus.online,
      );
      
      when(() => mockNetworkInfo.isConnected)
        .thenAnswer((_) async => true);
      when(() => mockRepository.connect(cameraId))
        .thenAnswer((_) async => expectedCamera);
      
      // Act
      final result = await useCase.execute(cameraId);
      
      // Assert
      expect(result, equals(expectedCamera));
      verify(() => mockNetworkInfo.isConnected).called(1);
      verify(() => mockRepository.connect(cameraId)).called(1);
    });
    
    test('should throw NetworkException when no internet', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected)
        .thenAnswer((_) async => false);
      
      // Act & Assert
      expect(
        () => useCase.execute('test-camera-123'),
        throwsA(isA<NetworkException>()),
      );
      verifyNever(() => mockRepository.connect(any()));
    });
  });
}
```

### Integration Tests

```dart
// Example: Camera connection flow test
void main() {
  testWidgets('should connect to camera and display live stream', (tester) async {
    // Setup
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cameraRepositoryProvider.overrideWithValue(
            FakeCameraRepository(),
          ),
        ],
        child: const MyApp(),
      ),
    );
    
    // Navigate to camera list
    await tester.tap(find.byIcon(Icons.video_call));
    await tester.pumpAndSettle();
    
    // Verify camera list is displayed
    expect(find.text('Living Room'), findsOneWidget);
    expect(find.text('Front Door'), findsOneWidget);
    
    // Tap on a camera
    await tester.tap(find.text('Living Room'));
    await tester.pumpAndSettle();
    
    // Verify live stream is displayed
    expect(find.byType(VideoPlayerWidget), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    
    // Test PTZ control
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    
    // Verify PTZ command was sent
    // (check via mock repository)
  });
}
```

### Performance Tests

```dart
// Example: Video stream performance test
void main() {
  test('should maintain 30 FPS for video stream', () async {
    final manager = VideoStreamManager();
    await manager.initialize();
    
    // Collect frame timestamps
    final timestamps = <DateTime>[];
    
    manager.frameStream.listen((frame) {
      timestamps.add(DateTime.now());
    });
    
    // Generate 100 frames
    for (var i = 0; i < 100; i++) {
      manager.processRawFrame(generateTestFrame());
      await Future.delayed(const Duration(milliseconds: 33));
    }
    
    // Calculate average FPS
    final totalTime = timestamps.last.difference(timestamps.first);
    final avgFps = timestamps.length / totalTime.inSeconds;
    
    // Assert FPS is close to 30
    expect(avgFps, greaterThan(28));
    expect(avgFps, lessThan(32));
  });
}
```

---

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.0
  get_it: ^7.6.0
  
  # Reactive Programming
  rxdart: ^0.27.0
  
  # Network
  dio: ^5.3.0
  connectivity_plus: ^5.0.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0
  
  # Camera & Video
  camera: ^0.10.5
  video_player: ^2.7.0
  
  # AI/ML
  tflite_flutter: ^0.10.0
  image: ^4.0.0
  
  # Utilities
  freezed: ^2.4.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  equatable: ^2.0.5
  logger: ^2.0.0
  intl: ^0.18.0
  
  # UI
  flutter_screenutil: ^5.9.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_svg: ^2.0.0
```

### Dev Dependencies
```yaml
dev_dependencies:
  # Testing
  mockito: ^5.4.0
  faker: ^2.1.0
  integration_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  
  # Linting
  flutter_lints: ^3.0.0
```

---

## 📅 Timeline & Milestones

### Week 1-2: Foundation & Core Camera Features
**Milestone 1: Camera Connection**
- ✅ Setup project structure
- ✅ Implement Clean Architecture layers
- ✅ Integrate Veepai SDK
- ✅ Camera connection/disconnection
- ✅ Camera list management
- ✅ Basic unit tests

**Deliverable:** Working camera connection with live stream

### Week 3-4: Video Streaming & PTZ Control
**Milestone 2: Live Video & Control**
- ✅ Live video streaming (optimized)
- ✅ PTZ control (up/down/left/right/zoom)
- ✅ Preset positions
- ✅ Video quality adjustment
- ✅ Integration tests

**Deliverable:** Full-featured camera control app

### Week 5-6: Alarm & Detection
**Milestone 3: Alarm Management**
- ✅ Alarm configuration
- ✅ Detection zones
- ✅ Alarm history
- ✅ Push notifications
- ✅ Alarm filtering

**Deliverable:** Complete alarm management system

### Week 7-8: AI Features
**Milestone 4: AI Detection**
- ✅ Object detection (TFLite)
- ✅ Object tracking
- ✅ Smart notifications
- ✅ Performance optimization
- ✅ Comprehensive testing

**Deliverable:** AI-powered camera app

### Week 9-10: Polish & Launch
**Milestone 5: Production Ready**
- ✅ UI/UX refinement
- ✅ Performance optimization
- ✅ Bug fixes
- ✅ Documentation
- ✅ App store preparation

**Deliverable:** Production-ready app

---

## 🎯 Success Metrics

### Performance KPIs
- **Video Latency:** < 100ms end-to-end
- **Frame Rate:** 30 FPS consistently
- **App Launch Time:** < 2 seconds
- **Camera Connection Time:** < 3 seconds
- **AI Detection Latency:** < 200ms per frame

### Quality KPIs
- **Test Coverage:** > 80%
- **Crash Rate:** < 0.1%
- **Bug Density:** < 1 bug per 1000 lines
- **Code Review Approval Rate:** 100%

### User Experience KPIs
- **App Store Rating:** > 4.5 stars
- **User Retention (30-day):** > 60%
- **Feature Adoption:** > 70% for core features

---

## 🚀 Next Steps

1. **Review this plan** with the team
2. **Setup development environment**
3. **Create initial project structure**
4. **Implement Milestone 1** (Weeks 1-2)
5. **Iterate based on feedback**

---

## 📚 References

- [Clean Architecture Documentation](/DOCUMENTATION/01-ARCHITECTURE.md)
- [Veepai SDK Reference](/DOCUMENTATION/13-API-REFERENCE.md)
- [Cursor Rules](/.cursorrules)
- [Flutter Best Practices](https://flutter.dev/docs/development/ui/best-practices)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart)

---

**Last Updated:** October 16, 2025  
**Status:** ✅ Planning Complete - Ready for Implementation

