import 'package:equatable/equatable.dart';

enum IngredientCategory {
  fruits('Fruits', '🍎'),
  vegetables('Vegetables', '🥦'),
  grains('Grains', '🌾'),
  proteins('Proteins', '🍗'),
  seafood('Seafood', '🦐'),
  dairy('Dairy', '🧀'),
  spices('Spices', '🌶️'),
  pantry('Pantry', '🥫');

  const IngredientCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

class Ingredient extends Equatable {
  const Ingredient({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
  });

  final String id;
  final String name;
  final String emoji;
  final IngredientCategory category;

  @override
  List<Object?> get props => [id, name, emoji, category];
}
