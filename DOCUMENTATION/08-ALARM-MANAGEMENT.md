# 🚨 VEEPAI SDK - ALARM MANAGEMENT GUIDE

> **Complete guide to alarm detection and notification**  
> PIR, Motion Detection, Human Detection, and Smart Alerting

---

## 🎯 What are Alarms?

**Alarms** = Camera detects events (motion, person, etc.) and sends notifications.

```
Event Detection → Analysis → Alert Decision → Notification
                                    ↓
                              Video Recording
                                    ↓
                              Cloud Upload (optional)
```

### Why Alarms are Important

```
✅ Security: Detect intruders, alert homeowners
✅ Safety: Monitor elderly, children, pets
✅ Efficiency: Only record when activity detected
✅ Convenience: Push notifications to phone
✅ Evidence: Auto-record important events
```

---

## 📊 Alarm Types Comparison

### Three Detection Methods

```
┌──────────────────────────────────────────────────────────────────────┐
│ Type   │ How It Works          │ Accuracy │ Power  │ False Alarms  │
├──────────────────────────────────────────────────────────────────────┤
│ PIR    │ Infrared sensor       │ Medium   │ Low    │ Medium        │
│        │ Detects body heat     │          │        │ (pets, heat)  │
├──────────────────────────────────────────────────────────────────────┤
│ Motion │ Video analysis        │ Low      │ Medium │ High          │
│        │ Detects pixel change  │          │        │ (shadows,tree)│
├──────────────────────────────────────────────────────────────────────┤
│ Human  │ AI shape recognition  │ High     │ High   │ Low           │
│        │ Identifies human form │          │        │ (very smart)  │
└──────────────────────────────────────────────────────────────────────┘
```

### When to Use Each Type

```
PIR Detection:
✅ Battery-powered cameras (lowest power)
✅ Indoor monitoring
✅ Close-range detection (< 5 meters)
⚠️ May trigger on pets

Motion Detection:
✅ Always-powered cameras
✅ Large area monitoring
✅ Basic security needs
⚠️ Many false alarms (trees, shadows)

Human Detection (AI):
✅ High-security applications
✅ Crowded areas (filters out non-humans)
✅ Outdoor monitoring
✅ Best choice if camera supports it
```

---

## 🔴 PIR Detection (Passive Infrared)

### How PIR Works

**PIR sensors** detect infrared radiation (body heat) from moving objects.

```
Human Approaches:
    🧍     →     🧍‍    →    🧍
   Far         Closer    In Range
   
PIR Sensor:
 [No Heat] → [Weak Heat] → [TRIGGER! 🚨]
 
Temperature change detected → Alarm triggered
```

### PIR Configuration

```dart
class AlarmCommand {
  // PIR Settings
  bool? pirPushEnable;         // Enable push notifications
  bool? pirPushVideoEnable;    // Enable video recording
  int? pirDetection;           // PIR level: 0=off, 1=low, 2=mid, 3=high
  int? pirCloudVideoDuration;  // Video duration (seconds)
  int? distanceAdjust;         // Detection distance: 0=near, 1=far
  int? humanoidDetection;      // Human-only filter: 0=off, 1=on
  int? autoRecordVideoMode;    // Auto-record mode
}
```

### PIR Sensitivity Levels

```
Level 0 (Off):
   No PIR detection
   
Level 1 (Low):
   • Detection range: 1-3 meters
   • Best for: Close monitoring, reduce false alarms
   • Triggers: Only very close movement
   
Level 2 (Medium) - Recommended:
   • Detection range: 3-5 meters
   • Best for: Normal home security
   • Good balance
   
Level 3 (High):
   • Detection range: 5-8 meters
   • Best for: Maximum coverage
   • Warning: More false alarms
```

### Distance Adjustment

```dart
// Near detection (1-3 meters)
await device.setDetectionRange(0);

// Far detection (5-8 meters)
await device.setDetectionRange(1);
```

### Humanoid Filter

Reduces false alarms by only triggering on human-shaped objects:

```dart
// Enable human-only detection
await device.setHuanoidDetection(1);

// Disable (detect all movement)
await device.setHuanoidDetection(0);
```

### Complete PIR Example

