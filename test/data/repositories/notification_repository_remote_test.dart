import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show PendingNotificationRequest;
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';

import '../../helpers/fakes/fake_services.dart';

/// Mirrors `NotificationRepositoryRemote._generateNotificationId`.
int prayerNotificationId(int base, String dateKey) =>
    base + dateKey.hashCode % 1000;

/// Mirrors `_generateDhikrReminderId` / `_generateDhikrCreationReminderId`.
int dhikrReminderId(int base, String userId, DateTime day) {
  final dateKey =
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
  return base + '$userId-$dateKey'.hashCode.abs() % 1000;
}

/// Copy of the message pool in `_generateDhikrCreationReminderMessage`.
List<({String title, String body})> creationReminderMessages(String userName) {
  return [
    (
      title: 'Zikir Vakti',
      body: 'Allah’ı çokça zikret ki kalbin huzur bulsun, $userName.',
    ),
    (
      title: 'Zikir Hatırlatma',
      body: 'Günün yoğun geçse de birkaç dakikalık zikir tüm ruhunu tazeler.',
    ),
    (title: 'Hey $userName!', body: 'Bugün zikirlerini yapmadın!.'),
    (
      title: 'Kalp Huzuru',
      body:
          '“Kalpler ancak Allah’ı zikretmekle huzur bulur.” Bugün zikrine vakit ayırmayı unutma.',
    ),
    (
      title: 'Kısa Bir Mola',
      body:
          'Yoğunluğa kısa bir ara ver ve dilini tesbih, tahmid ve tekbir ile süsle.',
    ),
    (
      title: 'Gizli Hazine',
      body:
          '“Lâ havle ve lâ kuvvete illâ billâh” zikri bugün sana güç ve teslimiyet versin.',
    ),
    (
      title: 'Akşam Sükûneti',
      body:
          'Günü, kalbini Rabbine çeviren birkaç tesbihle kapatmaya ne dersin?',
    ),
    (
      title: 'Tevekkül Hatırlatması',
      body:
          'Zikir, teslimiyetini tazeler. Bugün Rabbine sığınarak O’nu anmayı ihmal etme.',
    ),
    (
      title: 'Şükür Vakti',
      body:
          'Bugün nimetlerini düşünerek “Elhamdülillah” demeyi çoğalt, $userName.',
    ),
  ];
}

