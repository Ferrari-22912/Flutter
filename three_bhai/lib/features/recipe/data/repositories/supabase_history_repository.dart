import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/features/recipe/data/models/recipe_model.dart';
import 'package:three_bhai/features/recipe/data/models/search_record_model.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';
import 'package:three_bhai/features/recipe/domain/repositories/history_repository.dart';

/// Reads and writes `public.search_history`. Row Level Security guarantees a
/// signed-in user can only ever see, add or delete their own rows.
class SupabaseHistoryRepository implements HistoryRepository {
  SupabaseHistoryRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'search_history';

  @override
  Future<List<SearchRecord>> getHistory() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false)
          .limit(50);
      return rows.map<SearchRecord>(SearchRecordModel.fromRow).toList();
    } on PostgrestException {
      throw const ServerFailure('Could not load your history.');
    } catch (_) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> save({
    required List<String> ingredients,
    required String sourceName,
    required List<Recipe> recipes,
  }) async {
    // user_id is filled by the database from the caller's JWT (auth.uid()).
    await _client.from(_table).insert({
      'ingredients': ingredients,
      'source': sourceName,
      'recipes': recipes.map(RecipeModel.toJson).toList(),
    });
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  @override
  Future<void> clear() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from(_table).delete().eq('user_id', userId);
  }
}
