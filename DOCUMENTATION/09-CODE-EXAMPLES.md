# 💻 VEEPAI SDK - CODE EXAMPLES

> **Complete working examples cho mọi tính năng**

---

## 🚀 Quick Start - Minimal Example

### Kết nối camera và xem live (30 dòng code)

```dart
import 'package:flutter/material.dart';
import 'package:vsdk/app_player.dart';
import 'package:vsdk/camera_device/camera_device.dart';

class QuickStartPage extends StatefulWidget {
  @override
  _QuickStartPageState createState() => _QuickStartPageState();
}

class _QuickStartPageState extends State<QuickStartPage> {
  CameraDevice? device;
  AppPlayerController? player;
  
  @override
  void initState() {
    super.initState();
    _connectAndPlay();
  }
  
  Future<void> _connectAndPlay() async {
    // 1. Create device
    device = CameraDevice(
      "VE0005622QHOW",  // Device ID
      "Living Room",
      "admin",
      "888888",          // Password
      "QW6-T"
    );
    
    // 2. Connect
    var state = await device!.connect();
    if (state != CameraConnectState.connected) {
      print("❌ Failed to connect");
      return;
    }
    
    // 3. Create player
    player = AppPlayerController();
    await player!.create();
    
    // 4. Set video source
    int clientPtr = await device!.getClientPtr();
    await player!.setVideoSource(LiveVideoSource(clientPtr));
    
    // 5. Start stream
    await device!.startStream(resolution: VideoResolution.high);
    await player!.start();
    
    print("✅ Live streaming started");
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    if (player == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    // Display video
    return AppPlayerView<int>(
      controller: player!,
      fit: BoxFit.contain,
    );
  }
  
  @override
  void dispose() {
    player?.dispose();
    device?.disconnect();
    super.dispose();
  }
}
```

**Chạy:**
```bash
flutter run
```

---

## 📱 EXAMPLE 1: Device Management

### List all saved devices

```dart
class DeviceListPage extends StatefulWidget {
  @override
  _DeviceListPageState createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<Map<String, dynamic>> devices = [];
  
  @override
  void initState() {
    super.initState();
    _loadDevices();
  }
  
  Future<void> _loadDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? devicesJson = prefs.getString('devices');
    
    if (devicesJson != null) {
      setState(() {
        devices = List<Map<String, dynamic>>.from(
          json.decode(devicesJson)
        );
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Cameras")),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          var device = devices[index];
          return ListTile(
            leading: Icon(Icons.videocam),
            title: Text(device['name']),
            subtitle: Text(device['deviceId']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteDevice(index),
            ),
            onTap: () => _openLiveView(device),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        child: Icon(Icons.add),
      ),
    );
  }
  
  void _openLiveView(Map<String, dynamic> device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveViewPage(
          deviceId: device['deviceId'],
          password: device['password'],
          name: device['name'],
        ),
      ),
    );
  }
  
  void _addDevice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeviceBindPage()),
    ).then((_) => _loadDevices());
  }
  
  Future<void> _deleteDevice(int index) async {
    devices.removeAt(index);
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('devices', json.encode(devices));
    
    setState(() {});
  }
}
```

---

## 📹 EXAMPLE 2: Live Streaming with Controls

### Complete live view với controls

