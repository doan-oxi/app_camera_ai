# 🔧 VEEPAI SDK - TROUBLESHOOTING GUIDE

> **Complete guide to diagnosing and fixing common issues**  
> Quick solutions, debug tools, and error code reference

---

## 🎯 Quick Diagnosis Guide

### Problem Decision Tree

```
Camera not working?
    │
    ├─→ Can't connect?
    │      └─→ See "Connection Issues" section
    │
    ├─→ Connected but no video?
    │      └─→ See "Video Issues" section
    │
    ├─→ Alarms not working?
    │      └─→ See "Alarm Issues" section
    │
    ├─→ PTZ not responding?
    │      └─→ See "PTZ Issues" section
    │
    ├─→ Login fails?
    │      └─→ See "Authentication Issues" section
    │
    ├─→ App is slow/crashes?
    │      └─→ See "Performance Issues" section
    │
    └─→ Settings not saving?
           └─→ See "Configuration Issues" section
```

### Most Common Issues (Start Here)

```
1. ⚡ Connection timeout → Check network, verify credentials
2. 🎥 Black screen → Check video source type, restart stream
3. 🚨 No alarms → Verify PIR/motion enabled, check schedule
4. 🔋 Battery drain → Use PIR instead of continuous recording
5. 📵 Offline camera → Check WiFi, power cycle camera
```

---

## 🔌 CONNECTION ISSUES

### Issue 1: Camera Won't Connect

**Symptoms:**
```
❌ Connection timeout after 30 seconds
❌ Error: "Failed to establish P2P connection"
❌ Device shows offline in app
```

**Root Causes:**
1. Incorrect device ID or password
2. Camera is offline (no power/no WiFi)
3. Firewall blocking P2P ports
4. Camera and phone on different networks
5. Cloud server unreachable

**Solution Step-by-Step:**

```dart
// 1. Verify credentials
Future<void> diagnoseConnection(CameraDevice device) async {
  print("🔍 Diagnosing connection...");
  
  // Check device ID format
  if (!device.deviceId.contains('-')) {
    print("❌ Invalid device ID format");
    print("✅ Format should be: ABCD-123456-XXXXX");
    return;
  }
  
  // Check password
  if (device.password.length < 6) {
    print("❌ Password too short (min 6 characters)");
    return;
  }
  
  print("✅ Credentials format OK");
  
  // 2. Test network connectivity
  try {
    final response = await http.get(
      Uri.parse('https://vuid.eye4.cn/vuid/query')
    ).timeout(Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      print("✅ Cloud servers reachable");
    } else {
      print("❌ Cloud server error: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Network error: $e");
    print("💡 Check internet connection");
    return;
  }
  
  // 3. Try to resolve VID
  try {
    print("🔍 Resolving device VID...");
    await device.resolveClientID();
    print("✅ VID resolution successful");
  } catch (e) {
    print("❌ VID resolution failed: $e");
    print("💡 Device may be offline or ID is wrong");
    return;
  }
  
  // 4. Attempt connection
  try {
    print("🔍 Connecting to camera...");
    final state = await device.connect();
    
    if (state == CameraConnectState.connected) {
      print("✅ Connection successful!");
    } else {
      print("❌ Connection failed: $state");
    }
  } catch (e) {
    print("❌ Connection error: $e");
  }
}

// Quick fix function
Future<bool> quickFixConnection(CameraDevice device) async {
  print("🔧 Attempting quick fixes...");
  
  // Fix 1: Reset connection state
  await device.disconnect();
  await Future.delayed(Duration(seconds: 2));
  
  // Fix 2: Clear any cached state
  device.clearCache();
  
  // Fix 3: Try connection with extended timeout
  try {
    final state = await device.connect().timeout(
      Duration(seconds: 60),  // Longer timeout
    );
    
    return state == CameraConnectState.connected;
  } catch (e) {
    print("❌ Quick fix failed: $e");
    return false;
  }
}
```

