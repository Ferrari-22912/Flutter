import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/features/recipe/data/datasources/recipe_remote_data_source.dart';
import 'package:three_bhai/features/recipe/data/models/recipe_model.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe_search_result.dart';

/// Calls the `find-recipes` Edge Function. The function holds the Spoonacular
/// and Gemini keys, checks the caller's login and rate-limits per user.
/// The app itself never sees or contains a provider key.
class EdgeFunctionRecipeDataSource implements RecipeRemoteDataSource {
  EdgeFunctionRecipeDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<RecipeSearchResult> findRecipes(List<Ingredient> ingredients) async {
    try {
      final response = await _client.functions.invoke(
        'find-recipes',
        body: {'ingredients': ingredients.map((i) => i.name).toList()},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerFailure('The recipe service sent an unexpected reply.');
      }
      final list = data['recipes'];
      return RecipeSearchResult(
        recipes: list is List
            ? list
                .whereType<Map<String, dynamic>>()
                .map(RecipeModel.fromJson)
                .toList()
            : const [],
        sourceName: (data['source'] ?? 'Recipe service').toString(),
      );
    } on Failure {
      rethrow;
    } on FunctionException catch (e) {
      switch (e.status) {
        case 401:
          throw const AuthenticationFailure(
            'Your session expired. Please log in again.',
          );
        case 429:
          throw const Failure(
            'Too many searches. Wait a minute and try again.',
          );
        default:
          throw const ServerFailure();
      }
    } catch (_) {
      throw const NetworkFailure();
    }
  }
}
