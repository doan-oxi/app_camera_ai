# 🕹️ VEEPAI SDK - PTZ CONTROL GUIDE

> **Complete guide to Pan-Tilt-Zoom control**  
> From basic movements to advanced cruise modes

---

## 🎯 What is PTZ?

**PTZ** stands for **Pan-Tilt-Zoom**:

```
PAN   = Rotate left/right (horizontal) ←→
TILT  = Rotate up/down (vertical)      ↑↓
ZOOM  = Zoom in/out                     +−
```

### Why PTZ is Important

```
✅ Wide Coverage:
   Single PTZ camera covers area of 4-6 fixed cameras

✅ Track Movement:
   Follow people/vehicles automatically

✅ Flexible Monitoring:
   Remote operator controls view

✅ Preset Positions:
   Save important views, return instantly

✅ Auto Cruise:
   Patrol multiple areas automatically
```

### PTZ vs Fixed Camera

```
Fixed Camera:              PTZ Camera:
┌────────────┐            ┌────────────┐
│  ├──────┤  │            │  ┌──────┐  │
│            │            │  │←→↑↓+−│ │
│  Static    │            │  └──────┘  │
│   View     │            │  360° Pan  │
└────────────┘            └────────────┘
60-110° FOV              Can see entire room
```

---

## 📊 PTZ Commands Overview

### Command Types

```dart
// Basic Movements (single step)
await device.motorCommand!.up();        // Tilt up
await device.motorCommand!.down();      // Tilt down
await device.motorCommand!.left();      // Pan left
await device.motorCommand!.right();     // Pan right

// Continuous Movements (start/stop)
await device.motorCommand!.startUp();   // Start moving up
await device.motorCommand!.stopUp();    // Stop moving

// Preset Positions
await device.motorCommand!.setPresetLocation(1);   // Save position
await device.motorCommand!.toPresetLocation(1);    // Go to position

// Cruise Modes
await device.motorCommand!.startPresetCruise();    // Auto patrol
await device.motorCommand!.stopPresetCruise();     // Stop patrol

// Home Position
await device.motorCommand!.ptzCorrect();           // Return to default
```

---

## 🎮 Basic Movements

### Single-Step Movement

**One step = Small movement** (e.g., 5-10 degrees)

```dart
// Move up one step
await device.motorCommand!.up();

// CGI: decoder_control.cgi?command=0&onestep=1&
```

### CGI Command Reference

```
┌──────────────────────────────────────────────────┐
│ Direction │ Command │ CGI Parameter              │
├──────────────────────────────────────────────────┤
│ Up        │ 0       │ command=0&onestep=1&       │
│ Down      │ 2       │ command=2&onestep=1&       │
│ Left      │ 4       │ command=4&onestep=1&       │
│ Right     │ 6       │ command=6&onestep=1&       │
│ Home      │ 25      │ command=25&onestep=0&      │
└──────────────────────────────────────────────────┘
```

### Visual Representation

```
          [UP]
           ↑
    [LEFT] ← • → [RIGHT]
           ↓
         [DOWN]

      [HOME] (center)
```

### Code Example - Basic Joystick

```dart
class BasicPTZControl extends StatelessWidget {
  final CameraDevice device;
  
  BasicPTZControl({required this.device});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Up Button
        IconButton(
          icon: Icon(Icons.arrow_upward, size: 48),
          onPressed: () async {
            await device.motorCommand!.up();
          },
        ),
        
        // Left, Home, Right Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, size: 48),
              onPressed: () async {
                await device.motorCommand!.left();
              },
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.home, size: 48),
              onPressed: () async {
                await device.motorCommand!.ptzCorrect();
              },
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.arrow_forward, size: 48),
              onPressed: () async {
                await device.motorCommand!.right();
              },
            ),
          ],
        ),
        
        // Down Button
        IconButton(
          icon: Icon(Icons.arrow_downward, size: 48),
          onPressed: () async {
            await device.motorCommand!.down();
          },
        ),
      ],
    );
  }
}
```

---

## 🎯 Continuous Movement

### Start/Stop Control

For **smooth, long-distance** movements, use continuous mode:

```dart
// Start moving left
await device.motorCommand!.startLeft();

// Camera keeps rotating left...

// Stop when desired
await device.motorCommand!.stopLeft();
```

### CGI Commands

```
┌──────────────────────────────────────────────────────┐
│ Action      │ Command │ CGI Parameter                │
├──────────────────────────────────────────────────────┤
│ Start Up    │ 0       │ command=0&onestep=0&         │
│ Stop Up     │ 1       │ command=1&onestep=0&         │
│ Start Down  │ 2       │ command=2&onestep=0&         │
│ Stop Down   │ 3       │ command=3&onestep=0&         │
│ Start Left  │ 4       │ command=4&onestep=0&         │
│ Stop Left   │ 5       │ command=5&onestep=0&         │
│ Start Right │ 6       │ command=6&onestep=0&         │
│ Stop Right  │ 7       │ command=7&onestep=0&         │
└──────────────────────────────────────────────────────┘
```

### Motor Speed Control

```dart
// Fast movement
await device.motorCommand!.startLeft(motorSpeed: 9);  // Max speed

// Slow movement
await device.motorCommand!.startLeft(motorSpeed: 1);  // Min speed

// Default (medium)
await device.motorCommand!.startLeft();  // Speed ~5
```

### Complete Example - Continuous Control

```dart
class ContinuousPTZControl extends StatefulWidget {
  final CameraDevice device;
  
  ContinuousPTZControl({required this.device});
  
  @override
  _ContinuousPTZControlState createState() => _ContinuousPTZControlState();
}

class _ContinuousPTZControlState extends State<ContinuousPTZControl> {
  bool isMovingUp = false;
  bool isMovingDown = false;
  bool isMovingLeft = false;
  bool isMovingRight = false;
  int motorSpeed = 5;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Speed Slider
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Motor Speed: $motorSpeed"),
              Slider(
                value: motorSpeed.toDouble(),
                min: 1,
                max: 9,
                divisions: 8,
                label: motorSpeed.toString(),
                onChanged: (value) {
                  setState(() => motorSpeed = value.round());
                },
              ),
            ],
          ),
        ),
        
        // Control Pad
        Column(
          children: [
            // Up
            GestureDetector(
              onTapDown: (_) => _startMoving('up'),
              onTapUp: (_) => _stopMoving('up'),
              onTapCancel: () => _stopMoving('up'),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isMovingUp ? Colors.blue : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Left, Center, Right
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left
                GestureDetector(
                  onTapDown: (_) => _startMoving('left'),
                  onTapUp: (_) => _stopMoving('left'),
                  onTapCancel: () => _stopMoving('left'),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isMovingLeft ? Colors.blue : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(width: 40),
                
                // Home
                GestureDetector(
                  onTap: () async {
                    await widget.device.motorCommand!.ptzCorrect();
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(width: 40),
                
                // Right
                GestureDetector(
                  onTapDown: (_) => _startMoving('right'),
                  onTapUp: (_) => _stopMoving('right'),
                  onTapCancel: () => _stopMoving('right'),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isMovingRight ? Colors.blue : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Down
            GestureDetector(
              onTapDown: (_) => _startMoving('down'),
              onTapUp: (_) => _stopMoving('down'),
              onTapCancel: () => _stopMoving('down'),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isMovingDown ? Colors.blue : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_downward,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Future<void> _startMoving(String direction) async {
    setState(() {
      switch (direction) {
        case 'up': isMovingUp = true; break;
        case 'down': isMovingDown = true; break;
        case 'left': isMovingLeft = true; break;
        case 'right': isMovingRight = true; break;
      }
    });
    
    try {
      switch (direction) {
        case 'up':
          await widget.device.motorCommand!.startUp(motorSpeed: motorSpeed);
          break;
        case 'down':
          await widget.device.motorCommand!.startDown(motorSpeed: motorSpeed);
          break;
        case 'left':
          await widget.device.motorCommand!.startLeft(motorSpeed: motorSpeed);
          break;
        case 'right':
          await widget.device.motorCommand!.startRight(motorSpeed: motorSpeed);
          break;
      }
    } catch (e) {
      print("Error starting movement: $e");
    }
  }
  
  Future<void> _stopMoving(String direction) async {
    setState(() {
      switch (direction) {
        case 'up': isMovingUp = false; break;
        case 'down': isMovingDown = false; break;
        case 'left': isMovingLeft = false; break;
        case 'right': isMovingRight = false; break;
      }
    });
    
    try {
      switch (direction) {
        case 'up':
          await widget.device.motorCommand!.stopUp();
          break;
        case 'down':
          await widget.device.motorCommand!.stopDown();
          break;
        case 'left':
          await widget.device.motorCommand!.stopLeft();
          break;
        case 'right':
          await widget.device.motorCommand!.stopRight();
          break;
      }
    } catch (e) {
      print("Error stopping movement: $e");
    }
  }
}
```

