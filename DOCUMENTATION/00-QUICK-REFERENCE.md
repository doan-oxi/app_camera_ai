# ⚡ VEEPAI SDK - QUICK REFERENCE

> **Cheat sheet nhanh cho developers - All you need on 1 page**

---

## 🎯 5-Minute Quick Start

```dart
// 1. Create device
CameraDevice device = CameraDevice(
  "VE0005622QHOW",  // Device ID
  "Living Room",    // Name
  "admin",          // Username
  "888888",         // Password
  "QW6-T"          // Model
);

// 2. Connect
await device.connect();

// 3. Create player
AppPlayerController player = AppPlayerController();
await player.create();

// 4. Set source & play
int clientPtr = await device.getClientPtr();
await player.setVideoSource(LiveVideoSource(clientPtr));
await device.startStream(resolution: VideoResolution.high);
await player.start();

// 5. Display
AppPlayerView<int>(controller: player, fit: BoxFit.contain);
```

---

## 📊 Architecture Overview

```
App (Flutter/Dart)
    ↓ MethodChannel/FFI
Native (Kotlin/Swift)
    ↓ JNI
P2P Library (Proprietary)
    ↓ TCP/UDP
Camera Device
```

**Video flow:**
```
Camera → P2P (direct) → App
         ↓
    Your Backend (metadata only, NOT video!)
```

---

## 🔑 Key Concepts

### Device ID Types

```
Virtual ID (VID):     VE0005622QHOW
Real Device ID:       VSTC123456789ABCDEF
AP Mode IP:          192.168.168.1
```

### Connection Paths

```
1. LAN:       50-150ms   ✅ Best (same network)
2. P2P:       150-300ms  ✅ Good (NAT traversal)
3. Relay:     300-800ms  ⚠️ OK (fallback)
```

### Video Resolutions

```
VideoResolution.low       → 360p  (512 Kbps)
VideoResolution.general   → 720p  (1.5 Mbps) [Default]
VideoResolution.high      → 1080p (3 Mbps)
VideoResolution.superHD   → 4K    (8 Mbps)
```

---

## 🔌 Common Operations

### Device Management

```dart
// List devices
List<Map> devices = await DeviceListManager.getInstance().getDevices();

// Add device
await DeviceListManager.getInstance().saveDevice(deviceId, password);

// Remove device
await DeviceListManager.getInstance().removeDevice(deviceId);
```

### Connection

```dart
// Standard connect
var state = await device.connect();

// With options
var state = await device.connect(
  lanScan: true,          // Try LAN first
  connectCount: 3,        // Retry 3 times
  connectType: 0x7E       // Connection type
);

// Disconnect
await device.disconnect();
```

### Video Control

```dart
// Start live stream
await device.startStream(resolution: VideoResolution.high);
await player.start();

// Change resolution
await device.changeResolution(VideoResolution.general);

// Stop stream
await player.stop();
await device.stopStream();

// Audio
await player.startVoice();  // Enable audio
await player.stopVoice();   // Mute
```

### PTZ Control

```dart
// Basic movement
await device.motorCommand!.up();
await device.motorCommand!.down();
await device.motorCommand!.left();
await device.motorCommand!.right();

// Preset positions
await device.motorCommand!.setPresetLocation(1);  // Save to preset 1
await device.motorCommand!.toPresetLocation(1);   // Go to preset 1

// Home position
await device.motorCommand!.ptzCorrect();
```

### Recording

```dart
// Start recording
await player.startRecord(encoderType: RecordEncoderType.G711);

// Stop recording
await player.stopRecord();

// Screenshot
await player.screenshot("/path/to/save.jpg");
```

### AI Features

```dart
// Human tracking
await device.aiCommand!.humanTracking!.setHumanTracking(true);

// Human framing
await device.aiCommand!.humanFraming!.setHumanFraming(true);

// Human zoom
await device.aiCommand!.humanZoom!.setHumanZoom(true);
```

### Alarm Settings

```dart
// Enable push notifications
await device.alarmCommand!.setPushEnable(true);

// Set motion sensitivity
await device.alarmCommand!.setMotionLevel(70); // 0-100

// Set human detection sensitivity
await device.alarmCommand!.setHumanDetectionLevel(80);

// Video recording on alarm
await device.alarmCommand!.setVideoEnable(true);
await device.alarmCommand!.setVideoDuration(15); // seconds
```

---

## 🎯 Common Patterns

### Initialize & Connect

