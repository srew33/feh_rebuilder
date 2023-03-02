import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/pages/hero_detail/model.dart';
import 'package:feh_rebuilder/pages/hero_detail/ui.dart';
import 'package:feh_rebuilder/pages/skills/controller.dart';
import 'package:feh_rebuilder/pages/skills/model.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/widgets/skill_tile.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class SkillsPage extends ConsumerWidget {
  const SkillsPage({
    Key? key,
    required this.initialParam,
  }) : super(key: key);

  final SkillParam initialParam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skillsPageProvider(initialParam));

    return Scaffold(
      appBar: AppBar(),
      body: Consumer(
        builder: (context, ref, child) {
          return Column(
            children: [
              // if (state.exclusiveSkillTags.isNotEmpty)

              _FilterTiles(
                initialParam: initialParam,
              ),

              Expanded(
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
                      onClick: (String idtag) async {
                        var initial = await HerodetailState.initial(
                            PersonBuild(
                              equipSkills: const [],
                              personTag: idtag,
                            ),
                            ref.read(repoProvider).requireValue);

                        if (context.mounted) {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                HeroDetailPage(initialState: initial),
                          ));
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                  ),
                  itemCount: state.filtered.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SkillAccessoryTile extends ConsumerWidget {
  const _SkillAccessoryTile({
    Key? key,
    required this.initialParam,
  }) : super(key: key);

  final SkillParam initialParam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var filters = ref.watch(skillsPageProvider(initialParam)
        .select((value) => value.categoryFilters));
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
                ref
                    .read(skillsPageProvider(initialParam).notifier)
                    .changeFilters(
                  categoryFilters: {i},
                );
              }
            },
          )
      ],
    );
  }
}

class _FilterTiles extends ConsumerWidget {
  const _FilterTiles({
    Key? key,
    required this.initialParam,
  }) : super(key: key);
  final SkillParam initialParam;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.watch(skillsPageProvider(initialParam));

    return Column(children: [
      if (state.category == 0 && !state.selectMode)
        ListTile(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (WeaponTypeEnum weapon
                      in SkillPageState.weaponTypeDict.getRange(0, 6))
                    ChoiceChip(
                      label: UniImage(
                        path: p
                            .join(
                                "assets", "weapon", "${weapon.groupIndex}.webp")
                            .replaceAll(r"\", "/"),
                        height: 25,
                      ),
                      backgroundColor: Colors.transparent,
                      selectedColor: Colors.blue.shade200,
                      labelPadding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                      onSelected: (bool newState) {
                        if (newState) {
                          ref
                              .read(skillsPageProvider(initialParam).notifier)
                              .changeFilters(
                            weponTypeFilters: {weapon},
                          );
                        }
                      },
                      selected: state.weaponTypeFilters.contains(weapon),
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
                      in SkillPageState.weaponTypeDict.getRange(6, 12))
                    ChoiceChip(
                      label: UniImage(
                        path: p
                            .join(
                                "assets", "weapon", "${weapon.groupIndex}.webp")
                            .replaceAll(r"\", "/"),
                        height: 25,
                      ),
                      backgroundColor: Colors.transparent,
                      labelPadding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                      selectedColor: Colors.blue.shade200,
                      onSelected: (bool newState) {
                        ref
                            .read(skillsPageProvider(initialParam).notifier)
                            .changeFilters(
                          weponTypeFilters: {weapon},
                        );
                      },
                      selected: state.weaponTypeFilters.contains(weapon),
                    ),
                ],
              )
            ],
          ),
        ),
      if (state.category == 6)
        _SkillAccessoryTile(
          initialParam: initialParam,
        ),
      if (!state.selectMode)
        ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("显示专属技能"),
              Switch(
                value: !state.noExclusive,
                onChanged: (bool newVal) => newVal
                    ? ref
                        .read(skillsPageProvider(initialParam).notifier)
                        .changeFilters(
                            filters: {...state.filters}
                              ..remove(SkillFilterType.noExclusive))
                    : ref
                        .read(skillsPageProvider(initialParam).notifier)
                        .changeFilters(
                            filters: {...state.filters}
                              ..add(SkillFilterType.noExclusive)),
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
              onChanged: (bool newVal) => newVal
                  ? ref
                      .read(skillsPageProvider(initialParam).notifier)
                      .changeFilters(
                          filters: {...state.filters}
                            ..add(SkillFilterType.isRegular))
                  : ref
                      .read(skillsPageProvider(initialParam).notifier)
                      .changeFilters(
                          filters: {...state.filters}
                            ..remove(SkillFilterType.isRegular)),
            ),
          ],
        ),
      ),
    ]);
  }
}
