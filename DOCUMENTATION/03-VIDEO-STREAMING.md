# 📹 VEEPAI SDK - VIDEO STREAMING ARCHITECTURE

> **Hiểu rõ cách video stream từ camera đến màn hình điện thoại**

---

## 🎯 Câu Hỏi Quan Trọng Nhất

### ❓ Video đi qua đâu? Backend của tôi có xử lý video không?

```
❌ KHÔNG! Video KHÔNG đi qua backend của bạn
✅ Video stream TRỰC TIẾP: Camera → P2P → App
✅ Backend chỉ để: Device binding, metadata, authentication
```

### Kiến Trúc Video Streaming

```
┌──────────────────────────────────────────────────────────────┐
│                    VIDEO STREAMING FLOW                       │
└──────────────────────────────────────────────────────────────┘

       ┌─────────────┐
       │   CAMERA    │  ← Video sensor capture
       │  (Device)   │
       └──────┬──────┘
              │
              │ 1. Video capture (30 FPS)
              │ 2. AI processing (on-device NPU)
              │ 3. H.264/H.265 encoding
              │ 4. Packet formation
              │
              ↓
       ┌──────────────┐
       │ Video Buffer │  ← Memory trong camera
       └──────┬───────┘
              │
              ├─────────────→ LAN/P2P/Relay Connection
              │                (Choose best path)
              │
              ↓
┌──────────────────────────────────────────────────────────────┐
│              NETWORK LAYER (Transparent P2P)                  │
│  Option 1: LAN  ━━━━━→ Same WiFi ━━━━━→ Fastest (50ms)      │
│  Option 2: P2P  ━━━━━→ NAT Traverse ━━━━→ Fast (200ms)      │
│  Option 3: Relay ━━━━→ Cloud Relay ━━━━→ Slower (500ms)     │
└──────────────────────────────────────────────────────────────┘
              │
              ↓
       ┌──────────────────┐
       │  P2P Connection  │  ← Native library
       │  (libOKSMARTPLAY)│     (Proprietary)
       └──────┬───────────┘
              │
              │ Raw H.264/H.265 packets
              │ (Binary data, NOT HTTP/RTMP)
              │
              ↓
       ┌──────────────────┐
       │  Native Decoder  │  ← Hardware accelerated
       │  + Renderer      │     • Android: MediaCodec
       └──────┬───────────┘     • iOS: VideoToolbox
              │
              │ Decoded YUV frames
              │
              ↓
       ┌──────────────────┐
       │   Texture/View   │  ← Flutter Widget
       │  (Screen Display)│     AppPlayerView
       └──────────────────┘


Backend Server của bạn:
┌────────────────────┐
│   YOUR BACKEND     │  ← KHÔNG XỬ LÝ VIDEO!
│                    │
│ ✅ Device binding  │
│ ✅ Authentication  │
│ ✅ Metadata        │
│ ✅ Notifications   │
│ ❌ Video stream    │  ← Video KHÔNG đi qua đây!
└────────────────────┘
```

---

## 📊 Video Source Types

SDK hỗ trợ 6 loại video sources:

### 1. LIVE_SOURCE - Live Streaming ⭐ Phổ biến nhất

**Use case:** Xem live real-time từ camera

```dart
class LiveVideoSource extends VideoSource {
  final int clientPtr;  // P2P client pointer
  
  LiveVideoSource(this.clientPtr) : super(VideoSourceType.LIVE_SOURCE);
  
  @override
  getSource() => clientPtr;
}

// Usage
int clientPtr = await device.getClientPtr();
LiveVideoSource source = LiveVideoSource(clientPtr);
await player.setVideoSource(source);

// Camera → P2P → Native decoder → Screen
// Latency: 50-500ms
```

**Data flow:**
```
1. App gửi CGI: "livestream.cgi?streamid=10&substream=1&"
2. Camera bắt đầu encode video (H.264)
3. Camera đẩy packets qua P2P connection
4. Native library nhận packets
5. Hardware decoder decode real-time
6. Render lên Texture
7. Flutter widget hiển thị
```

**Packet format:**
```
┌────────────────────────────────────────┐
│ P2P Packet Header (16 bytes)           │
├────────────────────────────────────────┤
│ • Magic: 0xF1F2                        │
│ • Type: 0x01 (Video) / 0x02 (Audio)   │
│ • Frame: I-frame / P-frame             │
│ • Timestamp: Unix time                 │
│ • Length: Payload size                 │
├────────────────────────────────────────┤
│ Payload (Variable)                     │
│ • H.264/H.265 NAL units                │
│ • Or audio frames (G.711/ADPCM)        │
└────────────────────────────────────────┘
```

