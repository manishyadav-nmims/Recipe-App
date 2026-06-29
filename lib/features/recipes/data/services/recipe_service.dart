import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/core/network/base_service.dart';
import 'package:recipeapp/features/recipes/data/models/recipe_model.dart';

class RecipeService extends BaseService {
  RecipeService() : super('https://dummyjson.com');

  // ── GET /recipes ─────────────────────────────────────────────
  Future<ApiResponse<List<RecipeModel>>> getRecipes({
    int skip = 0,
    int limit = 20,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '/recipes',
      queryParameters: {'limit': limit, 'skip': skip},
    );

    return switch (response) {
      ApiSuccess<Map<String, dynamic>>(:final data) => ApiSuccess(
        (data['recipes'] as List<dynamic>)
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      ApiFailure<Map<String, dynamic>>(:final message) =>
          ApiFailure(message),
    };
  }

  // ── GET /recipes/:id ─────────────────────────────────────────
  Future<ApiResponse<RecipeModel>> getRecipeById(int id) async {
    final response = await get<Map<String, dynamic>>('/recipes/$id');

    return switch (response) {
      ApiSuccess<Map<String, dynamic>>(:final data) =>
          ApiSuccess(RecipeModel.fromJson(data)),
      ApiFailure<Map<String, dynamic>>(:final message) =>
          ApiFailure(message),
    };
  }

  // ── GET /recipes/search?q= ───────────────────────────────────
  Future<ApiResponse<List<RecipeModel>>> searchRecipes(String query) async {
    final response = await get<Map<String, dynamic>>(
      '/recipes/search',
      queryParameters: {'q': query, 'limit': 20},
    );

    return switch (response) {
      ApiSuccess<Map<String, dynamic>>(:final data) => ApiSuccess(
        (data['recipes'] as List<dynamic>)
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      ApiFailure<Map<String, dynamic>>(:final message) =>
          ApiFailure(message),
    };
  }
}