```dart
class LiveViewPage extends StatefulWidget {
  final String deviceId;
  final String password;
  final String name;
  
  LiveViewPage({
    required this.deviceId,
    required this.password,
    required this.name,
  });
  
  @override
  _LiveViewPageState createState() => _LiveViewPageState();
}

class _LiveViewPageState extends State<LiveViewPage> {
  CameraDevice? device;
  AppPlayerController? player;
  
  bool isConnecting = true;
  bool isAudioEnabled = false;
  bool isRecording = false;
  VideoResolution currentResolution = VideoResolution.general;
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      // Create device
      device = CameraDevice(
        widget.deviceId,
        widget.name,
        "admin",
        widget.password,
        "QW6-T"
      );
      
      // Setup listeners
      device!.addListener<CameraConnectChanged>((d, state) {
        print("Connection state: $state");
        if (state == CameraConnectState.disconnect) {
          _showError("Camera disconnected");
          Navigator.pop(context);
        }
      });
      
      device!.addListener<StatusChanged>((d, status) {
        print("Battery: ${status.batteryRate}%");
        if (status.batteryRate < 20) {
          _showWarning("Low battery: ${status.batteryRate}%");
        }
      });
      
      // Connect
      var state = await device!.connect(connectCount: 3);
      
      if (state != CameraConnectState.connected) {
        _showError("Failed to connect: $state");
        Navigator.pop(context);
        return;
      }
      
      // Create player
      player = AppPlayerController();
      await player!.create(audioRate: 8000);
      
      // Setup player callbacks
      player!.setStateChangeCallback((data, videoStatus, voiceStatus, recordStatus, touchType) {
        setState(() {
          isAudioEnabled = (voiceStatus == VoiceStatus.playing);
          isRecording = (recordStatus == RecordStatus.recording);
        });
      });
      
      player!.addProgressChangeCallback((data, totalSec, playSec, progress, loadState, velocity, timestamp) {
        // Update UI với video progress
        print("Load state: $loadState, Velocity: $velocity KB/s");
      });
      
      // Set video source
      int clientPtr = await device!.getClientPtr();
      await player!.setVideoSource(LiveVideoSource(clientPtr));
      
      // Start stream
      await device!.startStream(resolution: currentResolution);
      await player!.start();
      
      setState(() {
        isConnecting = false;
      });
      
      print("✅ Live streaming started");
      
    } catch (e) {
      _showError("Error: $e");
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isConnecting) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Connecting to ${widget.name}...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.black87,
        actions: [
          // Resolution selector
          PopupMenuButton<VideoResolution>(
            icon: Icon(Icons.settings),
            onSelected: _changeResolution,
            itemBuilder: (context) => [
              PopupMenuItem(value: VideoResolution.low, child: Text("360p")),
              PopupMenuItem(value: VideoResolution.general, child: Text("720p")),
              PopupMenuItem(value: VideoResolution.high, child: Text("1080p")),
              PopupMenuItem(value: VideoResolution.superHD, child: Text("4K")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Video player
          Expanded(
            child: player != null
                ? AppPlayerView<int>(
                    controller: player!,
                    fit: BoxFit.contain,
                  )
                : Container(),
          ),
          
          // Control buttons
          Container(
            color: Colors.black87,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Audio toggle
                IconButton(
                  icon: Icon(
                    isAudioEnabled ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                  ),
                  onPressed: _toggleAudio,
                ),
                
                // Screenshot
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: _takeScreenshot,
                ),
                
                // Record
                IconButton(
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: isRecording ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleRecording,
                ),
                
                // PTZ control
                IconButton(
                  icon: Icon(Icons.videogame_asset, color: Colors.white),
                  onPressed: _openPTZControl,
                ),
                
                // More options
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: _openMoreOptions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _changeResolution(VideoResolution resolution) async {
    if (device == null || player == null) return;
    
    try {
      // Stop current stream
      await player!.stop();
      
      // Change resolution
      await device!.changeResolution(resolution);
      
      // Restart stream
      await player!.start();
      
      setState(() {
        currentResolution = resolution;
      });
      
      _showSuccess("Resolution changed to ${_getResolutionName(resolution)}");
    } catch (e) {
      _showError("Failed to change resolution: $e");
    }
  }
  
  Future<void> _toggleAudio() async {
    if (player == null) return;
    
    if (isAudioEnabled) {
      await player!.stopVoice();
    } else {
      await player!.startVoice();
    }
  }
  
  Future<void> _takeScreenshot() async {
    if (player == null) return;
    
    String path = await _getScreenshotPath();
    bool success = await player!.screenshot(path);
    
    if (success) {
      _showSuccess("Screenshot saved to $path");
    } else {
      _showError("Failed to take screenshot");
    }
  }
  
  Future<void> _toggleRecording() async {
    if (player == null) return;
    
    if (isRecording) {
      await player!.stopRecord();
      _showSuccess("Recording stopped");
    } else {
      await player!.startRecord(
        encoderType: RecordEncoderType.G711
      );
      _showSuccess("Recording started");
    }
  }
  
  void _openPTZControl() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PTZControlWidget(device: device!),
    );
  }
  
  void _openMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => MoreOptionsWidget(device: device!),
    );
  }
  
  String _getResolutionName(VideoResolution res) {
    switch (res) {
      case VideoResolution.low: return "360p";
      case VideoResolution.general: return "720p";
      case VideoResolution.high: return "1080p";
      case VideoResolution.superHD: return "4K";
      default: return "Unknown";
    }
  }
  
  Future<String> _getScreenshotPath() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return "${appDir.path}/screenshot_$timestamp.jpg";
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
  
  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange)
    );
  }
  
  @override
  void dispose() {
    player?.dispose();
    device?.disconnect();
    super.dispose();
  }
}
```

