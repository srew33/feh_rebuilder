import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'favorite_controller.dart';

class FavoritePage extends GetView<FavoritePageController> {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 5,
      ),
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: GetBuilder<FavoritePageController>(
                id: "info",
                builder: (controller) => Text(
                    "共有${controller.count}位角色，请选择4位角色\n已选择角色的竞技场分数为${controller.averageScore} ")),
          )
        ],
      ),
      const SizedBox(
        height: 5,
      ),
      Expanded(
          child: GetBuilder<FavoritePageController>(
              id: "list",
              builder: (controller) => ListView.builder(
                    itemCount: controller.all.length,
                    itemBuilder: (context, index) => controller.all[index] !=
                            null
                        ? SwipeActionCell(
                            key: UniqueKey(),
                            // leadingActions: <SwipeAction>[
                            //   SwipeAction(
                            //     title: "标签",
                            //     onTap: (CompletionHandler handler) async {
                            //       // await handler(false);
                            //       Set<String>? result = await showDialog(
                            //         context: context,
                            //         builder: (context) => TagChooseDialog(
                            //           allTags: [
                            //             // for (int i = 0; i < 100; i++) i.toString()
                            //           ],
                            //           tags: ["5", "9", "6"],
                            //         ),
                            //       );
                            //       print(result);
                            //     },
                            //     color: Colors.blue,
                            //   )
                            // ],
                            trailingActions: <SwipeAction>[
                              SwipeAction(
                                nestedAction: SwipeNestedAction(title: "确认删除"),
                                title: "删除",
                                onTap: (CompletionHandler handler) async {
                                  await handler(true);
                                  controller.deleteBuild(index);
                                },
                                color: Colors.red,
                              ),
                              SwipeAction(
                                  title: "编辑",
                                  onTap: (CompletionHandler handler) async {
                                    handler(false);
                                    controller.toDetail(index);
                                  },
                                  color: Colors.blue),
                            ],
                            child: _ListItem(
                              controller: controller,
                              index: index,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ))),
    ]);
  }
}
// }

class _ListItem extends StatefulWidget {
  final FavoritePageController controller;
  final int index;

  const _ListItem({Key? key, required this.controller, required this.index})
      : super(key: key);

  @override
  __ListItemState createState() => __ListItemState();
}

class __ListItemState extends State<_ListItem> {
  late FavoritePageController controller;
  late int i;
  @override
  void initState() {
    controller = widget.controller;
    i = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      secondary: ClipOval(
        child: Image.file(
            File(
                "${controller.data.appPath.path}/assets/faces/${controller.data.personBox.read(controller.all[i]!.personTag)["face_name"]}.webp"),
            height: 40,
            errorBuilder: (context, obj, s) => const Icon(Icons.error)),
      ),
      value: controller.selected.contains(i),
      onChanged: (val) {
        setState(() {
          if (val != null) {
            controller.select(i, val);
          }
        });
      },
      title: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(17))),
            child: Center(
              child: Text(
                "+${controller.all[i]!.merged}",
                style: Get.textTheme.bodyText1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(17))),
            child: Center(
              child: Text(
                "+${controller.all[i]!.dragonflowers}",
                style: Get.textTheme.bodyText1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(("M${controller.all[i]!.personTag}").tr),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  controller.all[i]!.advantage == null &&
                          controller.all[i]!.disAdvantage == null
                      ? Text(
                          "中性",
                          style: Get.textTheme.bodyText2,
                        )
                      : Text(
                          "+" +
                              "CUSTOM_STATS_${controller.all[i]!.advantage!.toUpperCase()}"
                                  .tr +
                              "-" +
                              "CUSTOM_STATS_${controller.all[i]!.disAdvantage!.toUpperCase()}"
                                  .tr,
                          // "+${controller.all[i]!.advantage}-${controller.all[i]!.disAdvantage}",
                          style: Get.textTheme.bodyText2,
                        ),
                  Text(
                    "${controller.all[i]!.arenaScore}",
                    style: Get.textTheme.bodyText2,
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }
}
