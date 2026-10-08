import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/features/recipe/data/models/meal_summary_model.dart';
import 'package:three_bhai/features/recipe/data/models/recipe_model.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe_search_result.dart';
import 'recipe_remote_data_source.dart';

/// DEMO MODE: calls TheMealDB's free public API directly (no secret key).
/// With Supabase configured, [EdgeFunctionRecipeDataSource] is used instead
/// and the real provider keys stay on the server.
class MealDbRecipeDataSource implements RecipeRemoteDataSource {
  MealDbRecipeDataSource(this._client);

  final http.Client _client;

  static const String _base = 'https://www.themealdb.com/api/json/v1/1';
  static const Duration _timeout = Duration(seconds: 12);
  static const int _maxResults = 10;

  static const Map<String, String> _aliases = {
    'shrimp': 'prawns',
    'corn': 'sweetcorn',
    'chili': 'chilli',
    'peanuts': 'peanut_butter',
    'bell pepper': 'red_pepper',
    'yogurt': 'natural_yogurt',
    'kidney beans': 'kidney_beans',
    'chickpeas': 'chickpeas',
  };

  @override
  Future<RecipeSearchResult> findRecipes(List<Ingredient> ingredients) async {
    const sourceName = 'TheMealDB';
    if (ingredients.isEmpty) {
      return const RecipeSearchResult(recipes: [], sourceName: sourceName);
    }

    final queries = ingredients.map(_queryName).toList();
    final results = await Future.wait(queries.map(_search));

    final counts = <String, int>{};
    for (final meals in results) {
      for (final meal in meals) {
        counts[meal.id] = (counts[meal.id] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) {
      return const RecipeSearchResult(recipes: [], sourceName: sourceName);
    }

    final topIds = (counts.keys.toList()
          ..sort((a, b) => counts[b]!.compareTo(counts[a]!)))
        .take(_maxResults)
        .toList();
    final details = await Future.wait(topIds.map(_lookup));

    final have = <String>{
      for (final i in ingredients) i.name.toLowerCase(),
      for (final q in queries) q.replaceAll('_', ' ').toLowerCase(),
    };

    final recipes = [
      for (final r in details.whereType<Recipe>())
        r.copyWith(
          matchedCount: counts[r.id] ?? 0,
          missingIngredients: r.ingredients
              .map((i) => i.name)
              .where((n) => !_isCovered(n, have))
              .toList(),
        ),
    ]..sort((a, b) {
        final byMatch = b.matchedCount.compareTo(a.matchedCount);
        return byMatch != 0
            ? byMatch
            : a.missingIngredients.length.compareTo(b.missingIngredients.length);
      });

    return RecipeSearchResult(recipes: recipes, sourceName: sourceName);
  }

  Future<List<MealSummaryModel>> _search(String query) async {
    var meals = await _filter(query);
    if (meals.isEmpty && !query.endsWith('s')) meals = await _filter('${query}s');
    return meals;
  }

  Future<List<MealSummaryModel>> _filter(String ingredient) async {
    final json = await _get('filter.php', {'i': ingredient});
    final meals = json['meals'];
    if (meals is! List) return const [];
    return meals
        .whereType<Map<String, dynamic>>()
        .map(MealSummaryModel.fromJson)
        .toList();
  }

  Future<Recipe?> _lookup(String id) async {
    final json = await _get('lookup.php', {'i': id});
    final meals = json['meals'];
    if (meals is! List || meals.isEmpty) return null;
    final first = meals.first;
    return first is Map<String, dynamic> ? RecipeModel.fromLookupJson(first) : null;
  }

  Future<Map<String, dynamic>> _get(String path, Map<String, String> query) async {
    final uri = Uri.parse('$_base/$path').replace(queryParameters: query);
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw ServerFailure(
          'The recipe service returned an error (${response.statusCode}).',
        );
      }
      if (response.body.trim().isEmpty) return const {};
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const NetworkFailure('The recipe service took too long. Try again.');
    } on http.ClientException {
      throw const NetworkFailure();
    } on FormatException {
      throw const ServerFailure('The recipe service sent an unexpected reply.');
    }
  }

  String _queryName(Ingredient i) {
    final n = i.name.toLowerCase();
    return _aliases[n] ?? n.replaceAll(' ', '_');
  }

  bool _isCovered(String recipeIngredient, Set<String> have) {
    final r = recipeIngredient.toLowerCase();
    return have.any((h) => r == h || r.contains(h) || h.contains(r));
  }
}
