import 'package:flutter/material.dart';
import 'package:three_bhai/core/theme/app_colors.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// `null` means "All".
  final IngredientCategory? selected;
  final ValueChanged<IngredientCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = IngredientCategory.values;

    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = index == 0 ? null : categories[index - 1];
          return _CategoryChip(
            label: category == null
                ? 'All'
                : '${category.emoji} ${category.label}',
            selected: category == selected,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: selected ? AppColors.brandGradient : null,
        borderRadius: radius,
        border: Border.all(
          color: selected ? Colors.transparent : AppColors.outline,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.ink,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
