import 'package:equatable/equatable.dart';

/// Connection state entity - represents P2P connection status
class ConnectionState extends Equatable {
  final ConnectionStatus status;
  final String? message;
  final DateTime timestamp;

  const ConnectionState({
    required this.status,
    this.message,
    required this.timestamp,
  });

  factory ConnectionState.initial() {
    return ConnectionState(
      status: ConnectionStatus.disconnected,
      timestamp: DateTime.now(),
    );
  }

  factory ConnectionState.connecting() {
    return ConnectionState(
      status: ConnectionStatus.connecting,
      message: 'Connecting to camera...',
      timestamp: DateTime.now(),
    );
  }

  factory ConnectionState.connected() {
    return ConnectionState(
      status: ConnectionStatus.connected,
      message: 'Connected successfully',
      timestamp: DateTime.now(),
    );
  }

  factory ConnectionState.error(String errorMessage) {
    return ConnectionState(
      status: ConnectionStatus.error,
      message: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [status, message, timestamp];

  ConnectionState copyWith({
    ConnectionStatus? status,
    String? message,
    DateTime? timestamp,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Connection status enum
enum ConnectionStatus {
  disconnected,
  connecting,
  logging,
  connected,
  timeout,
  maxUser,
  offline,
  error,
}