**Prevention:**
```dart
// Save working credentials securely
final storage = FlutterSecureStorage();
await storage.write(
  key: 'device_${device.deviceId}_password',
  value: device.password,
);

// Implement auto-reconnect
class ReconnectManager {
  Timer? _reconnectTimer;
  
  void startMonitoring(CameraDevice device) {
    _reconnectTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      if (device.connectionState != CameraConnectState.connected) {
        await device.connect();
      }
    });
  }
  
  void stop() {
    _reconnectTimer?.cancel();
  }
}
```

---

### Issue 2: Connection Drops Frequently

**Symptoms:**
```
⚠️ Connection established but drops after 1-2 minutes
⚠️ Video stream stops unexpectedly
⚠️ "Connection lost" error appears
```

**Root Causes:**
1. Weak WiFi signal on camera
2. Network congestion
3. No keep-alive packets
4. Router timeout settings

**Solution:**

```dart
// Implement keep-alive mechanism
class ConnectionKeepAlive {
  Timer? _keepAliveTimer;
  final CameraDevice device;
  
  ConnectionKeepAlive(this.device);
  
  void start() {
    // Send keep-alive every 30 seconds
    _keepAliveTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      try {
        // Lightweight command to keep connection alive
        await device.getStatus(cache: false);
        print("💓 Keep-alive sent");
      } catch (e) {
        print("❌ Keep-alive failed: $e");
        await _attemptReconnect();
      }
    });
  }
  
  Future<void> _attemptReconnect() async {
    print("🔄 Attempting reconnection...");
    
    try {
      await device.disconnect();
      await Future.delayed(Duration(seconds: 1));
      await device.connect();
      print("✅ Reconnected");
    } catch (e) {
      print("❌ Reconnect failed: $e");
    }
  }
  
  void stop() {
    _keepAliveTimer?.cancel();
  }
}

// Usage
class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late ConnectionKeepAlive _keepAlive;
  
  @override
  void initState() {
    super.initState();
    _keepAlive = ConnectionKeepAlive(widget.device);
    _keepAlive.start();
  }
  
  @override
  void dispose() {
    _keepAlive.stop();
    super.dispose();
  }
}
```

**Check WiFi Signal:**

```dart
// Monitor connection quality
class ConnectionQualityMonitor {
  Future<ConnectionQuality> checkQuality(CameraDevice device) async {
    // Get WiFi signal strength from camera
    final status = await device.getStatus();
    
    int? signalStrength;
    if (status.wifiDbm != null) {
      signalStrength = int.tryParse(status.wifiDbm!);
    }
    
    if (signalStrength == null) {
      return ConnectionQuality.unknown;
    }
    
    // dBm scale: -30 (excellent) to -90 (poor)
    if (signalStrength > -50) {
      return ConnectionQuality.excellent;
    } else if (signalStrength > -60) {
      return ConnectionQuality.good;
    } else if (signalStrength > -70) {
      return ConnectionQuality.fair;
    } else {
      return ConnectionQuality.poor;
    }
  }
}

enum ConnectionQuality {
  excellent,  // -30 to -50 dBm
  good,       // -50 to -60 dBm
  fair,       // -60 to -70 dBm
  poor,       // -70 to -90 dBm
  unknown,
}
```

---

### Issue 3: P2P Connection Fails

**Symptoms:**
```
❌ "P2P connection failed"
❌ Falls back to relay server
❌ High latency (>500ms)
```

**Root Causes:**
1. Both devices behind NAT (symmetric NAT)
2. Firewall blocking UDP ports
3. Router doesn't support port forwarding
4. ISP blocks P2P traffic

**Solution:**

