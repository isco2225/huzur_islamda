import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.viewModel,
    required this.isAnswering,
    this.onSend,
  });

  final AssistantViewModel viewModel;
  final ValueListenable<bool> isAnswering;

  final void Function(String message)? onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend?.call(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 2,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  border: InputBorder.none,
                  isCollapsed: false,
                  contentPadding: EdgeInsets.all(4),
                  fillColor: Colors.white,
                  filled: true,
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 10),
            ListenableBuilder(
              listenable: Listenable.merge([
                widget.viewModel.dailyLimit,
                widget.viewModel.user,
                widget.isAnswering,
              ]),
              builder: (context, _) {
                return GestureDetector(
                  onTap: () => _isDisabled() ? null : _handleSend(),
                  child: Container(
                    width: responsive.isSmallScreen ? 32 : 42,
                    height: responsive.isSmallScreen ? 32 : 42,
                    decoration: BoxDecoration(
                      color: _isDisabled()
                          ? Colors.grey.shade500
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      size: responsive.isSmallScreen ? 16 : 20,
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

  bool _isDisabled() {
    return (widget.viewModel.dailyLimit.value <= 0 &&
            !widget.viewModel.user.value.isPremium) ||
        widget.isAnswering.value;
  }
}