---

### 2. CARD_SOURCE - TF Card Playback

**Use case:** Xem lại video đã ghi trên thẻ nhớ

```dart
class CardVideoSource extends VideoSource {
  final int clientPtr;
  final int size;        // File size in bytes
  final int checkHead;   // Check video header: 1=yes
  
  CardVideoSource(this.clientPtr, this.size, {this.checkHead = 1})
      : super(VideoSourceType.CARD_SOURCE);
  
  @override
  getSource() => [clientPtr, size, checkHead];
}

// Usage - Playback từ TF card
await player.setVideoSource(CardVideoSource(clientPtr, fileSize));

// Flow:
// 1. Query file list: device.getCardFileList()
// 2. User chọn file
// 3. Send CGI: "livestream.cgi?streamid=4&filename=xxx.h264&offset=0&"
// 4. Camera đọc từ TF card và stream
```

**TF Card File Structure:**
```
/mnt/sdcard/
├── 2023/
│   ├── 12/
│   │   ├── 15/
│   │   │   ├── 12/
│   │   │   │   ├── 20231215_120530.h264  (Main stream)
│   │   │   │   ├── 20231215_121030.h264
│   │   │   │   └── ...
│   │   │   └── ...
│   │   └── ...
│   └── ...
└── ...

File naming: YYYYMMDD_HHMMSS.h264
```

---

### 3. NETWORK_SOURCE - Cloud Storage Playback

**Use case:** Xem video từ cloud storage

```dart
class NetworkVideoSource extends VideoSource {
  final List<String> urls;  // HTTP/HTTPS URLs
  
  NetworkVideoSource(this.urls) : super(VideoSourceType.NETWORK_SOURCE);
  
  @override
  getSource() => urls;
}

// Usage
List<String> urls = [
  "https://d004-vstc.eye4.cn/VSTC123_2023-12-15:12_05_30.mp4?token=xxx",
  "https://d004-vstc.eye4.cn/VSTC123_2023-12-15:12_10_30.mp4?token=xxx"
];
await player.setVideoSource(NetworkVideoSource(urls));

// Flow:
// 1. App request URLs từ backend/cloud
// 2. Native player download từ URLs
// 3. Decode và play
// → KHÔNG qua P2P, trực tiếp HTTP download
```

**Cloud Storage Architecture:**
```
Camera (có motion detection)
    │
    │ Motion detected!
    ↓
┌─────────────────────┐
│ Record video clip   │ (10-30 seconds)
└──────────┬──────────┘
           │
           ↓ Upload via HTTPS
┌─────────────────────────────────┐
│ Cloud Storage (S3/OSS)          │
│ • Bucket: veepai-videos         │
│ • Path: /VSTC123/2023/12/15/... │
└──────────┬──────────────────────┘
           │
           ↓ Generate signed URL
┌──────────────────────┐
│ Backend API          │
│ POST /D004/file/url  │
└──────────┬───────────┘
           │
           ↓ Return URLs
┌──────────────────────┐
│ App downloads & play │
└──────────────────────┘
```

---

### 4. FILE_SOURCE - Local File Playback

**Use case:** Play video đã lưu trên điện thoại

```dart
class FileVideoSource extends VideoSource {
  final String filePath;  // Local file path
  
  FileVideoSource(this.filePath) : super(VideoSourceType.FILE_SOURCE);
  
  @override
  getSource() => filePath;
}

// Usage
await player.setVideoSource(FileVideoSource("/sdcard/recorded.mp4"));

// Native player đọc file local và decode
// KHÔNG cần network
```

---

### 5. TimeLine_SOURCE - TF Card Timeline

**Use case:** Timeline playback với progress bar

```dart
class TimeLineSource extends VideoSource {
  final int clientPtr;
  
  TimeLineSource(this.clientPtr) : super(VideoSourceType.TimeLine_SOURCE);
  
  @override
  getSource() => [clientPtr];
}

// Usage - Timeline view
await player.setVideoSource(TimeLineSource(clientPtr));

// Tương tự CARD_SOURCE nhưng có timeline UI
```

---

### 6. CAMERA_VIDEO_SOURCE - Mobile Camera

**Use case:** Ghi video từ camera điện thoại (two-way communication)

