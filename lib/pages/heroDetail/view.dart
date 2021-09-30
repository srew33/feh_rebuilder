import 'dart:io';
import 'package:feh_tool/models/personBuild/personBuild.dart';
import 'package:feh_tool/pages/heroDetail/widgets/heroIcon.dart';
import 'package:feh_tool/global/enum/moveType.dart';
import 'package:feh_tool/global/enum/weaponType.dart';
import 'package:feh_tool/global/filters/skill.dart';
import 'package:feh_tool/models/person/person.dart';
import 'package:feh_tool/models/skill/skill.dart';
import 'package:feh_tool/pages/heroDetail/widgets/picker.dart';
import 'package:feh_tool/pages/heroDetail/widgets/customBtn.dart';
import 'package:feh_tool/pages/skillsBrowse/controller.dart';
import 'package:feh_tool/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class HeroDetail extends GetView<HeroDetailController> {
  Future<List<int?>?> _showPicker(
    BuildContext context, {
    Widget? title,
    required List<Map> body,
    int? nullIndex,
  }) async {
    return await showModalBottomSheet<List<int?>?>(
        context: context,
        builder: (context) {
          return Picker(
            body: body,
            title: title,
            nullIndex: nullIndex,
          );
        });
  }

  Widget _buildAvatar(String path, double height) {
    return Image.file(
      File("${controller.data.appPath.path}/$path"),
      errorBuilder: (context, obj, s) => Icon(Icons.error),
      height: height,
    );
  }

  ///根据属性成长率设定文字颜色
  Color? getPropColor(String propName) {
    if (Utils.advantageList.contains(controller.growthMap[propName])) {
      return Colors.green.shade800;
    }
    if (Utils.disAdvantageList.contains(controller.growthMap[propName])) {
      return Colors.red;
    }
    return null;
  }

  List<Widget> _buildActions() {
// controller.build.equipSkills
    return [
      controller.build.custom
          ? IconButton(
              onPressed: () {
                PersonBuild? newBuild =
                    controller.addToFavorite(controller.build.timeStamp);
                if (newBuild != null) {
                  Get.back(result: newBuild);
                }
              },
              icon: Icon(Icons.save),
            )
          : IconButton(
              onPressed: () {
                if (controller.addToFavorite() != null) {
                  ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("成功")],
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    duration: Duration(seconds: 1),
                  ));
                  // Get.snackbar("", "添加成功",
                  //     snackPosition: SnackPosition.BOTTOM);
                }
              },
              icon: Icon(
                Icons.favorite_border,
              ),
            )
    ];
  }

  List<Widget> _buildStats() {
    return [
      ListTile(
        title: Text("数值"),
        tileColor: Colors.grey.shade200,
      ),
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("召唤师的羁绊"),
            Switch(
              value: controller.isSummonerSupport,
              onChanged: (bool newVal) =>
                  controller.setSummmonerSupport(newVal),
            )
          ],
        ),
      ),
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("神装英雄"),
            Switch(
              value: controller.isResplendent,
              // onChanged: (bool newVal) => _.resplendent = newVal,
              onChanged: controller.hero.resplendentHero!
                  ? (bool newVal) => controller.setResplendent(newVal)
                  : null,
            )
          ],
        ),
      ),
      // 数值显示部分
      ListTile(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: "竞技场", style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: controller.bst.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ])),
                FittedBox(
                  child: Row(
                    children: [
                      for (String propName in controller.growthMap.keys)
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              propName.toUpperCase(),
                              style: TextStyle(color: getPropColor(propName)),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("基础数值"),
                FittedBox(
                  child: Row(
                    children: [
                      for (int num in controller.baseStats.toJson().values)
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(num.toString()),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("装备数值"),
                FittedBox(
                  child: Row(
                    children: [
                      for (int num in controller.equipStats.toJson().values)
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(num.toString()),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      )
    ];
  }

  List<Widget> _buildUniqueEffect() {
    List<Widget> widgetList = [];

    if (controller.hero.legendary != null) {
      widgetList.add(ListTile(
        title: Text("常驻效果"),
        tileColor: Colors.grey.shade200,
      ));

      widgetList.add(ListTile(
          title:
              Text("MPID_LEGEND_${controller.hero.idTag!.split("_")[1]}".tr)));

      // 技能
      if (controller.hero.legendary!.duoSkillId != null) {
        widgetList.add(ExpansionTile(
          title: Text("特殊技能效果"),
          children: [
            ListTile(
              title: Text(
                  "MSID_H_${controller.hero.legendary!.duoSkillId!.split("_")[1]}"
                      .tr
                      .replaceAll(r"$a", "")),
            )
          ],
        ));
      }
    }
    return widgetList;
  }

  ///头像、突破、性格等
  Widget _buildBaseInfo() {
    return Row(
      children: [
        Padding(padding: EdgeInsets.only(left: 10)),
        // 头像
        IndexedStack(
          index: controller.isResplendent ? 0 : 1,
          children: [
            ClipOval(
              child: _buildAvatar(
                  "assets/faces/${controller.hero.faceName}EX01.webp", 50),
            ),
            ClipOval(
                child: _buildAvatar(
                    "assets/faces/${controller.hero.faceName}.webp", 50)),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        // 武器和移动类型
        Column(
          children: [
            _buildAvatar("assets/move/${controller.hero.moveType}.webp", 25),
            SizedBox(
              height: 5,
            ),
            _buildAvatar(
                "assets/weapon/${controller.hero.weaponType}.webp", 25),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        // 突破
        CircleBtn(
          key: controller.mergeBtnKey,
          displayValue: "+${controller.merged.toString()}",
          title: "突破极限",
          height: 20,
          titleSize: 10,
          onPressed: () async {
            List<int?>? _merge =
                await _showPicker(Get.context!, title: Text("突破极限"), body: [
              {"minValue": 0, "maxValue": 10, "value": controller.merged},
            ]);
            if (_merge != null) {
              // _showPicker相对于CircleBtn是独立的，因此无法直接获取到结果
              // 如果不在这里使用currentState需要在CircleBtn里调用_showPicker，
              controller.mergeBtnKey.currentState!
                  .setNewDisplay("+${_merge[0].toString()}");
              controller.merged = _merge[0]!;
              controller.calBaseStats();
            }
          },
        ),
        SizedBox(
          width: 10,
        ),
        // 性格
        TraitsBtn(
          key: controller.traitsBtnKey,
          onPressed: () async {
            // picker里面已经设置结果不可重复，这里不需判断
            List<int?>? _result = await _showPicker(Get.context!,
                title: Text("优势/劣势"),
                nullIndex: 0,
                body: [
                  {
                    "minValue": 0,
                    "maxValue": 5,
                    "value": controller.advantage != null
                        ? controller.statsMap.values
                                .toList()
                                .indexOf(controller.advantage!) +
                            1
                        : 0,
                    "textMapper": (String key) {
                      return controller.statsMap[key] != null
                          ? "+" + controller.statsMap[key]!.toUpperCase()
                          : "N/A";
                    }
                  },
                  {
                    "minValue": 0,
                    "maxValue": 5,
                    "value": controller.disadvantage != null
                        ? controller.statsMap.values
                                .toList()
                                .indexOf(controller.disadvantage!) +
                            1
                        : 0,
                    "textMapper": (String key) {
                      return controller.statsMap[key] != null
                          ? "-" + controller.statsMap[key]!.toUpperCase()
                          : "N/A";
                    }
                  },
                ]);
            if (_result != null) {
              controller.advantage = _result[0] == null
                  ? null
                  : controller.statsMap[_result[0].toString()];
              controller.disadvantage = _result[0] == null
                  ? null
                  : controller.statsMap[_result[1].toString()];
              controller.traitsBtnKey.currentState!.setNewDisplay(
                  "+${controller.advantage ?? ""}-${controller.disadvantage ?? ""}");
              controller.calBaseStats();
            }
          },
          displayValue:
              "+${controller.advantage ?? "    "} -${controller.disadvantage ?? ""}",
        ),

        SizedBox(
          width: 10,
        ),
        // 神龙之花
        CircleBtn(
          key: controller.dragonBtnKey,
          displayValue: "+${controller.dragonFlower.toString()}",
          title: "神龙之花",
          height: 20,
          titleSize: 10,
          onPressed: () async {
            List<int?>? _dragonFlower =
                await _showPicker(Get.context!, title: Text("神龙之花"), body: [
              {
                "minValue": 0,
                "maxValue": controller.hero.dragonflowers!.maxCount!,
                "value": controller.dragonFlower
              },
            ]);
            if (_dragonFlower != null) {
              controller.dragonBtnKey.currentState!
                  .setNewDisplay("+${_dragonFlower[0].toString()}");
              controller.dragonFlower = _dragonFlower[0]!;
              controller.calBaseStats();
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildExclusiveTile() {
    return controller.origWeaponRefine.isNotEmpty
        ? [
            ListTile(
              title: Text("武器炼成"),
              tileColor: Colors.grey.shade200,
            ),
            for (Map<Skill, Skill> s in controller.origWeaponRefine)
              ExpansionTile(title: Text((s.keys.first.nameId!).tr), children: [
                ListTile(
                    title: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: (s.keys.first.descId!).tr.replaceAll("\n", ""),
                    style: TextStyle(),
                  ),
                  TextSpan(text: "\n"),
                  TextSpan(
                    text: (s.values.first.descId!).tr.replaceAll("\n", ""),
                    style: TextStyle(color: Colors.green),
                  ),
                ])))
              ]),
          ]
        : [SizedBox.shrink()];
  }

  Widget _buildIcon(int index, Skill? s) {
    switch (index) {
      case 0:
        return _buildAvatar("assets/icons/1.webp", 30);

      case 1:
        return _buildAvatar("assets/icons/2.webp", 30);

      case 2:
        return _buildAvatar("assets/icons/3.webp", 30);

      case 3:
        if (s == null) {
          return Image.asset(
            "assets/static/3.png",
            errorBuilder: (context, obj, s) => Icon(Icons.error),
            height: 25,
          );
        }
        return _buildAvatar("assets/icons/${s.iconId}.webp", 30);

      case 4:
        if (s == null) {
          return Image.asset(
            "assets/static/4.png",
            errorBuilder: (context, obj, s) => Icon(Icons.error),
            height: 25,
          );
        }
        return _buildAvatar("assets/icons/${s.iconId}.webp", 30);

      case 5:
        if (s == null) {
          return Image.asset(
            "assets/static/5.png",
            errorBuilder: (context, obj, s) => Icon(Icons.error),
            height: 25,
          );
        }
        return _buildAvatar("assets/icons/${s.iconId}.webp", 30);

      case 6:
        if (s == null) {
          return Image.asset(
            "assets/static/6.png",
            errorBuilder: (context, obj, s) => Icon(Icons.error),
            height: 25,
          );
        }
        return _buildAvatar("assets/icons/${s.iconId}.webp", 30);

      case 7:
        return s == null
            ? _buildAvatar("assets/blessing/0.webp", 30)
            : _buildAvatar("assets/blessing/${s.iconId}.webp", 30);

      default:
        return SizedBox.shrink();
    }
  }

  /// 竞技场分数
  ListTile _buildArenaTile() {
    return ListTile(
      title: Row(
        children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: "竞技场分数 ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: controller.arenaScore.toString(),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ])),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text.rich(
              TextSpan(children: <InlineSpan>[
                TextSpan(text: "总SP ", style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: controller.allSpCost.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSkill() {
    return [
      ListTile(
        title: Text("技能配置"),
        tileColor: Colors.grey.shade200,
      ),
      for (int index = 0; index < (controller.hasLegendEffect ? 7 : 8); index++)
        controller.heroSkills[index] != null
            ? ExpansionTile(
                title: Row(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildIcon(index, controller.heroSkills[index]),
                    // 技能名称+威力/冷却
                    Text("${(controller.heroSkills[index]!.nameId!).tr} ${controller.heroSkills[index]!.might! > 0 && controller.heroSkills[index]!.category == 0 ? [
                        controller.heroSkills[index]!.might
                      ] : ""}${controller.heroSkills[index]!.cooldownCount! > 0 && controller.heroSkills[index]!.category! == 2 ? [controller.heroSkills[index]!.cooldownCount] : ""}"),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        controller.delSkill(controller.heroSkills[index]!);
                      },
                      icon: Icon(Icons.delete),
                      iconSize: 15,
                    )
                  ],
                ),
                children: [
                  ListTile(
                    title: Text.rich(TextSpan(children: [
                      if (index != 7)
                        TextSpan(
                            text:
                                "SP:${controller.heroSkills[index]!.spCost.toString()}\n"),
                      // 技能描述
                      TextSpan(
                          text: (controller.heroSkills[index]!.descId!)
                              .tr
                              .replaceAll("\n", "")
                              .replaceAll(r"$a", "")),
                      // 技能特效描述
                      if (controller.heroSkills[index]!.refineId != null)
                        TextSpan(
                          text: "\n" +
                              (("MSID_H_${controller.heroSkills[index]!.refineId!.split("_")[1]}")
                                      .tr)
                                  .replaceAll("\n", "")
                                  .replaceAll(r"$a", ""),
                          style: TextStyle(color: Colors.green),
                        ),
                      if (controller.heroSkills[index]!.exclusive!)
                        TextSpan(
                          text: "\n无法继承",
                          style: TextStyle(color: Colors.red),
                        ),
                    ])),
                  ),
                  if (controller.heroSkills[index]!.rarity3 != null)
                    if (controller.heroSkills[index]!.rarity3!.isNotEmpty)
                      ListTile(
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            Image.asset("assets/static/Rarity3.png"),
                            for (int i = 0;
                                i <
                                    controller
                                        .heroSkills[index]!.rarity3!.length;
                                i++)
                              HeroIcon(
                                person: Person.fromJson(
                                    controller.data.personBox.read(controller
                                        .heroSkills[index]!.rarity3![i])),
                                appPath: controller.data.appPath.path,
                              ),
                          ],
                        ),
                      ),
                  if (controller.heroSkills[index]!.rarity4 != null)
                    if (controller.heroSkills[index]!.rarity4!.isNotEmpty)
                      ListTile(
                        title: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            Image.asset("assets/static/Rarity4.png"),
                            for (int i = 0;
                                i <
                                    controller
                                        .heroSkills[index]!.rarity4!.length;
                                i++)
                              HeroIcon(
                                person: Person.fromJson(
                                    controller.data.personBox.read(controller
                                        .heroSkills[index]!.rarity4![i])),
                                appPath: controller.data.appPath.path,
                              ),
                          ],
                        ),
                      ),
                  if (controller.heroSkills[index]!.rarity5 != null)
                    if (controller.heroSkills[index]!.rarity5!.isNotEmpty)
                      ListTile(
                        title: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Image.asset("assets/static/Rarity5.png"),
                            for (int i = 0;
                                i <
                                    controller
                                        .heroSkills[index]!.rarity5!.length;
                                i++)
                              HeroIcon(
                                person: Person.fromJson(
                                    controller.data.personBox.read(controller
                                        .heroSkills[index]!.rarity5![i])),
                                appPath: controller.data.appPath.path,
                              ),
                          ],
                        ),
                      ),
                ],
              )
            : ListTile(
                title: Row(
                  children: [_buildIcon(index, null)],
                ),
                onTap: () async {
                  dynamic newSkill = await Get.toNamed("/skillsBrowse",
                      arguments: SkillChooseConfig(
                          // category 是一些特殊技能，祝福的category是15
                          category: index == 7 ? 15 : index,
                          selectMode: true,
                          exclusiveSkills: {
                            // 这里不能直接用controller.heroskills，
                            // 因为heroskills是动态的会被修改
                            // 使用set是为了过滤重复技能
                            // 从数据库读取refineBase对应技能是因为这里的技能是锻造后的武器
                            // 为了显示全部可锻造武器必须读取锻造前的技能
                            for (Map<Skill, Skill> refine
                                in controller.origWeaponRefine)
                              Skill.fromJson(controller.data.skillBox
                                      .read(refine.keys.first.refineBase!))
                                  .idTag!,
                            for (Skill? s in controller.origHeroSkills)
                              if (s != null)
                                if (s.exclusive!) s.idTag!
                          }.cast<String>().toList(),
                          filters: [
                            SkillFilter(
                                filterType: SkillFilterType.moveType,
                                valid: {
                                  MoveTypeEnum.values[controller.hero.moveType!]
                                }),
                            SkillFilter(
                                filterType: SkillFilterType.weaponType,
                                valid: {
                                  WeaponTypeEnum
                                      .values[controller.hero.weaponType!]
                                }),
                            SkillFilter(
                                filterType: SkillFilterType.showExclusive,
                                valid: false)
                          ]));
                  controller.setSkill(index, newSkill as Skill?);
                },
              )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HeroDetailController>(
        init: controller,
        builder: (controller) => Scaffold(
              appBar: AppBar(
                title: Text(("MPID_HONOR_" + controller.heroName).tr +
                    "  " +
                    ("MPID_" + controller.heroName).tr),
                // 右上角按钮
                actions: _buildActions(),
              ),
              body: ListView(
                children: ListTile.divideTiles(context: context, tiles: [
                  // 头像、性格等，
                  _buildBaseInfo(),
                  // 数值显示
                  for (Widget w in _buildStats()) w,

                  // 比翼、传承、神阶效果
                  for (Widget w in _buildUniqueEffect()) w,
                  // 武器炼成
                  for (Widget w in _buildExclusiveTile()) w,
                  // _ExclusiveCard(),
                  // 角色技能
                  for (Widget w in _buildSkill()) w,
                  // ArenaTile(),
                  // 竞技场分数
                  _buildArenaTile(),
                ]).toList(),
              ),
            ));
  }
}