---

## 🕹️ EXAMPLE 3: PTZ Control

### PTZ joystick control

```dart
class PTZControlWidget extends StatefulWidget {
  final CameraDevice device;
  
  PTZControlWidget({required this.device});
  
  @override
  _PTZControlWidgetState createState() => _PTZControlWidgetState();
}

class _PTZControlWidgetState extends State<PTZControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("PTZ Control", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          
          // Joystick layout
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  // Up
                  IconButton(
                    icon: Icon(Icons.arrow_upward, size: 40),
                    onPressed: () => _ptzMove("up"),
                  ),
                  
                  // Left, Home, Right
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, size: 40),
                        onPressed: () => _ptzMove("left"),
                      ),
                      IconButton(
                        icon: Icon(Icons.home, size: 40),
                        onPressed: _ptzCorrect,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward, size: 40),
                        onPressed: () => _ptzMove("right"),
                      ),
                    ],
                  ),
                  
                  // Down
                  IconButton(
                    icon: Icon(Icons.arrow_downward, size: 40),
                    onPressed: () => _ptzMove("down"),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Preset positions
          Wrap(
            spacing: 10,
            children: List.generate(8, (index) {
              return ElevatedButton(
                onPressed: () => _gotoPreset(index + 1),
                child: Text("Preset ${index + 1}"),
              );
            }),
          ),
          
          SizedBox(height: 10),
          
          // Set preset button
          ElevatedButton.icon(
            icon: Icon(Icons.add_location),
            label: Text("Save Current Position"),
            onPressed: _showSavePresetDialog,
          ),
        ],
      ),
    );
  }
  
  Future<void> _ptzMove(String direction) async {
    try {
      MotorCommand motor = widget.device.motorCommand!;
      
      switch (direction) {
        case "up":
          await motor.up();
          break;
        case "down":
          await motor.down();
          break;
        case "left":
          await motor.left();
          break;
        case "right":
          await motor.right();
          break;
      }
      
      // Auto stop sau 200ms
      await Future.delayed(Duration(milliseconds: 200));
      // Camera tự động stop khi hết command timeout
      
    } catch (e) {
      print("PTZ move error: $e");
    }
  }
  
  Future<void> _ptzCorrect() async {
    try {
      await widget.device.motorCommand!.ptzCorrect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Returning to home position..."))
      );
    } catch (e) {
      print("PTZ correct error: $e");
    }
  }
  
  Future<void> _gotoPreset(int index) async {
    try {
      await widget.device.motorCommand!.toPresetLocation(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Moving to preset $index..."))
      );
    } catch (e) {
      print("Goto preset error: $e");
    }
  }
  
  void _showSavePresetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Save Preset Position"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(8, (index) {
            return ListTile(
              title: Text("Preset ${index + 1}"),
              onTap: () {
                _savePreset(index + 1);
                Navigator.pop(context);
              },
            );
          }),
        ),
      ),
    );
  }
  
  Future<void> _savePreset(int index) async {
    try {
      await widget.device.motorCommand!.setPresetLocation(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preset $index saved"), backgroundColor: Colors.green)
      );
    } catch (e) {
      print("Save preset error: $e");
    }
  }
}
```

---

## 💾 EXAMPLE 4: TF Card Playback

### Browse và play TF card recordings

