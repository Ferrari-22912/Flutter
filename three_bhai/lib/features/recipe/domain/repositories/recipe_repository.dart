import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe_search_result.dart';

abstract interface class RecipeRepository {
  /// Throws a [Failure] on network or server errors.
  Future<RecipeSearchResult> findRecipes(List<Ingredient> ingredients);
}