```dart
class CameraVideoSource extends VideoSource {
  final int clientPtr;
  final int dir;          // 0=back, 1=front camera
  final int frameRate;    // FPS: 8, 15, 30
  
  CameraVideoSource(this.clientPtr, {this.dir = 0, this.frameRate = 8})
      : super(VideoSourceType.CAMERA_VIDEO_SOURCE);
  
  @override
  getSource() => [clientPtr, dir, frameRate];
}

// Usage - Send video TO camera (intercom)
await player.setVideoSource(CameraVideoSource(clientPtr, dir: 1, frameRate: 15));
```

---

## 🔧 Video Parameters & Configuration

### Resolution Settings

```dart
enum VideoResolution {
  none,       // Không xác định
  high,       // 1920x1080 (1080p) - 2-4 Mbps
  general,    // 1280x720 (720p)   - 1-2 Mbps [DEFAULT]
  unknown,    // Unknown
  low,        // 640x360 (360p)    - 512 Kbps
  superHD,    // 2560x1440 or 3840x2160 (4K) - 6-8 Mbps
}

// Change resolution
await device.changeResolution(VideoResolution.high);

// Or start stream with resolution
await device.startStream(resolution: VideoResolution.superHD);
```

**CGI Command:**
```
livestream.cgi?streamid=10&substream=<INDEX>&

INDEX values:
• 0 = none
• 1 = high (1080p)
• 2 = general (720p) [default]
• 3 = unknown
• 4 = low (360p)
• 100 = superHD (4K)
```

### Frame Rate

```
• Low-power cameras: 10-15 FPS (battery saving)
• Standard cameras: 20-25 FPS
• High-end cameras: 30 FPS
• Configurable via CGI commands
```

### Bitrate & Bandwidth

```
┌─────────────────────────────────────────────────────────┐
│ Resolution │ Bitrate   │ Bandwidth/hour │ Use Case     │
├─────────────────────────────────────────────────────────┤
│ Low (360p) │ 512 Kbps  │ ~230 MB/hour   │ Mobile 3G   │
│ General HD │ 1.5 Mbps  │ ~675 MB/hour   │ WiFi/4G     │
│ High (1080)│ 3 Mbps    │ ~1.35 GB/hour  │ Good WiFi   │
│ SuperHD 4K │ 8 Mbps    │ ~3.6 GB/hour   │ Fiber/5G    │
└─────────────────────────────────────────────────────────┘

⚠️ Lưu ý:
• Bandwidth là per camera stream
• Multiple cameras = multiply bandwidth
• P2P connection ít tốn bandwidth server (direct peer)
```

---

## 🎥 Video Codec & Format

### H.264 (AVC) - Default

```
• Codec: H.264/AVC (Advanced Video Coding)
• Profile: Baseline, Main, or High
• Level: 3.1, 4.0, 4.1
• GOP (Group of Pictures): 2-4 seconds
• I-frame interval: 60-120 frames
• Support: Universal (all devices)
```

**Frame Types:**
```
I-frame (Intra-coded):
├─→ Keyframe, self-contained
├─→ Largest size (~10x P-frame)
├─→ Sent every 2-4 seconds
└─→ Required for stream start

P-frame (Predicted):
├─→ Delta from previous frame
├─→ Smallest size
├─→ Most frames are P-frames
└─→ Require I-frame reference

B-frame (Bi-directional): [Rarely used]
└─→ Reference both past & future frames
```

### H.265 (HEVC) - Optional

```
• Codec: H.265/HEVC (High Efficiency Video Coding)
• Profile: Main, Main 10
• 40-50% better compression than H.264
• Same quality at lower bitrate
• Higher CPU usage for encoding/decoding
• Support: Modern devices (Android 5+, iOS 11+)
```

**When to use:**
- ✅ Bandwidth limited (3G/4G)
- ✅ Cloud storage (save space)
- ✅ Recording to TF card (save space)
- ❌ Old devices (compatibility issues)

---

## 🔊 Audio Codec & Format

### G.711 - Default

```
• Sample rate: 8 kHz
• Bit depth: 8-bit (logarithmic)
• Bitrate: 64 Kbps
• Format: μ-law (US) or A-law (International)
• Latency: Very low (~20ms)
• Use case: Two-way audio, intercom
```

### ADPCM (Adaptive Differential PCM)

```
• Sample rate: 8 kHz
• Compression: 4:1
• Bitrate: 32 Kbps
• Quality: Better than G.711
• Use case: Recording with audio
```

