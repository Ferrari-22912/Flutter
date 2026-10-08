import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';

/// Always scoped to the signed-in user. No method can read another user's data.
abstract interface class HistoryRepository {
  Future<List<SearchRecord>> getHistory();

  Future<void> save({
    required List<String> ingredients,
    required String sourceName,
    required List<Recipe> recipes,
  });

  Future<void> delete(String id);
  Future<void> clear();
}
