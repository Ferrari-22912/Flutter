import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/domain/repositories/ingredient_repository.dart';

/// Built-in catalog of 99 ingredients. A later phase can move this to a
/// Supabase table without touching the UI (swap this repository).
class MockIngredientRepository implements IngredientRepository {
  @override
  Future<List<Ingredient>> getIngredients() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _catalog;
  }

  static const _f = IngredientCategory.fruits;
  static const _v = IngredientCategory.vegetables;
  static const _g = IngredientCategory.grains;
  static const _p = IngredientCategory.proteins;
  static const _s = IngredientCategory.seafood;
  static const _d = IngredientCategory.dairy;
  static const _x = IngredientCategory.spices;
  static const _y = IngredientCategory.pantry;

  static const List<Ingredient> _catalog = [
    Ingredient(id: 'apple', name: 'Apple', emoji: '🍎', category: _f),
    Ingredient(id: 'banana', name: 'Banana', emoji: '🍌', category: _f),
    Ingredient(id: 'lemon', name: 'Lemon', emoji: '🍋', category: _f),
    Ingredient(id: 'orange', name: 'Orange', emoji: '🍊', category: _f),
    Ingredient(id: 'strawberry', name: 'Strawberry', emoji: '🍓', category: _f),
    Ingredient(id: 'mango', name: 'Mango', emoji: '🥭', category: _f),
    Ingredient(id: 'pineapple', name: 'Pineapple', emoji: '🍍', category: _f),
    Ingredient(id: 'grapes', name: 'Grapes', emoji: '🍇', category: _f),
    Ingredient(id: 'watermelon', name: 'Watermelon', emoji: '🍉', category: _f),
    Ingredient(id: 'peach', name: 'Peach', emoji: '🍑', category: _f),
    Ingredient(id: 'cherry', name: 'Cherry', emoji: '🍒', category: _f),
    Ingredient(id: 'pear', name: 'Pear', emoji: '🍐', category: _f),
    Ingredient(id: 'coconut', name: 'Coconut', emoji: '🥥', category: _f),
    Ingredient(id: 'avocado', name: 'Avocado', emoji: '🥑', category: _f),
    Ingredient(id: 'kiwi', name: 'Kiwi', emoji: '🥝', category: _f),
    Ingredient(id: 'blueberries', name: 'Blueberries', emoji: '🫐', category: _f),
    Ingredient(id: 'melon', name: 'Melon', emoji: '🍈', category: _f),
    Ingredient(id: 'tomato', name: 'Tomato', emoji: '🍅', category: _v),
    Ingredient(id: 'onion', name: 'Onion', emoji: '🧅', category: _v),
    Ingredient(id: 'garlic', name: 'Garlic', emoji: '🧄', category: _v),
    Ingredient(id: 'potato', name: 'Potato', emoji: '🥔', category: _v),
    Ingredient(id: 'sweet_potato', name: 'Sweet potato', emoji: '🍠', category: _v),
    Ingredient(id: 'carrot', name: 'Carrot', emoji: '🥕', category: _v),
    Ingredient(id: 'broccoli', name: 'Broccoli', emoji: '🥦', category: _v),
    Ingredient(id: 'spinach', name: 'Spinach', emoji: '🥬', category: _v),
    Ingredient(id: 'cabbage', name: 'Cabbage', emoji: '🥬', category: _v),
    Ingredient(id: 'lettuce', name: 'Lettuce', emoji: '🥬', category: _v),
    Ingredient(id: 'cucumber', name: 'Cucumber', emoji: '🥒', category: _v),
    Ingredient(id: 'mushroom', name: 'Mushroom', emoji: '🍄', category: _v),
    Ingredient(id: 'eggplant', name: 'Eggplant', emoji: '🍆', category: _v),
    Ingredient(id: 'bell_pepper', name: 'Bell pepper', emoji: '🫑', category: _v),
    Ingredient(id: 'pumpkin', name: 'Pumpkin', emoji: '🎃', category: _v),
    Ingredient(id: 'olives', name: 'Olives', emoji: '🫒', category: _v),
    Ingredient(id: 'green_peas', name: 'Green peas', emoji: '🟢', category: _v),
    Ingredient(id: 'ginger', name: 'Ginger', emoji: '🟤', category: _v),
    Ingredient(id: 'rice', name: 'Rice', emoji: '🍚', category: _g),
    Ingredient(id: 'bread', name: 'Bread', emoji: '🍞', category: _g),
    Ingredient(id: 'pasta', name: 'Pasta', emoji: '🍝', category: _g),
    Ingredient(id: 'noodles', name: 'Noodles', emoji: '🍜', category: _g),
    Ingredient(id: 'flour', name: 'Flour', emoji: '🌾', category: _g),
    Ingredient(id: 'corn', name: 'Corn', emoji: '🌽', category: _g),
    Ingredient(id: 'oats', name: 'Oats', emoji: '🥣', category: _g),
    Ingredient(id: 'tortilla', name: 'Tortilla', emoji: '🫓', category: _g),
    Ingredient(id: 'baguette', name: 'Baguette', emoji: '🥖', category: _g),
    Ingredient(id: 'bagel', name: 'Bagel', emoji: '🥯', category: _g),
    Ingredient(id: 'croissant', name: 'Croissant', emoji: '🥐', category: _g),
    Ingredient(id: 'chicken', name: 'Chicken', emoji: '🍗', category: _p),
    Ingredient(id: 'beef', name: 'Beef', emoji: '🥩', category: _p),
    Ingredient(id: 'lamb', name: 'Lamb', emoji: '🍖', category: _p),
    Ingredient(id: 'pork', name: 'Pork', emoji: '🐖', category: _p),
    Ingredient(id: 'bacon', name: 'Bacon', emoji: '🥓', category: _p),
    Ingredient(id: 'sausage', name: 'Sausage', emoji: '🌭', category: _p),
    Ingredient(id: 'turkey', name: 'Turkey', emoji: '🦃', category: _p),
    Ingredient(id: 'kidney_beans', name: 'Kidney beans', emoji: '🔴', category: _p),
    Ingredient(id: 'chickpeas', name: 'Chickpeas', emoji: '🟡', category: _p),
    Ingredient(id: 'lentils', name: 'Lentils', emoji: '🟠', category: _p),
    Ingredient(id: 'black_beans', name: 'Black beans', emoji: '⚫', category: _p),
    Ingredient(id: 'peanuts', name: 'Peanuts', emoji: '🥜', category: _p),
    Ingredient(id: 'almonds', name: 'Almonds', emoji: '🌰', category: _p),
    Ingredient(id: 'fish', name: 'Fish', emoji: '🐟', category: _s),
    Ingredient(id: 'salmon', name: 'Salmon', emoji: '🐟', category: _s),
    Ingredient(id: 'tuna', name: 'Tuna', emoji: '🐟', category: _s),
    Ingredient(id: 'shrimp', name: 'Shrimp', emoji: '🦐', category: _s),
    Ingredient(id: 'crab', name: 'Crab', emoji: '🦀', category: _s),
    Ingredient(id: 'lobster', name: 'Lobster', emoji: '🦞', category: _s),
    Ingredient(id: 'squid', name: 'Squid', emoji: '🦑', category: _s),
    Ingredient(id: 'oyster', name: 'Oyster', emoji: '🦪', category: _s),
    Ingredient(id: 'milk', name: 'Milk', emoji: '🥛', category: _d),
    Ingredient(id: 'cheese', name: 'Cheese', emoji: '🧀', category: _d),
    Ingredient(id: 'butter', name: 'Butter', emoji: '🧈', category: _d),
    Ingredient(id: 'eggs', name: 'Eggs', emoji: '🥚', category: _d),
    Ingredient(id: 'yogurt', name: 'Yogurt', emoji: '🥛', category: _d),
    Ingredient(id: 'cream', name: 'Cream', emoji: '🥛', category: _d),
    Ingredient(id: 'paneer', name: 'Paneer', emoji: '🧀', category: _d),
    Ingredient(id: 'ghee', name: 'Ghee', emoji: '🧈', category: _d),
    Ingredient(id: 'chili', name: 'Chili', emoji: '🌶️', category: _x),
    Ingredient(id: 'salt', name: 'Salt', emoji: '🧂', category: _x),
    Ingredient(id: 'black_pepper', name: 'Black pepper', emoji: '⚫', category: _x),
    Ingredient(id: 'turmeric', name: 'Turmeric', emoji: '🟨', category: _x),
    Ingredient(id: 'cumin', name: 'Cumin', emoji: '🟫', category: _x),
    Ingredient(id: 'garam_masala', name: 'Garam masala', emoji: '🍂', category: _x),
    Ingredient(id: 'cardamom', name: 'Cardamom', emoji: '🟢', category: _x),
    Ingredient(id: 'cinnamon', name: 'Cinnamon', emoji: '🟫', category: _x),
    Ingredient(id: 'basil', name: 'Basil', emoji: '🌿', category: _x),
    Ingredient(id: 'coriander', name: 'Coriander', emoji: '🌱', category: _x),
    Ingredient(id: 'mint', name: 'Mint', emoji: '🍃', category: _x),
    Ingredient(id: 'oregano', name: 'Oregano', emoji: '🌿', category: _x),
    Ingredient(id: 'olive_oil', name: 'Olive oil', emoji: '🫒', category: _y),
    Ingredient(id: 'cooking_oil', name: 'Cooking oil', emoji: '🛢️', category: _y),
    Ingredient(id: 'sugar', name: 'Sugar', emoji: '🍬', category: _y),
    Ingredient(id: 'honey', name: 'Honey', emoji: '🍯', category: _y),
    Ingredient(id: 'vinegar', name: 'Vinegar', emoji: '🍶', category: _y),
    Ingredient(id: 'soy_sauce', name: 'Soy sauce', emoji: '🍶', category: _y),
    Ingredient(id: 'tomato_paste', name: 'Tomato paste', emoji: '🥫', category: _y),
    Ingredient(id: 'ketchup', name: 'Ketchup', emoji: '🥫', category: _y),
    Ingredient(id: 'mayonnaise', name: 'Mayonnaise', emoji: '🥫', category: _y),
    Ingredient(id: 'chocolate', name: 'Chocolate', emoji: '🍫', category: _y),
    Ingredient(id: 'baking_powder', name: 'Baking powder', emoji: '🥄', category: _y),
    Ingredient(id: 'stock', name: 'Veg stock', emoji: '🍲', category: _y),
  ];
}
