import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';

abstract final class RecipeModel {
  static String? _text(Object? value) {
    final s = value?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  /// Maps a TheMealDB `lookup.php` meal object to a [Recipe].
  static Recipe fromLookupJson(Map<String, dynamic> json) {
    final ingredients = <RecipeIngredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = _text(json['strIngredient$i']);
      if (name == null) continue;
      ingredients.add(RecipeIngredient(
        name: name,
        measure: _text(json['strMeasure$i']) ?? '',
      ));
    }
    return Recipe(
      id: json['idMeal'].toString(),
      title: _text(json['strMeal']) ?? 'Untitled recipe',
      imageUrl: _text(json['strMealThumb']),
      category: _text(json['strCategory']),
      area: _text(json['strArea']),
      instructions: _text(json['strInstructions']) ?? '',
      ingredients: ingredients,
    );
  }

  /// The app's own schema: used by the Edge Function reply and by history.
  static Recipe fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'];
    final rawMissing = json['missingIngredients'];
    return Recipe(
      id: json['id'].toString(),
      title: _text(json['title']) ?? 'Untitled recipe',
      imageUrl: _text(json['imageUrl']),
      category: _text(json['category']),
      area: _text(json['area']),
      instructions: _text(json['instructions']) ?? '',
      ingredients: rawIngredients is List
          ? rawIngredients
              .whereType<Map<String, dynamic>>()
              .map((e) => RecipeIngredient(
                    name: _text(e['name']) ?? '',
                    measure: _text(e['measure']) ?? '',
                  ))
              .where((e) => e.name.isNotEmpty)
              .toList()
          : const [],
      matchedCount: (json['matchedCount'] as num?)?.toInt() ?? 0,
      missingIngredients: rawMissing is List
          ? rawMissing.map((e) => e.toString()).toList()
          : const [],
    );
  }

  static Map<String, dynamic> toJson(Recipe r) => {
        'id': r.id,
        'title': r.title,
        // Only a public https link is ever stored, never image bytes.
        'imageUrl': r.imageUrl,
        'category': r.category,
        'area': r.area,
        'instructions': r.instructions,
        'ingredients': [
          for (final i in r.ingredients) {'name': i.name, 'measure': i.measure},
        ],
        'matchedCount': r.matchedCount,
        'missingIngredients': r.missingIngredients,
      };
}
