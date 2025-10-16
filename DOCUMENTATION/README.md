# 📚 VEEPAI SDK - COMPLETE DOCUMENTATION

> **Senior-Level Analysis & Implementation Guide**  
> Tài liệu đầy đủ để hiểu và triển khai Veepai Camera SDK

---

## 📖 Mục Lục Tài Liệu

### 🎯 Phần 1: Tổng Quan
- **[01-ARCHITECTURE.md](./01-ARCHITECTURE.md)** - Kiến trúc tổng thể của SDK
  - Flutter Plugin Architecture
  - Native Libraries (Android/iOS)
  - P2P Communication Layer
  - Module Structure

### 🔌 Phần 2: Kết Nối Camera
- **[02-CONNECTION-FLOW.md](./02-CONNECTION-FLOW.md)** - Quy trình kết nối camera từ A-Z
  - Giai đoạn 1: Cấu hình mạng (Bluetooth/WiFi/QR)
  - Giai đoạn 2: Device Binding
  - Giai đoạn 3: P2P Connection & Login
  - State Machine & Error Handling

### 📹 Phần 3: Video Streaming
- **[03-VIDEO-STREAMING.md](./03-VIDEO-STREAMING.md)** - Video streaming architecture
  - Video Source Types
  - P2P Protocol Details
  - Codec & Format Specifications
  - Performance & Optimization

### 🌐 Phần 4: Cloud & Self-Host
- **[04-BYPASS-CLOUD.md](./04-BYPASS-CLOUD.md)** - Các phương án không dùng cloud Veepai
  - AP Mode (Pure Offline)
  - Self-Host Backend
  - Pure Offline Mode
  - Reverse Engineering
- **[05-SELF-HOST-GUIDE.md](./05-SELF-HOST-GUIDE.md)** - Hướng dẫn tự host backend chi tiết
  - Backend APIs cần implement
  - Database Schema
  - Cloud Storage Integration
  - Deployment Guide

### 🤖 Phần 5: Tính Năng
- **[06-AI-FEATURES.md](./06-AI-FEATURES.md)** - AI features & on-device processing
  - Human Detection & Tracking
  - Face Detection
  - Smart Alarms
  - Custom AI Configuration
- **[07-PTZ-CONTROL.md](./07-PTZ-CONTROL.md)** - PTZ control & presets
- **[08-ALARM-MANAGEMENT.md](./08-ALARM-MANAGEMENT.md)** - Alarm & notification system

### 💻 Phần 6: Implementation
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - Code examples đầy đủ
  - Quick Start
  - Live Streaming
  - TF Card Playback
  - Cloud Playback
  - PTZ Control
  - AI Features
- **[10-BEST-PRACTICES.md](./10-BEST-PRACTICES.md)** - Best practices & optimization

### 🐛 Phần 7: Troubleshooting
- **[11-FAQ.md](./11-FAQ.md)** - Câu hỏi thường gặp
- **[12-TROUBLESHOOTING.md](./12-TROUBLESHOOTING.md)** - Xử lý lỗi thường gặp
- **[13-API-REFERENCE.md](./13-API-REFERENCE.md)** - API reference đầy đủ

---

## 🚀 Quick Start

### Đọc theo thứ tự này nếu bạn mới bắt đầu:

1. **[01-ARCHITECTURE.md](./01-ARCHITECTURE.md)** - Hiểu kiến trúc tổng thể
2. **[02-CONNECTION-FLOW.md](./02-CONNECTION-FLOW.md)** - Hiểu cách kết nối camera
3. **[03-VIDEO-STREAMING.md](./03-VIDEO-STREAMING.md)** - Hiểu cách stream video
4. **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - Xem code và chạy thử

### Đọc theo nhu cầu:

- **Muốn tự host backend?** → [04-BYPASS-CLOUD.md](./04-BYPASS-CLOUD.md) + [05-SELF-HOST-GUIDE.md](./05-SELF-HOST-GUIDE.md)
- **Muốn dùng AI features?** → [06-AI-FEATURES.md](./06-AI-FEATURES.md)
- **Gặp lỗi?** → [12-TROUBLESHOOTING.md](./12-TROUBLESHOOTING.md)
- **Tìm API cụ thể?** → [13-API-REFERENCE.md](./13-API-REFERENCE.md)

---

## 📊 Tổng Quan Nhanh

### SDK này làm được gì?

