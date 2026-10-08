import 'package:equatable/equatable.dart';

class RecipeIngredient extends Equatable {
  const RecipeIngredient({required this.name, this.measure = ''});

  final String name;
  final String measure;

  @override
  List<Object?> get props => [name, measure];
}

class Recipe extends Equatable {
  const Recipe({
    required this.id,
    required this.title,
    this.imageUrl,
    this.category,
    this.area,
    this.instructions = '',
    this.ingredients = const [],
    this.matchedCount = 0,
    this.missingIngredients = const [],
  });

  final String id;
  final String title;

  /// Public HTTPS link. Images are never stored locally or in the database.
  final String? imageUrl;
  final String? category;
  final String? area;
  final String instructions;
  final List<RecipeIngredient> ingredients;

  /// How many of the user's selected ingredients this recipe uses.
  final int matchedCount;

  /// Names of recipe ingredients the user did not select.
  final List<String> missingIngredients;

  Recipe copyWith({int? matchedCount, List<String>? missingIngredients}) {
    return Recipe(
      id: id,
      title: title,
      imageUrl: imageUrl,
      category: category,
      area: area,
      instructions: instructions,
      ingredients: ingredients,
      matchedCount: matchedCount ?? this.matchedCount,
      missingIngredients: missingIngredients ?? this.missingIngredients,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        imageUrl,
        category,
        area,
        instructions,
        ingredients,
        matchedCount,
        missingIngredients,
      ];
}