```dart
class PIRSettingsPage extends StatefulWidget {
  final CameraDevice device;
  
  PIRSettingsPage({required this.device});
  
  @override
  _PIRSettingsPageState createState() => _PIRSettingsPageState();
}

class _PIRSettingsPageState extends State<PIRSettingsPage> {
  bool pushEnabled = false;
  bool videoEnabled = false;
  int pirLevel = 2;  // 0-3
  int distanceRange = 0;  // 0=near, 1=far
  int humanoidFilter = 0;  // 0=off, 1=on
  int videoDuration = 15;  // seconds
  int autoRecordMode = 0;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() => isLoading = true);
    
    try {
      // Load PIR parameters
      await widget.device.getAlarmParam();
      
      // Load detection range
      await widget.device.getDetectionRange();
      
      setState(() {
        pushEnabled = widget.device.pirPushEnable ?? false;
        videoEnabled = widget.device.pirPushVideoEnable ?? false;
        pirLevel = widget.device.pirLevel ?? 2;
        distanceRange = widget.device.distanceAdjust ?? 0;
        humanoidFilter = widget.device.humanoidDetection ?? 0;
        videoDuration = widget.device.pirCloudVideoDuration ?? 15;
        autoRecordMode = widget.device.autoRecordVideoMode ?? 0;
      });
      
    } catch (e) {
      _showError("Error loading PIR settings: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() => isLoading = true);
    
    try {
      // Save PIR push settings
      bool success1 = await widget.device.setPriPush(
        pushEnable: pushEnabled,
        videoEnable: videoEnabled,
        videoDuration: videoDuration,
        autoRecordMode: autoRecordMode,
      );
      
      // Save PIR detection level
      bool success2 = await widget.device.setPriDetection(pirLevel);
      
      // Save detection range
      bool success3 = await widget.device.setDetectionRange(distanceRange);
      
      // Save humanoid filter
      bool success4 = await widget.device.setHuanoidDetection(humanoidFilter);
      
      if (success1 && success2 && success3 && success4) {
        _showSuccess("PIR settings saved successfully");
      } else {
        _showError("Failed to save some settings");
      }
      
    } catch (e) {
      _showError("Error saving settings: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PIR Detection Settings"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: isLoading ? null : _saveSettings,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Info Card
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sensors, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              "About PIR Detection",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          "PIR sensors detect infrared radiation (body heat). "
                          "Best for battery-powered cameras. Low power consumption.",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Enable Notifications
                Card(
                  child: SwitchListTile(
                    title: Text("Push Notifications"),
                    subtitle: Text("Send alerts to your phone"),
                    value: pushEnabled,
                    onChanged: (value) {
                      setState(() => pushEnabled = value);
                    },
                  ),
                ),
                
                // Enable Video Recording
                Card(
                  child: SwitchListTile(
                    title: Text("Video Recording"),
                    subtitle: Text("Record video when alarm triggered"),
                    value: videoEnabled,
                    onChanged: (value) {
                      setState(() => videoEnabled = value);
                    },
                  ),
                ),
                
                SizedBox(height: 16),
                
                // PIR Sensitivity Level
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PIR Sensitivity",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _getPIRLevelDescription(pirLevel),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Slider(
                          value: pirLevel.toDouble(),
                          min: 0,
                          max: 3,
                          divisions: 3,
                          label: _getPIRLevelName(pirLevel),
                          onChanged: (value) {
                            setState(() => pirLevel = value.round());
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Off", style: TextStyle(fontSize: 12)),
                            Text("Low", style: TextStyle(fontSize: 12)),
                            Text("Mid", style: TextStyle(fontSize: 12)),
                            Text("High", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Detection Range
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Detection Range",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        SegmentedButton<int>(
                          segments: [
                            ButtonSegment(
                              value: 0,
                              label: Text("Near (1-3m)"),
                              icon: Icon(Icons.close),
                            ),
                            ButtonSegment(
                              value: 1,
                              label: Text("Far (5-8m)"),
                              icon: Icon(Icons.compare_arrows),
                            ),
                          ],
                          selected: {distanceRange},
                          onSelectionChanged: (Set<int> selection) {
                            setState(() {
                              distanceRange = selection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Humanoid Filter
                Card(
                  child: SwitchListTile(
                    title: Text("Human-Only Detection"),
                    subtitle: Text(
                      "Only trigger on human shapes (reduces false alarms)"
                    ),
                    value: humanoidFilter == 1,
                    onChanged: (value) {
                      setState(() => humanoidFilter = value ? 1 : 0);
                    },
                  ),
                ),
                
                // Video Duration
                if (videoEnabled) ...[
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Video Duration: ${videoDuration}s",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Slider(
                            value: videoDuration.toDouble(),
                            min: 5,
                            max: 60,
                            divisions: 11,
                            label: "${videoDuration}s",
                            onChanged: (value) {
                              setState(() {
                                videoDuration = value.round();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
  
  String _getPIRLevelName(int level) {
    switch (level) {
      case 0: return "Off";
      case 1: return "Low";
      case 2: return "Medium";
      case 3: return "High";
      default: return "Unknown";
    }
  }
  
  String _getPIRLevelDescription(int level) {
    switch (level) {
      case 0:
        return "PIR detection disabled";
      case 1:
        return "Low sensitivity (1-3m range). Fewer false alarms.";
      case 2:
        return "Medium sensitivity (3-5m range). Recommended for most cases.";
      case 3:
        return "High sensitivity (5-8m range). Maximum coverage, more false alarms.";
      default:
        return "";
    }
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
```

