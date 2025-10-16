# 🤖 VEEPAI SDK - AI FEATURES GUIDE

> **Complete guide to on-device AI features**  
> Human detection, tracking, smart alarms, and advanced AI capabilities

---

## 🎯 Overview

### What Makes Veepai AI Special?

```
✅ ON-DEVICE Processing
   → AI runs on camera's NPU/AI chip
   → NO cloud upload needed
   → Best privacy
   → Zero AI subscription fees

✅ Real-time Processing
   → < 100ms detection latency
   → Instant alerts
   → Smooth tracking

✅ Multiple AI Features
   → Human tracking
   → Auto framing
   → Auto zoom
   → Custom sounds
   → Advanced AI detection (8 types)
```

### AI Processing Architecture

```
┌────────────────────────────────────────────────────┐
│                   CAMERA DEVICE                     │
│  ┌──────────────────────────────────────────────┐ │
│  │  Video Sensor → NPU/AI Chip → Results       │ │
│  │                    ↓                          │ │
│  │              AI Processing                    │ │
│  │              (On-Device)                      │ │
│  │                    ↓                          │ │
│  │         ┌──────────┴──────────┐              │ │
│  │         ↓                     ↓               │ │
│  │    Tracking/Framing    Detection Results     │ │
│  └──────────────────────────────────────────────┘ │
└────────────────────┬───────────────────────────────┘
                     │
                     ↓ Commands & Results
┌────────────────────────────────────────────────────┐
│                  FLUTTER APP                        │
│  • Enable/disable features                         │
│  • Configure parameters                            │
│  • Receive detection events                        │
│  • Show tracking status                            │
└────────────────────────────────────────────────────┘

Key Point: AI processing does NOT use cloud/backend!
```

---

## 📊 AI Features Overview

### Feature Comparison Table

```
┌────────────────────────────────────────────────────────────────┐
│ Feature        │ What It Does              │ Camera Req       │
├────────────────────────────────────────────────────────────────┤
│ HumanTracking  │ PTZ follows detected human│ PTZ + AI support │
│ HumanFraming   │ Auto-frames human in view │ AI support       │
│ HumanZoom      │ Auto-zooms on human       │ PTZ + AI support │
│ CustomSound    │ 20 custom alarm sounds    │ Speaker support  │
│ AiDetect       │ 8 advanced AI types       │ Advanced AI chip │
└────────────────────────────────────────────────────────────────┘
```

### Check Camera Support

```dart
Future<void> checkAISupport(CameraDevice device) async {
  // Get device status
  StatusResult status = await device.getStatus();
  
  // Check support
  print("Human Tracking: ${status.support_humanDetect == '1' ? '✅' : '❌'}");
  print("Human Framing: ${status.support_humanoidFrame == '1' ? '✅' : '❌'}");
  print("Human Zoom: ${status.support_humanoid_zoom == '1' ? '✅' : '❌'}");
  print("Custom Sound: ${status.support_voiceTypedef == '1' ? '✅' : '❌'}");
  print("AI Detect: ${status.support_mode_AiDetect != null ? '✅' : '❌'}");
}
```

---

## 🎯 FEATURE 1: Human Tracking (人形追踪)

### What It Does

**Human Tracking** makes the camera automatically follow a detected person using PTZ (Pan-Tilt-Zoom) motors.

```
Scenario:
1. Person enters camera view
2. Camera detects human (on-device AI)
3. Camera calculates person's position
4. Camera rotates PTZ to keep person centered
5. Person moves → Camera follows
6. Person exits → Camera returns to default position
```

### How It Works

```
┌──────────────────────────────────────────────────┐
│         HUMAN TRACKING FLOW                      │
└──────────────────────────────────────────────────┘

Video Frame → AI Detection → Human Found?
                                  │
                         ┌────────┴─────────┐
                         ↓                  ↓
                       YES                 NO
                         │                  │
                         ↓                  ↓
              Calculate Position      Continue Scanning
                         │
                         ↓
              Move PTZ to Center Person
                         │
                         ↓
              Update Tracking Status
                         │
                         ↓
              Send Status to App
                         │
                         ↓
              Wait 100ms → Loop
```

### API Methods

