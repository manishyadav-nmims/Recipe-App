import 'package:recipeapp/features/recipes/domain/entities/recipe_entity.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    required super.name,
    required super.ingredients,
    required super.instructions,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.servings,
    required super.difficulty,
    required super.cuisine,
    required super.caloriesPerServing,
    required super.tags,
    required super.image,
    required super.rating,
    required super.reviewCount,
    required super.mealType,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      ingredients: _toStringList(json['ingredients']),
      instructions: _toStringList(json['instructions']),
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 0,
      cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'Easy',
      cuisine: json['cuisine'] as String? ?? '',
      caloriesPerServing:
      (json['caloriesPerServing'] as num?)?.toDouble() ?? 0.0,
      tags: _toStringList(json['tags']),
      image: json['image'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      // API returns mealType as a List<dynamic>
      mealType: _parseMealType(json['mealType']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'ingredients': ingredients,
    'instructions': instructions,
    'prepTimeMinutes': prepTimeMinutes,
    'cookTimeMinutes': cookTimeMinutes,
    'servings': servings,
    'difficulty': difficulty,
    'cuisine': cuisine,
    'caloriesPerServing': caloriesPerServing,
    'tags': tags,
    'image': image,
    'rating': rating,
    'reviewCount': reviewCount,
    'mealType': mealType,
  };

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static String _parseMealType(dynamic value) {
    if (value == null) return 'Meal';
    if (value is List && value.isNotEmpty) return value.first.toString();
    if (value is String) return value;
    return 'Meal';
  }
}