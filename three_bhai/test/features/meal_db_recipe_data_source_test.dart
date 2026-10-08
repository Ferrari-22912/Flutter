import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:three_bhai/features/recipe/data/datasources/meal_db_recipe_data_source.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';

Map<String, dynamic> _meal(String id) => {'idMeal': id, 'strMeal': 'Meal $id'};

void main() {
  test('ranks by matched ingredients and reports missing ones', () async {
    final client = MockClient((request) async {
      final path = request.url.path;
      final i = request.url.queryParameters['i'];
      if (path.endsWith('filter.php')) {
        final meals = {
          'chicken': [_meal('1'), _meal('2')],
          'garlic': [_meal('2')],
        }[i];
        return http.Response(jsonEncode({'meals': meals}), 200);
      }
      if (path.endsWith('lookup.php')) {
        final meal = i == '2'
            ? {
                ..._meal('2'),
                'strIngredient1': 'Chicken',
                'strIngredient2': 'Garlic',
                'strIngredient3': 'Cream',
                'strMeasure1': '200g',
              }
            : {
                ..._meal('1'),
                'strIngredient1': 'Chicken',
                'strIngredient2': 'Rice',
              };
        return http.Response(jsonEncode({'meals': [meal]}), 200);
      }
      return http.Response('{}', 404);
    });

    final source = MealDbRecipeDataSource(client);
    final result = await source.findRecipes(const [
      Ingredient(
          id: 'chicken',
          name: 'Chicken',
          emoji: '🍗',
          category: IngredientCategory.proteins),
      Ingredient(
          id: 'garlic',
          name: 'Garlic',
          emoji: '🧄',
          category: IngredientCategory.vegetables),
    ]);

    expect(result.recipes.map((r) => r.id), ['2', '1']);
    expect(result.recipes.first.matchedCount, 2);
    expect(result.recipes.first.missingIngredients, ['Cream']);
    expect(result.recipes.last.missingIngredients, ['Rice']);
    expect(result.sourceName, 'TheMealDB');
  });
}
