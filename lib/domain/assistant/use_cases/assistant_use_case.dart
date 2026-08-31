import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

class AssistantUseCase {
  AssistantUseCase({
    required this.assistantRepository,
    required this.appRepository,
    required this.userRepository,
  }) : _log = Logger('AssistantUseCase');
  final AssistantRepository assistantRepository;
  final AppRepository appRepository;
  final UserRepository userRepository;
  final Logger _log;

  /// if daily limit is not 0, decrement the daily limit and send message to assistant and return the response
  Future<Result<String>> execute({
    required String message,
    required String senderName,
    required String senderAge,
    required String senderGender,
    required List<String>? previousMessages,
    required String? postContent,
  }) async {
    final currentUser = userRepository.currentUser.value;
    if (currentUser.isPremium) {
      _log.info('User is premium, skipping assistant daily limit');
      final messageResult = await assistantRepository.sendMessage(
        message: message,
        senderName: senderName,
        senderAge: senderAge,
        senderGender: senderGender,
        previousMessages: previousMessages,
        postContent: postContent,
      );
      switch (messageResult) {
        case Ok():
          return Result.ok(messageResult.asOk.value);
        case Error():
          return Result.error(messageResult.asError.error);
      }
    } else {
      final assistantDailyLimit =
          appRepository.appPreferences.value.assistantDailyLimit;
      _log.info('Assistant daily limit: $assistantDailyLimit');
      if (assistantDailyLimit <= 0) {
        _log.severe('no assistant daily limit available');
        return Result.error(const AssistantDailyLimitExceeded());
      }
      final result = await appRepository.updateAssistantDailyLimit(
        updatedDailyLimit: assistantDailyLimit - 1,
      );
      _log.info(
        'Assistant daily limit decremented: ${assistantDailyLimit - 1}',
      );
      switch (result) {
        case Ok():
          final messageResult = await assistantRepository.sendMessage(
            message: message,
            senderName: senderName,
            senderAge: senderAge,
            senderGender: senderGender,
            previousMessages: previousMessages,
            postContent: postContent,
          );
          switch (messageResult) {
            case Ok():
              return Result.ok(messageResult.asOk.value);
            case Error():
              // The user got no answer, so give the consumed unit back.
              final refundResult = await appRepository
                  .updateAssistantDailyLimit(
                    updatedDailyLimit: assistantDailyLimit,
                  );
              if (refundResult is Error) {
                _log.warning(
                  'Failed to refund assistant daily limit after send error: '
                  '${refundResult.asError.error}',
                );
              }
              return Result.error(messageResult.asError.error);
          }
        case Error():
          return Result.error(result.asError.error);
      }
    }
  }
}
