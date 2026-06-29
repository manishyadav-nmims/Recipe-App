import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/core/network/dio_client.dart';

abstract class BaseService {
  late final DioClient dioClient;

  BaseService(String baseUrl) {
    dioClient = DioClient(baseUrl);
  }

  Future<ApiResponse<T>> post<T>(
      String endpoint, {
        dynamic data,
      }) {
    return dioClient.post<T>(endpoint, data: data);
  }

  Future<ApiResponse<T>> get<T>(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) {
    return dioClient.get<T>(
      endpoint,
      queryParameters: queryParameters,
    );
  }
}