```dart
class HumanTracking {
  // Get tracking status
  Future<bool> getHumanTracking({
    int timeout = 5,
    HumanTrackCallBack? humanTrackCallBack
  });
  
  // Enable/disable tracking
  Future<bool> setHumanTracking(int enable, {int timeout = 5});
  
  // Current state
  int humanTrackingEnable;  // 0=disabled, 1=enabled
  int humanTrackStatus;     // 0=idle, 1=tracking
}
```

### CGI Commands

```
Enable Tracking:
trans_cmd_string.cgi?cmd=2127&command=0&enable=1&

Disable Tracking:
trans_cmd_string.cgi?cmd=2127&command=0&enable=0&

Get Status:
trans_cmd_string.cgi?cmd=2127&command=1&

Response Format:
cmd=2127;command=0;enable=1;track_status=0;result=0;
```

### Complete Code Example

```dart
class HumanTrackingPage extends StatefulWidget {
  final CameraDevice device;
  
  HumanTrackingPage({required this.device});
  
  @override
  _HumanTrackingPageState createState() => _HumanTrackingPageState();
}

class _HumanTrackingPageState extends State<HumanTrackingPage> {
  bool isEnabled = false;
  int trackStatus = 0;  // 0=idle, 1=tracking
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadStatus();
  }
  
  Future<void> _loadStatus() async {
    setState(() => isLoading = true);
    
    try {
      // Check if camera supports human tracking
      if (widget.device.aiCommand?.humanTracking == null) {
        _showError("Camera does not support human tracking");
        return;
      }
      
      // Get current status with callback
      bool success = await widget.device.aiCommand!.humanTracking!
          .getHumanTracking(
            humanTrackCallBack: (status) {
              setState(() {
                trackStatus = status;
              });
              
              if (status == 1) {
                _showInfo("Tracking person...");
              } else {
                _showInfo("Tracking stopped");
              }
            }
          );
      
      if (success) {
        setState(() {
          isEnabled = widget.device.aiCommand!.humanTracking!
              .humanTrackingEnable == 1;
          trackStatus = widget.device.aiCommand!.humanTracking!
              .humanTrackStatus;
        });
      }
      
    } catch (e) {
      _showError("Error loading status: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Future<void> _toggleTracking(bool value) async {
    setState(() => isLoading = true);
    
    try {
      int enable = value ? 1 : 0;
      
      bool success = await widget.device.aiCommand!.humanTracking!
          .setHumanTracking(enable);
      
      if (success) {
        setState(() => isEnabled = value);
        _showSuccess(value 
          ? "Human tracking enabled" 
          : "Human tracking disabled"
        );
      } else {
        _showError("Failed to change tracking mode");
      }
      
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Human Tracking")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enable/Disable Switch
            Card(
              child: SwitchListTile(
                title: Text("Human Tracking"),
                subtitle: Text(
                  isEnabled 
                    ? "Camera will follow detected person" 
                    : "Tracking is disabled"
                ),
                value: isEnabled,
                onChanged: isLoading ? null : _toggleTracking,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Tracking Status
            if (isEnabled) ...[
              Card(
                color: trackStatus == 1 ? Colors.green[50] : Colors.grey[100],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        trackStatus == 1 
                          ? Icons.location_searching 
                          : Icons.location_disabled,
                        color: trackStatus == 1 
                          ? Colors.green 
                          : Colors.grey,
                        size: 40,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trackStatus == 1 
                                ? "Tracking Active" 
                                : "Waiting for Human",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: trackStatus == 1 
                                  ? Colors.green 
                                  : Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              trackStatus == 1
                                ? "Camera is following detected person"
                                : "No person detected in view",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 20),
            
            // Info
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "How It Works",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "• AI detects humans on-device (no cloud)\n"
                      "• Camera calculates person's position\n"
                      "• PTZ motors rotate to keep person centered\n"
                      "• Works in real-time (< 100ms latency)\n"
                      "• Returns to default when person exits",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green)
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }
  
  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue)
    );
  }
}
```

### Use Cases

```
✅ Security surveillance:
   • Track intruders automatically
   • Keep person in frame for evidence

✅ Baby monitoring:
   • Follow baby as they crawl
   • Keep focus on baby at all times

✅ Pet monitoring:
   • Track pet movements
   • Auto-record pet activities

✅ Retail analytics:
   • Follow customer movements
   • Analyze shopping behavior
```