---

## 📍 Preset Positions

### What are Presets?

**Preset positions** = Saved camera positions you can return to instantly.

```
Example:
Preset 1: Main entrance
Preset 2: Parking lot
Preset 3: Loading dock
Preset 4: Hallway
Preset 5: Storage area

→ One tap to switch between views
```

### Preset Operations

```dart
// Save current position as preset 1
await device.motorCommand!.setPresetLocation(1);

// Go to preset 1
await device.motorCommand!.toPresetLocation(1);

// Delete preset 1
await device.motorCommand!.deletePresetLocation(1);
```

### Preset Index Mapping

```
┌────────────────────────────────────────────────┐
│ Index │ Set Cmd │ Go Cmd │ Delete Cmd         │
├────────────────────────────────────────────────┤
│ 0     │ 30      │ 31     │ 62                 │
│ 1     │ 32      │ 33     │ 63                 │
│ 2     │ 34      │ 35     │ 64                 │
│ 3     │ 36      │ 37     │ 65                 │
│ 4     │ 38      │ 39     │ 66                 │
└────────────────────────────────────────────────┘

Total: 5 preset positions (0-4)
```

### Complete Example - Preset Manager

```dart
class PresetManager extends StatefulWidget {
  final CameraDevice device;
  
  PresetManager({required this.device});
  
  @override
  _PresetManagerState createState() => _PresetManagerState();
}

class _PresetManagerState extends State<PresetManager> {
  List<String> presetNames = [
    "Preset 1",
    "Preset 2",
    "Preset 3",
    "Preset 4",
    "Preset 5",
  ];
  
  @override
  void initState() {
    super.initState();
    _loadPresetNames();
  }
  
  Future<void> _loadPresetNames() async {
    // Load saved names from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 5; i++) {
      String? name = prefs.getString('preset_${widget.device.id}_$i');
      if (name != null) {
        presetNames[i] = name;
      }
    }
    setState(() {});
  }
  
  Future<void> _savePresetName(int index, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('preset_${widget.device.id}_$index', name);
    setState(() {
      presetNames[index] = name;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preset Positions")),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text("${index + 1}"),
              ),
              title: Text(presetNames[index]),
              subtitle: Text("Tap to go, long press to set/delete"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Go to preset
                  IconButton(
                    icon: Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () => _gotoPreset(index),
                    tooltip: "Go to this position",
                  ),
                  // Set preset
                  IconButton(
                    icon: Icon(Icons.save, color: Colors.blue),
                    onPressed: () => _setPreset(index),
                    tooltip: "Save current position",
                  ),
                  // Delete preset
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePreset(index),
                    tooltip: "Delete this preset",
                  ),
                ],
              ),
              onTap: () => _gotoPreset(index),
              onLongPress: () => _renamePreset(index),
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _gotoPreset(int index) async {
    try {
      bool success = await widget.device.motorCommand!.toPresetLocation(index);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Going to ${presetNames[index]}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Preset not set or error occurred"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _setPreset(int index) async {
    try {
      bool success = await widget.device.motorCommand!.setPresetLocation(index);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Current position saved as ${presetNames[index]}"),
            backgroundColor: Colors.green,
          ),
        );
        
        // Prompt to rename
        _renamePreset(index);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save preset"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error setting preset: $e");
    }
  }
  
  Future<void> _deletePreset(int index) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Preset"),
        content: Text("Delete ${presetNames[index]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete"),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        bool success = await widget.device.motorCommand!
            .deletePresetLocation(index);
        
        if (success) {
          // Reset name
          _savePresetName(index, "Preset ${index + 1}");
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Preset deleted"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print("Error deleting preset: $e");
      }
    }
  }
  
  void _renamePreset(int index) {
    TextEditingController controller = TextEditingController(
      text: presetNames[index]
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rename Preset"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter name",
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _savePresetName(index, controller.text);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔄 Cruise Modes

### What is Cruise?

**Cruise** = Camera automatically patrols between positions/areas.

```
Types of Cruise:
1. Preset Cruise    → Tour saved preset positions
2. Up/Down Cruise   → Scan vertically
3. Left/Right Cruise → Scan horizontally
4. Circle Loop      → Rotate 360°
5. Up/Down Loop     → Vertical sweep loop
6. Polyline Loop    → Custom path
```

### 1. Preset Cruise

Automatically tour through saved preset positions:

```dart
// Start touring presets
await device.motorCommand!.startPresetCruise();

