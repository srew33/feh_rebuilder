import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/game_version.dart';
import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/core/enum/series.dart';
import 'package:feh_rebuilder/core/enum/sort_key.dart';
import 'package:feh_rebuilder/core/enum/stats.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filterChain/filter_chain.dart';
import 'package:feh_rebuilder/core/filters/person.dart';

import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/widgets/jumpable_listview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.repo})
      : super(
          const HomeState(
            status: StateStatus.initial,
            sortKey: SortKey.translations,
            all: [],
            filtered: [],
            filters: {},
            cacheFilters: {},
            shouldFilt: false,
            // currentLang: AppLanguages.zh,
          ),
        ) {
    on<HomeStarted>(_onStarted);
    on<HomeSortChanged>(_onHomeSortChanged);
    on<HomeFilterChanged>(_onHomeFilterChanged);
    on<HomeFilterCleared>(_onHomeFilterCleared);
    on<HomeFilterConfirmed>(_onHomeFilterConfirmed);
    on<HomeDrawerClosed>(_onHomeDrawerClosed);
    on<HomeLangChanged>(_onHomeLangChanged);
  }

  /// 存储库实例
  Repository repo;

  /// 主页列表的控制器
  final JumpListScrollController controller = JumpListScrollController();

  /// 启动事件
  Future<void> _onStarted(HomeStarted event, Emitter emit) async {
    var all = [...repo.cachePersons.values];

    controller.setData(sortBy(all, SortKey.translations, event.currentLang));

    emit(
      HomeState(
        status: StateStatus.success,
        sortKey: SortKey.translations,
        all: all,
        filtered: [...all],
        filters: const {},
        cacheFilters: const {},
        shouldFilt: false,
      ),
    );
  }

  /// 排序事件响应
  void _onHomeSortChanged(HomeSortChanged event, Emitter emit) {
    controller
        .setData(sortBy(state.filtered, event.newSortKey, event.currentLang));

    emit(state.copyWith(sortKey: event.newSortKey));
  }

  /// 语言切换事件，不需发送新状态
  void _onHomeLangChanged(HomeLangChanged event, Emitter emit) {
    // if (state.sortKey == SortKey.translations) {
    //   controller.setData(sortBy(
    //       state.filtered, SortKey.translations, config.state.dataLanguage));
    // }
  }

  /// 过滤事件响应，代表用户点击过滤器图标，此时仅进行图标选中的显示，还没有开始进行过滤处理
  void _onHomeFilterChanged(HomeFilterChanged event, Emitter emit) {
    Set<dynamic> cache = {...state.cacheFilters};
    if (event.operation) {
      cache.add(event.filterType);
    } else {
      cache.remove(event.filterType);
    }
    emit(
      state.copyWith(
        cacheFilters: cache,
      ),
    );
  }

  /// 清空过滤器事件响应
  void _onHomeFilterCleared(HomeFilterCleared event, Emitter emit) {
    emit(
      state.copyWith(
        filters: {},
        cacheFilters: {},
      ),
    );
  }

  /// 过滤确认事件响应，代表用户点击确定
  void _onHomeFilterConfirmed(HomeFilterConfirmed event, Emitter emit) {
    List<PersonFilter> filters = [];
    Set<MoveTypeEnum> moveValid = {};
    Set<WeaponTypeEnum> weaponValid = {};
    Set<SeriesEnum> seriesValid = {};
    Set<GameVersionEnum> gameVersionValid = {};

    for (var type in state.cacheFilters) {
      switch (type.runtimeType) {
        case MoveTypeEnum:
          moveValid.add(type);
          break;
        case WeaponTypeEnum:
          weaponValid.add(type);
          break;
        case SeriesEnum:
          seriesValid.add(type);
          break;
        case GameVersionEnum:
          gameVersionValid.add(type);
          break;
        default:
          filters.add(PersonFilter(filterType: type, valid: null));
          break;
      }
    }

    if (moveValid.isNotEmpty) {
      filters.add(PersonFilter(
          filterType: PersonFilterType.moveType, valid: moveValid));
    }
    if (weaponValid.isNotEmpty) {
      filters.add(PersonFilter(
          filterType: PersonFilterType.weaponType, valid: weaponValid));
    }
    if (seriesValid.isNotEmpty) {
      filters.add(PersonFilter(
          filterType: PersonFilterType.series, valid: seriesValid));
    }
    if (gameVersionValid.isNotEmpty) {
      filters.add(
        PersonFilter(
          filterType: PersonFilterType.gameVersion,
          valid: gameVersionValid,
        ),
      );
    }
    var chain = FilterChain(input: state.all, filters: filters);

    controller.setData(sortBy(chain.output, state.sortKey));

    emit(
      state.copyWith(
        shouldFilt: true,
        filtered: chain.output,
        filters: {...state.cacheFilters},
      ),
    );
  }

  /// drawer关闭事件响应是重置过滤器状态（未点击确定）还是合并过滤器（点击确定）
  void _onHomeDrawerClosed(HomeDrawerClosed event, Emitter emit) {
    if (state.shouldFilt) {
      // 关闭时，若shouldFilt为true，代表[HomeFilterConfirmed]触发，
      // 因此把shouldFilt重置为false
      emit(
        state.copyWith(
          shouldFilt: false,
        ),
      );
    } else {
      // 关闭时，若shouldFilt为false,代表没有选择确定，因此通过把复制filters为cacheFilters
      // 来重置选择的过滤器
      emit(
        state.copyWith(
          cacheFilters: {...state.filters},
          shouldFilt: false,
        ),
      );
    }
  }

  /// 排序，返回排序后的数据
  Map<String, List<Person>> sortBy(List<Person> source, SortKey key,
      [AppLanguages lang = AppLanguages.zh]) {
    Map<String, List<Person>> grouped = {};
    switch (key) {
      case SortKey.bst:
        // listKey.currentState!.showHeader = true;
        // 对source排序
        _sortedByBst(source);
        // 可以使用下面方法计算边界
        // int min = personList.first.bst;
        // int max = personList.last.bst;
        // int start = min - min % 5;
        // int last = (5 - max % 5) + max;

        for (var person in source) {
          String key = (person.bst - person.bst % 5).toString();
          if (!grouped.containsKey(key)) {
            grouped.addAll({
              key: [person]
            });
          } else {
            grouped[key]!.add(person);
          }
        }
        break;
      case SortKey.stats:
        _sortedByStats(source, StatsEnum.ALL);

        for (var person in source) {
          String key = (person.defaultStats!.sum - person.defaultStats!.sum % 5)
              .toString();
          if (!grouped.containsKey(key)) {
            grouped.addAll({
              key: [person]
            });
          } else {
            grouped[key]!.add(person);
          }
        }
        break;
      case SortKey.hp:
        _sortedByStats(source, StatsEnum.HP);

        int start = 0;
        int range = (source.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped
                  .addAll({(100 - i * 10).toString(): source.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString():
                      source.sublist(start, start + range)
                });
          start += range;
        }
        break;
      case SortKey.atk:
        _sortedByStats(source, StatsEnum.ATK);

        int start = 0;
        int range = (source.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped
                  .addAll({(100 - i * 10).toString(): source.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString():
                      source.sublist(start, start + range)
                });
          start += range;
        }
        break;
      case SortKey.spd:
        _sortedByStats(source, StatsEnum.SPD);

        int start = 0;
        int range = (source.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped
                  .addAll({(100 - i * 10).toString(): source.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString():
                      source.sublist(start, start + range)
                });
          start += range;
        }
        break;
      case SortKey.def:
        _sortedByStats(source, StatsEnum.DEF);

        int start = 0;
        int range = (source.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped
                  .addAll({(100 - i * 10).toString(): source.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString():
                      source.sublist(start, start + range)
                });
          start += range;
        }
        break;
      case SortKey.res:
        _sortedByStats(source, StatsEnum.RES);

        int start = 0;
        int range = (source.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped
                  .addAll({(100 - i * 10).toString(): source.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString():
                      source.sublist(start, start + range)
                });
          start += range;
        }
        break;

      case SortKey.translations:

        // 华为的机器读取当前的locale似乎会和其他机器不一样，这里直接传值

        String localeStr = lang.locale.toString();

        _sortByTranslations(source, localeStr);

        for (var person in source) {
          String translatedNames =
              person.translatedNames[localeStr] ?? person.roman!;
          if (!grouped.containsKey(translatedNames[0].toUpperCase())) {
            grouped.addAll({
              translatedNames[0].toUpperCase(): [person]
            });
          } else {
            grouped[translatedNames[0].toUpperCase()]!.add(person);
          }
        }
        break;
      case SortKey.versionNum:
        _sortedByVersion(source);
        for (var person in source) {
          String key = (person.versionNum! / 100).floor().toString();
          if (!grouped.containsKey(key)) {
            grouped.addAll({
              key: [person]
            });
          } else {
            grouped[key]!.add(person);
          }
        }
        break;
    }
    return grouped;
  }

  void _sortByTranslations(List<Person> personList, String localeStr) {
    personList.sort((Person p1, Person p2) {
      // 比较罗马名,不包含下划线后的内容

      String nameP1 = p1.translatedNames[localeStr] ?? p1.roman!.split("_")[0];
      String nameP2 = p2.translatedNames[localeStr] ?? p2.roman!.split("_")[0];
      int r = nameP1.compareTo(nameP2);
      if (r != 0) {
        return r;
      }
      // 如果 B的名字包含A的全名，比较series
      // 如果series仍然相等，比较idnum大小
      if (p1.series!.compareTo(p2.series!) != 0) {
        return p1.series!.compareTo(p2.series!);
      } else {
        return p1.idNum!.compareTo(p2.idNum!);
      }
    });
    // return personList;
  }

  ///5点白值一段
  void _sortedByBst(List<Person> personList) {
    personList.sort((Person p1, Person p2) {
      return p2.bst.compareTo(p1.bst);
    });
  }

  void _sortedByStats(List<Person> personList, StatsEnum key) {
    switch (key) {
      case StatsEnum.ALL:
        personList.sort((Person p1, Person p2) {
          return p2.defaultStats!.sum.compareTo(p1.defaultStats!.sum);
        });
        break;
      case StatsEnum.HP:
        personList.sort((Person p1, Person p2) {
          return p2.defaultStats!.hp.compareTo(p1.defaultStats!.hp) != 0
              ? p2.defaultStats!.hp.compareTo(p1.defaultStats!.hp)
              : p2.defaultStats!.sum.compareTo(p1.defaultStats!.sum);
        });
        break;
      case StatsEnum.ATK:
        personList.sort((Person p1, Person p2) {
          return p2.defaultStats!.atk.compareTo(p1.defaultStats!.atk) != 0
              ? p2.defaultStats!.atk.compareTo(p1.defaultStats!.atk)
              : p2.defaultStats!.sum.compareTo(p1.defaultStats!.sum);
        });
        break;
      case StatsEnum.SPD:
        personList.sort((Person p1, Person p2) {
          return p2.defaultStats!.spd.compareTo(p1.defaultStats!.spd) != 0
              ? p2.defaultStats!.spd.compareTo(p1.defaultStats!.spd)
              : p2.defaultStats!.sum.compareTo(p1.defaultStats!.sum);
        });
        break;
      case StatsEnum.DEF:
        personList.sort((Person p1, Person p2) {
          return p2.defaultStats!.def.compareTo(p1.defaultStats!.def) != 0
              ? p2.defaultStats!.def.compareTo(p1.defaultStats!.def)
              : p2.defaultStats!.sum.compareTo(p1.defaultStats!.sum);
        });
        break;
      case StatsEnum.RES:
        personList.sort((Person p1, Person p2) {
          return p2.defaultStats!.res.compareTo(p1.defaultStats!.res) != 0
              ? p2.defaultStats!.res.compareTo(p1.defaultStats!.res)
              : p2.defaultStats!.sum.compareTo(p1.defaultStats!.sum);
        });
        break;
    }
  }

  /// 按游戏版本排序，相同时使用idnum比较
  void _sortedByVersion(List<Person> personList) {
    personList.sort((Person p1, Person p2) {
      return p2.versionNum!.compareTo(p1.versionNum!) != 0
          ? p2.versionNum!.compareTo(p1.versionNum!)
          : p2.idNum!.compareTo(p1.idNum!);
    });
  }
}
