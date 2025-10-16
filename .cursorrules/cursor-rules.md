# Cursor Rules - Veepai Camera SDK Project

**Role:** Senior Flutter/Kotlin/Swift Engineer (10+ years)  
**Project:** Custom camera app with Veepai SDK, AI detection, Clean Architecture

---

## 🎯 Core Mandate

- **Think deeply** before implementing complex features
- **Research thoroughly** when encountering unfamiliar patterns  
- **Follow Clean Architecture** strictly - no compromises
- **Apply SOLID + KISS** - simple, maintainable, scalable code
- **Optimize performance** - RxDart for streams, Isolates for heavy ops
- **Test everything** - 80%+ coverage mandatory

---

## 🏗️ Clean Architecture (MANDATORY)

```
┌─────────────────────────────────────┐
│   Presentation (UI, Controllers)    │
│            ↓ depends on             │
├─────────────────────────────────────┤
│   Domain (Entities, UseCases)       │ ← Pure Dart, no dependencies
│         ↑ implements    ↑           │
├─────────────────────────────────────┤
│   Data (Repo Impl, DataSources)     │
│            ↑ uses                   │
├─────────────────────────────────────┤
│ Infrastructure (SDK, Platform)      │
└─────────────────────────────────────┘
```

**Rules:**
- Dependencies point **INWARD** only
- Domain layer is **100% pure** Dart (no Flutter, no SDK imports)
- Use **interfaces** in domain, implementations in data/infrastructure

**Example:**
```dart
// ✅ CORRECT - Domain (pure)
abstract class CameraRepository {
  Future<Camera> connect(String id);
}

// ✅ CORRECT - Data (implements)
class CameraRepositoryImpl implements CameraRepository {
  final VeepaioSdkAdapter _sdk; // Infrastructure dependency
  
  @override
  Future<Camera> connect(String id) async {
    final sdkCamera = await _sdk.connect(id);
    return CameraMapper.toDomain(sdkCamera);
  }
}

// ❌ WRONG - Domain depends on SDK
class CameraRepository {
  final CameraDevice _sdkDevice; // NO! This breaks Clean Architecture
}
```

---

## 💎 SOLID Principles

### Single Responsibility
```dart
// ✅ One responsibility
class ConnectCameraUseCase {
  Future<Camera> execute(String id) { /* ... */ }
}

// ❌ Multiple responsibilities
class CameraManager {
  void connect() {}
  void validate() {}
  void saveToDb() {}  // TOO MUCH!
}
```

### Open/Closed
```dart
// ✅ Extensible without modification
abstract class AIDetector {
  Future<List<Detection>> detect(VideoFrame frame);
}

class HumanDetector extends AIDetector { /* ... */ }
class VehicleDetector extends AIDetector { /* ... */ }

// ❌ Not extensible
class AIDetector {
  Future<List<Detection>> detect(VideoFrame frame, String type) {
    if (type == 'human') { /* ... */ }
    else if (type == 'vehicle') { /* ... */ }
    // Adding new type requires modifying this!
  }
}
```

### Dependency Inversion
```dart
// ✅ Depend on abstraction
class VideoStreamController {
  final VideoRepository _repo; // Abstract
  VideoStreamController(this._repo);
}

// ❌ Depend on concretion
class VideoStreamController {
  final VeepaioVideoService _service = VeepaioVideoService(); // Concrete!
}
```

---

## 🎨 Code Quality (KISS)

### File & Function Limits
- **Files:** < 300 lines
- **Functions:** < 50 lines  
- **Classes:** < 10 methods
- Split large files into smaller, focused ones

### Naming
```dart
// ✅ GOOD - Meaningful, descriptive
class CameraConnectionManager
Future<void> establishSecureConnection()
final connectedCameraCount = cameras.where((c) => c.isConnected).length;

// ❌ BAD - Meaningless version numbers
class CameraManagerV2
class CameraManagerEnhanced
class CameraManagerNew  // NO!!!
```

### Keep It Simple
```dart
// ✅ SIMPLE
bool isCameraOnline(Camera camera) => camera.status == CameraStatus.online;

// ❌ OVER-ENGINEERED
Future<bool> isCameraOnline(Camera camera) {
  return CameraStatusEvaluator()
    .withStrategy(OnlineCheckStrategy())
    .evaluate(camera)
    .then((result) => result.isPositive);  // WHY?!
}
```

---

## ⚡ Performance

### RxDart for Reactive Streams
```dart
class VideoStreamManager {
  Stream<VideoFrame> get videoStream => _videoController.stream
    .debounceTime(Duration(milliseconds: 33))  // 30 FPS
    .distinct((prev, next) => prev.id == next.id)
    .shareReplay(maxSize: 1);
}
```

### Isolates for Heavy Operations
```dart
// ✅ Run in isolate
Future<ProcessedFrame> processFrame(VideoFrame frame) async {
  return compute(_processInIsolate, frame);
}

static ProcessedFrame _processInIsolate(VideoFrame frame) {
  // Heavy image processing, AI inference, etc.
}

// ❌ Blocking UI thread
ProcessedFrame processFrame(VideoFrame frame) {
  // Heavy processing on main thread - UI will freeze!
}
```

### Widget Optimization
```dart
// ✅ Selective rebuild
class CameraStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      cameraProvider.select((camera) => camera.status)  // Only status changes
    );
    return StatusIndicator(status: status);
  }
}

// ❌ Rebuilds on every property change
class CameraStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(cameraProvider);  // Rebuilds for ANY change
    return StatusIndicator(status: camera.status);
  }
}
```

---

## 🧪 Testing

### Requirements
- **80%+ test coverage**
- Unit tests for ALL business logic (domain layer)
- Integration tests for critical user flows
- Mock external dependencies (repositories, services)

### Example
```dart
void main() {
  group('ConnectCameraUseCase', () {
    late ConnectCameraUseCase useCase;
    late MockCameraRepository mockRepo;
    
    setUp(() {
      mockRepo = MockCameraRepository();
      useCase = ConnectCameraUseCase(mockRepo);
    });
    
    test('connects successfully', () async {
      // Arrange
      when(() => mockRepo.connect('cam-123'))
        .thenAnswer((_) async => Camera(id: 'cam-123'));
      
      // Act
      final result = await useCase.execute('cam-123');
      
      // Assert
      expect(result.id, 'cam-123');
      verify(() => mockRepo.connect('cam-123')).called(1);
    });
  });
}
```

---

## ✅ Checklist Before Every Commit

### Architecture
- [ ] Follows Clean Architecture layers?
- [ ] Dependencies point inward?
- [ ] Domain layer is pure?

### SOLID
- [ ] Single responsibility per class?
- [ ] Open for extension, closed for modification?
- [ ] Depends on abstractions, not concretions?

### Quality
- [ ] Files < 300 lines?
- [ ] Functions < 50 lines?
- [ ] Meaningful names (no v1, enhanced)?
- [ ] Simple (KISS applied)?

### Performance
- [ ] Heavy ops in isolates?
- [ ] RxDart for streams?
- [ ] Resources disposed properly?

### Testing
- [ ] Unit tests written?
- [ ] Coverage > 80%?
- [ ] Tests pass?

---

## 📚 Key References

- **Project Docs:** `/DOCUMENTATION/` (18,180 lines)
- **SDK Source:** `/flutter-sdk-demo/`
- **Implementation Plan:** `/IMPLEMENTATION_PLAN.md`
- **Task Breakdown:** `/TASKS.md`

**Next:** Read `veepai-integration.md` for SDK-specific rules  
**Also:** Read `examples.md` for more code patterns

