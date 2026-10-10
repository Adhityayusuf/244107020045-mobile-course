import 'package:dio/dio.dart';

/// Base URL dapat ditimpa saat build/run untuk menguji skenario error:
/// flutter run --dart-define=API_BASE_URL=https://localhost:9/
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://jsonplaceholder.typicode.com',
);

/// Seluruh konfigurasi jaringan Dio terpusat di satu tempat.
Dio createDio({String baseUrl = apiBaseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  return dio;
}