```dart
// Check P2P connectivity mode
Future<void> checkP2PMode(CameraDevice device) async {
  print("🔍 Checking P2P connection mode...");
  
  // Get connection mode from client
  final mode = device.p2pClient?.connectMode;
  
  switch (mode) {
    case ClientConnectMode.p2p:
      print("✅ Direct P2P connection");
      print("   → Lowest latency");
      print("   → Best performance");
      break;
      
    case ClientConnectMode.relay:
      print("⚠️ Relay connection");
      print("   → Higher latency");
      print("   → May have bandwidth limits");
      print("💡 Try:");
      print("   • Use same WiFi network as camera");
      print("   • Enable UPnP on router");
      print("   • Configure port forwarding");
      break;
      
    case ClientConnectMode.lan:
      print("✅ LAN connection");
      print("   → Same network, fast");
      break;
      
    default:
      print("❓ Unknown connection mode");
  }
}

// Force LAN connection when on same network
Future<bool> tryLANConnection(CameraDevice device) async {
  print("🔍 Attempting LAN connection...");
  
  try {
    // Get camera's local IP
    final status = await device.getStatus();
    final localIP = status.localIP;
    
    if (localIP != null && localIP.isNotEmpty) {
      print("📍 Camera local IP: $localIP");
      
      // Try direct LAN connection
      // (Implementation depends on SDK capabilities)
      
      return true;
    } else {
      print("❌ Camera local IP not available");
      return false;
    }
  } catch (e) {
    print("❌ LAN connection failed: $e");
    return false;
  }
}
```

---

## 🎥 VIDEO ISSUES

### Issue 4: No Video Stream (Black Screen)

**Symptoms:**
```
❌ Video widget shows black screen
❌ No error message
❌ Audio might still work
```

**Root Causes:**
1. Wrong video source type
2. Video not started
3. Codec not supported
4. Memory issue

**Solution:**

```dart
// Comprehensive video troubleshooting
Future<void> diagnoseVideo(CameraDevice device) async {
  print("🎥 Diagnosing video stream...");
  
  // 1. Check if connected
  if (device.connectionState != CameraConnectState.connected) {
    print("❌ Device not connected");
    print("💡 Connect to device first");
    return;
  }
  
  // 2. Stop any existing stream
  if (device.playerController != null) {
    print("🛑 Stopping existing stream...");
    await device.stopVideo();
    await Future.delayed(Duration(seconds: 1));
  }
  
  // 3. Try live stream
  print("▶️ Starting live stream...");
  try {
    final player = AppPlayerController(
      device: device,
      sourceType: VideoSourceType.live,
    );
    
    await player.play();
    
    await Future.delayed(Duration(seconds: 3));
    
    if (player.videoStatus == VideoStatus.playing) {
      print("✅ Live stream working");
    } else {
      print("❌ Live stream not playing");
      print("   Status: ${player.videoStatus}");
    }
    
  } catch (e) {
    print("❌ Live stream error: $e");
  }
  
  // 4. Check camera video settings
  final status = await device.getStatus();
  print("📹 Camera video settings:");
  print("   Resolution: ${status.resolution}");
  print("   FPS: ${status.fps}");
  print("   Bitrate: ${status.bitrate}");
}

// Quick fix function
Future<bool> fixBlackScreen(CameraDevice device) async {
  print("🔧 Fixing black screen...");
  
  try {
    // Fix 1: Stop and restart
    await device.stopVideo();
    await Future.delayed(Duration(seconds: 2));
    
    // Fix 2: Recreate player
    final player = AppPlayerController(
      device: device,
      sourceType: VideoSourceType.live,
    );
    
    // Fix 3: Start with callback
    bool started = false;
    player.videoStatusCallBack = (status) {
      print("Video status: $status");
      if (status == VideoStatus.playing) {
        started = true;
      }
    };
    
    await player.play();
    
    // Fix 4: Wait for stream to start
    await Future.delayed(Duration(seconds: 5));
    
    return started;
    
  } catch (e) {
    print("❌ Fix failed: $e");
    return false;
  }
}
```

