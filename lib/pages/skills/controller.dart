import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filterChain/filter_chain.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/models/base/skill_base.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/pages/skills/model.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SkillParam extends Equatable {
  final int category;
  final bool selectMode;
  final List<Skill> exclusiveSkills;
  final Set<SkillFilterType> filters;
  final Set<MoveTypeEnum> moveTypeFilters;
  final Set<WeaponTypeEnum> weaponTypeFilters;
  final Set<int> categoryFilters;

  const SkillParam({
    required this.category,
    required this.selectMode,
    required this.exclusiveSkills,
    required this.filters,
    required this.moveTypeFilters,
    required this.weaponTypeFilters,
    required this.categoryFilters,
  });

  @override
  List<Object?> get props => [
        category,
        selectMode,
        exclusiveSkills,
        filters,
        moveTypeFilters,
        weaponTypeFilters,
        categoryFilters,
      ];
}

final skillsPageProvider = AutoDisposeAsyncNotifierProviderFamily<
    SkillsPageNotifier, SkillPageState, SkillParam>(SkillsPageNotifier.new);

class SkillsPageNotifier
    extends AutoDisposeFamilyAsyncNotifier<SkillPageState, SkillParam> {
  // late SkillParam _param;

  @override
  Future<SkillPageState> build(SkillParam arg) async {
    Repository repo = ref.read(repoProvider).requireValue;

    var allSkill = (await repo.skill.getAll()).values;

    // 圣印不能仅靠category区分
    // var input = arg.category == 6
    //     ? repo.cacheSkills.values.where((element) => element.isSkillAccessory)
    //     : repo.cacheSkills.values
    //         .where((element) => element.category == arg.category);

    var input = arg.category == 6
        ? allSkill.where((element) => element.isSkillAccessory)
        : allSkill.where((element) => element.category == arg.category);

    List<Skill> output = _filt(
      input.toList(),
      arg.filters,
      arg.moveTypeFilters,
      arg.weaponTypeFilters,
      arg.categoryFilters,
      "reset",
    );

    var exclusive = [...arg.exclusiveSkills];
    // 去掉其他类的技能
    exclusive.removeWhere((element) => element.category != arg.category);
    // 排序
    exclusive.sort((a, b) => a.sortId! == b.sortId!
        ? a.refineSortId!.compareTo(b.refineSortId!)
        : a.sortId!.compareTo(b.sortId!));
    // 插入到output中，因为目前传入exclusiveSkills肯定是技能选择模式，
    // 该模式不显示专武，所以不需处理output存在多个相同专武的情况

    output.insertAll(0, exclusive);

    return SkillPageState(
      category: arg.category,
      selectMode: arg.selectMode,
      exclusiveSkills: exclusive,
      filters: arg.filters,
      moveTypeFilters: arg.moveTypeFilters,
      weaponTypeFilters: arg.weaponTypeFilters,
      categoryFilters: arg.categoryFilters,
      input: input.toList(),
      filtered: output,
      series: "reset",
    );
  }

  Future<void> changeFilters({
    Set<SkillFilterType>? filters,
    Set<MoveTypeEnum>? moveTypeFilters,
    Set<WeaponTypeEnum>? weponTypeFilters,
    Set<int>? categoryFilters,
    String? series,
  }) async {
    state = await AsyncValue.guard(() async {
      var s = state.requireValue;

      List<Skill> output = _filt(
        s.input,
        filters ?? s.filters,
        moveTypeFilters ?? s.moveTypeFilters,
        weponTypeFilters ?? s.weaponTypeFilters,
        categoryFilters ?? s.categoryFilters,
        series ?? s.series,
      );

      output.insertAll(0, s.exclusiveSkills);

      return s.copyWith(
        filtered: output,
        filters: filters,
        moveTypeFilters: moveTypeFilters,
        weaponTypeFilters: weponTypeFilters,
        categoryFilters: categoryFilters,
        series: series,
      );
    });
  }
}

List<Skill> _filt(
  List<Skill> input,
  Set<SkillFilterType> filters,
  Set<MoveTypeEnum> moveTypefilters,
  Set<WeaponTypeEnum> weponTypefilters,
  Set<int> categoryFilters,
  String? series,
) {
  FilterChain<BaseSkill, SkillFilterType, Skill> chain =
      FilterChain(filters: [], input: input);

  for (var item in filters) {
    chain.filters.add(SkillFilter(filterType: item));
  }
  if (moveTypefilters.isNotEmpty) {
    chain.add(
      SkillFilter(
        filterType: SkillFilterType.moveType,
        valid: moveTypefilters,
      ),
    );
  }
  if (weponTypefilters.isNotEmpty) {
    chain.add(
      SkillFilter(
        filterType: SkillFilterType.weaponType,
        valid: weponTypefilters,
      ),
    );
  }
  if (categoryFilters.isNotEmpty) {
    chain.add(
      SkillFilter(
        filterType: SkillFilterType.category,
        valid: categoryFilters,
      ),
    );
  }
  var _ = chain.output
      .where((element) =>
          series == "reset" ? true : element!.skill.series == series)
      .map((e) => e!.skill)
      .toList();

  // var _ = [for (var e in chain.output) e!.skill];
  _.sort((a, b) => a.sortId!.compareTo(b.sortId!) != 0
      ? a.sortId!.compareTo(b.sortId!)
      : a.refineSortId!.compareTo(b.refineSortId!));
  return _;
}
