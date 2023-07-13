import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/fav/body/first/controller.dart';
import 'package:feh_rebuilder/pages/fav/body/first/model.dart';
import 'package:feh_rebuilder/pages/local_builds/controller.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalBuildsPage extends StatelessWidget {
  const LocalBuildsPage({
    Key? key,
    required this.heroTag,
  }) : super(key: key);

  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("M${(heroTag)}".tr),
        ),
        body: Consumer(
          builder: (context, ref, child) {
            var asyncState = ref.watch(localBuildsPageProvider(heroTag));
            return asyncState.when(
              data: (state) => state.builds.isEmpty
                  ? const Center(
                      child: Text("空空如也"),
                    )
                  : ListView.builder(
                      itemCount: state.builds.length,
                      itemBuilder: (context, index) => _BuildItem(
                        heroBuild: state.builds[index],
                      ),
                    ),
              error: (error, stackTrace) =>
                  Center(child: Text("发生错误：\n${error.toString()}")),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BuildItem extends ConsumerWidget {
  const _BuildItem({
    required this.heroBuild,
  });
  final PersonBuildVM heroBuild;

  Color? getStatCol(
    String key,
    int merged, [
    String? advantage,
    String? disAdvantage,
    String? ascendedAsset,
  ]) {
    if (key == advantage) {
      return Colors.green;
    } else if (key == ascendedAsset) {
      return Colors.blue;
    } else if (key == disAdvantage && merged == 0) {
      // 只有在突破为0时才显示弱势性格，并且如果弱势性格和绽放相同则会优先显示绽放的颜色
      return Colors.red;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int allSp = heroBuild.skills.fold(
        0, (previousValue, element) => previousValue + (element?.spCost ?? 0));

    return FutureBuilder(
        future: heroBuild.getStats(ref.read(repoProvider).requireValue),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return const SizedBox.shrink();
          }
          return Card(
            child: Column(
              children: [
                Stack(
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            UniImage(
                              path: heroBuild.build.summonerSupport
                                  ? "assets/static/Wdw_Reliance.png"
                                  : "assets/static/Wdw_5.png",
                              height: 60,
                            ),
                            UniImage(
                              path: heroBuild.build.resplendent
                                  ? "assets/faces/${heroBuild.person.faceName}EX01.webp"
                                  : "assets/faces/${heroBuild.person.faceName}.webp",
                              height: 55,
                            ),
                            UniImage(
                              path: heroBuild.build.summonerSupport
                                  ? "assets/static/Frm_Reliance.png"
                                  : "assets/static/Frm_5.png",
                              height: 60,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: const ShapeDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(color: Colors.black),
                                ),
                              ),
                              child: Center(
                                  child: Text("+${heroBuild.build.merged}")),
                            ),
                            const Text(
                              "突破极限",
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: const ShapeDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(color: Colors.black),
                                ),
                              ),
                              child: Center(
                                  child: Text(
                                      "+${heroBuild.build.dragonflowers}")),
                            ),
                            const Text(
                              "神龙之花",
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        // Text(
                        //   heroBuild.objectId.title ?? "",
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "竞技场分数：${(150 + heroBuild.arenaScore).floor() * 2}"),
                            Text("总SP：$allSp"),
                          ],
                        ))
                      ],
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          // 删除按钮
                          onPressed: () async {
                            try {
                              await ref
                                  .read(favFirstProvider.notifier)
                                  .saveBuild(build: heroBuild.build);

                              Utils.showToast("成功");
                            } on Exception catch (e) {
                              Utils.showToast(e.toString());
                            }
                          },
                          icon: const Icon(
                            Icons.download_for_offline,
                            color: Colors.blue,
                          )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var stat in snapshot.data!.toJson().entries)
                      FittedBox(
                        child: Text(
                          "${("CUSTOM_STATS_${stat.key.toUpperCase()}").tr}:${stat.value}",
                          style: TextStyle(
                            color: getStatCol(
                              stat.key,
                              heroBuild.build.merged,
                              heroBuild.build.advantage,
                              heroBuild.build.disAdvantage,
                              heroBuild.build.ascendedAsset,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                for (var i = 0; i < 4; i++)
                  Row(
                    children: [
                      _SkillTile(
                        category: i == 3 ? 7 : i,
                        skill: heroBuild.skills[i == 3 ? 7 : i],
                      ),
                      // _SkillTile(
                      //   category: i == 3 ? 15 : i,
                      //   skill: heroBuild.skills[i == 3 ? 7 : i],
                      // ),
                      _SkillTile(
                        category: i + 3,
                        skill: heroBuild.skills[i + 3],
                      ),
                    ],
                  ),
              ],
            ),
          );
        });
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({
    Key? key,
    required this.category,
    this.skill,
  }) : super(key: key);
  final int category;
  final Skill? skill;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          skill == null
              ? UniImage(
                  path: "assets/skill_placeholder/$category.webp",
                  height: 20,
                )
              : skill!.category != 15
                  ? UniImage(
                      path: "assets/icons/${skill!.iconId}.webp",
                      height: 20,
                    )
                  : UniImage(
                      path: "assets/blessing/${skill!.iconId}.webp",
                      height: 20,
                    ),
          Text((skill?.nameId ?? "").tr),
        ],
      ),
    );
  }
}
