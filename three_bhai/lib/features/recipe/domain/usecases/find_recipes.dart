import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe_search_result.dart';
import 'package:three_bhai/features/recipe/domain/repositories/history_repository.dart';
import 'package:three_bhai/features/recipe/domain/repositories/recipe_repository.dart';

/// Finds recipes, then saves the search to the user's private history.
/// A failure to save never breaks the search itself.
class FindRecipes implements UseCase<RecipeSearchResult, List<Ingredient>> {
  const FindRecipes(this._recipes, this._history);

  final RecipeRepository _recipes;
  final HistoryRepository _history;

  @override
  Future<RecipeSearchResult> call(List<Ingredient> params) async {
    final result = await _recipes.findRecipes(params);
    if (result.recipes.isNotEmpty) {
      try {
        await _history.save(
          ingredients: params.map((i) => i.name).toList(),
          sourceName: result.sourceName,
          recipes: result.recipes,
        );
      } catch (_) {
        // History is a convenience; ignore storage errors.
      }
    }
    return result;
  }
}
