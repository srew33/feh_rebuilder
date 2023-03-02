import 'package:flutter/foundation.dart';

class FilterVM {
  /// 选中图标并且点击确定进行过滤的过滤器
  final Set filters;

  /// 仅点击图标，没有点击确定进行过滤的过滤器
  final Set cacheFilters;

  FilterVM({
    this.filters = const {},
    this.cacheFilters = const {},
  });

  @override
  bool operator ==(covariant FilterVM other) {
    if (identical(this, other)) return true;

    return setEquals(other.filters, filters) &&
        setEquals(other.cacheFilters, cacheFilters);
  }

  @override
  int get hashCode => filters.hashCode ^ cacheFilters.hashCode;

  FilterVM copyWith({
    Set? filters,
    Set? cacheFilters,
    bool? shouldFilt,
  }) {
    return FilterVM(
      filters: filters ?? this.filters,
      cacheFilters: cacheFilters ?? this.cacheFilters,
    );
  }
}
