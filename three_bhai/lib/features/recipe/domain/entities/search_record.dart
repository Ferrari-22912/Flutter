import 'package:equatable/equatable.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';

/// One past search belonging to the signed-in user.
class SearchRecord extends Equatable {
  const SearchRecord({
    required this.id,
    required this.ingredients,
    required this.sourceName,
    required this.recipes,
    required this.createdAt,
  });

  final String id;
  final List<String> ingredients;
  final String sourceName;
  final List<Recipe> recipes;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, ingredients, sourceName, recipes, createdAt];
}
