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

final skillsPageProvider = AutoDisposeNotifierProviderFamily<SkillsPageNotifier,
    SkillPageState, SkillParam>(SkillsPageNotifier.new);

class SkillsPageNotifier
    extends AutoDisposeFamilyNotifier<SkillPageState, SkillParam> {
  @override
  SkillPageState build(SkillParam arg) {
    return initial(arg);
  }

  SkillPageState initial(SkillParam params) {
    Repository repo = ref.read(repoProvider).requireValue;
    // 圣印不能仅靠category区分
    var input = params.category == 6
        ? repo.cacheSkills.values.where((element) => element.isSkillAccessory)
        : repo.cacheSkills.values
            .where((element) => element.category == params.category);

    List<Skill> output = _filt(
      input.toList(),
      params.filters,
      params.moveTypeFilters,
      params.weaponTypeFilters,
      params.categoryFilters,
    );

    var exclusive = [...params.exclusiveSkills];
    // 去掉其他类的技能
    exclusive.removeWhere((element) => element.category != params.category);
    // 排序
    exclusive.sort((a, b) => a.sortId! == b.sortId!
        ? a.refineSortId!.compareTo(b.refineSortId!)
        : a.sortId!.compareTo(b.sortId!));
    // 插入到output中，因为目前传入exclusiveSkills肯定是技能选择模式，
    // 该模式不显示专武，所以不需处理output存在多个相同专武的情况

    output.insertAll(0, exclusive);

    return SkillPageState(
      category: params.category,
      selectMode: params.selectMode,
      exclusiveSkills: exclusive,
      filters: params.filters,
      moveTypeFilters: params.moveTypeFilters,
      weaponTypeFilters: params.weaponTypeFilters,
      categoryFilters: params.categoryFilters,
      input: input.toList(),
      filtered: output,
    );
  }

  void changeFilters({
    Set<SkillFilterType>? filters,
    Set<MoveTypeEnum>? moveTypeFilters,
    Set<WeaponTypeEnum>? weponTypeFilters,
    Set<int>? categoryFilters,
  }) {
    List<Skill> output = _filt(
      state.input,
      filters ?? state.filters,
      moveTypeFilters ?? state.moveTypeFilters,
      weponTypeFilters ?? state.weaponTypeFilters,
      categoryFilters ?? state.categoryFilters,
    );

    output.insertAll(0, state.exclusiveSkills);

    state = state.copyWith(
      filtered: output,
      filters: filters,
      moveTypeFilters: moveTypeFilters,
      weaponTypeFilters: weponTypeFilters,
      categoryFilters: categoryFilters,
    );
  }
}

List<Skill> _filt(
  List<Skill> input,
  Set<SkillFilterType> filters,
  Set<MoveTypeEnum> moveTypefilters,
  Set<WeaponTypeEnum> weponTypefilters,
  Set<int> categoryFilters,
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
  var _ = [for (var e in chain.output) e!.skill];
  _.sort((a, b) => a.sortId!.compareTo(b.sortId!) != 0
      ? a.sortId!.compareTo(b.sortId!)
      : a.refineSortId!.compareTo(b.refineSortId!));
  return _;
}
