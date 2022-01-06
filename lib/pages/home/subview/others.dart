import 'package:cloud_db/cloud_db.dart';

import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/global/filters/skill.dart';
import 'package:feh_rebuilder/pages/heroDetail/widgets/picker.dart';
import 'package:feh_rebuilder/pages/home/widgets/backup_dialog.dart';
import 'package:feh_rebuilder/pages/home/widgets/update_dialog.dart';
import 'package:feh_rebuilder/pages/skillsBrowse/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../utils.dart';
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
              icon: const Icon(Icons.upgrade_rounded),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                          title: const Text("完整版本号"),
                          children: [
                            Center(
                              child: Text(
                                  controller.data.assetsVersion.toString()),
                            )
                          ],
                        ));
              },
              child: Text(
                DateFormat("yyyyMMdd").format(
                  DateTime.fromMillisecondsSinceEpoch(
                    controller.data.assetsVersion,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ListTile(
        title: Row(
          children: [
            const Text("检查更新"),
            const Spacer(),
            Obx(() => Text(controller.findNewVersion.value)),
          ],
        ),
        onTap: () async {
          controller.checkUpdate();
        },
      ),
      ListTile(
        title: Row(
          children: const [
            Text("设备识别码"),
            Spacer(),
          ],
        ),
        onTap: () async {
          String _deviceId = await Cloud().generateDeviceId();
          TextEditingController controller =
              TextEditingController(text: Cloud().deviceId ?? _deviceId);

          showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    children: [
                      const Text(
                        "这是当前使用的设备识别码（已加密）\n你可以将以前设备的识别码粘贴到下方来恢复设备权限",
                      ),
                      TextField(
                        controller: controller,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () async {
                                if (Get.find<DataService>().allowGetId) {
                                  await Cloud().restoreDevice(
                                      controller.text.replaceAll(" ", ""));
                                  // Utils.showToast("成功");
                                  Navigator.of(context).pop();
                                } else {
                                  Utils.showToast("请先到“其他”页面打开信息服务开关");
                                }
                              },
                              child: const Text("设置")),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("取消")),
                        ],
                      )
                    ],
                  ));
        },
      ),
      ListTile(
        title: Row(
          children: const [
            Text("信息服务"),
            Spacer(),
            _AllowGetId(),
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
              context: context,
              applicationVersion: controller.data.appVersionAlias);
        },
      ),
    ]);
  }
}

class _AllowGetId extends StatefulWidget {
  const _AllowGetId({Key? key}) : super(key: key);

  @override
  __AllowGetIdState createState() => __AllowGetIdState();
}

class __AllowGetIdState extends State<_AllowGetId> {
  @override
  Widget build(BuildContext context) {
    return Switch(
        value: Get.find<DataService>().allowGetId,
        onChanged: (bool newState) async {
          if (!Get.find<DataService>().allowGetId) {
            bool? confirm = await showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                      title: const Text("注意"),
                      children: [
                        const Text(
                            "使用信息服务会收集本机的系统识别码用作身份和权限认证，收集的信息会加密存放在数据库中，同意请选择确定"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text("确定")),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("取消")),
                          ],
                        )
                      ],
                    ));
            if (confirm == true) {
              Get.find<DataService>().customBox.write("allowGetId", true);
              setState(() {});
            }
          } else {
            Get.find<DataService>().customBox.write("allowGetId", false);
            if (Cloud().sp.inited) {
              await Cloud().sp.clear();
            }
            setState(() {});
          }
        });
  }
}
