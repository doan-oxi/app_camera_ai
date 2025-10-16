# 🔌 VEEPAI SDK - QUY TRÌNH KẾT NỐI CAMERA

> **Hướng dẫn chi tiết từ khi mua camera về đến khi xem được live stream**

---

## 📖 Tổng Quan

Khi mua 1 camera Veepai về, bạn cần thực hiện **3 giai đoạn** để có thể xem được video:

```
┌─────────────────────────────────────────────────────────────┐
│ GIAI ĐOẠN 1: CẤU HÌNH MẠNG CHO CAMERA (5-10 phút)         │
│ • Camera chưa có WiFi → Cần cho camera biết WiFi nhà bạn   │
│ • 2 cách: Bluetooth hoặc QR Code                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ GIAI ĐOẠN 2: BIND DEVICE - LẤY DEVICE ID (30s - 1 phút)   │
│ • Camera kết nối WiFi → Đăng ký lên cloud                  │
│ • App lấy Device ID từ cloud                               │
│ • Lưu device vào app                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ GIAI ĐOẠN 3: KẾT NỐI P2P VÀ XEM LIVE (5-15 giây)         │
│ • Tạo P2P connection                                       │
│ • Login vào camera                                         │
│ • Bắt đầu stream video                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 GIAI ĐOẠN 1: CẤU HÌNH MẠNG CHO CAMERA

### Tại sao cần bước này?

```
Camera mới mua về → CHƯA CÓ THÔNG TIN WIFI
├─→ Camera không thể tự động kết nối internet
├─→ Camera không thể đăng ký lên cloud
└─→ App không thể tìm thấy camera

→ Cần "dạy" camera biết:
  • Tên WiFi (SSID)
  • Mật khẩu WiFi
  • Loại mã hóa (WPA2, etc.)
```

---

### PHƯƠNG ÁN A: Bluetooth Configuration ⭐ Khuyến nghị

**File code:** `example/lib/bluetooth_connect/bluetooth_connect_logic.dart`

#### Bước 1.1: Quét thiết bị Bluetooth

```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<void> scanBluetoothDevices() async {
  // Start scanning
  await FlutterBluePlus.startScan(
    timeout: Duration(seconds: 4),
    androidUsesFineLocation: true  // Required for Android
  );
  
  // Listen for results
  FlutterBluePlus.onScanResults.listen((results) {
    for (ScanResult r in results) {
      String deviceName = r.device.platformName;
      
      // Camera Veepai có tên:
      // • "IPC-XXXXXXX" (long-power cameras)
      // • "MC-XXXXXXX"  (low-power cameras)
      
      if (deviceName.startsWith("IPC-") || deviceName.startsWith("MC-")) {
        print("✅ Found camera: $deviceName");
        // Lưu device này để connect
        _foundCameras.add(r);
      }
    }
  });
}
```

**⚠️ Lưu ý:**
- Android cần permission: `BLUETOOTH`, `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`, `ACCESS_FINE_LOCATION`
- iOS cần: `NSBluetoothAlwaysUsageDescription` trong Info.plist

#### Bước 1.2: Kết nối Bluetooth

```dart
Future<BluetoothDevice> connectToCamera(ScanResult scanResult) async {
  BluetoothDevice camera = scanResult.device;
  
  // Kết nối
  await camera.connect(
    mtu: null,
    autoConnect: true,
    timeout: Duration(seconds: 15)
  );
  
  // Đợi connected
  var state = await camera.connectionState.firstWhere(
    (element) => 
      element == BluetoothConnectionState.connected ||
      element == BluetoothConnectionState.disconnected
  );
  
  if (state == BluetoothConnectionState.connected) {
    print("✅ Connected to camera via Bluetooth");
    return camera;
  } else {
    throw Exception("Failed to connect");
  }
}
```

#### Bước 1.3: Tìm Bluetooth Service & Characteristic

```dart
Future<BluetoothCharacteristic> findWiFiCharacteristic(
  BluetoothDevice camera
) async {
  // Discover services
  List<BluetoothService> services = await camera.discoverServices();
  
  // Tìm service có UUID = "FFF0"
  BluetoothService? service = services.firstWhereOrNull(
    (s) => s.uuid.toString().toUpperCase() == "FFF0"
  );
  
  if (service == null) {
    throw Exception("WiFi service not found");
  }
  
  // Tìm characteristic có UUID = "FFF1"
  BluetoothCharacteristic? characteristic = 
    service.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString().toUpperCase() == "FFF1"
    );
  
  if (characteristic == null) {
    throw Exception("WiFi characteristic not found");
  }
  
  return characteristic;
}
```

#### Bước 1.4: Chuẩn bị dữ liệu WiFi

```dart
import 'package:vsdk_example/utils/blue_package.dart';

