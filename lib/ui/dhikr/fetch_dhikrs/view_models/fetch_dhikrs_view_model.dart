import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class FetchDhikrsViewModel {
  FetchDhikrsViewModel({
    required DhikrRepository dhikrRepository,
    required UserRepository userRepository,
    required DhikrUseCase dhikrUseCase,
  }) : _dhikrRepository = dhikrRepository,
       _dhikrUseCase = dhikrUseCase,
       _userRepository = userRepository {
    fetchDhikrs = Command1<void, DateTime>(
      _fetchDhikrs,
      debugLabel: 'fetchDhikrs',
    );
    deleteGroup = Command1<void, List<String>>(
      _deleteGroup,
      debugLabel: 'deleteGroup',
    );
    _selectedDate = ValueNotifier<DateTime>(_getToday());

    _dhikrRepository.dhikrsLocally.addListener(_updateDhikrsForSelectedDate);

    _selectedDate.addListener(_updateDhikrsForSelectedDate);

    _loadAllDhikrs();
  }

  void _loadAllDhikrs() async {
    final result = await _dhikrRepository.loadAllDhikrsLocally();
    switch (result) {
      case Ok():
        _log.info('All dhikrs loaded successfully');
      case Error():
        _log.severe('Failed to load all dhikrs: ${result.asError.error}');
    }
  }

  // LOGGER
  final _log = Logger('FetchDhikrsViewModel');

  // REPOSITORIES & USE CASES
  final DhikrRepository _dhikrRepository;
  final UserRepository _userRepository;
  final DhikrUseCase _dhikrUseCase;
  // DOMAIN
  ValueListenable<List<Dhikr>?> get dhikrs => _dhikrs;
  final ValueNotifier<List<Dhikr>?> _dhikrs = ValueNotifier<List<Dhikr>?>(null);

  /// Seçili tarihteki grup zikirleri.
  ///
  /// Aynı `groupId`'ye sahip zikirler bir `GroupDhikrData` içinde gruplanır.
  ValueListenable<List<GroupDhikrData>?> get groupDhikrs => _groupDhikrs;
  final ValueNotifier<List<GroupDhikrData>?> _groupDhikrs =
      ValueNotifier<List<GroupDhikrData>?>(null);
  ValueListenable<DateTime> get selectedDate => _selectedDate;
  late final ValueNotifier<DateTime> _selectedDate;

  /// İlk yükleme durumu. İlk yükleme tamamlanana kadar true kalır.
  ValueListenable<bool> get isInitialLoading => _isInitialLoading;
  final ValueNotifier<bool> _isInitialLoading = ValueNotifier<bool>(true);

  // COMMANDS
  late Command1<void, DateTime> fetchDhikrs;
  late Command1<void, List<String>> deleteGroup;

  // DISPOSE
  void dispose() {
    _dhikrRepository.dhikrsLocally.removeListener(_updateDhikrsForSelectedDate);
    _selectedDate.removeListener(_updateDhikrsForSelectedDate);
    fetchDhikrs.dispose();
    deleteGroup.dispose();
    _selectedDate.dispose();
    _dhikrs.dispose();
    _groupDhikrs.dispose();
    _isInitialLoading.dispose();
    _log.fine('Disposed');
  }

  // DATE NAVIGATION
  void goToPreviousDay() {
    final currentDate = _selectedDate.value;
    final previousDate = currentDate.subtract(const Duration(days: 1));
    _selectedDate.value = previousDate;
    // _onSelectedDateChanged otomatik olarak çağrılacak
  }

  void goToNextDay() {
    final currentDate = _selectedDate.value;
    final nextDate = currentDate.add(const Duration(days: 1));
    final today = _getToday();
    // Geleceğe gidilemez, bugüne kadar gidilebilir
    if (!nextDate.isAfter(today)) {
      _selectedDate.value = nextDate;
      // _onSelectedDateChanged otomatik olarak çağrılacak
    }
  }

  void goToToday() {
    final today = _getToday();
    _selectedDate.value = today;
    // _onSelectedDateChanged otomatik olarak çağrılacak
  }

  bool get canGoToNextDay {
    final currentDate = _selectedDate.value;
    final today = _getToday();
    return currentDate.isBefore(today);
  }

  // PRIVATE HELPERS
  DateTime _getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Seçili tarihe göre zikirleri güncelle
  void _updateDhikrsForSelectedDate() {
    if (_isInitialLoading.value) {
      _isInitialLoading.value = false;
    }

    final selectedDate = _selectedDate.value;
    final allDhikrs = _dhikrRepository.dhikrsLocally.value;

    // Seçili tarihe göre filtrele
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final filteredDhikrs = allDhikrs.where((dhikr) {
      final dhikrDate = DateTime(
        dhikr.day.year,
        dhikr.day.month,
        dhikr.day.day,
      );
      return dhikrDate.year == normalizedDate.year &&
          dhikrDate.month == normalizedDate.month &&
          dhikrDate.day == normalizedDate.day;
    }).toList();

    if (filteredDhikrs.isEmpty) {
      _dhikrs.value = null;
      _groupDhikrs.value = null;
    } else {
      // Grup zikirlerini oluştur (groupId'ye göre grupla)
      final groupMap = <String, List<Dhikr>>{};
      final nonGroupDhikrs = <Dhikr>[];

      for (final dhikr in filteredDhikrs) {
        final groupId = dhikr.groupId ?? '';
        if (groupId.isEmpty) {
          // groupId yoksa normal zikir listesine ekle
          nonGroupDhikrs.add(dhikr);
        } else {
          // groupId varsa grup haritasına ekle
          groupMap.putIfAbsent(groupId, () => <Dhikr>[]).add(dhikr);
        }
      }

      // Normal zikirleri sırala ve ayarla (groupId'si olmayanlar)
      nonGroupDhikrs.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
      _dhikrs.value = nonGroupDhikrs.isEmpty ? null : nonGroupDhikrs;

      if (groupMap.isEmpty) {
        _groupDhikrs.value = null;
      } else {
        final groups = <GroupDhikrData>[];

        for (final entry in groupMap.entries) {
          final groupId = entry.key;
          final dhikrsInGroup = List<Dhikr>.from(entry.value);
          // Namaz tesbihatı sırası: Subhanallah, Elhamdulillah, Allahu Ekber
          dhikrsInGroup.sort((a, b) {
            final indexA = PrayerDhikrConstants.prayerDhikrNames.indexOf(
              a.name,
            );
            final indexB = PrayerDhikrConstants.prayerDhikrNames.indexOf(
              b.name,
            );
            final orderA = indexA >= 0 ? indexA : 999;
            final orderB = indexB >= 0 ? indexB : 999;
            return orderA.compareTo(orderB);
          });
          groups.add(
            GroupDhikrData(
              groupId: groupId,
              dhikrs: dhikrsInGroup,
              groupName:
                  dhikrsInGroup.first.groupDisplayName ?? 'Namaz Tesbihatı',
            ),
          );
        }
        final groupWithCreatedAt = groups.map((g) {
          final created = g.dhikrs
              .map((d) => d.createdAt)
              .reduce((x, y) => x.isBefore(y) ? x : y);
          return (group: g, createdAt: created);
        }).toList();
        groupWithCreatedAt.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _groupDhikrs.value = groupWithCreatedAt.map((e) => e.group).toList();
      }
    }

    _log.fine(
      'Updated dhikrs for date: $selectedDate, count: ${filteredDhikrs.length}',
    );
  }

  // FUNCTIONS
  Future<Result<void>> _fetchDhikrs(DateTime date) async {
    final currentUser = _userRepository.currentUser.value;
    if (currentUser.uid.isEmpty) {
      _log.warning('No authenticated user found');
      return Result.error(const DhikrUserIdEmpty());
    }

    final result = await _dhikrRepository.getAllDhikrsByDateLocally(date: date);
    switch (result) {
      case Ok():
        final dhikrs = result.asOk.value;
        if (dhikrs == null) {
          _log.fine('No dhikrs found for date: $date');
          _dhikrs.value = null;
          return Result.ok(null);
        }
        _log.fine('Dhikrs fetched successfully');

        // groupId'si olmayan zikirleri filtrele
        final nonGroupDhikrs = dhikrs
            .where((dhikr) => dhikr.groupId == null || dhikr.groupId!.isEmpty)
            .toList();

        nonGroupDhikrs.sort(
          (a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt),
        );
        _dhikrs.value = nonGroupDhikrs.isEmpty ? null : nonGroupDhikrs;
        return Result.ok(null);
      case Error():
        _log.severe('Failed to fetch dhikrs: ${result.asError.error}');
        _dhikrs.value = null;
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _deleteGroup(List<String> groupIds) async {
    final result = await _dhikrUseCase.deleteGroup(groupIds: groupIds);
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.asError.error);
    }
  }
}