### Limitations

```
⚠️ Requires PTZ camera
⚠️ One person at a time (tracks closest/largest)
⚠️ May lose tracking if person moves too fast
⚠️ Indoor performance better than outdoor
⚠️ May false-trigger on large moving objects
```

---

## 🎯 FEATURE 2: Human Framing (人形框定)

### What It Does

**Human Framing** automatically adjusts the camera's field of view to keep detected humans properly framed within the image.

```
Without Framing:       With Framing:
┌─────────────┐        ┌─────────────┐
│             │        │             │
│     👤      │   →    │   ┌──👤──┐  │
│             │        │   │     │  │
│             │        │   └─────┘  │
└─────────────┘        └─────────────┘
```

### How It Works

```
Video Frame → AI Detection → Human Found?
                                  │
                                 YES
                                  │
                                  ↓
                    Calculate Optimal Frame
                    • Person centered
                    • Proper head room
                    • Include shoulders
                                  │
                                  ↓
                    Adjust Digital Crop
                    (No PTZ movement)
                                  │
                                  ↓
                    Send Adjusted Frame
```

### API Methods

```dart
class HumanFraming {
  // Get framing status
  Future<bool> getHumanFraming({int timeout = 5});
  
  // Enable/disable framing
  Future<bool> setHumanFraming(int enable, {int timeout = 5});
  
  // Current state
  int humanFrameEnable;  // 0=disabled, 1=enabled
}
```

### CGI Commands

```
Enable Framing:
trans_cmd_string.cgi?cmd=2126&command=0&bHumanoidFrame=1&

Disable Framing:
trans_cmd_string.cgi?cmd=2126&command=0&bHumanoidFrame=0&

Get Status:
trans_cmd_string.cgi?cmd=2126&command=1&
```

### Code Example

```dart
Future<void> toggleHumanFraming(
  CameraDevice device,
  bool enable
) async {
  if (device.aiCommand?.humanFraming == null) {
    print("❌ Camera does not support human framing");
    return;
  }
  
  try {
    int enableValue = enable ? 1 : 0;
    
    bool success = await device.aiCommand!.humanFraming!
        .setHumanFraming(enableValue);
    
    if (success) {
      print("✅ Human framing ${enable ? 'enabled' : 'disabled'}");
    } else {
      print("❌ Failed to change framing mode");
    }
    
  } catch (e) {
    print("❌ Error: $e");
  }
}
```

### Use Cases

```
✅ Video calls: Auto-frame person for better composition
✅ Portraits: Professional-looking shots
✅ Security: Keep person properly framed in recording
✅ Presentations: Speaker stays well-framed
```

---

## 🎯 FEATURE 3: Human Zoom (人形变倍跟踪)

### What It Does

**Human Zoom** automatically zooms in on detected humans to get a closer view.

```
Before Zoom:           After Zoom:
┌─────────────┐        ┌─────────────┐
│             │        │  ┌───────┐  │
│    👤       │   →    │  │  👤   │  │
│             │        │  │      │  │
│             │        │  └───────┘  │
└─────────────┘        └─────────────┘
(Wide view)            (Zoomed on person)
```

### API Methods

```dart
class HumanZoom {
  // Get zoom status
  Future<bool> getHumanZoom({int timeout = 5});
  
  // Enable/disable zoom
  Future<bool> setHumanZoom(int enable, {int timeout = 5});
  
  // Current state
  int humanZoomEnable;  // 0=disabled, 1=enabled
}
```

### CGI Commands

```
Enable Zoom:
trans_cmd_string.cgi?cmd=2126&command=0&humanoid_zoom=1&

Disable Zoom:
trans_cmd_string.cgi?cmd=2126&command=0&humanoid_zoom=0&
```

### Code Example

