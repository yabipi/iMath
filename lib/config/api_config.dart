enum Environment {
  DEV,
  PROD,
}

class ApiConfig {
  static Environment environment = Environment.DEV;

  static String get SERVER_BASE_URL {
    switch (environment) {
      case Environment.DEV:
        return 'http://192.168.1.100:8080';
      case Environment.PROD:
        return 'http://math.icodelib.cn';
      default:
        return 'http://192.168.1.100:8080';
    }
  }
} 