import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/ui/prayer/place_selector/view_models/base_selector_view_model.dart';

/// Minimal item with the `name` property the base class filters on.
class _Named {
  const _Named(this.id, this.name);
  final String id;
  final String name;

  @override
  String toString() => '_Named($id, $name)';
}

class _TestSelectorViewModel extends BaseSelectorViewModel<_Named> {
  _TestSelectorViewModel() : super(loggerName: 'TestSelectorViewModel') {
    _items.addListener(filterItems);
  }

  final ValueNotifier<List<_Named>> _items = ValueNotifier<List<_Named>>([]);

  @override
  ValueListenable<List<_Named>> get items => _items;

  void setItems(List<_Named> value) => _items.value = value;

  @override
  void dispose() {
    _items.removeListener(filterItems);
    _items.dispose();
    super.dispose();
  }
}

void main() {
  const istanbul = _Named('34', 'İstanbul');
  const izmir = _Named('35', 'İzmir');
  const ankara = _Named('06', 'Ankara');
  const all = [istanbul, izmir, ankara];

  late _TestSelectorViewModel viewModel;

  setUp(() {
    viewModel = _TestSelectorViewModel();
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('starts with an empty query, no selection and an empty filtered list', () {
    expect(viewModel.searchQuery.value, '');
    expect(viewModel.selectedId.value, isNull);
    expect(viewModel.filteredItems.value, isEmpty);
  });

  group('filtering', () {
    test('exposes every item when the query is empty', () {
      viewModel.setItems(all);

      expect(viewModel.filteredItems.value, all);
    });

    test('matches on a case-insensitive prefix of the name', () {
      viewModel.setItems(all);

      viewModel.searchQuery.value = 'İz';

      expect(viewModel.filteredItems.value, [izmir]);
    });

    test('trims surrounding whitespace from the query', () {
      viewModel.setItems(all);

      viewModel.searchQuery.value = '  an  ';

      expect(viewModel.filteredItems.value, [ankara]);
    });

    test('does not match substrings that are not prefixes', () {
      viewModel.setItems(all);

      viewModel.searchQuery.value = 'kara';

      expect(viewModel.filteredItems.value, isEmpty);
    });

    test('re-filters when the underlying items change', () {
      viewModel.searchQuery.value = 'i';
      expect(viewModel.filteredItems.value, isEmpty);

      viewModel.setItems(all);

      expect(viewModel.filteredItems.value, [istanbul, izmir]);
    });
  });

  group('selection', () {
    test('selectItem stores the id and returns Ok', () async {
      final result = await viewModel.selectItem('35');

      expect(result, isA<Ok<void>>());
      expect(viewModel.selectedId.value, '35');
    });

    test('resetSelection clears the id and the query', () async {
      viewModel.setItems(all);
      await viewModel.selectItem('35');
      viewModel.searchQuery.value = 'İz';

      viewModel.resetSelection();

      expect(viewModel.selectedId.value, isNull);
      expect(viewModel.searchQuery.value, '');
      expect(viewModel.filteredItems.value, all);
    });
  });
}