// Camera visits: Preset 1 → Preset 2 → Preset 3 → ... → Preset 1

// Stop cruise
await device.motorCommand!.stopPresetCruise();
```

**CGI Commands:**
```
Start: decoder_control.cgi?command=22&onestep=0&
Stop:  decoder_control.cgi?command=23&onestep=0&
```

### 2. Up/Down Cruise

Scan vertically (tilt up/down repeatedly):

```dart
// Start up/down scanning
await device.motorCommand!.startUpAndDown();

// Camera: ↑ ↓ ↑ ↓ ↑ ↓ ...

// Stop
await device.motorCommand!.stopUpAndDown();
```

**CGI Commands:**
```
Start: decoder_control.cgi?command=26&onestep=0&
Stop:  decoder_control.cgi?command=27&onestep=0&
```

### 3. Left/Right Cruise

Scan horizontally (pan left/right repeatedly):

```dart
// Start left/right scanning
await device.motorCommand!.startLeftAndRight();

// Camera: ← → ← → ← → ...

// Stop
await device.motorCommand!.stopLeftAndRight();
```

**CGI Commands:**
```
Start: decoder_control.cgi?command=28&onestep=0&
Stop:  decoder_control.cgi?command=29&onestep=0&
```

### 4. Circle Loop

Rotate 360° continuously:

```dart
// Start 360° rotation
await device.motorCommand!.startCircleLoop();

// Camera: ↻ (clockwise rotation)
```

**CGI Command:**
```
Start: decoder_control.cgi?command=80&onestep=0&
```

### 5. Up/Down Loop

Vertical sweep in a loop:

```dart
await device.motorCommand!.startUpAndDownLoop();
```

**CGI Command:**
```
Start: decoder_control.cgi?command=79&onestep=0&
```

### 6. Polyline Loop

Follow a custom recorded path:

```dart
await device.motorCommand!.startPolylineLoop();
```

**CGI Command:**
```
Start: decoder_control.cgi?command=78&onestep=0&
```

### Complete Example - Cruise Control

```dart
class CruiseControl extends StatefulWidget {
  final CameraDevice device;
  
  CruiseControl({required this.device});
  
  @override
  _CruiseControlState createState() => _CruiseControlState();
}

