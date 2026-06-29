import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/recipe_bloc.dart';
import '../bloc/recipe_event.dart';
import '../bloc/recipe_state.dart';
import '../widget/error_state_widge.dart';
import '../widget/recipe_card.dart';
import '../widget/recipe_skeleton_grid.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<RecipeBloc>().add( LoadRecipesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<RecipeBloc>().state;
      if (state is RecipeLoadedState && state.hasMore) {
        context.read<RecipeBloc>().add(LoadMoreRecipesEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticatedState) {
          context.go(AppRouter.login);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title:
          _isSearching ? _buildSearchField() : const Text('RecipeHub 🍳'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() => _isSearching = !_isSearching);
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<RecipeBloc>().add(ClearSearchEvent());
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () => context.go(AppRouter.favorites),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'logout') _showLogoutDialog();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: BlocBuilder<RecipeBloc, RecipeState>(
                builder: (context, state) {
                  if (state is RecipeLoadingState ||
                      state is RecipeSearchingState) {
                    return const RecipeSkeletonGrid();
                  }

                  if (state is RecipeErrorState) {
                    return ErrorStateWidget(
                      message: state.message,
                      onRetry: () => context
                          .read<RecipeBloc>()
                          .add( LoadRecipesEvent()),
                    );
                  }

                  if (state is RecipeEmptyState) {
                    return EmptyStateWidget(
                      message: state.message,
                      icon: Icons.no_meals,
                      actionLabel: 'Clear Search',
                      onAction: () {
                        _searchController.clear();
                        context.read<RecipeBloc>().add(ClearSearchEvent());
                      },
                    );
                  }

                  if (state is RecipeLoadedState) {
                    return _buildRecipeGrid(state);
                  }

                  if (state is RecipeLoadingMoreState) {
                    return _buildRecipeGridWithLoader(state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search recipes...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
      onChanged: (query) {
        if (query.length >= 2) {
          context.read<RecipeBloc>().add(SearchRecipesEvent(query));
        } else if (query.isEmpty) {
          context.read<RecipeBloc>().add(ClearSearchEvent());
        }
      },
    );
  }

  Widget _buildFilterBar() {
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        if (state is! RecipeLoadedState) return const SizedBox.shrink();

        final cuisines = state.allRecipes.map((r) => r.cuisine).toSet().toList()
          ..sort();

        return Column(
          children: [
            if (state.isOffline) const OfflineBanner(),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _SortButton(currentSort: state.sortOption),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('All'),
                    selected: state.selectedCuisine == null,
                    onSelected: (_) => context
                        .read<RecipeBloc>()
                        .add( FilterRecipesByCuisineEvent(null)),
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  const SizedBox(width: 8),
                  ...cuisines.take(10).map((cuisine) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cuisine),
                      selected: state.selectedCuisine == cuisine,
                      onSelected: (_) => context
                          .read<RecipeBloc>()
                          .add(FilterRecipesByCuisineEvent(cuisine)),
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  )),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecipeGrid(RecipeLoadedState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<RecipeBloc>()
            .add( LoadRecipesEvent(isRefresh: true));
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppTheme.primaryColor,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: state.recipes.length,
        itemBuilder: (context, index) {
          final recipe = state.recipes[index];
          return RecipeCard(
            recipe: recipe,
            isFavorite: state.favoriteIds.contains(recipe.id),
            onTap: () => context.go('/recipes/${recipe.id}'),
            onFavorite: () => context
                .read<RecipeBloc>()
                .add(ToggleFavoriteEvent(recipe.id)),
          );
        },
      ),
    );
  }

  Widget _buildRecipeGridWithLoader(RecipeLoadingMoreState state) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      // +2 skeleton cards at the bottom while loading
      itemCount: state.currentRecipes.length + 2,
      itemBuilder: (context, index) {
        if (index >= state.currentRecipes.length) {
          return const RecipeCardSkeleton();
        }
        final recipe = state.currentRecipes[index];
        return RecipeCard(
          recipe: recipe,
          isFavorite: state.favoriteIds.contains(recipe.id),
          onTap: () => context.go('/recipes/${recipe.id}'),
          onFavorite: () => context
              .read<RecipeBloc>()
              .add(ToggleFavoriteEvent(recipe.id)),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
             /* Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutEvent());*/
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final SortOption currentSort;

  const _SortButton({required this.currentSort});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      initialValue: currentSort,
      onSelected: (option) =>
          context.read<RecipeBloc>().add(SortRecipesEvent(option)),
      itemBuilder: (_) => const [
        PopupMenuItem(value: SortOption.rating, child: Text('⭐ Highest Rating')),
        PopupMenuItem(value: SortOption.name, child: Text('🔤 Name A-Z')),
        PopupMenuItem(value: SortOption.cookTime, child: Text('⏱ Cook Time')),
        PopupMenuItem(value: SortOption.calories, child: Text('🔥 Calories')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 16),
            SizedBox(width: 4),
            Text('Sort', style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}