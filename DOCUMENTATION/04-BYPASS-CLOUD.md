# 🚫 VEEPAI SDK - BYPASS CLOUD SERVERS

> **Cách không dùng cloud servers của Veepai - Privacy & Independence**

---

## 🎯 Tại Sao Cần Bypass Cloud?

### Lý do phổ biến

```
✅ Privacy concerns:
   • Không muốn data đi qua servers bên thứ 3
   • Compliance requirements (GDPR, HIPAA)
   • Sensitive locations (hospitals, military)

✅ Independence:
   • Không phụ thuộc uptime của Veepai cloud
   • Tự control infrastructure
   • Custom business logic

✅ Cost optimization:
   • Không trả phí cloud storage của họ
   • Dùng S3/storage riêng rẻ hơn

✅ Customization:
   • Custom authentication
   • Custom video processing
   • Custom analytics
```

---

## 📊 Phân Tích Mức Độ Phụ Thuộc Cloud

### Cloud Servers Trong SDK

```
┌──────────────────────────────────────────────────────────┐
│ Server                    │ Dùng khi nào?    │ Bypass?   │
├──────────────────────────────────────────────────────────┤
│ api.eye4.cn/hello/*       │ Device binding   │ ✅ CÓ     │
│ vuid.eye4.cn              │ VID → Real ID    │ ✅ CÓ     │
│ authentication.eye4.cn    │ Service params   │ ✅ CÓ     │
│ open.eye4.cn              │ Cloud APIs       │ ⚠️ TÙY    │
│ P2P Relay Servers         │ NAT fallback     │ ❌ KHÓ    │
└──────────────────────────────────────────────────────────┘
```

### Giai Đoạn Kết Nối - Cloud Dependencies

```
┌─────────────────────────────────────────────────────────┐
│ GIAI ĐOẠN 1: WiFi Configuration                         │
│ • Bluetooth/QR Config                                   │
│ • Cloud dependency: ❌ NONE                             │
│ • Bypass: ✅ Đã bypass sẵn (local Bluetooth/QR)        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GIAI ĐOẠN 2: Device Binding                             │
│ • Camera đăng ký lên hello.eye4.cn                      │
│ • App query device ID                                   │
│ • Cloud dependency: ⚠️ HIGH                             │
│ • Bypass options:                                       │
│   → Option A: Use Real Device ID (skip VID)            │
│   → Option B: Self-host binding server                 │
│   → Option C: AP Mode (no binding needed)              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GIAI ĐOẠN 3: P2P Connection                             │
│ • Resolve VID → Real ID (vuid.eye4.cn)                 │
│ • Get service params (authentication.eye4.cn)           │
│ • P2P direct connection                                 │
│ • Cloud dependency: ⚠️ MEDIUM                           │
│ • Bypass options:                                       │
│   → Option A: Use Real ID (skip vuid query)            │
│   → Option B: Cache service params                     │
│   → Option C: Local service param calculation          │
│   → Option D: AP Mode (192.168.168.1 direct)           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ GIAI ĐOẠN 4: Video Streaming                            │
│ • P2P direct streaming                                  │
│ • Cloud dependency: ❌ NONE                             │
│ • Bypass: ✅ Đã bypass sẵn (P2P direct)                │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 PHƯƠNG ÁN 1: AP Mode (Pure Offline) ⭐ Khuyến nghị

### Khái niệm

```
Camera hoạt động như một WiFi Access Point
├─→ Tạo WiFi riêng: "IPC-XXXXXXX"
├─→ IP tĩnh: 192.168.168.1
├─→ App kết nối trực tiếp qua WiFi này
└─→ ❌ ZERO cloud dependency
```

### Cách Kích Hoạt AP Mode

#### Phương án A: CGI Command (Nếu đã kết nối)

```dart
Future<bool> enableAPMode(CameraDevice device) async {
  // Set camera to AP mode
  bool success = await device.writeCgi(
    "set_wifi_ap.cgi?enable=1&ssid=IPC-${device.id}&password=12345678&"
  );
  
  if (success) {
    print("✅ AP Mode enabled");
    print("📶 WiFi SSID: IPC-${device.id}");
    print("🔑 Password: 12345678");
    return true;
  }
  
  return false;
}
```

#### Phương án B: Factory Reset + Không Config WiFi

```
1. Reset camera về factory settings
   • Giữ nút reset 10 giây
   