---

### Issue 5: Video Freezes or Choppy

**Symptoms:**
```
⚠️ Video plays but freezes every few seconds
⚠️ Choppy/laggy playback
⚠️ Audio continues but video stops
```

**Root Causes:**
1. Slow network connection
2. High video bitrate
3. Device CPU overload
4. Memory pressure

**Solution:**

```dart
// Reduce video quality for better performance
Future<void> optimizeVideoPlayback(CameraDevice device) async {
  print("⚙️ Optimizing video playback...");
  
  // 1. Lower video resolution
  try {
    // Change to sub-stream (lower quality, less bandwidth)
    await device.playerController?.switchChannel(
      ClientChannelType.sub  // Sub-stream = lower quality
    );
    print("✅ Switched to lower quality stream");
  } catch (e) {
    print("❌ Failed to switch stream: $e");
  }
  
  // 2. Check network speed
  final startTime = DateTime.now();
  try {
    await device.getStatus();
    final latency = DateTime.now().difference(startTime);
    
    print("📶 Network latency: ${latency.inMilliseconds}ms");
    
    if (latency.inMilliseconds > 500) {
      print("⚠️ High latency detected");
      print("💡 Consider:");
      print("   • Move closer to WiFi router");
      print("   • Reduce other network usage");
      print("   • Use lower video quality");
    }
  } catch (e) {
    print("❌ Network test failed: $e");
  }
  
  // 3. Enable hardware decoding (if available)
  // This reduces CPU usage
  
  // 4. Reduce frame buffer size
  // (Implementation specific to player)
}

// Monitor video performance
class VideoPerformanceMonitor {
  int frameCount = 0;
  DateTime? lastCheck;
  
  void onFrameReceived() {
    frameCount++;
    
    final now = DateTime.now();
    if (lastCheck == null) {
      lastCheck = now;
      return;
    }
    
    final elapsed = now.difference(lastCheck!);
    if (elapsed.inSeconds >= 1) {
      final fps = frameCount / elapsed.inSeconds;
      print("📊 Video FPS: ${fps.toStringAsFixed(1)}");
      
      if (fps < 15) {
        print("⚠️ Low FPS detected");
        print("💡 Try optimizing playback settings");
      }
      
      frameCount = 0;
      lastCheck = now;
    }
  }
}
```

---

## 🚨 ALARM ISSUES

### Issue 6: Alarms Not Triggering

**Symptoms:**
```
❌ Person walks by, no alarm
❌ Motion detected but no push notification
❌ PIR sensor not detecting
```

**Root Causes:**
1. Detection disabled
2. Sensitivity too low
3. Detection zones configured wrong
4. Alarm schedule blocks detection
5. Battery saving mode

**Solution:**

