class ApiEndpoints {
  // Live Deployed Render HTTPS Base URL
  static const String renderBaseUrl = 'https://trusight-backend.onrender.com';
  static const String baseUrl = renderBaseUrl;

  // Local Fallback Base URL
  static const String localBaseUrl = 'http://192.168.1.103:8000';

  // Active FastAPI Endpoint (Render Live Cloud Server)
  static const String detect = '/api/v1/detect';
  static const String healthCheck = '/';

  // Config defaults
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 40);
}
