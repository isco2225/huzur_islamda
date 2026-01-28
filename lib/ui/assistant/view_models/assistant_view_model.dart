import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

class AssistantMessage {
  AssistantMessage({required this.text, required this.isUser, this.timeLabel});

  final String text;
  final bool isUser;
  final String? timeLabel;
}

class AssistantViewModel {
  AssistantViewModel({
    required AssistantRepository assistantRepository,
    required UserRepository userRepository,
  }) : _assistantRepository = assistantRepository,
       _userRepository = userRepository {
    // DEFINE COMMANDS
    sendMessage = Command1<void, String>(
      _sendMessage,
      debugLabel: 'sendMessage',
    );

    // Default welcome message
    messages.value = [
      AssistantMessage(
        text:
            'Selam ${_userRepository.currentUser.value.name}, bugün sana nasıl yardımcı olabilirim?',
        isUser: false,
        timeLabel: _nowLabel,
      ),
    ];
  }
  // logger
  final _log = Logger('AssistantViewModel');
  // repositories and use cases
  final AssistantRepository _assistantRepository;
  final UserRepository _userRepository;
  // state
  final ValueNotifier<List<AssistantMessage>> messages =
      ValueNotifier<List<AssistantMessage>>([]);
  // commands
  late final Command1<void, String> sendMessage;
  // dispose
  void dispose() {
    messages.dispose();
    sendMessage.dispose();
    _log.fine('Disposed');
  }

  // functions

  Future<Result<void>> _sendMessage(String userMessage) async {
    // Mevcut mesaj listesini (geçmiş) kopyala
    final previousMessages = List<AssistantMessage>.from(messages.value);

    // Yeni kullanıcı mesajını listeye ekle
    final current = List<AssistantMessage>.from(previousMessages);
    current.add(
      AssistantMessage(text: userMessage, isUser: true, timeLabel: _nowLabel),
    );
    messages.value = current;

    final user = _userRepository.currentUser.value;

    final List<AssistantMessage> limitedHistory;
    if (previousMessages.length <= 2) {
      limitedHistory = previousMessages;
    } else {
      limitedHistory = previousMessages.sublist(previousMessages.length - 2);
    }
    final previousTexts = limitedHistory.map((m) => m.text).toList();
    final result = await _assistantRepository.sendMessage(
      message: userMessage,
      senderName: user.name.isNotEmpty ? user.name : 'Kullanıcı',
      senderAge: _getUserAge(),
      senderGender: 'Erkek',
      previousMessages: previousTexts,
    );
    switch (result) {
      case Ok():
        _log.info('Message sent successfully');
        _addAssistantReply(result.asOk.value);
        return Result.ok(null);
      case Error():
        _log.warning('Message sending failed: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }

  void _addAssistantReply(String text) {
    final current = List<AssistantMessage>.from(messages.value);
    current.add(
      AssistantMessage(text: text, isUser: false, timeLabel: _nowLabel),
    );
    messages.value = current;
  }

  String get _nowLabel {
    final now = DateTime.now();
    String twoDigits(int v) => v.toString().padLeft(2, '0');
    return '${twoDigits(now.hour)}:${twoDigits(now.minute)}';
  }

  String _getUserAge() {
    final dobString = _userRepository.currentUser.value.dateOfBirth;
    if (dobString.isEmpty) {
      return 'Bilinmiyor';
    }
    try {
      final dob = DateTime.parse(dobString);
      return UserAgeCalculater(dateOfBirth: dob).calculateAge().toString();
    } catch (_) {
      return 'Bilinmiyor';
    }
  }
}
