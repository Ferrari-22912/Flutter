import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/repositories/ingredient_repository.dart';

class GetIngredients implements UseCase<List<Ingredient>, NoParams> {
  const GetIngredients(this._repository);
  final IngredientRepository _repository;

  @override
  Future<List<Ingredient>> call(NoParams params) =>
      _repository.getIngredients();
}
