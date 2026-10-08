import 'package:flutter/material.dart';
import 'package:three_bhai/core/theme/app_colors.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';
import 'package:three_bhai/features/recipe/presentation/widgets/recipe_card.dart';

Future<void> showRecipeDetailSheet(BuildContext context, Recipe recipe) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) =>
          _RecipeDetail(recipe: recipe, controller: controller),
    ),
  );
}

class _RecipeDetail extends StatelessWidget {
  const _RecipeDetail({required this.recipe, required this.controller});

  final Recipe recipe;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: RecipeImage(url: recipe.imageUrl),
          ),
        ),
        const SizedBox(height: 16),
        Text(recipe.title, style: text.headlineSmall),
        const SizedBox(height: 20),
        Text('Ingredients', style: text.titleLarge),
        const SizedBox(height: 10),
        for (final item in recipe.ingredients)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Icon(
                  recipe.missingIngredients.contains(item.name)
                      ? Icons.shopping_basket_outlined
                      : Icons.check_circle_rounded,
                  size: 20,
                  color: recipe.missingIngredients.contains(item.name)
                      ? AppColors.muted
                      : AppColors.ember,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.measure.isEmpty
                        ? item.name
                        : '${item.measure} ${item.name}',
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text('Method', style: text.titleLarge),
        const SizedBox(height: 10),
        Text(
          recipe.instructions.isEmpty
              ? 'No instructions provided by this source.'
              : recipe.instructions,
          style: text.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
