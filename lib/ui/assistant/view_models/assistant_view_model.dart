import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class AssistantMessage {
  AssistantMessage({
    required this.text,
    required this.isUser,
    this.timeLabel,
  });

  final String text;
  final bool isUser;
  final String? timeLabel;
}

class AssistantViewModel {
  AssistantViewModel() {
    _log.fine('Initialized');

    messages.value = [
      AssistantMessage(
        text: 'Selam, bugün sana nasıl yardımcı olabilirim?',
        isUser: false,
        timeLabel: '09:12',
      ),
    ];
  }

  // LOGGER
  final _log = Logger('AssistantViewModel');

  // STATE
  final ValueNotifier<List<AssistantMessage>> messages =
      ValueNotifier<List<AssistantMessage>>([]);

  final ValueNotifier<bool> isThinking = ValueNotifier<bool>(false);

  // PUBLIC API
  void sendUserMessage(String text) {
    if (text.trim().isEmpty) return;

    final current = List<AssistantMessage>.from(messages.value);
    current.add(
      AssistantMessage(
        text: text.trim(),
        isUser: true,
        timeLabel: _nowLabel,
      ),
    );
    messages.value = current;

    // Şimdilik basit bir demo cevabı ekleyelim.
    _addAssistantReply(
      'Not aldım. Yakında buraya gerçek yapay zeka cevabı gelecek.',
    );
  }

  // PRIVATE HELPERS
  void _addAssistantReply(String text) {
    final current = List<AssistantMessage>.from(messages.value);
    current.add(
      AssistantMessage(
        text: text,
        isUser: false,
        timeLabel: _nowLabel,
      ),
    );
    messages.value = current;
  }

  String get _nowLabel {
    final now = DateTime.now();
    String twoDigits(int v) => v.toString().padLeft(2, '0');
    return '${twoDigits(now.hour)}:${twoDigits(now.minute)}';
  }

  // DISPOSE
  void dispose() {
    messages.dispose();
    isThinking.dispose();
    _log.fine('Disposed');
  }
}
