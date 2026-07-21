class ApiEndpoints {
  // Live Deployed Render HTTPS Base URL
  static const String renderBaseUrl = 'https://trusight-backend.onrender.com/api/v1';
  static const String baseUrl = renderBaseUrl;

  // Local Fallback Base URL
  static const String localBaseUrl = 'http://192.168.1.103:8000/api/v1';

  // Active FastAPI Endpoint (Render Live Cloud Server)
  static const String detect = '$renderBaseUrl/detect';
  static const String healthCheck = 'https://trusight-backend.onrender.com/';

  // Config defaults (extended 45s connect timeout for Render free tier cold-starts)
  static const Duration connectTimeout = Duration(seconds: 45);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