```dart
class TFCardPlaybackPage extends StatefulWidget {
  final CameraDevice device;
  
  TFCardPlaybackPage({required this.device});
  
  @override
  _TFCardPlaybackPageState createState() => _TFCardPlaybackPageState();
}

class _TFCardPlaybackPageState extends State<TFCardPlaybackPage> {
  List<CardFileInfo> recordings = [];
  bool isLoading = true;
  AppPlayerController? player;
  
  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }
  
  Future<void> _loadRecordings() async {
    try {
      // Get file list from camera
      List<CardFileInfo> files = await widget.device.getCardFileList(
        startTime: DateTime.now().subtract(Duration(days: 7)),
        endTime: DateTime.now(),
      );
      
      setState(() {
        recordings = files;
        isLoading = false;
      });
      
    } catch (e) {
      print("Error loading recordings: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TF Card Recordings")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : recordings.isEmpty
              ? Center(child: Text("No recordings found"))
              : ListView.builder(
                  itemCount: recordings.length,
                  itemBuilder: (context, index) {
                    var file = recordings[index];
                    return ListTile(
                      leading: Icon(Icons.videocam),
                      title: Text(file.filename),
                      subtitle: Text(
                        "${_formatDateTime(file.startTime)} - "
                        "${_formatFileSize(file.size)}"
                      ),
                      trailing: Icon(Icons.play_arrow),
                      onTap: () => _playRecording(file),
                    );
                  },
                ),
    );
  }
  
  Future<void> _playRecording(CardFileInfo file) async {
    // Create player if not exists
    if (player == null) {
      player = AppPlayerController();
      await player!.create();
    }
    
    // Set source
    int clientPtr = await widget.device.getClientPtr();
    await player!.setVideoSource(
      CardVideoSource(clientPtr, file.size)
    );
    
    // Request playback
    await widget.device.startCardPlayback(
      filename: file.filename,
      offset: 0,
    );
    
    // Start player
    await player!.start();
    
    // Navigate to playback page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaybackViewPage(
          player: player!,
          file: file,
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-"
           "${dt.day.toString().padLeft(2, '0')} "
           "${dt.hour.toString().padLeft(2, '0')}:"
           "${dt.minute.toString().padLeft(2, '0')}";
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
  
  @override
  void dispose() {
    player?.dispose();
    super.dispose();
  }
}

class PlaybackViewPage extends StatefulWidget {
  final AppPlayerController player;
  final CardFileInfo file;
  
  PlaybackViewPage({required this.player, required this.file});
  
  @override
  _PlaybackViewPageState createState() => _PlaybackViewPageState();
}

class _PlaybackViewPageState extends State<PlaybackViewPage> {
  int totalSeconds = 0;
  int playSeconds = 0;
  double progress = 0.0;
  bool isPlaying = true;
  
  @override
  void initState() {
    super.initState();
    
    // Listen to progress
    widget.player.addProgressChangeCallback((data, total, play, prog, loadState, velocity, timestamp) {
      setState(() {
        totalSeconds = total;
        playSeconds = play;
        progress = prog.toDouble();
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.file.filename),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Video player
          Expanded(
            child: AppPlayerView<int>(
              controller: widget.player,
              fit: BoxFit.contain,
            ),
          ),
          
          // Progress bar
          Container(
            color: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Time display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(playSeconds),
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      _formatDuration(totalSeconds),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                
                // Slider
                Slider(
                  value: progress,
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    // Seek to position
                    int seekSeconds = (totalSeconds * value / 100).round();
                    widget.player.setProgress(seekSeconds);
                  },
                ),
                
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Speed control
                    IconButton(
                      icon: Icon(Icons.slow_motion_video, color: Colors.white),
                      onPressed: () => _setSpeed(0.5),
                    ),
                    
                    // Play/Pause
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    
                    // Fast forward
                    IconButton(
                      icon: Icon(Icons.fast_forward, color: Colors.white),
                      onPressed: () => _setSpeed(2.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await widget.player.pause();
    } else {
      await widget.player.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }
  
  Future<void> _setSpeed(double speed) async {
    await widget.player.setSpeed(speed);
  }
  
  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:"
             "${minutes.toString().padLeft(2, '0')}:"
             "${secs.toString().padLeft(2, '0')}";
    } else {
      return "${minutes.toString().padLeft(2, '0')}:"
             "${secs.toString().padLeft(2, '0')}";
    }
  }
}
```