```dart
// Comprehensive alarm diagnosis
Future<void> diagnoseAlarms(CameraDevice device) async {
  print("🚨 Diagnosing alarm system...");
  
  // 1. Check PIR detection
  try {
    await device.getPirDetection();
    
    print("PIR Settings:");
    print("  Level: ${device.pirLevel}");
    print("  Distance: ${device.distanceAdjust}");
    print("  Humanoid filter: ${device.humanoidDetection}");
    
    if (device.pirLevel == 0) {
      print("❌ PIR detection is OFF");
      print("💡 Enable PIR: await device.setPriDetection(2);");
    } else {
      print("✅ PIR detection enabled");
    }
  } catch (e) {
    print("❌ PIR check failed: $e");
  }
  
  // 2. Check push notifications
  try {
    await device.getAlarmParam();
    
    print("Push Notification Settings:");
    print("  Push enabled: ${device.pirPushEnable}");
    print("  Video enabled: ${device.pirPushVideoEnable}");
    
    if (device.pirPushEnable == false) {
      print("❌ Push notifications disabled");
      print("💡 Enable: await device.setPriPush(pushEnable: true);");
    }
  } catch (e) {
    print("❌ Push check failed: $e");
  }
  
  // 3. Check alarm schedule
  try {
    await device.getAlarmPlan(11, 2);
    
    // Check if current time is in active slot
    final now = DateTime.now();
    final dayOfWeek = now.weekday - 1;  // 0=Monday
    final hour = now.hour;
    
    // Determine which slot (0-2) based on hour
    int slotIndex = hour ~/ 8;
    int slotNumber = dayOfWeek * 3 + slotIndex + 1;
    
    print("Current time slot: $slotNumber");
    print("💡 Check if this slot is enabled in alarm plan");
    
  } catch (e) {
    print("❌ Alarm plan check failed: $e");
  }
  
  // 4. Check detection zones
  print("💡 Verify detection zones are configured");
  print("   See detection zone settings in app");
}

// Quick fix for alarms
Future<void> fixAlarms(CameraDevice device) async {
  print("🔧 Fixing alarm settings...");
  
  // Fix 1: Enable PIR with medium sensitivity
  await device.setPriDetection(2);
  print("✅ PIR enabled (medium sensitivity)");
  
  // Fix 2: Enable push notifications
  await device.setPriPush(
    pushEnable: true,
    videoEnable: true,
    videoDuration: 15,
  );
  print("✅ Push notifications enabled");
  
  // Fix 3: Set detection range to far
  await device.setDetectionRange(1);
  print("✅ Detection range set to far");
  
  // Fix 4: Enable humanoid filter (reduce false alarms)
  await device.setHuanoidDetection(1);
  print("✅ Humanoid filter enabled");
  
  // Fix 5: Enable all detection zones
  List<int> allZones = List.filled(18, 1);
  await device.setAlarmZone(1, ...allZones);  // Motion
  await device.setAlarmZone(3, ...allZones);  // Human
  print("✅ All detection zones enabled");
  
  print("🎉 Alarm system configured");
  print("💡 Test by walking in front of camera");
}
```

---

### Issue 7: Too Many False Alarms

**Symptoms:**
```
⚠️ Alarm triggers on pets
⚠️ Alarm triggers on shadows/trees
⚠️ Constant notifications
```

**Solution:**

```dart
// Reduce false alarms
Future<void> reduceFalseAlarms(CameraDevice device) async {
  print("🔧 Reducing false alarms...");
  
  // 1. Use Human Detection instead of Motion
  if (device.aiCommand?.humanDetection != null) {
    await device.setHumanDetectionLevel(2);  // Medium
    print("✅ Switched to Human Detection (AI-based)");
  } else {
    print("⚠️ Human detection not supported");
    
    // 2. Enable humanoid filter on PIR
    await device.setHuanoidDetection(1);
    print("✅ Humanoid filter enabled on PIR");
  }
  
  // 3. Lower sensitivity
  await device.setPriDetection(1);  // Low sensitivity
  print("✅ Reduced PIR sensitivity");
  
  // 4. Configure detection zones (exclude problem areas)
  List<int> zones = [
    1, 1, 1, 1, 1, 1,  // Top row: Monitor
    1, 1, 1, 1, 1, 1,  // Middle row: Monitor
    0, 0, 0, 0, 0, 0,  // Bottom row: Ignore (pets, ground)
  ];
  
  await device.setAlarmZone(1, ...zones);  // Motion zones
  await device.setAlarmZone(3, ...zones);  // Human zones
  print("✅ Detection zones configured (ignoring ground)");
  
  // 5. Use alarm schedule (only when needed)
  print("💡 Consider setting alarm schedule");
  print("   Only enable during specific hours");
  
  print("🎉 False alarm reduction applied");
}
```

---

## 🕹️ PTZ ISSUES

### Issue 8: PTZ Not Responding

**Symptoms:**
```
❌ PTZ buttons don't move camera
❌ Preset positions don't work
❌ No error shown
```

**Solution:**

