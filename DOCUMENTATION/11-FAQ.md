# ❓ VEEPAI SDK - FAQ (Frequently Asked Questions)

> **Câu hỏi thường gặp và câu trả lời chi tiết**

---

## 🎯 General Questions

### Q1: SDK này dùng để làm gì?

**A:** Veepai SDK là Flutter plugin để:
- Kết nối và điều khiển camera Veepai qua P2P
- Xem live stream real-time (< 500ms latency)
- Playback video từ TF card hoặc cloud storage
- Điều khiển PTZ (Pan-Tilt-Zoom)
- Cấu hình AI features (human detection, tracking, framing)
- Quản lý alarm và notifications
- Hỗ trợ multi-sensor cameras (2-4 cameras)

---

### Q2: Backend của tôi có xử lý video không?

**A:** ❌ KHÔNG! Video không đi qua backend.

```
Camera → P2P → App  (Video đi trực tiếp)
   ↓
Your Backend  (Chỉ metadata, authentication)
```

Backend chỉ cần:
- Device binding API
- User authentication
- Cloud storage URLs (optional)
- Push notifications (optional)

→ **Chi phí rất thấp**, không cần infrastructure cho video

---

### Q3: Tôi có thể tự host backend không?

**A:** ✅ CÓ! Có nhiều phương án:

1. **AP Mode**: Zero cloud, hoàn toàn offline
2. **Self-Host Backend**: Tự implement binding/auth APIs
3. **Use Real Device ID**: Skip virtual ID resolution
4. **Pure Offline**: Chỉ hoạt động trên LAN

Xem chi tiết: [04-BYPASS-CLOUD.md](./04-BYPASS-CLOUD.md)

---

### Q4: SDK này có free không?

**A:** 
- ✅ **SDK**: FREE (mã nguồn có sẵn)
- ✅ **P2P bandwidth**: FREE (direct connection)
- ⚠️ **Cloud storage**: TRẢ PHÍ (nếu dùng cloud Veepai)
- ⚠️ **AI cloud**: TRẢ PHÍ (nếu dùng cloud AI)

Nếu tự host backend và không dùng cloud storage → **Hoàn toàn miễn phí**

---

### Q5: Hỗ trợ platform nào?

**A:**
- ✅ **Flutter**: SDK chính
- ✅ **Android**: 5.0+ (API level 21+)
- ✅ **iOS**: 11.0+
- ❌ **Web**: Chưa hỗ trợ (native libraries)
- ❌ **Desktop**: Chưa hỗ trợ chính thức

---

## 🔌 Connection Questions

### Q6: Camera mới mua về, làm sao kết nối?

**A:** 3 giai đoạn:

1. **WiFi Config** (5-10 phút)
   - Bluetooth hoặc QR code
   - Camera kết nối WiFi nhà bạn

2. **Device Binding** (30 giây)
   - Camera đăng ký cloud
   - App lấy device ID

3. **P2P Connection** (5-15 giây)
   - App kết nối camera qua P2P
   - Xem live stream

Chi tiết: [02-CONNECTION-FLOW.md](./02-CONNECTION-FLOW.md)

---

### Q7: Bluetooth config vs QR code, chọn cái nào?

**A:**

**Bluetooth** (Khuyến nghị):
- ✅ Nhanh hơn (5 phút)
- ✅ Reliable hơn
- ✅ Không cần độ sáng màn hình
- ❌ Cần permissions nhiều hơn

**QR Code**:
- ✅ Đơn giản hơn (không cần BLE library)
- ✅ Ít permissions hơn
- ❌ Cần độ sáng màn hình cao
- ❌ Cần giữ camera đúng góc độ

→ **Khuyến nghị**: Hỗ trợ cả 2, ưu tiên Bluetooth

---

### Q8: P2P connection lâu, tại sao?

**A:** P2P connection thử 3 paths:

1. **LAN** (50-150ms) - Cùng WiFi
2. **P2P Direct** (3-5s) - NAT traversal
3. **Relay** (10-15s) - Qua relay server

Nếu lâu → Có thể NAT phức tạp → Fallback về relay

**Tối ưu:**
```dart
// Skip LAN scan nếu chắc chắn không cùng mạng
await device.connect(lanScan: false);

// Hoặc force P2P direct
await device.connect(connectType: 0x7E);
```

---

### Q9: Camera offline, làm sao check?

**A:**

