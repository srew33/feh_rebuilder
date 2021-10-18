import 'package:feh_rebuilder/global/filters/skill.dart';
import 'package:feh_rebuilder/pages/heroDetail/widgets/picker.dart';
import 'package:feh_rebuilder/pages/home/widgets/backup_dialog.dart';
import 'package:feh_rebuilder/pages/home/widgets/update_dialog.dart';
import 'package:feh_rebuilder/pages/skillsBrowse/controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'others_controller.dart';

class OthersPage extends GetView<OthersPageController> {
  const OthersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scController = ScrollController();
    return ListView(controller: scController, children: [
      Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
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
          padding: const EdgeInsets.only(left: 20),
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
            const Text("语言"),
            const Spacer(),
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
            title: const Text("请选择语言"),
          ));
          if (_newLanguage != null) {
            controller.switchLanguage(_newLanguage[0]);
          }
        },
      ),
      ListTile(
        title: const Text("收藏备份"),
        onTap: () {
          showDialog(
              context: context, builder: (context) => const BackupDialog());
        },
      ),
      ListTile(
        title: const Text("收藏恢复"),
        onTap: () {
          showDialog(
              context: context, builder: (context) => const RecoverDialog());
        },
      ),
      ListTile(
        title: Row(
          children: [
            const Text("程序版本"),
            const Spacer(),
            Text(controller.appVersion)
          ],
        ),
      ),
      ListTile(
        title: Row(
          children: [
            const Text("数据版本"),
            IconButton(
                onPressed: () {
                  Get.dialog(const UpdateDialog());
                },
                icon: const Icon(Icons.upgrade_rounded)),
            const Spacer(),
            TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                          title: const Text("完整版本号"),
                          children: [
                            Center(
                              child: Text(controller.dataVersion),
                            )
                          ],
                        ));
              },
              child: Text(
                DateFormat("yyyyMMdd").format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(controller.dataVersion),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ListTile(
        title: Row(
          children: const [
            Text("开源许可"),
            Spacer(),
          ],
        ),
        onTap: () {
          showLicensePage(
              context: context, applicationVersion: controller.data.version);
        },
      ),
    ]);
  }
}
