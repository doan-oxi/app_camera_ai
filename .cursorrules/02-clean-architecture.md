# Rule 02: Clean Architecture

## Scope
```
lib/**/*.dart
```

## Description
Enforce strict Clean Architecture with clear layer separation. Dependencies MUST point inward only.

## Layer Structure

```
┌────────────────────────────────────────┐
│         Presentation Layer             │
│    (UI, State Management, Widgets)     │
└──────────────┬─────────────────────────┘
               │ depends on
┌──────────────▼─────────────────────────┐
│          Domain Layer                  │
│   (Entities, UseCases, Interfaces)     │
└──────────────┬─────────────────────────┘
               │ implemented by
┌──────────────▼─────────────────────────┐
│           Data Layer                   │
│      (Repositories, Data Sources)      │
└──────────────┬─────────────────────────┘
               │ depends on
┌──────────────▼─────────────────────────┐
│      Infrastructure Layer              │
│    (SDK, Network, Storage, Platform)   │
└────────────────────────────────────────┘
```

## Folder Structure

```
lib/
├── domain/
│   ├── entities/          # Pure business objects
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business logic
├── data/
│   ├── models/            # DTOs, API models
│   ├── repositories/      # Repository implementations
│   └── datasources/       # Remote, local, SDK data sources
├── infrastructure/
│   ├── sdk/               # Veepai SDK wrapper
│   ├── network/           # HTTP, P2P clients
│   └── storage/           # Local DB, cache
└── presentation/
    ├── screens/           # Full screen pages
    ├── widgets/           # Reusable components
    └── state/             # State management (Bloc, Cubit, etc.)
```

## Layer Rules

### Domain Layer (Pure Dart)
**Scope**: `lib/domain/**/*.dart`

- ✅ ONLY pure Dart code
- ✅ NO Flutter imports (`package:flutter/...`)
- ✅ NO SDK imports (`package:vsdk/...`)
- ✅ NO platform imports (`dart:io`, `dart:ui`)
- ✅ Entities are immutable classes
- ✅ Repository interfaces define contracts
- ✅ UseCases contain single business operation

```dart
// ✅ Good: Pure domain entity
class Camera {
  final String id;
  final String name;
  final CameraStatus status;
  
  const Camera({
    required this.id,
    required this.name,
    required this.status,
  });
}

// ✅ Good: Repository interface
abstract class CameraRepository {
  Future<Camera> getCamera(String id);
  Stream<CameraStatus> watchStatus(String id);
}

// ❌ Bad: Flutter dependency in domain
import 'package:flutter/material.dart'; // NEVER in domain!
class Camera extends ChangeNotifier { ... }
```

### Data Layer
**Scope**: `lib/data/**/*.dart`

- ✅ Implements domain repository interfaces
- ✅ Converts between models and entities
- ✅ Coordinates data sources
- ❌ NO business logic
- ❌ NO UI concerns

```dart
// ✅ Good: Repository implementation
class CameraRepositoryImpl implements CameraRepository {
  final VeepaiSdkDataSource _sdkSource;
  final CameraLocalDataSource _localSource;
  
  @override
  Future<Camera> getCamera(String id) async {
    final model = await _sdkSource.fetchCamera(id);
    return model.toEntity(); // Convert model → entity
  }
}
```

### Infrastructure Layer
**Scope**: `lib/infrastructure/**/*.dart`

- ✅ Direct SDK integration
- ✅ Network clients
- ✅ Platform channels
- ✅ Database access
- ❌ NO business logic
- ❌ Returns models, not entities

```dart
// ✅ Good: SDK wrapper
class VeepaiSdkDataSource {
  final CameraDevice _device;
  
  Future<CameraModel> fetchCamera(String id) async {
    final status = await _device.getStatus();
    return CameraModel.fromSdk(status);
  }
}
```

### Presentation Layer
**Scope**: `lib/presentation/**/*.dart`

- ✅ Flutter widgets and UI code
- ✅ State management (Bloc, Cubit, Provider)
- ✅ Depends ONLY on domain layer
- ❌ NO direct SDK calls
- ❌ NO data layer dependencies

```dart
// ✅ Good: UI calls UseCase
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final GetCameraUseCase _getCamera;
  
  void _onLoad(CameraEvent event, Emitter emit) async {
    final camera = await _getCamera(event.cameraId);
    emit(CameraLoaded(camera));
  }
}
```

## Dependency Rule
**Dependencies point INWARD only:**
- Presentation → Domain
- Data → Domain
- Infrastructure → Data
- Domain → NOTHING (pure)

## File Size Limits
- Files: < 300 lines
- Functions: < 50 lines
- Classes: Single responsibility

If file exceeds limits, split into:
- Multiple smaller files
- Mixins for cross-cutting concerns
- Extension methods for utilities

