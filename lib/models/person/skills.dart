import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:get/get.dart';

class Skills {
  late List<List<String?>> skills;
  static const List<String?> skillsList = [
    "weapon",
    "assist",
    "special",
    null,
    null,
    null,
    "weapon",
    "assist",
    "special",
    "passiveA",
    "passiveB",
    "passiveC",
    null,
    null
  ];

  // String? weapon1;
  // String? assist;
  // String? special;
  // String? passiveA;
  // String? passiveB;
  // String? passiveC;
  // String? weapon2;

  ///传入1到5星技能列表，返回五星时的所有技能
  Skills(this.skills);

  // // 这里不输出高级武器技能
  // Map<String, String?> toMap() {
  //   return {
  //     "weapon": weapon1,
  //     "assist": assist,
  //     "special": special,
  //     "passiveA": passiveA,
  //     "passiveB": passiveB,
  //     "passiveC": passiveC,
  //   };
  // }

  factory Skills.fromJson(List<dynamic> json) {
    return Skills(
        (json).map((e) => (e as List<dynamic>).cast<String?>()).toList());
  }

  List<List<String?>> toJson() {
    return skills;
  }

  /// 比较两个技能上下级关系，如果S1的前置技能有S2则返回S1，否则返回S2，
  Skill? compareSkill(Skill? s1, Skill? s2) {
    if (s1 == null && s2 == null) {
      return null;
    } else if (s1 == null || s2 == null) {
      return s1 ?? s2;
    } else {
      return s1.prerequisites.contains(s2.idTag) ? s1 : s2;
    }
  }

  /// 遍历一到五星技能，返回各技能栏位最高级的技能,0-5是技能，6，7是圣印，祝福，8（专武）
  List<Skill?> getSkills() {
    DataService data = Get.find<DataService>();

    List<Skill?> _skills = [
      null,
      null,
      null,
      null,
      null,
      null,
      null,
    ];

    // ?反正没有一星二星了，从三星遍历好像也可以

    for (List<String?> skillOnRarity in skills) {
      skillOnRarity.asMap().forEach((index, skillTag) {
        if (skillTag != null) {
          Skill newSkill = Skill.fromJson(data.skillBox.read(skillTag));
          if (newSkill.exclusive! && newSkill.category! == 0 && index > 5) {
            // _skills[6] = compareSkill(_skills[6], newSkill);
            _skills[6] = newSkill;
          } else {
            if (_skills[newSkill.category!] != null) {
              _skills[newSkill.category!] =
                  compareSkill(_skills[newSkill.category!], newSkill);
            } else {
              _skills[newSkill.category!] = newSkill;
            }
          }
        }
      });
    }

    Utils.debug(_skills);
    _skills.insertAll(6, [null, null]);
    return _skills;
  }
}
