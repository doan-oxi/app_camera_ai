import 'package:equatable/equatable.dart';

/// Camera entity - pure domain object
/// No Flutter or SDK dependencies allowed here
class Camera extends Equatable {
  final String id;
  final String name;
  final CameraStatus status;
  final String? ipAddress;
  final int? port;

  const Camera({
    required this.id,
    required this.name,
    required this.status,
    this.ipAddress,
    this.port,
  });

  @override
  List<Object?> get props => [id, name, status, ipAddress, port];

  Camera copyWith({
    String? id,
    String? name,
    CameraStatus? status,
    String? ipAddress,
    int? port,
  }) {
    return Camera(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
    );
  }
}

/// Camera connection status
enum CameraStatus {
  offline,
  connecting,
  connected,
  disconnected,
  error,
  timeout,
}
