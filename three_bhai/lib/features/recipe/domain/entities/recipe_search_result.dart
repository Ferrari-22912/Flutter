import 'package:equatable/equatable.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';

class RecipeSearchResult extends Equatable {
  const RecipeSearchResult({required this.recipes, required this.sourceName});

  final List<Recipe> recipes;
  final String sourceName;

  @override
  List<Object?> get props => [recipes, sourceName];
}