Uint8List prepareWiFiData({
  required String ssid,       // Tên WiFi
  required String password,   // Mật khẩu
  required String userId,     // User ID (e.g. "15463733-OEM")
}) {
  // BluePackage.toData() mã hóa thông tin WiFi theo format camera hiểu
  Uint8List wifiData = BluePackage.toData(
    userId,      // "15463733-OEM"
    ssid,        // "MyHomeWiFi"
    password,    // "password123"
    1            // Encryption type: 1 = WPA2
  ).buffer.asUint8List();
  
  return wifiData;
}
```

#### Bước 1.5: Gửi WiFi credentials qua Bluetooth

```dart
Future<bool> sendWiFiCredentials({
  required BluetoothCharacteristic characteristic,
  required Uint8List wifiData,
}) async {
  // Enable notifications để nhận phản hồi
  await characteristic.setNotifyValue(true);
  
  // Chuẩn bị 2 packets
  // Packet 1: 0xF0F0 + first 118 bytes
  List<int> packet1 = [0xF0, 0xF0];
  packet1.addAll(wifiData.sublist(0, 118));
  
  // Packet 2: 0xF0F1 + remaining bytes
  List<int> packet2 = [0xF0, 0xF1];
  packet2.addAll(wifiData.sublist(118, wifiData.length));
  
  print("📤 Sending packet 1 (${packet1.length} bytes)...");
  await characteristic.write(packet1);
  
  // Đợi camera xác nhận packet 1
  await _waitForResponse(characteristic, 0xF0, 0xF0);
  
  print("📤 Sending packet 2 (${packet2.length} bytes)...");
  await characteristic.write(packet2);
  
  // Đợi camera xác nhận packet 2
  await _waitForResponse(characteristic, 0xF0, 0xF1);
  
  print("✅ WiFi credentials sent successfully");
  return true;
}
```

#### Bước 1.6: Nhận kết quả cấu hình

```dart
Future<WiFiConfigResult> _waitForResponse(
  BluetoothCharacteristic characteristic,
  int expectedByte1,
  int expectedByte2,
) async {
  Completer<WiFiConfigResult> completer = Completer();
  
  // Listen for camera response
  StreamSubscription? subscription;
  subscription = characteristic.onValueReceived.listen((data) {
    if (data.length < 3) return;
    
    print("📥 Received: [${data[0]}, ${data[1]}, ${data[2]}]");
    
    // Check header
    if (data[0] == 0xF0 && data[1] == 0xF0) {
      // Camera đã nhận packet 1
      print("✅ Camera confirmed packet 1");
    } 
    else if (data[0] == 0xF0 && data[1] == 0xF1) {
      // Camera đã nhận packet 2
      print("✅ Camera confirmed packet 2");
    }
    else if (data[0] == 0xF0 && data[1] == 0xF2) {
      // Kết quả cấu hình WiFi
      int resultCode = data[2];
      
      switch (resultCode) {
        case 1:
          print("✅ WiFi connected successfully!");
          completer.complete(WiFiConfigResult.success);
          break;
        case 2:
          print("❌ Wrong WiFi password");
          completer.complete(WiFiConfigResult.wrongPassword);
          break;
        case 3:
          print("❌ Connection timeout");
          completer.complete(WiFiConfigResult.timeout);
          break;
        case 4:
          print("❌ DHCP failed");
          completer.complete(WiFiConfigResult.dhcpFailed);
          break;
        case 5:
          print("❌ Gateway config failed");
          completer.complete(WiFiConfigResult.gatewayFailed);
          break;
        case 6:
          print("❌ DNS config failed");
          completer.complete(WiFiConfigResult.dnsFailed);
          break;
        default:
          print("❌ Unknown error: $resultCode");
          completer.complete(WiFiConfigResult.unknown);
      }
      
      subscription?.cancel();
    }
  });
  
  // Timeout sau 30 giây
  return completer.future.timeout(
    Duration(seconds: 30),
    onTimeout: () => WiFiConfigResult.timeout
  );
}

