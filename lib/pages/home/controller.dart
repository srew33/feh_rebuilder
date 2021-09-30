import 'package:feh_tool/global/enum/sortKey.dart';
import 'package:feh_tool/pages/heroDetail/widgets/picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'subview/favoriteController.dart';
import 'subview/homePageController.dart';
import 'subview/othersController.dart';

class HomeController extends GetxController {
  List<String> title = const [
    "角色",
    "收藏",
    "其他",
  ];
  HomePageController homePageController = Get.put(HomePageController());
  FavoritePageController favoritePageController =
      Get.put(FavoritePageController());
  OthersPageController othersPageController = Get.put(OthersPageController());
  HomeController();

  final currentIndex = 0.obs;

  /// scaffold的key，用于打开侧边栏等
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void changeSort(BuildContext context) async {
    List<int>? sortKey = await showModalBottomSheet(
        context: context,
        builder: (context) => Picker(body: [
              {
                "minValue": 0,
                "maxValue": SortKey.values.length - 1,
                "value": homePageController.currentSortKey.index,
                "textMapper": (String key) {
                  return SortKey.values[int.tryParse(key)!].value;
                }
              }
            ]));
    if (sortKey != null) {
      if (homePageController.currentSortKey != SortKey.values[sortKey.first]) {
        homePageController.changeSortKey(SortKey.values[sortKey.first]);
      }
    }
  }
}