```dart
// Method 1: Check via wakeup server
bool isOnline = await device.checkDeviceOnline();

// Method 2: Check connect state
var state = await device.connect();
if (state == CameraConnectState.offline) {
  print("Camera offline");
}

// Method 3: Query device status from cloud
// (if using Veepai cloud)
var status = await DeviceCloudAPI.queryDeviceStatus(deviceId);
```

---

## 📹 Video Streaming Questions

### Q10: Latency cao, làm sao giảm?

**A:** Optimize theo thứ tự:

1. **Check connection path**
   ```dart
   // Force LAN if on same network
   await device.connect(lanScan: true, connectType: 0x7F);
   ```

2. **Giảm resolution**
   ```dart
   await device.startStream(resolution: VideoResolution.general); // 720p
   ```

3. **Reduce buffer**
   ```dart
   // Modify native player buffer settings
   player.setBufferTime(500); // 0.5 second
   ```

4. **Check network**
   - WiFi 5GHz tốt hơn 2.4GHz
   - Ethernet tốt hơn WiFi
   - Check ping: `ping camera_ip`

---

### Q11: Video bị lag/stutter, tại sao?

**A:** Nguyên nhân có thể:

1. **Network bandwidth không đủ**
   - Check: Latency cao, packet loss
   - Fix: Giảm resolution

2. **Device hardware yếu**
   - Check: CPU usage > 80%
   - Fix: Close other apps, enable hardware decoding

3. **Camera overloaded**
   - Check: Nhiều user cùng xem
   - Fix: Disconnect other users

4. **Buffer issues**
   - Check: Load state = buffering
   - Fix: Increase buffer size

---

### Q12: Có thể xem nhiều camera cùng lúc không?

**A:** ✅ CÓ!

```dart
List<CameraDevice> cameras = [];
List<AppPlayerController> players = [];

// Create 4 cameras
for (int i = 0; i < 4; i++) {
  var device = CameraDevice(deviceIds[i], ...);
  await device.connect();
  cameras.add(device);
  
  var player = AppPlayerController();
  await player.create();
  await player.setVideoSource(LiveVideoSource(device.clientPtr));
  await device.startStream(resolution: VideoResolution.low); // Use low res
  await player.start();
  players.add(player);
}

// Display in grid
GridView.count(
  crossAxisCount: 2,
  children: players.map((p) => AppPlayerView(controller: p)).toList(),
);
```

**Lưu ý:**
- Dùng low resolution (360p) để tiết kiệm bandwidth
- Max 9 cameras (hardware limitation)
- Cần device mạnh (CPU, RAM)

---

## 🎮 PTZ & Control Questions

### Q13: Làm sao biết camera hỗ trợ PTZ?

**A:**

```dart
// After connected, check status
StatusResult status = await device.getStatus();

if (status.isPTZ) {
  print("✅ Camera supports PTZ");
  print("Can rotate: ${status.canRotate}");
  print("Can tilt: ${status.canTilt}");
  print("Can zoom: ${status.canZoom}");
} else {
  print("❌ Fixed camera, no PTZ");
}
```

---

### Q14: PTZ không hoạt động, tại sao?

**A:** Check các điều kiện:

1. **Camera có hỗ trợ PTZ không?**
   ```dart
   if (device.motorCommand == null) {
     print("Camera không hỗ trợ PTZ");
   }
   ```

2. **Privacy mode có đang bật không?**
   ```dart
   bool inPrivacy = await device.cameraCommand!.privacyPosition!.checkPrivacyPosition();
   if (inPrivacy) {
     print("Camera đang ở privacy mode, disable để dùng PTZ");
   }
   ```

3. **Camera có đang sleep không?**
   ```dart
   if (device.status.isLowPower && device.status.isSleep) {
     await device.wakeup();
   }
   ```

---

## 🤖 AI Features Questions

### Q15: AI features xử lý ở đâu?

**A:** ✅ **On-device** (trên camera)!

```
Camera NPU/AI Chip
    ↓
Process video (human detection, tracking)
    ↓
Send results to app
```

**KHÔNG** cần:
- Cloud AI processing
- Upload video lên server
- Subscription AI services

→ Privacy tốt, latency thấp, FREE!

---

### Q16: Camera nào hỗ trợ AI features?

**A:** Check model:

```
✅ Hỗ trợ AI:
  • QW6-T series
  • Models with "AI" suffix
  • Firmware 10.62+ 

❌ Không hỗ trợ:
  • Older models
  • Budget cameras
```

