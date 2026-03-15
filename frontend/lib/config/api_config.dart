import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String appName = 'NutriPal';
  static const String appVersion = '1.0.0';
  static const String _devIp = '127.0.0.1';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:4000/api/v1';
    }
    // Android emulator should use 10.0.2.2 to access host machine localhost.
    return 'http://10.0.2.2:4000/api/v1';
  }

  static String get localDeviceBaseUrl => 'http://$_devIp:4000/api/v1';
}
