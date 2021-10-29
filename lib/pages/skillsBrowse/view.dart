import 'dart:io';

import 'package:feh_rebuilder/global/enum/weapon_type.dart';
import 'package:feh_rebuilder/global/filters/skill.dart';
import 'package:feh_rebuilder/global/theme/text_theme.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/pages/heroDetail/widgets/hero_icon.dart';
import 'package:feh_rebuilder/pages/skillsBrowse/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SkillsBrowse extends GetView<SkillsBrowseController> {
  const SkillsBrowse({Key? key}) : super(key: key);

  Widget _buildIcon(Skill? s) {
    switch (controller.category) {
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

      case 15:
        return s == null
            ? _buildAvatar("assets/blessing/0.webp", 30)
            : _buildAvatar("assets/blessing/${s.iconId}.webp", 30);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAvatar(String path, double height) {
    return Image.file(
      File("${controller.currentPath.path}/$path"),
      errorBuilder: (context, obj, s) => const Icon(Icons.error),
      height: height,
    );
  }

  Widget _buildTitle() {
    switch (controller.category) {
      case 0:
        return _buildAvatar("assets/icons/1.webp", 30);

      case 1:
        return _buildAvatar("assets/icons/2.webp", 30);

      case 2:
        return _buildAvatar("assets/icons/3.webp", 30);

      case 3:
        return Image.asset(
          "assets/static/3.png",
          errorBuilder: (context, obj, s) => const Icon(Icons.error),
          height: 25,
        );

      case 4:
        return Image.asset(
          "assets/static/4.png",
          errorBuilder: (context, obj, s) => const Icon(Icons.error),
          height: 25,
        );

      case 5:
        return Image.asset(
          "assets/static/5.png",
          errorBuilder: (context, obj, s) => const Icon(Icons.error),
          height: 25,
        );

      case 6:
        return Image.asset(
          "assets/static/6.png",
          errorBuilder: (context, obj, s) => const Icon(Icons.error),
          height: 25,
        );

      case 7:
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }

  List<Widget> _buildWeaponZone() {
    if (controller.category == 0 && !controller.selectMode) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (WeaponTypeEnum weapon
                in controller.weaponTypeDict.getRange(0, 6))
              Obx(() => ChoiceChip(
                  label: Image.file(
                    File(
                        "${controller.data.appPath.path}/assets/weapon/${weapon.groupIndex}.webp"),
                    height: 25,
                    width: 25,
                  ),
                  backgroundColor: Colors.transparent,
                  selectedColor: Colors.blue.shade200,
                  onSelected: (bool newState) {
                    controller.showWeaponType.value = weapon.groupIndex;
                    controller.setFilter(SkillFilterType.weaponType, {weapon});
                    controller.filt();
                  },
                  selected:
                      controller.showWeaponType.value == weapon.groupIndex))
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (WeaponTypeEnum weapon
                in controller.weaponTypeDict.getRange(6, 12))
              Obx(
                () => ChoiceChip(
                    label: Image.file(
                      File(
                          "${controller.data.appPath.path}/assets/weapon/${weapon.groupIndex}.webp"),
                      height: 25,
                      width: 25,
                    ),
                    backgroundColor: Colors.transparent,
                    selectedColor: Colors.blue.shade200,
                    onSelected: (bool newState) {
                      controller.showWeaponType.value = weapon.groupIndex;
                      controller
                          .setFilter(SkillFilterType.weaponType, {weapon});
                      controller.filt();
                    },
                    selected:
                        controller.showWeaponType.value == weapon.groupIndex),
              )
          ],
        ),
      ];
    }
    return [const SizedBox.shrink()];
  }

  Widget _buildCategoryZone() {
    if (controller.category == 6) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 3; i < 7; i++)
            Obx(() => ChoiceChip(
                  selected: controller.showAccessory.value == i,
                  label: Image.asset(
                    "assets/static/$i.png",
                    height: 30,
                    width: 30,
                  ),
                  backgroundColor: Colors.transparent,
                  selectedColor: Colors.blue.shade200,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  onSelected: (bool newState) {
                    if (newState) {
                      controller.showAccessory.value = i;
                      controller.setFilter(SkillFilterType.category, {i});
                      controller.filt();
                    }
                  },
                ))
        ],
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> _buildFilterZone() {
    return [
      const SizedBox(
        height: 5,
      ),
      for (Widget w in _buildWeaponZone()) w,
      //对于圣印，显示ABCS
      _buildCategoryZone(),
      if (controller.category == 0 && !controller.selectMode)
        Row(
          children: [
            const Text("只显示具有特效的锻造"),
            const Spacer(),
            Obx(() => Switch(
                value: controller.onlyRefinedSkill.value,
                onChanged: (bool val) {
                  controller.onlyRefinedSkill.value = val;
                  if (val) {
                    controller.isExclusive.value = true;
                    controller.setFilter(SkillFilterType.showExclusive, val);
                  }
                  controller.setFilter(SkillFilterType.isRefinedSkill, val);
                  controller.filt();
                }))
          ],
        ),
      if (!controller.selectMode)
        Row(
          children: [
            const Text("显示专属技能"),
            const Spacer(),
            Obx(() => Switch(
                value: controller.isExclusive.value,
                onChanged: (bool val) {
                  controller.isExclusive.value = val;
                  controller.setFilter(SkillFilterType.showExclusive, val);
                  controller.filt();
                }))
          ],
        ),
      Row(
        children: [
          const Text("只显示常用技能"),
          const Spacer(),
          Obx(() => Switch(
              value: controller.onlyRegularSkill.value,
              onChanged: (bool val) {
                controller.onlyRegularSkill.value = val;
                controller.setFilter(SkillFilterType.isRegular, val);
                controller.filt();
              }))
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: _buildTitle(),
          ),
          body: Column(
            children: [
              for (Widget w in _buildFilterZone()) w,
              Expanded(
                  child: GetBuilder<SkillsBrowseController>(
                id: "list",
                builder: (controller) => ListView.builder(
                    itemCount: controller.skills.length,
                    itemBuilder: (context, index) {
                      Skill s = controller.skills[index];

                      return ExpansionTile(
                        title: Row(
                          children: [
                            _buildIcon(s),
                            Text(
                              s.idTag!.split("_").length == 3
                                  ? "${(s.nameId!).tr}_${s.idTag!.split("_")[2]}"
                                  : (s.nameId!).tr,
                            ),
                            const Spacer(),
                            // Text(s.idNum!.toString()),
                            // Text("  "),
                            // Text(s.sortId!.toString()),
                            if (controller.selectMode)
                              IconButton(
                                  onPressed: () {
                                    Get.back(result: s);
                                  },
                                  icon: const Icon(Icons.done))
                          ],
                        ),
                        children: [
                          ListTile(
                            title: Text.rich(TextSpan(children: [
                              if (controller.category != 15)
                                TextSpan(
                                  text: "SP: ${s.spCost.toString()}\n",
                                  style: Get.textTheme.subtitle2,
                                ),
                              TextSpan(
                                text: (s.descId!)
                                    .tr
                                    // .replaceAll("\n", " ")
                                    .replaceAll(r"$a", ""),
                                style: Get.textTheme.descStyle,
                              ),
                              if (s.refineId != null)
                                TextSpan(
                                  text: "\n" +
                                      (("MSID_H_${s.refineId!.split("_")[1]}")
                                              .tr)
                                          // .replaceAll("\n", "")
                                          .replaceAll(r"$a", ""),
                                  style: Get.textTheme.descStyle.merge(
                                      const TextStyle(color: Colors.green)),
                                ),
                              if (s.exclusive!)
                                TextSpan(
                                  text: "\n无法继承",
                                  style: Get.textTheme.descStyle.merge(
                                      const TextStyle(color: Colors.red)),
                                ),
                            ])),
                          ),
                          if (s.rarity3 != null)
                            if (s.rarity3!.isNotEmpty)
                              ListTile(
                                title: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Image.asset("assets/static/Rarity3.png"),
                                    for (int i = 0; i < s.rarity3!.length; i++)
                                      HeroIcon(
                                          person: Person.fromJson(controller
                                              .data.personBox
                                              .read(s.rarity3![i])),
                                          appPath: controller.data.appPath.path)
                                  ],
                                ),
                              ),
                          if (s.rarity4 != null)
                            if (s.rarity4!.isNotEmpty)
                              ListTile(
                                title: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Image.asset("assets/static/Rarity4.png"),
                                    for (int i = 0; i < s.rarity4!.length; i++)
                                      HeroIcon(
                                          person: Person.fromJson(controller
                                              .data.personBox
                                              .read(s.rarity4![i])),
                                          appPath:
                                              controller.data.appPath.path),
                                  ],
                                ),
                              ),
                          if (s.rarity5 != null)
                            if (s.rarity5!.isNotEmpty)
                              ListTile(
                                title: Wrap(
                                  spacing: 5,
                                  runSpacing: 5,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Image.asset("assets/static/Rarity5.png"),
                                    for (int i = 0; i < s.rarity5!.length; i++)
                                      HeroIcon(
                                          person: Person.fromJson(controller
                                              .data.personBox
                                              .read(s.rarity5![i])),
                                          appPath:
                                              controller.data.appPath.path),
                                  ],
                                ),
                              ),
                        ],
                      );
                    }),
              ))
            ],
          )),
    );
  }
}
