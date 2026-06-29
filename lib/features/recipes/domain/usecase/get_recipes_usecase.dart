import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipeapp/features/recipes/domain/repository/recipe_repository.dart';


// ─────────────────────────────────────────────────────────────
// Get paginated recipes
// ─────────────────────────────────────────────────────────────
class GetRecipesUseCase {
  final RecipeRepository _repository;
  const GetRecipesUseCase(this._repository);

  Future<ApiResponse<List<RecipeEntity>>> call({
    int skip = 0,
    int limit = 20,
  }) =>
      _repository.getRecipes(skip: skip, limit: limit);
}

// ─────────────────────────────────────────────────────────────
// Get single recipe by id
// ─────────────────────────────────────────────────────────────
class GetRecipeByIdUseCase {
  final RecipeRepository _repository;
  const GetRecipeByIdUseCase(this._repository);

  Future<ApiResponse<RecipeEntity>> call(int id) =>
      _repository.getRecipeById(id);
}

// ─────────────────────────────────────────────────────────────
// Search recipes
// ─────────────────────────────────────────────────────────────
class SearchRecipesUseCase {
  final RecipeRepository _repository;
  const SearchRecipesUseCase(this._repository);

  Future<ApiResponse<List<RecipeEntity>>> call(String query) =>
      _repository.searchRecipes(query);
}

// ─────────────────────────────────────────────────────────────
// Get cached recipes (offline)
// ─────────────────────────────────────────────────────────────
class GetCachedRecipesUseCase {
  final RecipeRepository _repository;
  const GetCachedRecipesUseCase(this._repository);

  Future<List<RecipeEntity>> call() => _repository.getCachedRecipes();
}

// ─────────────────────────────────────────────────────────────
// Favorites
// ─────────────────────────────────────────────────────────────
class GetFavoriteIdsUseCase {
  final RecipeRepository _repository;
  const GetFavoriteIdsUseCase(this._repository);

  List<int> call() => _repository.getFavoriteIds();
}

class ToggleFavoriteUseCase {
  final RecipeRepository _repository;

  const ToggleFavoriteUseCase(this._repository);

  Future<void> call(int recipeId) => _repository.toggleFavorite(recipeId);
}