import 'package:feh_tool/pages/home/controller.dart';
import 'package:feh_tool/pages/home/subview/favorite.dart';
import 'package:feh_tool/pages/home/subview/home.dart';
import 'package:feh_tool/pages/home/subview/others.dart';
import 'package:feh_tool/pages/home/widgets/endDraw.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends GetView<HomeController> {
  Home();

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
                  icon: Icon(Icons.sort))
              : SizedBox.shrink()),
          Obx(() => controller.currentIndex.value == 0
              ? IconButton(
                  onPressed: () {
                    controller.scaffoldKey.currentState!.openEndDrawer();
                  },
                  icon: Icon(Icons.filter_list_alt))
              : SizedBox.shrink())
        ],
        // automaticallyImplyLeading: false,
      ),
      endDrawer: Padding(
        padding: EdgeInsets.fromLTRB(
            0, appBarHeight + 1, 0, bottomNavigationBarHeight),
        child: FilterDraw(),
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
            children: [HomePage(), FavoritePage(), OthersPage()],
            index: controller.currentIndex.value,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "首页"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "收藏"),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: "其他"),
            ],
            onTap: (index) {
              controller.currentIndex.value = index;
            },
          )),
    ));
  }
}
