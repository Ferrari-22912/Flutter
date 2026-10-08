import 'package:three_bhai/features/recipe/data/datasources/recipe_remote_data_source.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe_search_result.dart';
import 'package:three_bhai/features/recipe/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  const RecipeRepositoryImpl(this._remote);

  final RecipeRemoteDataSource _remote;

  @override
  Future<RecipeSearchResult> findRecipes(List<Ingredient> ingredients) =>
      _remote.findRecipes(ingredients);
}
