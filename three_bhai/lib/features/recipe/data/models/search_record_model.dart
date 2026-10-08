import 'package:three_bhai/features/recipe/data/models/recipe_model.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';

abstract final class SearchRecordModel {
  static SearchRecord fromRow(Map<String, dynamic> row) {
    final recipes = row['recipes'];
    final ingredients = row['ingredients'];
    return SearchRecord(
      id: row['id'].toString(),
      ingredients: ingredients is List
          ? ingredients.map((e) => e.toString()).toList()
          : const [],
      sourceName: (row['source'] ?? '').toString(),
      recipes: recipes is List
          ? recipes
              .whereType<Map<String, dynamic>>()
              .map(RecipeModel.fromJson)
              .toList()
          : const [],
      createdAt: DateTime.tryParse((row['created_at'] ?? '').toString())
              ?.toLocal() ??
          DateTime.now(),
    );
  }
}
