import 'package:feh_rebuilder/core/enum/game_version.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/series.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/models/base/person_base.dart';
import 'package:feh_rebuilder/models/person/person.dart';

import 'filter.dart';

const List<int> _legendaryKind = [1, 2, 3, 4];
const List<int> _mythicKind = [5, 6, 7, 8];

enum PersonTypeEnum {
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
}

extension PersonTypeEnumFunc on PersonTypeEnum {
  bool Function(BasePerson person) get check {
    switch (this) {
      case PersonTypeEnum.isRefersher:
        return (BasePerson basePerson) => basePerson.person.refresher!;
      case PersonTypeEnum.isResplendent:
        return (BasePerson basePerson) => basePerson.person.resplendentHero!;
      case PersonTypeEnum.isDuo:
        return (BasePerson basePerson) =>
            basePerson.person.legendary?.kind == 2;
      case PersonTypeEnum.isMythic:
        return (BasePerson basePerson) =>
            basePerson.person.legendary?.kind == 1 &&
            _mythicKind.contains(basePerson.person.legendary?.element);
      case PersonTypeEnum.isHarmonic:
        return (BasePerson basePerson) =>
            basePerson.person.legendary?.kind == 3;
      case PersonTypeEnum.isLegend:
        return (BasePerson basePerson) =>
            basePerson.person.legendary?.kind == 1 &&
            _legendaryKind.contains(basePerson.person.legendary?.element);
      case PersonTypeEnum.isAscendant:
        return (BasePerson basePerson) =>
            basePerson.person.legendary?.kind == 4;
      case PersonTypeEnum.isRearmed:
        return (BasePerson basePerson) =>
            basePerson.person.legendary?.kind == 5;
      default:
        throw UnimplementedError("PersonTypeEnumFunc的$this 没有实现");
    }
  }
}

enum PersonFilterEnum {
  moveType,
  weaponType,
  series,
  recentlyUpdated,
  gameVersion,
  personType,
}

class PersonFilter implements Filter<BasePerson?, PersonFilterEnum, Person> {
  @override
  List<BasePerson?> input = [];

  @override
  PersonFilterEnum filterType;

  dynamic valid;

  //   1: "火",
  //   2: "水",
  //   3: "风",
  //   4: "地",
  //   5: "光",
  //   6: "暗",
  //   7: "天",
  //   8: "理",

  PersonFilter({required this.filterType, required this.valid});

  @override
  List<BasePerson> get output {
    List<BasePerson> result = [];
    // ? null是否应放入？
    for (BasePerson? t in input) {
      if (t == null) {
        // result.add(null);
        continue;
      }

      if (filtFunc(t.person)) {
        result.add(t);
      }
    }

    return result;
  }

  @override
  bool filtFunc(basePerson) {
    switch (filterType) {
      case PersonFilterEnum.personType:
        return _filtPerson(basePerson, valid as Set<PersonTypeEnum>);
      // case PersonFilterEnum.isRefersher:
      //   return basePerson.refresher!;
      // case PersonFilterEnum.isResplendent:
      // return basePerson.resplendentHero!;
      case PersonFilterEnum.moveType:
        return (valid as Set<MoveTypeEnum>)
            .contains(MoveTypeEnum.values[basePerson.moveType!]);
      case PersonFilterEnum.weaponType:
        return (valid as Set<WeaponTypeEnum>)
            .contains(WeaponTypeEnum.values[basePerson.weaponType!]);
      case PersonFilterEnum.series:
        // origins数值二进制化，为和SeriesEnum的index对应，把高位和地位对换
        List<String> validator = basePerson.origins!
            .toRadixString(2)
            .padLeft(SeriesEnum.values.length, "0")
            .split("")
            .reversed
            .toList();
        return (valid as Set<SeriesEnum>)
            .any((element) => validator[element.index] == "1");
      // case PersonFilterEnum.isDuo:
      //   return basePerson.legendary?.kind == 2;
      // case PersonFilterEnum.isMythic:
      //   return basePerson.legendary?.kind == 1 &&
      //       _mythicKind.contains(basePerson.legendary?.element);
      // case PersonFilterEnum.isHarmonic:
      //   return basePerson.legendary?.kind == 3;
      // case PersonFilterEnum.isLegend:
      //   return basePerson.legendary?.kind == 1 &&
      //       _legendaryKind.contains(basePerson.legendary?.element);
      // case PersonFilterEnum.isAscendant:
      //   return basePerson.legendary?.kind == 4;
      // case PersonFilterEnum.isRearmed:
      //   return basePerson.legendary?.kind == 5;
      case PersonFilterEnum.recentlyUpdated:
        return basePerson.recentlyUpdate;
      case PersonFilterEnum.gameVersion:
        Set<int> valid1 =
            (valid as Set<GameVersionEnum>).map((e) => e.index + 1).toSet();
        return valid1.contains((basePerson.versionNum! / 100).floor());
      default:
        throw "错误的过滤类型";
    }
  }

  bool _filtPerson(BasePerson person, Set<PersonTypeEnum> valid) {
    return valid.fold(
        false,
        (previousValue, personType) =>
            previousValue || personType.check(person));
  }

  @override
  String toString() {
    return filterType.toString();
  }
}
