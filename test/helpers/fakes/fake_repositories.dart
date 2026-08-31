import 'package:flutter/foundation.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

/// Hand-written, configurable fakes for every abstract repository.
///
/// Each fake:
/// - exposes its listenables as public [ValueNotifier]s so tests can seed them,
/// - records every call in [calls] as `'method(arg=value, ...)'`,
/// - returns an `Ok` result by default; individual results can be overridden
///   through the `xxxResult` fields (or `onXxx` handlers where per-call
///   behaviour matters).

// ---------------------------------------------------------------------------
// Connectivity
// ---------------------------------------------------------------------------

/// Overrides [ConnectivityUseCase.connectionType] with a settable value.
///
/// The base constructor builds a `Connectivity()` instance from
/// connectivity_plus; that constructor is channel-free, so subclassing is safe
/// under `flutter test`.
class FakeConnectivityUseCase extends ConnectivityUseCase {
  FakeConnectivityUseCase({this.type = ConnectivityEnum.wifi});

  ConnectivityEnum type;

  /// When non-null, returned instead of `Ok(type)`.
  Result<ConnectivityEnum>? connectionTypeResult;

  final List<String> calls = [];

  @override
  Future<Result<ConnectivityEnum>> connectionType() async {
    calls.add('connectionType()');
    return connectionTypeResult ?? Result.ok(type);
  }
}

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({Auth? auth, bool isSignedIn = false})
    : authNotifier = ValueNotifier<Auth>(auth ?? Auth.empty()),
      isSignedInNotifier = ValueNotifier<bool>(isSignedIn);

  final ValueNotifier<Auth> authNotifier;
  final ValueNotifier<bool> isSignedInNotifier;
  final List<String> calls = [];

  Result<dynamic>? signInResult;
  Result<dynamic>? signInWithGoogleResult;
  Result<dynamic>? signInWithAppleResult;
  Result<dynamic>? requestSignUpResult;
  Result<void>? sendPasswordResetEmailResult;
  Result<void>? sendEmailVerificationResult;
  Result<bool>? checkEmailVerificationResult;
  Result<dynamic>? signOutResult;
  Result<dynamic>? deleteAccountResult;
  Result<void>? updatePasswordResult;
  Result<dynamic>? reauthenticateResult;

  /// Per-call hook for [checkEmailVerification]; wins over the result field.
  Future<Result<bool>> Function()? onCheckEmailVerification;

  @override
  ValueListenable<Auth> get auth => authNotifier;

  @override
  ValueListenable<bool> get isSignedIn => isSignedInNotifier;

  @override
  Future<Result<dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('signIn(email=$email)');
    return signInResult ?? const Ok(null);
  }

  @override
  Future<Result<dynamic>> signInWithGoogle() async {
    calls.add('signInWithGoogle()');
    return signInWithGoogleResult ?? const Ok(null);
  }

  @override
  Future<Result<dynamic>> signInWithApple() async {
    calls.add('signInWithApple()');
    return signInWithAppleResult ?? const Ok(null);
  }

  @override
  Future<Result<dynamic>> requestSignUp({
    required String email,
    required String password,
  }) async {
    calls.add('requestSignUp(email=$email)');
    return requestSignUpResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    calls.add('sendPasswordResetEmail(email=$email)');
    return sendPasswordResetEmailResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    calls.add('sendEmailVerification()');
    return sendEmailVerificationResult ?? const Ok(null);
  }

  @override
  Future<Result<bool>> checkEmailVerification() async {
    calls.add('checkEmailVerification()');
    if (onCheckEmailVerification != null) {
      return onCheckEmailVerification!();
    }
    return checkEmailVerificationResult ?? const Ok(true);
  }

  @override
  Future<Result<dynamic>> signOut() async {
    calls.add('signOut()');
    return signOutResult ?? const Ok(null);
  }

  @override
  Future<Result<dynamic>> deleteAccount() async {
    calls.add('deleteAccount()');
    return deleteAccountResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    calls.add('updatePassword()');
    return updatePasswordResult ?? const Ok(null);
  }

  @override
  Future<Result<dynamic>> reauthenticate() async {
    calls.add('reauthenticate()');
    return reauthenticateResult ?? const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// User
// ---------------------------------------------------------------------------

class FakeUserRepository implements UserRepository {
  FakeUserRepository({User? currentUser})
    : currentUserNotifier = ValueNotifier<User>(currentUser ?? User.empty());

  final ValueNotifier<User> currentUserNotifier;
  final List<String> calls = [];

  Result<User>? createUserResult;
  Result<void>? updateEmailVerificationStatusResult;
  Result<void>? updateUserResult;
  Result<List<String>?>? getFavoritedPostIdsResult;
  Result<bool>? fetchAuthenticatedUserResult;
  Result<void>? deleteAuthenticatedUserResult;
  Result<bool>? initUserResult;
  Result<void>? updateUserLocationResult;
  Result<void>? updateUserPremiumResult;

  /// Optional hook invoked by [createUser]; wins over [createUserResult].
  Future<Result<User>> Function({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String gender,
  })?
  onCreateUser;

  @override
  ValueListenable<User> get currentUser => currentUserNotifier;

  @override
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String gender,
  }) async {
    calls.add(
      'createUser(uid=$uid, email=$email, name=$name, surname=$surname, '
      'dateOfBirth=$dateOfBirth, gender=$gender)',
    );
    if (onCreateUser != null) {
      return onCreateUser!(
        uid: uid,
        email: email,
        name: name,
        surname: surname,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
    }
    return createUserResult ??
        Ok(
          User(
            uid: uid,
            email: email,
            name: name,
            surname: surname,
            dateOfBirth: dateOfBirth,
            gender: gender,
            emailVerified: false,
            createdAt: null,
            updatedAt: null,
            isRegistered: true,
            country: '',
            city: '',
            districtId: '',
          ),
        );
  }

  @override
  Future<Result<void>> updateEmailVerificationStatus({
    required String uid,
    required bool emailVerified,
  }) async {
    calls.add(
      'updateEmailVerificationStatus(uid=$uid, emailVerified=$emailVerified)',
    );
    return updateEmailVerificationStatusResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> updateUser({
    required String uid,
    String? name,
    String? surname,
    String? dateOfBirth,
    String? gender,
  }) async {
    calls.add('updateUser(uid=$uid)');
    return updateUserResult ?? const Ok(null);
  }

  @override
  Future<Result<List<String>?>> getFavoritedPostIds({
    required String uid,
  }) async {
    calls.add('getFavoritedPostIds(uid=$uid)');
    return getFavoritedPostIdsResult ?? const Ok(<String>[]);
  }

  @override
  Future<Result<bool>> fetchAuthenticatedUser({required String uid}) async {
    calls.add('fetchAuthenticatedUser(uid=$uid)');
    return fetchAuthenticatedUserResult ?? const Ok(true);
  }

  @override
  Future<Result<void>> deleteAuthenticatedUser({required String uid}) async {
    calls.add('deleteAuthenticatedUser(uid=$uid)');
    return deleteAuthenticatedUserResult ?? const Ok(null);
  }

  @override
  void wipeUser() {
    calls.add('wipeUser()');
    currentUserNotifier.value = User.empty();
  }

  @override
  Future<Result<bool>> initUser({required String uid}) async {
    calls.add('initUser(uid=$uid)');
    return initUserResult ?? const Ok(true);
  }

  @override
  Future<Result<void>> updateUserLocation({
    required String uid,
    required String country,
    required String city,
    required String districtId,
  }) async {
    calls.add(
      'updateUserLocation(uid=$uid, country=$country, city=$city, '
      'districtId=$districtId)',
    );
    return updateUserLocationResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> updateUserPremium({
    required String uid,
    required DateTime lastPremiumAt,
    required SupportPackage supportPackage,
  }) async {
    calls.add(
      'updateUserPremium(uid=$uid, supportPackage=${supportPackage.value})',
    );
    return updateUserPremiumResult ?? const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// Dhikr
// ---------------------------------------------------------------------------

class FakeDhikrRepository implements DhikrRepository {
  FakeDhikrRepository({List<Dhikr>? dhikrs})
    : dhikrsLocallyNotifier = ValueNotifier<List<Dhikr>>(dhikrs ?? const []);

  final ValueNotifier<List<Dhikr>> dhikrsLocallyNotifier;
  final List<String> calls = [];

  Result<void>? loadAllDhikrsLocallyResult;
  Result<void>? saveDhikrLocallyResult;
  Result<Dhikr?>? getDhikrLocallyResult;
  Result<List<Dhikr>?>? getAllDhikrsByDateLocallyResult;
  Result<void>? deleteDhikrLocallyResult;
  Result<int>? getDhikrsCountLocallyResult;
  Result<void>? clearAllDhikrsLocallyResult;
  Result<void>? updateDhikrLocallyResult;
  Result<void>? createGroupDhikrsResult;
  Result<List<Dhikr>>? getDhikrsByGroupIdResult;
  Result<void>? syncDhikrsToLocallyResult;
  Result<void>? syncDhikrsToFirestoreResult;
  Result<List<Dhikr>>? getAllDhikrsFromFirestoreResult;
  Result<void>? deleteDhikrFromFirestoreResult;
  Result<int?>? getFirestoreDhikrsCountResult;
  Result<List<Dhikr>?>? getUnsyncedDhikrsResult;

  /// Per-call hook for [deleteDhikrFromFirestore]; wins over the result field.
  Future<Result<void>> Function(String dhikrId)? onDeleteDhikrFromFirestore;

  /// Per-call hook for [getDhikrLocally]; wins over the result field.
  Future<Result<Dhikr?>> Function(String dhikrId)? onGetDhikrLocally;

  /// Per-call hook for [updateDhikrLocally]; wins over the result field.
  Future<Result<void>> Function(String dhikrId, Dhikr dhikr)?
  onUpdateDhikrLocally;

  /// Dhikrs passed to [updateDhikrLocally], in call order.
  final List<Dhikr> updatedDhikrs = [];

  /// Dhikrs passed to [saveDhikrLocally], in call order.
  final List<Dhikr> savedDhikrs = [];

  /// Dhikr lists passed to [createGroupDhikrs], in call order.
  final List<List<Dhikr>> createdGroups = [];

  @override
  ValueListenable<List<Dhikr>> get dhikrsLocally => dhikrsLocallyNotifier;

  @override
  Future<Result<void>> loadAllDhikrsLocally() async {
    calls.add('loadAllDhikrsLocally()');
    return loadAllDhikrsLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> saveDhikrLocally({required Dhikr dhikr}) async {
    calls.add('saveDhikrLocally(id=${dhikr.id})');
    savedDhikrs.add(dhikr);
    return saveDhikrLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<Dhikr?>> getDhikrLocally({required String dhikrId}) async {
    calls.add('getDhikrLocally(dhikrId=$dhikrId)');
    if (onGetDhikrLocally != null) {
      return onGetDhikrLocally!(dhikrId);
    }
    return getDhikrLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<List<Dhikr>?>> getAllDhikrsByDateLocally({
    required DateTime date,
  }) async {
    calls.add(
      'getAllDhikrsByDateLocally(date=${date.toIso8601String().substring(0, 10)})',
    );
    return getAllDhikrsByDateLocallyResult ?? const Ok(<Dhikr>[]);
  }

  @override
  Future<Result<void>> deleteDhikrLocally({required String dhikrId}) async {
    calls.add('deleteDhikrLocally(dhikrId=$dhikrId)');
    return deleteDhikrLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<int>> getDhikrsCountLocally() async {
    calls.add('getDhikrsCountLocally()');
    return getDhikrsCountLocallyResult ?? const Ok(0);
  }

  @override
  Future<Result<void>> clearAllDhikrsLocally() async {
    calls.add('clearAllDhikrsLocally()');
    return clearAllDhikrsLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> updateDhikrLocally({
    required String dhikrId,
    required Dhikr dhikr,
  }) async {
    calls.add('updateDhikrLocally(dhikrId=$dhikrId, isSynced=${dhikr.isSynced})');
    updatedDhikrs.add(dhikr);
    if (onUpdateDhikrLocally != null) {
      return onUpdateDhikrLocally!(dhikrId, dhikr);
    }
    return updateDhikrLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> createGroupDhikrs({required List<Dhikr> dhikrs}) async {
    calls.add('createGroupDhikrs(count=${dhikrs.length})');
    createdGroups.add(List<Dhikr>.of(dhikrs));
    return createGroupDhikrsResult ?? const Ok(null);
  }

  @override
  Future<Result<List<Dhikr>>> getDhikrsByGroupId({
    required String groupId,
  }) async {
    calls.add('getDhikrsByGroupId(groupId=$groupId)');
    return getDhikrsByGroupIdResult ?? const Ok(<Dhikr>[]);
  }

  @override
  Future<Result<void>> syncDhikrsToLocally({required String userId}) async {
    calls.add('syncDhikrsToLocally(userId=$userId)');
    return syncDhikrsToLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> syncDhikrsToFirestore({required String userId}) async {
    calls.add('syncDhikrsToFirestore(userId=$userId)');
    return syncDhikrsToFirestoreResult ?? const Ok(null);
  }

  @override
  Future<Result<List<Dhikr>>> getAllDhikrsFromFirestore({
    required String userId,
  }) async {
    calls.add('getAllDhikrsFromFirestore(userId=$userId)');
    return getAllDhikrsFromFirestoreResult ?? const Ok(<Dhikr>[]);
  }

  @override
  Future<Result<void>> deleteDhikrFromFirestore({
    required String dhikrId,
    required String userId,
  }) async {
    calls.add('deleteDhikrFromFirestore(dhikrId=$dhikrId, userId=$userId)');
    if (onDeleteDhikrFromFirestore != null) {
      return onDeleteDhikrFromFirestore!(dhikrId);
    }
    return deleteDhikrFromFirestoreResult ?? const Ok(null);
  }

  @override
  Future<Result<int?>> getFirestoreDhikrsCount({required String userId}) async {
    calls.add('getFirestoreDhikrsCount(userId=$userId)');
    return getFirestoreDhikrsCountResult ?? const Ok(0);
  }

  @override
  Future<Result<List<Dhikr>?>> getUnsyncedDhikrs() async {
    calls.add('getUnsyncedDhikrs()');
    return getUnsyncedDhikrsResult ?? const Ok(<Dhikr>[]);
  }
}

// ---------------------------------------------------------------------------
// Prayer
// ---------------------------------------------------------------------------

class FakePrayerRepository implements PrayerRepository {
  final List<String> calls = [];

  Result<Prayer?>? getPrayerTimesLocallyResult;
  Result<void>? savePrayerTimesLocallyResult;
  Result<void>? clearOldPrayerTimesResult;
  Result<void>? clearAllPrayerTimesLocallyResult;
  Result<Prayer?>? getPrayerTimesFromRemoteResult;

  /// Prayers passed to [savePrayerTimesLocally], in call order.
  final List<Prayer> savedPrayers = [];

  @override
  Future<Result<Prayer?>> getPrayerTimesLocally({
    required String districtId,
    required String city,
    required String country,
  }) async {
    calls.add(
      'getPrayerTimesLocally(districtId=$districtId, city=$city, '
      'country=$country)',
    );
    return getPrayerTimesLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> savePrayerTimesLocally({required Prayer prayer}) async {
    calls.add('savePrayerTimesLocally(id=${prayer.id})');
    savedPrayers.add(prayer);
    return savePrayerTimesLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> clearOldPrayerTimes({
    required String currentDistrictId,
    required String userId,
  }) async {
    calls.add(
      'clearOldPrayerTimes(currentDistrictId=$currentDistrictId, '
      'userId=$userId)',
    );
    return clearOldPrayerTimesResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> clearAllPrayerTimesLocally() async {
    calls.add('clearAllPrayerTimesLocally()');
    return clearAllPrayerTimesLocallyResult ?? const Ok(null);
  }

  @override
  Future<Result<Prayer?>> getPrayerTimesFromRemote({
    required String districtId,
    required String city,
    required String country,
    required String userId,
  }) async {
    calls.add(
      'getPrayerTimesFromRemote(districtId=$districtId, city=$city, '
      'country=$country, userId=$userId)',
    );
    return getPrayerTimesFromRemoteResult ?? const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// Notification
// ---------------------------------------------------------------------------

/// A single recorded prayer notification schedule request.
typedef ScheduledPrayerNotification = ({
  String prayerName,
  DateTime prayerTime,
  String dateKey,
});

/// A single recorded dhikr reminder schedule request.
typedef ScheduledDhikrReminder = ({String userId, DateTime day});

/// A single recorded dhikr creation reminder schedule request.
typedef ScheduledDhikrCreationReminder = ({
  String userId,
  DateTime day,
  String userName,
});

class FakeNotificationRepository implements NotificationRepository {
  final List<String> calls = [];

  Result<void>? schedulePrayerTimeNotificationResult;
  Result<void>? scheduleDhikrCompletionReminderNotificationResult;
  Result<void>? scheduleDhikrCreationReminderNotificationResult;
  Result<void>? cancelAllPrayerNotificationsResult;
  Result<void>? cancelAllNotificationsResult;
  Result<void>? cancelDhikrCreationReminderNotificationsResult;
  Result<void>? cancelTodayDhikrNotificationsResult;
  Result<void>? cancelTodayDhikrCreationReminderNotificationResult;
  Result<void>? cancelDhikrReminderNotificationResult;

  /// Per-call hook for [schedulePrayerTimeNotification]; wins over the
  /// result field.
  Future<Result<void>> Function(ScheduledPrayerNotification request)?
  onSchedulePrayerTimeNotification;

  /// Per-call hook for [scheduleDhikrCreationReminderNotification]; wins
  /// over the result field.
  Future<Result<void>> Function(ScheduledDhikrCreationReminder request)?
  onScheduleDhikrCreationReminderNotification;

  final List<ScheduledPrayerNotification> scheduledPrayerNotifications = [];
  final List<ScheduledDhikrReminder> scheduledDhikrReminders = [];
  final List<ScheduledDhikrCreationReminder> scheduledDhikrCreationReminders =
      [];

  @override
  Future<Result<void>> schedulePrayerTimeNotification({
    required String prayerName,
    required DateTime prayerTime,
    required String dateKey,
  }) async {
    calls.add(
      'schedulePrayerTimeNotification(prayerName=$prayerName, '
      'dateKey=$dateKey)',
    );
    final request = (
      prayerName: prayerName,
      prayerTime: prayerTime,
      dateKey: dateKey,
    );
    scheduledPrayerNotifications.add(request);
    if (onSchedulePrayerTimeNotification != null) {
      return onSchedulePrayerTimeNotification!(request);
    }
    return schedulePrayerTimeNotificationResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> scheduleDhikrCompletionReminderNotification({
    required String userId,
    required DateTime day,
  }) async {
    calls.add(
      'scheduleDhikrCompletionReminderNotification(userId=$userId, '
      'day=${day.toIso8601String()})',
    );
    scheduledDhikrReminders.add((userId: userId, day: day));
    return scheduleDhikrCompletionReminderNotificationResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> scheduleDhikrCreationReminderNotification({
    required String userId,
    required DateTime day,
    required String userName,
  }) async {
    calls.add(
      'scheduleDhikrCreationReminderNotification(userId=$userId, '
      'userName=$userName)',
    );
    final request = (userId: userId, day: day, userName: userName);
    scheduledDhikrCreationReminders.add(request);
    if (onScheduleDhikrCreationReminderNotification != null) {
      return onScheduleDhikrCreationReminderNotification!(request);
    }
    return scheduleDhikrCreationReminderNotificationResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> cancelAllPrayerNotifications() async {
    calls.add('cancelAllPrayerNotifications()');
    return cancelAllPrayerNotificationsResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> cancelAllNotifications() async {
    calls.add('cancelAllNotifications()');
    return cancelAllNotificationsResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> cancelDhikrCreationReminderNotifications() async {
    calls.add('cancelDhikrCreationReminderNotifications()');
    return cancelDhikrCreationReminderNotificationsResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> cancelTodayDhikrNotifications({
    required String userId,
  }) async {
    calls.add('cancelTodayDhikrNotifications(userId=$userId)');
    return cancelTodayDhikrNotificationsResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> cancelTodayDhikrCreationReminderNotification({
    required String userId,
  }) async {
    calls.add('cancelTodayDhikrCreationReminderNotification(userId=$userId)');
    return cancelTodayDhikrCreationReminderNotificationResult ??
        const Ok(null);
  }

  @override
  Future<Result<void>> cancelDhikrReminderNotification({
    required String userId,
    required DateTime day,
  }) async {
    calls.add(
      'cancelDhikrReminderNotification(userId=$userId, '
      'day=${day.toIso8601String()})',
    );
    return cancelDhikrReminderNotificationResult ?? const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------

class FakeAppRepository implements AppRepository {
  FakeAppRepository({AppPreferences? preferences})
    : appPreferencesNotifier = ValueNotifier<AppPreferences>(
        preferences ?? AppPreferences.empty(),
      );

  final ValueNotifier<AppPreferences> appPreferencesNotifier;
  final List<String> calls = [];

  Result<AppPreferences>? getPreferencesResult;
  Result<void>? updateIsVibrationEnabledResult;
  Result<void>? updateIsNotificationsEnabledResult;
  Result<void>? updateIsOnboardingCompletedResult;
  Result<void>? updateAssistantDailyLimitResult;
  Result<void>? resetAssistantDailyLimitResult;

  @override
  ValueListenable<AppPreferences> get appPreferences => appPreferencesNotifier;

  @override
  Future<Result<AppPreferences>> getPreferences() async {
    calls.add('getPreferences()');
    return getPreferencesResult ?? Ok(appPreferencesNotifier.value);
  }

  @override
  Future<Result<void>> updateIsVibrationEnabled({
    required bool isVibrationEnabled,
  }) async {
    calls.add('updateIsVibrationEnabled($isVibrationEnabled)');
    if (updateIsVibrationEnabledResult == null) {
      appPreferencesNotifier.value = appPreferencesNotifier.value.copyWith(
        isVibrationEnabled: isVibrationEnabled,
      );
    }
    return updateIsVibrationEnabledResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> updateIsNotificationsEnabled({
    required bool isNotificationsEnabled,
  }) async {
    calls.add('updateIsNotificationsEnabled($isNotificationsEnabled)');
    if (updateIsNotificationsEnabledResult == null) {
      appPreferencesNotifier.value = appPreferencesNotifier.value.copyWith(
        isNotificationsEnabled: isNotificationsEnabled,
      );
    }
    return updateIsNotificationsEnabledResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> updateIsOnboardingCompleted({
    required bool isOnboardingCompleted,
  }) async {
    calls.add('updateIsOnboardingCompleted($isOnboardingCompleted)');
    if (updateIsOnboardingCompletedResult == null) {
      appPreferencesNotifier.value = appPreferencesNotifier.value.copyWith(
        isOnboardingCompleted: isOnboardingCompleted,
      );
    }
    return updateIsOnboardingCompletedResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> updateAssistantDailyLimit({
    required int updatedDailyLimit,
  }) async {
    calls.add('updateAssistantDailyLimit($updatedDailyLimit)');
    final handler = onUpdateAssistantDailyLimit;
    if (handler != null) {
      final result = await handler(updatedDailyLimit);
      if (result is Ok) {
        appPreferencesNotifier.value = appPreferencesNotifier.value.copyWith(
          assistantDailyLimit: updatedDailyLimit,
        );
      }
      return result;
    }
    if (updateAssistantDailyLimitResult == null) {
      appPreferencesNotifier.value = appPreferencesNotifier.value.copyWith(
        assistantDailyLimit: updatedDailyLimit,
      );
    }
    return updateAssistantDailyLimitResult ?? const Ok(null);
  }

  /// Per-call handler for [updateAssistantDailyLimit]; takes precedence over
  /// [updateAssistantDailyLimitResult] when set.
  Future<Result<void>> Function(int updatedDailyLimit)?
  onUpdateAssistantDailyLimit;

  @override
  Future<Result<void>> resetAssistantDailyLimit() async {
    calls.add('resetAssistantDailyLimit()');
    return resetAssistantDailyLimitResult ?? const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// Assistant
// ---------------------------------------------------------------------------

/// A single recorded [FakeAssistantRepository.sendMessage] request.
typedef SentAssistantMessage = ({
  String message,
  String senderName,
  String senderAge,
  String senderGender,
  List<String>? previousMessages,
  String? postContent,
});

class FakeAssistantRepository implements AssistantRepository {
  final List<String> calls = [];
  final List<SentAssistantMessage> sentMessages = [];

  Result<String>? sendMessageResult;

  @override
  Future<Result<String>> sendMessage({
    required String message,
    required String senderName,
    required String senderAge,
    required String senderGender,
    List<String>? previousMessages,
    String? postContent,
  }) async {
    calls.add('sendMessage(message=$message)');
    sentMessages.add((
      message: message,
      senderName: senderName,
      senderAge: senderAge,
      senderGender: senderGender,
      previousMessages: previousMessages,
      postContent: postContent,
    ));
    return sendMessageResult ?? const Ok('assistant-reply');
  }
}

// ---------------------------------------------------------------------------
// Purchase
// ---------------------------------------------------------------------------

class FakePurchaseRepository implements PurchaseRepository {
  final List<String> calls = [];

  Result<bool>? isUserPremiumResult;
  Result<void>? purchasePremiumResult;
  Result<void>? restorePurchasesResult;
  Result<void>? syncPremiumStatusWithBackendResult;

  /// When set, thrown by every method (to exercise use-case catch blocks).
  Object? throwOnCall;

  void _maybeThrow() {
    if (throwOnCall != null) {
      // ignore: only_throw_errors
      throw throwOnCall!;
    }
  }

  @override
  Future<Result<bool>> isUserPremium() async {
    calls.add('isUserPremium()');
    _maybeThrow();
    return isUserPremiumResult ?? const Ok(false);
  }

  @override
  Future<Result<void>> purchasePremium(SupportPackage package) async {
    calls.add('purchasePremium(package=${package.value})');
    _maybeThrow();
    return purchasePremiumResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> restorePurchases() async {
    calls.add('restorePurchases()');
    _maybeThrow();
    return restorePurchasesResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> syncPremiumStatusWithBackend() async {
    calls.add('syncPremiumStatusWithBackend()');
    _maybeThrow();
    return syncPremiumStatusWithBackendResult ?? const Ok(null);
  }
}

// ---------------------------------------------------------------------------
// Post
// ---------------------------------------------------------------------------

class FakePostRepository implements PostRepository {
  FakePostRepository({
    List<Post>? posts,
    List<String>? savedPostIds,
    List<Post>? savedPosts,
  }) : postsNotifier = ValueNotifier<List<Post>>(posts ?? const []),
       savedPostIdsNotifier = ValueNotifier<List<String>>(
         savedPostIds ?? const [],
       ),
       savedPostsNotifier = ValueNotifier<List<Post>>(savedPosts ?? const []);

  final ValueNotifier<List<Post>> postsNotifier;
  final ValueNotifier<List<String>> savedPostIdsNotifier;
  final ValueNotifier<List<Post>> savedPostsNotifier;
  final List<String> calls = [];

  Result<Post>? createPostResult;
  Result<Post>? updatePostResult;
  Result<Post>? fetchPostResult;
  Result<List<Post>>? fetchPostsResult;
  Result<List<Post>>? fetchPostsByUserResult;
  Result<void>? deletePostResult;
  Result<void>? savePostResult;
  Result<void>? unsavePostResult;
  Result<List<String>>? fetchSavedPostIdsResult;
  Result<List<Post>>? fetchPostsByIdsResult;

  /// Per-call hook for [fetchPosts]; wins over the result field. Lets a test
  /// mutate [postsNotifier] mid-fetch, the way the real repository does.
  Future<Result<List<Post>>> Function()? onFetchPosts;

  /// Per-call hook for [fetchPostsByIds]; wins over the result field.
  Future<Result<List<Post>>> Function()? onFetchPostsByIds;

  Post _placeholder(String id, String title, String content) => Post(
    id: id,
    title: title,
    contentType: ContentType.dua,
    content: content,
    source: '',
    createdAt: DateTime(2000),
  );

  @override
  ValueListenable<List<Post>> get posts => postsNotifier;

  @override
  ValueListenable<List<String>> get savedPostIds => savedPostIdsNotifier;

  @override
  ValueListenable<List<Post>> get savedPosts => savedPostsNotifier;

  @override
  Future<Result<Post>> createPost({
    required String userId,
    required String title,
    required String content,
  }) async {
    calls.add('createPost(userId=$userId, title=$title)');
    return createPostResult ?? Ok(_placeholder('post-new', title, content));
  }

  @override
  Future<Result<Post>> updatePost({
    required String postId,
    String? title,
    String? content,
  }) async {
    calls.add('updatePost(postId=$postId)');
    return updatePostResult ??
        Ok(_placeholder(postId, title ?? '', content ?? ''));
  }

  @override
  Future<Result<Post>> fetchPost({required String postId}) async {
    calls.add('fetchPost(postId=$postId)');
    return fetchPostResult ?? Ok(_placeholder(postId, '', ''));
  }

  @override
  Future<Result<List<Post>>> fetchPosts() async {
    calls.add('fetchPosts()');
    if (onFetchPosts != null) {
      return onFetchPosts!();
    }
    return fetchPostsResult ?? Ok(postsNotifier.value);
  }

  @override
  Future<Result<List<Post>>> fetchPostsByUser({required String userId}) async {
    calls.add('fetchPostsByUser(userId=$userId)');
    return fetchPostsByUserResult ?? const Ok(<Post>[]);
  }

  @override
  Future<Result<void>> deletePost({required String postId}) async {
    calls.add('deletePost(postId=$postId)');
    return deletePostResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> savePost({
    required String userId,
    required String postId,
  }) async {
    calls.add('savePost(userId=$userId, postId=$postId)');
    return savePostResult ?? const Ok(null);
  }

  @override
  Future<Result<void>> unsavePost({
    required String userId,
    required String postId,
  }) async {
    calls.add('unsavePost(userId=$userId, postId=$postId)');
    return unsavePostResult ?? const Ok(null);
  }

  @override
  Future<Result<List<String>>> fetchSavedPostIds({
    required String userId,
  }) async {
    calls.add('fetchSavedPostIds(userId=$userId)');
    return fetchSavedPostIdsResult ?? Ok(savedPostIdsNotifier.value);
  }

  @override
  Future<Result<List<Post>>> fetchPostsByIds() async {
    calls.add('fetchPostsByIds()');
    if (onFetchPostsByIds != null) {
      return onFetchPostsByIds!();
    }
    return fetchPostsByIdsResult ?? Ok(savedPostsNotifier.value);
  }
}

// ---------------------------------------------------------------------------
// Places
// ---------------------------------------------------------------------------

class FakePlacesRepository implements PlacesRepository {
  FakePlacesRepository({List<Country>? countries})
    : countriesNotifier = ValueNotifier<List<Country>>(countries ?? const []);

  final ValueNotifier<List<Country>> countriesNotifier;
  final List<String> calls = [];

  Result<void>? getCountriesResult;
  Result<List<StateModel>>? getStatesResult;
  Result<List<District>>? getDistrictsResult;

  @override
  ValueListenable<List<Country>> get countries => countriesNotifier;

  @override
  Future<Result<void>> getCountries() async {
    calls.add('getCountries()');
    return getCountriesResult ?? const Ok(null);
  }

  @override
  Future<Result<List<StateModel>>> getStates(String countryId) async {
    calls.add('getStates(countryId=$countryId)');
    return getStatesResult ?? const Ok(<StateModel>[]);
  }

  @override
  Future<Result<List<District>>> getDistricts(String stateId) async {
    calls.add('getDistricts(stateId=$stateId)');
    return getDistrictsResult ?? const Ok(<District>[]);
  }
}

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

class FakeReportRepository implements ReportRepository {
  final List<String> calls = [];

  Result<void>? reportPostResult;

  @override
  Future<Result<void>> reportPost({
    required String reporterId,
    required String reportedPostId,
    required String reason,
  }) async {
    calls.add(
      'reportPost(reporterId=$reporterId, reportedPostId=$reportedPostId, '
      'reason=$reason)',
    );
    return reportPostResult ?? const Ok(null);
  }
}
