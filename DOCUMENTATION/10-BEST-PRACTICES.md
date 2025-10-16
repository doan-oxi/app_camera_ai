# ⭐ VEEPAI SDK - BEST PRACTICES

> **Complete guide to building production-ready camera apps**  
> Architecture, Performance, Security, Testing, and More

---

## 🎯 Overview

This guide consolidates best practices learned from analyzing the Veepai SDK codebase and building production camera applications. Follow these guidelines to create maintainable, performant, and secure applications.

### Who Should Read This?

```
✅ Flutter developers integrating Veepai SDK
✅ Team leads architecting camera apps
✅ Code reviewers ensuring quality
✅ DevOps engineers deploying apps
✅ Anyone building on this SDK
```

---

## 📐 Architecture Best Practices

### 1. Use Mixins for Shared Functionality

**Why:** The SDK uses mixins effectively to compose device commands.

```dart
// ✅ GOOD: Modular, reusable functionality
mixin AlarmCommand on P2PCommand {
  Future<bool> getAlarmParam({int timeout = 5}) async {
    // Alarm-specific logic
  }
}

mixin AICommand on CameraCommand {
  Future<bool> getHumanTracking() async {
    // AI-specific logic
  }
}

class CameraDevice extends P2PBasisDevice
    with AlarmCommand, AICommand, MotorCommand {
  // Composed functionality
}

// ❌ BAD: Monolithic inheritance
class CameraDevice extends BaseDevice {
  // 3000+ lines of mixed functionality
  Future<bool> getAlarmParam() { }
  Future<bool> getHumanTracking() { }
  Future<bool> motorLeft() { }
  // ... everything in one class
}
```

**When to Use:**
- ✅ Shared behavior across multiple classes
- ✅ Optional features (not all cameras have AI)
- ✅ Horizontal composition (multiple concerns)

**When NOT to Use:**
- ❌ Core functionality (use inheritance)
- ❌ State that needs to be shared
- ❌ Complex initialization logic

### 2. Separate Concerns with Proper Layering

**Layer Structure:**

```
┌─────────────────────────────────────────────┐
│           UI Layer (Pages/Widgets)          │
│  • No business logic                        │
│  • Pure presentation                        │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│        Business Logic (Controllers)         │
│  • State management (GetX)                  │
│  • Use case orchestration                   │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│         SDK Layer (Device/Commands)         │
│  • Device communication                     │
│  • Command execution                        │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│       Platform Layer (P2P/Native)           │
│  • FFI calls                                │
│  • Platform channels                        │
└─────────────────────────────────────────────┘
```

**Example Implementation:**

```dart
// ✅ GOOD: Clear separation

// 1. UI Layer
class CameraPlayPage extends StatelessWidget {
  final CameraController controller = Get.find();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isConnecting.value) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (controller.hasError.value) {
        return ErrorWidget(controller.errorMessage.value);
      }
      
      return VideoPlayerWidget(
        controller: controller.playerController,
      );
    });
  }
}

// 2. Business Logic Layer
class CameraController extends GetxController {
  final CameraRepository _repository;
  
  final isConnecting = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  
  CameraController(this._repository);
  
  Future<void> connect(String deviceId) async {
    try {
      isConnecting.value = true;
      hasError.value = false;
      
      await _repository.connect(deviceId);
      
      // Start video
      await _repository.startLiveVideo();
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isConnecting.value = false;
    }
  }
}

// 3. SDK Layer
class CameraRepository {
  final CameraDevice _device;
  
  Future<void> connect(String deviceId) async {
    await _device.connect();
  }
  
  Future<void> startLiveVideo() async {
    await _device.startVideo(VideoSourceType.live);
  }
}

// ❌ BAD: Everything mixed in UI
class CameraPlayPage extends StatefulWidget {
  @override
  _CameraPlayPageState createState() => _CameraPlayPageState();
}

class _CameraPlayPageState extends State<CameraPlayPage> {
  CameraDevice? device;
  bool isConnecting = false;
  
  @override
  void initState() {
    super.initState();
    // Business logic in UI
    _connectAndPlay();
  }
  
  Future<void> _connectAndPlay() async {
    setState(() => isConnecting = true);
    
    // Direct SDK calls in UI
    device = CameraDevice(deviceId: widget.deviceId);
    await device!.connect();
    await device!.startVideo(VideoSourceType.live);
    
    setState(() => isConnecting = false);
  }
  
  @override
  Widget build(BuildContext context) {
    // Complex build logic with business logic
    return isConnecting
        ? CircularProgressIndicator()
        : VideoPlayer();
  }
}
```

### 3. Implement Repository Pattern

