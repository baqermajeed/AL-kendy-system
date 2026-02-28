import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reception_app_kendy/core/network/api_constants.dart';
import 'package:reception_app_kendy/core/network/api_exception.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: ApiConstants.tokenKey);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _clearTokens();
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: ApiConstants.tokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
  }

  Future<void> clearTokens() => _clearTokens();

  ApiException _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    String message = 'حدث خطأ';
    if (data is Map && data['detail'] != null) {
      message = data['detail'] is String ? data['detail'] : data['detail'].toString();
    } else if (data is String) {
      message = data;
    }
    if (statusCode == 401) return UnauthorizedException(message);
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkException('انتهت مهلة الاتصال');
    }
    return ServerException(message, statusCode: statusCode);
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String endpoint, {dynamic data, FormData? formData}) async {
    try {
      return await _dio.post(endpoint, data: formData ?? data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<String?> getToken() async =>
      await _storage.read(key: ApiConstants.tokenKey);

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: ApiConstants.tokenKey, value: accessToken);
    await _storage.write(key: ApiConstants.refreshTokenKey, value: refreshToken);
  }
}