void main() {
  late FakeNotificationService service;
  late NotificationRepositoryRemote repository;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  setUp(() {
    service = FakeNotificationService();
    repository = NotificationRepositoryRemote(notificationService: service);
  });

  group('schedulePrayerTimeNotification', () {
    test('skips past prayer times with Ok(null) and no service call', () async {
      final result = await repository.schedulePrayerTimeNotification(
        prayerName: 'Öğle',
        prayerTime: now.subtract(const Duration(minutes: 1)),
        dateKey: '2026-01-15',
      );

      expect(result, isA<Ok<void>>());
      expect(service.scheduled, isEmpty);
    });

    test(
      'schedules future prayers with "<name> Vakti" / "<name> vakti geldi" '
      'and id = base + dateKey.hashCode % 1000',
      () async {
        final prayerTime = now.add(const Duration(hours: 1));
        const dateKey = '2026-01-15';
        const bases = {
          'İmsak': 1000,
          'Öğle': 2000,
          'İkindi': 3000,
          'Akşam': 4000,
          'Yatsı': 5000,
        };

        for (final entry in bases.entries) {
          final result = await repository.schedulePrayerTimeNotification(
            prayerName: entry.key,
            prayerTime: prayerTime,
            dateKey: dateKey,
          );
          expect(result, isA<Ok<void>>());
        }

        expect(service.scheduled.length, 5);
        for (var i = 0; i < bases.length; i++) {
          final name = bases.keys.elementAt(i);
          final call = service.scheduled[i];
          expect(call.id, prayerNotificationId(bases[name]!, dateKey));
          expect(call.title, '$name Vakti');
          expect(call.body, '$name vakti geldi');
          expect(call.scheduledDate, prayerTime);
        }
      },
    );

    test('uses a base of 0 for an unknown prayer name', () async {
      // Latent issue: such an id falls outside the 1000..9999 window that
      // cancelAllPrayerNotifications cancels. The prayer use case only ever
      // schedules the five named prayers, so it is not reachable today.
      final result = await repository.schedulePrayerTimeNotification(
        prayerName: 'Güneş',
        prayerTime: now.add(const Duration(hours: 1)),
        dateKey: '2026-01-15',
      );

      expect(result, isA<Ok<void>>());
      expect(service.scheduled.single.id, prayerNotificationId(0, '2026-01-15'));
      expect(service.scheduled.single.id, inInclusiveRange(0, 999));
    });

    test(
      'keeps prayer ids inside [base, base + 999] for every date key '
      '(the id generator does not abs() the hashCode)',
      () async {
        // Brute-force search for a date key with a negative hashCode. On the
        // Dart VM String.hashCode is a 30-bit non-negative value, so none is
        // expected; if a platform ever produced one, the un-abs()'d modulo
        // would push the id below the base and outside the cancel window.
        final keys = <String>[];
        for (var year = 1990; year <= 2100; year++) {
          for (var month = 1; month <= 12; month++) {
            for (var day = 1; day <= 28; day += 9) {
              keys.add(
                '$year-${month.toString().padLeft(2, '0')}-'
                '${day.toString().padLeft(2, '0')}',
              );
            }
          }
        }
        final negativeKeys = keys.where((k) => k.hashCode < 0).toList();
        expect(
          negativeKeys,
          isEmpty,
          reason: 'String.hashCode is non-negative on the Dart VM',
        );

        final prayerTime = now.add(const Duration(hours: 1));
        for (final key in keys.take(400)) {
          await repository.schedulePrayerTimeNotification(
            prayerName: 'Akşam',
            prayerTime: prayerTime,
            dateKey: key,
          );
        }

        for (final call in service.scheduled) {
          expect(call.id, inInclusiveRange(4000, 4999));
        }
      },
    );

    test('returns the service error unchanged', () async {
      final failure = Exception('Bildirim planlanamadı');
      service.scheduleNotificationResult = Result.error(failure);

      final result = await repository.schedulePrayerTimeNotification(
        prayerName: 'Öğle',
        prayerTime: now.add(const Duration(hours: 1)),
        dateKey: '2026-01-15',
      );

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
    });
  });

  group('scheduleDhikrCompletionReminderNotification', () {
    test('skips past days with Ok(null) and no service call', () async {
      final result = await repository
          .scheduleDhikrCompletionReminderNotification(
            userId: 'uid-1',
            day: yesterday,
          );

      expect(result, isA<Ok<void>>());
      expect(service.scheduled, isEmpty);
    });

    test('schedules tomorrow at exactly 22:00 with the derived id', () async {
      final result = await repository
          .scheduleDhikrCompletionReminderNotification(
            userId: 'uid-1',
            day: tomorrow.add(const Duration(hours: 13, minutes: 45)),
          );

      expect(result, isA<Ok<void>>());
      final call = service.scheduled.single;
      expect(
        call.scheduledDate,
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 22),
      );
      expect(call.id, dhikrReminderId(11000, 'uid-1', tomorrow));
      expect(call.id, inInclusiveRange(11000, 11999));
      expect(call.title, 'Zikir Hatırlatma');
      expect(call.body, 'Bugünkü zikirlerini tamamlamayı unutma.');
    });

    test('for today, schedules only if 22:00 has not passed yet', () async {
      final target = DateTime(today.year, today.month, today.day, 22);
      final expectScheduled = target.isAfter(DateTime.now());

      final result = await repository
          .scheduleDhikrCompletionReminderNotification(
            userId: 'uid-1',
            day: today,
          );

      expect(result, isA<Ok<void>>());
      if (expectScheduled) {
        expect(service.scheduled.single.scheduledDate, target);
      } else {
        expect(service.scheduled, isEmpty);
      }
    });

    test('returns the service error unchanged', () async {
      final failure = Exception('x');
      service.scheduleNotificationResult = Result.error(failure);

      final result = await repository
          .scheduleDhikrCompletionReminderNotification(
            userId: 'uid-1',
            day: tomorrow,
          );

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
    });
  });

  group('scheduleDhikrCreationReminderNotification', () {
    test('skips past days with Ok(null) and no service call', () async {
      final result = await repository.scheduleDhikrCreationReminderNotification(
        userId: 'uid-1',
        day: yesterday,
        userName: 'Ahmet',
      );

      expect(result, isA<Ok<void>>());
      expect(service.scheduled, isEmpty);
    });

    test(
      'schedules tomorrow at 19:00 with a 12000-based id and a message from '
      'the pool (two of which interpolate the user name)',
      () async {
        final expected = creationReminderMessages('Ahmet');

        // The message is picked at random; sample several times.
        for (var i = 0; i < 25; i++) {
          final result = await repository
              .scheduleDhikrCreationReminderNotification(
                userId: 'uid-1',
                day: tomorrow,
                userName: 'Ahmet',
              );
          expect(result, isA<Ok<void>>());
        }

        expect(service.scheduled.length, 25);
        for (final call in service.scheduled) {
          expect(
            call.scheduledDate,
            DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 19),
          );
          expect(call.id, dhikrReminderId(12000, 'uid-1', tomorrow));
          expect(call.id, inInclusiveRange(12000, 12999));
          expect(
            expected.any((m) => m.title == call.title && m.body == call.body),
            isTrue,
            reason: 'unexpected message: $call',
          );
        }
      },
    );

    test('for today, schedules only if 19:00 has not passed yet', () async {
      final target = DateTime(today.year, today.month, today.day, 19);
      final expectScheduled = target.isAfter(DateTime.now());

      final result = await repository.scheduleDhikrCreationReminderNotification(
        userId: 'uid-1',
        day: today,
        userName: 'Ahmet',
      );

      expect(result, isA<Ok<void>>());
      if (expectScheduled) {
        expect(service.scheduled.single.scheduledDate, target);
      } else {
        expect(service.scheduled, isEmpty);
      }
    });

    test('returns the service error unchanged', () async {
      final failure = Exception('x');
      service.scheduleNotificationResult = Result.error(failure);

      final result = await repository.scheduleDhikrCreationReminderNotification(
        userId: 'uid-1',
        day: tomorrow,
        userName: 'Ahmet',
      );

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
    });
  });

  group('cancelAllPrayerNotifications', () {
    test('cancels only pending ids inside 1000..9999', () async {
      service.pending = const [
        PendingNotificationRequest(500, 't', 'b', null),
        PendingNotificationRequest(999, 't', 'b', null),
        PendingNotificationRequest(1000, 't', 'b', null),
        PendingNotificationRequest(4321, 't', 'b', null),
        PendingNotificationRequest(9999, 't', 'b', null),
        PendingNotificationRequest(10000, 't', 'b', null),
        PendingNotificationRequest(11234, 't', 'b', null),
        PendingNotificationRequest(12345, 't', 'b', null),
      ];

      final result = await repository.cancelAllPrayerNotifications();

      expect(result, isA<Ok<void>>());
      expect(service.cancelCalls, [
        [1000, 4321, 9999],
      ]);
    });

    test('returns Ok(null) without cancelling when none are in range', () async {
      service.pending = const [
        PendingNotificationRequest(11234, 't', 'b', null),
        PendingNotificationRequest(12345, 't', 'b', null),
      ];

      final result = await repository.cancelAllPrayerNotifications();

      expect(result, isA<Ok<void>>());
      expect(service.cancelCalls, isEmpty);
    });

    test('returns Ok(null) when nothing is pending', () async {
      final result = await repository.cancelAllPrayerNotifications();

      expect(result, isA<Ok<void>>());
      expect(service.cancelCalls, isEmpty);
    });

    test('propagates a failure to read pending notifications', () async {
      final failure = Exception('x');
      service.getPendingNotificationsError = failure;

      final result = await repository.cancelAllPrayerNotifications();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
      expect(service.cancelCalls, isEmpty);
    });

    test('propagates a cancel failure', () async {
      service.pending = const [PendingNotificationRequest(2000, 't', 'b', null)];
      final failure = Exception('x');
      service.cancelNotificationsResult = Result.error(failure);

      final result = await repository.cancelAllPrayerNotifications();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
    });
  });

  group('cancelTodayDhikrNotifications', () {
    test('cancels today\'s completion reminder id', () async {
      final result = await repository.cancelTodayDhikrNotifications(
        userId: 'uid-1',
      );

      expect(result, isA<Ok<void>>());
      expect(service.cancelCalls, [
        [dhikrReminderId(11000, 'uid-1', today)],
      ]);
      // The pending list is read even though it is not used for filtering.
      expect(service.getPendingNotificationsCount, 1);
    });

    test('propagates a failure to read pending notifications', () async {
      service.getPendingNotificationsError = Exception('x');

      final result = await repository.cancelTodayDhikrNotifications(
        userId: 'uid-1',
      );

      expect(result, isA<Error<void>>());
      expect(service.cancelCalls, isEmpty);
    });
  });

  group('cancelTodayDhikrCreationReminderNotification', () {
    test('cancels today\'s creation reminder id', () async {
      final result = await repository
          .cancelTodayDhikrCreationReminderNotification(userId: 'uid-1');

      expect(result, isA<Ok<void>>());
      expect(service.cancelCalls, [
        [dhikrReminderId(12000, 'uid-1', today)],
      ]);
      expect(service.getPendingNotificationsCount, 0);
    });

    test('propagates a cancel failure', () async {
      final failure = Exception('x');
      service.cancelNotificationsResult = Result.error(failure);

      final result = await repository
          .cancelTodayDhikrCreationReminderNotification(userId: 'uid-1');

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(failure));
    });
  });

  test('cancelDhikrCreationReminderNotifications delegates to the service', () async {
    final result = await repository.cancelDhikrCreationReminderNotifications();

    expect(result, isA<Ok<void>>());
    expect(service.cancelDhikrCreationReminderNotificationsCount, 1);
  });

  test('cancelAllNotifications delegates to the service', () async {
    final failure = Exception('x');
    service.cancelAllNotificationsResult = Result.error(failure);

    final result = await repository.cancelAllNotifications();

    expect(result, isA<Error<void>>());
    expect(result.asError.error, same(failure));
    expect(service.cancelAllNotificationsCount, 1);
  });

  test('cancelDhikrReminderNotification is not implemented', () {
    expect(
      () => repository.cancelDhikrReminderNotification(
        userId: 'uid-1',
        day: tomorrow,
      ),
      throwsUnimplementedError,
    );
  });
}