**Why:** Abstracts data sources, makes testing easier, allows swapping implementations.

```dart
// ✅ GOOD: Repository pattern

abstract class CameraRepository {
  Future<CameraDevice> getDevice(String id);
  Future<List<CameraDevice>> getAllDevices();
  Future<void> saveDevice(CameraDevice device);
  Future<void> deleteDevice(String id);
}

// Implementation 1: Local storage
class LocalCameraRepository implements CameraRepository {
  final SharedPreferences _prefs;
  
  @override
  Future<CameraDevice> getDevice(String id) async {
    String? json = _prefs.getString('device_$id');
    if (json == null) throw DeviceNotFoundException();
    return CameraDevice.fromJson(jsonDecode(json));
  }
  
  @override
  Future<List<CameraDevice>> getAllDevices() async {
    // Load from SharedPreferences
  }
}

// Implementation 2: Remote API (future)
class CloudCameraRepository implements CameraRepository {
  final ApiClient _client;
  
  @override
  Future<CameraDevice> getDevice(String id) async {
    final response = await _client.get('/devices/$id');
    return CameraDevice.fromJson(response.data);
  }
}

// Usage in controller
class DeviceListController extends GetxController {
  final CameraRepository repository;
  
  DeviceListController(this.repository);  // Dependency injection
  
  Future<void> loadDevices() async {
    devices.value = await repository.getAllDevices();
  }
}

// Easy to swap implementations
void main() {
  // Production
  Get.put(LocalCameraRepository(Get.find<SharedPreferences>()));
  
  // Or cloud
  // Get.put(CloudCameraRepository(Get.find<ApiClient>()));
}
```

---

## 💎 Code Quality

### 1. Fix Mixed Language Naming

**Current Issue:** Code mixes Chinese and English names.

```dart
// ❌ BAD: Mixed languages
class QiangQiuCommand {
  Future<bool> qiangqiuPTZReset() { }
  Future<bool> qiangqiuPTZCheck() { }
}

// ✅ GOOD: Consistent English
class DomeCommand {
  Future<bool> resetPTZ() { }
  Future<bool> checkPTZStatus() { }
}

// ❌ BAD: Chinese comments only
/// 云台指令
class MotorCommand { }

// ✅ GOOD: English or bilingual
/// PTZ (Pan-Tilt-Zoom) Motor Commands
/// 云台指令
class MotorCommand { }
```

### 2. Break Down God Classes

**Problem:** `CameraDevice` has 3000+ lines.

**Solution:** Split into focused classes.

```dart
// ❌ BAD: One massive class
class CameraDevice extends P2PBasisDevice
    with AlarmCommand, AICommand, MotorCommand, WifiCommand, 
         LedCommand, SirenCommand, PowerCommand, DVRCommand {
  // 3000+ lines
  // Connection logic
  // Video playback
  // Configuration
  // State management
  // Error handling
  // Everything!
}

// ✅ GOOD: Focused responsibilities

// 1. Core device
class CameraDevice extends P2PBasisDevice {
  final ConnectionManager connectionManager;
  final VideoPlayer videoPlayer;
  final CommandExecutor commandExecutor;
  
  CameraDevice({
    required this.connectionManager,
    required this.videoPlayer,
    required this.commandExecutor,
  });
}

// 2. Connection management
class ConnectionManager {
  Future<ConnectionState> connect() async { }
  Future<void> disconnect() async { }
  Stream<ConnectionState> get stateStream => _stateController.stream;
}

// 3. Video playback
class VideoPlayer {
  Future<void> startLive() async { }
  Future<void> startPlayback(DateTime time) async { }
  Future<void> stop() async { }
}

// 4. Command execution
class CommandExecutor {
  Future<bool> execute(Command cmd) async { }
  Future<T> executeWithResult<T>(Command cmd) async { }
}
```

### 3. Extract Configuration

**Problem:** Hardcoded values scattered in code.

