// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';

class SkillPageState extends Equatable {
  const SkillPageState({
    this.category = 0,
    this.selectMode = false,
    this.exclusiveSkills = const [],
    this.filters = const {},
    this.moveTypeFilters = const {},
    this.weaponTypeFilters = const {},
    this.categoryFilters = const {},
    this.input = const [],
    this.filtered = const [],
    this.series,
  });

  // ignore: constant_identifier_names
  static const SkillPageState DEFAULT = SkillPageState();

  /// 初始化后的技能列表，一般不变，用于过滤器的输入
  final List<Skill> input;

  /// 过滤后的技能列表，可变，用于界面显示
  final List<Skill> filtered;

  /// 技能类别
  ///
  /// 为0且[selectMode]false时显示武器类别过滤组件
  ///
  /// 为6（圣印）时显示ABCS四个类别的过滤组件
  final int category;

  /// 是否选择模式，和[exclusiveSkills]配套使用
  final bool selectMode;

  /// 专属技能列表，显示人物专属技能，[selectMode]为ture时使用
  final List<Skill> exclusiveSkills;

  bool get onlyRegular => filters.contains(SkillFilterType.isRegular);

  bool get noExclusive => filters.contains(SkillFilterType.noExclusive);

  /// 一般过滤器集合，用于生成过滤链
  final Set<SkillFilterType> filters;

  /// 移动类型过滤器集合
  final Set<MoveTypeEnum> moveTypeFilters;

  /// 武器类型过滤器集合
  final Set<WeaponTypeEnum> weaponTypeFilters;

  /// 技能类别过滤器集合，目前用于对圣印进行分类
  final Set<int> categoryFilters;

  /// 技能快速过滤，目前是单选
  final String? series;

  ///用作给武器类别显示分类的字典
  static const List<WeaponTypeEnum> weaponTypeDict = [
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

  @override
  List<Object?> get props => [
        filters,
        moveTypeFilters,
        weaponTypeFilters,
        categoryFilters,
        exclusiveSkills,
        input,
        filtered,
        series,
      ];

  // SkillPageState copyWith({
  //   Set<SkillFilterType>? filters,
  //   bool? selectMode,
  //   bool? selectMode,
  //   Set<MoveTypeEnum>? moveTypefilters,
  //   Set<WeaponTypeEnum>? weponTypefilters,
  //   Set<int>? categoryFilters,
  //   List<Skill>? exclusiveSkills,
  //   List<Skill>? input,
  //   List<Skill>? filtered,
  // }) {
  //   return SkillPageState(
  //     category: category,
  //     selectMode: selectMode ?? this.selectMode,
  //     exclusiveSkills: exclusiveSkills ?? this.exclusiveSkills,
  //     filters: filters ?? this.filters,
  //     moveTypeFilters: moveTypefilters ?? this.moveTypeFilters,
  //     weaponTypeFilters: weponTypefilters ?? this.weaponTypeFilters,
  //     categoryFilters: categoryFilters ?? this.categoryFilters,
  //     input: input ?? this.input,
  //     filtered: filtered ?? this.filtered,
  //   );
  // }

  SkillPageState copyWith({
    List<Skill>? input,
    List<Skill>? filtered,
    int? category,
    bool? selectMode,
    List<Skill>? exclusiveSkills,
    Set<SkillFilterType>? filters,
    Set<MoveTypeEnum>? moveTypeFilters,
    Set<WeaponTypeEnum>? weaponTypeFilters,
    Set<int>? categoryFilters,
    String? series,
  }) {
    return SkillPageState(
      input: input ?? this.input,
      filtered: filtered ?? this.filtered,
      category: category ?? this.category,
      selectMode: selectMode ?? this.selectMode,
      exclusiveSkills: exclusiveSkills ?? this.exclusiveSkills,
      filters: filters ?? this.filters,
      moveTypeFilters: moveTypeFilters ?? this.moveTypeFilters,
      weaponTypeFilters: weaponTypeFilters ?? this.weaponTypeFilters,
      categoryFilters: categoryFilters ?? this.categoryFilters,
      series: series ?? this.series,
      // series: series ?? this.series,
    );
  }

  // static Future<SkillPageState> initial(
  //   int category,
  //   bool selectMode,
  //   List<Skill> exclusiveSkills,
  //   Set<SkillFilterType> filters,
  //   Set<MoveTypeEnum> moveTypeFilters,
  //   Set<WeaponTypeEnum> weaponTypeFilters,
  //   Set<int> categoryFilters,
  //   Repository repo,
  // ) async {
  //   // 圣印不能仅靠category区分
  //   var input = category == 6
  //       ? repo.cacheSkills.values.where((element) => element.isSkillAccessory)
  //       : repo.cacheSkills.values
  //           .where((element) => element.category == category);

  //   var exclusive = [...exclusiveSkills];
  //   // 去掉其他类的技能
  //   exclusive.removeWhere((element) => element.category != category);
  //   // 排序
  //   exclusive.sort((a, b) => a.sortId! == b.sortId!
  //       ? a.refineSortId!.compareTo(b.refineSortId!)
  //       : a.sortId!.compareTo(b.sortId!));

  //   List<Skill> output = _filt(
  //     input.toList(),
  //     filters,
  //     moveTypeFilters,
  //     weaponTypeFilters,
  //     categoryFilters,
  //   );
  //   // 插入到output中，因为目前传入exclusiveSkills肯定是技能选择模式，
  //   // 该模式不显示专武，所以不需处理output存在多个相同专武的情况

  //   output.insertAll(0, exclusive);

  //   return SkillPageState(
  //     category: category,
  //     selectMode: selectMode,
  //     exclusiveSkills: exclusive,
  //     filters: filters,
  //     moveTypeFilters: moveTypeFilters,
  //     weaponTypeFilters: weaponTypeFilters,
  //     categoryFilters: categoryFilters,
  //     input: input.toList(),
  //     filtered: output,
  //   );
  // }
}
