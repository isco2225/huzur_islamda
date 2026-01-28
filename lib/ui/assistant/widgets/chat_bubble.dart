import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.timeLabel,
  });

  final String text;
  final bool isUser;
  final String? timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final crossAxisAlignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final bubbleColor = isUser
        ? AppColors.primary
        : theme.colorScheme.surface.withValues(alpha: 0.98);

    final textColor = isUser ? Colors.white : Colors.black87;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isUser ? 20 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 20),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  height: 1.4,
                ),
              ),
              if (timeLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  timeLabel!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: (isUser ? Colors.white70 : Colors.grey[600]),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