class _CruiseControlState extends State<CruiseControl> {
  String? activeCruise;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cruise Modes")),
      body: ListView(
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
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "About Cruise Modes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Cruise modes automatically patrol different areas. "
                    "Tap a mode to start, tap again to stop.",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Cruise Mode Buttons
          _buildCruiseButton(
            "Preset Cruise",
            "Tour saved preset positions",
            Icons.location_on,
            "preset",
          ),
          
          _buildCruiseButton(
            "Up/Down Scan",
            "Vertical scanning patrol",
            Icons.swap_vert,
            "updown",
          ),
          
          _buildCruiseButton(
            "Left/Right Scan",
            "Horizontal scanning patrol",
            Icons.swap_horiz,
            "leftright",
          ),
          
          _buildCruiseButton(
            "360° Circle",
            "Continuous clockwise rotation",
            Icons.loop,
            "circle",
          ),
          
          _buildCruiseButton(
            "Up/Down Loop",
            "Vertical sweep loop",
            Icons.unfold_more,
            "updownloop",
          ),
          
          _buildCruiseButton(
            "Polyline Loop",
            "Follow custom recorded path",
            Icons.timeline,
            "polyline",
          ),
        ],
      ),
    );
  }
  
  Widget _buildCruiseButton(
    String title,
    String subtitle,
    IconData icon,
    String cruiseId,
  ) {
    bool isActive = activeCruise == cruiseId;
    
    return Card(
      color: isActive ? Colors.green[50] : null,
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: isActive ? Colors.green : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isActive
            ? Chip(
                label: Text("Active"),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              )
            : null,
        onTap: () {
          if (isActive) {
            _stopCruise(cruiseId);
          } else {
            _startCruise(cruiseId);
          }
        },
      ),
    );
  }
  
  Future<void> _startCruise(String cruiseId) async {
    // Stop any active cruise first
    if (activeCruise != null) {
      await _stopCruise(activeCruise!);
    }
    
    try {
      bool success = false;
      
      switch (cruiseId) {
        case "preset":
          success = await widget.device.motorCommand!.startPresetCruise();
          break;
        case "updown":
          success = await widget.device.motorCommand!.startUpAndDown();
          break;
        case "leftright":
          success = await widget.device.motorCommand!.startLeftAndRight();
          break;
        case "circle":
          success = await widget.device.motorCommand!.startCircleLoop();
          break;
        case "updownloop":
          success = await widget.device.motorCommand!.startUpAndDownLoop();
          break;
        case "polyline":
          success = await widget.device.motorCommand!.startPolylineLoop();
          break;
      }
      
      if (success) {
        setState(() {
          activeCruise = cruiseId;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cruise started"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to start cruise"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error starting cruise: $e");
    }
  }
  
  Future<void> _stopCruise(String cruiseId) async {
    try {
      bool success = false;
      
      switch (cruiseId) {
        case "preset":
          success = await widget.device.motorCommand!.stopPresetCruise();
          break;
        case "updown":
          success = await widget.device.motorCommand!.stopUpAndDown();
          break;
        case "leftright":
          success = await widget.device.motorCommand!.stopLeftAndRight();
          break;
        // Note: Circle, UpDownLoop, PolylineLoop typically use stopPresetCruise
        case "circle":
        case "updownloop":
        case "polyline":
          success = await widget.device.motorCommand!.stopPresetCruise();
          break;
      }
      
      if (success) {
        setState(() {
          activeCruise = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cruise stopped"),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print("Error stopping cruise: $e");
    }
  }
}
```

---

## 🏠 Guard Position (Auto-Return)

### What is Guard Position?

**Guard position** = Default position camera returns to after inactivity.

```
Scenario:
1. User manually controls PTZ
2. After 30 seconds of no movement
3. Camera automatically returns to guard position
4. Useful for maintaining default view
```

### Set Guard Position

```dart
// Set current position as guard position
await device.motorCommand!.configCameraSensorGuard(1);

// Disable guard position
await device.motorCommand!.configCameraSensorGuard(0);

// Guard positions: 1-16 available
```

**CGI Command:**
```
set_sensor_preset.cgi?sensorid=255&presetid=<1-16>&

presetid=0: Disable guard
presetid=1-16: Set guard to corresponding position
```

---

## 🎯 Best Practices

### 1. Error Handling

```dart
Future<bool> safePTZOperation(Future<bool> Function() operation) async {
  try {
    return await operation().timeout(
      Duration(seconds: 5),
      onTimeout: () {
        print("⏱️ PTZ operation timed out");
        return false;
      },
    );
  } catch (e) {
    print("❌ PTZ error: $e");
    return false;
  }
}

// Usage
bool success = await safePTZOperation(() => 
  device.motorCommand!.left()
);
```

### 2. Prevent Rapid Commands

```dart
DateTime? lastPTZCommand;

Future<void> ptzWithDebounce(Future<void> Function() command) async {
  DateTime now = DateTime.now();
  
  if (lastPTZCommand != null) {
    Duration diff = now.difference(lastPTZCommand!);
    if (diff.inMilliseconds < 200) {
      print("⚠️ Too fast, skipping command");
      return;
    }
  }
  
  lastPTZCommand = now;
  await command();
}
```

### 3. Check PTZ Support

```dart
Future<bool> checkPTZSupport(CameraDevice device) async {
  StatusResult status = await device.getStatus();
  
  if (device.motorCommand == null) {
    print("❌ Camera does not support PTZ");
    return false;
  }
  
  // Check guard position support
  bool hasGuard = status.support_ptz_guard == "1";
  print("Guard position: ${hasGuard ? 'Supported' : 'Not supported'}");
  
  return true;
}
```

### 4. Stop Before New Movement

```dart
Future<void> changeDirection(String newDirection) async {
  // Stop all movements first
  await device.motorCommand!.stopUp();
  await device.motorCommand!.stopDown();
  await device.motorCommand!.stopLeft();
  await device.motorCommand!.stopRight();
  
  // Small delay
  await Future.delayed(Duration(milliseconds: 100));
  
  // Start new movement
  switch (newDirection) {
    case 'up':
      await device.motorCommand!.startUp();
      break;
    // ... etc
  }
}
```

---

## ❓ FAQ

### Q: How fast do PTZ motors move?

**A:** Depends on camera model:
- Speed 1: ~3°/second
- Speed 5: ~15°/second (default)
- Speed 9: ~30°/second

360° rotation at speed 5: ~24 seconds

### Q: Can I control zoom?

**A:** Basic PTZ controls pan/tilt only. Zoom typically controlled separately via:
- `multipleZoomCommand(scale)` - Digital zoom
- Optical zoom (if camera supports)

### Q: What happens if camera loses power during cruise?

**A:** Cruise stops. Camera returns to default position when power restored.

### Q: Can multiple users control PTZ simultaneously?

**A:** ⚠️ Yes, but can cause conflicts. Last command wins.

**Solution:** Implement locking mechanism in your app.

### Q: How to make smooth movements?

**A:** Use continuous movement (start/stop) instead of single-step for smooth, long-distance rotation.

---

## 🐛 Troubleshooting

### Issue: PTZ doesn't move

**Check:**
```dart
// 1. Camera supports PTZ?
if (device.motorCommand == null) {
  print("Not a PTZ camera");
}

// 2. Privacy mode enabled?
bool inPrivacy = await device.cameraCommand!.privacyPosition!
    .checkPrivacyPosition();
if (inPrivacy) {
  print("Disable privacy mode first");
}

// 3. Camera online?
var state = await device.connect();
if (state != CameraConnectState.connected) {
  print("Camera not connected");
}
```

### Issue: Preset doesn't work

**Check:**
```dart
// Preset was saved?
await device.motorCommand!.setPresetLocation(1);  // Save first
await device.motorCommand!.toPresetLocation(1);   // Then go
```

### Issue: Movement too slow/fast

**Solution:**
```dart
// Adjust motor speed
await device.motorCommand!.startLeft(motorSpeed: 9);  // Faster
await device.motorCommand!.startLeft(motorSpeed: 1);  // Slower
```

---

## 🎯 Summary

### Key Takeaways

```
✅ Two movement modes: Single-step & Continuous
✅ 5 preset positions (0-4)
✅ 6 cruise modes for auto-patrol
✅ Guard position for auto-return
✅ Motor speed control (1-9)
✅ CGI command-based control
```

### When to Use What

```
Single-Step → Fine adjustments, manual control
Continuous → Long-distance movements, joystick
Presets → Quick view switching, common positions
Cruise → Automatic patrol, surveillance
Guard → Maintain default view
```

---

## 📚 Next Steps

- **[06-AI-FEATURES.md](./06-AI-FEATURES.md)** - AI features (human tracking uses PTZ)
- **[08-ALARM-MANAGEMENT.md](./08-ALARM-MANAGEMENT.md)** - Alarm setup
- **[09-CODE-EXAMPLES.md](./09-CODE-EXAMPLES.md)** - More examples

---

*Updated: 2024 | Version: 1.0*

