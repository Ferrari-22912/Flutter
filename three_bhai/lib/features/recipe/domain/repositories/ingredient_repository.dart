import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';

abstract interface class IngredientRepository {
  Future<List<Ingredient>> getIngredients();
}
