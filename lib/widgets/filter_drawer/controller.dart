import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';

class FilterNotifier extends FamilyNotifier<FilterVM, int> {
  @override
  FilterVM build(int arg) {
    return FilterVM();
  }

  void change(bool operation, dynamic filterType) {
    Set<dynamic> filters = {...state.filters};
    Set<dynamic> cache = {...state.cacheFilters};
    if (operation) {
      cache.add(filterType);
    } else {
      filters.remove(filterType);
      cache.remove(filterType);
    }

    state = state.copyWith(
      filters: filters,
      cacheFilters: cache,
    );
  }

  void clear() {
    state = state.copyWith(
      cacheFilters: {},
      filters: {},
    );
  }

  void clearCache() {
    state = state.copyWith(
      cacheFilters: {},
    );
  }

  void confirm() {
    // 当 shouldFilt 为true，则为点击确定触发，执行过滤操作，并合并filters和cacheFilters
    // 否则为点击空白位置触发，重置过滤器

    Set<dynamic> filters = {...state.filters};
    filters.addAll(state.cacheFilters);

    state = state.copyWith(
      cacheFilters: {},
      filters: filters,
    );
  }
}

final fProvider =
    NotifierProviderFamily<FilterNotifier, FilterVM, int>(FilterNotifier.new);
