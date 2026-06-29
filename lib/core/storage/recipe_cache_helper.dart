import 'package:hive_ce/hive.dart';
import 'package:recipeapp/features/recipes/data/models/recipe_model.dart';

/// Thin wrapper around two Hive boxes:
///   • 'recipes'   – cached API data (List of recipe maps)
///   • 'favorites' – list of favorited recipe ids
class RecipeCacheHelper {
  static const _recipesBox = 'recipes';
  static const _favoritesBox = 'favorites';
  static const _recipesKey = 'all';

  // Call once inside main() after Hive.initFlutter()
  static Future<void> init() async {
    await Hive.openBox<dynamic>(_recipesBox);
    await Hive.openBox<dynamic>(_favoritesBox);
  }

  // ── Recipe cache ──────────────────────────────────────────────

  static Future<void> saveRecipes(List<RecipeModel> recipes) async {
    final box = Hive.box<dynamic>(_recipesBox);
    final jsonList = recipes.map((r) => r.toJson()).toList();
    await box.put(_recipesKey, jsonList);
  }

  static List<RecipeModel> getRecipes() {
    final box = Hive.box<dynamic>(_recipesBox);
    final raw = box.get(_recipesKey);
    if (raw == null) return [];
    return (raw as List<dynamic>)
        .map((e) => RecipeModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> saveRecipeDetail(RecipeModel recipe) async {
    final box = Hive.box<dynamic>(_recipesBox);
    await box.put('detail_${recipe.id}', recipe.toJson());
  }

  static RecipeModel? getRecipeDetail(int id) {
    final box = Hive.box<dynamic>(_recipesBox);
    final raw = box.get('detail_$id');
    if (raw == null) return null;
    return RecipeModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  // ── Favorites ─────────────────────────────────────────────────

  static List<int> getFavoriteIds() {
    final box = Hive.box<dynamic>(_favoritesBox);
    final raw = box.get('ids');
    if (raw == null) return [];
    return List<int>.from(raw as List);
  }

  static Future<void> toggleFavorite(int id) async {
    final box = Hive.box<dynamic>(_favoritesBox);
    final ids = getFavoriteIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await box.put('ids', ids);
  }

  static bool isFavorite(int id) => getFavoriteIds().contains(id);
}