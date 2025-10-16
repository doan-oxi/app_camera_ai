# Code Examples & Patterns

**Quick reference for common patterns in this project**

---

## 🏗️ Clean Architecture Example

### Complete Flow: Connect Camera

```dart
// 1. DOMAIN LAYER - Entity (Pure Dart)
class Camera {
  final String id;
  final String name;
  final CameraStatus status;
  
  const Camera({required this.id, required this.name, required this.status});
  
  bool get isOnline => status == CameraStatus.online;
}

enum CameraStatus { online, offline, connecting }

// 2. DOMAIN LAYER - Repository Interface
abstract class CameraRepository {
  Future<Camera> connect(String cameraId);
  Stream<List<Camera>> watchCameraList();
}

// 3. DOMAIN LAYER - Use Case
class ConnectCameraUseCase {
  final CameraRepository _repository;
  
  ConnectCameraUseCase(this._repository);
  
  Future<Camera> execute(String cameraId) async {
    if (cameraId.isEmpty) throw ArgumentError('ID required');
    return await _repository.connect(cameraId);
  }
}

// 4. DATA LAYER - Model (DTO)
class CameraModel {
  final String deviceId;
  final String deviceName;
  final int statusCode;
  
  CameraModel({required this.deviceId, required this.deviceName, required this.statusCode});
  
  factory CameraModel.fromSdk(CameraDevice sdk) => CameraModel(
    deviceId: sdk.id,
    deviceName: sdk.name,
    statusCode: sdk.status.index,
  );
}

// 5. DATA LAYER - Mapper
class CameraMapper {
  static Camera toDomain(CameraModel model) => Camera(
    id: model.deviceId,
    name: model.deviceName,
    status: _mapStatus(model.statusCode),
  );
  
  static CameraStatus _mapStatus(int code) {
    return switch (code) {
      1 => CameraStatus.online,
      2 => CameraStatus.offline,
      _ => CameraStatus.connecting,
    };
  }
}

// 6. DATA LAYER - Repository Implementation
class CameraRepositoryImpl implements CameraRepository {
  final VeepaioSdkAdapter _sdk;
  final CameraLocalDataSource _local;
  
  CameraRepositoryImpl(this._sdk, this._local);
  
  @override
  Future<Camera> connect(String cameraId) async {
    try {
      final sdkDevice = await _sdk.connect(cameraId);
      final model = CameraModel.fromSdk(sdkDevice);
      await _local.save(model);
      return CameraMapper.toDomain(model);
    } catch (e) {
      throw CameraConnectionException('Failed: $e');
    }
  }
  
  @override
  Stream<List<Camera>> watchCameraList() {
    return _local.watchAll()
      .map((models) => models.map(CameraMapper.toDomain).toList());
  }
}

// 7. INFRASTRUCTURE LAYER - SDK Adapter
class VeepaioSdkAdapter {
  final AppP2PApi _p2pApi;
  
  VeepaioSdkAdapter(this._p2pApi);
  
  Future<CameraDevice> connect(String cameraId) async {
    final device = CameraDevice(id: cameraId);
    await device.connect();
    return device;
  }
}

// 8. PRESENTATION LAYER - Controller (Riverpod)
@riverpod
class CameraListController extends _$CameraListController {
  @override
  Future<List<Camera>> build() async {
    final repo = ref.read(cameraRepositoryProvider);
    return repo.watchCameraList().first;
  }
  
  Future<void> connectCamera(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(connectCameraUseCaseProvider);
      await useCase.execute(id);
      final repo = ref.read(cameraRepositoryProvider);
      return repo.watchCameraList().first;
    });
  }
}

// 9. PRESENTATION LAYER - Widget
class CameraListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasAsync = ref.watch(cameraListControllerProvider);
    
    return camerasAsync.when(
      data: (cameras) => ListView.builder(
        itemCount: cameras.length,
        itemBuilder: (context, index) => CameraCard(camera: cameras[index]),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget(error.toString()),
    );
  }
}
```

---

## 💎 SOLID Examples

