// ignore_for_file: unused_import

import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/pages/hero_detail/controller.dart';
import 'package:feh_rebuilder/pages/skills/controller.dart';
import 'package:feh_rebuilder/pages/skills/ui.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/widgets/skill_tile.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../model.dart';
import '../ui.dart';

class SkillTiles extends ConsumerWidget {
  /// 技能配置的列表项
  const SkillTiles(this.family, {Key? key}) : super(key: key);

  final PersonBuild family;

  Future<void> toAnotherHero(
      BuildContext context, String heroId, Repository repo) async {
    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HeroDetailPage(
            favKey: null,
            family: PersonBuild(
              personTag: heroId,
              equipSkills: const [],
            ),
          ),
        ),
      );
    }
  }

  Future<void> selectSkill({
    required BuildContext context,
    required int index,
    required Person hero,
    required List<Skill> exclusiveList,
    required void Function(int index, Skill newSkill) onSelect,
  }) async {
    var newSkill = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SkillsPage(
        initialParam: SkillParam(
          category: index == 7 ? 15 : index,
          selectMode: true,
          exclusiveSkills: exclusiveList,
          filters: const {
            SkillFilterType.isRegular,
            SkillFilterType.noEnemyOnly,
            SkillFilterType.noExclusive
          },
          moveTypeFilters: {MoveTypeEnum.values[hero.moveType!]},
          weaponTypeFilters: {WeaponTypeEnum.values[hero.weaponType!]},
          categoryFilters: const {},
        ),
      ),
    ));
    if (newSkill is Skill) {
      onSelect.call(index, newSkill);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var hero = ref.watch(heroDetailPageProvider(family)
        .select((value) => value.valueOrNull!.hero));

    int skillNumLimit =
        (hero.legendary != null && hero.legendary?.kind == 1) ? 7 : 8;

    return Column(
      children: [
        ListTile(
          title: const Text("技能配置"),
          tileColor: Colors.grey.shade200,
        ),
        for (int index = 0; index < skillNumLimit; index++)
          Consumer(
            builder: (context, ref, child) {
              var (done, skill) = ref.watch(heroDetailPageProvider(family)
                  .select((value) =>
                      (value.hasValue, value.valueOrNull!.equipSkills[index])));

              if (!done) {
                return const SizedBox.shrink();
              }

              return skill != null
                  ? SkillTile(
                      skill: skill,
                      iconHeight: 30,
                      heroHeight: 40,
                      onClick: (String idtag) => toAnotherHero(
                          context, idtag, ref.read(repoProvider).requireValue),
                      tailBtn: IconButton(
                        onPressed: () => ref
                            .read(heroDetailPageProvider(family).notifier)
                            .changeSkill(
                              HerodetailSkillsChanged(
                                  skill: null, index: index),
                            ),
                        icon: const Icon(Icons.delete),
                      ),
                    )
                  : ListTile(
                      title: Row(
                        children: [
                          UniImage(
                              path: p
                                  .join("assets", "skill_placeholder",
                                      "$index.webp")
                                  .replaceAll(r"\", "/"),
                              height: 30),
                        ],
                      ),
                      onTap: () => selectSkill(
                        context: context,
                        index: index,
                        hero: hero,
                        exclusiveList: ref
                            .read(heroDetailPageProvider(family))
                            .requireValue
                            .exclusiveList
                            .keys
                            .toList(),
                        onSelect: (index, newSkill) => ref
                            .read(heroDetailPageProvider(family).notifier)
                            .changeSkill(
                              HerodetailSkillsChanged(
                                skill: newSkill,
                                index: index,
                              ),
                            ),
                      ),
                    );
            },
          ),
        ListTile(
          title: Row(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  var arenaScore = ref.watch(heroDetailPageProvider(family)
                      .select((value) => value.valueOrNull!.arenaScore));

                  return Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "竞技场分数 ", style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: arenaScore.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ]));
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Consumer(
                  builder: (context, ref, child) {
                    var allSpCost = ref.watch(heroDetailPageProvider(family)
                        .select((value) => value.valueOrNull!.allSpCost));

                    return Text.rich(
                      TextSpan(children: <InlineSpan>[
                        const TextSpan(
                            text: "总SP ",
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: allSpCost.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
