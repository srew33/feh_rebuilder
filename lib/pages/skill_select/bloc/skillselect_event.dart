part of 'skillselect_bloc.dart';

abstract class SkillselectEvent extends Equatable {
  const SkillselectEvent();

  @override
  List<Object> get props => [];
}

class SkillselectStarted extends SkillselectEvent {}

class SkillselectFIlterChanged extends SkillselectEvent {
  const SkillselectFIlterChanged({
    this.filters,
    this.moveTypeFilters,
    this.weponTypeFilters,
    this.categoryFilters,
  });
  final Set<SkillFilterType>? filters;
  final Set<MoveTypeEnum>? moveTypeFilters;
  final Set<WeaponTypeEnum>? weponTypeFilters;
  final Set<int>? categoryFilters;
}
