import 'package:recipeapp/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipeapp/features/recipes/presentation/bloc/recipe_event.dart';

sealed class RecipeState {}

class RecipeInitialState extends RecipeState {}

class RecipeLoadingState extends RecipeState {}

class RecipeSearchingState extends RecipeState {}

class RecipeLoadingMoreState extends RecipeState {
  final List<RecipeEntity> currentRecipes;
  final List<int> favoriteIds;
  RecipeLoadingMoreState({
    required this.currentRecipes,
    required this.favoriteIds,
  });
}

class RecipeLoadedState extends RecipeState {
  final List<RecipeEntity> recipes;
  final List<RecipeEntity> allRecipes;
  final List<int> favoriteIds;
  final bool hasMore;
  final int currentSkip;
  final String? searchQuery;
  final String? selectedCuisine;
  final SortOption sortOption;
  final bool isOffline;

   RecipeLoadedState({
    required this.recipes,
    required this.allRecipes,
    required this.favoriteIds,
    this.hasMore = true,
    this.currentSkip = 0,
    this.searchQuery,
    this.selectedCuisine,
    this.sortOption = SortOption.rating,
    this.isOffline = false,
  });

  RecipeLoadedState copyWith({
    List<RecipeEntity>? recipes,
    List<RecipeEntity>? allRecipes,
    List<int>? favoriteIds,
    bool? hasMore,
    int? currentSkip,
    String? searchQuery,
    bool clearSearch = false,
    String? selectedCuisine,
    bool clearCuisine = false,
    SortOption? sortOption,
    bool? isOffline,
  }) =>
      RecipeLoadedState(
        recipes: recipes ?? this.recipes,
        allRecipes: allRecipes ?? this.allRecipes,
        favoriteIds: favoriteIds ?? this.favoriteIds,
        hasMore: hasMore ?? this.hasMore,
        currentSkip: currentSkip ?? this.currentSkip,
        searchQuery: clearSearch ? null : searchQuery ?? this.searchQuery,
        selectedCuisine:
        clearCuisine ? null : selectedCuisine ?? this.selectedCuisine,
        sortOption: sortOption ?? this.sortOption,
        isOffline: isOffline ?? this.isOffline,
      );
}

class RecipeDetailLoadingState extends RecipeState {}

class RecipeDetailLoadedState extends RecipeState {
  final RecipeEntity recipe;
  final bool isFavorite;
  RecipeDetailLoadedState({required this.recipe, required this.isFavorite});
}

class RecipeEmptyState extends RecipeState {
  final String message;
  RecipeEmptyState(this.message);
}

class RecipeErrorState extends RecipeState {
  final String message;
  RecipeErrorState(this.message);
}