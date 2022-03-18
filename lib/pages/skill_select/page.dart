import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/home_screens/favourites/bloc/favscreen_bloc.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/pages/hero_detail/page.dart';
import 'package:feh_rebuilder/pages/skill_select/bloc/skillselect_bloc.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/widgets/skill_tile.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class SkillSelectPage extends StatelessWidget {
  const SkillSelectPage({
    Key? key,
    required this.category,
    required this.selectMode,
    this.exclusiveSkills = const [],
    this.filters = const {},
    this.moveTypefilters = const {},
    this.weponTypefilters = const {},
    this.categoryFilters = const {},
  }) : super(key: key);
  final int category;
  final bool selectMode;
  final List<Skill> exclusiveSkills;
  final Set<SkillFilterType> filters;
  final Set<MoveTypeEnum> moveTypefilters;
  final Set<WeaponTypeEnum> weponTypefilters;
  final Set<int> categoryFilters;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: ((context) => SkillselectBloc(
            repo: context.read<Repository>(),
            category: category,
            selectMode: selectMode,
            exclusiveSkills: exclusiveSkills,
            filters: filters,
            moveTypefilters: moveTypefilters,
            weponTypefilters: weponTypefilters,
            categoryFilters: categoryFilters,
          )..add(SkillselectStarted())),
      child: const _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // if (state.exclusiveSkillTags.isNotEmpty)

          const _FilterTiles(),

          BlocBuilder<SkillselectBloc, SkillselectState>(
            builder: (context, state) {
              if (state.status != StateStatus.success) {
                return const SizedBox.shrink();
              } else {
                return Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return SkillTile(
                        skill: state.filtered[index],
                        tailBtn: state.selectMode
                            ? IconButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(state.filtered[index]);
                                },
                                icon: const Icon(Icons.check),
                              )
                            : null,
                        iconHeight: 30,
                        heroHeight: 40,
                        onClick: (String idtag) {
                          FavscreenBloc bloc = context.read<FavscreenBloc>();
                          Person hero =
                              context.read<Repository>().cachePersons[idtag]!;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HeroDetailPage(
                                hero: hero,
                                favBloc: bloc,
                                initialBuild: PersonBuild(
                                  personTag: idtag,
                                  equipSkills: const [],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                    ),
                    itemCount: state.filtered.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SkillAccessoryTile extends StatelessWidget {
  const _SkillAccessoryTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SkillselectBloc, SkillselectState, Set<int>>(
      selector: (state) {
        return state.categoryFilters;
      },
      builder: (context, filters) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 3; i < 7; i++)
              ChoiceChip(
                selected: filters.contains(i),
                label: UniImage(
                  path: p
                      .join("assets", "skill_placeholder", "$i.webp")
                      .replaceAll(r"\", "/"),
                  height: 25,
                ),
                backgroundColor: Colors.transparent,
                labelPadding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                selectedColor: Colors.blue.shade200,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                onSelected: (bool newState) {
                  if (newState) {
                    context.read<SkillselectBloc>().add(
                          SkillselectFIlterChanged(
                            categoryFilters: {i},
                          ),
                        );
                  }
                },
              )
          ],
        );
      },
    );
  }
}

class _FilterTiles extends StatelessWidget {
  const _FilterTiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkillselectBloc, SkillselectState>(
      builder: (context, state) {
        return Column(children: [
          if (state.category == 0 && !state.selectMode)
            ListTile(
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (WeaponTypeEnum weapon
                          in SkillselectState.weaponTypeDict.getRange(0, 6))
                        ChoiceChip(
                          label: UniImage(
                            path: p
                                .join("assets", "weapon",
                                    "${weapon.groupIndex}.webp")
                                .replaceAll(r"\", "/"),
                            height: 25,
                          ),
                          backgroundColor: Colors.transparent,
                          selectedColor: Colors.blue.shade200,
                          labelPadding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                          onSelected: (bool newState) {
                            if (newState) {
                              context.read<SkillselectBloc>().add(
                                    SkillselectFIlterChanged(
                                      weponTypeFilters: {weapon},
                                    ),
                                  );
                            }
                          },
                          selected: state.weponTypefilters.contains(weapon),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (WeaponTypeEnum weapon
                          in SkillselectState.weaponTypeDict.getRange(6, 12))
                        ChoiceChip(
                          label: UniImage(
                            path: p
                                .join("assets", "weapon",
                                    "${weapon.groupIndex}.webp")
                                .replaceAll(r"\", "/"),
                            height: 25,
                          ),
                          backgroundColor: Colors.transparent,
                          labelPadding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                          selectedColor: Colors.blue.shade200,
                          onSelected: (bool newState) {
                            context.read<SkillselectBloc>().add(
                                  SkillselectFIlterChanged(
                                    weponTypeFilters: {weapon},
                                  ),
                                );
                          },
                          selected: state.weponTypefilters.contains(weapon),
                        ),
                    ],
                  )
                ],
              ),
            ),
          if (state.category == 6) const _SkillAccessoryTile(),
          if (!state.selectMode)
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("显示专属技能"),
                  Switch(
                    value: !state.noExclusive,
                    onChanged: (bool newVal) =>
                        context.read<SkillselectBloc>().add(
                              newVal
                                  ? SkillselectFIlterChanged(
                                      filters: {...state.filters}
                                        ..remove(SkillFilterType.noExclusive),
                                    )
                                  : SkillselectFIlterChanged(
                                      filters: {...state.filters}
                                        ..add(SkillFilterType.noExclusive),
                                    ),
                            ),
                  ),
                ],
              ),
            ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("只显示常用技能"),
                Switch(
                  value: state.onlyRegular,
                  onChanged: (bool newVal) =>
                      context.read<SkillselectBloc>().add(
                            newVal
                                ? SkillselectFIlterChanged(
                                    filters: {...state.filters}
                                      ..add(SkillFilterType.isRegular),
                                  )
                                : SkillselectFIlterChanged(
                                    filters: {...state.filters}
                                      ..remove(SkillFilterType.isRegular),
                                  ),
                          ),
                ),
              ],
            ),
          ),
        ]);
      },
    );
  }
}
