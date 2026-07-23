import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectTimeout,
        sendTimeout: ApiEndpoints.sendTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'TruSight-AI-Media-Detector/1.0.0',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Can attach API Tokens or Bearer auth headers here
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Log or handle retry / standard error formatting
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
