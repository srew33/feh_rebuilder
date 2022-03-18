part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

/// 首页启动事件
class HomeStarted extends HomeEvent {
  final AppLanguages currentLang;

  const HomeStarted({required this.currentLang});
}

/// 首页排序改变事件
///
/// [newSortKey] 新的排序关键字枚举类,类型是[SortKey]
///
class HomeSortChanged extends HomeEvent {
  /// 新的排序关键字枚举类,类型是[SortKey]
  final SortKey newSortKey;

  /// 当前的locale
  final AppLanguages currentLang;

  const HomeSortChanged(this.newSortKey, this.currentLang);
}

/// 首页过滤器改变事件
///
/// [operation] 操作 添加为TRUE  删除是FALSE null代表清空
///
/// [filterType] 需要添加/删除的过滤器类别
class HomeFilterChanged extends HomeEvent {
  /// 操作 添加为TRUE  删除是FALSE null代表清空
  final bool operation;

  /// 需要添加/删除的过滤器类别
  final dynamic filterType;

  const HomeFilterChanged({
    required this.operation,
    required this.filterType,
  });
}

/// 翻译切换事件，影响首页排序
class HomeLangChanged extends HomeEvent {}

/// 首页过滤器清空事件
class HomeFilterCleared extends HomeEvent {}

/// 首页过滤器确认事件
class HomeFilterConfirmed extends HomeEvent {}

/// 首页过滤器关闭事件，特指点击空白区域关闭
class HomeDrawerClosed extends HomeEvent {}