```dart
class AIFeaturesControl extends StatefulWidget {
  final CameraDevice device;
  
  AIFeaturesControl({required this.device});
  
  @override
  _AIFeaturesControlState createState() => _AIFeaturesControlState();
}

class _AIFeaturesControlState extends State<AIFeaturesControl> {
  bool trackingEnabled = false;
  bool framingEnabled = false;
  bool zoomEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }
  
  Future<void> _loadAllSettings() async {
    // Load tracking status
    if (widget.device.aiCommand?.humanTracking != null) {
      await widget.device.aiCommand!.humanTracking!.getHumanTracking();
      setState(() {
        trackingEnabled = widget.device.aiCommand!.humanTracking!
            .humanTrackingEnable == 1;
      });
    }
    
    // Load framing status
    if (widget.device.aiCommand?.humanFraming != null) {
      await widget.device.aiCommand!.humanFraming!.getHumanFraming();
      setState(() {
        framingEnabled = widget.device.aiCommand!.humanFraming!
            .humanFrameEnable == 1;
      });
    }
    
    // Load zoom status
    if (widget.device.aiCommand?.humanZoom != null) {
      await widget.device.aiCommand!.humanZoom!.getHumanZoom();
      setState(() {
        zoomEnabled = widget.device.aiCommand!.humanZoom!
            .humanZoomEnable == 1;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Human Tracking
        SwitchListTile(
          title: Text("Human Tracking"),
          subtitle: Text("Camera follows detected person"),
          value: trackingEnabled,
          onChanged: widget.device.aiCommand?.humanTracking != null
            ? (value) async {
                await widget.device.aiCommand!.humanTracking!
                    .setHumanTracking(value ? 1 : 0);
                setState(() => trackingEnabled = value);
              }
            : null,
        ),
        
        // Human Framing
        SwitchListTile(
          title: Text("Human Framing"),
          subtitle: Text("Auto-frames person in view"),
          value: framingEnabled,
          onChanged: widget.device.aiCommand?.humanFraming != null
            ? (value) async {
                await widget.device.aiCommand!.humanFraming!
                    .setHumanFraming(value ? 1 : 0);
                setState(() => framingEnabled = value);
              }
            : null,
        ),
        
        // Human Zoom
        SwitchListTile(
          title: Text("Human Zoom"),
          subtitle: Text("Auto-zooms on detected person"),
          value: zoomEnabled,
          onChanged: widget.device.aiCommand?.humanZoom != null
            ? (value) async {
                await widget.device.aiCommand!.humanZoom!
                    .setHumanZoom(value ? 1 : 0);
                setState(() => zoomEnabled = value);
              }
            : null,
        ),
      ],
    );
  }
}
```

---

## 🔊 FEATURE 4: Custom Alarm Sounds

### What It Does

Configure custom alarm sounds for different detection types. Upload your own audio files to play when specific events are detected.

### 20 Alarm Sound Types

```dart
enum VoiceType {
  faceDetection = 0,      // 人脸侦测报警提示音
  humanDetection = 1,     // 人形侦测报警提示音
  smokeDetection = 2,     // 烟感报警提示音
  motionDetection = 3,    // 移动侦测报警提示音
  offPost = 4,            // 离岗检测提示音
  cryingDetection = 5,    // 哭声检测提示音
  onPost = 6,             // 在岗监测提示音
  fireFlame = 7,          // 烟火相机火焰提示音
  fireSmoke = 8,          // 烟火相机烟雾提示音
  areaIntrusion = 9,      // 区域入侵提示音
  personStay = 10,        // 人逗留检测提示音
  illegalParking = 11,    // 车违停检测提示音
  crossLine = 12,         // 越线检测提示音
  offPostMonitor = 13,    // 离岗检测提示音
  carRetrograde = 14,     // 车辆逆行提示音
  packageAppear = 15,     // 包裹监测(出现包裹)
  packageDisappear = 16,  // 包裹消失
  packageStay = 17,       // 包裹滞留
  deviceCall = 19,        // 带屏设备呼叫声
}
```

### API Methods

```dart
class CustomSound {
  // Get current sound configuration
  Future<bool> getVoiceInfo(int voiceType, {int timeout = 10});
  
  // Set custom sound
  Future<bool> setVoiceInfo(
    String? voiceUrl,      // Download URL for audio file
    String voiceName,      // Filename
    int switch,            // 0=no sound, 1=has sound
    int voicetype,         // 0-19 (see VoiceType enum)
    {
      bool playInDevice = false,  // Play on camera speaker
      int timeout = 20,
      String playTimes = '3'      // Number of times to play
    }
  );
  
  // Current data
  Map? soundData;
}
```

