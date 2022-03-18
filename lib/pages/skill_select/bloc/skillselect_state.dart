part of 'skillselect_bloc.dart';

class SkillselectState extends Equatable {
  const SkillselectState({
    required this.status,
    required this.category,
    required this.selectMode,
    required this.exclusiveSkills,
    required this.filters,
    required this.moveTypefilters,
    required this.weponTypefilters,
    required this.categoryFilters,
    this.input = const [],
    this.filtered = const [],
  });

  /// 页面状态
  final StateStatus status;

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
  final Set<MoveTypeEnum> moveTypefilters;

  /// 武器类型过滤器集合
  final Set<WeaponTypeEnum> weponTypefilters;

  /// 技能类别过滤器集合，目前用于对圣印进行分类
  final Set<int> categoryFilters;

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
  List<Object> get props => [
        status,
        filters,
        moveTypefilters,
        weponTypefilters,
        categoryFilters,
        exclusiveSkills,
        input,
        filtered,
      ];

  SkillselectState copyWith({
    StateStatus? status,
    Set<SkillFilterType>? filters,
    Set<MoveTypeEnum>? moveTypefilters,
    Set<WeaponTypeEnum>? weponTypefilters,
    Set<int>? categoryFilters,
    List<Skill>? exclusiveSkills,
    List<Skill>? input,
    List<Skill>? filtered,
  }) {
    return SkillselectState(
      status: status ?? this.status,
      category: category,
      selectMode: selectMode,
      exclusiveSkills: exclusiveSkills ?? this.exclusiveSkills,
      filters: filters ?? this.filters,
      moveTypefilters: moveTypefilters ?? this.moveTypefilters,
      weponTypefilters: weponTypefilters ?? this.weponTypefilters,
      categoryFilters: categoryFilters ?? this.categoryFilters,
      input: input ?? this.input,
      filtered: filtered ?? this.filtered,
    );
  }
}

// class SkillselectInitial extends SkillselectState {
//   const SkillselectInitial({
//     required int category,
//     required bool selectMode,
//     required List<Skill> exclusiveSkills,
//     required Set<SkillFilterType> filters,
//     required Set<MoveTypeEnum> moveTypefilters,
//     required Set<WeaponTypeEnum> weponTypefilters,
//   }) : super(
//           category,
//           selectMode,
//           exclusiveSkills,
//           filters,
//           moveTypefilters,
//           weponTypefilters,
//         );
// }

// class SkillselectSucess extends SkillselectState {
//   final List<Skill> input;
//   final List<Skill> filtered;
//   const SkillselectSucess({
//     required this.input,
//     required this.filtered,
//     required int category,
//     required bool selectMode,
//     required List<Skill> exclusiveSkills,
//     required Set<SkillFilterType> filters,
//     required Set<MoveTypeEnum> moveTypefilters,
//     required Set<WeaponTypeEnum> weponTypefilters,
//   }) : super(
//           category,
//           selectMode,
//           exclusiveSkills,
//           filters,
//           moveTypefilters,
//           weponTypefilters,
//         );

//   SkillselectSucess copyWith({
//     List<Skill>? input,
//     List<Skill>? filtered,
//     Set<SkillFilterType>? filters,
//     Set<MoveTypeEnum>? moveTypefilters,
//     Set<WeaponTypeEnum>? weponTypefilters,
//   }) {
//     return SkillselectSucess(
//       input: input ?? this.input,
//       filtered: filtered ?? this.filtered,
//       category: category,
//       selectMode: selectMode,
//       exclusiveSkills: exclusiveSkills,
//       filters: filters ?? this.filters,
//       moveTypefilters: moveTypefilters ?? this.moveTypefilters,
//       weponTypefilters: weponTypefilters ?? this.weponTypefilters,
//     );
//   }

//   @override
//   List<Object> get props => [filters, moveTypefilters, weponTypefilters];
// }
