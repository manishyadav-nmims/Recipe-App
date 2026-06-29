import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/core/storage/recipe_cache_helper.dart';
import 'package:recipeapp/features/recipes/data/services/recipe_service.dart';
import 'package:recipeapp/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipeapp/features/recipes/domain/repository/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeService _service;

  const RecipeRepositoryImpl(this._service);

  // ── Helpers ──────────────────────────────────────────────────

  Future<bool> get _isOnline async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // ── Get recipes (offline-first) ──────────────────────────────
  @override
  Future<ApiResponse<List<RecipeEntity>>> getRecipes({
    int skip = 0,
    int limit = 20,
  }) async {
    if (!await _isOnline) {
      final cached = RecipeCacheHelper.getRecipes();
      if (cached.isNotEmpty) return ApiSuccess(cached);
      return const ApiFailure('No internet connection and no cached data.');
    }

    final response = await _service.getRecipes(skip: skip, limit: limit);

    // Cache the first page so it is always fresh
    if (response is ApiSuccess && skip == 0) {
      final recipes = (response as ApiSuccess).data;
      await RecipeCacheHelper.saveRecipes(recipes);
    }

    return response;
  }

  // ── Get single recipe (cache detail too) ─────────────────────
  @override
  Future<ApiResponse<RecipeEntity>> getRecipeById(int id) async {
    if (!await _isOnline) {
      final cached = RecipeCacheHelper.getRecipeDetail(id);
      if (cached != null) return ApiSuccess(cached);
      return const ApiFailure('No internet. Recipe not cached.');
    }

    final response = await _service.getRecipeById(id);

    if (response is ApiSuccess) {
      await RecipeCacheHelper.saveRecipeDetail(
        (response as ApiSuccess<RecipeEntity>).data as dynamic,
      );
    }

    return response;
  }

  // ── Search (falls back to local filter when offline) ─────────
  @override
  Future<ApiResponse<List<RecipeEntity>>> searchRecipes(String query) async {
    if (!await _isOnline) {
      final q = query.toLowerCase();
      final results = RecipeCacheHelper.getRecipes().where((r) {
        return r.name.toLowerCase().contains(q) ||
            r.cuisine.toLowerCase().contains(q) ||
            r.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
      return ApiSuccess(results);
    }

    return _service.searchRecipes(query);
  }

  // ── Cached recipes ───────────────────────────────────────────
  @override
  Future<List<RecipeEntity>> getCachedRecipes() async =>
      RecipeCacheHelper.getRecipes();

  // ── Favorites ────────────────────────────────────────────────
  @override
  List<int> getFavoriteIds() => RecipeCacheHelper.getFavoriteIds();

  @override
  Future<void> toggleFavorite(int recipeId) =>
      RecipeCacheHelper.toggleFavorite(recipeId);
}