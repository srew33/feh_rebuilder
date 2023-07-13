import 'package:feh_rebuilder/core/enum/category.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
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
    required this.initialParam,
    super.key,
  });

  final SkillParam initialParam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: initialParam.category > 2 && initialParam.category < 6
          ? _Drawer(initialParam: initialParam)
          : null,
      body: _Body(initialParam: initialParam),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.initialParam,
  });

  final SkillParam initialParam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(skillsPageProvider(initialParam));

    return state.when(
      data: (data) => Column(
        children: [
          // if (state.exclusiveSkillTags.isNotEmpty)

          _FilterTiles(
            initialParam: initialParam,
          ),

          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return SkillTile(
                  skill: data.filtered[index],
                  tailBtn: data.selectMode
                      ? IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(data.filtered[index]);
                          },
                          icon: const Icon(Icons.check),
                        )
                      : null,
                  iconHeight: 30,
                  heroHeight: 40,
                  onClick: (String idtag) async {
                    if (context.mounted) {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => HeroDetailPage(
                          family: PersonBuild(
                            equipSkills: const [],
                            personTag: idtag,
                          ),
                        ),
                      ));
                    }
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(
                height: 1,
              ),
              itemCount: data.filtered.length,
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Center(
        child: Text(
          error.toString(),
        ),
      ),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _Drawer extends ConsumerWidget {
  const _Drawer({
    required this.initialParam,
  });

  final SkillParam initialParam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<String>?>(
      future: () async {
        if (initialParam.category < CategoryEnum.values.length) {
          var s = await ref
              .read(repoProvider)
              .requireValue
              .skillSeries
              .read(CategoryEnum.values[initialParam.category].name);
          if (s != null) {
            return s.cast<String>();
          }
        }
      }(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const SizedBox.shrink();
        }

        var s = snapshot.data!;

        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(skillsPageProvider(initialParam));

            return state.when(
              data: (data) => Padding(
                padding: EdgeInsets.fromLTRB(
                    0,
                    kToolbarHeight + MediaQuery.of(context).viewPadding.top,
                    0,
                    kBottomNavigationBarHeight),
                child: SizedBox(
                  width: 200,
                  child: Drawer(
                    child: ListView.builder(
                      itemCount: s.length,
                      itemBuilder: (context, index) => RadioListTile<String>(
                        dense: true,
                        value: s[index],
                        selected: s[index] == data.series,
                        groupValue: data.series,
                        title: Text(
                          s[index],
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondary: s[index] == data.series
                            ? IconButton(
                                onPressed: () {
                                  ref
                                      .read(skillsPageProvider(initialParam)
                                          .notifier)
                                      .changeFilters(series: "reset");
                                },
                                icon: const Icon(Icons.cancel))
                            : null,
                        onChanged: (value) => ref
                            .read(skillsPageProvider(initialParam).notifier)
                            .changeFilters(series: value),
                      ),
                    ),
                  ),
                ),
              ),
              error: (error, stackTrace) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            );
          },
        );
      },
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
        .select((value) => value.valueOrNull!.categoryFilters));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 3; i < 7; i++)
          FilterChip(
            showCheckmark: false,
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

    return state.when(
      data: (data) => Column(children: [
        if (data.category == 0 && !data.selectMode)
          ListTile(
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (WeaponTypeEnum weapon
                        in SkillPageState.weaponTypeDict.getRange(0, 6))
                      FilterChip(
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
                            ref
                                .read(skillsPageProvider(initialParam).notifier)
                                .changeFilters(
                              weponTypeFilters: {weapon},
                            );
                          }
                        },
                        showCheckmark: false,
                        selected: data.weaponTypeFilters.contains(weapon),
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
                      FilterChip(
                        showCheckmark: false,
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
                        onSelected: (bool newdata) {
                          ref
                              .read(skillsPageProvider(initialParam).notifier)
                              .changeFilters(
                            weponTypeFilters: {weapon},
                          );
                        },
                        selected: data.weaponTypeFilters.contains(weapon),
                      ),
                  ],
                )
              ],
            ),
          ),
        if (data.category == 6)
          _SkillAccessoryTile(
            initialParam: initialParam,
          ),
        if (!data.selectMode)
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("显示专属技能"),
                Switch(
                  value: !data.noExclusive,
                  onChanged: (bool newVal) => newVal
                      ? ref
                          .read(skillsPageProvider(initialParam).notifier)
                          .changeFilters(
                              filters: {...data.filters}
                                ..remove(SkillFilterType.noExclusive))
                      : ref
                          .read(skillsPageProvider(initialParam).notifier)
                          .changeFilters(
                              filters: {...data.filters}
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
                value: data.onlyRegular,
                onChanged: (bool newVal) => newVal
                    ? ref
                        .read(skillsPageProvider(initialParam).notifier)
                        .changeFilters(
                            filters: {...data.filters}
                              ..add(SkillFilterType.isRegular))
                    : ref
                        .read(skillsPageProvider(initialParam).notifier)
                        .changeFilters(
                            filters: {...data.filters}
                              ..remove(SkillFilterType.isRegular)),
              ),
            ],
          ),
        ),
      ]),
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