### CGI Commands

```
Get Sound Info:
trans_cmd_string.cgi?cmd=2135&command=1&voicetype=1&

Set Sound:
trans_cmd_string.cgi?cmd=2135&command=0&
  urlJson={"url":"https://example.com/sound.mp3"}&
  filename=alarm.mp3&
  switch=1&
  voicetype=1&
  play=1&
  playtimes=3&
```

### Complete Example

```dart
class CustomSoundPage extends StatefulWidget {
  final CameraDevice device;
  
  CustomSoundPage({required this.device});
  
  @override
  _CustomSoundPageState createState() => _CustomSoundPageState();
}

class _CustomSoundPageState extends State<CustomSoundPage> {
  int selectedVoiceType = 1;  // Human detection
  bool soundEnabled = false;
  String? currentSoundUrl;
  String? currentSoundName;
  
  final List<Map<String, dynamic>> voiceTypes = [
    {'id': 0, 'name': 'Face Detection', 'icon': Icons.face},
    {'id': 1, 'name': 'Human Detection', 'icon': Icons.person},
    {'id': 2, 'name': 'Smoke Detection', 'icon': Icons.cloud},
    {'id': 3, 'name': 'Motion Detection', 'icon': Icons.directions_walk},
    {'id': 4, 'name': 'Off-Post Detection', 'icon': Icons.exit_to_app},
    {'id': 5, 'name': 'Crying Detection', 'icon': Icons.child_care},
    {'id': 9, 'name': 'Area Intrusion', 'icon': Icons.warning},
    {'id': 10, 'name': 'Person Stay', 'icon': Icons.timer},
    {'id': 11, 'name': 'Illegal Parking', 'icon': Icons.local_parking},
    {'id': 12, 'name': 'Cross Line', 'icon': Icons.trending_up},
    {'id': 15, 'name': 'Package Appear', 'icon': Icons.inventory},
    {'id': 16, 'name': 'Package Disappear', 'icon': Icons.remove_shopping_cart},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadSoundInfo();
  }
  
  Future<void> _loadSoundInfo() async {
    if (widget.device.aiCommand?.customSound == null) {
      _showError("Camera does not support custom sounds");
      return;
    }
    
    try {
      bool success = await widget.device.aiCommand!.customSound!
          .getVoiceInfo(selectedVoiceType);
      
      if (success && widget.device.aiCommand!.customSound!.soundData != null) {
        Map data = widget.device.aiCommand!.customSound!.soundData!;
        
        setState(() {
          soundEnabled = data['switch'] == '1';
          currentSoundUrl = data['urlJson'];
          currentSoundName = data['filename'];
        });
      }
      
    } catch (e) {
      _showError("Error loading sound info: $e");
    }
  }
  
  Future<void> _uploadCustomSound(String url, String filename) async {
    try {
      bool success = await widget.device.aiCommand!.customSound!.setVoiceInfo(
        url,
        filename,
        1,  // Enable sound
        selectedVoiceType,
        playInDevice: true,  // Test play on camera
        playTimes: '3'
      );
      
      if (success) {
        _showSuccess("Custom sound uploaded and configured");
        setState(() {
          soundEnabled = true;
          currentSoundUrl = url;
          currentSoundName = filename;
        });
      } else {
        _showError("Failed to upload sound");
      }
      
    } catch (e) {
      _showError("Error: $e");
    }
  }
  
  Future<void> _disableSound() async {
    try {
      bool success = await widget.device.aiCommand!.customSound!.setVoiceInfo(
        null,
        '',
        0,  // Disable sound
        selectedVoiceType,
      );
      
      if (success) {
        _showSuccess("Sound disabled");
        setState(() => soundEnabled = false);
      }
      
    } catch (e) {
      _showError("Error: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Custom Alarm Sounds")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Voice Type Selector
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Alarm Type",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<int>(
                    value: selectedVoiceType,
                    isExpanded: true,
                    items: voiceTypes.map((type) {
                      return DropdownMenuItem<int>(
                        value: type['id'],
                        child: Row(
                          children: [
                            Icon(type['icon'], size: 20),
                            SizedBox(width: 12),
                            Text(type['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedVoiceType = value);
                        _loadSoundInfo();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Current Configuration
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(soundEnabled ? "Enabled" : "Disabled"),
                        backgroundColor: soundEnabled 
                          ? Colors.green[100] 
                          : Colors.grey[300],
                      ),
                    ],
                  ),
                  if (soundEnabled && currentSoundName != null) ...[
                    SizedBox(height: 12),
                    Text("File: $currentSoundName"),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Actions
          if (!soundEnabled)
            ElevatedButton.icon(
              icon: Icon(Icons.upload),
              label: Text("Upload Custom Sound"),
              onPressed: () => _showUploadDialog(),
            )
          else
            ElevatedButton.icon(
              icon: Icon(Icons.delete),
              label: Text("Disable Sound"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _disableSound,
            ),
        ],
      ),
    );
  }
  
  void _showUploadDialog() {
    TextEditingController urlController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Upload Sound"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: "Sound URL",
                hintText: "https://example.com/alarm.mp3",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Filename",
                hintText: "alarm.mp3",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadCustomSound(
                urlController.text,
                nameController.text,
              );
            },
            child: Text("Upload"),
          ),
        ],
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green)
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }
}
```