### CGI Commands - PIR

```
Get PIR Settings:
trans_cmd_string.cgi?cmd=2106&command=8&

Set PIR Push:
trans_cmd_string.cgi?cmd=2106&command=9&
  pirPushSwitch=<0|1>&
  pirPushSwitchVideo=<0|1>&
  CloudVideoDuration=<15>&
  autoRecordMode=<0>&

Get PIR Detection Level:
trans_cmd_string.cgi?cmd=2106&command=3&

Set PIR Detection:
trans_cmd_string.cgi?cmd=2106&command=4&
  humanDetection=<0-3>&
  DistanceAdjust=<0|1>&
  HumanoidDetection=<0|1>&
```

---

## 🎥 Motion Detection

### How Motion Detection Works

**Motion detection** analyzes video frames and triggers when pixels change significantly.

```
Frame 1:        Frame 2:        Difference:
┌──────┐       ┌──────┐        ┌──────┐
│      │       │  🧍  │   →    │ [🚨] │
│      │       │      │        │      │
└──────┘       └──────┘        └──────┘
No change      Person moved    ALARM!
```

### Motion Sensitivity Levels

```
Level 0-3 (Higher = More Sensitive):

Level 0:
  • Very insensitive
  • Only large, fast movements
  • Fewest false alarms

Level 1:
  • Low sensitivity
  • Normal walking speed
  • Good for indoor

Level 2:
  • Medium sensitivity (Recommended)
  • Detects most movement
  • Balance of detection/false alarms

Level 3:
  • High sensitivity
  • Detects small movements
  • More false alarms (trees, shadows)
```

### Motion Detection API

```dart
// Enable motion detection with level 2
await device.setAlarmMotionDetection(
  true,              // enable
  2,                 // sensitivity level (0-3)
  videoDuration: 15, // optional: video length
);

// Disable motion detection
await device.setAlarmMotionDetection(false, 0);
```

### Complete Motion Example

```dart
class MotionDetectionPage extends StatefulWidget {
  final CameraDevice device;
  
  MotionDetectionPage({required this.device});
  
  @override
  _MotionDetectionPageState createState() => _MotionDetectionPageState();
}

class _MotionDetectionPageState extends State<MotionDetectionPage> {
  bool motionEnabled = false;
  int motionLevel = 2;  // 0-3
  int videoDuration = 15;
  bool isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Motion Detection")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Enable/Disable
          Card(
            child: SwitchListTile(
              title: Text("Motion Detection"),
              subtitle: Text(
                motionEnabled 
                  ? "Detecting motion in video"
                  : "Motion detection disabled"
              ),
              value: motionEnabled,
              onChanged: (value) async {
                setState(() => isLoading = true);
                
                bool success = await widget.device.setAlarmMotionDetection(
                  value,
                  motionLevel,
                  videoDuration: videoDuration,
                );
                
                if (success) {
                  setState(() => motionEnabled = value);
                  _showSuccess(value ? "Motion detection enabled" : "Disabled");
                } else {
                  _showError("Failed to change motion detection");
                }
                
                setState(() => isLoading = false);
              },
            ),
          ),
          
          SizedBox(height: 16),
          
          // Sensitivity Level
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sensitivity Level",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getMotionLevelDescription(motionLevel),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Slider(
                    value: motionLevel.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: "Level $motionLevel",
                    onChanged: (value) {
                      setState(() => motionLevel = value.round());
                    },
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Apply Button
          ElevatedButton.icon(
            icon: Icon(Icons.check),
            label: Text("Apply Settings"),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(16),
            ),
            onPressed: isLoading ? null : _applySettings,
          ),
        ],
      ),
    );
  }
  
  String _getMotionLevelDescription(int level) {
    switch (level) {
      case 0: return "Very low - Only large, fast movements";
      case 1: return "Low - Normal walking speed";
      case 2: return "Medium - Most movements (Recommended)";
      case 3: return "High - Small movements, more false alarms";
      default: return "";
    }
  }
  
  Future<void> _applySettings() async {
    setState(() => isLoading = true);
    
    try {
      bool success = await widget.device.setAlarmMotionDetection(
        motionEnabled,
        motionLevel,
        videoDuration: videoDuration,
      );
      
      if (success) {
        _showSuccess("Motion settings applied");
      } else {
        _showError("Failed to apply settings");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
```

