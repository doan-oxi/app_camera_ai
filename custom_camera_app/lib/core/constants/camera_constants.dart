/// Camera and SDK specific constants
class CameraConstants {
  CameraConstants._(); // Private constructor

  // Connection timeouts (milliseconds)
  static const int connectionTimeout = 30000; // 30s
  static const int commandTimeout = 5000; // 5s
  static const int streamTimeout = 10000; // 10s

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const int retryInitialDelayMs = 1000; // 1s
  static const int retryMaxDelayMs = 5000; // 5s
  static const double retryMultiplier = 2.0; // Exponential backoff

  // Keep alive
  static const int keepAliveIntervalMs = 10000; // 10s
  static const int wakeupCheckIntervalOnlineMs = 45000; // 45s
  static const int wakeupCheckIntervalOfflineMs = 3000; // 3s

  // Video streaming
  static const int maxConcurrentStreams = 4;
  static const int defaultFrameRate = 30;
  static const int videoBufferSize = 10;

  // Cache
  static const int cameraListCacheDuration = 300; // 5 minutes in seconds
  static const int statusCacheDuration = 30; // 30 seconds

  // SDK Error Codes (from Veepai documentation)
  static const int errorInvalidId = -1;
  static const int errorInvalidParam = -2;
  static const int errorNotSupported = -3;
  static const int errorIllegal = -4;
  static const int errorMaxSession = -5;
  static const int errorTimeout = -6;
}
