import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_bhai/features/auth/domain/repositories/auth_repository.dart';
import 'package:three_bhai/features/recipe/data/models/recipe_model.dart';
import 'package:three_bhai/features/recipe/data/models/search_record_model.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';
import 'package:three_bhai/features/recipe/domain/repositories/history_repository.dart';

/// DEMO MODE: on-device history, stored under a key that includes the user id,
/// so two accounts on the same phone never see each other's records.
class LocalHistoryRepository implements HistoryRepository {
  LocalHistoryRepository(this._auth);

  final AuthRepository _auth;
  static const _maxItems = 50;

  String get _key => 'history_v1_${_auth.currentUser?.id ?? 'signed_out'}';

  Future<List<Map<String, dynamic>>> _rows() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(rows));
  }

  @override
  Future<List<SearchRecord>> getHistory() async =>
      (await _rows()).map(SearchRecordModel.fromRow).toList();

  @override
  Future<void> save({
    required List<String> ingredients,
    required String sourceName,
    required List<Recipe> recipes,
  }) async {
    final rows = await _rows();
    rows.insert(0, {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'ingredients': ingredients,
      'source': sourceName,
      'recipes': recipes.map(RecipeModel.toJson).toList(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _write(rows.take(_maxItems).toList());
  }

  @override
  Future<void> delete(String id) async {
    final rows = await _rows();
    await _write(rows.where((r) => r['id'].toString() != id).toList());
  }

  @override
  Future<void> clear() => _write([]);
}
