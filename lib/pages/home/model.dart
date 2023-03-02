import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/sort_key.dart';
import 'package:feh_rebuilder/models/person/person.dart';

class HomeState extends Equatable {
  // ignore: non_constant_identifier_names
  static HomeState DEFAULT = const HomeState(
    sortKey: SortKey.translations,
    all: [],
    filtered: [],
  );

  /// 排序关键字
  final SortKey sortKey;

  /// 所有人物模型的列表，加载后不变
  final List<Person> all;

  /// 过滤后的人物模型列表，由[all]根据过滤器来生成，用于处理排序，可变
  final List<Person> filtered;

  const HomeState({
    required this.sortKey,
    required this.all,
    required this.filtered,
  });

  HomeState copyWith({
    SortKey? sortKey,
    List<Person>? filtered,
  }) {
    return HomeState(
      sortKey: sortKey ?? this.sortKey,
      all: all,
      filtered: filtered ?? this.filtered,
    );
  }

  @override
  List<Object> get props => [
        sortKey,
        all,
        filtered,
      ];
}