### Single Responsibility
```dart
// ✅ Each class has ONE job
class VideoDecoder {
  Future<VideoFrame> decode(RawFrame raw) { /* ... */ }
}

class VideoPlayer {
  Future<void> play(VideoFrame frame) { /* ... */ }
}

class VideoRecorder {
  Future<void> record(VideoFrame frame) { /* ... */ }
}

// ❌ God class doing everything
class VideoManager {
  Future<void> decode() { /* ... */ }
  Future<void> play() { /* ... */ }
  Future<void> record() { /* ... */ }
  Future<void> upload() { /* ... */ }
  Future<void> compress() { /* ... */ }  // TOO MUCH!
}
```

### Open/Closed
```dart
// ✅ Add new detectors without modifying existing code
abstract class AIDetector {
  Future<List<Detection>> detect(VideoFrame frame);
}

class HumanDetector implements AIDetector {
  @override
  Future<List<Detection>> detect(VideoFrame frame) async {
    // Human detection logic
  }
}

class VehicleDetector implements AIDetector {
  @override
  Future<List<Detection>> detect(VideoFrame frame) async {
    // Vehicle detection logic
  }
}

// New detector - no modification to existing code
class PetDetector implements AIDetector {
  @override
  Future<List<Detection>> detect(VideoFrame frame) async {
    // Pet detection logic
  }
}

// ❌ Must modify for every new type
class AIDetector {
  Future<List<Detection>> detect(VideoFrame frame, String type) {
    if (type == 'human') { /* ... */ }
    else if (type == 'vehicle') { /* ... */ }
    // Adding pet requires modifying this method!
  }
}
```

### Liskov Substitution
```dart
// ✅ Subtypes are substitutable
abstract class Camera {
  Future<void> connect();
  Future<void> disconnect();
}

class PTZCamera extends Camera {
  @override
  Future<void> connect() async { /* ... */ }
  
  @override
  Future<void> disconnect() async { /* ... */ }
  
  // Additional PTZ methods
  Future<void> moveUp() async { /* ... */ }
}

// Can use PTZCamera anywhere Camera is expected
void useCamera(Camera camera) {
  camera.connect();  // Works for both Camera and PTZCamera
}

// ❌ Breaks contract
class OfflineCamera extends Camera {
  @override
  Future<void> connect() async {
    throw UnsupportedError('Cannot connect');  // Violates contract!
  }
}
```

### Interface Segregation
```dart
// ✅ Small, focused interfaces
abstract class Connectable {
  Future<void> connect();
  Future<void> disconnect();
}

abstract class PTZControllable {
  Future<void> moveUp();
  Future<void> moveDown();
  Future<void> moveLeft();
  Future<void> moveRight();
}

abstract class AICapable {
  Future<void> enableAI();
  Future<void> disableAI();
}

// Fixed camera only needs Connectable
class FixedCamera implements Connectable {
  @override
  Future<void> connect() async { /* ... */ }
  
  @override
  Future<void> disconnect() async { /* ... */ }
}

// PTZ camera needs both
class PTZCamera implements Connectable, PTZControllable {
  @override
  Future<void> connect() async { /* ... */ }
  
  @override
  Future<void> disconnect() async { /* ... */ }
  
  @override
  Future<void> moveUp() async { /* ... */ }
  // ... other PTZ methods
}

// ❌ Fat interface
abstract class Camera {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> moveUp();  // Fixed cameras don't need this!
  Future<void> moveDown();
  Future<void> enableAI();  // Not all cameras have AI!
}
```

### Dependency Inversion
```dart
// ✅ Depend on abstraction
class CameraListController {
  final CameraRepository _repository;  // Abstract
  
  CameraListController(this._repository);
}

// Injected via DI
final controller = CameraListController(
  CameraRepositoryImpl(sdk, local),
);

// ❌ Depend on concretion
class CameraListController {
  final CameraRepositoryImpl _repository;  // Concrete!
  
  CameraListController() : _repository = CameraRepositoryImpl();
}
```

---

## ⚡ Performance Patterns

