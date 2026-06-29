import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/recipe_bloc.dart';
import '../bloc/recipe_event.dart';
import '../bloc/recipe_state.dart';
import '../widget/error_state_widge.dart';
import '../widget/recipe_card.dart';
import '../widget/recipe_skeleton_grid.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites ❤️'),
        leading: BackButton(onPressed: () {
          context.pop();
          context.read<RecipeBloc>().add( LoadRecipesEvent());
        }),
      ),
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoadingState) {
            return const RecipeSkeletonGrid();
          }

          if (state is RecipeEmptyState) {
            return EmptyStateWidget(
              message: state.message,
              icon: Icons.favorite_border,
              actionLabel: 'Browse Recipes',
              onAction: () {
                context.pop();
              },
            );
          }

          if (state is RecipeLoadedState) {
            return GridView.builder(
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
                  onTap: () => context.push('/recipes/${recipe.id}'),
                  onFavorite: () => context
                      .read<RecipeBloc>()
                      .add(ToggleFavoriteEvent(recipe.id)),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}