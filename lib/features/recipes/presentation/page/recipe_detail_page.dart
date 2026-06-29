import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/recipe_entity.dart';
import '../bloc/recipe_bloc.dart';
import '../bloc/recipe_event.dart';
import '../bloc/recipe_state.dart';
import '../widget/error_state_widge.dart';
import '../widget/recipe_skeleton_grid.dart';

class RecipeDetailPage extends StatefulWidget {
  final int recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadRecipeDetailEvent(widget.recipeId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeDetailLoadingState) {
            return const RecipeDetailSkeleton();
          }

          if (state is RecipeErrorState) {
            return Scaffold(
              appBar: AppBar(),
              body: ErrorStateWidget(
                message: state.message,
                onRetry: () => context
                    .read<RecipeBloc>()
                    .add(LoadRecipeDetailEvent(widget.recipeId)),
              ),
            );
          }

          if (state is RecipeDetailLoadedState) {
            return _buildDetail(state.recipe, state.isFavorite);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(RecipeEntity recipe, bool isFavorite) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          actions: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFavorite),
                  color: isFavorite ? Colors.red : Colors.white,
                ),
              ),
              onPressed: () => context
                  .read<RecipeBloc>()
                  .add(ToggleFavoriteEvent(recipe.id)),
            ),
          ],

          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: recipe.image,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.restaurant,
                      size: 80,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: recipe.rating,
                      itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${recipe.rating.toStringAsFixed(1)} · ${recipe.reviewCount} reviews',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(Icons.restaurant_menu, recipe.cuisine),
                    _InfoChip(Icons.lunch_dining, recipe.mealType),
                    _InfoChip(Icons.fitness_center, recipe.difficulty),
                    _InfoChip(Icons.people, '${recipe.servings} servings'),
                    _InfoChip(
                      Icons.local_fire_department,
                      '${recipe.caloriesPerServing.round()} cal',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _TimeCard(
                        label: 'Prep Time',
                        minutes: recipe.prepTimeMinutes,
                        icon: Icons.cut,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeCard(
                        label: 'Cook Time',
                        minutes: recipe.cookTimeMinutes,
                        icon: Icons.outdoor_grill,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeCard(
                        label: 'Total',
                        minutes: recipe.totalTimeMinutes,
                        icon: Icons.timer,
                        highlight: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (recipe.tags.isNotEmpty) ...[
                  const _SectionTitle('Tags'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: recipe.tags
                        .map((tag) => Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor:
                      AppTheme.primaryColor.withOpacity(0.1),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                const _SectionTitle('Ingredients'),
                const SizedBox(height: 12),
                ...recipe.ingredients.asMap().entries.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionTitle('Instructions'),
                const SizedBox(height: 12),
                ...recipe.instructions.asMap().entries.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String label;
  final int minutes;
  final IconData icon;
  final bool highlight;

  const _TimeCard({
    required this.label,
    required this.minutes,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: highlight ? AppTheme.primaryColor : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            '${minutes}m',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? AppTheme.primaryColor : Colors.black87,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}