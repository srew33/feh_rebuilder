// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';

class CheckResult {
  bool result;
  String msg;
  CheckResult({
    required this.result,
    this.msg = "",
  });
}

abstract class BuilderCheckerPolicy {
  CheckResult check(Person person, List<Skill?> skills);
}

/// 传承英雄不能设置祝福
class BuilderChecker1 implements BuilderCheckerPolicy {
  @override
  CheckResult check(Person person, List<Skill?> skills) {
    if (person.legendary?.kind == 1 &&
        (person.legendary?.element ?? 0) <= 4 &&
        (person.legendary?.element ?? 0) >= 1) {
      if (skills.length >= 8 && skills[7] != null) {
        return CheckResult(result: false, msg: "传承英雄不能设置祝福");
      }
    }
    return CheckResult(result: true);
  }
}

/// 非魔器英雄不能同时装备魔器技能和专有技能
class BuilderChecker2 implements BuilderCheckerPolicy {
  @override
  CheckResult check(Person person, List<Skill?> skills) {
    // 第九位技能是英雄的专有技能，部分追加专武的角色会因此造成问题，这里手动取前八位
    var s = skills.sublist(0, 8);
    // 非魔器英雄 且 技能列表中存在魔器技能
    if (person.legendary?.kind != 5 &&
        s.any((skill) => skill?.arcaneWeapon == true)) {
      // 如果有除SID_歌う SID_踊る外的专有技能
      if (s.any((skill) =>
          (skill?.exclusive ?? false) &&
          !["SID_歌う", "SID_踊る", "SID_奏でる"].contains(skill?.idTag))) {
        return CheckResult(result: false, msg: "非魔器英雄不能同时装备魔器技能和专有技能");
      }
    }

    return CheckResult(result: true);
  }
}
