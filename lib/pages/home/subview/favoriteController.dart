import 'package:feh_tool/dataService.dart';
import 'package:feh_tool/models/personBuild/personBuild.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';

class FavoritePageController extends GetxController {
  DataService data = Get.find<DataService>();

  FavoritePageController();
  List<PersonBuild?> all = [];

  ///返回列表里不为空的数量（角色数量）
  int get count {
    int count = 0;
    all.forEach((element) {
      if (element != null) {
        count++;
      }
    });
    return count;
  }

  void refreshData() {
    Iterable _all = (Get.find<DataService>().customBox.read("favorites")
            as Iterable<dynamic>?) ??
        [];

    all.clear();
    _all.forEach((element) {
      all.add(PersonBuild.fromJson(element));
    });
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

  // final selected = <int>{}.obs;

  SwipeActionController sc = SwipeActionController();
  void select(int index, bool val) {
    sc.closeAllOpenCell();

    if (selected.length < 4 && val) {
      selected.add(index);
    } else {
      selected.removeWhere((element) => element == index);
    }
    update([index, "info"]);
  }

  void deleteBuild(int index) {
    all[index] = null;
    Get.find<DataService>().customBox.write("favorites", [
      for (PersonBuild? build in all)
        if (build != null) build.toJson()
    ]);
    sc.deleteCellAt(indexPaths: [index]);
    update(["info"]);
  }

  void toDetail(int i) async {
    dynamic r = await Get.toNamed("heroDetail", arguments: all[i]);
    // print(r);
    if (r is PersonBuild) {
      all[i] = r;
      update([i]);
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}
