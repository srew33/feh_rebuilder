import 'package:feh_rebuilder/core/enum/game_version.dart';
import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/series.dart';
import 'package:feh_rebuilder/core/enum/sort_key.dart';
import 'package:feh_rebuilder/core/enum/stats.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filterChain/filter_chain.dart';
import 'package:feh_rebuilder/core/filters/person.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/widgets/jumpable_listview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState.DEFAULT;
  }

  JumpListScrollController controller = JumpListScrollController();

  // 这里可以完全使用同步操作从build方法返回，
  // 使用future是因为有需要从数据库读取的操作，现在通过一些手段转换成了同步，
  // 但以后修改的可能性比较大
  /// 初始化事件
  Future<void> initial(AppLanguages initialLang) async {
    var all = (await ref.read(repoProvider).requireValue.person.getAll())
        .values
        .toList();

    controller.setData(_sortBy(all, SortKey.translations, initialLang));

    state = HomeState(
      sortKey: SortKey.translations,
      all: all,
      filtered: [...all],
    );
  }

  void sortBy(SortKey newSortKey, AppLanguages currentLang) {
    controller.setData(_sortBy(state.filtered, newSortKey, currentLang));

    state = state.copyWith(sortKey: newSortKey);
  }

  void confirmFilter(Set filters) {
    List<PersonFilter> personFilters = [];
    Set<MoveTypeEnum> moveValid = {};
    Set<WeaponTypeEnum> weaponValid = {};
    Set<SeriesEnum> seriesValid = {};
    Set<GameVersionEnum> gameVersionValid = {};
    Set<PersonTypeEnum> personTypeValid = {};

    for (var type in filters) {
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
        case PersonTypeEnum:
          personTypeValid.add(type);
          break;
        case PersonFilterEnum:
          // 目前只有“最新”的选项
          personFilters.add(PersonFilter(filterType: type, valid: null));
          break;
        default:
          // personFilters.add(PersonFilter(filterType: type, valid: null));
          break;
      }
    }

    if (moveValid.isNotEmpty) {
      personFilters.add(PersonFilter(
          filterType: PersonFilterEnum.moveType, valid: moveValid));
    }
    if (weaponValid.isNotEmpty) {
      personFilters.add(PersonFilter(
          filterType: PersonFilterEnum.weaponType, valid: weaponValid));
    }
    if (seriesValid.isNotEmpty) {
      personFilters.add(PersonFilter(
          filterType: PersonFilterEnum.series, valid: seriesValid));
    }
    if (gameVersionValid.isNotEmpty) {
      personFilters.add(
        PersonFilter(
          filterType: PersonFilterEnum.gameVersion,
          valid: gameVersionValid,
        ),
      );
    }
    if (personTypeValid.isNotEmpty) {
      personFilters.add(
        PersonFilter(
          filterType: PersonFilterEnum.personType,
          valid: personTypeValid,
        ),
      );
    }
    var chain = FilterChain(input: state.all, filters: personFilters);

    List<Person> filtered = [for (var e in chain.output) e!.person];

    controller.setData(_sortBy(filtered, state.sortKey));

    state = state.copyWith(filtered: filtered);
  }
}

final homeProvider =
    NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

/// 排序，返回排序后的数据
Map<String, List<Person>> _sortBy(List<Person> source, SortKey key,
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
            ? grouped.addAll({(100 - i * 10).toString(): source.sublist(start)})
            : grouped.addAll({
                (100 - i * 10).toString(): source.sublist(start, start + range)
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
            ? grouped.addAll({(100 - i * 10).toString(): source.sublist(start)})
            : grouped.addAll({
                (100 - i * 10).toString(): source.sublist(start, start + range)
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
            ? grouped.addAll({(100 - i * 10).toString(): source.sublist(start)})
            : grouped.addAll({
                (100 - i * 10).toString(): source.sublist(start, start + range)
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
            ? grouped.addAll({(100 - i * 10).toString(): source.sublist(start)})
            : grouped.addAll({
                (100 - i * 10).toString(): source.sublist(start, start + range)
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
            ? grouped.addAll({(100 - i * 10).toString(): source.sublist(start)})
            : grouped.addAll({
                (100 - i * 10).toString(): source.sublist(start, start + range)
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