---

## 🤖 EXAMPLE 5: AI Features Control

### Human detection & tracking

```dart
class AIFeaturesPage extends StatefulWidget {
  final CameraDevice device;
  
  AIFeaturesPage({required this.device});
  
  @override
  _AIFeaturesPageState createState() => _AIFeaturesPageState();
}

class _AIFeaturesPageState extends State<AIFeaturesPage> {
  bool humanTrackingEnabled = false;
  bool humanFramingEnabled = false;
  bool humanZoomEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _loadAISettings();
  }
  
  Future<void> _loadAISettings() async {
    if (widget.device.aiCommand?.humanTracking == null) {
      print("⚠️ AI features not supported on this camera");
      return;
    }
    
    try {
      // Get current settings
      bool tracking = await widget.device.aiCommand!.humanTracking!.getHumanTracking();
      bool framing = await widget.device.aiCommand!.humanFraming!.getHumanFraming();
      bool zoom = await widget.device.aiCommand!.humanZoom!.getHumanZoom();
      
      setState(() {
        humanTrackingEnabled = tracking;
        humanFramingEnabled = framing;
        humanZoomEnabled = zoom;
      });
    } catch (e) {
      print("Error loading AI settings: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Features")),
      body: ListView(
        children: [
          // Human Tracking
          SwitchListTile(
            title: Text("Human Tracking"),
            subtitle: Text("Camera follows detected person"),
            value: humanTrackingEnabled,
            onChanged: (value) async {
              await _setHumanTracking(value);
            },
          ),
          
          Divider(),
          
          // Human Framing
          SwitchListTile(
            title: Text("Human Framing"),
            subtitle: Text("Auto-adjust frame to keep person centered"),
            value: humanFramingEnabled,
            onChanged: (value) async {
              await _setHumanFraming(value);
            },
          ),
          
          Divider(),
          
          // Human Zoom
          SwitchListTile(
            title: Text("Human Zoom"),
            subtitle: Text("Auto-zoom on detected person"),
            value: humanZoomEnabled,
            onChanged: (value) async {
              await _setHumanZoom(value);
            },
          ),
          
          Divider(),
          
          // AI Detection Plans
          ListTile(
            title: Text("AI Detection Plans"),
            subtitle: Text("Configure schedule for AI features"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AIDetectionPlanPage(
                    device: widget.device
                  ),
                ),
              );
            },
          ),
          
          Divider(),
          
          // Custom Alarm Sounds
          ListTile(
            title: Text("Custom Alarm Sounds"),
            subtitle: Text("Configure sounds for different detections"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomSoundsPage(
                    device: widget.device
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _setHumanTracking(bool enabled) async {
    try {
      await widget.device.aiCommand!.humanTracking!.setHumanTracking(enabled);
      setState(() {
        humanTrackingEnabled = enabled;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Human tracking ${enabled ? 'enabled' : 'disabled'}"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error setting human tracking: $e");
    }
  }
  
  Future<void> _setHumanFraming(bool enabled) async {
    try {
      await widget.device.aiCommand!.humanFraming!.setHumanFraming(enabled);
      setState(() {
        humanFramingEnabled = enabled;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Human framing ${enabled ? 'enabled' : 'disabled'}"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error setting human framing: $e");
    }
  }
  
  Future<void> _setHumanZoom(bool enabled) async {
    try {
      await widget.device.aiCommand!.humanZoom!.setHumanZoom(enabled);
      setState(() {
        humanZoomEnabled = enabled;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Human zoom ${enabled ? 'enabled' : 'disabled'}"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error setting human zoom: $e");
    }
  }
}
```

---

## 🔔 EXAMPLE 6: Alarm Management

### Configure motion detection & alarms

