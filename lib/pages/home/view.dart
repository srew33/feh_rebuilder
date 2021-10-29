import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/pages/home/controller.dart';
import 'package:feh_rebuilder/pages/home/subview/favorite.dart';
import 'package:feh_rebuilder/pages/home/subview/home.dart';
import 'package:feh_rebuilder/pages/home/subview/others.dart';
import 'package:feh_rebuilder/pages/home/widgets/end_draw.dart';
import 'package:feh_rebuilder/pages/home/widgets/import_dialog.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends GetView<HomeController> {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var statusBarHeight = MediaQuery.of(context).padding.top;
    var appBarHeight = kToolbarHeight;
    var bottomNavigationBarHeight = kBottomNavigationBarHeight;
    return SafeArea(
        child: Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        title: Obx(() => Text(controller.title[controller.currentIndex.value])),
        actions: [
          Obx(() => controller.currentIndex.value == 0
              ? IconButton(
                  onPressed: () async {
                    controller.changeSort(context);
                  },
                  icon: const Icon(Icons.sort))
              : const SizedBox.shrink()),
          Obx(() => controller.currentIndex.value == 0
              ? IconButton(
                  onPressed: () {
                    controller.scaffoldKey.currentState!.openEndDrawer();
                  },
                  icon: const Icon(Icons.filter_list_alt))
              : const SizedBox.shrink()),
          // 导入build
          Obx(
            () => controller.currentIndex.value == 1
                ? IconButton(
                    onPressed: () async {
                      PersonBuild? personBuild = await showDialog(
                          context: context,
                          builder: (context) => const SimpleDialog(
                                children: [ImportDialog()],
                              ));

                      if (personBuild != null) {
                        // 需要将custom置为true，否则会加载默认配置
                        personBuild.custom = true;
                        Utils.showToast("解析成功");

                        dynamic r = await Get.toNamed(
                          "/heroDetail",
                          arguments: personBuild,
                        );
                        if (r != null) {
                          controller.favoritePageController.add(r);
                          Utils.showToast("保存成功");
                        }
                      } else {
                        // Utils.showToast("导入失败");
                      }
                    },
                    icon: const Icon(Icons.download_for_offline))
                : const SizedBox.shrink(),
          ),
          // 清空收藏
          Obx(
            () => controller.currentIndex.value == 1
                ? IconButton(
                    onPressed: () async {
                      bool select = await showDialog(
                              context: context,
                              builder: (context) => SimpleDialog(
                                    title: const Text("清空收藏！"),
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            "你真的要清空收藏吗，此操作不可逆！",
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text(
                                                "确定",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              )),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("取消")),
                                        ],
                                      )
                                    ],
                                  )) ??
                          false;
                      if (select) {
                        controller.favoritePageController.deleteAll();
                      }
                    },
                    icon: const Icon(Icons.delete_forever_outlined))
                : const SizedBox.shrink(),
          ),
        ],
        // automaticallyImplyLeading: false,
      ),
      endDrawer: Padding(
        padding: EdgeInsets.fromLTRB(
            0, appBarHeight + 1, 0, bottomNavigationBarHeight),
        child: const FilterDraw(),
      ),
      onEndDrawerChanged: (bool state) {
        // 当drawer关闭时判断是否需要执行过滤和排序
        // ? 为false时会执行两次，原因未知
        if (!state) {
          if (controller.homePageController.doFilterFlag) {
            controller.homePageController.doFilter();
          } else {
            controller.homePageController.cacheSelectedFilter.clear();
          }
        }
      },
      body: Obx(() => IndexedStack(
            children: const [HomePage(), FavoritePage(), OthersPage()],
            index: controller.currentIndex.value,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "首页"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "收藏"),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: "其他"),
            ],
            onTap: (index) {
              controller.currentIndex.value = index;
            },
          )),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   // PID_ミカヤ PID_ロイ PID_ケンプフ
      //   for (var stat in Utils.statKeys) {
      //     if (stat != "spd") {
      //       print(Utils.calcStats(
      //         controller.homePageController.all
      //             .firstWhere((element) => element.idTag == "PID_ロイ"),
      //         1,
      //         40,
      //         5,
      //         "spd",
      //         "hp",
      //         1,
      //         0,
      //         true,
      //         false,
      //         stat,
      //         // null,
      //       ));
      //     }
      //   }
      // }),
    ));
  }
}
