class Env {
  static const environment = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const apiUrl = String.fromEnvironment('API_URL');
  static const useMock = String.fromEnvironment('USE_MOCK');

  static String get originUrl => apiUrl.isNotEmpty ? Uri.parse(apiUrl).origin : '';
  static bool get isMock => useMock.toLowerCase() == 'true';
  static bool get isDev => environment == 'dev';
  static bool get isProd => environment == 'prod';
}
