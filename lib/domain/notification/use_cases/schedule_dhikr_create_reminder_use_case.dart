import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class ScheduleDhikrCreateReminderUseCase {
  ScheduleDhikrCreateReminderUseCase({
    required NotificationRepository notificationRepository,
    required UserRepository userRepository,
  }) : _notificationRepository = notificationRepository,
       _userRepository = userRepository,
       _log = Logger('ScheduleDhikrReminderUseCase');

  final NotificationRepository _notificationRepository;
  final UserRepository _userRepository;
  final Logger _log;

  ValueListenable<User> get currentUser => _userRepository.currentUser;

  /// Schedule a dhikr reminder notification for 3 days( tomorrow, day after tomorrow and day after that) from now for remind the user to create a dhikr
  Future<Result<void>> scheduleReminderForCreatingDhikr() async {
    final user = currentUser.value;
    if (user.uid.isEmpty) {
      _log.warning('No authenticated user for dhikr reminder');
      return Result.error(Exception('Kullanıcı bulunamadı'));
    }
    try {
      // clear all scheduled notifications for dhikr creation reminder
      await _notificationRepository.cancelDhikrCreationReminderNotifications();
      final now = DateTime.now();
      final targetDates = [
        now.add(Duration(days: 1)),
        now.add(Duration(days: 2)),
        now.add(Duration(days: 3)),
      ];
      for (final date in targetDates) {
        final result = await _notificationRepository
            .scheduleDhikrCreationReminderNotification(
              userId: user.uid,
              day: date,
              userName: user.name,
            );
        switch (result) {
          case Ok():
            _log.info('Dhikr reminder scheduled successfully for $date');
          case Error():
            _log.warning(
              'Failed to schedule dhikr reminder for creating dhikr: ${result.asError.error}',
            );
        }
      }
      return Result.ok(null);
    } catch (e) {
      _log.severe('Exception scheduling dhikr reminder: $e');
      return Result.error(
        Exception('Zikir hatırlatma bildirimi planlanamadı: $e'),
      );
    }
  }
}