### CGI Commands - Motion

```
Set Motion Detection:
set_alarm.cgi?
  motion_armed=<0|1>&
  motion_sensitivity=<0-3>&
  CloudVideoDuration=<15>&
  schedule_enable=1&
  schedule_sun_0=<-1|0>&  [21 time slots...]
  ... (full schedule)
```

---

## 🤖 Human Detection (AI)

### How Human Detection Works

**Human detection** uses AI to identify human shapes in video, filtering out animals, objects, etc.

```
Scene Analysis:
┌──────────────────────────────┐
│  🌳  🚗  🧍  🐕  📦       │
│ Tree Car Person Dog Box     │
└──────────────────────────────┘
         ↓ AI Processing
┌──────────────────────────────┐
│  ❌  ❌   ✅   ❌  ❌       │
│           🚨 ALARM!           │
└──────────────────────────────┘
Only triggers on human
```

### Human Detection Levels

**⚠️ Note:** Human detection levels are **reversed** from PIR!

```
Level 0 (Off):
   Human detection disabled
   
Level 1 (High Sensitivity):
   • Detects humans at maximum distance
   • May have some false positives
   • Best for: Wide area monitoring
   
Level 2 (Medium Sensitivity) - Recommended:
   • Balanced detection
   • Good accuracy
   • Best for: Most applications
   
Level 3 (Low Sensitivity):
   • Only very clear human shapes
   • Fewest false alarms
   • Best for: Close-range, high-confidence needs
```

### Human Detection API

```dart
// Get current level
await device.getHumanDetectionLevel();
int currentLevel = device.humanLevel;

// Set human detection level (0=off, 1=high, 2=mid, 3=low)
await device.setHumanDetectionLevel(2);  // Medium sensitivity
```

### Complete Human Detection Example

```dart
class HumanDetectionPage extends StatefulWidget {
  final CameraDevice device;
  
  HumanDetectionPage({required this.device});
  
  @override
  _HumanDetectionPageState createState() => _HumanDetectionPageState();
}

class _HumanDetectionPageState extends State<HumanDetectionPage> {
  int humanLevel = 2;  // 0=off, 1=high, 2=mid, 3=low
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() => isLoading = true);
    
    try {
      await widget.device.getHumanDetectionLevel();
      setState(() {
        humanLevel = widget.device.humanLevel ?? 2;
      });
    } catch (e) {
      _showError("Error loading settings: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() => isLoading = true);
    
    try {
      bool success = await widget.device.setHumanDetectionLevel(humanLevel);
      
      if (success) {
        _showSuccess("Human detection level saved");
      } else {
        _showError("Failed to save settings");
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
      appBar: AppBar(
        title: Text("Human Detection (AI)"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: isLoading ? null : _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            color: Colors.purple[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        "AI-Powered Detection",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Uses on-device AI to identify humans. "
                    "Much more accurate than motion detection. "
                    "Filters out animals, vehicles, and objects.",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Sensitivity Level
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Detection Sensitivity",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getHumanLevelDescription(humanLevel),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  
                  // Level buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildLevelChip(0, "Off", Icons.block),
                      _buildLevelChip(1, "High", Icons.signal_cellular_alt),
                      _buildLevelChip(2, "Medium", Icons.signal_cellular_alt_2_bar),
                      _buildLevelChip(3, "Low", Icons.signal_cellular_alt_1_bar),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Visual Comparison
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What Gets Detected?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _buildDetectionRow("🧍 Humans", true),
                  _buildDetectionRow("🐕 Pets", false),
                  _buildDetectionRow("🚗 Vehicles", false),
                  _buildDetectionRow("🌳 Trees/Shadows", false),
                  _buildDetectionRow("📦 Objects", false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelChip(int level, String label, IconData icon) {
    bool isSelected = humanLevel == level;
    
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => humanLevel = level);
        }
      },
    );
  }
  
  Widget _buildDetectionRow(String item, bool detected) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            detected ? Icons.check_circle : Icons.cancel,
            color: detected ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(item),
        ],
      ),
    );
  }
  
  String _getHumanLevelDescription(int level) {
    switch (level) {
      case 0:
        return "Human detection disabled";
      case 1:
        return "High sensitivity - Maximum detection range, may have false positives";
      case 2:
        return "Medium sensitivity - Recommended for most cases, good balance";
      case 3:
        return "Low sensitivity - Only very clear humans, fewest false alarms";
      default:
        return "";
    }
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
```

