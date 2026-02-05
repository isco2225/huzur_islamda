import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.timeLabel,
    this.isThinking = false,
  });

  final String text;
  final bool isUser;
  final String? timeLabel;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final crossAxisAlignment = isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    final bubbleColor = !isUser ? AppColors.primary : Colors.grey.shade400;

    final textColor = !isUser ? Colors.white : Colors.black87;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isUser ? 20 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 20),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
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
              if (isThinking && !isUser)
                const _TypingDots()
              else
                _buildStyledText(
                  text,
                  theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        height: 1.4,
                      ) ??
                      TextStyle(color: textColor, height: 1.4),
                  textColor,
                ),
              if (timeLabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  timeLabel!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: (!isUser ? Colors.white70 : Colors.grey[600]),
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

  Widget _buildStyledText(String text, TextStyle baseStyle, Color normalColor) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    // Tüm **...** pattern'lerini bul
    final matches = regex.allMatches(text);

    for (final match in matches) {
      // **...** öncesindeki normal metin
      if (match.start > lastEnd) {
        final normalText = text.substring(lastEnd, match.start);
        if (normalText.isNotEmpty) {
          spans.add(
            TextSpan(
              text: normalText,
              style: baseStyle.copyWith(
                color: normalColor,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        }
      }

      // **...** içindeki kalın metin (match.group(1) → ** olmadan içerik)
      final boldText = match.group(1) ?? '';
      if (boldText.isNotEmpty) {
        spans.add(
          TextSpan(
            text: boldText,
            style: baseStyle.copyWith(
              color: normalColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Son **...** sonrasındaki normal metin
    if (lastEnd < text.length) {
      final remainingText = text.substring(lastEnd);
      if (remainingText.isNotEmpty) {
        spans.add(
          TextSpan(
            text: remainingText,
            style: baseStyle.copyWith(
              color: normalColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        );
      }
    }

    // Eğer hiç **...** yoksa, tüm metni normal göster
    if (spans.isEmpty) {
      spans.add(
        TextSpan(
          text: text,
          style: baseStyle.copyWith(
            color: normalColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotCount = IntTween(begin: 1, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, _) {
        final dots = '.' * _dotCount.value;
        return Text(
          dots,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
