import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  late FakePrayerRepository prayerRepository;
  late FakeConnectivityUseCase connectivity;
  late PrayerTimeUseCase useCase;

  setUp(() {
    prayerRepository = FakePrayerRepository();
    connectivity = FakeConnectivityUseCase(type: ConnectivityEnum.wifi);
    useCase = PrayerTimeUseCase(
      prayerRepository: prayerRepository,
      connectivityUseCase: connectivity,
    );
  });

  Future<Result<PrayerTimes?>> call({
    String districtId = '9541',
    String city = 'İstanbul',
    String country = 'Türkiye',
  }) => useCase.getPrayerTimes(
    districtId: districtId,
    city: city,
    country: country,
    userId: 'uid-1',
  );

  group('PrayerTimeUseCase.getPrayerTimes', () {
    test('returns an error without any calls when location is empty', () async {
      for (final result in [
        await call(districtId: ''),
        await call(city: ''),
        await call(country: ''),
      ]) {
        expect(result, isA<Error<PrayerTimes?>>());
        expect(
          result.asError.error.toString(),
          contains('Lütfen konum bilgilerini seçiniz'),
        );
      }
      expect(prayerRepository.calls, isEmpty);
      expect(connectivity.calls, isEmpty);
    });

    test('returns cached today times without remote or connectivity', () async {
      final cached = Fixtures.prayer(days: 1);
      prayerRepository.getPrayerTimesLocallyResult = Ok(cached);

      final result = await call();

      expect(result, isA<Ok<PrayerTimes?>>());
      expect(result.asOk.value, same(cached.getTodayPrayerTimes()));
      expect(prayerRepository.calls, [
        'getPrayerTimesLocally(districtId=9541, city=İstanbul, '
            'country=Türkiye)',
      ]);
      expect(connectivity.calls, isEmpty);
    });

    test('falls through to remote when cache lacks today', () async {
      final now = DateTime.now();
      final stale = Fixtures.prayer(
        from: DateTime(now.year, now.month, now.day - 10),
        days: 1,
      );
      prayerRepository.getPrayerTimesLocallyResult = Ok(stale);
      prayerRepository.getPrayerTimesFromRemoteResult = Ok(
        Fixtures.prayer(days: 2),
      );

      final result = await call();

      expect(result, isA<Ok<PrayerTimes?>>());
      expect(connectivity.calls, ['connectionType()']);
      expect(
        prayerRepository.calls,
        contains(
          'getPrayerTimesFromRemote(districtId=9541, city=İstanbul, '
          'country=Türkiye, userId=uid-1)',
        ),
      );
    });

    test('falls through to remote when the local read fails', () async {
      prayerRepository.getPrayerTimesLocallyResult = Error(Exception('hive'));
      prayerRepository.getPrayerTimesFromRemoteResult = Ok(Fixtures.prayer());

      final result = await call();

      expect(result, isA<Ok<PrayerTimes?>>());
    });

    test('returns a connectivity error on cache miss when offline', () async {
      connectivity.type = ConnectivityEnum.none;

      final result = await call();

      expect(result, isA<Error<PrayerTimes?>>());
      expect(
        result.asError.error.toString(),
        contains('İnternet bağlantısı yok'),
      );
      expect(
        prayerRepository.calls,
        isNot(contains(startsWith('getPrayerTimesFromRemote'))),
      );
    });

    test('proceeds to remote when the connectivity check itself fails', () async {
      connectivity.connectionTypeResult = Error(Exception('plugin'));
      prayerRepository.getPrayerTimesFromRemoteResult = Ok(Fixtures.prayer());

      final result = await call();

      expect(result, isA<Ok<PrayerTimes?>>());
    });

    test('clears old times, saves and returns today on remote success', () async {
      final remote = Fixtures.prayer(days: 3);
      prayerRepository.getPrayerTimesFromRemoteResult = Ok(remote);

      final result = await call();

      expect(result, isA<Ok<PrayerTimes?>>());
      expect(result.asOk.value, same(remote.getTodayPrayerTimes()));
      expect(prayerRepository.calls, [
        'getPrayerTimesLocally(districtId=9541, city=İstanbul, '
            'country=Türkiye)',
        'getPrayerTimesFromRemote(districtId=9541, city=İstanbul, '
            'country=Türkiye, userId=uid-1)',
        'clearOldPrayerTimes(currentDistrictId=9541, userId=uid-1)',
        'savePrayerTimesLocally(id=${remote.id})',
      ]);
      expect(prayerRepository.savedPrayers.single, same(remote));
    });

    test('still returns today when clearing or saving fails', () async {
      final remote = Fixtures.prayer();
      prayerRepository.getPrayerTimesFromRemoteResult = Ok(remote);
      prayerRepository.clearOldPrayerTimesResult = Error(Exception('clear'));
      prayerRepository.savePrayerTimesLocallyResult = Error(Exception('save'));

      final result = await call();

      expect(result, isA<Ok<PrayerTimes?>>());
      expect(result.asOk.value, isNotNull);
    });

    test('returns "Namaz vakitleri bulunamadı" when remote yields null', () async {
      prayerRepository.getPrayerTimesFromRemoteResult = const Ok(null);

      final result = await call();

      expect(result, isA<Error<PrayerTimes?>>());
      expect(
        result.asError.error.toString(),
        contains('Namaz vakitleri bulunamadı'),
      );
      expect(prayerRepository.savedPrayers, isEmpty);
    });

    test('returns "Bugünün namaz vakitleri bulunamadı" when remote lacks today', () async {
      final now = DateTime.now();
      final remote = Fixtures.prayer(
        from: DateTime(now.year, now.month, now.day + 1),
        days: 1,
      );
      prayerRepository.getPrayerTimesFromRemoteResult = Ok(remote);

      final result = await call();

      expect(result, isA<Error<PrayerTimes?>>());
      expect(
        result.asError.error.toString(),
        contains('Bugünün namaz vakitleri bulunamadı'),
      );
      // The (incomplete) prayer is still persisted before the check.
      expect(prayerRepository.savedPrayers.single, same(remote));
    });

    test('propagates a remote error unchanged', () async {
      final exception = Exception('http 500');
      prayerRepository.getPrayerTimesFromRemoteResult = Error(exception);

      final result = await call();

      expect(result, isA<Error<PrayerTimes?>>());
      expect(result.asError.error, same(exception));
      expect(prayerRepository.savedPrayers, isEmpty);
    });
  });
}