2. KHÔNG cấu hình WiFi qua Bluetooth/QR
   
3. Camera tự động vào AP mode sau 3-5 phút
   • SSID: "IPC-XXXXXXX" hoặc "MC-XXXXXXX"
   • Password: Mặc định (check manual, thường là "12345678")
```

### Kết Nối Qua AP Mode

```dart
class APModeConnection {
  static const String AP_IP = "192.168.168.1";
  static const int AP_PORT = 8800;
  
  Future<CameraDevice> connectViaAPMode({
    required String apSSID,      // "IPC-VSTC123456"
    required String apPassword,  // "12345678"
    required String cameraPassword = "888888",
  }) async {
    // 1. Check if connected to camera's AP
    String? currentSSID = await _getCurrentWiFiSSID();
    if (currentSSID != apSSID) {
      print("❌ Please connect to camera WiFi: $apSSID");
      // You can auto-connect on Android/iOS with permission
      return null;
    }
    
    // 2. Check if camera is in AP mode
    bool isAPMode = await _checkCameraAPMode(AP_IP);
    if (!isAPMode) {
      print("❌ Camera not in AP mode");
      return null;
    }
    
    // 3. Create device with AP IP
    CameraDevice device = CameraDevice(
      AP_IP,           // Use IP directly as device ID
      "AP Camera",
      "admin",
      cameraPassword,
      "Unknown"
    );
    
    // Override getClientId() để dùng IP thay vì resolve cloud
    device.overrideClientId(AP_IP);
    
    // 4. Connect
    CameraConnectState state = await device.connect(
      lanScan: true,    // Ưu tiên LAN
      connectCount: 1   // Không retry (vì đã biết chắc là LAN)
    );
    
    if (state == CameraConnectState.connected) {
      print("✅ Connected via AP mode");
      return device;
    }
    
    return null;
  }
  
