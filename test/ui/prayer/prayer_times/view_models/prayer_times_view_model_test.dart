import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakePrayerRepository prayerRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late PrayerTimesViewModel viewModel;

  const params = (
    districtId: '9541',
    city: 'İstanbul',
    country: 'Türkiye',
    userId: 'uid-1',
  );

  setUp(() {
    prayerRepository = FakePrayerRepository();
    connectivityUseCase = FakeConnectivityUseCase();
    viewModel = PrayerTimesViewModel(
      prayerTimeUseCase: PrayerTimeUseCase(
        prayerRepository: prayerRepository,
        connectivityUseCase: connectivityUseCase,
      ),
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('prayerTimes starts null', () {
    expect(viewModel.prayerTimes.value, isNull);
  });

  group('getPrayerTimes (real PrayerTimeUseCase)', () {
    test("sets today's times from the local cache on Ok", () async {
      final prayer = Fixtures.prayer();
      prayerRepository.getPrayerTimesLocallyResult = Ok(prayer);

      await viewModel.getPrayerTimes.execute(params);

      expect(viewModel.getPrayerTimes.completed.value, isTrue);
      expect(viewModel.prayerTimes.value, same(prayer.getTodayPrayerTimes()));
      expect(prayerRepository.calls, [
        'getPrayerTimesLocally(districtId=9541, city=İstanbul, country=Türkiye)',
      ]);
      expect(connectivityUseCase.calls, isEmpty);
    });

    test('falls back to the remote source and saves it locally', () async {
      final prayer = Fixtures.prayer();
      prayerRepository.getPrayerTimesFromRemoteResult = Ok(prayer);

      await viewModel.getPrayerTimes.execute(params);

      expect(viewModel.prayerTimes.value, same(prayer.getTodayPrayerTimes()));
      expect(prayerRepository.savedPrayers, [prayer]);
      expect(
        prayerRepository.calls,
        contains(
          'getPrayerTimesFromRemote(districtId=9541, city=İstanbul, '
          'country=Türkiye, userId=uid-1)',
        ),
      );
    });

    test('nulls prayerTimes and flags the command when nothing is found', () async {
      prayerRepository.getPrayerTimesLocallyResult = Ok(Fixtures.prayer());
      await viewModel.getPrayerTimes.execute(params);
      expect(viewModel.prayerTimes.value, isNotNull);

      prayerRepository.getPrayerTimesLocallyResult = const Ok(null);
      prayerRepository.getPrayerTimesFromRemoteResult = const Ok(null);
      await viewModel.getPrayerTimes.execute(params);

      expect(viewModel.getPrayerTimes.error.value, isTrue);
      expect(
        viewModel.getPrayerTimes.result.value!.asError.error.toString(),
        contains('Namaz vakitleri bulunamadı'),
      );
      expect(viewModel.prayerTimes.value, isNull);
    });

    test('errors when offline and nothing is cached', () async {
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.getPrayerTimes.execute(params);

      expect(viewModel.getPrayerTimes.error.value, isTrue);
      expect(
        viewModel.getPrayerTimes.result.value!.asError.error.toString(),
        contains('İnternet bağlantısı yok'),
      );
      expect(prayerRepository.calls, isNot(contains(startsWith('getPrayerTimesFromRemote'))));
    });

    test('errors on empty location parameters without touching the repository', () async {
      await viewModel.getPrayerTimes.execute((
        districtId: '',
        city: 'İstanbul',
        country: 'Türkiye',
        userId: 'uid-1',
      ));

      expect(viewModel.getPrayerTimes.error.value, isTrue);
      expect(prayerRepository.calls, isEmpty);
    });
  });
}
