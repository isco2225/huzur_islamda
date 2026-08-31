import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  late FakeNotificationRepository notificationRepository;
  late FakeUserRepository userRepository;
  late ScheduleDhikrReminderUseCase useCase;

  setUp(() {
    notificationRepository = FakeNotificationRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    useCase = ScheduleDhikrReminderUseCase(
      notificationRepository: notificationRepository,
      userRepository: userRepository,
    );
  });

  group('ScheduleDhikrReminderUseCase.scheduleForDay', () {
    test('returns an error without scheduling when uid is empty', () async {
      userRepository.currentUserNotifier.value = User.empty();

      final result = await useCase.scheduleForDay();

      expect(result, isA<Error<bool>>());
      expect(result.asError.error.toString(), contains('Kullanıcı bulunamadı'));
      expect(notificationRepository.calls, isEmpty);
    });

    test('returns Ok(false) without scheduling for yesterday', () async {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1, 12);

      final result = await useCase.scheduleForDay(day: yesterday);

      expect(result, isA<Ok<bool>>());
      expect(result.asOk.value, isFalse);
      expect(notificationRepository.calls, isEmpty);
    });

    test('schedules tomorrow with the day normalized to midnight', () async {
      final now = DateTime.now();
      final tomorrowNoon = DateTime(now.year, now.month, now.day + 1, 12, 34);
      final expectedDay = DateTime(now.year, now.month, now.day + 1);

      final result = await useCase.scheduleForDay(day: tomorrowNoon);

      expect(result, isA<Ok<bool>>());
      expect(result.asOk.value, isTrue);
      final request = notificationRepository.scheduledDhikrReminders.single;
      expect(request.userId, 'uid-1');
      expect(request.day, expectedDay);
      expect(request.day.hour, 0);
      expect(request.day.minute, 0);
    });

    test('schedules for today only when 22:00 has not passed yet', () async {
      // Time-of-day sensitive: the expected outcome is derived from the
      // current clock so the test is deterministic at any hour.
      final now = DateTime.now();
      final reminderTime = DateTime(now.year, now.month, now.day, 22);
      final expectScheduled = reminderTime.isAfter(now);

      final result = await useCase.scheduleForDay();

      expect(result, isA<Ok<bool>>());
      expect(result.asOk.value, expectScheduled);
      expect(
        notificationRepository.scheduledDhikrReminders,
        hasLength(expectScheduled ? 1 : 0),
      );
    });

    test('propagates a repository error', () async {
      final now = DateTime.now();
      final exception = Exception('schedule');
      notificationRepository.scheduleDhikrCompletionReminderNotificationResult =
          Error(exception);

      final result = await useCase.scheduleForDay(
        day: DateTime(now.year, now.month, now.day + 1),
      );

      expect(result, isA<Error<bool>>());
      expect(result.asError.error, same(exception));
    });
  });
}