### CGI Commands - Human Detection

```
Get Human Detection Level:
trans_cmd_string.cgi?cmd=2126&command=1&

Set Human Detection Level:
trans_cmd_string.cgi?cmd=2126&command=0&sensitive=<0-3>&

Response:
cmd=2126;command=0;sensitive=2;result=0;
```

---

## 📐 Detection Zones

### What are Detection Zones?

**Detection zones** = Define specific areas in the camera view where detection should trigger.

```
Full Frame (No Zones):        With Zones:
┌────────────────────┐        ┌────────────────────┐
│                    │        │░░░░░░░░░░░░░░░░░░░░│
│   Everything       │   →    │░░░ACTIVE ZONE░░░░░░│
│   Monitored        │        │░░░░░░░░░░░░░░░░░░░░│
│                    │        │      (Ignore)      │
└────────────────────┘        └────────────────────┘
   Many false alarms           Only important area
```

### Zone Grid System

The camera view is divided into an **18-zone grid** (6 columns × 3 rows):

```
┌───┬───┬───┬───┬───┬───┐
│ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │  Row 1
├───┼───┼───┼───┼───┼───┤
│ 6 │ 7 │ 8 │ 9 │10 │11 │  Row 2
├───┼───┼───┼───┼───┼───┤
│12 │13 │14 │15 │16 │17 │  Row 3
└───┴───┴───┴───┴───┴───┘

Zone values:
0 = Disabled (ignore this zone)
1 = Enabled (monitor this zone)
```

### Zone Configuration Examples

```dart
// Example 1: Monitor center area only
List<int> centerZone = [
  0, 0, 0, 0, 0, 0,  // Row 1: All off
  0, 1, 1, 1, 1, 0,  // Row 2: Center on
  0, 0, 0, 0, 0, 0,  // Row 3: All off
];

// Example 2: Monitor entrance (left side)
List<int> entranceZone = [
  1, 1, 0, 0, 0, 0,  // Row 1: Left side
  1, 1, 0, 0, 0, 0,  // Row 2: Left side
  1, 1, 0, 0, 0, 0,  // Row 3: Left side
];

// Example 3: Monitor entire area
List<int> fullZone = List.filled(18, 1);

// Example 4: Ignore ground (reduce false alarms)
List<int> noGroundZone = [
  1, 1, 1, 1, 1, 1,  // Row 1: Monitor
  1, 1, 1, 1, 1, 1,  // Row 2: Monitor
  0, 0, 0, 0, 0, 0,  // Row 3: Ignore ground
];
```

### Zone API

```dart
// Set motion detection zones (command=1)
await device.setAlarmZone(
  1,  // command: 1=motion, 3=human
  pd_reign0,  pd_reign1,  pd_reign2,  pd_reign3,  pd_reign4,  pd_reign5,
  pd_reign6,  pd_reign7,  pd_reign8,  pd_reign9,  pd_reign10, pd_reign11,
  pd_reign12, pd_reign13, pd_reign14, pd_reign15, pd_reign16, pd_reign17,
);

// Set human detection zones (command=3)
await device.setAlarmZone(3, ...zones);

// Get current zones
await device.getAlarmZone(1);  // Motion zones
await device.getAlarmZone(3);  // Human zones
```

### Complete Zone Editor Example