### PCM (Raw)

```
• Sample rate: 8/16/44.1 kHz
• Bit depth: 16-bit
• Format: Linear PCM
• Bitrate: 128-1411 Kbps (uncompressed)
• Quality: Highest
• Use case: Local playback, editing
```

---

## 🔄 Connection Path Selection

### P2P Path Selection Algorithm

```
┌──────────────────────────────────────────────────────┐
│              CONNECTION PATH SELECTION                │
└──────────────────────────────────────────────────────┘

Step 1: Try LAN (if lanScan = true)
    ├─→ UDP broadcast to 255.255.255.255:8800
    ├─→ Wait for camera response (500ms)
    └─→ If found: Use direct LAN connection
                  Latency: 50-150ms ✅ BEST

Step 2: Try P2P (NAT Traversal)
    ├─→ Query STUN server for public IP/port
    ├─→ Camera also queries STUN
    ├─→ Exchange NAT info via signaling server
    ├─→ Attempt hole punching
    └─→ If success: Direct P2P connection
                    Latency: 150-300ms ✅ GOOD

Step 3: Fallback to Relay
    ├─→ Connect to relay server
    ├─→ Camera connects to same relay
    ├─→ Relay forwards packets
    └─→ Always works (guaranteed)
                    Latency: 300-800ms ⚠️ ACCEPTABLE
```

### Connection States

```dart
enum ClientConnectState {
  CONNECT_STATUS_CONNECTING,    // Đang kết nối
  CONNECT_STATUS_INITIALING,    // Đang khởi tạo
  CONNECT_STATUS_ONLINE,        // ✅ Kết nối thành công
  CONNECT_STATUS_OFFLINE,       // Camera offline
  CONNECT_STATUS_DISCONNECT,    // Mất kết nối
  CONNECT_STATUS_CONNECT_TIMEOUT,     // Timeout
  CONNECT_STATUS_CONNECT_FAILED,      // Thất bại
  CONNECT_STATUS_INVALID_ID,          // Device ID không hợp lệ
  CONNECT_STATUS_INVALID_CLIENT,      // Client không hợp lệ
  CONNECT_STATUS_MAX_SESSION,         // Quá nhiều user
  CONNECT_STATUS_MAX,                 // Unknown
}
```

---

## 🎬 Playback Control

### Player Lifecycle

```dart
class AppPlayerController<T> {
  // 1. Create player instance
  Future<bool> create({int audioRate = 8000}) async {
    // Create native player
    // Allocate video/audio buffers
    // Setup callbacks
  }
  
  // 2. Set video source
  Future<bool> setVideoSource(VideoSource source) async {
    // Configure player for source type
  }
  
  // 3. Start playback
  Future<bool> start() async {
    // Start video decoding
    // Start rendering
  }
  
  // 4. Control playback
  Future<bool> pause() async;
  Future<bool> resume() async;
  Future<bool> stop() async;
  
  // 5. Audio control
  Future<bool> startVoice() async;    // Enable audio
  Future<bool> stopVoice() async;     // Mute
  
  // 6. Recording
  Future<bool> startRecord({
    RecordEncoderType encoderType = RecordEncoderType.G711
  }) async;
  Future<bool> stopRecord() async;
  
  // 7. Screenshot
  Future<bool> screenshot(String filePath) async;
  
  // 8. Speed control (playback only, not live)
  Future<bool> setSpeed(double speed) async;  // 0.5x, 1x, 2x, 4x
  
  // 9. Progress control (playback only)
  Future<bool> setProgress(int duration) async;  // Seek to position
  
  // 10. Cleanup
  void dispose() async;
}
```

### Callbacks & Events

```dart
// State change callback
player.setStateChangeCallback((data, videoStatus, voiceStatus, recordStatus, touchType) {
  print("Video: $videoStatus, Voice: $voiceStatus");
});

// Progress callback (for playback)
player.addProgressChangeCallback((data, totalSec, playSec, progress, loadState, velocity, timestamp) {
  print("Playing: $playSec / $totalSec seconds");
  print("Progress: $progress%");
  print("Load state: $loadState");  // Buffering status
  print("Velocity: $velocity KB/s");  // Download speed
});

// Focal change callback (for PTZ cameras)
player.addFocalChangeCallback((data, focal) {
  print("Focal length: $focal");
});

// GPS callback (for cameras with GPS)
player.addGPSChangeCallback((data, fixStatus, satellites, lat, lng, speed, course) {
  print("GPS: $lat, $lng");
  print("Speed: $speed km/h");
});

// Video head info callback
player.addHeadInfoCallback((data, resolution, channel, type) {
  print("Resolution: $resolution");
  print("Channel: $channel");  // For multi-sensor cameras
});
```

