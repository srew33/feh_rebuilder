import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:feh_rebuilder/pages/heroBuildShare/controller.dart';
import 'package:feh_rebuilder/pages/heroBuildShare/widgets/build_item.dart';

class HeroBuildSharePage extends GetView<HeroBuildSharePageController> {
  const HeroBuildSharePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("M${(controller.hero.idTag ?? "")}".tr),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : controller.buildList.isEmpty
                ? const Center(
                    child: Text("空空如也"),
                  )
                : ListView.builder(
                    itemBuilder: (context, index) => BuildItem(
                      heroBuild: controller.buildList[index],
                    ),
                    itemCount: controller.buildList.length,
                  ),
      ),
    ));
  }
}
