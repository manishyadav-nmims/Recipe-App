sealed class RecipeEvent {}

class LoadRecipesEvent extends RecipeEvent {
  final bool isRefresh;
   LoadRecipesEvent({this.isRefresh = false});
}

class LoadMoreRecipesEvent extends RecipeEvent {}

class LoadRecipeDetailEvent extends RecipeEvent {
  final int id;
   LoadRecipeDetailEvent(this.id);
}

class SearchRecipesEvent extends RecipeEvent {
  final String query;
   SearchRecipesEvent(this.query);
}

class ClearSearchEvent extends RecipeEvent {}

class FilterRecipesByCuisineEvent extends RecipeEvent {
  final String? cuisine;
   FilterRecipesByCuisineEvent(this.cuisine);
}

class SortRecipesEvent extends RecipeEvent {
  final SortOption option;
   SortRecipesEvent(this.option);
}

class ToggleFavoriteEvent extends RecipeEvent {
  final int id;
   ToggleFavoriteEvent(this.id);
}

class LoadFavoritesEvent extends RecipeEvent {}

enum SortOption { rating, name, cookTime, calories }