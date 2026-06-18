import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base URL of the backend server.
  /// - On Web: localhost:5001
  /// - On Android Emulator: 10.0.2.2:5001 (forwards to host's localhost)
  /// - On iOS Simulator/Desktop: 127.0.0.1:5001
  /// 
  /// NOTE: If you are running on a physical Android/iOS device, 
  /// you must change this to your computer's local IP address (e.g., 'http://192.168.1.100:5001').
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5001';
    } else {
      return 'http://127.0.0.1:5001';
    }
  }
}