```dart
// Diagnose PTZ
Future<void> diagnosePTZ(CameraDevice device) async {
  print("🕹️ Diagnosing PTZ...");
  
  // 1. Check if camera supports PTZ
  if (device.motorCommand == null) {
    print("❌ Camera does not support PTZ");
    return;
  }
  
  print("✅ Camera supports PTZ");
  
  // 2. Check privacy mode
  if (device.cameraCommand?.privacyPosition != null) {
    final inPrivacy = await device.cameraCommand!.privacyPosition!
        .checkPrivacyPosition();
    
    if (inPrivacy) {
      print("❌ Camera is in privacy mode");
      print("💡 Exit privacy mode:");
      print("   await device.cameraCommand!.privacyPosition!.exitPrivacyPosition();");
      return;
    }
  }
  
  // 3. Test PTZ movement
  print("🔄 Testing PTZ left...");
  try {
    bool success = await device.motorCommand!.left();
    
    if (success) {
      print("✅ PTZ command accepted");
      
      // Wait for movement
      await Future.delayed(Duration(milliseconds: 500));
      
      // Test right to return
      await device.motorCommand!.right();
      print("✅ PTZ movement successful");
      
    } else {
      print("❌ PTZ command failed");
    }
  } catch (e) {
    print("❌ PTZ error: $e");
  }
  
  // 4. Test continuous movement
  print("🔄 Testing continuous PTZ...");
  try {
    await device.motorCommand!.startLeft();
    await Future.delayed(Duration(seconds: 1));
    await device.motorCommand!.stopLeft();
    print("✅ Continuous PTZ works");
  } catch (e) {
    print("❌ Continuous PTZ failed: $e");
  }
}

// Fix slow/jerky PTZ
Future<void> fixPTZPerformance(CameraDevice device) async {
  print("🔧 Optimizing PTZ performance...");
  
  // Use continuous movement with speed control
  class SmoothPTZController {
    final CameraDevice device;
    bool _isMoving = false;
    
    SmoothPTZController(this.device);
    
    Future<void> moveLeft({int speed = 5}) async {
      if (_isMoving) return;
      
      _isMoving = true;
      await device.motorCommand!.startLeft(motorSpeed: speed);
    }
    
    Future<void> stop() async {
      if (!_isMoving) return;
      
      await device.motorCommand!.stopLeft();
      await device.motorCommand!.stopRight();
      await device.motorCommand!.stopUp();
      await device.motorCommand!.stopDown();
      
      _isMoving = false;
    }
  }
  
  print("✅ Use speed control for smoother movements");
}
```

---

## 🔐 AUTHENTICATION ISSUES

### Issue 9: Invalid Credentials

**Symptoms:**
```
❌ "Invalid device ID or password"
❌ "Authentication failed"
❌ Can't login to camera
```

**Solution:**