enum WiFiConfigResult {
  success,
  wrongPassword,
  timeout,
  dhcpFailed,
  gatewayFailed,
  dnsFailed,
  unknown,
}
```

#### Code hoàn chỉnh - Bluetooth Config

```dart
Future<bool> configureCameraWiFiViaBluetooth({
  required String ssid,
  required String password,
}) async {
  try {
    // 1. Scan for camera
    print("🔍 Scanning for camera...");
    await scanBluetoothDevices();
    
    if (_foundCameras.isEmpty) {
      print("❌ No camera found");
      return false;
    }
    
    // 2. Connect to camera
    print("🔗 Connecting to camera...");
    BluetoothDevice camera = await connectToCamera(_foundCameras[0]);
    
    // 3. Find WiFi characteristic
    print("🔍 Finding WiFi service...");
    BluetoothCharacteristic char = await findWiFiCharacteristic(camera);
    
    // 4. Prepare WiFi data
    print("📝 Preparing WiFi credentials...");
    Uint8List wifiData = prepareWiFiData(
      ssid: ssid,
      password: password,
      userId: "15463733-OEM"  // Replace with your user ID
    );
    
    // 5. Send credentials
    print("📤 Sending WiFi credentials...");
    await sendWiFiCredentials(
      characteristic: char,
      wifiData: wifiData
    );
    
    // 6. Wait for result
    print("⏳ Waiting for camera to connect WiFi...");
    WiFiConfigResult result = await _waitForFinalResult(char);
    
    // 7. Disconnect bluetooth
    await camera.disconnect();
    
    if (result == WiFiConfigResult.success) {
      print("✅ Camera connected to WiFi successfully!");
      return true;
    } else {
      print("❌ WiFi config failed: $result");
      return false;
    }
    
  } catch (e) {
    print("❌ Error: $e");
    return false;
  }
}
```

---

### PHƯƠNG ÁN B: QR Code Configuration

**File code:** `example/lib/wifi_connect/device_connect_logic.dart`

#### Cách hoạt động

```
1. App lấy thông tin WiFi hiện tại (SSID, BSSID)
2. App tạo QR code chứa:
   {
     "BS": "MAC_address_router",  // BSSID (không dấu :)
     "P": "password",
     "U": "user_id",
     "RS": "wifi_name"             // SSID
   }
3. User giữ camera trước màn hình (10-20cm)
4. Camera quét QR, đọc thông tin, kết nối WiFi
```

#### Code Implementation

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WiFiQRConfig {
  String? ssid;
  String? bssid;  // MAC address của router
  
  Future<bool> getWiFiInfo() async {
    // Check if connected to WiFi
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.wifi) {
      print("❌ Not connected to WiFi");
      return false;
    }
    
    final info = NetworkInfo();
    
    // Get WiFi name (SSID)
    String? wifiName = await info.getWifiName();
    if (wifiName != null) {
      // Remove quotes if present
      ssid = wifiName.replaceAll('"', '');
    }
    
    // Get router MAC address (BSSID)
    String? wifiBSSID = await info.getWifiBSSID();
    if (wifiBSSID != null) {
      // Remove colons: "e0:d4:62:e6:63:b0" → "e0d462e663b0"
      bssid = wifiBSSID.replaceAll(':', '');
    }
    
    if (ssid != null && bssid != null) {
      print("✅ WiFi Info:");
      print("  SSID: $ssid");
      print("  BSSID: $bssid");
      return true;
    }
    
    return false;
  }
  
  String generateQRData({required String password}) {
    return json.encode({
      "BS": bssid,           // Router MAC
      "P": password,         // WiFi password
      "U": "15463733-OEM",   // User ID
      "RS": ssid             // WiFi name
    });
  }
  
  Widget buildQRCodeWidget({
    required String password,
    double size = 300,
  }) {
    String qrData = generateQRData(password: password);
    
    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }
}
```

