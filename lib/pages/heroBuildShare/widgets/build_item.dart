import 'dart:io';

import 'package:cloud_db/cloud_db.dart';
import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/build_share/favorite_table.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/pages/heroBuildShare/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class BuildItem extends StatelessWidget {
  const BuildItem({
    Key? key,
    required this.heroBuild,
  }) : super(key: key);
  final HeroBuild heroBuild;

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

    String avatarPath = heroBuild.personBuild.resplendent
        ? "${Get.find<DataService>().appPath.path}/${"assets/faces/${heroBuild.person.faceName}EX01.webp"}"
        : "${Get.find<DataService>().appPath.path}/${"assets/faces/${heroBuild.person.faceName}.webp"}";
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
                      Image(
                        image: heroBuild.personBuild.summonerSupport
                            ? const AssetImage("assets/static/Wdw_Reliance.png")
                            : const AssetImage("assets/static/Wdw_5.png"),
                        height: 60,
                      ),
                      Image(
                        image: FileImage(File(avatarPath)),
                        height: 55,
                      ),
                      Image(
                        image: heroBuild.personBuild.summonerSupport
                            ? const AssetImage("assets/static/Frm_Reliance.png")
                            : const AssetImage("assets/static/Frm_5.png"),
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
                            child: Text("+${heroBuild.personBuild.merged}")),
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
                                "+${heroBuild.personBuild.dragonflowers}")),
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
                  Text(
                    heroBuild.tableData.title ?? "",
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("竞技场分数：${heroBuild.personBuild.arenaScore}"),
                      Text("总SP：$allSp"),
                    ],
                  ))
                ],
              ),
              if (Cloud().currentUser.username == heroBuild.tableData.creator)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () async {
                        var controller =
                            Get.find<HeroBuildSharePageController>();
                        controller.throttle(() => controller.delete(
                            context, heroBuild.tableData.objectId!));
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
          if ((heroBuild.tableData.tags?.objects ?? []).isNotEmpty)
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var tag in heroBuild.tableData.tags!.objects)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      child: Chip(
                          label: Text(
                        Get.find<DataService>().cloudTags[tag] ?? "",
                      )),
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
                    "${("CUSTOM_STATS_" + stat.key.toUpperCase()).tr}:${stat.value}",
                    style: TextStyle(
                      color: getStatCol(
                        stat.key,
                        heroBuild.personBuild.merged,
                        heroBuild.personBuild.advantage,
                        heroBuild.personBuild.disAdvantage,
                        heroBuild.personBuild.ascendedAsset,
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
                  category: i == 3 ? 15 : i,
                  skill: heroBuild.skills[i == 3 ? 7 : i],
                ),
                _SkillTile(
                  category: i + 3,
                  skill: heroBuild.skills[i + 3],
                ),
              ],
            ),
          _ItemActions(
            // 这里要传入一个key，否则删除的时候会因为模型深度问题认为参数相等而不重建
            key: UniqueKey(),
            objectId: heroBuild.tableData.objectId!,
            likeId: heroBuild.tableData.likes!.objectId,
            creator: heroBuild.tableData.creator ?? "",
            onAdd: () {
              Get.find<HeroBuildSharePageController>()
                  .addToFavorite(heroBuild.tableData.build ?? "");
            },
            count: heroBuild.tableData.likes!.content!.count!,
          ),
        ],
      ),
    );
  }
}

class _ItemActions extends StatefulWidget {
  const _ItemActions({
    Key? key,
    required this.objectId,
    required this.count,
    required this.creator,
    required this.likeId,
    required this.onAdd,
  }) : super(key: key);

  final int count;

  final String creator;
  final String objectId;
  final String likeId;
  final Function() onAdd;

  @override
  _ItemActionsState createState() => _ItemActionsState();
}

class _ItemActionsState extends State<_ItemActions> {
  late bool like;
  late bool dislike;
  late int count;
  late int type;
  Map<String, FavoriteTable> favorites = Get.find<DataService>().favorites;

  @override
  void initState() {
    type = favorites[widget.objectId]?.type! ?? 0;
    like = type == 1 ? true : false;
    dislike = type == -1 ? true : false;
    count = widget.count;
    super.initState();
  }

  Future onClick(int btnType) async {
    int newType = btnType == type ? 0 : btnType;
    int amount = newType - type;

    var r = await Batch(tasks: [
      favorites[widget.objectId] == null
          ? BatchTask(
              method: BatchMethod.POST,
              path: "/1/classes/favorite",
              body: {
                "user": Cloud().currentUser.username,
                "type": newType,
                "build":
                    BPointer(className: "hero_build", objectId: widget.objectId)
                        .toJson(),
              },
            )
          : BatchTask(
              method: BatchMethod.PUT,
              path:
                  "/1/classes/favorite/${favorites[widget.objectId]!.objectId}",
              body: {
                "type": newType,
              },
            ),
      BatchTask(
        method: BatchMethod.PUT,
        path: "/1/classes/likes/${widget.likeId}",
        body: {
          "count": {
            "__op": "Increment",
            "amount": amount,
          },
        },
      ),
    ]).doTasks();

    setState(() {
      count += amount;
      type = newType;
      favorites[widget.objectId] == null
          ? favorites.addAll({
              widget.objectId: FavoriteTable(
                  type: type,
                  createdAt: (r[0].result as PostResult).createdAt,
                  objectId: (r[0].result as PostResult).objectId)
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
              Get.find<HeroBuildSharePageController>().throttle(() async {
                await onClick(1);
              });
            },
            // onPressed: () => onClick(true),
            icon: Icon(
              Icons.thumb_up,
              color: type == 1 ? Colors.green : null,
            )),
        Text(count.toString()),
        IconButton(
            onPressed: () async {
              Get.find<HeroBuildSharePageController>().throttle(() async {
                await onClick(-1);
              });
            },
            icon: Icon(
              Icons.thumb_down,
              color: type == -1 ? Colors.red : null,
            )),
        const Spacer(),
        IconButton(
            onPressed: () => widget.onAdd.call(),
            icon: const Icon(Icons.download_for_offline)),
      ],
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

  String get iconPath {
    if (skill == null) {
      String _p;
      _p = category == 15
          ? "assets/static/no-blessing.webp"
          : category < 3
              // todo 由于资源变体的影响，这里会被其他文件替代，所以前面加了n，以后改掉
              ? "assets/static/n$category.webp"
              : "assets/static/$category.png";
      return p.join(_p);
    } else {
      return p.join(
          Get.find<DataService>().appPath.path,
          category == 15
              ? "assets/blessing/${skill!.iconId}.webp"
              : category < 3
                  ? "assets/icons/${category + 1}.webp"
                  : "assets/icons/${skill!.iconId}.webp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          skill == null
              ? Image(
                  image: AssetImage(iconPath),
                  height: 20,
                )
              : Image(
                  image: FileImage(File(iconPath)),
                  height: 20,
                ),
          Text((skill?.nameId ?? "").tr),
        ],
      ),
    );
  }
}
