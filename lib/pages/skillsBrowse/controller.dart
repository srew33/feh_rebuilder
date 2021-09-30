import 'dart:io';

import 'package:feh_tool/dataService.dart';
import 'package:feh_tool/global/enum/weaponType.dart';
import 'package:feh_tool/global/filterChain/filterChain.dart';
import 'package:feh_tool/global/filters/filter.dart';
import 'package:feh_tool/global/filters/skill.dart';
import 'package:feh_tool/models/skill/skill.dart';
import 'package:feh_tool/utils.dart';
import 'package:get/get.dart';

class SkillsBrowseController extends GetxController {
  SkillsBrowseController();

  SkillChooseConfig config = Get.arguments as SkillChooseConfig;

  late int category;

  ///是否显示技能选择按钮
  late bool selectMode;

  ///锻造前的专有技能的idtag
  late List<String> _exclusiveTags;

  /// 所有专有技能，如果是武器的话包含所有可锻造的武器如atk，spd等
  List<Skill> exclusiveSkills = [];

  DataService data = Get.find<DataService>();

  ///常用技能
  final onlyRegularSkill = true.obs;

  /// 显示专属技能
  final isExclusive = false.obs;

  /// 只显示具有特效的武器锻造
  final onlyRefinedSkill = false.obs;

  ///初始化后的技能列表,只读，代表符合当前类别category的所有技能，
  ///主要作用是减少修改过滤条件时需要过滤的数量
  ///其他过滤项由skills实现
  List<Skill> _skills = [];

  List<Skill> get origSkills => [..._skills];

  ///符合所有过滤项的技能列表
  List<Skill> skills = [];

  late FilterChain<Skill, SkillFilterType> filterChain;

  late Directory currentPath;

  ///专为圣印保留，对圣印分类
  final showAccessory = 3.obs;

  ///专为武器类型保留，对武器分类
  final showWeaponType = 0.obs;

  ///用作给武器类别显示分类的字典
  final List<WeaponTypeEnum> weaponTypeDict = const [
    WeaponTypeEnum.Sword,
    WeaponTypeEnum.Lance,
    WeaponTypeEnum.Axe,
    WeaponTypeEnum.Staff,
    WeaponTypeEnum.AllBow,
    WeaponTypeEnum.AllDagger,
    WeaponTypeEnum.RedTome,
    WeaponTypeEnum.BlueTome,
    WeaponTypeEnum.GreenTome,
    WeaponTypeEnum.ColorlessTome,
    WeaponTypeEnum.AllBreath,
    WeaponTypeEnum.AllBeast,
  ];

  void setFilter(SkillFilterType type, dynamic valid) {
    if (filterChain.filters.any((element) => element.filterType == type)) {
      SkillFilter s = filterChain.filters
          .firstWhere((element) => element.filterType == type) as SkillFilter;
      s.valid = valid;
      Utils.debug(filterChain.filters);
    } else {
      filterChain.filters.add(SkillFilter(filterType: type, valid: valid));
    }
  }

  void filt() {
    List<Skill> _ = filterChain.output;
    Utils.debug(_.length);

    _.sort((a, b) => a.sortId!.compareTo(b.sortId!) != 0
        ? a.sortId!.compareTo(b.sortId!)
        : a.refineSortId!.compareTo(b.refineSortId!));

    _.insertAll(0, exclusiveSkills);
    skills = _;
    update(["list"]);
  }

  void deleteFilter(SkillFilterType type) {
    filterChain.filters.removeWhere((element) => element.filterType == type);
  }

  @override
  void onInit() {
    currentPath = data.appPath;

    category = config.category;
    selectMode = config.selectMode;

    _exclusiveTags = config.exclusiveSkills;

    // 初始化该类别的全部技能
    (data.skillBox.getValues() as Iterable<dynamic>)
        .cast<Map<String, dynamic>>()
        .forEach((element) {
      if (category != 6) {
        if (element["category"] == category) {
          _skills.add(Skill.fromJson(element));
        }
      } else {
        if (element["isSkillAccessory"]) {
          _skills.add(Skill.fromJson(element));
        }
      }
    });

    // 初始化特有技能列表
    // refine_base是为了添加所有锻造的武器（ATK DEF这些锻造id_tag不一样但是refine_base都是原武器的id_tag）
    origSkills.forEach((element) {
      if (_exclusiveTags.contains(element.refineBase) ||
          _exclusiveTags.contains(element.idTag)) {
        exclusiveSkills.add(element);
      }
    });

    exclusiveSkills.sort((a, b) => a.sortId!.compareTo(b.sortId!) != 0
        ? a.sortId!.compareTo(b.sortId!)
        : a.refineSortId!.compareTo(b.refineSortId!));

    filterChain = FilterChain<Skill, SkillFilterType>(
        input: origSkills, filters: config.filters);

    if (category == 0 && !filterChain.contains(SkillFilterType.weaponType)) {
      setFilter(SkillFilterType.weaponType,
          {WeaponTypeEnum.values[showWeaponType.value]});
    }

    if (category == 6) {
      setFilter(SkillFilterType.category, {showAccessory.value});
    }

    setFilter(SkillFilterType.isRegular, onlyRegularSkill.value);
    setFilter(SkillFilterType.showExclusive, isExclusive.value);
    setFilter(SkillFilterType.showEnemyOnly, false);
    filt();
    super.onInit();
  }
}

class SkillChooseConfig {
  int category;

  ///是否显示选择单个技能的按钮
  bool selectMode;

  ///自带的专有技能
  List<String> exclusiveSkills;

  ///过滤器的enum列表，
  List<Filter<Skill, SkillFilterType>> filters;
  // 舞娘技能，舞娘技能被视为特殊技能，因此过滤的时候会被排除，而且有SID_踊る、SID_歌う及其他高级技能，
  // 这里根据人物本身技能传入显示
  // List<String> refresherSkill;
  SkillChooseConfig({
    required this.category,
    // this.filterEnums = const [],
    this.selectMode = false,
    this.exclusiveSkills = const [],
    this.filters = const [],
    // this.refresherSkill = const [],
  });
}
