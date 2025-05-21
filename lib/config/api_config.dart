enum Environment {
  DEV,
  PROD,
}

class ApiConfig {
  static String environment = 'DEV';

  static String get SERVER_BASE_URL {
    switch (environment) {
      case 'DEV':
        return 'http://192.168.1.100:8080';
      case 'PROD':
        return 'http://math.icodelib.cn';
      default:
        return 'http://localhost:8080';
    }
  }
}