#### UI Example

```dart
class QRConfigPage extends StatefulWidget {
  @override
  _QRConfigPageState createState() => _QRConfigPageState();
}

class _QRConfigPageState extends State<QRConfigPage> {
  WiFiQRConfig config = WiFiQRConfig();
  TextEditingController passwordController = TextEditingController();
  bool showQR = false;
  
  @override
  void initState() {
    super.initState();
    _loadWiFiInfo();
  }
  
  Future<void> _loadWiFiInfo() async {
    bool success = await config.getWiFiInfo();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please connect to WiFi first"))
      );
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Code Configuration")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            if (config.ssid != null) ...[
              Text("Current WiFi: ${config.ssid}"),
              SizedBox(height: 20),
              
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "WiFi Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              
              if (!showQR)
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter password"))
                      );
                      return;
                    }
                    setState(() {
                      showQR = true;
                    });
                    _startQuerying();  // Start querying for device
                  },
                  child: Text("Generate QR Code"),
                ),
              
              if (showQR) ...[
                Text(
                  "Point camera at this QR code",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                
                config.buildQRCodeWidget(
                  password: passwordController.text,
                  size: 250,
                ),
                SizedBox(height: 20),
                
                Text("Keep camera 10-20cm from screen"),
                SizedBox(height: 10),
                CircularProgressIndicator(),
              ],
            ] else
              Center(child: Text("Connecting to WiFi info...")),
          ],
        ),
      ),
    );
  }
  
  // Query cho device đã kết nối WiFi
  void _startQuerying() {
    // See next section for device binding
  }
}
```

---

## 🔗 GIAI ĐOẠN 2: DEVICE BINDING - LẤY DEVICE ID

### Tại sao cần bước này?

```
Camera đã kết nối WiFi thành công
├─→ Camera tự động đăng ký lên cloud: hello.eye4.cn
├─→ Cloud sinh ra VIRTUAL ID (VID) cho camera
├─→ App cần query VID này để biết camera nào vừa kết nối
└─→ Lưu VID vào app để kết nối lần sau
```

### Cloud Servers & APIs

```
┌────────────────────────────────────────────────────────┐
│ Server: https://api.eye4.cn                            │
├────────────────────────────────────────────────────────┤
│ POST /hello/confirm                                    │
│   - Clear previous binding                             │
│   - Body: { "key": "YOUR_USER_ID_binding" }          │
│                                                        │
│ POST /hello/query                                      │
│   - Query device ID                                    │
│   - Body: { "key": "YOUR_USER_ID_binding" }          │
│   - Response: { "value": "URL_ENCODED_JSON" }        │
└────────────────────────────────────────────────────────┘
```

### Device Registration Process (Camera Side)

```
Camera vừa kết nối WiFi
        ↓
┌───────────────────────────────────────────────┐
│ Camera gửi thông tin lên hello.eye4.cn       │
│ Data: {                                       │
│   "realDeviceId": "VSTC123456ABCDEF",       │
│   "userId": "15463733-OEM",                  │
│   "model": "QW6-T",                          │
│   "firmwareVersion": "10.62.120.456"         │
│ }                                             │
└───────────────────┬───────────────────────────┘
                    ↓
┌───────────────────────────────────────────────┐
│ Cloud xử lý & tạo Virtual ID                 │
│ • Check if device đã tồn tại                 │
│ • Generate Virtual ID: "VE0005622QHOW"       │
│ • Map: Virtual ID → Real Device ID           │
│ • Store metadata                             │
└───────────────────┬───────────────────────────┘
                    ↓
┌───────────────────────────────────────────────┐
│ Cloud response 3 giai đoạn:                  │
│                                               │
│ 1. C2Net (Camera to Network)                 │
│    Status: 1 = Success                       │
│    → Camera đã kết nối internet              │
│                                               │
│ 2. R2SVR (Register to Server)                │
│    Status: 1 = Success                       │
│    → Camera đã đăng ký cloud                 │
│                                               │
│ 3. B2SVR (Bind to Server)                    │
│    Status: 1 = Success                       │
│    → Binding hoàn tất                        │
└───────────────────────────────────────────────┘
```