```dart
// ❌ BAD: Hardcoded everywhere
class P2PDevice {
  Future<void> resolveVID() async {
    final url = "https://vuid.eye4.cn/vuid/query";  // Hardcoded
    final response = await http.post(url, body: data);
  }
  
  Future<void> getServiceParams() async {
    final url = "https://authentication.eye4.cn/api/client/device/query";
    // Another hardcoded URL
  }
}

// ✅ GOOD: Centralized configuration
class VeepaiConfig {
  // URLs
  static const String vidResolveUrl = "https://vuid.eye4.cn/vuid/query";
  static const String serviceParamUrl = "https://authentication.eye4.cn/api/client/device/query";
  
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 5);
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  // Video
  static const int defaultVideoDuration = 15;
  static const int maxVideoDuration = 60;
  
  // Retry
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Battery
  static const int lowBatteryThreshold = 20;
  static const int criticalBatteryThreshold = 10;
}

// Usage
class P2PDevice {
  Future<void> resolveVID() async {
    final response = await http.post(
      VeepaiConfig.vidResolveUrl,
      body: data,
    ).timeout(VeepaiConfig.defaultTimeout);
  }
}

// Even better: Environment-specific config
class VeepaiConfig {
  static VeepaiConfig get instance {
    if (kDebugMode) {
      return VeepaiConfig.debug();
    } else {
      return VeepaiConfig.production();
    }
  }
  
  final String vidResolveUrl;
  final String serviceParamUrl;
  final bool enableLogging;
  
  VeepaiConfig.debug()
      : vidResolveUrl = "https://dev-vuid.eye4.cn/vuid/query",
        serviceParamUrl = "https://dev-auth.eye4.cn/api/client/device/query",
        enableLogging = true;
  
  VeepaiConfig.production()
      : vidResolveUrl = "https://vuid.eye4.cn/vuid/query",
        serviceParamUrl = "https://authentication.eye4.cn/api/client/device/query",
        enableLogging = false;
}
```

### 4. Use Proper Null Safety

```dart
// ❌ BAD: Null checks everywhere
class CameraDevice {
  String? deviceId;
  String? password;
  
  Future<void> connect() async {
    if (deviceId == null) throw Exception("No device ID");
    if (password == null) throw Exception("No password");
    
    // ... more null checks
  }
}

// ✅ GOOD: Non-nullable with validation
class CameraDevice {
  final String deviceId;
  final String password;
  
  CameraDevice({
    required this.deviceId,
    required this.password,
  }) {
    if (deviceId.isEmpty) {
      throw ArgumentError("Device ID cannot be empty");
    }
    if (password.isEmpty) {
      throw ArgumentError("Password cannot be empty");
    }
  }
  
  Future<void> connect() async {
    // No null checks needed - guaranteed to have values
  }
}

// Optional values: Use late or nullable with clear semantics
class CameraDevice {
  final String deviceId;
  final String password;
  
  // Optional - may not be set yet
  String? nickname;
  
  // Lazy initialized - will be set before use
  late final ConnectionManager _connectionManager;
  
  Future<void> initialize() async {
    _connectionManager = ConnectionManager(this);
  }
}
```

### 5. Document Public APIs

```dart
// ❌ BAD: No documentation
class CameraDevice {
  Future<bool> setPriDetection(int detection) async {
    bool ret = await writeCgi(
        "trans_cmd_string.cgi?cmd=2106&command=4&humanDetection=$detection&&mark=123456789&");
    // ...
  }
}

// ✅ GOOD: Clear documentation
class CameraDevice {
  /// Sets the PIR (Passive Infrared) detection sensitivity level.
  /// 
  /// PIR sensors detect infrared radiation (body heat) from moving objects.
  /// 
  /// **Parameters:**
  /// - [detection]: Sensitivity level
  ///   - `0`: Off (no PIR detection)
  ///   - `1`: Low (1-3m range, fewer false alarms)
  ///   - `2`: Medium (3-5m range, recommended)
  ///   - `3`: High (5-8m range, more false alarms)
  /// 
  /// **Returns:** `true` if setting was successfully applied, `false` otherwise.
  /// 
  /// **Throws:**
  /// - [TimeoutException] if camera doesn't respond within timeout
  /// - [SocketException] if network connection fails
  /// 
  /// **Example:**
  /// ```dart
  /// // Set medium sensitivity
  /// bool success = await device.setPriDetection(2);
  /// if (success) {
  ///   print("PIR sensitivity updated");
  /// }
  /// ```
  /// 
  /// **See also:**
  /// - [getPirDetection] to retrieve current setting
  /// - [setDetectionRange] to adjust detection distance
  Future<bool> setPriDetection(int detection) async {
    if (detection < 0 || detection > 3) {
      throw ArgumentError('Detection level must be 0-3');
    }
    
    bool ret = await writeCgi(
        "trans_cmd_string.cgi?cmd=2106&command=4&humanDetection=$detection&");
    // ...
  }
}
```

---

## 🛡️ Error Handling

### 1. Use Typed Exceptions

```dart
// ❌ BAD: Generic exceptions
Future<void> connectDevice() async {
  if (deviceId.isEmpty) {
    throw Exception("Invalid device ID");
  }
  
  if (networkFailed) {
    throw Exception("Network error");
  }
}

// ✅ GOOD: Typed exceptions
class DeviceException implements Exception {
  final String message;
  DeviceException(this.message);
  
