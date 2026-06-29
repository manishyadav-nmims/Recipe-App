import 'package:dio/dio.dart';
import 'package:recipeapp/core/network/Interceptors/auth_interceptor.dart';
import 'package:recipeapp/core/network/Interceptors/networks_logger_interceptor.dart';
import 'package:recipeapp/core/network/api_response.dart';

class DioClient {
  final Dio dio;

  DioClient(String baseUrl)
      : dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  ) {
    dio.interceptors.addAll([
      AuthInterceptor(),           //  TOKEN HERE
      NetworkLoggerInterceptor(),  // Logs after auth
    ]);
  }

  Future<ApiResponse<T>> post<T>(
      String endpoint, {
        dynamic data,
      }) async {
    try {
      final response = await dio.post(endpoint, data: data);
      return ApiSuccess(response.data as T);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return ApiFailure("Connection timeout");

        case DioExceptionType.sendTimeout:
          return ApiFailure("Request timeout");

        case DioExceptionType.receiveTimeout:
          return ApiFailure("Server response timeout");

        case DioExceptionType.connectionError:
          return ApiFailure("No internet connection");

        case DioExceptionType.badResponse:
          return ApiFailure(
            e.response?.data?['message'] ??
                'Server error',
          );

        default:
          return ApiFailure(
            e.message ?? 'Something went wrong',
          );
      }
    }
  }

  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await dio.get(endpoint, queryParameters: queryParameters);
      return ApiSuccess(response.data as T);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiFailure("No internet connection");
      }
      return ApiFailure(
        e.response?.data?['message'] ?? 'Something went wrong',
      );
    }
  }
}