import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'favoriteController.dart';

class FavoritePage extends GetView<FavoritePageController> {
  @override
  Widget build(BuildContext context) {
    controller.refreshData();
    controller.selected.clear();

    return Column(
      children: [
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 10,
              ),
              child: GetBuilder<FavoritePageController>(
                  id: "info",
                  builder: (controller) => Text(
                      "共有${controller.count}位角色，请选择4位角色\n已选择角色的竞技场分数为${controller.averageScore} ")),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Expanded(
          child: ListView(
            children: [
              for (int i = 0; i < controller.all.length; i++)
                if (controller.all[i] != null)
                  GetBuilder<FavoritePageController>(
                    id: i,
                    builder: (controller) => SwipeActionCell(
                      key: UniqueKey(),
                      trailingActions: <SwipeAction>[
                        SwipeAction(
                          nestedAction: SwipeNestedAction(title: "确认删除"),
                          title: "删除",
                          onTap: (CompletionHandler handler) async {
                            await handler(true);
                            controller.deleteBuild(i);
                          },
                          color: Colors.red,
                        ),
                        SwipeAction(
                            title: "编辑",
                            onTap: (CompletionHandler handler) async {
                              handler(false);
                              controller.toDetail(i);

                              // await Get.toNamed("heroDetail",
                              //     arguments: controller.all[i]);

                              // controller.update([i]);
                            },
                            color: Colors.blue),
                      ],
                      child: CheckboxListTile(
                        secondary: ClipOval(
                          child: Image.file(
                            File(
                                "${controller.data.appPath.path}/assets/faces/${controller.data.personBox.read(controller.all[i]!.idTag)["face_name"]}.webp"),
                            height: 40,
                          ),
                        ),
                        value: controller.selected.contains(i),
                        onChanged: (val) {
                          if (val != null) {
                            controller.select(i, val);
                          }
                        },
                        title: Row(
                          children: [
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(17))),
                              child: Center(
                                child: Text(
                                  "+${controller.all[i]!.merged}",
                                  style: Get.textTheme.bodyText1,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(17))),
                              child: Center(
                                child: Text(
                                  "+${controller.all[i]!.dragonflowers}",
                                  style: Get.textTheme.bodyText1,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(("M${controller.all[i]!.idTag}").tr),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    controller.all[i]!.advantage == null &&
                                            controller.all[i]!.disAdvantage ==
                                                null
                                        ? Text(
                                            "中性",
                                            style: Get.textTheme.bodyText2,
                                          )
                                        : Text(
                                            "+${controller.all[i]!.advantage}-${controller.all[i]!.disAdvantage}",
                                            style: Get.textTheme.bodyText2,
                                          ),
                                    Text(
                                      " 竞技场 ${controller.all[i]!.arenaScore}",
                                      style: Get.textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
// }


