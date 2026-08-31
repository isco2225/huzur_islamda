import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, QuerySnapshot;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show PendingNotificationRequest;
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show CustomerInfo;

/// Hand-written fakes for the concrete service classes used by the
/// repositories. Every fake `implements` the real service so the repository
/// under test can be constructed without touching Hive, Firebase, HTTP or
/// platform channels. Field initializers of the real classes (for example
/// `dotenv.env[...]` in [AssistantService]) do not run because the fakes
/// implement rather than extend them.

// ---------------------------------------------------------------------------
// Hive
// ---------------------------------------------------------------------------

/// In-memory stand-in for [HiveService].
///
/// Values are kept in a [SplayTreeMap] so that `getAll`/`getWithFilter`
/// return values in key order, which mirrors a real Hive box (Hive keeps its
/// keystore sorted, so `box.values` is ordered by key rather than by insertion).
/// `getWithFilter` returns `Ok(null)` when nothing matches, exactly like the
/// real service.
class FakeHiveService<T> implements HiveService<T> {
  FakeHiveService({this.boxName = 'fake_box'});

  @override
  final String boxName;

  /// Backing store, sorted by key.
  final SplayTreeMap<String, T> store = SplayTreeMap<String, T>();

  /// Names of every method invoked, in order (for example `'save'`).
  final List<String> calls = [];

  /// Keys passed to `save`/`update`, in order.
  final List<String> savedKeys = [];

  /// Keys passed to `delete`/`deleteMany`, in order.
  final List<String> deletedKeys = [];

  /// Methods that always fail.
  final Set<String> alwaysFail = {};

  /// Methods that fail exactly once, then behave normally.
  final Set<String> failOnce = {};

  /// Optional predicate for fine-grained failures (method, key).
  bool Function(String method, String? key)? failWhen;

  /// The exception returned when a call is configured to fail.
  Exception failure = Exception('fake hive failure');

  bool _shouldFail(String method, [String? key]) {
    calls.add(method);
    if (alwaysFail.contains(method)) return true;
    if (failOnce.remove(method)) return true;
    final predicate = failWhen;
    if (predicate != null && predicate(method, key)) return true;
    return false;
  }

  int callCount(String method) => calls.where((c) => c == method).length;

  @override
  Future<Result<T>> save(String key, T value) async {
    if (_shouldFail('save', key)) return Result.error(failure);
    store[key] = value;
    savedKeys.add(key);
    return Result.ok(value);
  }

  @override
  Future<Result<T>> update(String key, T value) async {
    if (_shouldFail('update', key)) return Result.error(failure);
    store[key] = value;
    savedKeys.add(key);
    return Result.ok(value);
  }

  @override
  Future<Result<void>> saveAll(Map<String, T> entries) async {
    if (_shouldFail('saveAll')) return Result.error(failure);
    store.addAll(entries);
    savedKeys.addAll(entries.keys);
    return Result.ok(null);
  }

  @override
  Future<Result<T?>> getById(String key) async {
    if (_shouldFail('getById', key)) return Result.error(failure);
    return Result.ok(store[key]);
  }

  @override
  Future<Result<List<T>>> getAll() async {
    if (_shouldFail('getAll')) return Result.error(failure);
    return Result.ok(store.values.toList());
  }

  @override
  Future<Result<List<T>?>> getWithFilter(bool Function(T) filter) async {
    if (_shouldFail('getWithFilter')) return Result.error(failure);
    final values = store.values.where(filter).toList();
    if (values.isEmpty) return Result.ok(null);
    return Result.ok(values);
  }

  @override
  Future<Result<Map<String, T>>> getAllAsMap() async {
    if (_shouldFail('getAllAsMap')) return Result.error(failure);
    return Result.ok(Map<String, T>.from(store));
  }

  @override
  Future<Result<List<String>>> getAllKeys() async {
    if (_shouldFail('getAllKeys')) return Result.error(failure);
    return Result.ok(store.keys.toList());
  }

  @override
  Future<Result<bool>> exists(String key) async {
    if (_shouldFail('exists', key)) return Result.error(failure);
    return Result.ok(store.containsKey(key));
  }

  @override
  Future<Result<int>> count() async {
    if (_shouldFail('count')) return Result.error(failure);
    return Result.ok(store.length);
  }

