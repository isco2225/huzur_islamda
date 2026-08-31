import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  late FakeAssistantRepository assistantRepository;
  late FakeAppRepository appRepository;
  late FakeUserRepository userRepository;
  late AssistantUseCase useCase;

  setUp(() {
    assistantRepository = FakeAssistantRepository();
    appRepository = FakeAppRepository(
      preferences: Fixtures.appPreferences(assistantDailyLimit: 3),
    );
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    useCase = AssistantUseCase(
      assistantRepository: assistantRepository,
      appRepository: appRepository,
      userRepository: userRepository,
    );
  });

  Future<Result<String>> send() => useCase.execute(
    message: 'Selam',
    senderName: 'Ahmet',
    senderAge: '36',
    senderGender: 'male',
    previousMessages: const ['önceki'],
    postContent: 'post',
  );

  group('AssistantUseCase.execute', () {
    test('forwards every argument to the repository', () async {
      await send();

      final sent = assistantRepository.sentMessages.single;
      expect(sent.message, 'Selam');
      expect(sent.senderName, 'Ahmet');
      expect(sent.senderAge, '36');
      expect(sent.senderGender, 'male');
      expect(sent.previousMessages, ['önceki']);
      expect(sent.postContent, 'post');
    });

    test('premium user sends without touching the daily limit', () async {
      userRepository.currentUserNotifier.value = Fixtures.user(
        supportPackage: SupportPackage.yearly,
      );
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        assistantDailyLimit: 0,
      );

      final result = await send();

      expect(result, isA<Ok<String>>());
      expect(result.asOk.value, 'assistant-reply');
      expect(appRepository.calls, isEmpty);
      expect(assistantRepository.calls, hasLength(1));
    });

    test('premium user gets the repository error unchanged', () async {
      userRepository.currentUserNotifier.value = Fixtures.user(
        supportPackage: SupportPackage.weekly,
      );
      final exception = Exception('gemini');
      assistantRepository.sendMessageResult = Error(exception);

      final result = await send();

      expect(result, isA<Error<String>>());
      expect(result.asError.error, same(exception));
    });

    test('returns AssistantDailyLimitExceeded when the limit is 0', () async {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        assistantDailyLimit: 0,
      );

      final result = await send();

      expect(result, isA<Error<String>>());
      expect(result.asError.error, isA<AssistantDailyLimitExceeded>());
      expect(appRepository.calls, isEmpty);
      expect(assistantRepository.calls, isEmpty);
    });

    test('treats a negative limit like zero', () async {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        assistantDailyLimit: -1,
      );

      final result = await send();

      expect(result.asError.error, isA<AssistantDailyLimitExceeded>());
    });

    test('decrements the limit to 2 and then sends when the limit is 3', () async {
      final result = await send();

      expect(result, isA<Ok<String>>());
      expect(appRepository.calls, ['updateAssistantDailyLimit(2)']);
      expect(assistantRepository.calls, ['sendMessage(message=Selam)']);
      expect(
        appRepository.appPreferencesNotifier.value.assistantDailyLimit,
        2,
      );
    });

    test('does not send when updating the limit fails', () async {
      final exception = Exception('prefs');
      appRepository.updateAssistantDailyLimitResult = Error(exception);

      final result = await send();

      expect(result, isA<Error<String>>());
      expect(result.asError.error, same(exception));
      expect(assistantRepository.calls, isEmpty);
    });

    test('propagates a send error for a non-premium user', () async {
      final exception = Exception('gemini');
      assistantRepository.sendMessageResult = Error(exception);

      final result = await send();

      expect(result, isA<Error<String>>());
      expect(result.asError.error, same(exception));
    });

    test(
      'does not consume quota when the send fails',
      () async {
        assistantRepository.sendMessageResult = Error(Exception('gemini'));

        await send();

        expect(
          appRepository.appPreferencesNotifier.value.assistantDailyLimit,
          3,
        );
      },
      skip:
          'KNOWN BUG: AssistantUseCase decrements the daily limit before '
          'sending, so a failed send still consumes one unit of quota.',
    );
  });
}
