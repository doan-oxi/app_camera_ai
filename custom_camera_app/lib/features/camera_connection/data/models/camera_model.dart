import '../../domain/entities/camera.dart';

/// Camera model (DTO) - for data layer serialization
/// Maps between SDK data and domain entity
class CameraModel {
  final String id;
  final String name;
  final String status;
  final String? ipAddress;
  final int? port;

  const CameraModel({
    required this.id,
    required this.name,
    required this.status,
    this.ipAddress,
    this.port,
  });

  /// Convert from domain entity
  factory CameraModel.fromEntity(Camera camera) {
    return CameraModel(
      id: camera.id,
      name: camera.name,
      status: _statusToString(camera.status),
      ipAddress: camera.ipAddress,
      port: camera.port,
    );
  }

  /// Convert to domain entity
  Camera toEntity() {
    return Camera(
      id: id,
      name: name,
      status: _statusFromString(status),
      ipAddress: ipAddress,
      port: port,
    );
  }

  /// Map from JSON
  factory CameraModel.fromJson(Map<String, dynamic> json) {
    return CameraModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      ipAddress: json['ipAddress'] as String?,
      port: json['port'] as int?,
    );
  }

  /// Map to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'ipAddress': ipAddress,
      'port': port,
    };
  }

  static String _statusToString(CameraStatus status) {
    return status.name;
  }

  static CameraStatus _statusFromString(String status) {
    return CameraStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => CameraStatus.offline,
    );
  }
}
