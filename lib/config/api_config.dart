enum Environment {
  DEV,
  PROD,
}

class ApiConfig {
  static Environment environment = Environment.PROD;

  static String get SERVER_BASE_URL {
    switch (environment) {
      case Environment.DEV:
        return 'http://localhost:8080';
      case Environment.PROD:
        return 'http://math.icodelib.cn';
      default:
        return 'http://localhost:8080';
    }
  }
}
