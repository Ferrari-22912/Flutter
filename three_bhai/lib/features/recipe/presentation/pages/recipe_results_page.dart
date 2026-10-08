import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/theme/app_colors.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/recipe_results_cubit.dart';
import 'package:three_bhai/features/recipe/presentation/widgets/recipe_card.dart';
import 'package:three_bhai/features/recipe/presentation/widgets/recipe_detail_sheet.dart';

class RecipeResultsPage extends StatelessWidget {
  const RecipeResultsPage({
    super.key,
    required this.labels,
    this.canSearchAgain = true,
  });

  /// Ingredient chips shown in the header (for example "🍗 Chicken").
  final List<String> labels;

  /// False for saved history entries, which are shown as they were stored.
  final bool canSearchAgain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Header(
            labels: labels,
            title: canSearchAgain ? 'Recipes for you' : 'Saved recipes',
            onBack: () => Navigator.of(context).maybePop(),
            onRefresh: canSearchAgain
                ? () => context.read<RecipeResultsCubit>().retry()
                : null,
          ),
          Expanded(
            child: BlocBuilder<RecipeResultsCubit, RecipeResultsState>(
              builder: (context, state) =>
                  _Body(state: state, total: labels.length),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.labels,
    required this.title,
    required this.onBack,
    required this.onRefresh,
  });

  final List<String> labels;
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoundButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: onBack,
              ),
              const Spacer(),
              if (onRefresh != null)
                _RoundButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Search again',
                  onPressed: onRefresh!,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: text.headlineMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                BlocBuilder<RecipeResultsCubit, RecipeResultsState>(
                  builder: (context, state) {
                    final label = switch (state.status) {
                      RecipeSearchStatus.loading => 'Searching...',
                      RecipeSearchStatus.failure => 'Search failed',
                      RecipeSearchStatus.loaded =>
                        '${state.recipes.length} found via ${state.sourceName}',
                    };
                    return Text(
                      label,
                      style: text.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9)),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final label in labels)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon),
        color: Colors.white,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
        ),
      );
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.total});

  final RecipeResultsState state;
  final int total;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case RecipeSearchStatus.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.ember),
              SizedBox(height: 16),
              Text('Finding recipes...'),
            ],
          ),
        );
      case RecipeSearchStatus.failure:
        return _Message(
          icon: Icons.cloud_off_rounded,
          title: state.errorMessage ?? 'Could not load recipes.',
          actionLabel: 'Try again',
          onAction: () => context.read<RecipeResultsCubit>().retry(),
        );
      case RecipeSearchStatus.loaded:
        if (state.recipes.isEmpty) {
          return _Message(
            icon: Icons.search_off_rounded,
            title: 'No recipes matched these ingredients.',
            subtitle: 'Try selecting fewer or more common ingredients.',
            actionLabel: 'Go back',
            onAction: () => Navigator.of(context).maybePop(),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemCount: state.recipes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final recipe = state.recipes[index];
            return RecipeCard(
              recipe: recipe,
              totalSelected: total,
              onTap: () => showRecipeDetailSheet(context, recipe),
            );
          },
        );
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(backgroundColor: AppColors.ember),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