---

## 🔐 Security & Encryption

### Video Stream Encryption

```
┌────────────────────────────────────────────────────┐
│ Encryption Layer (Optional)                        │
├────────────────────────────────────────────────────┤
│ • Algorithm: AES-128                               │
│ • Mode: CBC or CTR                                 │
│ • Key: Derived from service param                  │
│ • IV: Per-packet initialization vector             │
│                                                    │
│ Flow:                                              │
│ Camera → Encrypt(Video) → P2P → Decrypt → App    │
└────────────────────────────────────────────────────┘

⚠️ Encryption tăng CPU usage ~10-15%
⚠️ Tăng latency ~20-50ms
✅ Bảo mật cao hơn cho privacy
```

### P2P Authentication

```
┌────────────────────────────────────────────────────┐
│ P2P Connection Authentication                      │
├────────────────────────────────────────────────────┤
│ 1. Client creates connection with service param    │
│    • Service param = encrypted credentials         │
│    • Format: base64(encrypted(device_secret))      │
│                                                    │
│ 2. Native library decrypts & validates            │
│                                                    │
│ 3. Establishes secure channel                     │
│                                                    │
│ 4. All traffic encrypted end-to-end               │
└────────────────────────────────────────────────────┘
```

---

## 📊 Performance Optimization

### Buffer Management

```
┌────────────────────────────────────────────────────┐
│ Video Buffer Strategy                              │
├────────────────────────────────────────────────────┤
│ • Pre-buffer: 0.5-1 second (reduce latency)       │
│ • Main buffer: 2-5 seconds (smooth playback)       │
│ • Max buffer: 10 seconds (avoid memory overflow)   │
│                                                    │
│ Auto-adjust based on:                              │
│ • Network conditions                               │
│ • Device memory                                    │
│ • Video resolution                                 │
└────────────────────────────────────────────────────┘
```

### Adaptive Bitrate (ABR)

```
Camera monitors:
├─→ Packet loss rate
├─→ RTT (Round-Trip Time)
├─→ App feedback
└─→ Automatically adjusts:
    ├─→ Lower bitrate if network poor
    ├─→ Higher bitrate if network good
    └─→ Smooth transition (no stutter)
```

### Hardware Acceleration

```
Android:
├─→ MediaCodec API
├─→ GPU rendering (OpenGL ES)
└─→ Low CPU usage (~10-15%)

iOS:
├─→ VideoToolbox framework
├─→ Metal rendering
└─→ Efficient battery usage

Result:
✅ Smooth 30 FPS playback
✅ Low battery drain (~5-10%/hour)
✅ Multi-stream capable (4-9 cameras)
```

---

## 🎯 Summary - Video Streaming

### Điểm Quan Trọng

```
1. ❌ Backend KHÔNG xử lý video stream
   ✅ Video đi trực tiếp: Camera → P2P → App

2. ✅ P2P tự động chọn path tốt nhất:
   • LAN (fastest)
   • P2P direct (fast)
   • Relay (fallback)

3. ✅ Hardware decoding = hiệu năng cao
   • MediaCodec (Android)
   • VideoToolbox (iOS)

4. ✅ Multiple video sources:
   • Live streaming (real-time)
   • TF card playback
   • Cloud playback
   • Local file

5. ✅ Flexible resolution:
   • 360p → 4K
   • Auto-adjust bitrate
```

### Khi Self-Host Backend

```
✅ Backend chỉ cần:
  • Device binding API
  • Cloud storage URLs (optional)
  • Push notifications

❌ Backend KHÔNG cần:
  • Video streaming server
  • RTMP/HLS/WebRTC server
  • Video transcoding
  • Real-time processing

💰 Chi phí thấp:
  • P2P direct = FREE bandwidth
  • Chỉ tốn bandwidth cho cloud playback
  • VPS nhỏ (~$10-20/month) là đủ
```

---

## 📚 Next Steps

- **[04-BYPASS-CLOUD.md](./04-BYPASS-CLOUD.md)** - Không dùng cloud Veepai
- **[05-SELF-HOST-GUIDE.md](./05-SELF-HOST-GUIDE.md)** - Tự host backend
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - Code examples

---

*Updated: 2024 | Version: 1.0*

