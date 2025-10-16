# Contributing to Veepai Custom Camera App

Thank you for considering contributing to this project! This document outlines our code quality standards, development workflow, and best practices.

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Code Quality Standards](#code-quality-standards)
5. [Architecture Guidelines](#architecture-guidelines)
6. [Testing Requirements](#testing-requirements)
7. [Pull Request Process](#pull-request-process)
8. [Coding Conventions](#coding-conventions)

---

## 🤝 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Follow the project's technical standards

---

## 🚀 Getting Started

### Prerequisites

```bash
# Flutter SDK 3.16+
flutter --version

# Dart SDK 3.2+
dart --version
```

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd custom_camera_app

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

---

## 🔄 Development Workflow

### Branch Naming

```
feature/camera-connection
bugfix/video-stream-memory-leak
refactor/clean-architecture-layers
docs/api-documentation
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(camera): add P2P connection support
fix(video): resolve memory leak in stream decoder
refactor(domain): separate camera entities by feature
docs(readme): update setup instructions
test(alarm): add unit tests for alarm configuration
perf(ai): optimize object detection performance
chore(deps): update flutter_riverpod to 2.4.0
```

**Format:**
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `test`: Test additions/changes
- `perf`: Performance improvements
- `chore`: Maintenance tasks
- `style`: Code style changes
- `ci`: CI/CD changes

---

## ✅ Code Quality Standards

### Linting

All code must pass static analysis:

```bash
# Run analyzer
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

**Zero warnings policy** - All code must be warning-free before merging.

### Formatting

```bash
# Format all Dart files
dart format .

# Check formatting without modifying
dart format --output=none --set-exit-if-changed .
```

**Settings:**
- Line length: 80 characters
- Indent: 2 spaces
- Single quotes for strings
- Trailing commas for multi-line

### Code Metrics

| Metric | Limit |
|--------|-------|
| File length | < 300 lines |
| Function length | < 50 lines |
| Class methods | < 20 methods |
| Function parameters | < 5 parameters |
| Cyclomatic complexity | < 10 |
| Cognitive complexity | < 15 |

### Naming Conventions

**✅ Good:**
```dart
class CameraConnectionCoordinator { }
class VideoFrameProcessor { }
Future<void> connectCamera() async { }
bool isConnectionEstablished = false;
final activeCamera = Camera(...);
```

**❌ Bad:**
```dart
class CameraManager { }          // Too generic
class CameraHandlerV2 { }        // Versioned name
Future<void> connect() async { } // Too vague
bool flag = false;               // Unclear
final cam = Camera(...);         // Abbreviated
```

**Forbidden words:**
- Manager, Handler, Helper, Util, Service
- v1, v2, new, old, enhanced
- Single letters (except loop counters)
- Abbreviations (mgr, tmp, conn)

---

## 🏗️ Architecture Guidelines

### Clean Architecture Layers

```
Presentation → Domain ← Data ← Infrastructure
```

**Rules:**
1. **Domain layer** = Pure Dart only (no Flutter, no SDK)
2. **Data layer** = Implements domain interfaces, converts models ↔ entities
3. **Infrastructure layer** = SDK integration, platform-specific code
4. **Presentation layer** = UI, state management, depends only on domain

### File Organization

```
lib/
├── core/                    # Shared utilities
│   ├── di/                  # Dependency injection
│   ├── errors/              # Error handling
│   ├── constants/           # Constants
│   └── usecases/            # Base UseCase class
│
├── features/                # Feature modules
│   └── camera_connection/
│       ├── data/
│       │   ├── models/      # DTOs
│       │   ├── repositories/# Repository implementations
│       │   └── datasources/ # Data sources
│       ├── domain/
│       │   ├── entities/    # Business objects
│       │   ├── repositories/# Repository interfaces
│       │   └── usecases/    # Business logic
│       └── presentation/
│           ├── bloc/        # State management
│           ├── screens/     # Full pages
│           └── widgets/     # Reusable components
```

### Dependency Injection

**Register in `lib/core/di/injection_container.dart`:**

```dart
// Data sources
sl.registerLazySingleton<CameraDataSource>(
  () => VeepaiCameraDataSource(sdk: sl()),
);

// Repositories
sl.registerLazySingleton<CameraRepository>(
  () => CameraRepositoryImpl(dataSource: sl()),
);

// Use cases
sl.registerLazySingleton(() => ConnectCameraUseCase(repository: sl()));

// Blocs (factory - new instance each time)
sl.registerFactory(() => CameraConnectionBloc(connectCamera: sl()));
```

---

## 🧪 Testing Requirements

### Test Coverage

**Minimum 80% coverage** for all new code.

```bash
# Run all tests with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

### Test Types

#### Unit Tests (Required)

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
    
    test('should return camera when connection succeeds', () async {
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
    
    test('should return failure when connection fails', () async {
      // Arrange
      when(() => mockRepository.connect(any()))
        .thenAnswer((_) async => Left(ConnectionFailure()));
      
      // Act
      final result = await useCase('test-camera-123');
      
      // Assert
      expect(result, Left(ConnectionFailure()));
    });
  });
}
```

#### Widget Tests (Required for UI)

```dart
// test/features/camera_connection/presentation/widgets/camera_card_test.dart

void main() {
  testWidgets('CameraCard displays camera information', (tester) async {
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
  });
}
```

#### Integration Tests (For critical flows)

```dart
// integration_test/camera_connection_flow_test.dart

void main() {
  testWidgets('complete camera connection flow', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Tap on camera list
    await tester.tap(find.byIcon(Icons.video_call));
    await tester.pumpAndSettle();
    
    // Verify camera list
    expect(find.text('Living Room'), findsOneWidget);
    
    // Tap on camera
    await tester.tap(find.text('Living Room'));
    await tester.pumpAndSettle();
    
    // Verify connection
    expect(find.text('Connected'), findsOneWidget);
  });
}
```

---

## 🔍 Pull Request Process

### Before Submitting

✅ **Checklist:**
- [ ] Code passes `flutter analyze` with zero warnings
- [ ] Code is formatted with `dart format`
- [ ] All tests pass (`flutter test`)
- [ ] Test coverage ≥ 80% for new code
- [ ] Documentation updated (if needed)
- [ ] No commented-out code
- [ ] No debug print statements
- [ ] Follows Clean Architecture
- [ ] File sizes < 300 lines
- [ ] Function sizes < 50 lines

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Refactoring
- [ ] Documentation
- [ ] Performance improvement

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

### Review Process

1. **Automated checks** must pass:
   - Linting (`flutter analyze`)
   - Formatting (`dart format`)
   - Tests (`flutter test`)
   - Build (`flutter build`)

2. **Code review** by at least one maintainer
3. **Approval** required before merge
4. **Squash and merge** for clean history

---

## 🎨 Coding Conventions

### Dart Style Guide

Follow [Effective Dart](https://dart.dev/guides/language/effective-dart):

#### DO: Use trailing commas

```dart
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Hello'),
        Text('World'),
      ],
    ),
  );
}
```

#### DO: Use const constructors

```dart
const SizedBox(height: 16)
const EdgeInsets.all(8)
const Duration(seconds: 1)
```

#### DO: Declare types explicitly

```dart
// Good
final String userName = 'John';
final List<Camera> cameras = [];

