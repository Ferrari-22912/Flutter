import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:three_bhai/core/config/app_config.dart';
import 'package:three_bhai/core/theme/app_colors.dart';
import 'package:three_bhai/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:three_bhai/features/chat/presentation/widgets/message_bubble.dart';

/// The signed-in user's private chat with Chef Bhai (cooking topics only).
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  static const _suggestions = [
    'What can I cook with eggs and rice?',
    'Substitute for butter in baking?',
    'How long do I boil eggs?',
    'How do I store cooked chicken?',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    context.read<ChatCubit>().send(text);
    _input.clear();
    _toBottom();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _confirmClear() async {
    final cubit = context.read<ChatCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear this chat?'),
        content: const Text('Your messages with Chef Bhai will be deleted.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
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
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.status == ChatStatus.ready) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          if (state.failedText != null && _input.text.isEmpty) {
            _input.text = state.failedText!;
          }
          context.read<ChatCubit>().errorShown();
        }
        _toBottom();
      },
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              _Header(
                canClear: state.messages.isNotEmpty,
                onClear: _confirmClear,
              ),
              if (!AppConfig.hasSupabase)
                Container(
                  width: double.infinity,
                  color: AppColors.outline,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text(
                    'Demo mode: connect Supabase + Gemini for real answers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: AppColors.ink),
                  ),
                ),
              Expanded(child: _buildBody(state)),
              _InputBar(
                controller: _input,
                enabled: state.status == ChatStatus.ready && !state.isSending,
                onSend: _send,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ChatState state) {
    switch (state.status) {
      case ChatStatus.loading:
        return const Center(
            child: CircularProgressIndicator(color: AppColors.ember));
      case ChatStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                Text(state.errorMessage ?? 'Could not load your chat.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.read<ChatCubit>().load(),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ember),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      case ChatStatus.ready:
        if (state.messages.isEmpty && !state.isSending) {
          return _Welcome(onPick: _send, suggestions: _suggestions);
        }
        return ListView(
          controller: _scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          children: [
            for (final m in state.messages) MessageBubble(message: m),
            if (state.isSending) const TypingBubble(),
          ],
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.canClear, required this.onClear});

  final bool canClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 18),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.white,
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2)),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/logo.png',
                width: 44, height: 44, semanticLabel: '3Bhai logo'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chef Bhai',
                    style: text.titleLarge?.copyWith(color: Colors.white)),
                Text(
                  'Cooking questions only. Private to you.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (canClear)
            IconButton(
              onPressed: onClear,
              tooltip: 'Clear chat',
              icon: const Icon(Icons.delete_sweep_outlined),
              color: Colors.white,
              style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2)),
            ),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onPick, required this.suggestions});

  final ValueChanged<String> onPick;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text('Salaam! I am Chef Bhai.', style: text.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Ask me about recipes, ingredients, substitutions, cooking times '
            'and food storage. I only talk about cooking.',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final s in suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: () => onPick(s),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.outline, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                maxLength: 500,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Ask about cooking...',
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: 10),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final canSend = enabled && value.text.trim().isNotEmpty;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: canSend ? 1 : 0.45,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: canSend ? onSend : null,
                      tooltip: 'Send',
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
