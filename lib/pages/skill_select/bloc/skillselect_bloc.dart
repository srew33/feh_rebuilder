import 'package:equatable/equatable.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filterChain/filter_chain.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'skillselect_event.dart';
part 'skillselect_state.dart';

class SkillselectBloc extends Bloc<SkillselectEvent, SkillselectState> {
  SkillselectBloc({
    required this.repo,
    required int category,
    required bool selectMode,
    required List<Skill> exclusiveSkills,
    required Set<SkillFilterType> filters,
    required Set<MoveTypeEnum> moveTypefilters,
    required Set<WeaponTypeEnum> weponTypefilters,
    required Set<int> categoryFilters,
  }) : super(SkillselectState(
          status: StateStatus.initial,
          category: category,
          selectMode: selectMode,
          exclusiveSkills: exclusiveSkills,
          filters: filters,
          moveTypefilters: moveTypefilters,
          weponTypefilters: weponTypefilters,
          categoryFilters: categoryFilters,
        )) {
    on<SkillselectStarted>(_onSkillselectStarted);

    on<SkillselectFIlterChanged>(_onSkillselectFIlterChanged);
  }
  Repository repo;

  Future<void> _onSkillselectStarted(
      SkillselectStarted event, Emitter emit) async {
    // 圣印不能仅靠category区分
    var input = state.category == 6
        ? repo.cacheSkills.values.where((element) => element.isSkillAccessory)
        : repo.cacheSkills.values
            .where((element) => element.category == state.category);

    List<Skill> output = doFilt(
      input.toList(),
      state.filters,
      state.moveTypefilters,
      state.weponTypefilters,
      state.categoryFilters,
    );

    var exclusiveSkills = [...state.exclusiveSkills];
    // 去掉其他类的技能
    exclusiveSkills
        .removeWhere((element) => element.category != state.category);
    // 排序
    exclusiveSkills.sort((a, b) => a.sortId! == b.sortId!
        ? a.refineSortId!.compareTo(b.refineSortId!)
        : a.sortId!.compareTo(b.sortId!));
    // 插入到output中，因为目前传入exclusiveSkills肯定是技能选择模式，
    // 该模式不显示专武，所以不需处理output存在多个相同专武的情况

    output.insertAll(0, exclusiveSkills);
    emit(state.copyWith(
      status: StateStatus.success,
      input: input.toList(),
      filtered: output,
      exclusiveSkills: exclusiveSkills,
    ));
  }

  void _onSkillselectFIlterChanged(
      SkillselectFIlterChanged event, Emitter emit) {
    List<Skill> output = doFilt(
      state.input,
      event.filters ?? state.filters,
      event.moveTypeFilters ?? state.moveTypefilters,
      event.weponTypeFilters ?? state.weponTypefilters,
      event.categoryFilters ?? state.categoryFilters,
    );

    output.insertAll(0, state.exclusiveSkills);

    emit(state.copyWith(
      filtered: output,
      filters: event.filters,
      moveTypefilters: event.moveTypeFilters,
      weponTypefilters: event.weponTypeFilters,
      categoryFilters: event.categoryFilters,
    ));
  }

  List<Skill> doFilt(
    List<Skill> input,
    Set<SkillFilterType> filters,
    Set<MoveTypeEnum> moveTypefilters,
    Set<WeaponTypeEnum> weponTypefilters,
    Set<int> categoryFilters,
  ) {
    FilterChain<Skill, SkillFilterType> chain =
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
    var _ = chain.output;
    _.sort((a, b) => a.sortId!.compareTo(b.sortId!) != 0
        ? a.sortId!.compareTo(b.sortId!)
        : a.refineSortId!.compareTo(b.refineSortId!));
    return _;
  }
}
