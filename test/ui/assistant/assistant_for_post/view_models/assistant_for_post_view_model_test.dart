import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  final timeLabelPattern = RegExp(r'^\d\d:\d\d$');
  final post = Fixtures.post(title: 'Sabır', content: 'Sabır imanın yarısıdır.');

  late FakeUserRepository userRepository;
  late FakeAssistantRepository assistantRepository;
  late FakeAppRepository appRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late AssistantForPostViewModel viewModel;

  setUp(() {
    userRepository = FakeUserRepository(currentUser: Fixtures.user(dateOfBirth: '1990-01-01'));
    assistantRepository = FakeAssistantRepository();
    appRepository = FakeAppRepository(preferences: Fixtures.appPreferences(assistantDailyLimit: 5));
    connectivityUseCase = FakeConnectivityUseCase();
    viewModel = AssistantForPostViewModel(
      post: post,
      userRepository: userRepository,
      assistantUseCase: AssistantUseCase(
        assistantRepository: assistantRepository,
        appRepository: appRepository,
        userRepository: userRepository,
      ),
      connectivityUseCase: connectivityUseCase,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('seeds the conversation with a prompt built from the post title', () {
    expect(viewModel.post, same(post));
    final seed = viewModel.messages.value.single;
    expect(seed.text, '**Sabır**, konusu hakkında ne sormak istersin?');
    expect(seed.isUser, isFalse);
    expect(seed.timeLabel, matches(timeLabelPattern));
  });

  group('sendMessage', () {
    test('no connection: ConnectivityNoConnection and the seed stays alone', () async {
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.sendMessage.execute('Sabır nedir?');

      expect(viewModel.sendMessage.result.value!.asError.error, isA<ConnectivityNoConnection>());
      expect(viewModel.messages.value, hasLength(1));
      expect(assistantRepository.calls, isEmpty);
    });

    test('forwards the post content and the seed as history', () async {
      assistantRepository.sendMessageResult = const Ok('Sabır güzeldir.');

      await viewModel.sendMessage.execute('Sabır nedir?');

      final sent = assistantRepository.sentMessages.single;
      expect(sent.postContent, 'Sabır imanın yarısıdır.');
      expect(sent.message, 'Sabır nedir?');
      expect(sent.senderName, 'Ahmet');
      expect(sent.previousMessages, ['**Sabır**, konusu hakkında ne sormak istersin?']);

      final messages = viewModel.messages.value;
      expect(messages.map((m) => m.text).toList(), [
        '**Sabır**, konusu hakkında ne sormak istersin?',
        'Sabır nedir?',
        'Sabır güzeldir.',
      ]);
      expect(messages.map((m) => m.isUser).toList(), [false, true, false]);
      expect(viewModel.sendMessage.completed.value, isTrue);
    });

    test('sends only the last two previous messages as history', () async {
      assistantRepository.sendMessageResult = const Ok('cevap');

      await viewModel.sendMessage.execute('soru-1');
      await viewModel.sendMessage.execute('soru-2');

      expect(assistantRepository.sentMessages.last.previousMessages, ['soru-1', 'cevap']);
    });

    test("falls back to 'Kullanıcı' and 'Bilinmiyor' for an anonymous user", () async {
      userRepository.currentUserNotifier.value = Fixtures.user(name: '', dateOfBirth: '');

      await viewModel.sendMessage.execute('soru');

      final sent = assistantRepository.sentMessages.single;
      expect(sent.senderName, 'Kullanıcı');
      expect(sent.senderAge, 'Bilinmiyor');
    });

    test('limit 0 fails with AssistantDailyLimitExceeded', () async {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(assistantDailyLimit: 0);

      await viewModel.sendMessage.execute('soru');

      expect(viewModel.sendMessage.result.value!.asError.error, isA<AssistantDailyLimitExceeded>());
      expect(assistantRepository.calls, isEmpty);
    });

    test('propagates an assistant repository error', () async {
      final exception = Exception('gemini');
      assistantRepository.sendMessageResult = Error<String>(exception);

      await viewModel.sendMessage.execute('soru');

      expect(viewModel.sendMessage.error.value, isTrue);
      expect(viewModel.sendMessage.result.value!.asError.error, same(exception));
      expect(viewModel.messages.value, hasLength(2));
    });
  });
}
