import 'package:feh_tool/global/enum/moveType.dart';
import 'package:feh_tool/global/enum/weaponType.dart';
import 'package:feh_tool/models/skill/skill.dart';

import 'filter.dart';

enum SkillFilterType {
  moveType,
  weaponType,
  category,
  showExclusive,
  showEnemyOnly,
  isRegular,
  isRefinedSkill,
  weaponEffect,
  moveEffect,
}

class SkillFilter implements Filter<Skill, SkillFilterType> {
  List<Skill> input = [];

  ///category:set<int> 0-6 0,武器 1，辅助  2，奥义 3，A 4，B 5，C 6，圣印（技能里没有的圣印）
  SkillFilterType filterType;
  dynamic valid;

  /// 去掉的idnum
  final _ignoreIds = const [
    143,
    144,
    145,
    146,
    195,
    196,
    197,
    198,
    235,
    238,
    241,
    244
  ];
  SkillFilter({required this.filterType, required this.valid});

  @override
  List<Skill> get output {
    List<Skill> output = [];

    for (Skill t in input) {
      if (filtFunc(t)) {
        output.add(t);
      }
    }

    return output;
  }

  @override
  bool filtFunc(Skill skill) {
    switch (filterType) {
      case SkillFilterType.moveType:
        return _filterMove(skill, valid as Set<MoveTypeEnum>);
      case SkillFilterType.weaponType:
        return _filterWeapon(skill, valid as Set<WeaponTypeEnum>);
      case SkillFilterType.category:
        return (valid as Set<int>).contains(skill.category);
      case SkillFilterType.showExclusive:
        return (valid as bool) ? true : !skill.exclusive!;
      case SkillFilterType.showEnemyOnly:
        return (valid as bool) ? true : !skill.enemyOnly!;
      case SkillFilterType.moveEffect:
        return _filterMove(skill, valid as Set<MoveTypeEnum>);
      case SkillFilterType.weaponEffect:
        return _filterWeapon(skill, valid as Set<WeaponTypeEnum>);

      case SkillFilterType.isRegular:
        return (valid as bool)
            ? // 祝福
            skill.category == 15 ||
                // 奥义跃动
                skill.idNum == 470 ||
                (skill.nextSkill == null &&
                    skill.passiveNext == null &&
                    skill.spCost! >= 120 &&
                    skill.maxLv == 0 &&
                    skill.score! >= 4 &&
                    !_ignoreIds.contains(skill.idNum))
            : true;
      case SkillFilterType.isRefinedSkill:
        return (valid as bool)
            ? skill.refined! && skill.refineSortId == 1
            : true;
      default:
        throw "错误的过滤类型";
    }
  }

  bool _filterMove(Skill skill, Set<MoveTypeEnum> valid) {
    // e.g skill.movEquip=8(b1000) validator=[0,0,0,1]
    List<String> validator = skill.movEquip!
        .toRadixString(2)
        .padLeft(4, "0")
        .split("")
        .reversed
        .toList();

    Set<int> _ = {};
    valid.forEach((element) {
      _.addAll(element.value);
    });

    // 存在element，使得validator[element]==0，则不匹配
    if (_.any((element) => validator[element] == "0")) {
      return false;
    }
    return true;
  }

  bool _filterWeapon(Skill skill, Set<WeaponTypeEnum> valid) {
    // e.g skill.wepEquip=8(b1000) validator=[0,0,0,1]
    List<String> validator = skill.wepEquip!
        .toRadixString(2)
        .padLeft(24, "0")
        .split("")
        .reversed
        .toList();

    Set<int> _ = {};
    valid.forEach((element) {
      _.addAll(element.value);
    });

    // 存在int element，使得validator[element]==0，则不匹配
    if (_.any((element) => validator[element] == "0")) {
      return false;
    }
    return true;
  }

  @override
  String toString() {
    return "$filterType  ${valid.toString()}";
  }
}