  @override
  String toString() => 'DeviceException: $message';
}

class InvalidDeviceIdException extends DeviceException {
  InvalidDeviceIdException(String deviceId)
      : super('Invalid device ID: $deviceId');
}

class NetworkException extends DeviceException {
  final int? statusCode;
  
  NetworkException(String message, {this.statusCode})
      : super(message);
}

class TimeoutException extends DeviceException {
  final Duration timeout;
  
  TimeoutException(this.timeout)
      : super('Operation timed out after ${timeout.inSeconds}s');
}

// Usage
Future<void> connectDevice() async {
  if (deviceId.isEmpty) {
    throw InvalidDeviceIdException(deviceId);
  }
  
  try {
    await _performConnection().timeout(Duration(seconds: 30));
  } on SocketException catch (e) {
    throw NetworkException('Connection failed: ${e.message}');
  } on TimeoutError {
    throw TimeoutException(Duration(seconds: 30));
  }
}

// Handling
try {
  await device.connectDevice();
} on InvalidDeviceIdException catch (e) {
  showError("Please enter a valid device ID");
} on NetworkException catch (e) {
  showError("Network error. Please check your connection.");
} on TimeoutException catch (e) {
  showError("Connection timed out. Please try again.");
} on DeviceException catch (e) {
  showError("Device error: ${e.message}");
}
```

### 2. Implement Retry Logic

```dart
// ✅ GOOD: Generic retry utility
class RetryHelper {
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 2),
    bool Function(dynamic error)? retryIf,
  }) async {
    int attempts = 0;
    
    while (true) {
      attempts++;
      
      try {
        return await operation();
      } catch (e) {
        // Check if should retry
        bool shouldRetry = retryIf?.call(e) ?? true;
        
        if (attempts >= maxAttempts || !shouldRetry) {
          rethrow;
        }
        
        print('Attempt $attempts failed, retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }
    }
  }
}

// Usage
Future<void> connectWithRetry() async {
  try {
    await RetryHelper.retry(
      () => device.connect(),
      maxAttempts: 3,
      delay: Duration(seconds: 2),
      retryIf: (error) {
        // Only retry on network errors, not on invalid credentials
        return error is NetworkException || error is TimeoutException;
      },
    );
  } catch (e) {
    print('Failed after 3 attempts: $e');
  }
}
```

### 3. Graceful Degradation

```dart
// ✅ GOOD: Feature detection with fallback
class CameraFeatures {
  final CameraDevice device;
  
  // Cache feature support
  bool? _supportsAI;
  bool? _supportsPTZ;
  
  CameraFeatures(this.device);
  
  Future<bool> supportsAI() async {
    if (_supportsAI != null) return _supportsAI!;
    
    try {
      final status = await device.getStatus();
      _supportsAI = status.support_humanDetect == '1';
      return _supportsAI!;
    } catch (e) {
      print('Error checking AI support: $e');
      _supportsAI = false;  // Assume not supported on error
      return false;
    }
  }
  
  Future<bool> supportsPTZ() async {
    if (_supportsPTZ != null) return _supportsPTZ!;
    
    try {
      _supportsPTZ = device.motorCommand != null;
      return _supportsPTZ!;
    } catch (e) {
      _supportsPTZ = false;
      return false;
    }
  }
}

// Usage in UI
class CameraControlsPage extends StatelessWidget {
  final CameraDevice device;
  final CameraFeatures features;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _loadFeatures(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        
        final hasAI = snapshot.data!['ai'] ?? false;
        final hasPTZ = snapshot.data!['ptz'] ?? false;
        
        return Column(
          children: [
            // Always available
            BasicControlsWidget(device: device),
            
            // Optional features
            if (hasAI)
              AIControlsWidget(device: device)
            else
              Text("AI features not available"),
              
            if (hasPTZ)
              PTZControlsWidget(device: device)
            else
              Text("PTZ not supported"),
          ],
        );
      },
    );
  }
  
  Future<Map<String, bool>> _loadFeatures() async {
    return {
      'ai': await features.supportsAI(),
      'ptz': await features.supportsPTZ(),
    };
  }
}
```

---

## ⚡ Performance Optimization

### 1. Battery Optimization

**Critical for wireless cameras!**

```dart
// ✅ GOOD: Battery-aware configuration
class BatteryOptimizer {
  static Future<void> optimizeForBattery(CameraDevice device) async {
    // 1. Use PIR instead of continuous video
    await device.setPriDetection(2);  // Medium sensitivity
    
    // 2. Disable video recording (only push notifications)
    await device.setPriPush(
      pushEnable: true,
      videoEnable: false,  // Save battery
    );
    
    // 3. Reduce video quality for recordings
    // (if video is needed)
    await device.setRecordResolution(1);  // 720p instead of 1080p
    
    // 4. Increase detection cooldown
    // (configure via alarm plan - not all day)
    
    print('✅ Battery optimization applied');
  }
  
