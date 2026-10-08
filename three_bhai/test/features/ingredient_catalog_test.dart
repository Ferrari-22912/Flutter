import 'package:flutter_test/flutter_test.dart';
import 'package:three_bhai/features/recipe/data/repositories/mock_ingredient_repository.dart';

void main() {
  test('catalog is large with unique ids', () async {
    final items = await MockIngredientRepository().getIngredients();
    expect(items.length, greaterThanOrEqualTo(90));
    expect(items.map((i) => i.id).toSet().length, items.length);
  });
}
