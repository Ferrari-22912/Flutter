import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/error/failures.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';
import 'package:three_bhai/features/recipe/domain/usecases/find_recipes.dart';

enum RecipeSearchStatus { loading, loaded, failure }

class RecipeResultsState extends Equatable {
  const RecipeResultsState({
    this.status = RecipeSearchStatus.loading,
    this.recipes = const [],
    this.sourceName = '',
    this.errorMessage,
  });

  final RecipeSearchStatus status;
  final List<Recipe> recipes;
  final String sourceName;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, recipes, sourceName, errorMessage];
}

class RecipeResultsCubit extends Cubit<RecipeResultsState> {
  RecipeResultsCubit(this._findRecipes) : super(const RecipeResultsState());

  final FindRecipes _findRecipes;
  List<Ingredient> _last = const [];
  int _requestId = 0;

  Future<void> search(List<Ingredient> ingredients) async {
    _last = ingredients;
    final id = ++_requestId;
    emit(const RecipeResultsState());
    try {
      final result = await _findRecipes(ingredients);
      if (id != _requestId) return;
      emit(RecipeResultsState(
        status: RecipeSearchStatus.loaded,
        recipes: result.recipes,
        sourceName: result.sourceName,
      ));
    } on Failure catch (e) {
      if (id != _requestId) return;
      emit(RecipeResultsState(
        status: RecipeSearchStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      if (id != _requestId) return;
      emit(const RecipeResultsState(
        status: RecipeSearchStatus.failure,
        errorMessage: 'Something went wrong while finding recipes.',
      ));
    }
  }

  Future<void> retry() => search(_last);

  /// Shows a saved history entry without calling any API.
  void showSaved(SearchRecord record) {
    _requestId++;
    emit(RecipeResultsState(
      status: RecipeSearchStatus.loaded,
      recipes: record.recipes,
      sourceName: record.sourceName,
    ));
  }
}