### App Query Process

#### Bước 2.1: Clear previous binding

```dart
Future<void> clearPreviousBinding(String userId) async {
  try {
    await dio.post(
      "https://api.eye4.cn/hello/confirm",
      data: {"key": "${userId}_binding"}
    );
    print("✅ Cleared previous binding");
  } catch (e) {
    print("Error clearing binding: $e");
  }
}
```

#### Bước 2.2: Query device ID (with retry)

```dart
Future<String?> queryDeviceId({
  required String userId,
  int maxAttempts = 30,  // Tối đa 30 lần
  Duration interval = const Duration(seconds: 2),
}) async {
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    print("🔍 Query attempt $attempt/$maxAttempts...");
    
    try {
      // Query theo lượt: old device / new device
      String? deviceId;
      if (attempt % 2 == 0) {
        // Query old device format
        deviceId = await _queryOldDevice(userId);
      } else {
        // Query new device format
        deviceId = await _queryNewDevice(userId);
      }
      
      if (deviceId != null) {
        print("✅ Found device: $deviceId");
        return deviceId;
      }
      
    } catch (e) {
      print("Query error: $e");
    }
    
    // Wait before next attempt
    if (attempt < maxAttempts) {
      await Future.delayed(interval);
    }
  }
  
  print("❌ Timeout: No device found after $maxAttempts attempts");
  return null;
}
```

#### Bước 2.3: Parse response

```dart
// Old device format (simple)
Future<String?> _queryOldDevice(String userId) async {
  var response = await dio.post(
    "https://api.eye4.cn/hello/query",
    data: {"key": userId}
  );
  
  if (response.statusCode == 200 && response.data["value"] != null) {
    String deviceId = response.data["value"];
    return deviceId;  // Direct device ID
  }
  
  return null;
}

// New device format (with status)
Future<String?> _queryNewDevice(String userId) async {
  var response = await dio.post(
    "https://api.eye4.cn/hello/query",
    data: {"key": "${userId}_binding"}
  );
  
  if (response.statusCode == 200 && response.data["value"] != null) {
    // Decode URL-encoded JSON
    String encodedData = response.data["value"];
    String jsonString = Uri.decodeComponent(encodedData);
    
    Map<String, dynamic> data = json.decode(jsonString);
    
    /*
    Format:
    {
      "vuid": "VE0005622QHOW",
      "timestamp": 1703728593,
      "userid": "15463733-OEM",
      "C2Net": {
        "TStep": 1,
        "CStep": 1,
        "FCode": 4097,
        "Status": 1,
        "Ecode": 0
      }
    }
    */
    
    // Check C2Net status
    if (data["C2Net"] != null) {
      int status = data["C2Net"]["Status"];
      if (status == 1) {
        String deviceId = data["vuid"];
        return deviceId;
      } else {
        int errorCode = data["C2Net"]["Ecode"];
        print("C2Net failed: $errorCode");
      }
    }
    
    // Check R2SVR status
    if (data["R2SVR"] != null) {
      int status = data["R2SVR"]["Status"];
      if (status == 1) {
        String deviceId = data["vuid"];
        return deviceId;
      }
    }
    
    // Check B2SVR status (final)
    if (data["B2SVR"] != null) {
      int status = data["B2SVR"]["Status"];
      if (status == 1) {
        String deviceId = data["vuid"];
        return deviceId;
      }
    }
  }
  
  return null;
}
```

#### Bước 2.4: Validate device ID

```dart
bool validateDeviceId(String deviceId) {
  // Supported prefixes
  final supportedPrefixes = [
    "VSTC", "VSTG", "VSGG", "VSKK", "VSTD", "VSTF",
    "VSTB", "VSTA", "VSTH", "VSTJ", "VSTK", "VSTL",
    "VSTM", "VSTN", "VSTP", "VE", "VC", // etc.
  ];
  
  String prefix = deviceId.substring(0, 4);
  
  if (!supportedPrefixes.contains(prefix)) {
    print("⚠️ Unknown device prefix: $prefix");
    return false;
  }
  
  return true;
}
```

