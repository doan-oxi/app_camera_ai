# 🏗️ VEEPAI SDK - KIẾN TRÚC TỔNG THỂ

> **Tài liệu này giải thích kiến trúc của Veepai SDK từ tầng cao nhất đến implementation chi tiết**

---

## 📊 High-Level Architecture Overview

### Sơ đồ tổng thể

```
┌─────────────────────────────────────────────────────────────────┐
│                      FLUTTER APPLICATION                         │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │   UI Layer     │  │  State Mgmt    │  │  Controllers   │   │
│  │   (Widgets)    │  │    (GetX)      │  │   (Logic)      │   │
│  └────────┬───────┘  └────────┬───────┘  └────────┬───────┘   │
│           └──────────────┬─────────────────────────┘            │
│                          ↓                                       │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              VSDK DART LAYER                             │  │
│  │  • CameraDevice                                          │  │
│  │  • AppPlayerController                                   │  │
│  │  • Commands (Mixins)                                     │  │
│  └──────────────────┬───────────────────────────────────────┘  │
│                     ↓                                            │
└─────────────────────┼────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │    MethodChannel/FFI      │
        │  (Flutter ↔ Native)       │
        └─────────────┼─────────────┘
                      │
┌─────────────────────┼────────────────────────────────────────────┐
│              NATIVE LAYER                                         │
│  ┌──────────────────┴──────────────────┐                        │
│  │         PLATFORM CHANNEL HANDLER     │                        │
│  │  Android: AppP2PApiPlugin.kt         │                        │
│  │  iOS: VsdkPlugin.m                   │                        │
│  └──────────────────┬──────────────────┘                        │
│                     ↓                                             │
│  ┌──────────────────────────────────────────────────────┐       │
│  │          NATIVE P2P LIBRARIES (Proprietary)          │       │
│  │  Android: libOKSMARTPLAY.so                          │       │
│  │  iOS: libVSTC.a                                      │       │
│  │                                                       │       │
│  │  Functions:                                          │       │
│  │  • P2P client creation                               │       │
│  │  • Connection management                             │       │
│  │  • Video decoding (H.264/H.265)                      │       │
│  │  • Audio encoding/decoding                           │       │
│  └──────────────────┬───────────────────────────────────┘       │
│                     ↓                                             │
└─────────────────────┼─────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │    NETWORK LAYER           │
        │  • TCP/UDP sockets        │
        │  • LAN/P2P/Relay          │
        └─────────────┼─────────────┘
                      │
                      ↓
┌─────────────────────────────────────────────────────────────────┐
│                      CAMERA DEVICE                               │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │
│  │   Sensor   │→ │  AI Chip   │→ │  Encoder   │→ │ Network  │ │
│  │   (Video)  │  │   (NPU)    │  │ H.264/265  │  │  Stack   │ │
│  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Module Structure

### 1. Flutter Dart Layer (`lib/`)

```
lib/
├── app_dart.dart              # FFI bindings & callbacks
├── app_p2p_api.dart          # P2P API wrapper
├── app_player.dart           # Video player controller
├── basis_device.dart         # Base device class
│
├── p2p_device/               # P2P Device Layer
│   ├── p2p_device.dart       # Base P2P device
│   ├── p2p_connect.dart      # Connection mixin
│   └── p2p_command.dart      # Command mixin
│
├── camera_device/            # Camera-specific Layer
│   ├── camera_device.dart    # Main camera class
│   └── commands/             # Modular command system
│       ├── ai_command.dart          # AI features
│       ├── alarm_command.dart       # Alarm config
│       ├── camera_command.dart      # General camera control
│       ├── card_command.dart        # TF card operations
│       ├── login_command.dart       # Authentication
│       ├── param_command.dart       # Parameters
│       ├── plan_command.dart        # Schedule plans
│       ├── record_command.dart      # Recording
│       ├── status_command.dart      # Device status
│       ├── video_command.dart       # Video settings
│       ├── voice_command.dart       # Audio control
│       └── wakeup_command.dart      # Low-power wakeup
│
└── device_wakeup_server.dart # Wakeup service
```

**Thiết kế Pattern:**
- **Mixin Pattern**: Chia commands thành các mixins độc lập
- **Composition over Inheritance**: Dễ mở rộng
- **Single Responsibility**: Mỗi file chỉ làm 1 việc

---

### 2. Native Android Layer (`android/`)

```
android/
├── build.gradle              # Gradle config
├── src/main/
│   ├── AndroidManifest.xml
│   └── java/
│       └── AppP2PApiPlugin.java    # Platform channel handler
│
├── vp_p2p/                   # P2P module
│   └── libs/
│       └── app_p2p_api-2.0.0.0.aar  # P2P library wrapper
│
├── vp_play/                  # Player module
│   └── libs/
│       └── app_player-4.0.0.aar     # Video player wrapper
│
└── vp_log/                   # Logging module
    └── libs/
        └── vp_log-2.0.0.0.aar       # Logging utility
