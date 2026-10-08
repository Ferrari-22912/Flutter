import 'package:flutter_test/flutter_test.dart';
import 'package:three_bhai/features/recipe/data/models/recipe_model.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';

void main() {
  test('recipe survives a JSON round trip', () {
    const recipe = Recipe(
      id: 'sp-1',
      title: 'Garlic Chicken',
      imageUrl: 'https://example.com/a.jpg',
      category: 'Main',
      area: 'Italian',
      instructions: '1. Cook.',
      ingredients: [RecipeIngredient(name: 'Chicken', measure: '200 g')],
      matchedCount: 2,
      missingIngredients: ['Cream'],
    );
    expect(RecipeModel.fromJson(RecipeModel.toJson(recipe)), recipe);
  });
}
