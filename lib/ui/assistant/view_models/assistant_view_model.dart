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
    required UserRepository userRepository,
    required AssistantUseCase assistantUseCase,
    required ConnectivityUseCase connectivityUseCase,
  }) : _userRepository = userRepository,
       _assistantUseCase = assistantUseCase,
       _connectivityUseCase = connectivityUseCase {
    // DEFINE COMMANDS
    sendMessage = Command1<void, String>(
      _sendMessage,
      debugLabel: 'sendMessage',
    );
  }
  // logger
  final _log = Logger('AssistantViewModel');
  // repositories and use cases
  final UserRepository _userRepository;
  final AssistantUseCase _assistantUseCase;
  final ConnectivityUseCase _connectivityUseCase;
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
  /// check internet connection and execute assistant use case
  Future<Result<void>> _sendMessage(String userMessage) async {
    final connectivityResult = await _connectivityUseCase.connectionType();
    switch (connectivityResult) {
      case Ok():
        if (connectivityResult.asOk.value == ConnectivityEnum.none) {
          _log.severe('No internet connection');
          return Result.error(ConnectivityNoConnection());
        }
      case Error():
        _log.warning(
          'Failed to check internet connection: ${connectivityResult.asError.error}',
        );
        return Result.error(connectivityResult.asError.error);
    }
    _log.info('Internet connection is available');
    // copy current messages list to previous messages list
    final previousMessages = List<AssistantMessage>.from(messages.value);

    // add new user message to messages list
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
    final result = await _assistantUseCase.execute(
      message: userMessage,
      senderName: user.name.isNotEmpty ? user.name : 'Kullanıcı',
      senderAge: _getUserAge(),
      senderGender: user.gender.isNotEmpty ? user.gender : '',
      previousMessages: previousTexts,
      postContent: null,
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

  /// add assistant reply to messages list
  void _addAssistantReply(String text) {
    final current = List<AssistantMessage>.from(messages.value);
    current.add(
      AssistantMessage(text: text, isUser: false, timeLabel: _nowLabel),
    );
    messages.value = current;
  }

  /// get current time label
  String get _nowLabel {
    final now = DateTime.now();
    String twoDigits(int v) => v.toString().padLeft(2, '0');
    return '${twoDigits(now.hour)}:${twoDigits(now.minute)}';
  }

  /// get user age
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
