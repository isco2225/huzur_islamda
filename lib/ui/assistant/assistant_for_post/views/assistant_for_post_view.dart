import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class AssistantForPostView extends StatelessWidget {
  const AssistantForPostView({
    super.key,
    required this.viewModel,
    required this.assistantViewModel,
  });

  final AssistantForPostViewModel viewModel;
  final AssistantViewModel assistantViewModel;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        final currentFocus = FocusScope.of(context);

        // Eğer bir TextField odakta ise önce klavyeyi kapat, sayfayı kapatma
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.unfocus();
          return;
        }

        Navigator.of(context).pop();
      },
      child: BaseScaffold(
        appBar: AssistantAppBar(
          viewModel: assistantViewModel,
          user: assistantViewModel.user,
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
              viewModel: assistantViewModel,
              isAnswering: viewModel.sendMessage.running,
              onSend: (userMessage) =>
                  viewModel.sendMessage.execute(userMessage),
            ),
          ],
        ),
      ),
    );
  }
}
