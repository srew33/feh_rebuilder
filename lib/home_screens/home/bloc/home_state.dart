part of 'home_bloc.dart';

class HomeState extends Equatable {
  /// 当前状态
  final StateStatus status;

  /// 排序关键字
  final SortKey sortKey;

  /// 所有人物模型的列表，加载后不变
  final List<Person> all;

  /// 过滤后的人物模型列表，由[all]根据过滤器来生成，用于处理排序，可变
  final List<Person> filtered;

  /// 选中图标并且点击确定进行过滤的过滤器
  final Set filters;

  /// 仅点击图标，没有点击确定进行过滤的过滤器
  final Set cacheFilters;

  /// 是否应进行过滤
  final bool shouldFilt;

  /// 当前选择的语言
  // final AppLanguages currentLang;

  const HomeState({
    required this.status,
    required this.sortKey,
    required this.all,
    required this.filtered,
    required this.filters,
    required this.cacheFilters,
    required this.shouldFilt,
    // required this.currentLang,
  });

  HomeState copyWith({
    StateStatus? status,
    SortKey? sortKey,
    List<Person>? filtered,
    Set? filters,
    Set? cacheFilters,
    bool? shouldFilt,
    AppLanguages? currentLang,
  }) {
    return HomeState(
      status: status ?? this.status,
      sortKey: sortKey ?? this.sortKey,
      all: all,
      filtered: filtered ?? this.filtered,
      cacheFilters: cacheFilters ?? this.cacheFilters,
      filters: filters ?? this.filters,
      shouldFilt: shouldFilt ?? this.shouldFilt,
      // currentLang: currentLang ?? this.currentLang,
    );
  }

  @override
  List<Object> get props => [
        sortKey,
        all,
        filtered,
        filters,
        cacheFilters,
        shouldFilt,
      ];
}

// /// 默认状态
// class HomeInitial extends HomeState {}

// /// 加载成功状态
// class HomePageLoadSucess extends HomeState {
//   /// 排序关键字
//   final SortKey sortKey;

//   /// 所有人物模型的列表，加载后不变
//   final List<Person> all;

//   /// 过滤后的人物模型列表，由[all]根据过滤器来生成，可变
//   final List<Person> filtered;

//   /// 选中图标并且点击确定进行过滤的过滤器
//   final Set filters;

//   /// 仅点击图标，没有点击确定进行过滤的过滤器
//   final Set cacheFilters;

//   /// 是否应进行过滤
//   final bool shouldFilt;

//   const HomePageLoadSucess({
//     required this.sortKey,
//     required this.all,
//     required this.filtered,
//     required this.filters,
//     required this.cacheFilters,
//     required this.shouldFilt,
//   });

//   HomePageLoadSucess copyWith({
//     SortKey? sortKey,
//     List<Person>? filtered,
//     Set? filters,
//     Set? cacheFilters,
//     bool? shouldFilt,
//   }) {
//     return HomePageLoadSucess(
//       sortKey: sortKey ?? this.sortKey,
//       all: all,
//       filtered: filtered ?? this.filtered,
//       cacheFilters: cacheFilters ?? this.cacheFilters,
//       filters: filters ?? this.filters,
//       shouldFilt: shouldFilt ?? this.shouldFilt,
//     );
//   }

//   @override
//   List<Object> get props => [
//         sortKey,
//         all,
//         filtered,
//         filters,
//         cacheFilters,
//         shouldFilt,
//       ];
// }
