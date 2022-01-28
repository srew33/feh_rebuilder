import 'dart:io';

import 'package:feh_rebuilder/global/enum/move_type.dart';
import 'package:feh_rebuilder/global/enum/series.dart';
import 'package:feh_rebuilder/global/enum/game_version.dart';
import 'package:feh_rebuilder/global/enum/weapon_type.dart';
import 'package:feh_rebuilder/global/filters/person.dart';
import 'package:feh_rebuilder/models/weapon_type/weapon_type.dart';
import 'package:feh_rebuilder/pages/home/subview/home_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class FilterDraw extends GetView<HomePageController> {
  const FilterDraw({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scController = ScrollController();
    return SizedBox(
      width: 276,
      child: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scController,
                children: [
                  ListTile(
                    title: Text(
                      "角色过滤",
                      style: Get.textTheme.headline5!
                          .merge(const TextStyle(color: Colors.white)),
                    ),
                    tileColor: Colors.blue,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 4; i++)
                            Obx(() => ChoiceChip(
                                  visualDensity: VisualDensity.comfortable,
                                  label: Image.file(
                                    File(
                                      p.join(controller.data.appPath.path,
                                          "assets", "move", "$i.webp"),
                                    ),
                                    height: 45,
                                    width: 45,
                                  ),
                                  selected: controller
                                      .isSelected(MoveTypeEnum.values[i]),
                                  selectedColor: Colors.blue,
                                  backgroundColor: Colors.transparent,
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(),
                                  onSelected: (bool val) {
                                    if (val) {
                                      controller.cacheSelectedFilter
                                          .add(MoveTypeEnum.values[i]);
                                    } else {
                                      controller.cacheSelectedFilter
                                          .remove(MoveTypeEnum.values[i]);
                                    }
                                  },
                                ))
                        ],
                      ),
                      for (int i = 0; i < controller.weaponType.length / 4; i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int j = 0; j < 4; j++)
                              Obx(
                                () => ChoiceChip(
                                  label: Image.file(
                                    File(
                                      p.join(
                                          controller.data.appPath.path,
                                          "assets",
                                          "weapon",
                                          "${controller.weaponType.firstWhere((weapon) => weapon.sortId == (4 * i + j)).index}.webp"),
                                    ),
                                    height: 45,
                                    width: 45,
                                  ),
                                  selected: controller.isSelected(
                                      WeaponTypeEnum.values[controller
                                          .weaponType
                                          .firstWhere((element) =>
                                              element.sortId == i * 4 + j)
                                          .index]),
                                  selectedColor: Colors.blue,
                                  backgroundColor: Colors.transparent,
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(),
                                  onSelected: (bool val) {
                                    WeaponType w = controller.weaponType
                                        .firstWhere((element) =>
                                            element.sortId == i * 4 + j);
                                    if (val) {
                                      controller.cacheSelectedFilter
                                          .add(WeaponTypeEnum.values[w.index]);
                                    } else {
                                      controller.cacheSelectedFilter.remove(
                                          WeaponTypeEnum.values[w.index]);
                                    }
                                  },
                                ),
                              )
                          ],
                        ),
                      Obx(
                        () => CheckboxListTile(
                          title: const Text("最新"),
                          value: controller
                              .isSelected(PersonFilterType.recentlyUpdated),
                          onChanged: (selected) {
                            selected ??= false;
                            if (selected) {
                              controller.cacheSelectedFilter
                                  .add(PersonFilterType.recentlyUpdated);
                            } else {
                              controller.cacheSelectedFilter
                                  .remove(PersonFilterType.recentlyUpdated);
                            }
                          },
                        ),
                      ),
                      ExpansionTile(
                        title: const Text("更多"),
                        children: [
                          const ListTile(
                            title: Text("类型"),
                          ),
                          ListTile(
                            title: Wrap(
                              runSpacing: 10,
                              spacing: 6,
                              children: [
                                Obx(() => ChoiceChip(
                                      label: const Text("神装"),
                                      selected: controller.isSelected(
                                          PersonFilterType.isResplendent),
                                      onSelected: (bool val) {
                                        if (val) {
                                          controller.cacheSelectedFilter.add(
                                              PersonFilterType.isResplendent);
                                        } else {
                                          controller.cacheSelectedFilter.remove(
                                              PersonFilterType.isResplendent);
                                        }
                                      },
                                    )),
                                Obx(() => ChoiceChip(
                                      label: const Text("舞娘"),
                                      selected: controller.isSelected(
                                          PersonFilterType.isRefersher),
                                      onSelected: (bool val) {
                                        if (val) {
                                          controller.cacheSelectedFilter.add(
                                              PersonFilterType.isRefersher);
                                        } else {
                                          controller.cacheSelectedFilter.remove(
                                              PersonFilterType.isRefersher);
                                        }
                                      },
                                    )),
                                Obx(() => ChoiceChip(
                                      label: const Text("比翼"),
                                      selected: controller
                                          .isSelected(PersonFilterType.isDuo),
                                      onSelected: (bool val) {
                                        if (val) {
                                          controller.cacheSelectedFilter
                                              .add(PersonFilterType.isDuo);
                                        } else {
                                          controller.cacheSelectedFilter
                                              .remove(PersonFilterType.isDuo);
                                        }
                                      },
                                    )),
                                Obx(() => ChoiceChip(
                                      label: const Text("双界"),
                                      selected: controller.isSelected(
                                          PersonFilterType.isHarmonic),
                                      onSelected: (bool val) {
                                        if (val) {
                                          controller.cacheSelectedFilter
                                              .add(PersonFilterType.isHarmonic);
                                        } else {
                                          controller.cacheSelectedFilter.remove(
                                              PersonFilterType.isHarmonic);
                                        }
                                      },
                                    )),
                                Obx(() => ChoiceChip(
                                      label: const Text("神阶"),
                                      selected: controller.isSelected(
                                          PersonFilterType.isMythic),
                                      onSelected: (bool val) {
                                        if (val) {
                                          controller.cacheSelectedFilter
                                              .add(PersonFilterType.isMythic);
                                        } else {
                                          controller.cacheSelectedFilter.remove(
                                              PersonFilterType.isMythic);
                                        }
                                      },
                                    )),
                                Obx(() => ChoiceChip(
                                      label: const Text("传承"),
                                      selected: controller.isSelected(
                                          PersonFilterType.isLegend),
                                      onSelected: (bool val) {
                                        if (val) {
                                          controller.cacheSelectedFilter
                                              .add(PersonFilterType.isLegend);
                                        } else {
                                          controller.cacheSelectedFilter.remove(
                                              PersonFilterType.isLegend);
                                        }
                                      },
                                    )),
                              ],
                            ),
                          ),
                          const ListTile(
                            title: Text("出处"),
                          ),
                          ListTile(
                            title: Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                for (int i = 0;
                                    i < SeriesEnum.values.length;
                                    i++)
                                  Obx(() => Tooltip(
                                        preferBelow: false,
                                        message: SeriesEnum.values[i].name,
                                        child: ChoiceChip(
                                          label: Image.asset(
                                            "assets/static/series/$i.webp",
                                            height: 25,
                                          ),
                                          selected: controller
                                              .isSelected(SeriesEnum.values[i]),
                                          onSelected: (bool val) {
                                            if (val) {
                                              controller.cacheSelectedFilter
                                                  .add(SeriesEnum.values[i]);
                                            } else {
                                              controller.cacheSelectedFilter
                                                  .remove(SeriesEnum.values[i]);
                                            }
                                          },
                                        ),
                                      )),
                              ],
                            ),
                          ),
                          const ListTile(
                            title: Text("版本"),
                          ),
                          ListTile(
                            title: Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                for (int i = 0;
                                    i < GameVersion.values.length;
                                    i++)
                                  Obx(() => ChoiceChip(
                                        label: Text("${i + 1}"),
                                        selected: controller
                                            .isSelected(GameVersion.values[i]),
                                        onSelected: (bool val) {
                                          if (val) {
                                            controller.cacheSelectedFilter
                                                .add(GameVersion.values[i]);
                                          } else {
                                            controller.cacheSelectedFilter
                                                .remove(GameVersion.values[i]);
                                          }
                                        },
                                      )),
                              ],
                            ),
                          ),
                          // todo 也许以后版本完成
                          // ListTile(
                          //   title: Text("数值大于"),
                          // ),
                          // ListTile(title: Text("HP"), dense: true),
                          // ListTile(title: Text("HP"), dense: true),
                          // ListTile(title: Text("HP"), dense: true),
                          // ListTile(title: Text("HP"), dense: true),
                          // ListTile(title: Text("HP"), dense: true),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              children: [
                const Spacer(),
                TextButton(
                    onPressed: () {
                      controller.selectedFilter.clear();
                      controller.cacheSelectedFilter.clear();
                    },
                    child: const Text("清除")),
                const Spacer(),
                TextButton(
                    onPressed: () {
                      controller.doFilterFlag = true;
                      Get.back();
                    },
                    child: const Text("确定")),
                const Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
