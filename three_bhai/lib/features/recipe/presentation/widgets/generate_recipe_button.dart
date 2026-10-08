import 'package:flutter/material.dart';
import 'package:three_bhai/core/theme/app_colors.dart';

/// Floating action pill. Muted until at least one ingredient is selected,
/// then animates into the brand gradient with a live count.
class GenerateRecipeButton extends StatelessWidget {
  const GenerateRecipeButton({
    super.key,
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(30);
    final label = enabled ? 'Generate recipe ($count)' : 'Select ingredients';
    final foreground = enabled ? Colors.white : AppColors.muted;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.outline,
          gradient: enabled ? AppColors.brandGradient : null,
          borderRadius: radius,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.ember.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    enabled
                        ? Icons.auto_awesome_rounded
                        : Icons.touch_app_outlined,
                    color: foreground,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      label,
                      key: ValueKey(label),
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
