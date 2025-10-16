# Veepai Camera App - Custom Implementation

Clean Architecture Flutter app for Veepai camera integration with AI features.

## ✅ Milestone M1 - Project Scaffold (COMPLETED)

### What's Done
- [x] Flutter project created with iOS/Android platforms
- [x] Clean Architecture folder structure
- [x] Core utilities (errors, usecases, logging, constants, DI)
- [x] Dependencies configured (Bloc, GetIt, RxDart, Dio, Hive, Logger)
- [x] Camera connection feature skeleton (domain/data/presentation)
- [x] Code verified with `flutter analyze` (no issues)

### Folder Structure
```
lib/
├── core/
│   ├── config/         # App configuration
│   ├── constants/      # App constants
│   ├── di/             # Dependency injection (GetIt)
│   ├── errors/         # Failure hierarchy
│   ├── extensions/     # Dart extensions
│   ├── logging/        # AppLogger
│   ├── theme/          # Colors, text styles
│   └── usecases/       # Base UseCase interface
├── features/
│   └── camera_connection/
│       ├── domain/     # Entities, repos, usecases (pure Dart)
│       ├── data/       # Models, repo impls, datasources
│       └── presentation/ # Bloc, screens, widgets
├── infrastructure/
│   ├── sdk/veepai/     # Veepai SDK wrappers
│   ├── network/        # HTTP clients
│   └── storage/        # Local storage
└── main.dart
```

## Next Steps (M2 - Domain Layer)
- Implement complete domain entities and repository interfaces
- Add use cases for connect, disconnect, stream
- Unit tests for domain layer

## Tech Stack
- **Flutter SDK**: ^3.7.2
- **State Management**: flutter_bloc ^8.1.6
- **DI**: get_it ^8.0.2
- **Reactive**: rxdart ^0.28.0
- **Network**: dio ^4.0.6
- **Storage**: hive ^2.2.3, shared_preferences ^2.3.3
- **Testing**: bloc_test, mocktail

## Run Commands
```bash
# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run app
flutter run

# Run tests
flutter test
```

## Clean Architecture Principles
- ✅ Domain = Pure Dart (no Flutter/SDK dependencies)
- ✅ Dependencies point inward only
- ✅ Single Responsibility per class
- ✅ Files < 300 lines
- ✅ Meaningful names (no v1, manager, handler)