  static Future<void> optimizeForPerformance(CameraDevice device) async {
    // Full quality, continuous detection
    await device.setPriDetection(3);  // High sensitivity
    await device.setPriPush(
      pushEnable: true,
      videoEnable: true,
      videoDuration: 30,  // Longer recordings
    );
    
    print('✅ Performance mode applied');
  }
}

// Usage
class DeviceSettingsController extends GetxController {
  Future<void> setBatteryMode(bool batteryMode) async {
    if (batteryMode) {
      await BatteryOptimizer.optimizeForBattery(device);
      showSuccess("Battery mode enabled");
    } else {
      await BatteryOptimizer.optimizeForPerformance(device);
      showSuccess("Performance mode enabled");
    }
  }
}
```

### 2. Memory Management for Video

```dart
// ✅ GOOD: Proper resource cleanup
class VideoPlayerManager {
  AppPlayerController? _playerController;
  Timer? _keepAliveTimer;
  
  Future<void> startVideo(CameraDevice device) async {
    // Stop existing playback
    await stopVideo();
    
    // Create new controller
    _playerController = AppPlayerController(
      device: device,
      sourceType: VideoSourceType.live,
    );
    
    // Start playback
    await _playerController!.play();
    
    // Keep-alive heartbeat
    _keepAliveTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _sendKeepAlive();
    });
  }
  
  Future<void> stopVideo() async {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    
    if (_playerController != null) {
      await _playerController!.stop();
      _playerController!.dispose();  // Important!
      _playerController = null;
    }
  }
  
  @override
  void onClose() {
    stopVideo();  // Cleanup on controller dispose
    super.onClose();
  }
}

// Usage
class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with WidgetsBindingObserver {
  late VideoPlayerManager _manager;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _manager = VideoPlayerManager();
    _manager.startVideo(widget.device);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop video when app goes to background
    if (state == AppLifecycleState.paused) {
      _manager.stopVideo();
    } else if (state == AppLifecycleState.resumed) {
      _manager.startVideo(widget.device);
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manager.stopVideo();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return VideoWidget(controller: _manager.controller);
  }
}
```

### 3. Network Efficiency

```dart
// ✅ GOOD: Cache responses
class CachedDeviceRepository {
  final CameraDevice device;
  final Map<String, CachedValue> _cache = {};
  
  Future<StatusResult> getStatus({
    bool forceRefresh = false,
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    const cacheKey = 'status';
    
    // Check cache
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (!cached.isExpired) {
        return cached.value as StatusResult;
      }
    }
    
    // Fetch fresh data
    final status = await device.getStatus();
    
    // Update cache
    _cache[cacheKey] = CachedValue(
      value: status,
      expiresAt: DateTime.now().add(cacheDuration),
    );
    
    return status;
  }
  
  void clearCache() {
    _cache.clear();
  }
}

class CachedValue {
  final dynamic value;
  final DateTime expiresAt;
  
  CachedValue({required this.value, required this.expiresAt});
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// ✅ GOOD: Batch operations
class DeviceCommands {
  Future<void> configureDevice(CameraDevice device) async {
    // ❌ BAD: Multiple round trips
    // await device.setPriDetection(2);
    // await device.setAlarmMotionDetection(true, 2);
    // await device.setHumanDetectionLevel(2);
    // Each call = separate network request
    
    // ✅ GOOD: Batch if possible
    await Future.wait([
      device.setPriDetection(2),
      device.setAlarmMotionDetection(true, 2),
      device.setHumanDetectionLevel(2),
    ]);
    // Concurrent execution, faster
  }
}
```

### 4. UI Performance

```dart
// ✅ GOOD: Lazy loading with pagination
class DeviceListController extends GetxController {
  final devices = <CameraDevice>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  
  int _currentPage = 0;
  static const _pageSize = 20;
  
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    
    isLoading.value = true;
    
    try {
      final newDevices = await repository.getDevices(
        page: _currentPage,
        pageSize: _pageSize,
      );
      
      devices.addAll(newDevices);
      _currentPage++;
      
      if (newDevices.length < _pageSize) {
        hasMore.value = false;
      }
      
    } finally {
      isLoading.value = false;
    }
  }
}