```dart
class DetectionZoneEditor extends StatefulWidget {
  final CameraDevice device;
  final int zoneType;  // 1=motion, 3=human
  
  DetectionZoneEditor({
    required this.device,
    required this.zoneType,
  });
  
  @override
  _DetectionZoneEditorState createState() => _DetectionZoneEditorState();
}

class _DetectionZoneEditorState extends State<DetectionZoneEditor> {
  List<int> zones = List.filled(18, 1);  // All enabled by default
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadZones();
  }
  
  Future<void> _loadZones() async {
    setState(() => isLoading = true);
    
    try {
      await widget.device.getAlarmZone(widget.zoneType);
      // Parse zones from response if available
      // For demo, keeping default
    } catch (e) {
      print("Error loading zones: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  Future<void> _saveZones() async {
    setState(() => isLoading = true);
    
    try {
      bool success = await widget.device.setAlarmZone(
        widget.zoneType,
        zones[0],  zones[1],  zones[2],  zones[3],  zones[4],  zones[5],
        zones[6],  zones[7],  zones[8],  zones[9],  zones[10], zones[11],
        zones[12], zones[13], zones[14], zones[15], zones[16], zones[17],
      );
      
      if (success) {
        _showSuccess("Detection zones saved");
      } else {
        _showError("Failed to save zones");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    String zoneTypeName = widget.zoneType == 1 ? "Motion" : "Human";
    
    return Scaffold(
      appBar: AppBar(
        title: Text("$zoneTypeName Detection Zones"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: isLoading ? null : _saveZones,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info
          Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Tap zones to enable/disable detection. "
                        "Green = Active, Gray = Ignored",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Zone Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1.0,
                ),
                itemCount: 18,
                itemBuilder: (context, index) {
                  bool isActive = zones[index] == 1;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        zones[index] = isActive ? 0 : 1;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green[300] : Colors.grey[300],
                        border: Border.all(
                          color: Colors.black26,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$index",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              isActive ? Icons.check : Icons.close,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Quick Presets
          Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Presets",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => _applyPreset("all"),
                          child: Text("All"),
                        ),
                        ElevatedButton(
                          onPressed: () => _applyPreset("center"),
                          child: Text("Center"),
                        ),
                        ElevatedButton(
                          onPressed: () => _applyPreset("top"),
                          child: Text("Top Half"),
                        ),
                        ElevatedButton(
                          onPressed: () => _applyPreset("clear"),
                          child: Text("Clear All"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case "all":
          zones = List.filled(18, 1);
          break;
        case "center":
          zones = [
            0, 0, 0, 0, 0, 0,
            0, 1, 1, 1, 1, 0,
            0, 0, 0, 0, 0, 0,
          ];
          break;
        case "top":
          zones = [
            1, 1, 1, 1, 1, 1,
            1, 1, 1, 1, 1, 1,
            0, 0, 0, 0, 0, 0,
          ];
          break;
        case "clear":
          zones = List.filled(18, 0);
          break;
      }
    });
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
```

### CGI Commands - Zones

```
Get Detection Zones:
trans_cmd_string.cgi?cmd=2123&command=<1|3>&
  command=1: Motion detection zones
  command=3: Human detection zones

Set Detection Zones:
trans_cmd_string.cgi?cmd=2123&command=<1|3>&
  pd_reign0=<0|1>&pd_reign1=<0|1>&...pd_reign17=<0|1>&
```

---

## ⏰ Alarm Plans (Schedules)

### What are Alarm Plans?

**Alarm plans** = Schedule when alarms are active throughout the week.

```
Example Schedule:
Monday-Friday:    08:00-18:00  → Alarms ON  (work hours)
                  18:00-08:00  → Alarms OFF (at home)

Saturday-Sunday:  All day      → Alarms OFF (weekend)
```

### 21 Time Slots Explained

The week is divided into **21 time slots** (7 days × 3 periods per day):

```
┌──────────────────────────────────────────────────────┐
│ Day       │ Slot 1  │ Slot 2  │ Slot 3              │
├──────────────────────────────────────────────────────┤
│ Monday    │   1     │   2     │   3                 │
│ Tuesday   │   4     │   5     │   6                 │
│ Wednesday │   7     │   8     │   9                 │
│ Thursday  │  10     │  11     │  12                 │
│ Friday    │  13     │  14     │  15                 │
│ Saturday  │  16     │  17     │  18                 │
│ Sunday    │  19     │  20     │  21                 │
└──────────────────────────────────────────────────────┘

Each slot = ~8 hours
```

### Slot Values

```
Format: "HHMMSS-HHMMSS"

Examples:
"000000-235959" = All day (00:00:00 to 23:59:59)
"080000-180000" = 8 AM to 6 PM
"180000-060000" = 6 PM to 6 AM (overnight)
"000000-000000" = Disabled
```

### Alarm Plan API

```dart
// Get current alarm plan
await device.getAlarmPlan(
  11,  // command: 11=get
  2,   // type: 2=alarm plan
);

// Set alarm plan
await device.setAlarmPlan(
  2,   // command: 2=set
  1,   // enable plan
  // 21 slot values (0 or encoded time ranges)
  motion_push_plan1,
  motion_push_plan2,
  // ... (21 parameters total)
  motion_push_plan21,
);
```

### Complete Alarm Plan Example

