import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';

class FavoritePageController extends GetxController {
  DataService data = Get.find<DataService>();

  FavoritePageController();
  List<PersonBuild?> all = [];

  ///返回列表里不为空的数量（角色数量）
  int get count {
    int count = 0;
    for (var element in all) {
      if (element != null) {
        count++;
      }
    }
    return count;
  }

  void refreshData() {
    Iterable _all = (Get.find<DataService>().customBox.read("favorites")
            as Iterable<dynamic>?) ??
        [];

    all.clear();
    for (var element in _all) {
      all.add(PersonBuild.fromJson(element));
    }

    selected.clear();
    update(["info", "list"]);
  }

  int get averageScore {
    if (selected.length < 4) {
      return 0;
    } else {
      int sum = 0;
      for (int index in selected) {
        sum += all[index]!.arenaScore;
      }
      return (sum / 4).floor();
    }
  }

  Set<int> selected = {};

  Set<int> selectedTags = {};

  SwipeActionController sc = SwipeActionController();
  void select(int index, bool val) {
    sc.closeAllOpenCell();

    if (selected.length < 4 && val) {
      selected.add(index);
    } else {
      selected.removeWhere((element) => element == index);
    }
    update(["info"]);
  }

  void deleteBuild(int index) {
    all[index] = null;
    selected.remove(index);
    Get.find<DataService>().customBox.write("favorites", [
      for (PersonBuild? build in all)
        if (build != null) build.toJson()
    ]);
    sc.deleteCellAt(indexPaths: [index]);
    update(["info"]);
  }

  void toDetail(int i) async {
    dynamic r = await Get.toNamed("heroDetail", arguments: all[i]);
    if (r is PersonBuild) {
      all[i] = r;
      update(["list"]);
    }
  }

  void add(PersonBuild p) {
    all.add(p);
    update(["info", "list"]);
  }

  void deleteAll() {
    selected.clear();
    Get.find<DataService>().customBox.write("favorites", []);
    refreshData();
    update(["list", "info"]);
  }

  /// 首次启动时初始化数据，其他时候手动刷新
  @override
  void onInit() {
    refreshData();
    super.onInit();
  }
}
