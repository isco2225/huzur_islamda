import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../view_models/view_models.dart';

/// Gönderi bağlamında asistan sohbeti için ViewModel. [Post] her zaman vardır.
class AssistantForPostViewModel {
  AssistantForPostViewModel({
    required Post post,
    required UserRepository userRepository,
    required AssistantUseCase assistantUseCase,
    required ConnectivityUseCase connectivityUseCase,
  }) : _post = post,
       _userRepository = userRepository,
       _assistantUseCase = assistantUseCase,
       _connectivityUseCase = connectivityUseCase {
    sendMessage = Command1<void, String>(
      _sendMessage,
      debugLabel: 'sendMessage',
    );
    messages.value = [
      AssistantMessage(
        text: '**${post.title}**, konusu hakkında ne sormak istersin?',
        isUser: false,
        timeLabel: _nowLabel,
      ),
    ];
  }

  final Logger _log = Logger('AssistantForPostViewModel');
  final Post _post;
  final UserRepository _userRepository;
  final AssistantUseCase _assistantUseCase;
  final ConnectivityUseCase _connectivityUseCase;

  Post get post => _post;

  final ValueNotifier<List<AssistantMessage>> messages =
      ValueNotifier<List<AssistantMessage>>([]);
  late final Command1<void, String> sendMessage;

  void dispose() {
    messages.dispose();
    sendMessage.dispose();
    _log.fine('Disposed');
  }

  Future<Result<void>> _sendMessage(String userMessage) async {
    final connectivityResult = await _connectivityUseCase.connectionType();
    switch (connectivityResult) {
      case Ok():
        if (connectivityResult.asOk.value == ConnectivityEnum.none) {
          _log.severe('No internet connection');
          return Result.error(const ConnectivityNoConnection());
        }
      case Error():
        _log.warning(
          'Failed to check internet connection: ${connectivityResult.asError.error}',
        );
        return Result.error(connectivityResult.asError.error);
    }

    final previousMessages = List<AssistantMessage>.from(messages.value);
    final current = List<AssistantMessage>.from(previousMessages);
    current.add(
      AssistantMessage(text: userMessage, isUser: true, timeLabel: _nowLabel),
    );
    messages.value = current;

    final user = _userRepository.currentUser.value;
    final limitedHistory = previousMessages.length <= 2
        ? previousMessages
        : previousMessages.sublist(previousMessages.length - 2);
    final previousTexts = limitedHistory.map((m) => m.text).toList();

    final result = await _assistantUseCase.execute(
      message: userMessage,
      senderName: user.name.isNotEmpty ? user.name : 'Kullanıcı',
      senderAge: _getUserAge(),
      senderGender: user.gender.isNotEmpty ? user.gender : '',
      previousMessages: previousTexts,
      postContent: _post.content,
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
    if (dobString.isEmpty) return 'Bilinmiyor';
    try {
      final dob = DateTime.parse(dobString);
      return UserAgeCalculater(dateOfBirth: dob).calculateAge().toString();
    } catch (_) {
      return 'Bilinmiyor';
    }
  }
}
