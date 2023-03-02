// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/core/enum/person_type.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feh_rebuilder/core/enum/stats.dart';
import 'package:feh_rebuilder/models/person/growth_rates.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/styles/text_styles.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:path/path.dart' as p;
import '../controller.dart';
import '../model.dart';

class ResplendentTile extends StatelessWidget {
  /// 神装英雄
  const ResplendentTile(this.initialState, {super.key});

  final HerodetailState initialState;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("神装英雄"),
          Consumer(
            builder: (context, ref, child) {
              bool resplendent = ref.watch(heroDetailPageProvider(initialState)
                  .select((value) => value.resplendent));
              bool isResplendentHero = ref.watch(
                  heroDetailPageProvider(initialState)
                      .select((value) => value.hero.resplendentHero ?? false));
              return Switch(
                value: resplendent,
                onChanged: isResplendentHero
                    ? (bool newVal) => ref
                        .read(heroDetailPageProvider(initialState).notifier)
                        .changeProp(HerodetailPropChanged(resplendent: newVal))
                    : null,
              );
            },
          )
        ],
      ),
    );
  }
}

class AscendedAssetTile extends StatelessWidget {
  /// 绽放个性
  const AscendedAssetTile(this.initialState, {super.key});

  final HerodetailState initialState;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("绽放个性"),
          Consumer(
            builder: (context, ref, child) {
              String? ascendedAsset = ref.watch(
                  heroDetailPageProvider(initialState)
                      .select((value) => value.ascendedAsset));
              String? advantage = ref.watch(heroDetailPageProvider(initialState)
                  .select((value) => value.advantage));

              return DropdownButton<String?>(
                  value: ascendedAsset?.toUpperCase(),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("N/A"),
                    ),
                    for (var key in StatsEnum.values.getRange(0, 5))
                      DropdownMenuItem(
                        value: key.name,
                        enabled: key.name != advantage?.toUpperCase(),
                        child: Text("CUSTOM_STATS_${key.name}".tr),
                      ),
                  ],
                  onChanged: (obj) => ref
                      .read(heroDetailPageProvider(initialState).notifier)
                      .changeProp(HerodetailPropChanged(
                        ascendedAsset: () => obj?.toLowerCase(),
                      )));
            },
          )
        ],
      ),
    );
  }
}

class LevelSwitchTile extends StatelessWidget {
  const LevelSwitchTile(this.initialState, {super.key});
  final HerodetailState initialState;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("数值"),
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                  onPressed: () {
                    int current = ref
                        .read(heroDetailPageProvider(initialState))
                        .targetLevel;
                    ref
                        .read(heroDetailPageProvider(initialState).notifier)
                        .changeProp(HerodetailPropChanged(
                            targetLevel: current == 40 ? 1 : 40));
                  },
                  child: const Text("1/40"));
            },
          ),
        ],
      ),
      tileColor: Colors.grey.shade200,
    );
  }
}

class SummonSupportTile extends StatelessWidget {
  const SummonSupportTile(this.initialState, {super.key});
  final HerodetailState initialState;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("召唤师的羁绊"),
          Consumer(
            builder: (context, ref, child) {
              bool summonerSupport = ref.watch(
                  heroDetailPageProvider(initialState)
                      .select((value) => value.summonerSupport));

              return Switch(
                value: summonerSupport,
                onChanged: (bool newVal) => ref
                    .read(heroDetailPageProvider(initialState).notifier)
                    .changeProp(HerodetailPropChanged(summonerSupport: newVal)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LegendaryTile extends ConsumerWidget {
  /// 显示特殊技能,与人物LEGEND字段有关
  const LegendaryTile(
    this.initialState, {
    Key? key,
  }) : super(key: key);

  final HerodetailState initialState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Person hero = ref.watch(
        heroDetailPageProvider(initialState).select((value) => value.hero));

    return ((hero.legendary?.kind ?? 4) != 4 &&
            (hero.legendary?.kind ?? 4) != 5)
        ? Column(
            children: [
              ListTile(
                title: const Text("常驻效果"),
                tileColor: Colors.grey.shade200,
              ),
              ListTile(
                title: Text(
                  "MPID_LEGEND_${hero.idTag!.split("_")[1]}".tr,
                  style: Theme.of(context).textTheme.descStyle,
                ),
              ),
              if (hero.legendary?.duoSkillId != null)
                ExpansionTile(
                  title: const Text("特殊技能效果"),
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(
                        "MSID_H_${hero.legendary!.duoSkillId!.split("_")[1]}"
                            .tr
                            .replaceAll(r"$a", ""),
                        style: Theme.of(context).textTheme.descStyle,
                      ),
                    )
                  ],
                )
            ],
          )
        : const SizedBox.shrink();
  }
}

class WeaponRefineTile extends ConsumerWidget {
  /// 显示武器炼成和效果
  const WeaponRefineTile(this.initialState, {Key? key}) : super(key: key);

  final HerodetailState initialState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.watch(heroDetailPageProvider(initialState));

    return state.hasRefinedWeapon
        ? Column(
            children: [
              ListTile(
                title: const Text("武器炼成"),
                tileColor: Colors.grey.shade200,
              ),
              for (MapEntry<Skill, Skill?> s in state.exclusiveList.entries)
                if (s.key.category! == 0 && s.key.refineId != null)
                  ExpansionTile(title: Text(s.key.nameId!.tr), children: [
                    ListTile(
                        title: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: (s.key.descId!.tr).replaceAll(r"$a", ""),
                        style: Theme.of(context).textTheme.descStyle,
                      ),
                      const TextSpan(text: "\n"),
                      TextSpan(
                        text: ((s.value?.descId! ?? "").tr).replaceAll(r"", ""),
                        style: Theme.of(context).textTheme.descStyle.merge(
                              const TextStyle(color: Colors.green),
                            ),
                      ),
                    ])))
                  ]),
            ],
          )
        : const SizedBox.shrink();
  }
}