```

**Native Libraries (Binary):**
- `libOKSMARTPLAY.so` - Core P2P & video processing
- Compiled for: armeabi-v7a, arm64-v8a, x86, x86_64

---

### 3. Native iOS Layer (`ios/`)

```
ios/
├── vsdk.podspec              # CocoaPods spec
├── Classes/
│   ├── VsdkPlugin.h          # Plugin header
│   ├── VsdkPlugin.m          # Plugin implementation
│   ├── AppP2PApiPlugin.h     # P2P API header
│   └── AppPlayerPlugin.h     # Player API header
│
└── SDK/
    └── libVSTC.a             # Static library (proprietary)
```

**Native Library:**
- `libVSTC.a` - Core P2P & video processing for iOS
- Architectures: arm64, x86_64 (simulator)

---

## 🔗 Communication Flow

### 1. Flutter ↔ Native Communication

```dart
// Flutter side (Dart)
class AppP2PApi {
  static const MethodChannel _channel = MethodChannel('app_p2p_api');
  static const EventChannel _eventChannel = EventChannel('app_p2p_api/event');
  
  // Call native method
  Future<int> clientCreate(String deviceId) async {
    return await _channel.invokeMethod('client_create', deviceId);
  }
  
  // Listen to native events
  _eventChannel.receiveBroadcastStream().listen((event) {
    // Handle connection state changes
  });
}
```

```kotlin
// Android side (Kotlin)
class AppP2PApiPlugin : FlutterPlugin, MethodCallHandler {
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "client_create" -> {
        val deviceId = call.arguments as String
        val clientPtr = nativeClientCreate(deviceId)  // Call .so
        result.success(clientPtr)
      }
    }
  }
  
  private external fun nativeClientCreate(deviceId: String): Long
}
```

### 2. Dart ↔ Native FFI (for performance-critical operations)

```dart
// Direct FFI binding
import 'dart:ffi';

final DynamicLibrary playerLib = Platform.isAndroid
    ? DynamicLibrary.open('libOKSMARTPLAY.so')
    : DynamicLibrary.process();

// Define C function signature
typedef AppPlayerSetScaleNative = Void Function(
  Int64 playerPtr, Double minScale, Double maxScale
);
typedef AppPlayerSetScale = void Function(
  int playerPtr, double minScale, double maxScale
);

// Lookup and bind
final appPlayerSetScale = playerLib
    .lookup<NativeFunction<AppPlayerSetScaleNative>>("app_player_set_scale")
    .asFunction<AppPlayerSetScale>();

// Call directly
appPlayerSetScale(playerId, 1.0, 5.0);
```

**Khi nào dùng gì?**
- **MethodChannel**: Commands, async operations, complex data
- **EventChannel**: Stream of events (connection state, video progress)
- **FFI**: Performance-critical (video scaling, real-time operations)

---

## 🎭 Design Patterns

### 1. Mixin Pattern (Command System)

```dart
// Base device
abstract class P2PBasisDevice extends BasisDevice {
  // Core P2P functionality
}

// Add connection capability
mixin P2PConnect on P2PBasisDevice {
  Future<ClientConnectState> p2pConnect() { ... }
  Future<bool> disconnect() { ... }
}

// Add command capability
mixin P2PCommand on P2PBasisDevice {
  Future<bool> writeCgi(String cgi) { ... }
  Future<CommandResult> waitCommandResult() { ... }
}