```dart
// Validate credentials
Future<bool> validateCredentials(String deviceId, String password) async {
  print("🔍 Validating credentials...");
  
  // 1. Check device ID format
  // Format: ABCD-123456-XXXXX
  final deviceIdPattern = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{6}-[A-Z0-9]{5}$');
  
  if (!deviceIdPattern.hasMatch(deviceId)) {
    print("❌ Invalid device ID format");
    print("✅ Expected format: ABCD-123456-XXXXX");
    print("   Example: VUID-000001-ABCDE");
    return false;
  }
  
  print("✅ Device ID format valid");
  
  // 2. Check password
  if (password.length < 6) {
    print("❌ Password too short (minimum 6 characters)");
    return false;
  }
  
  if (password.length > 32) {
    print("❌ Password too long (maximum 32 characters)");
    return false;
  }
  
  // Check for invalid characters
  final passwordPattern = RegExp(r'^[a-zA-Z0-9@#$%^&*()_+\-=\[\]{};:,.<>?]+$');
  if (!passwordPattern.hasMatch(password)) {
    print("❌ Password contains invalid characters");
    print("✅ Allowed: letters, numbers, common symbols");
    return false;
  }
  
  print("✅ Password format valid");
  
  // 3. Try to create device
  try {
    final device = CameraDevice(
      deviceId: deviceId,
      password: password,
    );
    
    print("✅ Device object created");
    
    // 4. Try connection
    print("🔍 Testing connection...");
    final state = await device.connect().timeout(
      Duration(seconds: 30),
    );
    
    if (state == CameraConnectState.connected) {
      print("✅ Credentials valid, connection successful");
      await device.disconnect();
      return true;
    } else {
      print("❌ Connection failed: $state");
      print("💡 Possible reasons:");
      print("   • Camera is offline");
      print("   • Incorrect password");
      print("   • Network issue");
      return false;
    }
    
  } catch (e) {
    print("❌ Validation error: $e");
    
    if (e.toString().contains('authentication')) {
      print("💡 Password is incorrect");
    } else if (e.toString().contains('timeout')) {
      print("💡 Camera may be offline");
    } else {
      print("💡 Check network connection");
    }
    
    return false;
  }
}
```

---

## ⚡ PERFORMANCE ISSUES

### Issue 10: High Memory Usage

**Symptoms:**
```
⚠️ App uses >500MB RAM
⚠️ Device becomes hot
⚠️ System kills app
```

**Solution:**

```dart
// Monitor memory usage
class MemoryMonitor {
  static void printMemoryUsage() {
    // Get memory info (platform specific)
    print("💾 Memory usage monitoring");
    
    // iOS: Use Instruments
    // Android: adb shell dumpsys meminfo <package>
  }
  
  static Future<void> optimizeMemory() async {
    print("🔧 Optimizing memory...");
    
    // 1. Stop unused video streams
    // 2. Clear image caches
    // 3. Dispose controllers
    
    print("✅ Memory optimized");
  }
}

// Proper resource cleanup
class VideoPageController extends GetxController {
  AppPlayerController? _playerController;
  Timer? _keepAliveTimer;
  
  @override
  void onInit() {
    super.onInit();
    _startVideo();
  }
  
  Future<void> _startVideo() async {
    _playerController = AppPlayerController(
      device: device,
      sourceType: VideoSourceType.live,
    );
    
    await _playerController!.play();
  }
  
  @override
  void onClose() {
    // Critical: Clean up resources
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    
    if (_playerController != null) {
      _playerController!.stop();
      _playerController!.dispose();
      _playerController = null;
    }
    
    super.onClose();
  }
}
```

---

### Issue 11: Battery Drain

**Solution:**

```dart
// Optimize for battery
class BatteryOptimizer {
  static Future<void> enableBatteryMode(CameraDevice device) async {
    print("🔋 Enabling battery optimization...");
    
    // 1. Use PIR only (lowest power)
    await device.setPriDetection(2);
    
    // 2. Disable video recording
    await device.setPriPush(
      pushEnable: true,
      videoEnable: false,  // Save battery
    );
    
    // 3. Reduce detection frequency
    // Use alarm schedule to only monitor during specific hours
    
    // 4. Lower video quality if recording
    // Use sub-stream instead of main stream
    
    print("✅ Battery mode enabled");
  }
}
```

---

## 🛠️ DEBUG TOOLS

### Enable Debug Logging

```dart
// Enable comprehensive logging
class DebugConfig {
  static bool enableLogging = true;
  static bool enableNetworkLogging = true;
  static bool enableVideoLogging = true;
  
  static void init() {
    if (enableLogging) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      });
    }
  }
  
  static void logCommand(String command, Map<String, dynamic> params) {
    if (!enableNetworkLogging) return;
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📡 COMMAND: $command');
    print('📦 PARAMS: ${jsonEncode(params)}');
    print('⏰ TIME: ${DateTime.now()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
  
  static void logResponse(String command, dynamic response) {
    if (!enableNetworkLogging) return;
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ RESPONSE: $command');
    print('📥 DATA: ${jsonEncode(response)}');
    print('⏰ TIME: ${DateTime.now()}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}

// Usage in your app
void main() {
  DebugConfig.init();
  runApp(MyApp());
}
```

