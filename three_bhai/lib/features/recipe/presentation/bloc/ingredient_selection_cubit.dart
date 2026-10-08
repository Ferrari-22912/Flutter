import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/core/usecase/usecase.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/usecases/get_ingredients.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/ingredient_selection_state.dart';

class IngredientSelectionCubit extends Cubit<IngredientSelectionState> {
  IngredientSelectionCubit(this._getIngredients)
      : super(const IngredientSelectionState());

  final GetIngredients _getIngredients;

  Future<void> load() async {
    emit(state.copyWith(status: IngredientStatus.loading));
    try {
      final items = await _getIngredients(const NoParams());
      emit(state.copyWith(status: IngredientStatus.loaded, all: items));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: IngredientStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: IngredientStatus.failure,
        errorMessage: 'Could not load ingredients. Try again.',
      ));
    }
  }

  void selectCategory(IngredientCategory? category) {
    if (category == state.category) return;
    emit(state.copyWith(category: () => category, expanded: false));
  }

  void setQuery(String query) {
    if (query == state.query) return;
    emit(state.copyWith(query: query, expanded: false));
  }

  void toggle(String id) {
    final next = {...state.selectedIds};
    if (!next.remove(id)) next.add(id);
    emit(state.copyWith(selectedIds: next));
  }

  void toggleExpanded() => emit(state.copyWith(expanded: !state.expanded));

  void clearSelection() => emit(state.copyWith(selectedIds: const {}));
}
