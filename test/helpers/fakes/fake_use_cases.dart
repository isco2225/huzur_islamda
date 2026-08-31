import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

/// Stand-ins for the platform-facing services that concrete use cases reach
/// (AdMob, local notifications, asset-bundle mood catalogue, Hive).
///
/// The ViewModel tests construct the REAL use cases over the fake
/// repositories; only the methods that would touch a platform SDK are
/// overridden here. Every constructor below is channel-free, so subclassing
/// is safe under `flutter test`.

// ---------------------------------------------------------------------------
// AdMob
// ---------------------------------------------------------------------------

/// Records [showInterstitialAd] / [initialize] calls instead of loading ads.
class RecordingAdMobService extends AdMobService {
  int showInterstitialCalls = 0;
  int initializeCalls = 0;

  /// Result returned by [initialize].
  Result<void> initializeResult = const Ok(null);

  @override
  Future<void> showInterstitialAd({
    void Function()? onAdDismissed,
    void Function()? onAdFailedToShow,
    void Function()? onAdFailedToLoad,
  }) async {
    showInterstitialCalls++;
  }

  @override
  Future<Result<void>> initialize() async {
    initializeCalls++;
    return initializeResult;
  }
}

// ---------------------------------------------------------------------------
// Local notifications
// ---------------------------------------------------------------------------

/// Stubs the permission methods of [NotificationService].
class StubNotificationService extends NotificationService {
  Result<bool> checkPermissionStatusResult = const Ok(true);
  Result<bool> requestPermissionResult = const Ok(true);
  int checkPermissionStatusCalls = 0;
  int requestPermissionCalls = 0;

  @override
  Future<Result<bool>> checkPermissionStatus() async {
    checkPermissionStatusCalls++;
    return checkPermissionStatusResult;
  }

  @override
  Future<Result<bool>> requestPermission() async {
    requestPermissionCalls++;
    return requestPermissionResult;
  }
}

// ---------------------------------------------------------------------------
// Dhikr moods
// ---------------------------------------------------------------------------

/// Serves an in-memory mood catalogue instead of reading the asset bundle.
class StubDhikrMoodService extends DhikrMoodService {
  Result<List<Mood>> moodsResult = const Ok(<Mood>[]);
  int getDhikrMoodsCalls = 0;

  @override
  Future<Result<List<Mood>>> getDhikrMoods() async {
    getDhikrMoodsCalls++;
    return moodsResult;
  }
}

// ---------------------------------------------------------------------------
// Hive
// ---------------------------------------------------------------------------

class FakeHiveRepository implements HiveRepository {
  final List<String> calls = [];

  Result<void> initializeHiveResult = const Ok(null);
  Result<void> clearResult = const Ok(null);

  @override
  Future<Result<void>> initializeHive() async {
    calls.add('initializeHive()');
    return initializeHiveResult;
  }

  @override
  Future<Result<void>> clear() async {
    calls.add('clear()');
    return clearResult;
  }
}
