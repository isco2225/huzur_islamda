import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class ScheduleDhikrReminderUseCase {
  ScheduleDhikrReminderUseCase({
    required NotificationRepository notificationRepository,
    required UserRepository userRepository,
  }) : _notificationRepository = notificationRepository,
       _userRepository = userRepository,
       _log = Logger('ScheduleDhikrReminderUseCase');

  final NotificationRepository _notificationRepository;
  final UserRepository _userRepository;
  final Logger _log;

  ValueListenable<User> get currentUser => _userRepository.currentUser;

  /// Schedule a dhikr reminder notification for a specific day (default: today) at 22:00
  Future<Result<bool>> scheduleForDay({DateTime? day}) async {
    try {
      final user = currentUser.value;
      if (user.uid.isEmpty) {
        _log.warning('No authenticated user for dhikr reminder');
        return Result.error(const UserMessageException('Kullanıcı bulunamadı'));
      }
      final now = DateTime.now();
      final targetDay = day ?? now;
      final normalizedDay = DateTime(
        targetDay.year,
        targetDay.month,
        targetDay.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      if (normalizedDay.isBefore(today)) {
        _log.info(
          'Skipping dhikr reminder scheduling for past day: $normalizedDay',
        );
        return Result.ok(false);
      }

      final reminderTime = DateTime(
        normalizedDay.year,
        normalizedDay.month,
        normalizedDay.day,
        22,
      );

      if (!reminderTime.isAfter(now)) {
        _log.info(
          'Skipping dhikr reminder for today because 22:00 has already passed. '
          'Now: $now, target: $reminderTime',
        );
        return Result.ok(false);
      }
      // if today's 22:00 dhikr reminder notification is already scheduled, skip scheduling

      final result = await _notificationRepository
          .scheduleDhikrCompletionReminderNotification(
            userId: user.uid,
            day: normalizedDay,
          );

      switch (result) {
        case Ok():
          _log.info('Dhikr reminder scheduled successfully for $reminderTime');
          return Result.ok(true);
        case Error():
          _log.warning(
            'Failed to schedule dhikr reminder: ${result.asError.error}',
          );
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Exception scheduling dhikr reminder: $e');
      return Result.error(
        UserMessageException('Zikir hatırlatma bildirimi planlanamadı', cause: e),
      );
    }
  }
}