```dart
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraDevice? device;
  AppPlayerController? player;
  
  @override
  void initState() {
    super.initState();
    _init();
  }
  
  Future<void> _init() async {
    device = CameraDevice(...);
    
    // Setup listeners
    device!.addListener<CameraConnectChanged>((d, state) {
      print("State: $state");
    });
    
    // Connect
    await device!.connect();
    
    // Setup player
    player = AppPlayerController();
    await player!.create();
    await player!.setVideoSource(LiveVideoSource(device!.clientPtr));
    await device!.startStream();
    await player!.start();
    
    setState(() {});
  }
  
  @override
  void dispose() {
    player?.dispose();
    device?.disconnect();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (player == null) return CircularProgressIndicator();
    return AppPlayerView<int>(controller: player!);
  }
}
```

### Error Handling

```dart
try {
  var state = await device.connect();
  
  switch (state) {
    case CameraConnectState.connected:
      print("✅ Connected");
      break;
    case CameraConnectState.timeout:
      print("⏱️ Timeout");
      break;
    case CameraConnectState.password:
      print("🔑 Wrong password");
      break;
    case CameraConnectState.offline:
      print("📵 Camera offline");
      break;
    default:
      print("❌ Failed: $state");
  }
} catch (e) {
  print("💥 Error: $e");
}
```

### Progress Callback

```dart
player.addProgressChangeCallback((data, total, play, progress, loadState, velocity, timestamp) {
  print("$play / $total seconds");
  print("Progress: $progress%");
  print("Speed: $velocity KB/s");
});
```

---

## 🚫 Bypass Cloud Options

### Option 1: AP Mode (Zero Cloud)

```dart
// Connect to camera's WiFi: "IPC-XXXXXXX"
CameraDevice device = CameraDevice(
  "192.168.168.1",  // Fixed AP IP
  "AP Camera",
  "admin",
  "888888",
  "Unknown"
);

await device.connect(lanScan: true);
```

### Option 2: Self-Host Backend

Replace these URLs in your fork:
```dart
// Device binding
"https://api.eye4.cn/hello/*" 
  → "https://your-backend.com/api/hello/*"

// VID resolution
"https://vuid.eye4.cn"
  → "https://your-backend.com/api/vuid/*"

// Authentication
"https://authentication.eye4.cn"
  → "https://your-backend.com/api/auth/*"
```

### Option 3: Use Real Device ID

```dart
// Skip virtual ID resolution
CameraDevice device = CameraDevice(
  "VSTC123456789ABCDEF",  // Real ID, not VID
  ...
);
```

---

## 📋 CGI Commands Reference

### Common CGI Commands

```dart
// Login
"login.cgi?user=admin&password=888888&"

// Get status
"get_status.cgi"

// Start livestream
"livestream.cgi?streamid=10&substream=1&"  // High quality
"livestream.cgi?streamid=10&substream=2&"  // Medium quality

// PTZ control
"decoder_control.cgi?command=0&"   // Up
"decoder_control.cgi?command=2&"   // Down
"decoder_control.cgi?command=4&"   // Left
"decoder_control.cgi?command=6&"   // Right
"decoder_control.cgi?command=1&"   // Stop

// Get alarm params
"get_alarm_param.cgi"

// Set alarm
"set_alarm_param.cgi?motion_detect_enable=1&motion_detect_level=50&"

// Get WiFi list
"get_wifi_scan.cgi"

// Set WiFi
"set_wifi.cgi?ssid=MyWiFi&password=12345678&encryption=3&"

// Reboot
"reboot.cgi"
```

### Send CGI Command

```dart
// Method 1: Direct write
await device.writeCgi("get_status.cgi");

// Method 2: Wait for result
CommandResult result = await device.waitCommandResult(
  (cmd, data) => cmd == 0x01,  // Filter by command type
  5000  // Timeout: 5 seconds
);

// Method 3: Use command methods
StatusResult status = await device.getStatus();
```

---

## 🔐 Security Checklist

```
✅ Change default password (888888 → strong password)
✅ Use HTTPS for all APIs
✅ Validate device IDs
✅ Implement token-based auth
✅ Encrypt sensitive data in storage
✅ Use SSL certificates
✅ Implement rate limiting
✅ Log security events
```

---

## 📊 Performance Optimization

### Reduce Latency

```dart
// 1. Force LAN connection
await device.connect(lanScan: true, connectType: 0x7F);

// 2. Use lower resolution
await device.startStream(resolution: VideoResolution.general);

// 3. Reduce buffer
player.setBufferTime(500);  // 0.5 second

// 4. Disable audio if not needed
// (Don't call player.startVoice())
```