// Specialized camera device
class CameraDevice extends P2PBasisDevice
    with P2PConnect, P2PCommand, StatusCommand, 
         VideoCommand, AICommand, AlarmCommand {
  // Kết hợp tất cả capabilities
}
```

**Lợi ích:**
- ✅ Modular: Dễ thêm/bớt features
- ✅ Reusable: Mixins có thể dùng cho device khác
- ✅ Testable: Test từng mixin độc lập
- ✅ Readable: Code organization rõ ràng

### 2. State Management (GetX)

```dart
// State class
class DeviceBindState {
  final deviceName = Rx<String>('');
  final isLoading = RxBool(false);
  final connectState = Rx<CameraConnectState>(CameraConnectState.none);
}

// Logic class
class DeviceBindLogic extends GetXController {
  final state = DeviceBindState();
  
  Future<void> connectDevice(String deviceId) async {
    state.isLoading.value = true;
    // ... connection logic
    state.connectState.value = CameraConnectState.connected;
    state.isLoading.value = false;
  }
}

// UI binding
class DeviceBindPage extends GetView<DeviceBindLogic> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.state.isLoading.value) {
        return CircularProgressIndicator();
      }
      return Text(controller.state.deviceName.value);
    });
  }
}
```

### 3. Observer Pattern (Event Listeners)

```dart
class CameraDevice {
  StreamController<CameraEvent> _controller = StreamController.broadcast();
  
  void addListener<T>(void Function(CameraDevice, T) callback) {
    // Subscribe to specific event type
  }
  
  void notifyListeners<T>(void Function(T) callback) {
    // Notify all listeners of type T
  }
  
  // Usage
  device.addListener<CameraConnectChanged>((device, state) {
    print("Connection state: $state");
  });
  
  device.addListener<StatusChanged>((device, status) {
    print("Battery: ${status.batteryRate}%");
  });
}
```

### 4. Factory Pattern (Video Sources)

```dart
abstract class VideoSource {
  final VideoSourceType sourceType;
  VideoSource(this.sourceType);
  dynamic getSource();
}

class LiveVideoSource extends VideoSource {
  final int clientPtr;
  LiveVideoSource(this.clientPtr) : super(VideoSourceType.LIVE_SOURCE);
  
  @override
  getSource() => clientPtr;
}

class NetworkVideoSource extends VideoSource {
  final List<String> urls;
  NetworkVideoSource(this.urls) : super(VideoSourceType.NETWORK_SOURCE);
  
  @override
  getSource() => urls;
}

// Usage
VideoSource source = LiveVideoSource(clientPtr);  // or
VideoSource source = NetworkVideoSource(urls);

// Polymorphic handling
await playerController.setVideoSource(source);
```

---

## 🔄 Connection State Machine

```
┌─────────────────────────────────────────────────────────────┐
│              CameraDevice Connection States                  │
└─────────────────────────────────────────────────────────────┘

    [none] ────────────────┐
                           ↓
                    [connecting] ──────→ [timeout] ───→ [none]
                           │                  ↑
                           ↓                  │
                     [logging] ───────────────┤
                           │                  │
                           ↓                  │
                    [connected] ◄─────────────┘
                           │
                           ↓
              ┌────────────┴────────────┐
              ↓                         ↓
        [password error]          [maxUser]
              │                         │
              └─────────┬───────────────┘
                        ↓
                   [disconnect]
                        │
                        ↓
                    [offline]
```

**States:**
- `none`: Initial state
- `connecting`: Establishing P2P connection
- `logging`: Authenticating with camera
- `connected`: Ready for use
- `timeout`: Connection timed out
- `password`: Wrong password
- `maxUser`: Too many users connected
- `disconnect`: Connection lost
- `offline`: Camera is offline

---

## 🧩 Key Components Deep Dive

### 1. P2PBasisDevice

**Trách nhiệm:**
- Quản lý P2P client lifecycle
- Resolve virtual ID → real device ID
- Get service parameters cho authentication
- Handle listeners & events

**Key Methods:**
```dart
class P2PBasisDevice extends BasisDevice {
  // Virtual ID → Real ID resolution
  Future<String> getClientId() async {
    if (isVirtualId) {
      // Query https://vuid.eye4.cn
      return await _requestClientId();
    }
    return id;
  }
  
  // Create native P2P client
  Future<int> getClientPtr() async {
    String clientId = await getClientId();
    _clientPtr = await AppP2PApi().clientCreate(clientId);
    return _clientPtr;
  }
  