// Usage with ListView
ListView.builder(
  itemCount: controller.devices.length + (controller.hasMore.value ? 1 : 0),
  itemBuilder: (context, index) {
    // Load more when near end
    if (index == controller.devices.length - 3) {
      controller.loadMore();
    }
    
    // Show loading indicator at end
    if (index == controller.devices.length) {
      return Center(child: CircularProgressIndicator());
    }
    
    return DeviceTile(device: controller.devices[index]);
  },
);

// ✅ GOOD: Image optimization
Widget buildThumbnail(String url) {
  return CachedNetworkImage(
    imageUrl: url,
    placeholder: (context, url) => CircularProgressIndicator(),
    errorWidget: (context, url, error) => Icon(Icons.error),
    memCacheWidth: 200,  // Resize for memory
    memCacheHeight: 150,
    maxWidthDiskCache: 400,  // Limit disk cache
    maxHeightDiskCache: 300,
  );
}
```

---

## 🔒 Security Best Practices

### 1. Secure Credential Storage

```dart
// ❌ BAD: Plain text storage
class DeviceStorage {
  Future<void> saveCredentials(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);  // Plain text!
  }
}

// ✅ GOOD: Encrypted storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureDeviceStorage {
  final _storage = FlutterSecureStorage();
  
  Future<void> saveCredentials({
    required String deviceId,
    required String password,
  }) async {
    // Encrypted storage
    await _storage.write(
      key: 'device_${deviceId}_password',
      value: password,
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
  }
  
  Future<String?> getPassword(String deviceId) async {
    return await _storage.read(key: 'device_${deviceId}_password');
  }
  
  Future<void> deleteCredentials(String deviceId) async {
    await _storage.delete(key: 'device_${deviceId}_password');
  }
  
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### 2. Validate Inputs

```dart
// ✅ GOOD: Input validation
class DeviceValidator {
  static bool isValidDeviceId(String deviceId) {
    // Format: ABCD-123456-XXXXX or similar
    final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{6}-[A-Z0-9]{5}$');
    return regex.hasMatch(deviceId);
  }
  
  static bool isValidPassword(String password) {
    // At least 6 characters
    if (password.length < 6) return false;
    
    // Max 32 characters
    if (password.length > 32) return false;
    
    // Only alphanumeric and common symbols
    final regex = RegExp(r'^[a-zA-Z0-9@#$%^&*()_+\-=\[\]{};:,.<>?]+$');
    return regex.hasMatch(password);
  }
  
  static String? validateDeviceId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Device ID is required';
    }
    
    if (!isValidDeviceId(value)) {
      return 'Invalid device ID format';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (!isValidPassword(value)) {
      return 'Password must be 6-32 characters, alphanumeric only';
    }
    
    return null;
  }
}

// Usage in form
TextFormField(
  decoration: InputDecoration(labelText: "Device ID"),
  validator: DeviceValidator.validateDeviceId,
  onSaved: (value) => deviceId = value!,
),
```

### 3. Privacy Mode

```dart
// ✅ GOOD: Privacy controls
class PrivacyManager {
  final CameraDevice device;
  
  PrivacyManager(this.device);
  
  Future<void> enablePrivacyMode() async {
    // 1. Stop video streaming
    await device.stopVideo();
    
    // 2. Enable privacy position (PTZ goes to wall)
    if (device.cameraCommand?.privacyPosition != null) {
      await device.cameraCommand!.privacyPosition!
          .startPrivacyPosition();
    }
    
    // 3. Disable alarms
    await device.setPriDetection(0);
    await device.setAlarmMotionDetection(false, 0);
    
    // 4. Turn off LED indicator
    if (device.cameraCommand?.led != null) {
      await device.cameraCommand!.led!.setLed(0);
    }
    
    print('✅ Privacy mode enabled');
  }
  
  Future<void> disablePrivacyMode() async {
    // Restore normal operation
    if (device.cameraCommand?.privacyPosition != null) {
      await device.cameraCommand!.privacyPosition!
          .exitPrivacyPosition();
    }
    
    await device.setPriDetection(2);  // Medium
    await device.setAlarmMotionDetection(true, 2);
    
    print('✅ Privacy mode disabled');
  }
  
  Future<bool> isPrivacyModeActive() async {
    if (device.cameraCommand?.privacyPosition != null) {
      return await device.cameraCommand!.privacyPosition!
          .checkPrivacyPosition();
    }
    return false;
  }
}
```

---

## 🧪 Testing Strategies

### 1. Unit Testing

```dart
// ✅ GOOD: Testable repository
class MockCameraRepository implements CameraRepository {
  final List<CameraDevice> _devices = [];
  
  @override
  Future<CameraDevice> getDevice(String id) async {
    final device = _devices.firstWhere(
      (d) => d.deviceId == id,
      orElse: () => throw DeviceNotFoundException(),
    );
    return device;
  }
  
  @override
  Future<List<CameraDevice>> getAllDevices() async {
    return List.from(_devices);
  }
  
  void addMockDevice(CameraDevice device) {
    _devices.add(device);
  }
}

// Test file
void main() {
  group('DeviceListController', () {
    late MockCameraRepository repository;
    late DeviceListController controller;
    
    setUp(() {
      repository = MockCameraRepository();
      controller = DeviceListController(repository);
      
      // Add test data
      repository.addMockDevice(
        CameraDevice(deviceId: 'TEST-001', password: 'pass123'),
      );
    });
    
    test('loads devices on init', () async {
      await controller.loadDevices();
      
      expect(controller.devices.length, 1);
      expect(controller.devices[0].deviceId, 'TEST-001');
    });
    
    test('handles empty list', () async {
      repository = MockCameraRepository();  // Empty
      controller = DeviceListController(repository);
      
      await controller.loadDevices();
      
      expect(controller.devices.length, 0);
      expect(controller.hasError.value, false);
    });
    
    test('handles errors gracefully', () async {
      // Simulate error
      final errorRepo = ErrorCameraRepository();
      controller = DeviceListController(errorRepo);
      
      await controller.loadDevices();
      
      expect(controller.hasError.value, true);
      expect(controller.errorMessage.value, isNotEmpty);
    });
  });
}
```

### 2. Widget Testing

```dart
// ✅ GOOD: Widget tests
void main() {
  testWidgets('DeviceListPage shows devices', (tester) async {
    // Setup
    final controller = Get.put(DeviceListController(MockCameraRepository()));
    controller.devices.add(
      CameraDevice(deviceId: 'TEST-001', password: 'pass123'),
    );
    
    // Build widget
    await tester.pumpWidget(
      GetMaterialApp(
        home: DeviceListPage(),
      ),
    );
    
    // Verify
    expect(find.text('TEST-001'), findsOneWidget);
    expect(find.byType(DeviceTile), findsOneWidget);
  });
  
  testWidgets('Shows loading indicator', (tester) async {
    final controller = Get.put(DeviceListController(MockCameraRepository()));
    controller.isLoading.value = true;
    
    await tester.pumpWidget(
      GetMaterialApp(home: DeviceListPage()),
    );
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  
  testWidgets('Shows error message', (tester) async {
    final controller = Get.put(DeviceListController(MockCameraRepository()));
    controller.hasError.value = true;
    controller.errorMessage.value = 'Network error';
    
    await tester.pumpWidget(
      GetMaterialApp(home: DeviceListPage()),
    );
    
    expect(find.text('Network error'), findsOneWidget);
  });
}
```

### 3. Integration Testing

```dart
// ✅ GOOD: Integration test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Device connection flow', () {
    testWidgets('Complete connection and playback', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // 1. Navigate to add device
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // 2. Enter device credentials
      await tester.enterText(
        find.byKey(Key('deviceIdField')),
        'TEST-123456-ABCDE',
      );
      await tester.enterText(
        find.byKey(Key('passwordField')),
        'testpass123',
      );
      
      // 3. Connect
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle(Duration(seconds: 5));
      
      // 4. Verify connected
      expect(find.text('Connected'), findsOneWidget);
      
      // 5. Start video
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // 6. Verify video playing
      expect(find.byType(VideoPlayer), findsOneWidget);
    });
  });
}
```

---

## 📦 DevOps & Deployment

### 1. CI/CD Pipeline

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v2
      with:
        files: ./coverage/lcov.info
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
      if: runner.os == 'macOS'
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v2
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

### 2. Version Management

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String appName = "Veepai Camera";
  static const String version = "1.2.3";
  static const int buildNumber = 42;
  
  // Feature flags
  static const bool enableBetaFeatures = false;
  static const bool enableDebugLogging = kDebugMode;
  
  // API versions
  static const String minSupportedApiVersion = "1.0.0";
  static const String maxSupportedApiVersion = "2.0.0";
  
  static bool isVersionSupported(String version) {
    // Implement version comparison
    return true;
  }
}