class StatsTile extends ConsumerWidget {
  /// 显示属性数值
  const StatsTile(this.initialState, {Key? key}) : super(key: key);

  final HerodetailState initialState;

  ///根据属性成长率设定文字颜色
  Color? getPropColor(GrowthRates rates, String statsName) {
    if (Utils.advantageList.contains(rates.toJson()[statsName.toLowerCase()])) {
      return Colors.green.shade800;
    }
    if (Utils.disAdvantageList
        .contains(rates.toJson()[statsName.toLowerCase()])) {
      return Colors.red;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Person hero = ref.watch(
        heroDetailPageProvider(initialState).select((value) => value.hero));

    return ListTile(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  int bst = ref.watch(heroDetailPageProvider(initialState)
                      .select((value) => value.bst));

                  return Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "竞技场", style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: bst.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ]));
                },
              ),
              FittedBox(
                child: Row(
                  children: [
                    for (var key in StatsEnum.values.getRange(0, 5))
                      SizedBox(
                        width: 40,
                        child: Center(
                            child: Text(
                          "CUSTOM_STATS_${key.name}".tr,
                          style: TextStyle(
                              color: getPropColor(hero.growthRates!, key.name)),
                        )),
                      ),
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("基础数值"),
              Consumer(
                builder: (context, ref, child) {
                  Stats baseStats = ref.watch(
                      heroDetailPageProvider(initialState)
                          .select((value) => value.baseStats));

                  return FittedBox(
                    child: Row(
                      children: [
                        for (int num in baseStats.toJson().values)
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(num.toString()),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("装备数值"),
              Consumer(
                builder: (context, ref, child) {
                  Stats equipStats = ref.watch(
                      heroDetailPageProvider(initialState)
                          .select((value) => value.equipStats));

                  return FittedBox(
                    child: Row(
                      children: [
                        for (int num in equipStats.toJson().values)
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(num.toString()),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class RarityTile extends StatelessWidget {
  /// 稀有度
  const RarityTile(
    this.initialState, {
    Key? key,
  }) : super(key: key);

  final HerodetailState initialState;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey.shade200,
      title: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("稀有度"),
          Consumer(
            builder: (context, ref, child) {
              int rarity = ref.watch(heroDetailPageProvider(initialState)
                  .select((value) => value.rarity));

              return Expanded(
                child: Slider(
                  value: rarity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: rarity.toString(),
                  onChanged: (double value) {},
                  onChangeEnd: (double value) => ref
                      .read(heroDetailPageProvider(initialState).notifier)
                      .changeProp(
                        HerodetailPropChanged(rarity: value.round()),
                      ),
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              Person hero = ref.watch(heroDetailPageProvider(initialState)
                  .select((value) => value.hero));

              return hero.minRarity == 0
                  ? hero.maxRarity == 0
                      ? const Text("暂未添加")
                      : Tooltip(
                          message: PersonType.values[hero.type].name,
                          child: Row(
                            children: [
                              UniImage(
                                  path: p.join("assets", "static",
                                      "Rarity${hero.maxRarity}.png"),
                                  height: 20),
                            ],
                          ),
                        )
                  : Tooltip(
                      message: PersonType.values[hero.type].name,
                      child: Row(
                        children: [
                          UniImage(
                              path: p.join("assets", "static",
                                  "Rarity${hero.minRarity}.png"),
                              height: 20),
                          const Text("--"),
                          UniImage(
                              path: p.join("assets", "static",
                                  "Rarity${hero.maxRarity}.png"),
                              height: 20),
                        ],
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
