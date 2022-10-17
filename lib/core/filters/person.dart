import 'package:feh_rebuilder/core/enum/game_version.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/series.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/models/person/person.dart';

import 'filter.dart';

enum PersonFilterType {
  isRefersher,
  isResplendent,
  // 比翼
  isDuo,
  // 双界
  isHarmonic,
  // 传承
  isLegend,
  // 神阶
  isMythic,
  // 开花英雄
  isAscendant,
  // 魔器英雄
  isRearmed,

  moveType,
  weaponType,
  series,
  recentlyUpdated,
  gameVersion,
}

class PersonFilter implements Filter<Person, PersonFilterType> {
  @override
  List<Person> input = [];

  @override
  PersonFilterType filterType;

  dynamic valid;

  //   1: "火",
  //   2: "水",
  //   3: "风",
  //   4: "地",
  //   5: "光",
  //   6: "暗",
  //   7: "天",
  //   8: "理",
  final List<int> _legendaryKind = const [1, 2, 3, 4];
  final List<int> _mythicKind = const [5, 6, 7, 8];

  PersonFilter({required this.filterType, required this.valid});

  @override
  List<Person> get output {
    List<Person> result = [];

    for (Person t in input) {
      if (filtFunc(t)) {
        result.add(t);
      }
    }

    return result;
  }

  @override
  bool filtFunc(person) {
    switch (filterType) {
      case PersonFilterType.isRefersher:
        return person.refresher!;
      case PersonFilterType.isResplendent:
        return person.resplendentHero!;
      case PersonFilterType.moveType:
        return (valid as Set<MoveTypeEnum>)
            .contains(MoveTypeEnum.values[person.moveType!]);
      case PersonFilterType.weaponType:
        return (valid as Set<WeaponTypeEnum>)
            .contains(WeaponTypeEnum.values[person.weaponType!]);
      case PersonFilterType.series:
        // origins数值二进制化，为和SeriesEnum的index对应，把高位和地位对换
        List<String> validator = person.origins!
            .toRadixString(2)
            .padLeft(SeriesEnum.values.length, "0")
            .split("")
            .reversed
            .toList();
        return (valid as Set<SeriesEnum>)
            .any((element) => validator[element.index] == "1");
      case PersonFilterType.isDuo:
        return person.legendary?.kind == 2;
      case PersonFilterType.isMythic:
        return person.legendary?.kind == 1 &&
            _mythicKind.contains(person.legendary?.element);
      case PersonFilterType.isHarmonic:
        return person.legendary?.kind == 3;
      case PersonFilterType.isLegend:
        return person.legendary?.kind == 1 &&
            _legendaryKind.contains(person.legendary?.element);
      case PersonFilterType.isAscendant:
        return person.legendary?.kind == 4;
      case PersonFilterType.isRearmed:
        return person.legendary?.kind == 5;
      case PersonFilterType.recentlyUpdated:
        return person.recentlyUpdate;
      case PersonFilterType.gameVersion:
        Set<int> valid1 =
            (valid as Set<GameVersionEnum>).map((e) => e.index + 1).toSet();
        return valid1.contains((person.versionNum! / 100).floor());
      default:
        throw "错误的过滤类型";
    }
  }

  @override
  String toString() {
    return filterType.toString();
  }
}