### Audio File Requirements

```
Format: MP3, WAV, OGG
Size: < 5 MB
Duration: 2-10 seconds recommended
Bitrate: 128 kbps or higher
Sample Rate: 44.1 kHz or 48 kHz

Upload Methods:
1. HTTP/HTTPS URL (camera downloads)
2. Local file (future support)
```

---

## 🎯 FEATURE 5: Advanced AI Detection (AiDetect)

### What It Does

Configure and schedule 8 advanced AI detection types with custom parameters and time-based plans.

### 8 AI Detection Types

```dart
enum AiType {
  fire = 12,              // 火焰检测 (Fire detection)
  areaIntrusion = 14,     // 区域入侵 (Area intrusion)
  personStay = 15,        // 人逗留 (Person loitering)
  illegalParking = 16,    // 车违停 (Illegal parking)
  crossBorder = 17,       // 越线检测 (Line crossing)
  offPostMonitor = 18,    // 离岗检测 (Off-post detection)
  carRetrograde = 19,     // 车辆逆行 (Car going wrong way)
  packageDetect = 20,     // 包裹监测 (Package detection)
}
```

### API Methods

```dart
class AiDetect {
  // Get AI detection configuration
  Future<bool> getAiDetectData(int aiType, {int timeout = 5});
  
  // Set AI detection configuration
  Future<bool> setAiDetectData(
    int aiType,
    String aiConfigString,  // JSON config
    {int timeout = 5}
  );
  
  // Get detection schedule plan
  Future<bool> getAiDetectPlan(int type, {int timeout = 5});
  
  // Configure detection schedule
  Future<bool> configAiDetectPlan(
    int type,
    {required List records,  // 21 time slots
     int enable = 1,
     int timeout = 5}
  );
  
  // Current configurations
  Map<String, dynamic>? aiConfigMap;
  Map? firePlanData;
  Map? areaIntrusionPlanData;
  Map? personStayPlanData;
  // ... etc for each type
}
```

### Schedule Plans (21 Time Slots)

Each AI detection type can have a schedule plan with **21 time slots** representing hours of the week:

```
Monday:    Slots 1-3   (8 hours each)
Tuesday:   Slots 4-6
Wednesday: Slots 7-9
Thursday:  Slots 10-12
Friday:    Slots 13-15
Saturday:  Slots 16-18
Sunday:    Slots 19-21

Format: "HHMMSS-HHMMSS"
Example: "080000-180000" = 8:00 AM to 6:00 PM
         "000000-235959" = All day
         "000000-000000" = Disabled
```

### Complete Example - Fire Detection