### RxDart Stream
```dart
class AlarmMonitor {
  final _controller = BehaviorSubject<AlarmEvent>();
  
  Stream<AlarmEvent> get alarmStream => _controller.stream
    .debounceTime(Duration(seconds: 1))  // Prevent spam
    .distinct((prev, next) => prev.id == next.id)  // Deduplicate
    .where((event) => event.confidence > 0.8)  // Filter low confidence
    .shareReplay(maxSize: 10);  // Cache last 10 events
}
```

### Isolate for Heavy Work
```dart
// ✅ Use isolate
class ImageProcessor {
  Future<ProcessedImage> process(RawImage image) {
    return compute(_processInIsolate, image);
  }
  
  static ProcessedImage _processInIsolate(RawImage image) {
    // Heavy processing - doesn't block UI
    return ProcessedImage(/* ... */);
  }
}

// ❌ Block UI thread
class ImageProcessor {
  ProcessedImage process(RawImage image) {
    // Heavy processing on main thread - UI freezes!
    return ProcessedImage(/* ... */);
  }
}
```

### Widget Optimization
```dart
// ✅ Use const
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});  // const constructor
  
  @override
  Widget build(BuildContext context) {
    return const Card(  // const widget
      child: const Text('Hello'),  // const text
    );
  }
}

// ✅ Selective rebuild
class CameraCard extends ConsumerWidget {
  final String cameraId;
  
  const CameraCard({super.key, required this.cameraId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when name or status changes
    final name = ref.watch(
      cameraProvider(cameraId).select((c) => c.name)
    );
    final status = ref.watch(
      cameraProvider(cameraId).select((c) => c.status)
    );
    
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(status.toString()),
      ),
    );
  }
}
```

---

## ❌ Anti-Patterns

### God Class
```dart
// ❌ Doing too much
class CameraManager {
  void connect() {}
  void disconnect() {}
  void startVideo() {}
  void stopVideo() {}
  void saveToDatabase() {}
  void uploadToCloud() {}
  void processAI() {}
  void sendNotification() {}
  // ... 50 more methods
}

// ✅ Split responsibilities
class CameraConnectionService {
  void connect() {}
  void disconnect() {}
}

class VideoStreamService {
  void startVideo() {}
  void stopVideo() {}
}

class CameraStorageService {
  void saveToDatabase() {}
  void uploadToCloud() {}
}
```

### Magic Numbers
```dart
// ❌ What do these numbers mean?
if (camera.status == 1) {
  await Future.delayed(Duration(milliseconds: 500));
  final data = process(frame, 0.8, 640, 480);
}

// ✅ Named constants
const CameraStatus online = CameraStatus.online;
const Duration reconnectDelay = Duration(milliseconds: 500);
const double confidenceThreshold = 0.8;
const int videoWidth = 640;
const int videoHeight = 480;

if (camera.status == online) {
  await Future.delayed(reconnectDelay);
  final data = process(frame, confidenceThreshold, videoWidth, videoHeight);
}
```

### Swallowing Errors
```dart
// ❌ Hiding errors
Future<Camera?> connect(String id) async {
  try {
    return await _repository.connect(id);
  } catch (e) {
    return null;  // Where did the error go?!
  }
}

// ✅ Proper error handling
Future<Camera> connect(String id) async {
  try {
    return await _repository.connect(id);
  } on NetworkException catch (e) {
    throw CameraConnectionException('No network: $e');
  } on TimeoutException catch (e) {
    throw CameraConnectionException('Timeout: $e');
  } catch (e, stack) {
    logger.error('Unexpected error', e, stack);
    rethrow;
  }
}
```

---

## 📚 More Examples

See comprehensive documentation:
- **Architecture:** `/DOCUMENTATION/01-ARCHITECTURE.md`
- **Video Streaming:** `/DOCUMENTATION/03-VIDEO-STREAMING.md`
- **AI Features:** `/DOCUMENTATION/06-AI-FEATURES.md`
- **Code Examples:** `/DOCUMENTATION/09-CODE-EXAMPLES.md`
- **Best Practices:** `/DOCUMENTATION/10-BEST-PRACTICES.md`

