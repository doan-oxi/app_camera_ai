/// App-wide constants
class AppConstants {
  AppConstants._(); // Private constructor

  // App info
  static const String appName = 'Veepai Camera';
  static const String appVersion = '1.0.0';

  // Timeouts (milliseconds)
  static const int networkTimeout = 30000;
  static const int connectionTimeout = 30000;
  static const int keepAliveInterval = 10000;

  // Video
  static const int maxFrameRate = 30;
  static const int videoBufferSize = 10;

  // Retry policy
  static const int maxRetryAttempts = 3;
  static const int retryDelayMs = 1000;

  // Stream debounce/throttle (milliseconds)
  static const int userInputDebounce = 300;
  static const int statusUpdateThrottle = 1000;
}