### Reduce Bandwidth

```dart
// Use low resolution for multi-camera
await device.startStream(resolution: VideoResolution.low);

// Stop stream when not visible
await player.stop();
await device.stopStream();
```

### Reduce Memory

```dart
// Dispose properly
@override
void dispose() {
  player?.dispose();
  device?.disconnect();
  super.dispose();
}

// Limit concurrent cameras
const MAX_CAMERAS = 4;
```

---

## 🐛 Quick Troubleshooting

### Connection Failed

```dart
// Check 1: Device online?
bool online = await device.checkDeviceOnline();

// Check 2: Password correct?
// Try default: "888888"

// Check 3: Network reachable?
// Ping camera IP

// Check 4: Try AP mode
// Connect to camera's WiFi
```

### Video Not Playing

```dart
// Check 1: Stream started?
await device.startStream();

// Check 2: Player started?
await player.start();

// Check 3: Source set?
await player.setVideoSource(LiveVideoSource(clientPtr));

// Check 4: Check player state
player.setStateChangeCallback((data, videoStatus, ...) {
  print("Video status: $videoStatus");
});
```

### High Latency

```dart
// Check connection path
// Prefer: LAN > P2P > Relay

// Reduce resolution
await device.changeResolution(VideoResolution.low);

// Check network
// WiFi 5GHz > 2.4GHz
// Ethernet > WiFi
```

---

## 📦 Project Structure

```
lib/
├── app_dart.dart              # FFI bindings
├── app_p2p_api.dart          # P2P API
├── app_player.dart           # Video player
├── basis_device.dart         # Base device
├── p2p_device/               # P2P layer
│   ├── p2p_device.dart
│   ├── p2p_connect.dart
│   └── p2p_command.dart
└── camera_device/            # Camera layer
    ├── camera_device.dart
    └── commands/             # Modular commands
        ├── ai_command.dart
        ├── alarm_command.dart
        ├── camera_command.dart
        └── ...
```

---

## 📚 Full Documentation Index

- **[README.md](./README.md)** - Start here
- **[01-ARCHITECTURE.md](./01-ARCHITECTURE.md)** - System architecture
- **[02-CONNECTION-FLOW.md](./02-CONNECTION-FLOW.md)** - Connection process
- **[03-VIDEO-STREAMING.md](./03-VIDEO-STREAMING.md)** - Video streaming
- **[04-BYPASS-CLOUD.md](./04-BYPASS-CLOUD.md)** - Bypass cloud servers
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - Complete examples
- **[11-FAQ.md](./11-FAQ.md)** - FAQ
- **[12-TROUBLESHOOTING.md](./12-TROUBLESHOOTING.md)** - Troubleshooting
- **[13-API-REFERENCE.md](./13-API-REFERENCE.md)** - API reference

---

## 🎓 Learning Path

### Beginner (1-2 days)
1. Read [README.md](./README.md)
2. Read [01-ARCHITECTURE.md](./01-ARCHITECTURE.md)
3. Run example app: `flutter-sdk-demo/example/`
4. Try [09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md) - Quick Start

### Intermediate (3-7 days)
1. Read [02-CONNECTION-FLOW.md](./02-CONNECTION-FLOW.md)
2. Read [03-VIDEO-STREAMING.md](./03-VIDEO-STREAMING.md)
3. Implement device binding
4. Implement live streaming
5. Add PTZ control

### Advanced (1-2 weeks)
1. Read [04-BYPASS-CLOUD.md](./04-BYPASS-CLOUD.md)
2. Implement self-host backend
3. Add cloud storage integration
4. Optimize performance
5. Add AI features
6. Production deployment

---

## 💡 Pro Tips

```
✅ Always dispose resources (player, device)
✅ Handle connection state changes
✅ Use try-catch for network operations
✅ Show loading indicators
✅ Provide user feedback (SnackBars)
✅ Log errors for debugging
✅ Test on real devices, not just simulator
✅ Test with poor network conditions
✅ Test with multiple cameras
✅ Profile memory & CPU usage
```

---

## 🚀 Production Checklist

```
□ Change default passwords
□ Implement proper error handling
□ Add logging & analytics
□ Test edge cases
□ Optimize performance
□ Add unit tests
□ Add integration tests
□ Security audit
□ Load testing
□ Documentation
□ User onboarding
□ Support system
□ Monitoring & alerts
□ Backup & recovery
□ CI/CD pipeline
```

---

**🎯 You're ready to build!**

*For detailed information, refer to the full documentation set.*

---

*Updated: 2024 | Version: 1.0*

