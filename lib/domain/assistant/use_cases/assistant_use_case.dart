import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';

class AssistantUseCase {
  AssistantUseCase({
    required this.assistantRepository,
    required this.appRepository,
  }) : _log = Logger('AssistantUseCase');
  final AssistantRepository assistantRepository;
  final AppRepository appRepository;
  final Logger _log;

  /// if daily limit is not 0, decrement the daily limit and send message to assistant and return the response
  Future<Result<String>> execute({
    required String message,
    required String senderName,
    required String senderAge,
    required String senderGender,
    required List<String>? previousMessages,
  }) async {
    final assistantDailyLimit =
        appRepository.appPreferences.value.assistantDailyLimit;
    _log.info('Assistant daily limit: $assistantDailyLimit');
    if (assistantDailyLimit <= 0) {
      _log.severe('no assistant daily limit available');
      return Result.error(Exception('Günlük Asistan hakkınız doldu.'));
    }
    final result = await appRepository.updateAssistantDailyLimit(
      updatedDailyLimit: assistantDailyLimit - 1,
    );
    _log.info('Assistant daily limit decremented: ${assistantDailyLimit - 1}');
    switch (result) {
      case Ok():
        final messageResult = await assistantRepository.sendMessage(
          message: message,
          senderName: senderName,
          senderAge: senderAge,
          senderGender: senderGender,
          previousMessages: previousMessages,
        );
        switch (messageResult) {
          case Ok():
            return Result.ok(messageResult.asOk.value);
          case Error():
            return Result.error(messageResult.asError.error);
        }
      case Error():
        return Result.error(result.asError.error);
    }
  }
}
