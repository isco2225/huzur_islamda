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
      appBar: AssistantAppBar(viewModel: viewModel, user: viewModel.user),
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
                          onSuggestionTap: (text) =>
                              viewModel.sendMessage.execute(text),
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
          ChatInputBar(
            viewModel: viewModel,
            isAnswering: viewModel.sendMessage.running,
            onSend: (userMessage) => viewModel.sendMessage.execute(userMessage),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder({
    required this.responsivePadding,
    required this.onSuggestionTap,
  });

  final double responsivePadding;
  final void Function(String text) onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsivePadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: context.screenWidth * 0.25,
              color: AppColors.primary,
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
              'Sorularını, duaları, kuran ve hadisleri, islam ile ilgili merak ettiklerini buradan sorabilirsin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SuggestionChip(
                  label: 'Peygamberimizin en sık okuduğu dualar nelerdir?',
                  onTap: () => onSuggestionTap(
                    'Peygamberimizin en sık okuduğu dualar nelerdir?',
                  ),
                ),
                _SuggestionChip(
                  label: 'Bana kısa bir buhari hadis paylaşır mısın?',
                  onTap: () => onSuggestionTap(
                    'Bana kısa bir buhari hadis paylaşır mısın?',
                  ),
                ),
                _SuggestionChip(
                  label: 'Tesbih için bir zikir önerir misin?',
                  onTap: () => onSuggestionTap('Tesbih için bir zikir öner.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        side: BorderSide(color: AppColors.primary),
        label: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[800]),
        ),
      ),
    );
  }
}
