import 'package:flutter_test/flutter_test.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/repositories/ingredient_repository.dart';
import 'package:three_bhai/features/recipe/domain/usecases/get_ingredients.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/ingredient_selection_cubit.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/ingredient_selection_state.dart';

class _FakeRepo implements IngredientRepository {
  @override
  Future<List<Ingredient>> getIngredients() async => const [
        Ingredient(
            id: 'apple',
            name: 'Apple',
            emoji: '🍎',
            category: IngredientCategory.fruits),
        Ingredient(
            id: 'rice',
            name: 'Rice',
            emoji: '🍚',
            category: IngredientCategory.grains),
      ];
}

void main() {
  late IngredientSelectionCubit cubit;

  setUp(() async {
    cubit = IngredientSelectionCubit(GetIngredients(_FakeRepo()));
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads ingredients', () {
    expect(cubit.state.status, IngredientStatus.loaded);
    expect(cubit.state.all.length, 2);
  });

  test('filters by category and resets with All', () {
    cubit.selectCategory(IngredientCategory.grains);
    expect(cubit.state.visible.map((i) => i.id), ['rice']);
    cubit.selectCategory(null);
    expect(cubit.state.visible.length, 2);
  });

  test('multi-select toggles and enables generate', () {
    expect(cubit.state.canGenerate, isFalse);
    cubit.toggle('apple');
    cubit.toggle('rice');
    expect(cubit.state.selectedCount, 2);
    expect(cubit.state.canGenerate, isTrue);
    cubit.toggle('apple');
    expect(cubit.state.selectedCount, 1);
    cubit.clearSelection();
    expect(cubit.state.canGenerate, isFalse);
  });

  test('search narrows the list and ignores the collapse limit', () {
    cubit.setQuery('app');
    expect(cubit.state.visible.map((i) => i.id), ['apple']);
    cubit.setQuery('');
    expect(cubit.state.visible.length, 2);
  });
}
