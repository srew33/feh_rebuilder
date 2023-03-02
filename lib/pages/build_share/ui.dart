import 'package:feh_rebuilder/models/build_share/favorite_table.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/build_share/controller.dart';
import 'package:feh_rebuilder/pages/fav/body/first/controller.dart';
import 'package:feh_rebuilder/repositories/net_service/service.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';

class HeroBuildSharePage extends StatelessWidget {
  const HeroBuildSharePage({
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
            var asyncState = ref.watch(buildShareProvider(heroTag));
            return asyncState.when(
              data: (state) => state.buildList.isEmpty
                  ? const Center(
                      child: Text("空空如也"),
                    )
                  : ListView.builder(
                      itemCount: state.buildList.length,
                      itemBuilder: (context, index) => _BuildItem(
                        heroBuild: state.buildList[index],
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

class _BuildItem extends ConsumerStatefulWidget {
  const _BuildItem({
    Key? key,
    required this.heroBuild,
  }) : super(key: key);
  final BuildShareVM heroBuild;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __BuildItemState();
}

class __BuildItemState extends ConsumerState<_BuildItem> {
  late BuildShareVM heroBuild;

  @override
  void initState() {
    heroBuild = widget.heroBuild;
    super.initState();
  }

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
  Widget build(BuildContext context) {
    int allSp = heroBuild.skills.fold(
        0, (previousValue, element) => previousValue + (element?.spCost ?? 0));

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
                        path: heroBuild.netBuild.build.summonerSupport
                            ? "assets/static/Wdw_Reliance.png"
                            : "assets/static/Wdw_5.png",
                        height: 60,
                      ),
                      UniImage(
                        path: heroBuild.netBuild.build.resplendent
                            ? "assets/faces/${heroBuild.person.faceName}EX01.webp"
                            : "assets/faces/${heroBuild.person.faceName}.webp",
                        height: 55,
                      ),
                      UniImage(
                        path: heroBuild.netBuild.build.summonerSupport
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
                            child: Text("+${heroBuild.netBuild.build.merged}")),
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
                                "+${heroBuild.netBuild.build.dragonflowers}")),
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
                      Text("竞技场分数：${(150 + heroBuild.arenaScore).floor() * 2}"),
                      Text("总SP：$allSp"),
                    ],
                  ))
                ],
              ),
              if (ref.read(netProvider).currentUser ==
                  heroBuild.netBuild.creator)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      // 删除按钮
                      onPressed: () async {
                        await ref
                            .read(buildShareProvider(heroBuild.person.idTag!)
                                .notifier)
                            .deleteBuild(heroBuild.netBuild.objectId!);
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      )),
                )
            ],
          ),
          const SizedBox(
            height: 3,
          ),
          if ((heroBuild.netBuild.tags).isNotEmpty)
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var tag in heroBuild.netBuild.tags)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      child: Chip(
                        label: Text(
                          ref.read(netProvider).tags[tag] ?? "",
                        ),
                      ),
                    )
                ],
              ),
            ),
          const SizedBox(
            height: 3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var stat in heroBuild.stats.toJson().entries)
                FittedBox(
                  child: Text(
                    "${("CUSTOM_STATS_${stat.key.toUpperCase()}").tr}:${stat.value}",
                    style: TextStyle(
                      color: getStatCol(
                        stat.key,
                        heroBuild.netBuild.build.merged,
                        heroBuild.netBuild.build.advantage,
                        heroBuild.netBuild.build.disAdvantage,
                        heroBuild.netBuild.build.ascendedAsset,
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
          _ItemActions(
            // 这里要传入一个key，否则删除的时候不会重建
            key: UniqueKey(),
            objectId: heroBuild.netBuild.objectId!,
            likesId: heroBuild.netBuild.likesId,
            creator: heroBuild.netBuild.creator,
            onDownload: () async {
              try {
                await ref
                    .read(favFirstProvider.notifier)
                    .saveBuild(build: heroBuild.netBuild.build);

                Utils.showToast("成功");
              } on Exception catch (e) {
                Utils.showToast(e.toString());
              }
            },
            count: heroBuild.netBuild.count,
          ),
        ],
      ),
    );
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

class _ItemActions extends ConsumerStatefulWidget {
  const _ItemActions({
    Key? key,

    /// build的objectId
    required this.objectId,
    required this.count,
    required this.creator,
    required this.likesId,
    required this.onDownload,
  }) : super(key: key);

  final int count;

  final String creator;
  final String objectId;
  final String likesId;
  final Future<void> Function() onDownload;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ItemActionsState();
}

class _ItemActionsState extends ConsumerState<_ItemActions> {
  late bool like;
  late bool dislike;
  late int count;
  late int type;

  late Map<String, NetFavoriteBusinessModel> favorites;

  @override
  void initState() {
    favorites = ref.read(netProvider).favourites;
    type = favorites[widget.objectId]?.type ?? 0;
    like = type == 1 ? true : false;
    dislike = type == -1 ? true : false;
    count = widget.count;
    super.initState();
  }

  Future onClick(BuildContext context, int btnType) async {
    int newType = btnType == type ? 0 : btnType;
    int amount = newType - type;

    var r = await ref.read(netProvider).starBuild(
          favorites[widget.objectId]?.objectId!,
          widget.objectId,
          widget.likesId,
          newType,
          amount,
        );

    setState(() {
      count += amount;
      type = newType;
      favorites[widget.objectId] == null
          ? favorites.addAll({
              widget.objectId: NetFavoriteBusinessModel(
                buildId: widget.objectId,
                type: type,
                user: ref.read(netProvider).currentUser,
                objectId: r[0].objectId,
              )
            })
          : favorites[widget.objectId]!.type = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () async {
              await onClick(context, 1);
            },
            icon: Icon(
              Icons.thumb_up,
              color: type == 1 ? Colors.green : null,
            )),
        Text(count.toString()),
        IconButton(
            onPressed: () async {
              await onClick(context, -1);
            },
            icon: Icon(
              Icons.thumb_down,
              color: type == -1 ? Colors.red : null,
            )),
        const Spacer(),
        IconButton(
            onPressed: () => widget.onDownload.call(),
            icon: const Icon(Icons.download_for_offline)),
      ],
    );
  }
}
