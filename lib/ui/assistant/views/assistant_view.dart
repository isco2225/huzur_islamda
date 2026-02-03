import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class AssistantView extends StatelessWidget {
  const AssistantView({super.key, required this.viewModel});

  final AssistantViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return BaseScaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Asistan',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: AppColors.background,
      safeArea: true,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0.96),
                  ],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ValueListenableBuilder(
                    valueListenable: viewModel.messages,
                    builder: (context, messages, _) {
                      if (messages.isEmpty) {
                        return _EmptyChatPlaceholder(
                          responsivePadding: responsive.horizontalPadding,
                        );
                      }

                      return ValueListenableBuilder<bool>(
                        valueListenable: viewModel.sendMessage.running,
                        builder: (context, isRunning, __) {
                          final reversed = messages.reversed.toList();
                          final itemCount = isRunning
                              ? reversed.length + 1
                              : reversed.length;

                          return ListView.separated(
                            reverse: true,
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.horizontalPadding,
                              vertical: responsive.verticalPadding,
                            ),
                            itemBuilder: (context, index) {
                              // reverse: true olduğu için index 0 en altta.
                              final isTypingItem = isRunning && index == 0;

                              if (isTypingItem) {
                                return const ChatBubble(
                                  text: '',
                                  isUser: false,
                                  timeLabel: null,
                                  isThinking: true,
                                );
                              }

                              final message =
                                  reversed[isRunning ? index - 1 : index];
                              return ChatBubble(
                                text: message.text,
                                isUser: message.isUser,
                                timeLabel: message.timeLabel,
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 2),
                            itemCount: itemCount,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          ChatInputBar(onSend: viewModel.sendMessage.execute),
        ],
      ),
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder({required this.responsivePadding});

  final double responsivePadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsivePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Merhaba, ben senin asistanınım.',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sorularını, duaları, kuran ve hadisleri, ibadetle ilgili merak ettiklerini buradan sorabilirsin.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _SuggestionChip(label: 'Bugün hangi duayı okuyabilirim?'),
              _SuggestionChip(label: 'Bana kısa bir hadis paylaşır mısın?'),
              _SuggestionChip(label: 'Tesbih için bir zikir öner.'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      side: BorderSide(color: Colors.grey.shade300),
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[800]),
      ),
    );
  }
}