  @override
  Future<Result<void>> delete(String key) async {
    if (_shouldFail('delete', key)) return Result.error(failure);
    store.remove(key);
    deletedKeys.add(key);
    return Result.ok(null);
  }

  @override
  Future<Result<void>> deleteMany(List<String> keys) async {
    if (_shouldFail('deleteMany')) return Result.error(failure);
    for (final key in keys) {
      store.remove(key);
      deletedKeys.add(key);
    }
    return Result.ok(null);
  }

  @override
  Future<Result<void>> clear() async {
    if (_shouldFail('clear')) return Result.error(failure);
    store.clear();
    return Result.ok(null);
  }

  @override
  Future<Result<bool>> isEmpty() async {
    if (_shouldFail('isEmpty')) return Result.error(failure);
    return Result.ok(store.isEmpty);
  }

  @override
  Future<void> close() async {
    calls.add('close');
  }
}

// ---------------------------------------------------------------------------
// Prayer API
// ---------------------------------------------------------------------------

class FakePrayerService implements PrayerService {
  /// Result returned by [getPrayerTimes]. Defaults to an empty API payload.
  Result<Map<String, dynamic>> result = Result.ok(<String, dynamic>{});

  /// District ids requested, in order.
  final List<String> requestedDistrictIds = [];

  @override
  Future<Result<Map<String, dynamic>>> getPrayerTimes({
    required String districtId,
  }) async {
    requestedDistrictIds.add(districtId);
    return result;
  }
}

// ---------------------------------------------------------------------------
// Firestore dhikr
// ---------------------------------------------------------------------------

class FakeFirestoreDhikrService implements FirestoreDhikrService {
  Result<void> saveDhikrsResult = const Ok(null);
  Result<List<Dhikr>> fetchDhikrsResult = const Ok(<Dhikr>[]);
  Result<List<Dhikr>> fetchAllDhikrsResult = const Ok(<Dhikr>[]);
  Result<void> deleteDhikrResult = const Ok(null);
  Result<int?> getDhikrsCountResult = const Ok(null);

  /// Every `saveDhikrs` invocation as (userId, dhikrs).
  final List<({String userId, List<Dhikr> dhikrs})> saveDhikrsCalls = [];
  final List<String> fetchAllDhikrsUserIds = [];
  final List<({String userId, String dhikrId})> deleteDhikrCalls = [];
  final List<String> getDhikrsCountUserIds = [];

  @override
  Future<Result<void>> saveDhikrs({
    required String userId,
    required List<Dhikr> dhikrs,
  }) async {
    saveDhikrsCalls.add((userId: userId, dhikrs: List<Dhikr>.of(dhikrs)));
    return saveDhikrsResult;
  }

  @override
  Future<Result<List<Dhikr>>> fetchDhikrs({
    required String userId,
    required DateTime day,
  }) async {
    return fetchDhikrsResult;
  }

  @override
  Future<Result<List<Dhikr>>> fetchAllDhikrs({required String userId}) async {
    fetchAllDhikrsUserIds.add(userId);
    return fetchAllDhikrsResult;
  }

  @override
  Future<Result<void>> deleteDhikr({
    required String userId,
    required String dhikrId,
  }) async {
    deleteDhikrCalls.add((userId: userId, dhikrId: dhikrId));
    return deleteDhikrResult;
  }

  @override
  Future<Result<int?>> getDhikrsCount({required String userId}) async {
    getDhikrsCountUserIds.add(userId);
    return getDhikrsCountResult;
  }
}

// ---------------------------------------------------------------------------
// Firestore user
// ---------------------------------------------------------------------------

class FakeFirestoreUserService implements FirestoreUserService {
  Result<User>? createUserResult;
  Result<void> updateEmailVerificationStatusResult = const Ok(null);
  Result<List<String>?> getFavoritedPostIdsResult = const Ok(null);
  Result<User?> updateUserResult = const Ok(null);
  Result<User?> readAuthenticatedUserResult = const Ok(null);
  Result<void> deleteAuthenticatedUserResult = const Ok(null);
  Result<User?> updateUserLocationResult = const Ok(null);
  Result<User?> updateUserSupportResult = const Ok(null);

