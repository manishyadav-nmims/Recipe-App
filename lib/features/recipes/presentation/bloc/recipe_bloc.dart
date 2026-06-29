import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipeapp/core/network/api_response.dart';
import 'package:recipeapp/features/recipes/domain/entities/recipe_entity.dart';
import 'package:recipeapp/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:recipeapp/features/recipes/presentation/bloc/recipe_state.dart';
import '../../domain/usecase/get_recipes_usecase.dart';

const _pageSize = 20;

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final GetRecipesUseCase _getRecipes;
  final GetRecipeByIdUseCase _getRecipeById;
  final SearchRecipesUseCase _searchRecipes;
  final GetCachedRecipesUseCase _getCachedRecipes;
  final GetFavoriteIdsUseCase _getFavoriteIds;
  final ToggleFavoriteUseCase _toggleFavorite;

  RecipeBloc({
    required GetRecipesUseCase getRecipesUseCase,
    required GetRecipeByIdUseCase getRecipeByIdUseCase,
    required SearchRecipesUseCase searchRecipesUseCase,
    required GetCachedRecipesUseCase getCachedRecipesUseCase,
    required GetFavoriteIdsUseCase getFavoriteIdsUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
  })  : _getRecipes = getRecipesUseCase,
        _getRecipeById = getRecipeByIdUseCase,
        _searchRecipes = searchRecipesUseCase,
        _getCachedRecipes = getCachedRecipesUseCase,
        _getFavoriteIds = getFavoriteIdsUseCase,
        _toggleFavorite = toggleFavoriteUseCase,
        super(RecipeInitialState()) {
    on<LoadRecipesEvent>(_onLoadRecipes);
    on<LoadMoreRecipesEvent>(_onLoadMore);
    on<LoadRecipeDetailEvent>(_onLoadDetail);
    on<SearchRecipesEvent>(_onSearch);
    on<ClearSearchEvent>(_onClearSearch);
    on<FilterRecipesByCuisineEvent>(_onFilter);
    on<SortRecipesEvent>(_onSort);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<LoadFavoritesEvent>(_onLoadFavorites);
  }

  List<RecipeEntity> _cachedAllRecipes = [];
  List<int> _cachedFavoriteIds = [];

  Future<void> _onLoadRecipes(
      LoadRecipesEvent event,
      Emitter<RecipeState> emit,
      ) async {
    if (!event.isRefresh) emit(RecipeLoadingState());

    final response = await _getRecipes(skip: 0, limit: _pageSize);
    final favIds = _getFavoriteIds();

    switch (response) {
      case ApiSuccess(:final data):
        if (data.isEmpty) {
          emit(RecipeEmptyState('No recipes found.'));
          return;
        }
        _cachedAllRecipes = data;
        emit(RecipeLoadedState(
          recipes: _sorted(data, SortOption.rating),
          allRecipes: data,
          favoriteIds: favIds,
          hasMore: data.length >= _pageSize,
          currentSkip: data.length,
        ));
      case ApiFailure(:final message):
        final cached = await _getCachedRecipes();
        if (cached.isNotEmpty) {
          _cachedAllRecipes = cached;
          emit(RecipeLoadedState(
            recipes: _sorted(cached, SortOption.rating),
            allRecipes: cached,
            favoriteIds: favIds,
            hasMore: false,
            isOffline: true,
          ));
        } else {
          emit(RecipeErrorState(message));
        }
    }
  }

  Future<void> _onLoadMore(
      LoadMoreRecipesEvent event,
      Emitter<RecipeState> emit,
      ) async {
    final current = state;
    if (current is! RecipeLoadedState || !current.hasMore) return;

    emit(RecipeLoadingMoreState(
      currentRecipes: current.recipes,
      favoriteIds: current.favoriteIds,
    ));

    final response = await _getRecipes(
      skip: current.currentSkip,
      limit: _pageSize,
    );

    switch (response) {
      case ApiSuccess(:final data):
        final merged = [...current.allRecipes, ...data];
        _cachedAllRecipes = merged;
        emit(current.copyWith(
          recipes: _sorted(merged, current.sortOption),
          allRecipes: merged,
          hasMore: data.length >= _pageSize,
          currentSkip: current.currentSkip + data.length,
        ));
      case ApiFailure():
        emit(current);
    }
  }

  Future<void> _onLoadDetail(
      LoadRecipeDetailEvent event,
      Emitter<RecipeState> emit,
      ) async {
    emit(RecipeDetailLoadingState());

    final response = await _getRecipeById(event.id);
    final favIds = _getFavoriteIds();

    switch (response) {
      case ApiSuccess(:final data):
        emit(RecipeDetailLoadedState(
          recipe: data,
          isFavorite: favIds.contains(data.id),
        ));
      case ApiFailure(:final message):
        emit(RecipeErrorState(message));
    }
  }

  Future<void> _onSearch(
      SearchRecipesEvent event,
      Emitter<RecipeState> emit,
      ) async {
    if (event.query.trim().isEmpty) {
      add(ClearSearchEvent());
      return;
    }

    emit(RecipeSearchingState());

    final response = await _searchRecipes(event.query);
    final favIds = _getFavoriteIds();

    switch (response) {
      case ApiSuccess(:final data):
        if (data.isEmpty) {
          emit(RecipeEmptyState('No results for "${event.query}"'));
          return;
        }
        emit(RecipeLoadedState(
          recipes: data,
          allRecipes: data,
          favoriteIds: favIds,
          hasMore: false,
          searchQuery: event.query,
        ));
      case ApiFailure(:final message):
        emit(RecipeErrorState(message));
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<RecipeState> emit) {
    if (_cachedAllRecipes.isNotEmpty) {
      // Restore instantly from memory — zero API calls
      emit(RecipeLoadedState(
        recipes: _sorted(_cachedAllRecipes, SortOption.rating),
        allRecipes: _cachedAllRecipes,
        favoriteIds: _cachedFavoriteIds,
        hasMore: true, // let the user scroll to load more
        currentSkip: _cachedAllRecipes.length,
      ));
    } else {
      // Nothing cached yet, fall back to API
      add(LoadRecipesEvent());
    }
  }

  void _onFilter(FilterRecipesByCuisineEvent event, Emitter<RecipeState> emit) {
    final current = state;
    if (current is! RecipeLoadedState) return;

    if (event.cuisine == null) {
      emit(current.copyWith(
        recipes: _sorted(current.allRecipes, current.sortOption),
        clearCuisine: true,
      ));
      return;
    }

    final filtered = current.allRecipes
        .where((r) => r.cuisine.toLowerCase() == event.cuisine!.toLowerCase())
        .toList();

    emit(current.copyWith(
      recipes: _sorted(filtered, current.sortOption),
      selectedCuisine: event.cuisine,
    ));
  }

  void _onSort(SortRecipesEvent event, Emitter<RecipeState> emit) {
    final current = state;
    if (current is! RecipeLoadedState) return;

    emit(current.copyWith(
      recipes: _sorted(current.recipes, event.option),
      sortOption: event.option,
    ));
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event,
      Emitter<RecipeState> emit,
      ) async {
    await _toggleFavorite(event.id);
    final favIds = _getFavoriteIds();

    final current = state;
    if (current is RecipeLoadedState) {
      emit(current.copyWith(favoriteIds: favIds));
    } else if (current is RecipeDetailLoadedState) {
      emit(RecipeDetailLoadedState(
        recipe: current.recipe,
        isFavorite: favIds.contains(current.recipe.id),
      ));
    }
  }

  // Loads only the user's favourited recipes for the FavoritesPage
  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event,
      Emitter<RecipeState> emit,
      ) async {
    emit(RecipeLoadingState());

    final favIds = _getFavoriteIds();
    if (favIds.isEmpty) {
      emit(RecipeEmptyState('No favourites yet. Start hearting recipes!'));
      return;
    }

    // Fetch all cached/network recipes and filter to favourites
    final cached = await _getCachedRecipes();
    final favRecipes =
    cached.where((r) => favIds.contains(r.id)).toList();

    if (favRecipes.isEmpty) {
      emit(RecipeEmptyState('Your favourites aren\'t cached yet. Browse online first.'));
      return;
    }

    emit(RecipeLoadedState(
      recipes: favRecipes,
      allRecipes: favRecipes,
      favoriteIds: favIds,
      hasMore: false,
    ));
  }

  List<RecipeEntity> _sorted(List<RecipeEntity> list, SortOption opt) {
    final copy = List<RecipeEntity>.from(list);
    switch (opt) {
      case SortOption.rating:
        copy.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.name:
        copy.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.cookTime:
        copy.sort((a, b) => a.totalTimeMinutes.compareTo(b.totalTimeMinutes));
      case SortOption.calories:
        copy.sort((a, b) => a.caloriesPerServing.compareTo(b.caloriesPerServing));
    }
    return copy;
  }
}