```
✅ Kết nối camera qua P2P (Peer-to-Peer)
✅ Live streaming real-time (< 500ms latency)
✅ Playback TF card recordings
✅ Cloud storage & playback
✅ PTZ control (Pan-Tilt-Zoom)
✅ AI features (on-device processing)
✅ Two-way audio
✅ Alarm management
✅ Multi-camera support (2-4 sensors)
✅ Low-power device support
```

### Kiến trúc cốt lõi

```
App (Flutter/Dart)
    ↓ MethodChannel/FFI
Native Layer (Kotlin/Swift)
    ↓ JNI/Objective-C
P2P Library (libOKSMARTPLAY.so / libVSTC.a)
    ↓ TCP/UDP
Camera Device
```

### Video không qua server của bạn!

```
✅ Video stream trực tiếp: Camera → P2P → App
✅ Backend chỉ để: Device binding, metadata, authentication
❌ Backend KHÔNG xử lý video streaming
```

---

## 🎯 Các Phương Án Triển Khai

### Option 1: Dùng Cloud Veepai (Mặc định)
```
• Pros: Đơn giản, không cần maintain
• Cons: Phụ thuộc cloud bên thứ 3, privacy concerns
• Use case: Prototype, MVP, small projects
```

### Option 2: Self-Host Backend
```
• Pros: Full control, better privacy
• Cons: Cần maintain server
• Use case: Commercial products, security-critical apps
```

### Option 3: Pure Offline (AP Mode)
```
• Pros: Zero cloud dependency, best privacy
• Cons: Chỉ hoạt động LAN, không remote
• Use case: Local surveillance, private networks
```

### Option 4: Hybrid
```
• Pros: Linh hoạt nhất
• Cons: Phức tạp nhất
• Use case: Enterprise solutions
```

---

## 💰 Chi Phí Ước Tính

### Dùng Cloud Veepai
```
• SDK: Free
• Cloud storage: $5-20/device/month (optional)
• Bandwidth: Free (P2P)
```

### Self-Host Backend
```
• VPS: $10-50/month
• Storage (S3): $0.023/GB/month
• Bandwidth: Minimal (P2P direct)
• Total: ~$20-100/month
```

### Pure Offline
```
• Cost: $0
• Chỉ cần hardware camera + local network
```

---

## 🔐 Security & Privacy

### Data Flow
```
• Video stream: Camera → P2P → App (encrypted, không qua server)
• Control commands: App → P2P → Camera
• Metadata: App ↔ Backend (device info, user auth)
• Cloud storage: Camera → Cloud Storage → App (optional)
```

### Security Features
```
✅ AES encryption cho P2P
✅ Password authentication
✅ Dual authentication support
✅ Token-based API auth
✅ HTTPS for all APIs
```

---

## 🛠️ Technical Requirements

### Flutter SDK
```yaml
environment:
  sdk: ">=2.17.0 <3.0.0"
  flutter: ">=1.20.0"
```

### Android
```gradle
minSdkVersion: 21 (Android 5.0)
targetSdkVersion: 33 (Android 13)
```

### iOS
```
iOS 11.0+
Xcode 13+
Swift 5+
```

### Camera Requirements
```
• Veepai compatible cameras (VSTC, VSGG, VSKK, etc.)
• Network connection (WiFi/Ethernet/4G)
• Firmware: Latest version recommended
```

---

## 📞 Support & Resources

### Official Resources
```
• SDK Source: flutter-sdk-demo/
• Native Libraries: android库/, ios库/
• Documentation: doc/ (Chinese PDFs)
```

### Community
```
• GitHub Issues: (if available)
• Email Support: (check with vendor)
```

### This Documentation
```
• Created: 2024
• Last Updated: 2024
• Version: 1.0
• Language: Vietnamese (Tiếng Việt)
```

---

## 📝 License

Check the LICENSE file in the SDK for terms of use.

**⚠️ Important Notes:**
- Native libraries (`.so`, `.a`) are proprietary
- Reverse engineering may violate license terms
- For commercial use, verify licensing with Veepai

---

## 🎓 Next Steps

1. **Đọc kiến trúc**: [01-ARCHITECTURE.md](./01-ARCHITECTURE.md)
2. **Hiểu connection flow**: [02-CONNECTION-FLOW.md](./02-CONNECTION-FLOW.md)
3. **Xem code examples**: [09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)
4. **Chạy demo app**: `flutter-sdk-demo/example/`

---

**Good luck with your implementation! 🚀**

*Nếu có câu hỏi, tham khảo [FAQ](./11-FAQ.md) hoặc [Troubleshooting](./12-TROUBLESHOOTING.md)*