Kiểm tra:
```dart
StatusResult status = await device.getStatus();
if (status.aiSupported) {
  print("✅ AI features available");
}
```

---

## 💾 Storage Questions

### Q17: TF card playback không thấy file, tại sao?

**A:** Check:

1. **Có TF card không?**
   ```dart
   CardStatus card = await device.getCardStatus();
   if (card.status == 0) {
     print("❌ No TF card inserted");
   }
   ```

2. **Card có bị lỗi không?**
   ```dart
   if (card.status == 2) {
     print("⚠️ TF card error, reformat needed");
   }
   ```

3. **Có recording không?**
   ```dart
   List<CardFileInfo> files = await device.getCardFileList(
     startTime: DateTime.now().subtract(Duration(days: 7)),
     endTime: DateTime.now(),
   );
   
   if (files.isEmpty) {
     print("No recordings in date range");
   }
   ```

4. **Recording có enable không?**
   ```dart
   RecordParam param = await device.getRecordParam();
   if (!param.recordEnable) {
     await device.setRecordEnable(true);
   }
   ```

---

### Q18: Cloud storage URLs lấy ở đâu?

**A:** 

**Option 1: Veepai Cloud API**
```dart
// POST https://open.eye4.cn/D004/file/url
var response = await dio.post(
  "https://open.eye4.cn/D004/file/url",
  data: {
    "deviceId": device.id,
    "startTime": startTime,
    "endTime": endTime,
  },
  headers: {
    "accessKey": "YOUR_ACCESS_KEY",
    "sign": calculateSign(...),
  }
);

List<String> urls = response.data["urls"];
```

**Option 2: Self-hosted**
```dart
// Your backend API
var response = await dio.post(
  "https://your-backend.com/api/cloud/urls",
  data: {
    "deviceId": device.id,
    "startTime": startTime,
    "endTime": endTime,
  }
);

List<String> urls = response.data["urls"];
// URLs point to your S3/MinIO
```

---

## 🔐 Security Questions

### Q19: Video có được mã hóa không?

**A:** ✅ CÓ!

- **P2P connection**: AES-128 encryption
- **Service param**: Encrypted credentials
- **HTTPS APIs**: TLS 1.2+
- **Cloud storage**: Server-side encryption

→ Đủ an toàn cho hầu hết use cases

---

### Q20: Làm sao thay đổi password camera?

**A:**

```dart
await device.passwordCommand!.changePassword(
  oldPassword: "888888",
  newPassword: "NewSecure123!"
);

// Update locally
device.password = "NewSecure123!";

// Save to storage
await DeviceListManager.getInstance().updateDevice(
  device.id, 
  newPassword: "NewSecure123!"
);
```

**Lưu ý:**
- Password phải 6-12 ký tự
- Không nên dùng password mặc định "888888"
- Backup password, mất password = phải reset camera

---

## 🛠️ Development Questions

### Q21: Làm sao test mà không có camera thật?

**A:** Một số phương án:

1. **Mock classes**
   ```dart
   class MockCameraDevice extends CameraDevice {
     @override
     Future<CameraConnectState> connect() async {
       await Future.delayed(Duration(seconds: 2));
       return CameraConnectState.connected;
     }
   }
   ```

2. **Simulator mode trong SDK** (nếu có)
   ```dart
   CameraDevice.enableSimulatorMode(true);
   ```

3. **Mua 1 camera rẻ để dev**
   - ~$20-50 trên Alibaba/AliExpress
   - Search "Veepai camera" hoặc model tương thích

4. **Dùng demo device** (nếu vendor cung cấp)

---

### Q22: Có unit tests không?

**A:** ⚠️ SDK này **thiếu unit tests**

→ Bạn nên tự viết tests cho app:

```dart
testWidgets('Device connection test', (WidgetTester tester) async {
  var device = MockCameraDevice(...);
  
  var state = await device.connect();
  
  expect(state, CameraConnectState.connected);
});
```

Xem: [10-BEST-PRACTICES.md](./10-BEST-PRACTICES.md) - Testing section

---

## 💰 Cost Questions

### Q23: Chi phí khi self-host backend?

**A:** Ước tính:

```
Infrastructure:
├─ VPS (2GB RAM, 2 vCPU): $10-20/month
├─ Domain + SSL: $15/year
├─ S3/MinIO storage: $0.023/GB/month
└─ Total: ~$15-30/month

Development:
├─ Backend API: 5-10 giờ dev
├─ Testing: 2-5 giờ
└─ Total: ~$500-1000 (one-time)

Maintenance:
└─ ~2 giờ/tháng → $50-100/month
```