  final List<Map<String, Object?>> createUserCalls = [];
  final List<({String uid, bool emailVerified})>
  updateEmailVerificationStatusCalls = [];
  final List<String> getFavoritedPostIdsUids = [];
  final List<Map<String, Object?>> updateUserCalls = [];
  final List<String> readAuthenticatedUserUids = [];
  final List<String> deleteAuthenticatedUserUids = [];
  final List<Map<String, Object?>> updateUserLocationCalls = [];
  final List<Map<String, Object?>> updateUserSupportCalls = [];

  @override
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String gender,
  }) async {
    createUserCalls.add({
      'uid': uid,
      'email': email,
      'name': name,
      'surname': surname,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    });
    return createUserResult ??
        Result.ok(
          User(
            uid: uid,
            email: email,
            name: name,
            surname: surname,
            dateOfBirth: dateOfBirth,
            gender: gender,
            emailVerified: true,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
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
    updateEmailVerificationStatusCalls.add((
      uid: uid,
      emailVerified: emailVerified,
    ));
    return updateEmailVerificationStatusResult;
  }

  @override
  Future<Result<List<String>?>> getFavoritedPostIds({
    required String uid,
  }) async {
    getFavoritedPostIdsUids.add(uid);
    return getFavoritedPostIdsResult;
  }

  @override
  Future<Result<User?>> updateUser({
    required String uid,
    String? name,
    String? surname,
    String? dateOfBirth,
    String? gender,
  }) async {
    updateUserCalls.add({
      'uid': uid,
      'name': name,
      'surname': surname,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    });
    return updateUserResult;
  }

  @override
  Future<Result<User?>> readAuthenticatedUser({required String uid}) async {
    readAuthenticatedUserUids.add(uid);
    return readAuthenticatedUserResult;
  }

  @override
  Future<Result<void>> deleteAuthenticatedUser({required String uid}) async {
    deleteAuthenticatedUserUids.add(uid);
    return deleteAuthenticatedUserResult;
  }

  @override
  Future<Result<User?>> updateUserLocation({
    required String uid,
    required String country,
    required String city,
    required String districtId,
  }) async {
    updateUserLocationCalls.add({
      'uid': uid,
      'country': country,
      'city': city,
      'districtId': districtId,
    });
    return updateUserLocationResult;
  }

  @override
  Future<Result<User?>> updateUserSupport({
    required String uid,
    required bool hasSupported,
    required DateTime lastSupportedAt,
    required String supportPackage,
  }) async {
    updateUserSupportCalls.add({
      'uid': uid,
      'hasSupported': hasSupported,
      'lastSupportedAt': lastSupportedAt,
      'supportPackage': supportPackage,
    });
    return updateUserSupportResult;
  }

  @override
  Future<Result<User?>> updateUserPremium({
    required String uid,
    required DateTime lastPremiumAt,
    required String supportPackage,
  }) {
    // Mirrors the real service, which delegates to updateUserSupport.
    return updateUserSupport(
      uid: uid,
      hasSupported: true,
      lastSupportedAt: lastPremiumAt,
      supportPackage: supportPackage,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------

/// Arguments captured from one `scheduleNotification` call.
class ScheduledNotificationCall {
  const ScheduledNotificationCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledDate;

  @override
  String toString() =>
      'ScheduledNotificationCall(id: $id, title: $title, body: $body, '
      'scheduledDate: $scheduledDate)';
}

class FakeNotificationService implements NotificationService {
  Result<void> initializeResult = const Ok(null);
  Result<bool> checkPermissionStatusResult = const Ok(true);
  Result<bool> requestPermissionResult = const Ok(true);
  Result<void> scheduleNotificationResult = const Ok(null);
  Result<void> cancelNotificationsResult = const Ok(null);
  Result<void> cancelDhikrCreationReminderNotificationsResult = const Ok(null);
  Result<void> cancelAllNotificationsResult = const Ok(null);

  /// Pending list returned by [getPendingNotifications] (when
  /// [getPendingNotificationsError] is null).
  List<PendingNotificationRequest> pending = [];
  Exception? getPendingNotificationsError;

  final List<ScheduledNotificationCall> scheduled = [];

  /// Every `cancelNotifications` call, each holding the ids it received.
  final List<List<int>> cancelCalls = [];
  int cancelDhikrCreationReminderNotificationsCount = 0;
  int cancelAllNotificationsCount = 0;
  int getPendingNotificationsCount = 0;

  @override
  Future<Result<void>> initialize() async => initializeResult;

  @override
  Future<Result<bool>> checkPermissionStatus() async =>
      checkPermissionStatusResult;

  @override
  Future<Result<bool>> requestPermission() async => requestPermissionResult;

  @override
  Future<Result<void>> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    scheduled.add(
      ScheduledNotificationCall(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      ),
    );
    return scheduleNotificationResult;
  }

  @override
  Future<Result<void>> cancelNotifications({required List<int> ids}) async {
    cancelCalls.add(List<int>.of(ids));
    return cancelNotificationsResult;
  }

  @override
  Future<Result<void>> cancelDhikrCreationReminderNotifications() async {
    cancelDhikrCreationReminderNotificationsCount++;
    return cancelDhikrCreationReminderNotificationsResult;
  }

  @override
  Future<Result<void>> cancelAllNotifications() async {
    cancelAllNotificationsCount++;
    return cancelAllNotificationsResult;
  }

  @override
  Future<Result<List<PendingNotificationRequest>>>
  getPendingNotifications() async {
    getPendingNotificationsCount++;
    final error = getPendingNotificationsError;
    if (error != null) return Result.error(error);
    return Result.ok(List<PendingNotificationRequest>.of(pending));
  }
}

// ---------------------------------------------------------------------------
// Places
// ---------------------------------------------------------------------------

class FakePlaceSelectorService implements PlaceSelectorService {
  Result<List<Country>> countriesResult = const Ok(<Country>[]);
  Result<List<StateModel>> statesResult = const Ok(<StateModel>[]);
  Result<List<District>> districtsResult = const Ok(<District>[]);

  int getCountriesCount = 0;
  final List<String> requestedCountryIds = [];
  final List<String> requestedStateIds = [];

  @override
  Future<Result<List<Country>>> getCountries() async {
    getCountriesCount++;
    return countriesResult;
  }

  @override
  Future<Result<List<StateModel>>> getStates(String countryId) async {
    requestedCountryIds.add(countryId);
    return statesResult;
  }

  @override
  Future<Result<List<District>>> getDistricts(String stateId) async {
    requestedStateIds.add(stateId);
    return districtsResult;
  }
}

// ---------------------------------------------------------------------------
// Shared preferences
// ---------------------------------------------------------------------------

class FakeSharedPreferencesService implements SharedPreferencesService {
  /// Stored JSON documents keyed by preference key.
  final Map<String, Map<String, Object?>> store = {};

  /// When set, `fetchJson` returns this error instead of reading the store.
  Exception? fetchError;

  /// When set, `saveJson` returns this error and leaves the store untouched.
  Exception? saveError;

  /// When true, `fetchJson` throws instead of returning a Result.
  bool throwOnFetch = false;

  /// When true, `saveJson` throws instead of returning a Result.
  bool throwOnSave = false;

  final List<String> fetchedKeys = [];
  final List<String> savedKeys = [];

  @override
  Future<Result<Map<String, Object?>?>> fetchJson({
    required String key,
  }) async {
    fetchedKeys.add(key);
    if (throwOnFetch) throw Exception('fake fetch throw');
    final error = fetchError;
    if (error != null) return Result.error(error);
    final json = store[key];
    if (json == null) return Result.ok(null);
    return Result.ok(Map<String, Object?>.from(json));
  }

  @override
  Future<Result<dynamic>> saveJson({
    required String key,
    required Map<String, Object?> json,
  }) async {
    savedKeys.add(key);
    if (throwOnSave) throw Exception('fake save throw');
    final error = saveError;
    if (error != null) return Result.error(error);
    store[key] = Map<String, Object?>.from(json);
    return Result.ok(null);
  }
}

// ---------------------------------------------------------------------------
// Report
// ---------------------------------------------------------------------------

class FakeReportService implements ReportService {
  Result<void> reportPostResult = const Ok(null);

  /// When true, `reportPost` throws instead of returning a Result.
  bool throwOnCall = false;

  final List<Map<String, String>> reportPostCalls = [];

  @override
  Future<Result<void>> reportPost({
    required String reporterId,
    required String reportedPostId,
    required String reason,
  }) async {
    reportPostCalls.add({
      'reporterId': reporterId,
      'reportedPostId': reportedPostId,
      'reason': reason,
    });
    if (throwOnCall) throw Exception('fake report throw');
    return reportPostResult;
  }
}

// ---------------------------------------------------------------------------
// Assistant (Gemini)
// ---------------------------------------------------------------------------

class FakeAssistantService implements AssistantService {
  Result<String> sendMessageResult = const Ok('fake reply');

  /// When true, `sendMessage` throws instead of returning a Result.
  bool throwOnCall = false;

  final List<Map<String, Object?>> sendMessageCalls = [];

  @override
  Future<Result<String>> sendMessage({
    required String message,
    required String senderName,
    required String senderAge,
    required String senderGender,
    List<String>? previousMessages,
    String? postContent,
  }) async {
    sendMessageCalls.add({
      'message': message,
      'senderName': senderName,
      'senderAge': senderAge,
      'senderGender': senderGender,
      'previousMessages': previousMessages,
      'postContent': postContent,
    });
    if (throwOnCall) throw Exception('fake assistant throw');
    return sendMessageResult;
  }
}

// ---------------------------------------------------------------------------
// Firestore posts
// ---------------------------------------------------------------------------

class FakeFirestorePostService implements FirestorePostService {
  Result<void> savePostResult = const Ok(null);
  Result<void> unsavePostResult = const Ok(null);
  Result<List<String>> fetchSavedPostIdsResult = const Ok(<String>[]);

  /// When set, `fetchPostsByIds` returns this instead of looking up
  /// [postsById].
  Result<List<Post>>? fetchPostsByIdsResult;

  /// Posts served by `fetchPostsByIds`, keyed by id.
  final Map<String, Post> postsById = {};

  final List<({String userId, String postId})> savePostCalls = [];
  final List<({String userId, String postId})> unsavePostCalls = [];
  final List<String> fetchSavedPostIdsUserIds = [];
  final List<List<String>> fetchPostsByIdsCalls = [];

  /// `QuerySnapshot` cannot be constructed outside the Firestore SDK, so the
  /// feed pagination path is not fakeable.
  @override
  Future<Result<QuerySnapshot<Map<String, dynamic>>>> fetchPosts({
    required DocumentSnapshot? lastFetchedPost,
  }) {
    throw UnimplementedError(
      'fetchPosts returns a Firestore QuerySnapshot and cannot be faked',
    );
  }

  @override
  Future<Result<void>> savePost({
    required String userId,
    required String postId,
  }) async {
    savePostCalls.add((userId: userId, postId: postId));
    return savePostResult;
  }

  @override
  Future<Result<void>> unsavePost({
    required String userId,
    required String postId,
  }) async {
    unsavePostCalls.add((userId: userId, postId: postId));
    return unsavePostResult;
  }

  @override
  Future<Result<List<String>>> fetchSavedPostIds({
    required String userId,
  }) async {
    fetchSavedPostIdsUserIds.add(userId);
    return fetchSavedPostIdsResult;
  }

  @override
  Future<Result<List<Post>>> fetchPostsByIds({
    required List<String> postIds,
  }) async {
    fetchPostsByIdsCalls.add(List<String>.of(postIds));
    final override = fetchPostsByIdsResult;
    if (override != null) return override;
    return Result.ok([
      for (final id in postIds)
        if (postsById[id] != null) postsById[id]!,
    ]);
  }
}

// ---------------------------------------------------------------------------
// Firebase auth / cloud functions
// ---------------------------------------------------------------------------

/// `getCurrentUser` always returns null: a `firebase_auth.User` cannot be
/// constructed outside the SDK, so the "already signed in at startup" branch
/// of [AuthRepositoryRemote] is not reachable through this fake.
class FakeFirebaseAuthService implements FirebaseAuthService {
  Result<Auth> signUpResult = const Error<Auth>(AuthSignUpFailed());
  Result<Auth> signInWithGoogleResult = const Error<Auth>(
    AuthGoogleSignInFailed(),
  );
  Result<Auth> signInWithAppleResult = const Error<Auth>(
    AuthAppleSignInFailed(),
  );
  Result<Auth> signInResult = const Error<Auth>(AuthSignInFailed());
  Result<void> sendEmailVerificationResult = const Ok(null);
  Result<bool> checkEmailVerificationResult = const Ok(true);
  Result<void> sendPasswordResetEmailResult = const Ok(null);
  Result<void> signOutResult = const Ok(null);
  Result<void> deleteAccountResult = const Ok(null);
  Result<void> reauthenticateWithEmailResult = const Ok(null);
  Result<void> updatePasswordResult = const Ok(null);
  Result<void> reauthenticateWithGoogleResult = const Ok(null);
  Result<void> reauthenticateWithAppleResult = const Ok(null);
  Result<void> refreshUserResult = const Ok(null);

  final List<({String email, String password})> signInCalls = [];
  final List<({String email, String password})> signUpCalls = [];
  final List<String> passwordResetEmails = [];
  final List<({String currentPassword, String newPassword})>
  updatePasswordCalls = [];
  int signOutCount = 0;
  int deleteAccountCount = 0;
  int getCurrentUserCount = 0;

  @override
  firebase_auth.User? getCurrentUser() {
    getCurrentUserCount++;
    return null;
  }

  @override
  Future<Result<Auth>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signUpCalls.add((email: email, password: password));
    return signUpResult;
  }

  @override
  Future<Result<Auth>> signInWithGoogle() async => signInWithGoogleResult;

  @override
  Future<Result<Auth>> signInWithApple() async => signInWithAppleResult;

  @override
  Future<Result<void>> sendEmailVerification() async =>
      sendEmailVerificationResult;

  @override
  Future<Result<bool>> checkEmailVerification() async =>
      checkEmailVerificationResult;

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    passwordResetEmails.add(email);
    return sendPasswordResetEmailResult;
  }

  @override
  Future<Result<Auth>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInCalls.add((email: email, password: password));
    return signInResult;
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCount++;
    return signOutResult;
  }

  @override
  Future<Result<void>> deleteAccount() async {
    deleteAccountCount++;
    return deleteAccountResult;
  }

  @override
  Future<Result<void>> reauthenticateWithEmail({
    required String password,
  }) async => reauthenticateWithEmailResult;

  @override
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    updatePasswordCalls.add((
      currentPassword: currentPassword,
      newPassword: newPassword,
    ));
    return updatePasswordResult;
  }

  @override
  Future<Result<void>> reauthenticateWithGoogle() async =>
      reauthenticateWithGoogleResult;

  @override
  Future<Result<void>> reauthenticateWithApple() async =>
      reauthenticateWithAppleResult;

  @override
  Future<Result<void>> refreshUser() async => refreshUserResult;
}

