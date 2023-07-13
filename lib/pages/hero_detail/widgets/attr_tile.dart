import 'package:feh_rebuilder/core/enum/person_type.dart';
import 'package:feh_rebuilder/core/enum/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/hero_detail/controller.dart';
import 'package:feh_rebuilder/pages/hero_detail/widgets/circle_btn.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/picker.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'desc_widget.dart';

class AttrTile extends ConsumerWidget {
  /// 显示属性的tile，包括头像，类型，性格，突破等
  const AttrTile(this.family, {super.key});

  final PersonBuild family;

  Future changeMerged(
      BuildContext context, HeroDetailPageNotifier notifier, int merged) async {
    List<int?>? _ = await showModalBottomSheet(
        context: context,
        builder: (context1) => Picker(
              title: const Text("突破极限"),
              body: [
                {
                  "minValue": 0,
                  "maxValue": 10,
                  "value": merged,
                  "textMapper": (String key) {
                    return key;
                  }
                }
              ],
            ));
    if (_ != null) {
      notifier.changeProp(HerodetailPropChanged(merged: _[0]));
    }
  }

  Future chooseAscendAsset(
    BuildContext context,
    HeroDetailPageNotifier notifier,
    String? advantage,
    String? disAdvantage,
    String? ascendedAsset,
  ) async {
    List<String> statsList = [
      "N/A",
      for (var stat in StatsEnum.values.sublist(0, 5)) stat.name.toLowerCase()
    ];
    List<int?>? _ = await showModalBottomSheet(
        context: context,
        builder: (context1) => Picker(
              nullIndex: 0,
              title: const Text("优势/劣势"),
              body: [
                {
                  "minValue": 0,
                  "maxValue": 5,
                  "value": statsList.indexOf(advantage ?? "N/A"),
                  "textMapper": (String key) {
                    return int.parse(key) == 0
                        ? statsList[int.parse(key)]
                        : "+${"CUSTOM_STATS_${statsList[int.parse(key)].toUpperCase()}".tr}";
                  }
                },
                {
                  "minValue": 0,
                  "maxValue": 5,
                  "value": statsList.indexOf(disAdvantage ?? "N/A"),
                  "textMapper": (String key) {
                    return int.parse(key) == 0
                        ? statsList[int.parse(key)]
                        : "-${"CUSTOM_STATS_${statsList[int.parse(key)].toUpperCase()}".tr}";
                  }
                },
              ],
            ));
    if (_ != null) {
      if (statsList[_[0]!].toLowerCase() != ascendedAsset) {
        notifier.changeProp(HerodetailPropChanged(
          advantage: () => _[0] == 0 ? null : statsList[_[0]!],
          disAdvantage: () => _[1] == 0 ? null : statsList[_[1]!],
        ));
      } else {
        Utils.showToast("开花属性和优势属性不能相同");
      }
    }
  }

