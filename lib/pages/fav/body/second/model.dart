import 'package:equatable/equatable.dart';

import '../first/model.dart';

class FavSecondState extends Equatable {
  /// 所有的收藏数据，可以通过refresh方法更新
  final List<FavSecondItemModel> all;

  /// 通过过滤后的收藏数据
  final List<FavSecondItemModel> filtered;

  const FavSecondState({
    required this.all,
    required this.filtered,
  });

  FavSecondState copyWith({
    List<FavSecondItemModel>? all,
    List<FavSecondItemModel>? filtered,
  }) {
    return FavSecondState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
    );
  }

  @override
  List<Object?> get props => [all, filtered];
}

class FavSecondItemModel {
  final String key;
  final List<PersonBuildVM?> data;

  FavSecondItemModel(this.key, this.data);
}
