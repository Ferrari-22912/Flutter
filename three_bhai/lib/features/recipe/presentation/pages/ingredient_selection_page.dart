import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/theme/app_colors.dart';
import 'package:three_bhai/features/recipe/domain/entities/ingredient.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/ingredient_selection_cubit.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/ingredient_selection_state.dart';
import 'package:three_bhai/features/recipe/presentation/widgets/category_bar.dart';
import 'package:three_bhai/features/recipe/presentation/widgets/generate_recipe_button.dart';
import 'package:three_bhai/features/recipe/presentation/widgets/ingredient_tile.dart';

class IngredientSelectionPage extends StatelessWidget {
  const IngredientSelectionPage({
    super.key,
    required this.onGenerate,
    required this.onLogout,
    required this.onOpenHistory,
    required this.onOpenChat,
  });

  /// Receives the selected ingredients.
  final ValueChanged<List<Ingredient>> onGenerate;

  /// Called after the user confirms logging out.
  final VoidCallback onLogout;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenChat;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to find recipes.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.ember),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IngredientSelectionCubit, IngredientSelectionState>(
      builder: (context, state) {
        final cubit = context.read<IngredientSelectionCubit>();

        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: state.status == IngredientStatus.loaded
              ? GenerateRecipeButton(
                  count: state.selectedCount,
                  onPressed: state.canGenerate
                      ? () => onGenerate(state.selected)
                      : null,
                )
              : null,
          body: Column(
            children: [
              _Header(
                selectedCount: state.selectedCount,
                onClear: cubit.clearSelection,
                onLogout: () => _confirmLogout(context),
                onOpenHistory: onOpenHistory,
                onOpenChat: onOpenChat,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: TextField(
                  onChanged: cubit.setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: state.all.isEmpty
                        ? 'Search ingredients'
                        : 'Search ${state.all.length} ingredients',
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              CategoryBar(
                selected: state.category,
                onSelected: cubit.selectCategory,
              ),
              Expanded(child: _Body(state: state)),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedCount,
    required this.onClear,
    required this.onLogout,
    required this.onOpenHistory,
    required this.onOpenChat,
  });

  final int selectedCount;
  final VoidCallback onClear;
  final VoidCallback onLogout;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, topInset + 8, 24, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 40,
                  height: 40,
                  semanticLabel: '3Bhai logo',
                ),
              ),
              const SizedBox(width: 10),
              Text('3Bhai',
                  style: text.titleLarge?.copyWith(color: Colors.white)),
              const Spacer(),
              _HeaderAction(
                icon: Icons.chat_bubble_outline_rounded,
                tooltip: 'Ask Chef Bhai',
                onPressed: onOpenChat,
              ),
              const SizedBox(width: 6),
              _HeaderAction(
                icon: Icons.history_rounded,
                tooltip: 'My recipe history',
                onPressed: onOpenHistory,
              ),
              const SizedBox(width: 6),
              _HeaderAction(
                icon: Icons.logout_rounded,
                tooltip: 'Log out',
                onPressed: onLogout,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "What's in your kitchen?",
            style: text.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            "Tap everything you have. We'll find a recipe that fits.",
            style: text.bodyMedium
                ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    selectedCount == 0
                        ? 'Nothing selected yet'
                        : '$selectedCount selected',
                    key: ValueKey(selectedCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: selectedCount > 0 ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: selectedCount == 0,
                    child: TextButton(
                      onPressed: onClear,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Clear all'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});
  final IngredientSelectionState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<IngredientSelectionCubit>();

    switch (state.status) {
      case IngredientStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.ember),
        );
      case IngredientStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                Text(
                  state.errorMessage ?? 'Could not load ingredients.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: cubit.load,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ember,
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      case IngredientStatus.loaded:
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _IngredientGrid(
            key: ValueKey(state.category),
            state: state,
            cubit: cubit,
          ),
        );
    }
  }
}

class _IngredientGrid extends StatelessWidget {
  const _IngredientGrid({super.key, required this.state, required this.cubit});

  final IngredientSelectionState state;
  final IngredientSelectionCubit cubit;

  @override
  Widget build(BuildContext context) {
    final items = state.visible;

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No ingredients match your search.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 130,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return IngredientTile(
                ingredient: item,
                selected: state.selectedIds.contains(item.id),
                onTap: () => cubit.toggle(item.id),
              );
            },
          ),
        ),
        if (state.hasMore)
          SliverToBoxAdapter(
            child: Center(
              child: TextButton.icon(
                onPressed: cubit.toggleExpanded,
                style: TextButton.styleFrom(foregroundColor: AppColors.ember),
                icon: Icon(
                  state.expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                ),
                label: Text(
                  state.expanded
                      ? 'Show less'
                      : 'Show all ${state.filtered.length}',
                ),
              ),
            ),
          ),
        // Clearance so the floating button never covers the last row.
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
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
