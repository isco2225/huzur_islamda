import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  late FakeNotificationRepository notificationRepository;
  late FakeUserRepository userRepository;
  late ScheduleDhikrCreateReminderUseCase useCase;

  setUp(() {
    notificationRepository = FakeNotificationRepository();
    userRepository = FakeUserRepository(
      currentUser: Fixtures.user(uid: 'uid-7', name: 'Ayşe'),
    );
    useCase = ScheduleDhikrCreateReminderUseCase(
      notificationRepository: notificationRepository,
      userRepository: userRepository,
    );
  });

  group('ScheduleDhikrCreateReminderUseCase.scheduleReminderForCreatingDhikr', () {
    test('returns an error without any calls when uid is empty', () async {
      userRepository.currentUserNotifier.value = User.empty();

      final result = await useCase.scheduleReminderForCreatingDhikr();

      expect(result, isA<Error<void>>());
      expect(result.asError.error.toString(), contains('Kullanıcı bulunamadı'));
      expect(notificationRepository.calls, isEmpty);
    });

    test('cancels existing creation reminders before scheduling', () async {
      await useCase.scheduleReminderForCreatingDhikr();

      expect(
        notificationRepository.calls.first,
        'cancelDhikrCreationReminderNotifications()',
      );
      expect(notificationRepository.calls, hasLength(1 + 3));
    });

    test('schedules exactly three reminders for the next three days', () async {
      final before = DateTime.now();

      final result = await useCase.scheduleReminderForCreatingDhikr();

      final after = DateTime.now();
      expect(result, isA<Ok<void>>());
      final scheduled = notificationRepository.scheduledDhikrCreationReminders;
      expect(scheduled, hasLength(3));
      for (var i = 0; i < 3; i++) {
        final offset = Duration(days: i + 1);
        // The use case reads its own clock, which lies between `before` and
        // `after`; bound the scheduled day accordingly (robust at midnight).
        expect(
          scheduled[i].day.isBefore(before.add(offset)),
          isFalse,
          reason: 'day ${i + 1} too early',
        );
        expect(
          scheduled[i].day.isAfter(after.add(offset)),
          isFalse,
          reason: 'day ${i + 1} too late',
        );
      }
    });

    test('passes the user id and name to every reminder', () async {
      await useCase.scheduleReminderForCreatingDhikr();

      for (final request
          in notificationRepository.scheduledDhikrCreationReminders) {
        expect(request.userId, 'uid-7');
        expect(request.userName, 'Ayşe');
      }
    });

    test('ignores individual scheduling errors and returns Ok', () async {
      var count = 0;
      notificationRepository.onScheduleDhikrCreationReminderNotification =
          (request) async =>
              ++count == 2 ? Error(Exception('second')) : const Ok(null);

      final result = await useCase.scheduleReminderForCreatingDhikr();

      expect(result, isA<Ok<void>>());
      expect(
        notificationRepository.scheduledDhikrCreationReminders,
        hasLength(3),
      );
    });

    test('ignores a failure to cancel previous reminders', () async {
      notificationRepository.cancelDhikrCreationReminderNotificationsResult =
          Error(Exception('cancel'));

      final result = await useCase.scheduleReminderForCreatingDhikr();

      expect(result, isA<Ok<void>>());
      expect(
        notificationRepository.scheduledDhikrCreationReminders,
        hasLength(3),
      );
    });
  });
}