// Usage
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkCompatibility(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == false) {
          return UpdateRequiredScreen();
        }
        return SplashContent();
      },
    );
  }
  
  Future<bool> _checkCompatibility() async {
    // Check if app version is compatible with SDK
    return AppConfig.isVersionSupported(sdkVersion);
  }
}
```

### 3. Environment Configuration

```dart
// lib/config/environment.dart
enum Environment {
  development,
  staging,
  production,
}

class EnvConfig {
  static Environment _environment = Environment.development;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
  
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return "https://dev-api.veepai.com";
      case Environment.staging:
        return "https://staging-api.veepai.com";
      case Environment.production:
        return "https://api.veepai.com";
    }
  }
  
  static bool get enableLogging {
    return !isProduction;
  }
}

// main.dart
void main() {
  // Set environment
  EnvConfig.setEnvironment(
    kDebugMode ? Environment.development : Environment.production
  );
  
  // Initialize logging
  if (EnvConfig.enableLogging) {
    Logger.root.level = Level.ALL;
  }
  
  runApp(MyApp());
}
```

---

## 🎯 Developer Experience

### 1. Logging Strategy

```dart
// ✅ GOOD: Structured logging
import 'package:logger/logger.dart';

class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error, stackTrace);
  }
  
  static void info(String message) {
    _logger.i(message);
  }
  
  static void warning(String message, [dynamic error]) {
    _logger.w(message, error);
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
  }
}

