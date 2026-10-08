import 'package:flutter/material.dart';
import 'package:three_bhai/core/theme/app_colors.dart';
import 'package:three_bhai/features/recipe/domain/entities/recipe.dart';

/// Network image with loading and error placeholders.
class RecipeImage extends StatelessWidget {
  const RecipeImage({super.key, required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    Widget placeholder([Widget? child]) => ColoredBox(
          color: AppColors.outline,
          child: Center(child: child),
        );

    final link = url;
    if (link == null) {
      return placeholder(const Icon(Icons.restaurant_rounded,
          size: 40, color: AppColors.muted));
    }
    return Image.network(
      link,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : placeholder(const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.ember,
              ),
            )),
      errorBuilder: (_, __, ___) => placeholder(const Icon(
          Icons.broken_image_outlined,
          size: 36,
          color: AppColors.muted)),
    );
  }
}

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.totalSelected,
    required this.onTap,
  });

  final Recipe recipe;
  final int totalSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final missing = recipe.missingIngredients;
    final shown = missing.take(4).join(', ');
    final extra = missing.length > 4 ? ' +${missing.length - 4} more' : '';

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: RecipeImage(url: recipe.imageUrl),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Uses ${recipe.matchedCount} of $totalSelected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: text.titleLarge),
                  if (recipe.category != null || recipe.area != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (recipe.category != null) _Tag(recipe.category!),
                        if (recipe.area != null) _Tag(recipe.area!),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    missing.isEmpty
                        ? 'You have everything you need.'
                        : 'Also needed: $shown$extra',
                    style: text.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
}
