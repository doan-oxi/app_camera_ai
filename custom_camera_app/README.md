# Custom Camera App

> A production-ready Flutter camera application integrating Veepai SDK with AI-powered features.

## 🎯 Project Overview

This is a custom Flutter application that leverages the **Veepai SDK** to provide:
- **Real-time video streaming** from multiple cameras
- **Advanced AI detection** (human, vehicle, custom objects)
- **Smart alarm management** with ML-powered filtering
- **PTZ control** with preset positions and tours
- **Offline-first architecture** with seamless cloud sync

## 🏗️ Architecture

This project strictly follows **Clean Architecture** principles with clear layer separation:

```
Presentation → Domain ← Data ← Infrastructure
```

### Layers:
1. **Presentation**: UI, Widgets, State Management (Riverpod/GetX)
2. **Domain**: Entities, Use Cases, Repository Interfaces
3. **Data**: Repository Implementations, Data Sources, Models
4. **Infrastructure**: SDK Integration, Platform Services, External APIs

## 📁 Project Structure

```
lib/
├── core/                   # Core utilities
├── domain/                 # Business logic (pure Dart)
├── data/                   # Data layer
├── infrastructure/         # External integrations
└── presentation/           # UI layer
```

For detailed structure, see [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md#folder-structure)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode
- Veepai SDK (included)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/doan-oxi/app_camera_ai.git
cd custom_camera_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📚 Documentation

- **Implementation Plan**: [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md)
- **Cursor Rules**: [.cursorrules](../.cursorrules)
- **SDK Documentation**: [/DOCUMENTATION/](../DOCUMENTATION/)
- **API Reference**: [/DOCUMENTATION/13-API-REFERENCE.md](../DOCUMENTATION/13-API-REFERENCE.md)

## 🎯 Development Guidelines

### Code Quality Standards
- Follow **SOLID** principles
- Apply **KISS** (Keep It Simple, Stupid)
- Use **meaningful names** (no v1, enhanced, etc.)
- Keep files **< 300 lines**
- Keep functions **< 50 lines**
- **Test coverage > 80%**

### Performance Guidelines
- Use **RxDart** for reactive streams
- Use **Isolates** for heavy operations
- Optimize widget rebuilds
- Implement proper resource cleanup

See [.cursorrules](../.cursorrules) for comprehensive guidelines.

## 🔧 Tech Stack

### Flutter/Dart
- **State Management**: Riverpod / GetX
- **Dependency Injection**: GetIt
- **Reactive Programming**: RxDart
- **Network**: Dio
- **Local Storage**: Hive
- **AI/ML**: TensorFlow Lite

### Native
- **Android**: Kotlin, Coroutines
- **iOS**: Swift, Async/Await

## 📦 Dependencies

See [pubspec.yaml](pubspec.yaml) for full dependency list.

Key dependencies:
- `flutter_riverpod` - State management
- `rxdart` - Reactive programming
- `dio` - HTTP client
- `hive` - Local database
- `tflite_flutter` - TensorFlow Lite

## 🎯 Features

### Core Features
- ✅ Camera connection & management
- ✅ Live video streaming (30 FPS, < 100ms latency)
- ✅ PTZ control with presets
- ✅ Multi-camera dashboard

### Alarm Features
- ✅ Alarm configuration
- ✅ Detection zones
- ✅ Alarm history
- ✅ Smart notifications

### AI Features
- ✅ Real-time object detection
- ✅ Multi-object tracking
- ✅ Smart notification filtering
- ✅ Custom AI models

## 🚀 Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📊 Performance Metrics

### Target KPIs
- **Video Latency**: < 100ms
- **Frame Rate**: 30 FPS
- **App Launch**: < 2 seconds
- **Camera Connection**: < 3 seconds
- **AI Detection**: < 200ms per frame

## 🤝 Contributing

1. Follow the coding standards in [.cursorrules](../.cursorrules)
2. Write tests for new features
3. Update documentation
4. Submit pull request

## 📄 License

See [LICENSE](../LICENSE) file for details.

## 🙏 Acknowledgments

- **Veepai SDK** for camera integration
- **Flutter Team** for the amazing framework
- **Clean Architecture** principles by Robert C. Martin

---

**For detailed implementation guide, see [IMPLEMENTATION_PLAN.md](../IMPLEMENTATION_PLAN.md)**

