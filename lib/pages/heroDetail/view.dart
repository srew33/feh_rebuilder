import 'dart:io';
import 'package:feh_rebuilder/global/theme/text_theme.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/pages/heroDetail/widgets/hero_icon.dart';
import 'package:feh_rebuilder/global/enum/move_type.dart';
import 'package:feh_rebuilder/global/enum/weapon_type.dart';
import 'package:feh_rebuilder/global/filters/skill.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/pages/heroDetail/widgets/picker.dart';
import 'package:feh_rebuilder/pages/heroDetail/widgets/custom_btn.dart';
import 'package:feh_rebuilder/pages/heroDetail/widgets/share_widget.dart';
import 'package:feh_rebuilder/pages/home/subview/favorite_controller.dart';
import 'package:feh_rebuilder/pages/skillsBrowse/controller.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class HeroDetail extends GetView<HeroDetailController> {
  const HeroDetail({Key? key}) : super(key: key);

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
      errorBuilder: (context, obj, s) => const Icon(Icons.error),
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
              icon: const Icon(Icons.save),
            )
          : IconButton(
              onPressed: () {
                if (controller.addToFavorite() != null) {
                  // 收藏页面没有用obx进行响应式处理，所以这里要手动刷新
                  Get.find<FavoritePageController>().refreshData();
                  Utils.showToast("成功");
                }
              },
              icon: const Icon(
                Icons.favorite_border,
              ),
            ),
      // 导出按钮
      IconButton(
          onPressed: () async {
            showDialog(
              context: Get.context!,
              builder: (context) => Dialog(
                child: ShareWidget(
                  build: controller.currentBuild,
                  equipedStats: controller.equipStats,
                ),
              ),
            );
          },
          icon: const Icon(Icons.share)),
    ];
  }

  List<Widget> _buildStats() {
    return [
      ListTile(
        title: const Text("数值"),
        tileColor: Colors.grey.shade200,
      ),
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("召唤师的羁绊"),
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
            const Text("神装英雄"),
            Switch(
              value: controller.isResplendent,
              // onChanged: (bool newVal) => _.resplendent = newVal,
              onChanged: controller.hero.resplendentHero!
                  ? (bool newVal) => controller.setResplendent(newVal)
                  : null,
            ),
          ],
        ),
      ),
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("绽放个性"),
            Obx(() => DropdownButton(
                  value: controller.ascendedAsset.value,
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("N/A"),
                    ),
                    for (var key in controller.statsMap.values)
                      DropdownMenuItem(
                        value: key,
                        child: Text("CUSTOM_STATS_${key.toUpperCase()}".tr),
                        enabled: key != controller.advantage,
                      ),
                  ],
                  onChanged: (dynamic obj) {
                    controller.ascendedAsset.value = obj;
                    controller.calBaseStats();
                  },
                )),
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
                  const TextSpan(
                      text: "竞技场", style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: controller.bst.toString(),
                      style: const TextStyle(
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
                              "CUSTOM_STATS_${propName.toUpperCase()}".tr,
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
                const Text("基础数值"),
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
                const Text("装备数值"),
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
    // kind:1神阶、传承 2比翼 3双界 4开花
    if (controller.hero.legendary?.kind != 4 &&
        controller.hero.legendary != null) {
      widgetList.add(
        ListTile(
          title: const Text("常驻效果"),
          tileColor: Colors.grey.shade200,
        ),
      );

      widgetList.add(ListTile(
          title: Text(
        "MPID_LEGEND_${controller.hero.idTag!.split("_")[1]}".tr,
        style: Get.textTheme.descStyle,
      )));

      // 技能
      if (controller.hero.legendary?.duoSkillId != null) {
        widgetList.add(ExpansionTile(
          title: const Text("特殊技能效果"),
          children: [
            ListTile(
              dense: true,
              title: Text(
                "MSID_H_${controller.hero.legendary!.duoSkillId!.split("_")[1]}"
                    .tr
                    .replaceAll(r"$a", ""),
                style: Get.textTheme.descStyle,
              ),
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
        const Padding(padding: EdgeInsets.only(left: 10)),
        // 头像
        IndexedStack(
          index: controller.isResplendent ? 0 : 1,
          children: [
            ClipOval(
              child: _buildAvatar(
                  "assets/faces/${controller.hero.faceName}EX01.webp", 60),
            ),
            ClipOval(
                child: _buildAvatar(
                    "assets/faces/${controller.hero.faceName}.webp", 60)),
          ],
        ),
        const SizedBox(
          width: 5,
        ),
        // 武器和移动类型
        Column(
          children: [
            _buildAvatar("assets/move/${controller.hero.moveType}.webp", 25),
            const SizedBox(
              height: 5,
            ),
            _buildAvatar(
                "assets/weapon/${controller.hero.weaponType}.webp", 25),
          ],
        ),
        // const SizedBox(
        //   width: 10,
        // ),
        // Column(
        //   children: controller.hero.minRarity == 0
        //       ? controller.hero.maxRarity == 0
        //           ? [const SizedBox.shrink()]
        //           : [
        //               Image.asset(
        //                   "assets/static/Rarity${controller.hero.maxRarity}.png"),
        //             ]
        //       : [
        //           Image.asset(
        //               "assets/static/Rarity${controller.hero.minRarity}.png"),
        //           const SizedBox(height: 2),
        //           const Icon(
        //             Icons.arrow_downward,
        //             size: 10,
        //           ),
        //           const SizedBox(height: 2),
        //           Image.asset(
        //               "assets/static/Rarity${controller.hero.maxRarity}.png"),
        //         ],
        // ),
        const SizedBox(
          width: 5,
        ),
        // 突破
        CircleBtn(
          key: controller.mergeBtnKey,
          displayValue: "+${controller.merged.toString()}",
          title: "突破极限",
          height: 20,
          titleSize: 10,
          onPressed: () async {
            List<int?>? _merge = await _showPicker(Get.context!,
                title: const Text("突破极限"),
                body: [
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
        const SizedBox(
          width: 5,
        ),
        // 性格
        TraitsBtn(
          key: controller.traitsBtnKey,
          onPressed: () async {
            // picker里面已经设置结果不可重复，这里不需判断
            List<int?>? _result = await _showPicker(Get.context!,
                title: const Text("优势/劣势"),
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
                          ? "+" +
                              "CUSTOM_STATS_${controller.statsMap[key]!.toUpperCase()}"
                                  .tr
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
                          ? "-" +
                              "CUSTOM_STATS_${controller.statsMap[key]!.toUpperCase()}"
                                  .tr
                          : "N/A";
                    }
                  },
                ]);
            if (_result != null) {
              if (_result[0] != 0) {
                if (controller.statsMap[_result[0].toString()] ==
                    controller.ascendedAsset.value) {
                  Utils.showToast("开花属性和优势属性不能相同");
                } else {
                  controller.advantage =
                      controller.statsMap[_result[0].toString()];
                  // _result[0] _result[1]有一方为null则全部为null
                  controller.disadvantage =
                      controller.statsMap[_result[1].toString()];

                  controller.traitsBtnKey.currentState!.setNewDisplay("+" +
                      "CUSTOM_STATS_${controller.advantage!.toUpperCase()}".tr +
                      "-" +
                      "CUSTOM_STATS_${controller.disadvantage!.toUpperCase()}"
                          .tr);
                  controller.calBaseStats();
                }
              } else {
                controller.advantage = null;
                // _result[0] _result[1]有一方为null则全部为null
                controller.disadvantage = null;

                controller.traitsBtnKey.currentState!.setNewDisplay("+    -");
                controller.calBaseStats();
              }
            }
          },
          displayValue: controller.advantage == null
              ? "+    -"
              : "+" +
                  "CUSTOM_STATS_${controller.advantage!.toUpperCase()}".tr +
                  "-" +
                  "CUSTOM_STATS_${controller.disadvantage!.toUpperCase()}".tr,
        ),

        const SizedBox(
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
            List<int?>? _dragonFlower = await _showPicker(Get.context!,
                title: const Text("神龙之花"),
                body: [
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

  Widget _buildRarity() {
    return ListTile(
      tileColor: Colors.grey.shade200,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("稀有度"),
          controller.hero.minRarity == 0
              ? controller.hero.maxRarity == 0
                  ? const Text("暂未添加")
                  : Row(
                      children: [
                        Image.asset(
                            "assets/static/Rarity${controller.hero.maxRarity}.png"),
                        // Text(PersonType.values[controller.hero.type].value),
                      ],
                    )
              : Row(
                  children: [
                    Image.asset(
                        "assets/static/Rarity${controller.hero.minRarity}.png"),
                    const Text("--"),
                    Image.asset(
                        "assets/static/Rarity${controller.hero.maxRarity}.png"),
                    // Text(PersonType.values[controller.hero.type].value),
                  ],
                )
        ],
      ),
    );
  }

  List<Widget> _buildExclusiveTile() {
    return controller.origWeaponRefine.isNotEmpty
        ? [
            ListTile(
              title: const Text("武器炼成"),
              tileColor: Colors.grey.shade200,
            ),
            for (Map<Skill, Skill> s in controller.origWeaponRefine)
              ExpansionTile(title: Text((s.keys.first.nameId!).tr), children: [
                ListTile(
                    title: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: (s.keys.first.descId!).tr.replaceAll(r"$a", ""),
                    style: Get.textTheme.descStyle,
                  ),
                  const TextSpan(text: "\n"),
                  TextSpan(
                    text: (s.values.first.descId!).tr.replaceAll(r"$a", ""),
                    style: Get.textTheme.descStyle.merge(
                      const TextStyle(color: Colors.green),
                    ),
                  ),
                ])))
              ]),
          ]
        : [const SizedBox.shrink()];
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
            errorBuilder: (context, obj, s) => const Icon(Icons.error),
            height: 25,
          );
        }
        return _buildAvatar("assets/icons/${s.iconId}.webp", 30);

      case 4:
        if (s == null) {
          return Image.asset(
            "assets/static/4.png",
            errorBuilder: (context, obj, s) => const Icon(Icons.error),
            height: 25,
          );
        }
        return _buildAvatar("assets/icons/${s.iconId}.webp", 30);

      case 5:
        if (s == null) {
          return Image.asset(
            "assets/static/5.png",
            errorBuilder: (context, obj, s) => const Icon(Icons.error),
            height: 25,
          );
        }
        return _buildAvatar("assets/icons/${s.iconId}.webp", 30);

      case 6:
        if (s == null) {
          return Image.asset(
            "assets/static/6.png",
            errorBuilder: (context, obj, s) => const Icon(Icons.error),
            height: 25,
          );
        }
        return _buildAvatar("assets/icons/${s.iconId}.webp", 30);

      case 7:
        return s == null
            ? _buildAvatar("assets/blessing/0.webp", 30)
            : _buildAvatar("assets/blessing/${s.iconId}.webp", 30);

      default:
        return const SizedBox.shrink();
    }
  }

  /// 竞技场分数
  ListTile _buildArenaTile() {
    return ListTile(
      title: Row(
        children: [
          Text.rich(TextSpan(children: [
            const TextSpan(
                text: "竞技场分数 ", style: TextStyle(color: Colors.black)),
            TextSpan(
                text: controller.arenaScore.toString(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ])),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text.rich(
              TextSpan(children: <InlineSpan>[
                const TextSpan(
                    text: "总SP ", style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: controller.allSpCost.toString(),
                    style: const TextStyle(
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
        title: const Text("技能配置"),
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
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        controller.delSkill(controller.heroSkills[index]!);
                      },
                      icon: const Icon(Icons.delete),
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
                              "SP:${controller.heroSkills[index]!.spCost.toString()}\n",
                          style: Get.textTheme.subtitle2,
                        ),
                      // 技能描述
                      TextSpan(
                        text: (controller.heroSkills[index]!.descId!)
                            .tr
                            // .replaceAll("\n", "")
                            .replaceAll(r"$a", ""),
                        style: Get.textTheme.descStyle,
                      ),
                      // 技能特效描述
                      if (controller.heroSkills[index]!.refineId != null)
                        TextSpan(
                          text: "\n" +
                              (("MSID_H_${controller.heroSkills[index]!.refineId!.split("_")[1]}")
                                      .tr)
                                  // .replaceAll("\n", "")
                                  .replaceAll(r"$a", ""),
                          style: Get.textTheme.descStyle.merge(
                            const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      if (controller.heroSkills[index]!.exclusive!)
                        TextSpan(
                          text: "\n无法继承",
                          style: Get.textTheme.descStyle
                              .merge(const TextStyle(color: Colors.red)),
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
                  _buildRarity(),
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