  // Check camera AP mode via HTTP
  Future<bool> _checkCameraAPMode(String ip) async {
    try {
      var response = await dio.get(
        "http://$ip/check.cgi",
        options: Options(
          receiveTimeout: Duration(seconds: 3),
          sendTimeout: Duration(seconds: 3),
        )
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### Ưu & Nhược Điểm

```
✅ Ưu điểm:
  • ZERO cloud dependency
  • Best privacy (offline hoàn toàn)
  • Không cần internet
  • Latency thấp nhất (< 100ms)
  • Miễn phí bandwidth

❌ Nhược điểm:
  • Chỉ hoạt động khi điện thoại kết nối WiFi camera
  • Không remote từ xa
  • Mất kết nối khi ra khỏi phạm vi WiFi
  • Không dùng được cloud storage/AI cloud

🎯 Use cases:
  • Local surveillance
  • Offline monitoring
  • Testing & development
  • High-security environments
```

---

## 🔧 PHƯƠNG ÁN 2: Self-Host Backend

### Architecture

```
┌───────────────────────────────────────────────────────┐
│                   YOUR BACKEND                         │
│  ┌─────────────────────────────────────────────────┐ │
│  │ Device Binding Service                          │ │
│  │ • POST /api/hello/confirm                       │ │
│  │ • POST /api/hello/query                         │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────┐ │
│  │ VID Resolution Service                          │ │
│  │ • GET /api/vuid/:vid                            │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────┐ │
│  │ Authentication Service                          │ │
│  │ • POST /api/auth/service-param                  │ │
│  └─────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────┐ │
│  │ Cloud Storage Service (Optional)                │ │
│  │ • POST /api/cloud/urls                          │ │
│  │ • Integration with S3/MinIO                     │ │
│  └─────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────┘
```

### Implement Backend APIs

#### 1. Device Binding API

```javascript
// Node.js + Express example
const express = require('express');
const router = express.Router();

// In-memory storage (use Redis/database in production)
const bindingStore = new Map();

// Clear previous binding
router.post('/hello/confirm', (req, res) => {
  const { key } = req.body;
  
  bindingStore.delete(key);
  
  res.json({ success: true });
});

// Query device ID
router.post('/hello/query', (req, res) => {
  const { key } = req.body;
  
  const binding = bindingStore.get(key);
  
  if (binding) {
    // Return URL-encoded JSON format (same as Veepai)
    const data = {
      vuid: binding.deviceId,
      timestamp: Math.floor(Date.now() / 1000),
      userid: binding.userId,
      C2Net: {
        TStep: 1,
        CStep: 1,
        FCode: 4097,
        Status: 1,
        Ecode: 0
      }
    };
    
    const encoded = encodeURIComponent(JSON.stringify(data));
    res.json({ value: encoded });
  } else {
    res.status(404).json({ error: 'Not found' });
  }
});

// Camera registration endpoint (camera calls this)
router.post('/hello/register', (req, res) => {
  const { realDeviceId, userId, model } = req.body;
  
  // Generate virtual ID (or use real ID)
  const virtualId = `VE${Date.now().toString().slice(-12)}`;
  
  // Store binding
  const key = `${userId}_binding`;
  bindingStore.set(key, {
    deviceId: virtualId,
    realDeviceId: realDeviceId,
    userId: userId,
    model: model,
    timestamp: Date.now()
  });
  
  // Also store VID mapping
  const vidKey = `vuid_${virtualId}`;
  bindingStore.set(vidKey, realDeviceId);
  
  res.json({ 
    success: true, 
    virtualId: virtualId 
  });
});

module.exports = router;
```

#### 2. VID Resolution API

```javascript
router.get('/vuid/:vid', (req, res) => {
  const { vid } = req.params;
  
  const key = `vuid_${vid}`;
  const realId = bindingStore.get(key);
  
  if (realId) {
    res.json({ realDeviceId: realId });
  } else {
    // If not found, maybe it's already a real ID
    res.json({ realDeviceId: vid });
  }
});
```

#### 3. Service Parameter API

```javascript
const crypto = require('crypto');

router.post('/auth/service-param', async (req, res) => {
  const { deviceId } = req.body;
  
  // Get device info from database
  const device = await db.devices.findOne({ deviceId });
  
  if (!device) {
    return res.status(404).json({ error: 'Device not found' });
  }
  
  // Generate service param (simplified)
  // Real implementation would need proper encryption
  const param = {
    deviceId: device.realDeviceId,
    secret: device.secret,
    timestamp: Math.floor(Date.now() / 1000),
    token: crypto.randomBytes(16).toString('hex')
  };
  
  // Encode to base64
  const encoded = Buffer.from(JSON.stringify(param)).toString('base64');
  
  res.json({ serviceParam: encoded });
});
```

### Modify Flutter App to Use Your Backend

```dart
class AppWebApi {
  static const String BASE_URL = "https://your-backend.com/api";
  
  // Override default URLs
  static String getHelloConfirmURL() {
    return "$BASE_URL/hello/confirm";
  }
  
  static String getHelloQueryURL() {
    return "$BASE_URL/hello/query";
  }
  
  static String getVuidURL(String vid) {
    return "$BASE_URL/vuid/$vid";
  }
  
  static String getAuthURL() {
    return "$BASE_URL/auth/service-param";
  }
}
```

```dart
// Modify P2PBasisDevice
class P2PBasisDevice extends BasisDevice {
  @override
  Future<String> getClientId() async {
    if (isVirtualId) {
      // Use your backend instead of vuid.eye4.cn
      var response = await dio.get(AppWebApi.getVuidURL(id));
      return response.data["realDeviceId"];
    }
    return id;
  }
  
  @override
  Future<String?> getServiceParam() async {
    // Check cache first
    String? cached = _serviceMap[id];
    if (cached != null) return cached;
    
    // Query your backend
    var response = await dio.post(
      AppWebApi.getAuthURL(),
      data: {"deviceId": id}
    );
    
    String param = response.data["serviceParam"];
    _serviceMap[id] = param;
    return param;
  }
}
```

### Configure Camera to Use Your Backend

```dart
Future<void> configureCameraBackend(
  CameraDevice device,
  String backendURL
) async {
  await device.writeCgi(
    "set_server.cgi?"
    "hello_server=${Uri.encodeComponent(backendURL)}&"
    "vuid_server=${Uri.encodeComponent(backendURL)}&"
    "auth_server=${Uri.encodeComponent(backendURL)}&"
  );
  
  print("✅ Camera configured to use: $backendURL");
}
```

### Ưu & Nhược Điểm

```
✅ Ưu điểm:
  • Full control over infrastructure
  • Custom business logic
  • Better privacy
  • Can still work remotely (P2P)
  • Can integrate own cloud storage

❌ Nhược điểm:
  • Need to maintain backend
  • Need SSL certificates
  • Need to understand protocols
  • Initial setup effort

💰 Cost:
  • VPS: $10-50/month
  • Domain + SSL: $15/year
  • Storage (optional): Pay as you go
  
🎯 Use cases:
  • Commercial products
  • Enterprise solutions
  • Custom integrations
```

---

## 🔧 PHƯƠNG ÁN 3: Use Real Device ID (Skip VID)

### Concept

```
Thay vì dùng Virtual ID (VE000xxxx)
→ Dùng trực tiếp Real Device ID (VSTC123456789)
→ Skip bước resolve VID
```

### Cách Lấy Real Device ID

#### Phương án A: Từ QR Code trên camera

```
Trên camera thường có QR code với format:
{
  "ID": "VSTC123456789ABCDEF",
  "Model": "QW6-T",
  "Key": "abcdef1234567890"
}

Scan QR này để lấy Real ID
```

#### Phương án B: Query từ Virtual ID (1 lần)

```dart
Future<String> getRealDeviceId(String virtualId) async {
  // Query Veepai cloud 1 lần duy nhất
  var response = await dio.get(
    "https://vuid.eye4.cn/query?vuid=$virtualId"
  );
  
  String realId = response.data["realId"];
  
  // Lưu vào local storage
  await _saveDeviceMapping(virtualId, realId);
  
  return realId;
}

// Sau đó dùng real ID trực tiếp
CameraDevice device = CameraDevice(
  realId,  // "VSTC123456789ABCDEF"
  name,
  user,
  password,
  model
);
```

### Ưu & Nhược Điểm

```
✅ Ưu điểm:
  • Skip 1 cloud query (vuid.eye4.cn)
  • Faster connection (1 step less)
  • Still works remotely

❌ Nhược điểm:
  • Vẫn cần service param
  • Vẫn cần P2P relay (nếu NAT không punching được)

🎯 Use cases:
  • Quick optimization
  • Reduce cloud dependencies
```

---

## 🔧 PHƯƠNG ÁN 4: Pure Offline Mode

### Concept

```
Camera hoạt động 100% offline
├─→ KHÔNG kết nối internet
├─→ Chỉ kết nối LAN
└─→ App cũng chỉ dùng LAN
```

### Implementation

```dart
class OfflineCamera {
  Future<CameraDevice> connectOffline({
    required String cameraIP,     // e.g. "192.168.1.100"
    required String cameraPassword,
  }) async {
    // 1. Disable all cloud queries
    P2PBasisDevice.disableCloudQueries();
    
    // 2. Create device với IP
    CameraDevice device = CameraDevice(
      cameraIP,
      "Offline Camera",
      "admin",
      cameraPassword,
      "Unknown"
    );
    
    // 3. Override để force LAN only
    device.overrideConnectType(0x7F);  // LAN only
    
    // 4. Connect
    CameraConnectState state = await device.connect(
      lanScan: true,      // Force LAN scan
      connectCount: 1
    );
    
    return device;
  }
  
  // Scan LAN for cameras
  Future<List<String>> scanLocalCameras() async {
    List<String> found = [];
    
    // Get local network subnet
    String subnet = await _getLocalSubnet();  // e.g. "192.168.1"
    
    // Scan 192.168.1.1 - 192.168.1.254
    for (int i = 1; i <= 254; i++) {
      String ip = "$subnet.$i";
      
      try {
        // Try HTTP request
        var response = await dio.get(
          "http://$ip/check.cgi",
          options: Options(
            receiveTimeout: Duration(milliseconds: 500)
          )
        );
        
        if (response.statusCode == 200) {
          found.add(ip);
          print("✅ Found camera: $ip");
        }
      } catch (e) {
        // Skip
      }
    }
    
    return found;
  }
}
```

### Ưu & Nhược Điểm

```
✅ Ưu điểm:
  • ZERO internet dependency
  • Best privacy
  • Fast (LAN speed)
  • No cloud costs

❌ Nhược điểm:
  • KHÔNG remote được
  • Chỉ hoạt động cùng mạng LAN
  • Không cloud storage
  • Không push notifications

🎯 Use cases:
  • Air-gapped networks
  • Maximum security
  • Local surveillance only
```

---

## 🔧 PHƯƠNG ÁN 5: Reverse Engineering (Advanced) ⚠️

### ⚠️ Cảnh báo

```
⚠️ Reverse engineering native libraries có thể:
  • Vi phạm license agreement
  • Vi phạm DMCA/CFAA (US law)
  • Void warranty
  • Get blacklisted

→ Chỉ dùng cho nghiên cứu/học tập
→ Không dùng cho mục đích thương mại
```

### Phân Tích Native Libraries

```bash
# Android
$ cd android库/
$ unzip app_p2p_api-2.0.0.0.aar
$ cd jni/
$ ls -la
  libOKSMARTPLAY.so  (các architecture)

# Analyze với IDA Pro / Ghidra
$ file libOKSMARTPLAY.so
  ELF 64-bit LSB shared object, ARM aarch64

# Extract function signatures
$ nm -D libOKSMARTPLAY.so | grep client
  00012340 T client_create
  00012450 T client_destroy
  00012560 T client_connect
  ...
```

### Rebuild Service Param Generation

```
Nếu reverse engineer thành công, có thể:

1. Hiểu cách service param được generate
2. Tự implement generation logic
3. Không cần query authentication.eye4.cn

→ Khó, cần expertise, có thể bị update
```

---

## 📊 So Sánh Các Phương Án

```
┌────────────────────────────────────────────────────────────────┐
│ Phương án         │ Cloud │ Remote │ Effort │ Privacy │ Cost  │
├────────────────────────────────────────────────────────────────┤
│ 1. AP Mode        │ ZERO  │ ❌     │ Easy   │ ★★★★★   │ FREE  │
│ 2. Self-Host      │ Low   │ ✅     │ Medium │ ★★★★☆   │ $20/m │
│ 3. Real ID        │ Low   │ ✅     │ Easy   │ ★★★☆☆   │ FREE  │
│ 4. Pure Offline   │ ZERO  │ ❌     │ Easy   │ ★★★★★   │ FREE  │
│ 5. Reverse Eng    │ ZERO  │ ✅     │ Hard   │ ★★★★★   │ FREE  │
└────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Khuyến Nghị

### Cho từng use case

```
🏠 Home use:
→ AP Mode hoặc Real ID
  (Đơn giản, đủ dùng)

🏢 Small business:
→ Self-Host Backend
  (Control tốt, không phức tạp quá)

🏛️ Enterprise:
→ Self-Host Backend + Pure Offline
  (Hybrid: remote khi cần, offline khi security critical)

🔬 Research:
→ Reverse Engineering
  (Hiểu sâu protocol, contribute to community)
```

---

## 📚 Next Steps

- **[05-SELF-HOST-GUIDE.md](./05-SELF-HOST-GUIDE.md)** - Chi tiết self-host backend
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - Code examples đầy đủ
- **[13-API-REFERENCE.md](./13-API-REFERENCE.md)** - API reference

---

*Updated: 2024 | Version: 1.0*

