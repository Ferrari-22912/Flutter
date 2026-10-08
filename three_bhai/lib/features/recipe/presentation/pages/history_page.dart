import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/theme/app_colors.dart';
import 'package:three_bhai/core/utils/time_ago.dart';
import 'package:three_bhai/features/recipe/domain/entities/search_record.dart';
import 'package:three_bhai/features/recipe/presentation/bloc/history_cubit.dart';

/// The signed-in user's own past searches. Nobody else can see these.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.onOpen});

  final ValueChanged<SearchRecord> onOpen;

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<HistoryCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This removes every saved search from your account.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.ember),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) cubit.clear();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Column(
        children: [
          Container(
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
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    const Spacer(),
                    BlocBuilder<HistoryCubit, HistoryState>(
                      builder: (context, state) => state.records.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                              onPressed: () => _confirmClear(context),
                              tooltip: 'Clear all',
                              icon: const Icon(Icons.delete_sweep_outlined),
                              color: Colors.white,
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My recipes',
                          style: text.headlineMedium
                              ?.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Private to your account.',
                        style: text.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                switch (state.status) {
                  case HistoryStatus.loading:
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.ember),
                    );
                  case HistoryStatus.failure:
                    return _Centered(
                      icon: Icons.cloud_off_rounded,
                      title: state.errorMessage ?? 'Could not load history.',
                      actionLabel: 'Try again',
                      onAction: () => context.read<HistoryCubit>().load(),
                    );
                  case HistoryStatus.loaded:
                    if (state.records.isEmpty) {
                      return _Centered(
                        icon: Icons.menu_book_rounded,
                        title: 'No saved recipes yet.',
                        subtitle:
                            'Every search you make is saved here, just for you.',
                        actionLabel: 'Pick ingredients',
                        onAction: () => Navigator.of(context).maybePop(),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      itemCount: state.records.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final record = state.records[index];
                        return Dismissible(
                          key: ValueKey(record.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) =>
                              context.read<HistoryCubit>().delete(record.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(
                              color: AppColors.ember,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.white),
                          ),
                          child: _HistoryTile(
                            record: record,
                            onTap: () => onOpen(record),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record, required this.onTap});

  final SearchRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shown = record.ingredients.take(5).toList();
    final extra = record.ingredients.length - shown.length;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.outline, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${record.recipes.length} recipes via ${record.sourceName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  Text(
                    timeAgo(record.createdAt),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12.5),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final name in shown)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Text(name,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  if (extra > 0)
                    Text('+$extra more',
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({
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
  Widget build(BuildContext context) => Center(
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
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.ember),
                child: Text(actionLabel),
              ),
            ],
          ),
        ),
      );
}