#### Bước 2.5: Save device to local storage

```dart
import 'package:shared_preferences/shared_preferences.dart';

class DeviceListManager {
  static DeviceListManager? _instance;
  static DeviceListManager getInstance() {
    _instance ??= DeviceListManager();
    return _instance!;
  }
  
  Future<void> saveDevice(String deviceId, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load existing devices
    String? devicesJson = prefs.getString('devices');
    List<Map<String, dynamic>> devices = [];
    
    if (devicesJson != null) {
      devices = List<Map<String, dynamic>>.from(
        json.decode(devicesJson)
      );
    }
    
    // Add new device
    devices.add({
      'deviceId': deviceId,
      'password': password,
      'name': 'Camera ${devices.length + 1}',
      'addedAt': DateTime.now().toIso8601String(),
    });
    
    // Save back
    await prefs.setString('devices', json.encode(devices));
    
    print("✅ Device saved: $deviceId");
  }
  
  Future<List<Map<String, dynamic>>> getDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? devicesJson = prefs.getString('devices');
    
    if (devicesJson == null) return [];
    
    return List<Map<String, dynamic>>.from(json.decode(devicesJson));
  }
}
```

---

## 🎬 GIAI ĐOẠN 3: KẾT NỐI P2P VÀ XEM LIVE

Chi tiết về giai đoạn này xem tại:
- **[03-VIDEO-STREAMING.md](./03-VIDEO-STREAMING.md)** - Video streaming
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - Code examples

### Quick Overview

```dart
// 1. Create device
CameraDevice device = CameraDevice(
  deviceId,      // "VE0005622QHOW"
  "Living Room",
  "admin",
  "888888",
  "QW6-T"
);

// 2. Connect
CameraConnectState state = await device.connect();

// 3. Create player
AppPlayerController player = AppPlayerController();
await player.create();

// 4. Set source
await player.setVideoSource(LiveVideoSource(clientPtr));

// 5. Start stream
await device.startStream(resolution: VideoResolution.high);
await player.start();

// Done! Video playing
```

---

## 📊 Complete Flow Diagram

```
USER MUA CAMERA MỚI
        │
        ↓
┌───────────────────────────────────────────────┐
│ 1. CẤU HÌNH MẠNG (Choose one)                 │
├───────────────────────────────────────────────┤
│ A. Bluetooth Route:                            │
│    1.1 Scan BLE devices                       │
│    1.2 Connect to camera                      │
│    1.3 Find WiFi characteristic               │
│    1.4 Send WiFi credentials (2 packets)      │
│    1.5 Wait for 0xF0F2 response              │
│                                                │
│ B. QR Code Route:                             │
│    1.1 Get phone's WiFi info                  │
│    1.2 Generate QR code                       │
│    1.3 Show QR on screen                      │
│    1.4 Camera scans & connects               │
└───────────────────┬───────────────────────────┘
                    │
                    ↓
┌───────────────────────────────────────────────┐
│ 2. DEVICE BINDING                             │
├───────────────────────────────────────────────┤
│ Camera Side:                                  │
│  • Camera connects to internet                │
│  • Registers to hello.eye4.cn                 │
│  • Reports: C2Net → R2SVR → B2SVR            │
│                                                │
│ App Side:                                     │
│  • Clear previous: POST /hello/confirm        │
│  • Query every 2s: POST /hello/query          │
│  • Check C2Net/R2SVR/B2SVR status            │
│  • Extract Virtual ID (VID)                   │
│  • Validate device prefix                     │
│  • Save to local storage                      │
└───────────────────┬───────────────────────────┘
                    │
                    ↓
┌───────────────────────────────────────────────┐
│ 3. P2P CONNECTION & LOGIN                     │
├───────────────────────────────────────────────┤
│ 3.1 Initialize Device                         │
│     CameraDevice(vid, name, pwd)              │
│                                                │
│ 3.2 Resolve Virtual ID → Real ID              │
│     Query: https://vuid.eye4.cn               │
│                                                │
│ 3.3 Get Service Parameters                    │
│     Query: https://authentication.eye4.cn     │
│                                                │
│ 3.4 Create P2P Client                         │
│     Native: clientCreate(realId)              │
│                                                │
│ 3.5 Establish P2P Connection                  │
│     Try: LAN → P2P → Relay                    │
│                                                │
│ 3.6 Login to Camera                           │
│     CGI: login.cgi?user=admin&pwd=888888     │
│                                                │
│ 3.7 Get Device Status                         │
│     CGI: get_status.cgi                       │
└───────────────────┬───────────────────────────┘
                    │
                    ↓
┌───────────────────────────────────────────────┐
│ 4. LIVE STREAMING                             │
├───────────────────────────────────────────────┤
│ 4.1 Create Player                             │
│     player.create()                           │
│                                                │
│ 4.2 Set Video Source                          │
│     player.setVideoSource(LiveVideoSource)    │
│                                                │
│ 4.3 Request Stream                             │
│     CGI: livestream.cgi?streamid=10           │
│                                                │
│ 4.4 Start Playback                            │
│     player.start()                            │
│                                                │
│ 4.5 Video Data Flow                           │
│     Camera → P2P → Decoder → Texture → Screen│
└───────────────────────────────────────────────┘
        │
        ↓
    ✅ SUCCESS!
  User xem được live video
```

