import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  final timeLabelPattern = RegExp(r'^\d\d:\d\d$');

  late FakeUserRepository userRepository;
  late FakeAssistantRepository assistantRepository;
  late FakeAppRepository appRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late AssistantViewModel viewModel;

  AssistantViewModel build() {
    return AssistantViewModel(
      userRepository: userRepository,
      assistantUseCase: AssistantUseCase(
        assistantRepository: assistantRepository,
        appRepository: appRepository,
        userRepository: userRepository,
      ),
      connectivityUseCase: connectivityUseCase,
      appRepository: appRepository,
    );
  }

  setUp(() {
    // ISO date so the age can be derived; the fixture's dd/MM/yyyy would not
    // parse and would yield 'Bilinmiyor'.
    userRepository = FakeUserRepository(
      currentUser: Fixtures.user(dateOfBirth: '1990-01-01'),
    );
    assistantRepository = FakeAssistantRepository();
    appRepository = FakeAppRepository(
      preferences: Fixtures.appPreferences(assistantDailyLimit: 5),
    );
    connectivityUseCase = FakeConnectivityUseCase();
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('initial state', () {
    test('starts with no messages and the daily limit from preferences', () {
      expect(viewModel.messages.value, isEmpty);
      expect(viewModel.dailyLimit.value, 5);
      expect(viewModel.user, same(userRepository.currentUserNotifier));
    });

    test('dailyLimit mirrors later preference changes', () {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        assistantDailyLimit: 2,
      );

      expect(viewModel.dailyLimit.value, 2);
    });
  });

  group('sendMessage connectivity', () {
    test('no connection: ConnectivityNoConnection and no message appended', () async {
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.sendMessage.execute('Selam');

      expect(viewModel.sendMessage.error.value, isTrue);
      expect(viewModel.sendMessage.result.value!.asError.error, isA<ConnectivityNoConnection>());
      expect(viewModel.messages.value, isEmpty);
      expect(assistantRepository.calls, isEmpty);
    });

    test('connectivity check error is propagated as-is', () async {
      final exception = Exception('plugin');
      connectivityUseCase.connectionTypeResult = Error<ConnectivityEnum>(exception);

      await viewModel.sendMessage.execute('Selam');

      expect(viewModel.sendMessage.result.value!.asError.error, same(exception));
      expect(viewModel.messages.value, isEmpty);
    });
  });

  group('sendMessage success (real AssistantUseCase)', () {
    test('appends the user message then the assistant reply with HH:mm labels', () async {
      assistantRepository.sendMessageResult = const Ok('Aleyküm selam');

      await viewModel.sendMessage.execute('Selam');

      expect(viewModel.sendMessage.completed.value, isTrue);
      final messages = viewModel.messages.value;
      expect(messages, hasLength(2));
      expect(messages[0].text, 'Selam');
      expect(messages[0].isUser, isTrue);
      expect(messages[0].timeLabel, matches(timeLabelPattern));
      expect(messages[1].text, 'Aleyküm selam');
      expect(messages[1].isUser, isFalse);
      expect(messages[1].timeLabel, matches(timeLabelPattern));
    });

    test('forwards sender name, computed age, gender and null postContent', () async {
      await viewModel.sendMessage.execute('Selam');

      final sent = assistantRepository.sentMessages.single;
      expect(sent.message, 'Selam');
      expect(sent.senderName, 'Ahmet');
      expect(
        sent.senderAge,
        UserAgeCalculater(dateOfBirth: DateTime(1990, 1, 1)).calculateAge().toString(),
      );
      expect(sent.senderGender, 'male');
      expect(sent.previousMessages, isEmpty);
      expect(sent.postContent, isNull);
    });

    test("falls back to 'Kullanıcı' and 'Bilinmiyor' for a nameless user without a dob", () async {
      userRepository.currentUserNotifier.value = Fixtures.user(name: '', dateOfBirth: '', gender: '');

      await viewModel.sendMessage.execute('Selam');

      final sent = assistantRepository.sentMessages.single;
      expect(sent.senderName, 'Kullanıcı');
      expect(sent.senderAge, 'Bilinmiyor');
      expect(sent.senderGender, '');
    });

    test("reports 'Bilinmiyor' when the date of birth cannot be parsed", () async {
      userRepository.currentUserNotifier.value = Fixtures.user(dateOfBirth: '01/01/1990');

      await viewModel.sendMessage.execute('Selam');

      expect(assistantRepository.sentMessages.single.senderAge, 'Bilinmiyor');
    });

    test('sends only the last two previous messages as history', () async {
      assistantRepository.sendMessageResult = const Ok('cevap');

      await viewModel.sendMessage.execute('soru-1');
      await viewModel.sendMessage.execute('soru-2');
      await viewModel.sendMessage.execute('soru-3');

      expect(viewModel.messages.value, hasLength(6));
      final history = assistantRepository.sentMessages.map((m) => m.previousMessages).toList();
      expect(history[0], isEmpty);
      expect(history[1], ['soru-1', 'cevap']);
      expect(history[2], ['soru-2', 'cevap']);
    });

    test('decrements the daily limit for a non-premium user', () async {
      await viewModel.sendMessage.execute('Selam');

      expect(appRepository.calls, ['updateAssistantDailyLimit(4)']);
      expect(viewModel.dailyLimit.value, 4);
    });

    test('does not touch the daily limit for a premium user', () async {
      userRepository.currentUserNotifier.value = Fixtures.user(
        supportPackage: SupportPackage.yearly,
      );

      await viewModel.sendMessage.execute('Selam');

      expect(appRepository.calls, isEmpty);
      expect(viewModel.dailyLimit.value, 5);
      expect(viewModel.messages.value, hasLength(2));
    });
  });

  group('sendMessage failures', () {
    // The user's message is appended before the use case runs, so it stays
    // in the list even though no reply arrives.
    test('limit 0 fails with AssistantDailyLimitExceeded without a repository call', () async {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(assistantDailyLimit: 0);

      await viewModel.sendMessage.execute('Selam');

      expect(viewModel.sendMessage.error.value, isTrue);
      expect(
        viewModel.sendMessage.result.value!.asError.error,
        isA<AssistantDailyLimitExceeded>(),
      );
      expect(assistantRepository.calls, isEmpty);
      expect(viewModel.messages.value.map((m) => m.text), ['Selam']);
    });

    test('propagates an assistant repository error and appends no reply', () async {
      final exception = Exception('gemini');
      assistantRepository.sendMessageResult = Error<String>(exception);

      await viewModel.sendMessage.execute('Selam');

      expect(viewModel.sendMessage.error.value, isTrue);
      expect(viewModel.sendMessage.result.value!.asError.error, same(exception));
      expect(viewModel.messages.value, hasLength(1));
    });
  });

  test('dispose stops mirroring preference changes without throwing', () {
    viewModel.dispose();

    expect(
      () => appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        assistantDailyLimit: 1,
      ),
      returnsNormally,
    );
    viewModel = build();
  });
}
