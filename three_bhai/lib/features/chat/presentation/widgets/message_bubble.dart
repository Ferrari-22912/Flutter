import 'package:flutter/material.dart';
import 'package:three_bhai/core/theme/app_colors.dart';
import 'package:three_bhai/features/chat/domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.8;

    const radius = Radius.circular(20);
    final shape = BorderRadius.only(
      topLeft: radius,
      topRight: radius,
      bottomLeft: isUser ? radius : const Radius.circular(6),
      bottomRight: isUser ? const Radius.circular(6) : radius,
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isUser ? null : Colors.white,
              gradient: isUser ? AppColors.brandGradient : null,
              borderRadius: shape,
              border: isUser
                  ? null
                  : Border.all(
                      color: message.onTopic
                          ? AppColors.outline
                          : AppColors.flame.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
            ),
            child: isUser
                ? Text(
                    message.text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, height: 1.35),
                  )
                : SelectableText(
                    message.text,
                    style: const TextStyle(
                        color: AppColors.ink, fontSize: 15, height: 1.4),
                  ),
          ),
        ),
      ),
    );
  }
}

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outline, width: 1.5),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    child: Opacity(
                      opacity: 0.3 +
                          0.7 *
                              ((_controller.value * 3 - i).clamp(0.0, 1.0) *
                                  (1 - (_controller.value * 3 - i - 1).clamp(0.0, 1.0))),
                      child: const CircleAvatar(
                          radius: 4, backgroundColor: AppColors.ember),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