```dart
class FireDetectionPage extends StatefulWidget {
  final CameraDevice device;
  
  FireDetectionPage({required this.device});
  
  @override
  _FireDetectionPageState createState() => _FireDetectionPageState();
}

class _FireDetectionPageState extends State<FireDetectionPage> {
  bool planEnabled = false;
  List<String> timeSlots = List.filled(21, "000000-000000");
  Map<String, dynamic>? aiConfig;
  
  @override
  void initState() {
    super.initState();
    _loadFireDetection();
  }
  
  Future<void> _loadFireDetection() async {
    if (widget.device.aiCommand?.aiDetect == null) {
      _showError("Camera does not support AI detection");
      return;
    }
    
    try {
      // Load config
      await widget.device.aiCommand!.aiDetect!.getAiDetectData(12);  // Fire
      
      // Load schedule plan
      await widget.device.aiCommand!.aiDetect!.getAiDetectPlan(12);
      
      // Get data
      aiConfig = widget.device.aiCommand!.aiDetect!.aiConfigMap;
      Map? planData = widget.device.aiCommand!.aiDetect!.firePlanData;
      
      if (planData != null) {
        setState(() {
          planEnabled = planData['fire_plan_enable'] == '1';
          
          // Parse time slots
          for (int i = 0; i < 21; i++) {
            String key = 'fire_plan${i + 1}';
            if (planData.containsKey(key)) {
              timeSlots[i] = planData[key];
            }
          }
        });
      }
      
    } catch (e) {
      _showError("Error loading fire detection: $e");
    }
  }
  
  Future<void> _saveSchedule() async {
    try {
      bool success = await widget.device.aiCommand!.aiDetect!
          .configAiDetectPlan(
            12,  // Fire detection
            records: timeSlots,
            enable: planEnabled ? 1 : 0,
          );
      
      if (success) {
        _showSuccess("Fire detection schedule saved");
      } else {
        _showError("Failed to save schedule");
      }
      
    } catch (e) {
      _showError("Error: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fire Detection"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSchedule,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Enable/Disable
          SwitchListTile(
            title: Text("Fire Detection Schedule"),
            subtitle: Text("Enable time-based fire detection"),
            value: planEnabled,
            onChanged: (value) => setState(() => planEnabled = value),
          ),
          
          SizedBox(height: 16),
          
          // Weekly Schedule
          Text(
            "Weekly Schedule",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          
          ...List.generate(7, (dayIndex) {
            return Card(
              child: ExpansionTile(
                title: Text(_getDayName(dayIndex)),
                children: List.generate(3, (slotIndex) {
                  int index = dayIndex * 3 + slotIndex;
                  return ListTile(
                    title: Text("Slot ${slotIndex + 1}"),
                    subtitle: Text(timeSlots[index]),
                    trailing: Icon(Icons.edit),
                    onTap: () => _editTimeSlot(index),
                  );
                }),
              ),
            );
          }),
          
          SizedBox(height: 16),
          
          // Quick Presets
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Presets",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _applyPreset("24/7"),
                        child: Text("24/7"),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset("Business Hours"),
                        child: Text("Business Hours"),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset("Night Only"),
                        child: Text("Night Only"),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset("Clear All"),
                        child: Text("Clear All"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getDayName(int index) {
    const days = [
      "Monday", "Tuesday", "Wednesday", "Thursday",
      "Friday", "Saturday", "Sunday"
    ];
    return days[index];
  }
  
  void _editTimeSlot(int index) {
    TextEditingController controller = TextEditingController(
      text: timeSlots[index]
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Time Slot"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Format: HHMMSS-HHMMSS"),
            Text("Example: 080000-180000 (8 AM to 6 PM)"),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "080000-180000",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                timeSlots[index] = controller.text;
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
  
  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case "24/7":
          timeSlots = List.filled(21, "000000-235959");
          break;
        case "Business Hours":
          for (int i = 0; i < 15; i++) {  // Mon-Fri
            timeSlots[i] = "080000-180000";
          }
          for (int i = 15; i < 21; i++) {  // Sat-Sun
            timeSlots[i] = "000000-000000";
          }
          break;
        case "Night Only":
          timeSlots = List.filled(21, "180000-060000");
          break;
        case "Clear All":
          timeSlots = List.filled(21, "000000-000000");
          break;
      }
    });
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green)
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }
}
```

---

## 🎯 Best Practices

### 1. Check Support Before Use

