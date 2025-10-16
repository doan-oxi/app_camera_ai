// Domain Entity - Pure Dart, No Dependencies
// Following Clean Architecture principles

import 'package:equatable/equatable.dart';

/// Domain entity representing a camera device.
/// 
/// This is a pure Dart class with no framework dependencies.
/// It represents the core business concept of a camera in the domain layer.
/// 
/// Principles applied:
/// - Single Responsibility: Only represents camera data
/// - Immutability: All fields are final
/// - Value Object: Uses Equatable for value equality
class Camera extends Equatable {
  const Camera({
    required this.id,
    required this.name,
    required this.status,
    required this.type,
    this.ipAddress,
    this.macAddress,
    this.firmwareVersion,
    this.lastSeen,
  });

  /// Unique identifier for the camera
  final String id;

  /// Human-readable name
  final String name;

  /// Current connection status
  final CameraStatus status;

  /// Type of camera (PTZ, Fixed, etc.)
  final CameraType type;

  /// IP address if connected via network
  final String? ipAddress;

  /// MAC address for device identification
  final String? macAddress;

  /// Current firmware version
  final String? firmwareVersion;

  /// Last time camera was seen online
  final DateTime? lastSeen;

  /// Check if camera is online
  bool get isOnline => status == CameraStatus.online;

  /// Check if camera supports PTZ
  bool get supportsPTZ => type == CameraType.ptz;

  /// Copy with method for immutability
  Camera copyWith({
    String? id,
    String? name,
    CameraStatus? status,
    CameraType? type,
    String? ipAddress,
    String? macAddress,
    String? firmwareVersion,
    DateTime? lastSeen,
  }) {
    return Camera(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      type: type ?? this.type,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        type,
        ipAddress,
        macAddress,
        firmwareVersion,
        lastSeen,
      ];
}

/// Camera connection status
enum CameraStatus {
  /// Camera is online and ready
  online,

  /// Camera is offline
  offline,

  /// Currently connecting
  connecting,

  /// Connection failed
  failed,

  /// Camera is sleeping (low power mode)
  sleeping,
}

/// Type of camera
enum CameraType {
  /// Pan-Tilt-Zoom camera
  ptz,

  /// Fixed position camera
  fixed,

  /// Dome camera
  dome,

  /// Bullet camera
  bullet,
}