```dart
class AlarmSettingsPage extends StatefulWidget {
  final CameraDevice device;
  
  AlarmSettingsPage({required this.device});
  
  @override
  _AlarmSettingsPageState createState() => _AlarmSettingsPageState();
}

class _AlarmSettingsPageState extends State<AlarmSettingsPage> {
  bool pushEnabled = false;
  bool videoEnabled = false;
  int motionLevel = 50;
  int humanLevel = 50;
  int videoDuration = 10;
  
  @override
  void initState() {
    super.initState();
    _loadAlarmSettings();
  }
  
  Future<void> _loadAlarmSettings() async {
    try {
      var alarmParam = await widget.device.alarmCommand!.getAlarmParam();
      
      setState(() {
        pushEnabled = alarmParam.pushEnable;
        videoEnabled = alarmParam.videoEnable;
        motionLevel = alarmParam.motionLevel;
        humanLevel = alarmParam.humanLevel;
        videoDuration = alarmParam.videoDuration;
      });
    } catch (e) {
      print("Error loading alarm settings: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Alarm Settings")),
      body: ListView(
        children: [
          // Push notification
          SwitchListTile(
            title: Text("Push Notifications"),
            subtitle: Text("Receive alarm notifications on your phone"),
            value: pushEnabled,
            onChanged: (value) async {
              await widget.device.alarmCommand!.setPushEnable(value);
              setState(() => pushEnabled = value);
            },
          ),
          
          // Video recording
          SwitchListTile(
            title: Text("Video Recording on Alarm"),
            subtitle: Text("Record video clip when alarm triggered"),
            value: videoEnabled,
            onChanged: (value) async {
              await widget.device.alarmCommand!.setVideoEnable(value);
              setState(() => videoEnabled = value);
            },
          ),
          
          Divider(),
          
          // Motion detection level
          ListTile(
            title: Text("Motion Detection Sensitivity"),
            subtitle: Slider(
              value: motionLevel.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: "$motionLevel%",
              onChanged: (value) {
                setState(() => motionLevel = value.round());
              },
              onChangeEnd: (value) async {
                await widget.device.alarmCommand!.setMotionLevel(value.round());
              },
            ),
          ),
          
          // Human detection level
          ListTile(
            title: Text("Human Detection Sensitivity"),
            subtitle: Slider(
              value: humanLevel.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              label: "$humanLevel%",
              onChanged: (value) {
                setState(() => humanLevel = value.round());
              },
              onChangeEnd: (value) async {
                await widget.device.alarmCommand!.setHumanDetectionLevel(value.round());
              },
            ),
          ),
          
          // Video duration
          ListTile(
            title: Text("Alarm Video Duration"),
            subtitle: Text("$videoDuration seconds"),
            trailing: DropdownButton<int>(
              value: videoDuration,
              items: [5, 10, 15, 20, 30].map((sec) {
                return DropdownMenuItem(
                  value: sec,
                  child: Text("$sec sec"),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  await widget.device.alarmCommand!.setVideoDuration(value);
                  setState(() => videoDuration = value);
                }
              },
            ),
          ),
          
          Divider(),
          
          // Detection zones
          ListTile(
            title: Text("Detection Zones"),
            subtitle: Text("Configure areas for motion detection"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetectionZonesPage(
                    device: widget.device
                  ),
                ),
              );
            },
          ),
          
          // Alarm schedule
          ListTile(
            title: Text("Alarm Schedule"),
            subtitle: Text("Set when alarms are active"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlarmSchedulePage(
                    device: widget.device
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 Summary - Key Patterns

### Best Practices từ Examples

```dart
✅ Always dispose resources:
  @override
  void dispose() {
    player?.dispose();
    device?.disconnect();
    super.dispose();
  }

✅ Handle connection states:
  device.addListener<CameraConnectChanged>((d, state) {
    if (state == CameraConnectState.disconnect) {
      // Handle disconnect
    }
  });

✅ Show user feedback:
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Success!"))
  );

✅ Use try-catch for network operations:
  try {
    await device.connect();
  } catch (e) {
    _showError("Connection failed: $e");
  }

✅ Setup callbacks before starting:
  player.setStateChangeCallback(...);
  player.addProgressChangeCallback(...);
  await player.start();
```

---

## 📚 Next Steps

- **[10-BEST-PRACTICES.md](./10-BEST-PRACTICES.md)** - Best practices & optimization
- **[12-TROUBLESHOOTING.md](./12-TROUBLESHOOTING.md)** - Common issues
- **[13-API-REFERENCE.md](./13-API-REFERENCE.md)** - Complete API reference

---

*Updated: 2024 | Version: 1.0*