  // Get authentication parameters
  Future<String?> getServiceParam() async {
    // Check local cache first
    // Then query https://authentication.eye4.cn
  }
}
```

### 2. P2PConnect Mixin

**Trách nhiệm:**
- Thực hiện P2P connection
- Handle connection states
- Retry logic
- Disconnect

**Key Methods:**
```dart
mixin P2PConnect on P2PBasisDevice {
  Future<ClientConnectState> p2pConnect({
    bool lanScan = true,
    int reConnectCount = 2,
    required int connectType
  }) async {
    // 1. Check if already connecting
    // 2. Get client pointer & service params
    // 3. Try connection with retry
    // 4. Setup listeners
    // 5. Return connection state
  }
  
  Future<bool> disconnect() async {
    // Graceful disconnect with cleanup
  }
}
```

### 3. P2PCommand Mixin

**Trách nhiệm:**
- Send CGI commands to camera
- Wait for responses
- Parse results

**Key Methods:**
```dart
mixin P2PCommand on P2PBasisDevice {
  Future<bool> writeCgi(String cgi, {int timeout = 5}) async {
    int clientPtr = await getClientPtr();
    return await AppP2PApi().clientWrite(clientPtr, cgi, timeout);
  }
  
  Future<CommandResult> waitCommandResult(
    bool Function(int cmd, Uint8List data) filter,
    int timeout
  ) async {
    // Wait for specific response from camera
  }
}
```

### 4. CameraDevice (Main Class)

**Trách nhiệm:**
- Orchestrate connection flow
- Manage device lifecycle
- Coordinate all mixins
- Handle app lifecycle (background/foreground)

**Key Methods:**
```dart
class CameraDevice extends P2PBasisDevice
    with P2PConnect, P2PCommand, StatusCommand,
         VideoCommand, AICommand, AlarmCommand, ... {
  
  Future<CameraConnectState> connect({
    bool lanScan = true,
    int connectCount = 3
  }) async {
    // 1. Check connect type (LAN/P2P/Relay)
    // 2. Check if device offline
    // 3. Establish P2P connection (with retry)
    // 4. Login authentication
    // 5. Validate response
    // 6. Setup keep-alive
    // 7. Get device status
    return CameraConnectState.connected;
  }
}
```

### 5. AppPlayerController

**Trách nhiệm:**
- Control video playback
- Manage video sources
- Handle video callbacks
- Audio & recording control

**Key Methods:**
```dart
class AppPlayerController<T> {
  Future<bool> create({int audioRate = 8000}) async {
    // Create native player instance
  }
  
  Future<bool> setVideoSource(VideoSource source) async {
    // Set video source (live/card/network/file)
  }
  
  Future<bool> start() async {
    // Start playback
  }
  
  Future<bool> stop() async {
    // Stop playback
  }
  
  // Callbacks
  ProgressChangeCallback? progressCallback;
  StateChangeCallback? stateChangeCallback;
  FocalChangeCallback? focalCallback;
  GPSChangeCallback? gpsCallback;
}
```

---

## 📊 Data Flow Examples

### Example 1: Live Streaming

```
User Action: Tap "Watch Live"
        ↓
┌───────────────────────────────────────────────────────┐
│ 1. Create CameraDevice                                │
│    device = CameraDevice(deviceId, ...)               │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 2. Connect to camera                                  │
│    state = await device.connect()                     │
│    ├─→ getClientId() → vuid.eye4.cn                  │
│    ├─→ getServiceParam() → authentication.eye4.cn    │
│    ├─→ p2pConnect() → Native P2P                     │
│    └─→ login() → CGI command                         │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 3. Create player                                      │
│    player = AppPlayerController()                     │
│    await player.create()                              │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 4. Set video source                                   │
│    source = LiveVideoSource(clientPtr)                │
│    await player.setVideoSource(source)                │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 5. Start stream                                       │
│    await device.startStream(resolution: high)         │
│    → CGI: livestream.cgi?streamid=10&substream=1&    │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 6. Start playback                                     │
│    await player.start()                               │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 7. Video streaming                                    │
│    Camera → H.264 packets → P2P → Native Decoder     │
│    → Texture → Flutter Widget → Screen               │
└───────────────────────────────────────────────────────┘
```

### Example 2: PTZ Control

```
User Action: Tap "Up" button
        ↓
