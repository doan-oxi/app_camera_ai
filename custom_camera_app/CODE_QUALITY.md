# Code Quality Guidelines

This document outlines the code quality standards and best practices for the Veepai Custom Camera App.

## 📊 Code Quality Metrics

### Target Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Test Coverage | ≥ 80% | TBD |
| Cyclomatic Complexity | < 10 | TBD |
| Maintainability Index | ≥ 70 | TBD |
| Technical Debt Ratio | < 5% | TBD |
| Code Duplication | < 3% | TBD |
| Documentation Coverage | 100% | TBD |

## 🎯 Quality Gates

### Pre-Commit Checks

```bash
# Run all quality checks before committing
./scripts/pre-commit-check.sh
```

**Includes:**
1. ✅ Static analysis (`flutter analyze`)
2. ✅ Code formatting (`dart format`)
3. ✅ Unit tests (`flutter test`)
4. ✅ Linter checks
5. ✅ Import organization
6. ✅ Unused code detection

### Pre-Push Checks

```bash
# Run comprehensive checks before pushing
./scripts/pre-push-check.sh
```

**Includes:**
1. ✅ All pre-commit checks
2. ✅ Integration tests
3. ✅ Test coverage verification
4. ✅ Build verification (Android + iOS)
5. ✅ Performance benchmarks

## 🔍 Static Analysis

### Analyzer Configuration

Our `analysis_options.yaml` enforces:

- **Zero warnings policy**
- Strong mode with strict inference
- All recommended Flutter lints
- Additional custom rules

### Running Analysis

```bash
# Analyze entire project
flutter analyze

# Analyze specific directory
flutter analyze lib/features/camera_connection

# Fix auto-fixable issues
dart fix --apply
```

### Common Issues

#### Implicit Casts
```dart
// ❌ Bad - Implicit cast
dynamic value = getValue();
String text = value;

// ✅ Good - Explicit cast
dynamic value = getValue();
String text = value as String;

// ✅ Better - Type safety
String value = getValue() as String;
```

#### Missing Return Types
```dart
// ❌ Bad - Missing return type
Future connectCamera(String id) async {
  return await repository.connect(id);
}

// ✅ Good - Explicit return type
Future<Camera> connectCamera(String id) async {
  return await repository.connect(id);
}
```

#### Unused Imports
```dart
// ❌ Bad - Unused import
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Not used

// ✅ Good - Only necessary imports
import 'package:flutter/material.dart';
```

## 📏 Code Formatting

### Dart Formatter

We use the official Dart formatter with these settings:

```bash
# Format all files
dart format .

# Check formatting (CI)
dart format --output=none --set-exit-if-changed .

# Format specific file
dart format lib/main.dart
```

### Style Rules

#### Line Length
- **Maximum:** 80 characters
- Use trailing commas to help formatter

```dart
// ✅ Good - Trailing commas enable better formatting
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('First line'),
        Text('Second line'),
      ],
    ),
  );
}
```

#### Import Organization

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:io';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party package imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