  Future chooseDragonFlowers(BuildContext context,
      HeroDetailPageNotifier notifier, int maxCount, int dragonflowers) async {
    List<int?>? _ = await showModalBottomSheet(
        context: context,
        builder: (context1) => Picker(
              title: const Text("神龙之花"),
              body: [
                {
                  "minValue": 0,
                  "maxValue": maxCount,
                  "value": dragonflowers,
                  "textMapper": (String key) {
                    return key;
                  }
                }
              ],
            ));
    if (_ != null) {
      notifier.changeProp(HerodetailPropChanged(dragonflowers: _[0]));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var hero = ref.watch(heroDetailPageProvider(family)
        .select((value) => value.valueOrNull!.hero));

    return Row(
      children: [
        const Padding(padding: EdgeInsets.only(left: 10)),
        Consumer(
          builder: (context, ref, child) {
            var (resplendent) = ref.watch(heroDetailPageProvider(family)
                .select((value) => (value.valueOrNull!.resplendent)));

            return hero.resplendentHero ?? false
                ? IndexedStack(
                    index: resplendent ? 0 : 1,
                    children: [
                      DescWidget(
                        heroTag: hero.idTag!,
                        resplendent: true,
                        version: hero.versionNum!,
                        type: (hero.minRarity == 0 && hero.maxRarity == 0)
                            ? null
                            : PersonType.values[hero.type],
                        child: ClipOval(
                          child: UniImage(
                              path: p
                                  .join("assets", "faces",
                                      "${hero.faceName ?? ""}EX01.webp")
                                  .replaceAll(r"\", "/"),
                              height: 50),
                        ),
                      ),
                      DescWidget(
                        heroTag: hero.idTag!,
                        resplendent: false,
                        version: hero.versionNum!,
                        type: (hero.minRarity == 0 && hero.maxRarity == 0)
                            ? null
                            : PersonType.values[hero.type],
                        child: ClipOval(
                          child: UniImage(
                              path: p
                                  .join("assets", "faces",
                                      "${hero.faceName ?? ""}.webp")
                                  .replaceAll(r"\", "/"),
                              height: 50),
                        ),
                      ),
                    ],
                  )
                : DescWidget(
                    heroTag: hero.idTag!,
                    resplendent: false,
                    version: hero.versionNum!,
                    type: (hero.minRarity == 0 && hero.maxRarity == 0)
                        ? null
                        : PersonType.values[hero.type],
                    child: ClipOval(
                      child: UniImage(
                          path: p
                              .join("assets", "faces",
                                  "${hero.faceName ?? ""}.webp")
                              .replaceAll(r"\", "/"),
                          height: 50),
                    ),
                  );
          },
        ),

        const SizedBox(
          width: 5,
        ),
        // 武器和移动类型
        Column(
          children: [
            UniImage(
                path: p
                    .join("assets", "move", "${hero.moveType ?? ""}.webp")
                    .replaceAll(r"\", "/"),
                height: 25),
            const SizedBox(
              height: 5,
            ),
            UniImage(
                path: p
                    .join("assets", "weapon", "${hero.weaponType ?? ""}.webp")
                    .replaceAll(r"\", "/"),
                height: 25),
          ],
        ),
        Consumer(
          builder: (context, ref, child) {
            var (merged) = ref.watch(heroDetailPageProvider(family)
                .select((value) => (value.valueOrNull!.merged)));

            return CircleBtn(
              title: "突破极限",
              text: merged.toString(),
              onPressed: () => changeMerged(
                context,
                ref.read(heroDetailPageProvider(family).notifier),
                merged,
              ),
            );
          },
        ),

        const SizedBox(
          width: 5,
        ),
        // 性格按钮
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Consumer(
            builder: (context, ref, child) {
              var (advantage, disAdvantage, ascendedAsset) =
                  ref.watch(heroDetailPageProvider(family).select((value) => (
                        value.valueOrNull!.advantage,
                        value.valueOrNull!.disAdvantage,
                        value.valueOrNull!.ascendedAsset,
                      )));

              return SizedBox(
                width: 110,
                child: TextButton(
                  style: ButtonStyle(
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(15)),
                    side: MaterialStateProperty.all(const BorderSide()),
                  ),
                  onPressed: () => chooseAscendAsset(
                    context,
                    ref.read(heroDetailPageProvider(family).notifier),
                    advantage,
                    disAdvantage,
                    ascendedAsset,
                  ),
                  child: advantage == null && disAdvantage == null
                      ? Text("CUSTOM_STATS_NULL".tr)
                      : Text("+%s-%s".fill([
                          "CUSTOM_STATS_${(advantage ?? "NULL").toUpperCase()}"
                              .tr,
                          "CUSTOM_STATS_${(disAdvantage ?? "NULL").toUpperCase()}"
                              .tr
                        ])),
                ),
              );
            },
          ),
        ),

        const SizedBox(
          width: 5,
        ),

        Consumer(
          builder: (context, ref, child) {
            var (dragonflowers) = ref.watch(heroDetailPageProvider(family)
                .select((value) => (value.valueOrNull!.dragonflowers)));

            return CircleBtn(
              title: "神龙之花",
              text: dragonflowers.toString(),
              onPressed: () => chooseDragonFlowers(
                context,
                ref.read(heroDetailPageProvider(family).notifier),
                hero.dragonflowers!.maxCount!,
                dragonflowers,
              ),
            );
          },
        ),
      ],
    );
  }
}