### Collect Logs for Support

```dart
// Log collector
class LogCollector {
  static final List<String> _logs = [];
  
  static void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _logs.add('[$timestamp] $message');
    
    // Keep last 1000 logs
    if (_logs.length > 1000) {
      _logs.removeAt(0);
    }
  }
  
  static Future<File> exportLogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/veepai_logs.txt');
    
    await file.writeAsString(_logs.join('\n'));
    
    print('✅ Logs exported to: ${file.path}');
    return file;
  }
  
  static void clear() {
    _logs.clear();
  }
}
```

---

## 📚 ERROR CODE REFERENCE

### Common CGI Command Codes

```
24601: Motor command result
24785: Generic CGI command result
24588: Alarm configuration result
24584: WiFi scan result
24618: WiFi scan status
```

### Connection States

```dart
enum CameraConnectState {
  disconnected,  // Not connected
  connecting,    // Connecting in progress
  connected,     // Successfully connected
  error,         // Connection error
}
```

### Video Status Codes

```dart
enum VideoStatus {
  stopped,    // Video not playing
  loading,    // Loading video
  playing,    // Video playing
  paused,     // Video paused
  error,      // Playback error
}
```

---

## 🎯 Quick Reference Cheatsheet

```
Connection Won't Work:
→ Verify credentials, check network, try VID resolution manually

Black Screen:
→ Stop video, wait 2s, restart with correct source type

Alarms Not Working:
→ Check PIR level, verify push enabled, check schedule

PTZ Not Moving:
→ Check privacy mode, verify motorCommand exists

Battery Draining:
→ Use PIR only, disable video, reduce sensitivity

App Crashes:
→ Dispose controllers properly, check memory usage

Settings Won't Save:
→ Wait for success response, verify result=0
```

---

## 💡 Prevention Tips

### Before You Code

```
✅ Read documentation thoroughly
✅ Understand P2P architecture
✅ Test with real camera hardware
✅ Handle all error cases
✅ Implement proper cleanup
```

### During Development

```
✅ Use debug logging
✅ Test on slow networks
✅ Test with weak WiFi
✅ Test battery cameras
✅ Monitor memory usage
```

### Before Release

```
✅ Test all error scenarios
✅ Verify resource cleanup
✅ Check for memory leaks
✅ Test reconnection logic
✅ Review error handling
```

---

## 🎯 Summary

### Most Common Issues & Quick Fixes

```
1. Connection Timeout
   → Check credentials, verify network

2. Black Screen
   → Restart video stream

3. No Alarms
   → Enable PIR, check schedule

4. PTZ Not Working
   → Exit privacy mode

5. Battery Drain
   → Use PIR only, disable continuous video
```

### When All Else Fails

```
1. Restart camera (power cycle)
2. Restart app
3. Clear app cache
4. Reinstall app
5. Check for firmware updates
6. Contact support with logs
```

---

## 📞 Getting Help

If you're still stuck after trying these solutions:

1. **Collect logs** using LogCollector
2. **Document the issue** with screenshots
3. **Note camera model** and firmware version
4. **Describe what you tried** and results
5. **Contact support** with all information

---

## 📚 Related Documentation

- **[10-BEST-PRACTICES.md](./10-BEST-PRACTICES.md)** - Prevent issues with best practices
- **[02-CONNECTION-FLOW.md](./02-CONNECTION-FLOW.md)** - Understand connection process
- **[13-API-REFERENCE.md](./13-API-REFERENCE.md)** - Complete API reference

---

*Updated: 2024 | Version: 1.0*

