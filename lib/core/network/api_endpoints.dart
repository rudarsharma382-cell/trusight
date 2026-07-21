class ApiEndpoints {
  static const String baseUrl = 'https://api.trusight.ai/v1';

  // Endpoint paths
  static const String analyzeImage = '$baseUrl/detect/image';
  static const String analyzeVideo = '$baseUrl/detect/video';
  static const String analyzeAudio = '$baseUrl/detect/audio';
  static const String healthCheck = '$baseUrl/health';

  // Config defaults
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