┌───────────────────────────────────────────────────────┐
│ 1. Call PTZ command                                   │
│    await device.motorCommand.up()                     │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 2. Send CGI command                                   │
│    writeCgi("decoder_control.cgi?command=0&")        │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 3. Native layer sends via P2P                         │
│    AppP2PApi().clientWrite(clientPtr, cgi)           │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 4. Camera receives & executes                         │
│    Motor moves camera upward                          │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 5. Camera sends response                              │
│    Result code via P2P                                │
└───────────────────┬───────────────────────────────────┘
                    ↓
┌───────────────────────────────────────────────────────┐
│ 6. App receives confirmation                          │
│    waitCommandResult() completes                      │
└───────────────────────────────────────────────────────┘
```

---

## 🔒 Security Architecture

### Authentication Flow

```
1. P2P Connection Authentication:
   ├─→ Client creates connection with service param
   ├─→ Service param contains encrypted credentials
   └─→ Native library handles encryption/decryption

2. Camera Login:
   ├─→ Send: login.cgi?user=admin&password=888888
   ├─→ Camera validates credentials
   ├─→ Returns session info + capabilities
   └─→ Keep-alive heartbeat maintains session

3. Dual Authentication (optional):
   ├─→ Camera sends verification request
   ├─→ App shows confirmation dialog
   ├─→ User confirms
   └─→ Connection established
```

### Data Encryption

```
┌──────────────────────────────────────────────────────┐
│ Video Stream: AES-128 encryption (optional)          │
│ CGI Commands: Encrypted in service param             │
│ API Calls: HTTPS (TLS 1.2+)                         │
│ Cloud Storage: Server-side encryption                │
└──────────────────────────────────────────────────────┘
```

---

## 📈 Performance Characteristics

### Latency

```
┌─────────────────────────────────────────────────────┐
│ Connection Type │ Typical Latency │ Use Case        │
├─────────────────────────────────────────────────────┤
│ LAN             │ 50-150ms       │ Same network    │
│ P2P Direct      │ 150-300ms      │ Different ISPs  │
│ Relay Server    │ 300-800ms      │ Fallback        │
│ Cloud Playback  │ 1000-3000ms    │ Historical      │
└─────────────────────────────────────────────────────┘
```

### Memory Usage

```
┌────────────────────────────────────────────────┐
│ Component        │ Memory (approx)            │
├────────────────────────────────────────────────┤
│ P2P Client       │ ~10 MB                     │
│ Video Decoder    │ ~20-50 MB (depends on res)│
│ Video Buffers    │ ~5-10 MB                   │
│ Dart Overhead    │ ~5 MB                      │
│ Total            │ ~40-75 MB per stream       │
└────────────────────────────────────────────────┘
```

### CPU Usage

```
• Video Decoding: Hardware accelerated (MediaCodec/VideoToolbox)
• CPU: ~10-20% for 1080p stream on modern devices
• Battery: ~5-10% per hour of live streaming
```

---

## 🎯 Summary

### Điểm Mạnh của Kiến Trúc

```
✅ Modular: Mixin pattern cho phép dễ dàng thêm features
✅ Performant: Hardware decoding, P2P direct connection
✅ Scalable: Hỗ trợ nhiều camera, multi-sensor
✅ Flexible: Nhiều video sources, nhiều connect types
✅ Maintainable: Code organization rõ ràng
```

### Điểm Cần Cải Thiện

```
⚠️ Large classes: CameraCommand có quá nhiều trách nhiệm
⚠️ Hardcoded data: Service params, server URLs
⚠️ Testing: Thiếu unit tests, integration tests
⚠️ Documentation: Comments chủ yếu là Chinese
⚠️ Error handling: Chưa đầy đủ, chưa standardized
```

### Khuyến Nghị Refactoring

```
1. Extract hardcoded configs → Config class
2. Break down CameraCommand → Smaller command classes
3. Add comprehensive error handling
4. Write unit tests cho critical paths
5. Add English documentation
6. Implement retry strategies
7. Add telemetry/analytics hooks
```

---

## 📚 Next Steps

Sau khi hiểu kiến trúc, đọc tiếp:
- **[02-CONNECTION-FLOW.md](./02-CONNECTION-FLOW.md)** - Chi tiết connection flow
- **[03-VIDEO-STREAMING.md](./03-VIDEO-STREAMING.md)** - Video streaming internals

---

*Updated: 2024 | Version: 1.0*

