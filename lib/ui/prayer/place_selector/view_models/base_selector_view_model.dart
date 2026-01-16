import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';

/// Base class for place selector ViewModels
/// Handles common functionality: search, filtering, and selection
abstract class BaseSelectorViewModel<T extends Object> {
  BaseSelectorViewModel({required String loggerName})
      : _log = Logger(loggerName) {
    // DEFINE LISTENERS
    _searchQuery.addListener(_filterItems);

    // Initial filter
    _filterItems();
  }

  // LOGGER
  @protected
  Logger get log => _log;
  final Logger _log;

  // DOMAIN
  /// Get all items (from repository or local ValueNotifier)
  ValueListenable<List<T>> get items;

  /// Search query for filtering items
  ValueNotifier<String> get searchQuery => _searchQuery;
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  /// Filtered items based on search query
  ValueListenable<List<T>> get filteredItems => _filteredItems;
  final ValueNotifier<List<T>> _filteredItems = ValueNotifier<List<T>>([]);

  /// Selected item ID
  ValueNotifier<String?> get selectedId => _selectedId;
  final ValueNotifier<String?> _selectedId = ValueNotifier<String?>(null);

  // DISPOSE
  void dispose() {
    _searchQuery.removeListener(_filterItems);
    _searchQuery.dispose();
    _filteredItems.dispose();
    _selectedId.dispose();
    log.fine('${log.name} Disposed');
  }

  // FUNCTIONS

  /// Filter items based on search query
  /// Protected method that can be called from child classes
  @protected
  void filterItems() {
    final query = _searchQuery.value.toLowerCase().trim();
    final allItems = items.value;

    if (query.isEmpty) {
      _filteredItems.value = allItems;
    } else {
      _filteredItems.value = allItems
          .where((item) => _getItemName(item).toLowerCase().startsWith(query))
          .toList();
    }

    log.fine(
      'Filtered ${_filteredItems.value.length} items with query: "$query"',
    );
  }

  /// Internal filter method (called by listener)
  void _filterItems() => filterItems();

  /// Get item name for filtering (must be implemented by subclasses)
  String _getItemName(T item) {
    // Use dynamic to access name property
    return (item as dynamic).name as String;
  }

  /// Select an item by ID
  Future<Result<void>> selectItem(String itemId) async {
    _selectedId.value = itemId;
    log.fine('Item selected: $itemId');
    return Result.ok(null);
  }

  /// Reset selection
  void resetSelection() {
    _selectedId.value = null;
    _searchQuery.value = '';
  }
}