// Usage
class CameraDevice {
  Future<void> connect() async {
    AppLogger.info('🔌 Connecting to device: $deviceId');
    
    try {
      await _performConnection();
      AppLogger.info('✅ Connected successfully');
    } catch (e, stack) {
      AppLogger.error('❌ Connection failed', e, stack);
      rethrow;
    }
  }
}
```

### 2. Debugging Tools

```dart
// ✅ GOOD: Debug utilities
class DebugHelper {
  static void printDeviceInfo(CameraDevice device) {
    if (!kDebugMode) return;
    
    print('═══════════════════════════════════════');
    print('📷 DEVICE INFO');
    print('═══════════════════════════════════════');
    print('ID: ${device.deviceId}');
    print('Type: ${device.deviceType}');
    print('Firmware: ${device.firmwareVersion}');
    print('Battery: ${device.batteryLevel}%');
    print('Online: ${device.isOnline}');
    print('═══════════════════════════════════════');
  }
  
  static void printNetworkRequest(String url, Map<String, dynamic> data) {
    if (!kDebugMode) return;
    
    print('📡 REQUEST: $url');
    print('📦 DATA: ${jsonEncode(data)}');
  }
  
  static void printNetworkResponse(String url, dynamic response) {
    if (!kDebugMode) return;
    
    print('✅ RESPONSE: $url');
    print('📥 DATA: ${jsonEncode(response)}');
  }
}

// Usage
await device.connect();
DebugHelper.printDeviceInfo(device);
```

---

## ✅ Checklist

### Before Committing Code

```
Architecture:
□ No God classes (< 500 lines per class)
□ Clear separation of concerns
□ Proper use of design patterns

Code Quality:
□ Consistent English naming
□ No hardcoded values
□ Proper null safety
□ Documentation for public APIs

Error Handling:
□ Typed exceptions
□ User-friendly error messages
□ Proper timeout handling
□ Graceful degradation

Performance:
□ No memory leaks
□ Proper resource cleanup
□ Efficient network usage
□ Battery optimization considered

Security:
□ Credentials encrypted
□ Input validation
□ No sensitive data in logs
□ Privacy features work

Testing:
□ Unit tests written
□ Edge cases covered
□ Integration tests pass
□ Manual testing done
```

### Before Release

```
Documentation:
□ README updated
□ CHANGELOG updated
□ API docs generated
□ Migration guide (if breaking changes)

Testing:
□ All tests pass
□ Manual QA completed
□ Performance tested
□ Battery life tested

Security:
□ Security audit done
□ Credentials secure
□ Privacy compliance checked

Build:
□ Release build successful
□ ProGuard/R8 rules correct
□ App size acceptable
□ Crash reporting configured

Deployment:
□ Version numbers updated
□ Release notes written
□ Beta testing complete
□ Rollout plan ready
```

---

## 🎯 Summary

### Key Takeaways

```
Architecture:
✅ Use mixins for composition
✅ Separate concerns clearly
✅ Implement repository pattern

Code Quality:
✅ Fix mixed language naming
✅ Break down God classes
✅ Extract configuration
✅ Document public APIs

Performance:
✅ Optimize for battery
✅ Manage memory properly
✅ Cache responses
✅ Use lazy loading

Security:
✅ Encrypt credentials
✅ Validate inputs
✅ Implement privacy features

Testing:
✅ Write unit tests
✅ Test edge cases
✅ Use mocks effectively
```

---

## 📚 Next Steps

- **[12-TROUBLESHOOTING.md](./12-TROUBLESHOOTING.md)** - Common issues and solutions
- **[13-API-REFERENCE.md](./13-API-REFERENCE.md)** - Complete API documentation

---

*Updated: 2024 | Version: 1.0*

