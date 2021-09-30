import 'package:feh_tool/global/filters/skill.dart';
import 'package:feh_tool/pages/heroDetail/widgets/picker.dart';
import 'package:feh_tool/pages/home/widgets/updateDialog.dart';
import 'package:feh_tool/pages/skillsBrowse/controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'othersController.dart';

class OthersPage extends GetView<OthersPageController> {
  @override
  Widget build(BuildContext context) {
    final ScrollController scController = ScrollController();
    return ListView(controller: scController, children: [
      Container(
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "技能",
            style: Get.textTheme.headline6,
          ),
        ),
        alignment: Alignment.centerLeft,
        height: 50,
        color: Colors.grey.shade200,
      ),
      for (String k in controller.otherList.keys)
        ListTile(
          title: Text(k),
          onTap: () => Get.toNamed("/skillsBrowse",
              arguments: SkillChooseConfig(
                  category: controller.otherList[k]!,
                  selectMode: false,
                  filters: [
                    SkillFilter(
                        filterType: SkillFilterType.showEnemyOnly, valid: false)
                  ])),
        ),
      Container(
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            "选项和其他",
            style: Get.textTheme.headline6,
          ),
        ),
        alignment: Alignment.centerLeft,
        height: 50,
        color: Colors.grey.shade200,
      ),
      ListTile(
        title: Row(
          children: [
            Text("语言"),
            Spacer(),
            Obx(() => Text(controller.currentLanguage.value))
          ],
        ),
        onTap: () async {
          List<int>? _newLanguage = await Get.bottomSheet(Picker(
            body: [
              {
                "minValue": 0,
                "maxValue": 2,
                "value": controller.data.languageDict.keys
                    .toList()
                    .indexOf(controller.currentLanguage.value),
                "textMapper": (String key) {
                  return controller.data.languageDict.keys
                      .toList()[int.parse(key)];
                }
              },
            ],
            title: Text("请选择语言"),
          ));
          if (_newLanguage != null) {
            controller.switchLanguage(_newLanguage[0]);
          }
        },
      ),
      ListTile(
        title: Row(
          children: [
            Text("程序版本"),
            Spacer(),
            Obx(() => Text(controller.appVersion.value))
          ],
        ),
      ),
      ListTile(
        title: Row(
          children: [
            Text("数据版本"),
            Spacer(),
            Obx(
              () => Text.rich(TextSpan(children: [
                TextSpan(
                    text: (DateFormat("yyyyMMdd").format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(controller.dataVersion.value),
                  ),
                ))),
                TextSpan(
                    text:
                        "(${int.parse(controller.dataVersion.value).toString()})")
              ])),
            ),
            IconButton(
                onPressed: () {
                  Get.dialog(UpdateDialog());
                },
                icon: Icon(Icons.archive)),
          ],
        ),
      ),
      ListTile(
        title: Row(
          children: [
            Text("开源许可"),
            Spacer(),
          ],
        ),
        onTap: () {
          Get.toNamed("/openSource");
        },
      ),
    ]);
  }
}