```dart
Future<bool> checkAISupport(CameraDevice device) async {
  StatusResult status = await device.getStatus();
  
  // Check each feature
  bool hasHumanTracking = status.support_humanDetect == "1";
  bool hasHumanFraming = status.support_humanoidFrame == "1";
  bool hasHumanZoom = status.support_humanoid_zoom == "1";
  bool hasCustomSound = status.support_voiceTypedef == "1";
  bool hasAiDetect = status.support_mode_AiDetect != null;
  
  // Initialize only supported features
  if (hasHumanTracking && device.aiCommand?.humanTracking == null) {
    // Feature supported but not initialized
    // Call getStatus() to trigger initialization
    await device.getStatus(cache: false);
  }
  
  return hasHumanTracking || hasHumanFraming || 
         hasHumanZoom || hasCustomSound || hasAiDetect;
}
```

### 2. Handle Errors Gracefully

```dart
Future<bool> safeAIOperation(Future<bool> Function() operation) async {
  try {
    return await operation();
  } on TimeoutException {
    print("⏱️ Operation timed out");
    return false;
  } on SocketException {
    print("📵 Network error");
    return false;
  } catch (e) {
    print("❌ Error: $e");
    return false;
  }
}

// Usage
bool success = await safeAIOperation(() => 
  device.aiCommand!.humanTracking!.setHumanTracking(1)
);
```

### 3. Combine Features Intelligently

```dart
// Don't combine HumanTracking + HumanZoom on PTZ cameras
// → May cause jerky movements

// Good combinations:
✅ HumanFraming + HumanZoom (Fixed camera)
✅ HumanTracking alone (PTZ camera)
✅ CustomSound + any detection type

// Bad combinations:
❌ HumanTracking + HumanZoom (conflicts)
❌ All AI features at once (CPU overload)
```

### 4. Test with Real Scenarios

```dart
// Test human detection accuracy
await testDetectionAccuracy();

Future<void> testDetectionAccuracy() async {
  int detectCount = 0;
  int totalFrames = 100;
  
  // Enable tracking
  await device.aiCommand!.humanTracking!.setHumanTracking(1);
  
  // Monitor for 10 seconds
  await Future.delayed(Duration(seconds: 10));
  
  // Calculate accuracy
  double accuracy = (detectCount / totalFrames) * 100;
  print("Detection accuracy: ${accuracy.toStringAsFixed(2)}%");
}
```

---

## ❓ FAQ

### Q: Do AI features work offline?

**A:** ✅ YES! All AI processing happens on the camera's chip. No internet needed.

### Q: Can I use multiple AI features simultaneously?

**A:** ⚠️ Depends on camera model. High-end cameras can handle 2-3 features, budget cameras may struggle.

### Q: Why is tracking laggy?

**A:** Check:
- Camera CPU usage
- Network latency
- PTZ motor speed
- Too many features enabled

### Q: How accurate is human detection?

**A:** Typical accuracy:
- Indoor: 90-95%
- Outdoor (day): 85-90%
- Outdoor (night): 70-80%
- False positives: < 5%

### Q: Can I detect multiple people?

**A:** HumanTracking: Only 1 at a time (closest/largest)
AiDetect: Can detect multiple

### Q: Battery impact?

**A:** AI processing uses ~15-20% more power than without AI.

---

## 🎯 Summary

### Key Takeaways

```
✅ On-device AI = Best privacy + Zero cloud fees
✅ 5 AI features: Tracking, Framing, Zoom, Sound, Detect
✅ Real-time processing (< 100ms latency)
✅ 8 advanced AI types with schedule plans
✅ 20 custom alarm sound types
✅ Works completely offline
```

### When to Use Each Feature

```
HumanTracking → Security, monitoring
HumanFraming → Video calls, portraits
HumanZoom → Identification, evidence
CustomSound → Custom alerts, notifications
AiDetect → Advanced scenarios (fire, parking, etc.)
```

---

## 📚 Next Steps

- **[07-PTZ-CONTROL.md](./07-PTZ-CONTROL.md)** - PTZ control guide
- **[08-ALARM-MANAGEMENT.md](./08-ALARM-MANAGEMENT.md)** - Alarm setup
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - More examples

---

*Updated: 2024 | Version: 1.0*

