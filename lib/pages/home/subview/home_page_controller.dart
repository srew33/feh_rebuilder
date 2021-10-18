import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/global/enum/move_type.dart';
import 'package:feh_rebuilder/global/enum/series.dart';
import 'package:feh_rebuilder/global/enum/sort_key.dart';
import 'package:feh_rebuilder/global/enum/stats.dart';
import 'package:feh_rebuilder/global/enum/weapon_type.dart';
import 'package:feh_rebuilder/global/filterChain/filter_chain.dart';
import 'package:feh_rebuilder/global/filters/person.dart';
import 'package:feh_rebuilder/models/move_type/move_type.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/weapon_type/weapon_type.dart';
import 'package:feh_rebuilder/pages/home/widgets/jumpable_listview.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  HomePageController();
  DataService data = Get.find<DataService>();

  ///所有人物数据，初始化时生成并一直保留
  List<Person> all = [];

  ///过滤后的列表
  List<Person> filtered = [];

  ///分组列表，实际起作用的列表
  Map<String, List<Person>> grouped = {};

  ///移动类型和武器类型的列表，用来给drawer图标排序，在初始化时加载
  List<MoveType> moveType = [];
  List<WeaponType> weaponType = [];

  /// 当前排序，默认是roman
  SortKey currentSortKey = SortKey.roman;

  ///主页的listview，用来控制刷新数据
  JumpListScrollController sc = JumpListScrollController();

  ///主页的过滤链
  FilterChain<Person, PersonFilterType> filterChain = FilterChain();

  List<PersonFilter> get chainFilters {
    List<PersonFilter> r = [];
    Set<MoveTypeEnum> _move = {};
    Set<WeaponTypeEnum> _weapon = {};
    Set<SeriesEnum> _series = {};
    for (var item in selectedFilter) {
      switch (item.runtimeType) {
        case PersonFilterType:
          r.add(PersonFilter(filterType: item, valid: true));
          break;
        case MoveTypeEnum:
          _move.add(item);
          break;
        case WeaponTypeEnum:
          _weapon.add(item);
          break;
        case SeriesEnum:
          _series.add(item);
          break;
        default:
          break;
      }
    }
    if (_move.isNotEmpty) {
      r.add(PersonFilter(filterType: PersonFilterType.moveType, valid: _move));
    }
    if (_weapon.isNotEmpty) {
      r.add(PersonFilter(
          filterType: PersonFilterType.weaponType, valid: _weapon));
    }
    if (_series.isNotEmpty) {
      r.add(PersonFilter(filterType: PersonFilterType.series, valid: _series));
    }
    return r;
  }

  final selectedFilter = RxSet();
  final cacheSelectedFilter = RxSet();

  bool isSelected(dynamic val) {
    return selectedFilter.contains(val) || cacheSelectedFilter.contains(val)
        ? true
        : false;
  }

  ///是否确定执行过滤的flag，false的话关闭drawer不会执行
  bool doFilterFlag = false;

  void doFilter() {
    // 过滤链合并
    selectedFilter.addAll(cacheSelectedFilter);

    //生成过滤链，执行过滤和排序
    filterChain.input = all;
    filterChain.filters = chainFilters;
    filtered = filterChain.output;

    sortBy(
      filtered,
      currentSortKey,
    );

    if (grouped.isNotEmpty) {
      sc.setData(grouped);
      // listKey.currentState!.setData(grouped);
    } else {
      // listKey.currentState!.setData({"": <Person>[]});
      // sc.setData({"": <Person>[]});
      sc.setData(<String, List<Person>>{});
    }

    //清空缓存
    cacheSelectedFilter.clear();
    doFilterFlag = false;
  }

  void changeSortKey(SortKey newKey) {
    currentSortKey = newKey;

    sortBy(filtered, newKey);

    // listKey.currentState!.setData(grouped);
    sc.setData(grouped);
  }

  /// 排序，将grouped修改为排序后的数据
  void sortBy(List<Person> source, SortKey key) {
    List<Person> _all = [...source];
    switch (key) {
      case SortKey.bst:
        // listKey.currentState!.showHeader = true;
        _sortedByBst(_all);
        // 可以使用下面方法计算边界
        // int min = personList.first.bst;
        // int max = personList.last.bst;
        // int start = min - min % 5;
        // int last = (5 - max % 5) + max;
        grouped.clear();
        for (var person in _all) {
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
        _sortedByStats(_all, StatsEnum.All);

        grouped.clear();
        for (var person in _all) {
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
        _sortedByStats(_all, StatsEnum.HP);
        grouped.clear();
        int start = 0;
        int range = (_all.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped.addAll({(100 - i * 10).toString(): _all.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString(): _all.sublist(start, start + range)
                });
          start += range;
        }
        break;
      case SortKey.atk:
        _sortedByStats(_all, StatsEnum.ATK);
        grouped.clear();
        int start = 0;
        int range = (_all.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped.addAll({(100 - i * 10).toString(): _all.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString(): _all.sublist(start, start + range)
                });
          start += range;
        }
        break;
      case SortKey.spd:
        _sortedByStats(_all, StatsEnum.SPD);
        grouped.clear();
        int start = 0;
        int range = (_all.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped.addAll({(100 - i * 10).toString(): _all.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString(): _all.sublist(start, start + range)
                });
          start += range;
        }
        break;
      case SortKey.def:
        _sortedByStats(_all, StatsEnum.DEF);
        grouped.clear();
        int start = 0;
        int range = (_all.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped.addAll({(100 - i * 10).toString(): _all.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString(): _all.sublist(start, start + range)
                });
          start += range;
        }
        break;
      case SortKey.res:
        _sortedByStats(_all, StatsEnum.RES);
        grouped.clear();
        int start = 0;
        int range = (_all.length / 10).truncate();
        for (int i = 0; i < 10; i++) {
          i == 9
              ? grouped.addAll({(100 - i * 10).toString(): _all.sublist(start)})
              : grouped.addAll({
                  (100 - i * 10).toString(): _all.sublist(start, start + range)
                });
          start += range;
        }
        break;

      case SortKey.roman:
        // listKey.currentState?.showHeader = true;

        _sortByRoman(_all);
        grouped.clear();
        for (var person in _all) {
          if (!grouped.containsKey(person.roman![0])) {
            grouped.addAll({
              person.roman![0]: [person]
            });
          } else {
            grouped[person.roman![0]]!.add(person);
          }
        }
        break;
    }
  }

  void _sortByRoman(List<Person> personList) {
    personList.sort((Person p1, Person p2) {
      // 比较罗马名,不包含下划线后的内容
      String nameP1 = p1.roman!.split("_")[0];
      String nameP2 = p2.roman!.split("_")[0];
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
      case StatsEnum.All:
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

  @override
  void onInit() {
    moveType = [
      for (Map<String, dynamic> _
          in (data.moveBox.getValues() as Iterable<dynamic>)
              .cast<Map<String, dynamic>>())
        MoveType.fromJson(_)
    ];
    weaponType = [
      for (Map<String, dynamic> _
          in (data.weaponBox.getValues() as Iterable<dynamic>)
              .cast<Map<String, dynamic>>())
        WeaponType.fromJson(_)
    ];

    (data.personBox.getValues() as Iterable<dynamic>)
        .cast<Map<String, dynamic>>()
        .forEach((element) {
      all.add(Person.fromJson(element));
    });

    filtered = [...all];

    sortBy(filtered, currentSortKey);

    super.onInit();
  }
}
