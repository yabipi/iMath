import 'package:flutter/foundation.dart';

enum Environment {
  DEV,
  PROD,
  LOCAL,
}


class ApiConfig {
  static const String baseUrl = '';

  static const int sessionTimeoutThreshold =
  0; // Will refresh the access token 5 minutes before it expires
  static const bool loginWithPassword = true; // if false hide the form login
  //if false hide the fields password and confirm password from signup form
  //for security reason and the password generated after verification mail
  static const bool signupWithPassword = true;

  static Environment environment = Environment.PROD;

  static String get SERVER_BASE_URL {
    switch (environment) {
      case Environment.PROD:
        return 'http://math.icodelib.cn';
      case Environment.DEV:
        return 'http://192.168.1.100:8080';
        // return 'http://math.icodelib.cn';
      case Environment.LOCAL:
        return 'http://localhost:8080';
      default:
        return 'http://localhost:8080';
    }
  }

  static String get minerUrl {
    switch (environment) {
      case 'DEV':
        return 'http://192.168.1.9:9898';
      case 'PROD':
        return 'http://miner.icodelib.cn';
      default:
        return 'http://localhost:8080';
    }

  }
}
