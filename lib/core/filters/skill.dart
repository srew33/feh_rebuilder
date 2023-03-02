import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/models/base/skill_base.dart';
import 'package:flutter/foundation.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';

import 'filter.dart';

enum SkillFilterType {
  ///  移动类型 valid: Set[MoveTypeEnum]
  moveType,

  /// 武器类型 valid: Set[WeaponTypeEnum]
  weaponType,

  /// 技能类型 valid: Set[int]
  category,

  /// 不显示专属技能 valid:null
  noExclusive,

  /// 不显示敌方专属技能 valid: null
  noEnemyOnly,

  /// 显示常用技能 valid: null
  isRegular,

  /// 显示锻造后的武器 valid: null
  isRefinedSkill,

  /// 对武器特效 valid: Set[WeaponTypeEnum]
  weaponEffect,

  /// 对移动类型特效 valid: Set[MoveTypeEnum]
  moveEffect,
}

class SkillFilter implements Filter<BaseSkill, SkillFilterType, Skill> {
  @override
  List<BaseSkill> input = [];

  @override
  SkillFilterType filterType;
  Set? valid;

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
  SkillFilter({required this.filterType, this.valid});

  @override
  List<BaseSkill> get output {
    List<BaseSkill> output = [];

    for (BaseSkill t in input) {
      if (filtFunc(t.skill)) {
        output.add(t);
      }
    }

    return output;
  }

  @override
  bool filtFunc(Skill skill) {
    switch (filterType) {
      case SkillFilterType.moveType:
        return _filterMove(skill, Set<MoveTypeEnum>.from(valid!));
      case SkillFilterType.weaponType:
        return _filterWeapon(skill, Set<WeaponTypeEnum>.from(valid!));
      case SkillFilterType.category:
        return (valid as Set<int>).contains(skill.category);
      case SkillFilterType.noExclusive:
        return !skill.exclusive!;
      case SkillFilterType.noEnemyOnly:
        return !skill.enemyOnly!;
      case SkillFilterType.moveEffect:
        return _filterMove(skill, Set<MoveTypeEnum>.from(valid!));
      case SkillFilterType.weaponEffect:
        return _filterWeapon(skill, Set<WeaponTypeEnum>.from(valid!));

      case SkillFilterType.isRegular:
        return
            // 祝福
            skill.category == 15 ||
                // 奥义跃动
                skill.idNum == 470 ||
                (skill.nextSkill == null &&
                    skill.passiveNext == null &&
                    skill.spCost! >= 120 &&
                    skill.maxLv == 0 &&
                    skill.score! >= 4 &&
                    !_ignoreIds.contains(skill.idNum));
      case SkillFilterType.isRefinedSkill:
        return skill.refined! && skill.refineSortId == 1;
      default:
        throw "错误的过滤类型";
    }
  }

  bool _filterMove(Skill skill, Set<MoveTypeEnum> valid) {
    // 应该也可以使用位操作过滤，目前的方式比较好理解，暂时没发现性能问题，先不修改了
    // e.g skill.movEquip=8(b1000) validator=[0,0,0,1]
    List<String> validator = skill.movEquip!
        .toRadixString(2)
        .padLeft(4, "0")
        .split("")
        .reversed
        .toList();

    Set<int> _ = {};
    for (var element in valid) {
      _.addAll(element.value);
    }

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
    for (var element in valid) {
      _.addAll(element.value);
    }

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // print(other is SkillFilter &&
    //     filterType == other.filterType &&
    //     listEquals(other.valid?.toList(), valid?.toList()));
    return other is SkillFilter &&
        filterType == other.filterType &&
        listEquals(other.valid?.toList(), valid?.toList());
  }

  @override
  int get hashCode => input.hashCode ^ valid.hashCode;
}