class FakeFirebaseCloudFunctionsService
    implements FirebaseCloudFunctionsService {
  Result<void> deleteUserAccountResult = const Ok(null);
  int deleteUserAccountCount = 0;

  @override
  Future<Result<void>> deleteUserAccount() async {
    deleteUserAccountCount++;
    return deleteUserAccountResult;
  }
}

// ---------------------------------------------------------------------------
// RevenueCat
// ---------------------------------------------------------------------------

/// Only `logIn` is configurable. Every other method throws, because
/// `CustomerInfo` cannot be constructed outside the SDK and the tests only
/// exercise the login gate of [PurchaseRepositoryRemote].
class FakeRevenueCatService implements RevenueCatService {
  Result<void> logInResult = const Ok(null);
  final List<String> logInUserIds = [];

  Never _unexpected(String method) =>
      throw StateError('FakeRevenueCatService.$method must not be called');

  @override
  Future<Result<void>> configure({
    required String apiKey,
    String? appUserId,
  }) async => _unexpected('configure');

  @override
  Future<Result<void>> logIn({required String appUserId}) async {
    logInUserIds.add(appUserId);
    return logInResult;
  }

  @override
  Future<Result<void>> logOut() async => _unexpected('logOut');

  @override
  Future<Result<CustomerInfo>> getCustomerInfo() async =>
      _unexpected('getCustomerInfo');

  @override
  Future<Result<bool>> isUserPremium({required String entitlementId}) async =>
      _unexpected('isUserPremium');

  @override
  Future<Result<void>> purchasePremium({
    required SupportPackage package,
    required String entitlementId,
  }) async => _unexpected('purchasePremium');

  @override
  Future<Result<void>> restorePurchases({
    required String entitlementId,
  }) async => _unexpected('restorePurchases');
}