So với dùng cloud Veepai:
- Cloud storage: $5-20/device/month
- 10 cameras = $50-200/month
- Self-host = $30/month **bất kể số lượng camera**

→ Self-host **rẻ hơn** nếu > 5 cameras

---

### Q24: Có giới hạn số lượng cameras không?

**A:**

**Technical limits:**
- P2P connections: Unlimited (theory)
- Concurrent streams: 9 cameras (SDK limitation)
- Backend: Unlimited (tùy infrastructure)

**Practical limits:**
- Network bandwidth: ~3 Mbps/camera (1080p)
- Device RAM: ~50 MB/camera
- CPU: ~10-15%/camera

**Example:**
- 1080p × 4 cameras = 12 Mbps = OK cho WiFi
- 1080p × 9 cameras = 27 Mbps = Cần ethernet

---

## 📱 Platform-Specific Questions

### Q25: Android permissions cần thiết?

**A:**

```xml
<manifest>
  <!-- Camera & Video -->
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  
  <!-- Network -->
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  
  <!-- Storage -->
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  
  <!-- Bluetooth (nếu dùng BLE config) -->
  <uses-permission android:name="android.permission.BLUETOOTH" />
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
  <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  
  <!-- WiFi info (cho QR config) -->
  <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
</manifest>
```

**Runtime permissions:**
```dart
await Permission.camera.request();
await Permission.microphone.request();
await Permission.storage.request();
await Permission.bluetoothScan.request();
await Permission.location.request();
```

---

### Q26: iOS Info.plist keys cần gì?

**A:**

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access for video calls</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access for audio</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Save screenshots and recordings</string>

<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth for camera setup</string>

<key>NSLocalNetworkUsageDescription</key>
<string>Find cameras on local network</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location for WiFi scanning</string>
```

---

## 🔄 Migration & Update Questions

### Q27: Upgrade SDK như thế nào?

**A:**

```yaml
# pubspec.yaml
dependencies:
  vsdk:
    path: ../flutter-sdk-demo  # Local path
    # OR
    # git:
    #   url: https://github.com/your/vsdk
    #   ref: v2.0.0
```

**Migration checklist:**
1. Check CHANGELOG.md
2. Update dependencies
3. Fix breaking changes
4. Test critical flows
5. Deploy gradually

---

### Q28: Có thể migrate từ app khác sang SDK này không?

**A:** ✅ CÓ, nếu:

1. **Camera tương thích**
   - Check device ID prefix (VSTC, VSGG, etc.)
   - Test P2P connection

2. **Data migration**
   ```dart
   // Export from old app
   List devices = await OldApp.exportDevices();
   
   // Import to new app
   for (var d in devices) {
     await DeviceListManager.getInstance().saveDevice(
       d.deviceId,
       d.password
     );
   }
   ```

3. **User data**
   - Recordings: Copy từ old app storage
   - Settings: Map settings to new SDK

---

## 📚 Learning & Support Questions

### Q29: Tài liệu tiếng Anh ở đâu?

**A:** 

- ✅ **Code comments**: Mostly English
- ⚠️ **Docs PDF**: Chinese (trong `doc/`)
- ✅ **This documentation**: Vietnamese → Có thể translate
- ❌ **Official English docs**: Thiếu

**Resources:**
- Read code: `flutter-sdk-demo/lib/`
- Example app: `flutter-sdk-demo/example/`
- This documentation set (translate if needed)

---

### Q30: Liên hệ support ở đâu?

**A:**

**Official:**
- Email: (check with Veepai vendor)
- Website: eye4.cn
- Documentation: In `doc/` folder

**Community:**
- GitHub Issues: (if available)
- Stack Overflow: Tag `veepai`
- Flutter Community: Discord/Slack

**This documentation:**
- Comprehensive guide
- Code examples
- Troubleshooting
→ Should answer 80-90% questions

---

## 📚 Next Steps

Nếu không tìm thấy câu trả lời:
- **[12-TROUBLESHOOTING.md](./12-TROUBLESHOOTING.md)** - Common issues
- **[13-API-REFERENCE.md](./13-API-REFERENCE.md)** - Complete API docs
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - Working examples

---

*Updated: 2024 | Version: 1.0*

