import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/features/recipes/domain/entities/recipe_entity.dart';

abstract class RecipeRepository {
  Future<ApiResponse<List<RecipeEntity>>> getRecipes({
    int skip = 0,
    int limit = 20,
  });

  Future<ApiResponse<RecipeEntity>> getRecipeById(int id);

  Future<ApiResponse<List<RecipeEntity>>> searchRecipes(String query);

  // Offline cache
  Future<List<RecipeEntity>> getCachedRecipes();

  // Favorites (local only)
  List<int> getFavoriteIds();
  Future<void> toggleFavorite(int recipeId);
}