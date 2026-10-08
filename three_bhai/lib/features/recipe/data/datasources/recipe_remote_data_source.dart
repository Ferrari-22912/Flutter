import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe_search_result.dart';

abstract interface class RecipeRemoteDataSource {
  Future<RecipeSearchResult> findRecipes(List<Ingredient> ingredients);
}