// 4. Local imports
import 'package:custom_camera_app/core/core.dart';
import 'package:custom_camera_app/features/camera/camera.dart';
```

## 🧪 Testing Standards

### Test Coverage Requirements

| Layer | Minimum Coverage |
|-------|------------------|
| Domain (UseCases) | 100% |
| Data (Repositories) | 90% |
| Presentation (Blocs) | 80% |
| Infrastructure | 60% |
| UI (Widgets) | 70% |

### Test Types

#### 1. Unit Tests

**Location:** `test/features/<feature>/<layer>/`

```dart
// test/features/camera_connection/domain/usecases/connect_camera_test.dart
void main() {
  group('ConnectCameraUseCase', () {
    late ConnectCameraUseCase useCase;
    late MockCameraRepository mockRepository;
    
    setUp(() {
      mockRepository = MockCameraRepository();
      useCase = ConnectCameraUseCase(repository: mockRepository);
    });
    
    test('should connect to camera successfully', () async {
      // Arrange
      const cameraId = 'test-camera-123';
      final expectedCamera = Camera(
        id: cameraId,
        name: 'Test Camera',
        status: CameraStatus.connected,
      );
      
      when(() => mockRepository.connect(cameraId))
        .thenAnswer((_) async => Right(expectedCamera));
      
      // Act
      final result = await useCase(cameraId);
      
      // Assert
      expect(result, Right(expectedCamera));
      verify(() => mockRepository.connect(cameraId)).called(1);
    });
  });
}
```

#### 2. Widget Tests

**Location:** `test/features/<feature>/presentation/widgets/`

```dart
// test/features/camera_connection/presentation/widgets/camera_card_test.dart
void main() {
  testWidgets('CameraCard displays camera information correctly', 
    (tester) async {
      // Arrange
      final camera = Camera(
        id: '123',
        name: 'Living Room',
        status: CameraStatus.connected,
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraCard(camera: camera),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Living Room'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
    },
  );
}
```

#### 3. Integration Tests

**Location:** `integration_test/`

```dart
// integration_test/camera_connection_flow_test.dart
void main() {
  testWidgets('complete camera connection flow', (tester) async {
    // Start app
    await tester.pumpWidget(const MyApp());
    
    // Navigate to camera list
    await tester.tap(find.byIcon(Icons.video_call));
    await tester.pumpAndSettle();
    
    // Verify camera list displayed
    expect(find.text('Living Room'), findsOneWidget);
    
    // Connect to camera
    await tester.tap(find.text('Living Room'));
    await tester.pumpAndSettle();
    
    // Verify connection successful
    expect(find.text('Connected'), findsOneWidget);
    expect(find.byType(VideoStreamWidget), findsOneWidget);
  });
}
```

### Running Tests

```bash
# Run all unit tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/camera_connection/domain/usecases/connect_camera_test.dart

# Run integration tests
flutter test integration_test/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📐 Architecture Compliance

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │  ← Flutter, UI, State Management
│  (Screens, Widgets, Blocs/Cubits)      │
└────────────────┬────────────────────────┘
                 │ depends on
┌────────────────▼────────────────────────┐
│           DOMAIN LAYER                  │  ← Pure Dart, Business Logic
│  (Entities, UseCases, Repositories)     │
└────────────────┬────────────────────────┘
                 │ implemented by
┌────────────────▼────────────────────────┐
│            DATA LAYER                   │  ← Data Management
│  (Models, Repository Impl, DataSources) │
└────────────────┬────────────────────────┘
                 │ uses
┌────────────────▼────────────────────────┐
│       INFRASTRUCTURE LAYER              │  ← External Dependencies
│  (SDK, API, Database, Platform)         │
└─────────────────────────────────────────┘
```

### Layer Rules

#### Domain Layer (Pure Dart)

**✅ Allowed:**
- `dart:core`, `dart:async`
- Domain entities
- Repository interfaces
- Use cases

**❌ Forbidden:**
- `package:flutter/*`
- `dart:io`, `dart:ui`
- Any third-party packages (except `equatable`, `dartz`)
- Platform-specific code

```dart
// ✅ Good - Pure Dart domain entity
class Camera extends Equatable {
  const Camera({
    required this.id,
    required this.name,
    required this.status,
  });
  
  final String id;
  final String name;
  final CameraStatus status;
  
  @override
  List<Object?> get props => [id, name, status];
}

// ❌ Bad - Flutter dependency in domain
import 'package:flutter/material.dart'; // NEVER in domain!

class Camera {
  final Color statusColor; // UI concern in domain!
}
```

#### Data Layer

**✅ Allowed:**
- Domain entities and interfaces
- Data models (DTOs)
- JSON serialization
- Repository implementations

**❌ Forbidden:**
- Direct SDK calls (use Infrastructure)
- UI components
- Business logic

```dart
// ✅ Good - Clean repository implementation
class CameraRepositoryImpl implements CameraRepository {
  CameraRepositoryImpl({required this.dataSource});
  
  final CameraDataSource dataSource;
  
  @override
  Future<Either<Failure, Camera>> connect(String cameraId) async {
    try {
      final model = await dataSource.connect(cameraId);
      return Right(model.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
```

## 🚀 Performance Standards

### Video Streaming

- **Frame Rate:** 30 FPS minimum
- **Latency:** < 100ms end-to-end
- **Memory:** < 100MB for single stream
- **CPU:** < 30% on mid-range devices

### AI Detection

- **Inference Time:** < 200ms per frame
- **Frame Processing:** Process every 3rd frame
- **Model Size:** < 10MB
- **Memory Usage:** < 50MB

### App Performance

- **Cold Start:** < 2 seconds
- **Hot Reload:** < 1 second
- **UI Smoothness:** 60 FPS
- **Memory Leaks:** Zero tolerance

### Optimization Techniques

```dart
// ✅ Use const constructors
const SizedBox(height: 16)
const EdgeInsets.all(8)

// ✅ Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ComplexAnimatedWidget(),
)

// ✅ Use ListView.builder for large lists
ListView.builder(
  itemCount: cameras.length,
  itemBuilder: (context, index) {
    return CameraCard(camera: cameras[index]);
  },
)

// ✅ Use compute for heavy computation
final result = await compute(processLargeData, data);

// ✅ Use Isolates for video/AI processing
final isolate = await Isolate.spawn(
  videoProcessingIsolate,
  receivePort.sendPort,
);
```

## 📝 Documentation Standards

### Code Documentation

```dart
/// Connects to a camera using the Veepai SDK.
///
/// This use case handles the complete camera connection flow:
/// 1. Validates the camera ID
/// 2. Checks network connectivity
/// 3. Establishes P2P connection
/// 4. Initializes video stream
///
/// Returns [Right<Camera>] on success or [Left<Failure>] on error.
///
/// Throws [NetworkException] if no internet connection.
/// Throws [CameraNotFoundException] if camera ID is invalid.
///
/// Example:
/// ```dart
/// final result = await connectCamera('camera-123');
/// result.fold(
///   (failure) => print('Connection failed'),
///   (camera) => print('Connected to ${camera.name}'),
/// );
/// ```
class ConnectCameraUseCase {
  const ConnectCameraUseCase({required this.repository});
  
  final CameraRepository repository;
  
  Future<Either<Failure, Camera>> call(String cameraId) async {
    // Implementation
  }
}
```

### Required Documentation

- Public APIs (100% coverage)
- Complex algorithms
- Performance-critical code
- Platform-specific code
- Third-party integrations

## 🔒 Security Standards

### API Keys

```dart
// ❌ NEVER hardcode API keys
const apiKey = 'sk-12345678'; // BAD!

// ✅ Use environment variables
final apiKey = const String.fromEnvironment('API_KEY');

// ✅ Use secure storage for sensitive data
await secureStorage.write(key: 'api_key', value: apiKey);
```

### Input Validation

```dart
// ✅ Always validate user input
Future<Either<Failure, Camera>> connect(String cameraId) async {
  if (cameraId.isEmpty) {
    return Left(InvalidInputFailure('Camera ID cannot be empty'));
  }
  
  if (!_isValidCameraId(cameraId)) {
    return Left(InvalidInputFailure('Invalid camera ID format'));
  }
  
  // Proceed with connection
}
```

## 🛠️ Development Tools

### Recommended VS Code Extensions

- Dart
- Flutter
- Error Lens
- Better Comments
- GitLens
- Bracket Pair Colorizer

### Recommended Android Studio Plugins

- Flutter
- Dart
- Flutter Intl
- Flutter Riverpod Snippets
- Rainbow Brackets

## 📋 Code Review Checklist

### Functionality
- [ ] Code works as intended
- [ ] Edge cases handled
- [ ] Error handling implemented
- [ ] No hardcoded values

### Architecture
- [ ] Follows Clean Architecture
- [ ] Proper layer separation
- [ ] No circular dependencies
- [ ] Dependency injection used

### Code Quality
- [ ] Passes static analysis
- [ ] Properly formatted
- [ ] Meaningful names
- [ ] No code duplication
- [ ] Files < 300 lines
- [ ] Functions < 50 lines

### Testing
- [ ] Unit tests added
- [ ] Widget tests added (if UI)
- [ ] Integration tests added (if needed)
- [ ] Coverage ≥ 80%
- [ ] All tests pass

### Documentation
- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] README updated (if needed)
- [ ] CHANGELOG updated

### Performance
- [ ] No performance regressions
- [ ] Optimized for target devices
- [ ] No memory leaks
- [ ] Proper resource cleanup

### Security
- [ ] No hardcoded secrets
- [ ] Input validation
- [ ] Secure data storage
- [ ] No SQL injection risks

## 📈 Continuous Improvement

### Metrics Tracking

We track these metrics weekly:

1. Test coverage percentage
2. Code duplication ratio
3. Cyclomatic complexity
4. Technical debt ratio
5. Build time
6. App performance metrics

### Regular Reviews

- **Weekly:** Code quality metrics review
- **Bi-weekly:** Architecture review
- **Monthly:** Technical debt assessment
- **Quarterly:** Performance audit

---

**Remember:** Quality is not an act, it's a habit! 🚀

