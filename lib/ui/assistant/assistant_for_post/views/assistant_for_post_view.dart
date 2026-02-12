import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../view_models/view_models.dart' show AssistantMessage;
import '../../widgets/widgets.dart';
import '../view_models/view_models.dart';

class AssistantForPostView extends StatelessWidget {
  const AssistantForPostView({super.key, required this.viewModel});

  final AssistantForPostViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BaseScaffold(
      appBar: AppBar(title: const Text('Gönderi Hakkında')),
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
                  child: ValueListenableBuilder<List<AssistantMessage>>(
                    valueListenable: viewModel.messages,
                    builder: (context, messages, _) {
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
            onSend: (userMessage) => viewModel.sendMessage.execute(userMessage),
          ),
        ],
      ),
    );
  }
}