---

## ⏱️ Thời Gian Ước Tính

```
┌────────────────────────────────────────────────────┐
│ Giai đoạn              │ Thời gian (typical)       │
├────────────────────────────────────────────────────┤
│ 1. WiFi Config (BT)    │ 5-10 phút                 │
│ 1. WiFi Config (QR)    │ 2-5 phút                  │
│ 2. Device Binding      │ 30s - 1 phút              │
│ 3. P2P Connection      │ 5-15 giây                 │
│ 4. Live Streaming      │ 2-5 giây (first frame)    │
├────────────────────────────────────────────────────┤
│ TỔNG (lần đầu)         │ 8-16 phút                 │
│ TỔNG (lần sau)         │ 10-20 giây                │
└────────────────────────────────────────────────────┘
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Bluetooth scan không thấy camera

```
Nguyên nhân:
• Camera chưa reset về factory
• Camera đã có WiFi (không ở chế độ pairing)
• App thiếu permissions

Giải pháp:
1. Reset camera (giữ nút reset 10s)
2. Đèn LED camera phải nhấp nháy (pairing mode)
3. Check permissions: Bluetooth, Location
4. Thử tắt/bật Bluetooth
```

### Issue 2: QR code không được scan

```
Nguyên nhân:
• QR quá nhỏ hoặc quá mờ
• Khoảng cách không phù hợp
• Độ sáng màn hình thấp

Giải pháp:
1. Tăng size QR code (250-300dp)
2. Giữ camera cách màn hình 10-20cm
3. Tăng độ sáng màn hình 100%
4. Giữ camera vuông góc với màn hình
```

### Issue 3: Query device timeout

```
Nguyên nhân:
• Camera chưa kết nối WiFi thành công
• Camera chưa đăng ký cloud
• WiFi không có internet
• Server cloud bị lỗi

Giải pháp:
1. Check camera LED: Xanh liên tục = đã kết nối
2. Tăng maxAttempts lên 60 (2 phút)
3. Check router có internet không
4. Thử reset camera và làm lại
```

### Issue 4: P2P connection failed

```
Nguyên nhân:
• Virtual ID không hợp lệ
• Service parameters không đúng
• Firewall/NAT blocking
• Device offline

Giải pháp:
1. Validate device ID prefix
2. Check service param trong _serviceMap
3. Thử connect type khác: 0x7E, 0x7B
4. Check camera online: query wakeup status
```

---

## 📚 Next Steps

- **[03-VIDEO-STREAMING.md](./03-VIDEO-STREAMING.md)** - Chi tiết về video streaming
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - Complete code examples
- **[12-TROUBLESHOOTING.md](./12-TROUBLESHOOTING.md)** - Troubleshooting guide

---

*Updated: 2024 | Version: 1.0*

