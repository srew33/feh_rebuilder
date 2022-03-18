import 'package:cloud_db/cloud_db.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/home_screens/favourites/bloc/favscreen_bloc.dart';
import 'package:feh_rebuilder/models/cloud_object/favorite_table.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/build_share/bloc/buildshare_bloc.dart';
import 'package:feh_rebuilder/repositories/api.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeroBuildSharePage extends StatelessWidget {
  const HeroBuildSharePage({
    Key? key,
    required this.hero,
  }) : super(key: key);
  final Person hero;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BuildshareBloc>(
      create: (context) => BuildshareBloc(
        repo: context.read<Repository>(),
        api: context.read<API>(),
        hero: hero,
      )..add(BuildshareStarted()),
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: BlocBuilder<BuildshareBloc, BuildshareState>(
                buildWhen: (previous, current) => false,
                builder: (context, state) {
                  return Text("M${(state.hero.idTag ?? "")}".tr);
                },
              ),
            ),
            body: BlocBuilder<BuildshareBloc, BuildshareState>(
              builder: (context, state) {
                return state.status == StateStatus.initial
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : state.buildList.isEmpty
                        ? const Center(
                            child: Text("空空如也"),
                          )
                        : ListView.builder(
                            itemCount: state.buildList.length,
                            itemBuilder: (context, index) => _BuildItem(
                                  heroBuild: state.buildList[index],
                                ));
              },
            )),
      ),
    );
  }
}

class _BuildItem extends StatelessWidget {
  const _BuildItem({
    Key? key,
    required this.heroBuild,
  }) : super(key: key);
  final BuildShareVM heroBuild;

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
                        path: heroBuild.personBuild.summonerSupport
                            ? "assets/static/Wdw_Reliance.png"
                            : "assets/static/Wdw_5.png",
                        height: 60,
                      ),
                      UniImage(
                        path: heroBuild.personBuild.resplendent
                            ? "assets/faces/${heroBuild.person.faceName}EX01.webp"
                            : "assets/faces/${heroBuild.person.faceName}.webp",
                        height: 55,
                      ),
                      UniImage(
                        path: heroBuild.personBuild.summonerSupport
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
                      Text("竞技场分数：${heroBuild.arenaScore}"),
                      Text("总SP：$allSp"),
                    ],
                  ))
                ],
              ),
              if (Cloud().currentUser.username == heroBuild.tableData.creator)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      // 删除按钮
                      onPressed: () async {
                        context.read<BuildshareBloc>().add(BuildshareDeleted(
                            objectId: heroBuild.tableData.objectId!));
                        // var controller =
                        //     Get.find<HeroBuildSharePageController>();
                        // controller.throttle(() => controller.delete(
                        //     context, heroBuild.tableData.objectId!));
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
                          context.read<API>().cloudTags[tag] ?? "",
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
            // 这里要传入一个key，否则删除的时候会因为模型深度问题认为参数相等而不重建
            key: UniqueKey(),
            objectId: heroBuild.tableData.objectId!,
            likeId: heroBuild.tableData.likes!.objectId,
            creator: heroBuild.tableData.creator ?? "",
            onAdd: () async {
              try {
                Repository repo = context.read<Repository>();

                await repo.favourites.putIfAbsent(
                    DateTime.now().millisecondsSinceEpoch.toString(),
                    heroBuild.personBuild.toJson());

                context.read<FavscreenBloc>().add(FavscreenStarted());
                Utils.showToast("成功");
              } on Exception catch (e) {
                Utils.showToast(e.toString());
              }
              // Get.find<HeroBuildSharePageController>()
              //     .addToFavorite(heroBuild.tableData.build ?? "");
            },
            count: heroBuild.tableData.likes!.content!.count!,
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

  late Map<String, FavoriteTable> favorites;

  @override
  void initState() {
    favorites = context.read<API>().favorites;
    type = favorites[widget.objectId]?.type! ?? 0;
    like = type == 1 ? true : false;
    dislike = type == -1 ? true : false;
    count = context.read<BuildshareBloc>().cacheCount[widget.objectId] ??
        widget.count;
    super.initState();
  }

  Future onClick(BuildContext context, int btnType) async {
    int newType = btnType == type ? 0 : btnType;
    int amount = newType - type;
    var r = await context.read<API>().doBatch([
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
    ]);
    if (r != null) {
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
        context
            .read<BuildshareBloc>()
            .add(BuildshareLiked(objectId: widget.objectId, newCount: count));
      });
    }
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
            onPressed: () => widget.onAdd.call(),
            icon: const Icon(Icons.download_for_offline)),
      ],
    );
  }
}