// Bad (implicit types)
final userName = 'John';
final cameras = [];
```

#### DO: Use meaningful names

```dart
// Good
Future<void> connectCameraToNetwork() async { }
bool isConnectionEstablished = false;

// Bad
Future<void> connect() async { }
bool flag = false;
```

#### DON'T: Use print for logging

```dart
// Good
logger.info('Camera connected: $cameraId');
logger.error('Connection failed', error, stackTrace);

// Bad
print('Camera connected');
```

### Flutter Best Practices

#### Use const widgets

```dart
// Good
const Text('Hello')
const SizedBox(height: 16)

// Bad
Text('Hello')
SizedBox(height: 16)
```

#### Extract complex widgets

```dart
// Good - Widget extracted to separate file
class CameraCard extends StatelessWidget {
  const CameraCard({required this.camera, super.key});
  
  final Camera camera;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(camera.name),
        subtitle: Text(camera.status.toString()),
      ),
    );
  }
}

// Bad - Complex widget inline
ListView.builder(
  itemBuilder: (context, index) {
    return Card(
      child: Column(
        children: [
          // 50+ lines of widget code
        ],
      ),
    );
  },
)
```

#### Use keys for stateful widgets in lists

```dart
ListView.builder(
  itemBuilder: (context, index) {
    final camera = cameras[index];
    return CameraCard(
      key: ValueKey(camera.id), // Important!
      camera: camera,
    );
  },
)
```

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Project Documentation](/DOCUMENTATION/INDEX.md)

---

## ❓ Questions?

If you have questions:
1. Check the [documentation](/DOCUMENTATION/INDEX.md)
2. Review existing code for examples
3. Open an issue for discussion

---

**Happy coding!** 🚀