```dart
class AlarmPlanEditor extends StatefulWidget {
  final CameraDevice device;
  
  AlarmPlanEditor({required this.device});
  
  @override
  _AlarmPlanEditorState createState() => _AlarmPlanEditorState();
}

class _AlarmPlanEditorState extends State<AlarmPlanEditor> {
  bool planEnabled = true;
  List<int> slots = List.filled(21, 0);  // 0=disabled
  bool isLoading = false;
  
  final List<String> dayNames = [
    "Monday", "Tuesday", "Wednesday", "Thursday",
    "Friday", "Saturday", "Sunday"
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alarm Schedule"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: isLoading ? null : _saveSchedule,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Enable/Disable Plan
          Card(
            child: SwitchListTile(
              title: Text("Use Schedule"),
              subtitle: Text(
                planEnabled
                  ? "Alarms follow schedule below"
                  : "Alarms always active"
              ),
              value: planEnabled,
              onChanged: (value) {
                setState(() => planEnabled = value);
              },
            ),
          ),
          
          SizedBox(height: 16),
          
          // Weekly Schedule
          ...List.generate(7, (dayIndex) {
            return Card(
              child: ExpansionTile(
                title: Text(dayNames[dayIndex]),
                children: List.generate(3, (slotIndex) {
                  int slotNum = dayIndex * 3 + slotIndex;
                  bool isActive = slots[slotNum] == 1;
                  
                  return SwitchListTile(
                    title: Text("Period ${slotIndex + 1}"),
                    subtitle: Text(
                      _getSlotTime(slotIndex),
                    ),
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        slots[slotNum] = value ? 1 : 0;
                      });
                    },
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
                        onPressed: () => _applyPreset("business"),
                        child: Text("Business Hours"),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset("night"),
                        child: Text("Night Only"),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset("weekday"),
                        child: Text("Weekdays"),
                      ),
                      ElevatedButton(
                        onPressed: () => _applyPreset("off"),
                        child: Text("All Off"),
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
  
  String _getSlotTime(int slotIndex) {
    switch (slotIndex) {
      case 0: return "00:00 - 08:00";
      case 1: return "08:00 - 16:00";
      case 2: return "16:00 - 24:00";
      default: return "";
    }
  }
  
  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case "24/7":
          // All slots active
          slots = List.filled(21, 1);
          break;
          
        case "business":
          // Mon-Fri 8-18, weekends off
          slots = [
            0, 1, 0,  // Mon: Only slot 2 (8-16)
            0, 1, 0,  // Tue
            0, 1, 0,  // Wed
            0, 1, 0,  // Thu
            0, 1, 0,  // Fri
            0, 0, 0,  // Sat: All off
            0, 0, 0,  // Sun: All off
          ];
          break;
          
        case "night":
          // Only night slots
          slots = [
            1, 0, 1,  // Mon: Slot 1 & 3
            1, 0, 1,  // Tue
            1, 0, 1,  // Wed
            1, 0, 1,  // Thu
            1, 0, 1,  // Fri
            1, 0, 1,  // Sat
            1, 0, 1,  // Sun
          ];
          break;
          
        case "weekday":
          // Mon-Fri all day
          slots = [
            1, 1, 1,  // Mon
            1, 1, 1,  // Tue
            1, 1, 1,  // Wed
            1, 1, 1,  // Thu
            1, 1, 1,  // Fri
            0, 0, 0,  // Sat
            0, 0, 0,  // Sun
          ];
          break;
          
        case "off":
          // All off
          slots = List.filled(21, 0);
          break;
      }
    });
  }
  
  Future<void> _saveSchedule() async {
    setState(() => isLoading = true);
    
    try {
      bool success = await widget.device.setAlarmPlan(
        2,  // command: 2=set
        planEnabled ? 1 : 0,
        slots[0],  slots[1],  slots[2],  slots[3],  slots[4],
        slots[5],  slots[6],  slots[7],  slots[8],  slots[9],
        slots[10], slots[11], slots[12], slots[13], slots[14],
        slots[15], slots[16], slots[17], slots[18], slots[19],
        slots[20],
      );
      
      if (success) {
        _showSuccess("Alarm schedule saved");
      } else {
        _showError("Failed to save schedule");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
```

### CGI Commands - Alarm Plans

```
Get Alarm Plan:
trans_cmd_string.cgi?cmd=2017&command=11&type=2&

Set Alarm Plan:
trans_cmd_string.cgi?cmd=2017&command=2&
  motion_push_plan_enable=<0|1>&
  motion_push_plan1=<0|1>&
  motion_push_plan2=<0|1>&
  ...
  motion_push_plan21=<0|1>&
```

---

## 🎯 Best Practices

### 1. Reduce False Alarms

```dart
// Combine multiple detection methods for confirmation
Future<void> setupSmartAlarm(CameraDevice device) async {
  // Use Human Detection (most accurate)
  await device.setHumanDetectionLevel(2);  // Medium
  
  // Enable humanoid filter on PIR
  await device.setHuanoidDetection(1);
  
  // Configure zones (ignore problematic areas)
  List<int> zones = [
    1, 1, 1, 1, 1, 1,  // Monitor top
    1, 1, 1, 1, 1, 1,  // Monitor middle
    0, 0, 0, 0, 0, 0,  // Ignore ground (pets)
  ];
  await device.setAlarmZone(3, ...zones);
  
  // Use schedule (only when needed)
  // e.g., only weekdays 9-5 when office is closed
}
```

### 2. Battery-Powered Cameras

```dart
// Optimize for low power
Future<void> setupBatteryCam(CameraDevice device) async {
  // Use PIR only (lowest power)
  await device.setPriDetection(2);  // Medium sensitivity
  
  // Enable humanoid filter
  await device.setHuanoidDetection(1);
  
  // Disable continuous video recording
  await device.setPriPush(
    pushEnable: true,
    videoEnable: false,  // No video = save power
  );
  
  // Short video duration if enabled
  await device.setPriPush(
    videoDuration: 10,  // 10s instead of 30s
  );
}
```

### 3. Error Handling

```dart
Future<bool> safeAlarmConfig(
  Future<bool> Function() operation
) async {
  try {
    return await operation().timeout(
      Duration(seconds: 10),
      onTimeout: () {
        print("⏱️ Alarm config timed out");
        return false;
      },
    );
  } catch (e) {
    print("❌ Alarm config error: $e");
    return false;
  }
}
```

---

## ❓ FAQ

### Q: Which detection type should I use?

**A:** Priority order:
1. **Human Detection** (if supported) - Most accurate
2. **PIR** - Good for battery cameras
3. **Motion** - Last resort, many false alarms

### Q: How to reduce false alarms from pets?

**A:** 
- Enable humanoid filter on PIR
- Use Human Detection instead of Motion
- Configure detection zones (ignore ground level)
- Lower sensitivity levels

### Q: Can I use multiple detection types simultaneously?

**A:** ✅ Yes! You can enable PIR + Human + Motion together. The camera will trigger on any of them.

### Q: What happens when battery is low?

**A:** Camera may:
- Reduce video quality
- Shorten recording duration
- Increase PIR cooldown time
- Skip some alarm uploads

### Q: How long are alarm videos stored?

**A:** Depends on cloud storage plan:
- Free: 7 days
- Paid: 30-365 days (varies by plan)

---

## 🐛 Troubleshooting

### Issue: Too many false alarms

**Solutions:**
```dart
// 1. Lower sensitivity
await device.setPriDetection(1);  // Low instead of high

// 2. Enable humanoid filter
await device.setHuanoidDetection(1);

// 3. Use detection zones
// Exclude problem areas (trees, street, etc.)

// 4. Switch to Human Detection
await device.setHumanDetectionLevel(2);
```

### Issue: Missing alarms (not detecting events)

**Solutions:**
```dart
// 1. Increase sensitivity
await device.setPriDetection(3);  // High

// 2. Check detection zones
// Make sure target area is enabled

// 3. Verify push is enabled
await device.setPriPush(pushEnable: true);

// 4. Check alarm schedule
// Verify current time is in active slot
```

### Issue: Alarm notifications not received

**Check:**
```dart
// 1. Push enabled?
bool pushOn = device.pirPushEnable == true;

// 2. App has notification permission?
// Check device settings

// 3. Camera is online?
var state = await device.connect();

// 4. Network connection?
// Test with getStatus()
```

---

## 🎯 Summary

### Key Takeaways

```
✅ Three detection types: PIR, Motion, Human
✅ Human Detection = Most accurate (AI-powered)
✅ PIR = Best for battery cameras (low power)
✅ Detection zones = Ignore problematic areas
✅ Alarm plans = Schedule when alarms active
✅ Combine methods for best results
```

### Detection Comparison

```
PIR:
  + Low power
  + Good for indoor
  - False alarms from pets/heat

Motion:
  + Simple, works everywhere
  - Many false alarms
  - High power consumption

Human (AI):
  + Most accurate
  + Filters out non-humans
  - Higher power use
  - Requires AI chip
```

---

## 📚 Next Steps

- **[06-AI-FEATURES.md](./06-AI-FEATURES.md)** - Human tracking (uses alarms)
- **[07-PTZ-CONTROL.md](./07-PTZ-CONTROL.md)** - PTZ control
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - More examples

---

*Updated: 2024 | Version: 1.0*

