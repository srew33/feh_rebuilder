import 'dart:convert';

import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/pages/home/subview/favorite_controller.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackupDialog extends StatefulWidget {
  const BackupDialog({Key? key}) : super(key: key);

  @override
  _BackupDialogState createState() => _BackupDialogState();
}

class _BackupDialogState extends State<BackupDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    Iterable<Map<String, dynamic>> _ =
        (Get.find<DataService>().customBox.read("favorites") as Iterable)
            .cast<Map<String, dynamic>>();

    String encoded = base64Encode(utf8.encode(jsonEncode(_)));

    try {
      //测试是否正确
      List<Map<String, dynamic>> json =
          (jsonDecode(utf8.decode(base64Decode(encoded))) as List<dynamic>)
              .cast<Map<String, dynamic>>();
      // 测试传入的字符串是否正确
      for (var element in json) {
        PersonBuild.fromJson(element);
      }

      _textEditingController.text = encoded;
    } catch (e) {
      Utils.showToast("生成失败，请重试");
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: TextField(
            readOnly: true,
            controller: _textEditingController,
            decoration: const InputDecoration(labelText: "请将下列字符串妥善保存"),
          ),
        )
      ],
    );
  }
}

class RecoverDialog extends StatefulWidget {
  const RecoverDialog({Key? key}) : super(key: key);

  @override
  _RecoverDialogState createState() => _RecoverDialogState();
}

class _RecoverDialogState extends State<RecoverDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(labelText: "请将备份字符串粘贴到这里"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () {
                  try {
                    if (_textEditingController.text.isNotEmpty) {
                      // 解析传入的字符串
                      List<Map<String, dynamic>> json = (jsonDecode(utf8.decode(
                                  base64Decode(_textEditingController.text)))
                              as List<dynamic>)
                          .cast<Map<String, dynamic>>();

                      // 测试传入的字符串是否正确
                      for (var element in json) {
                        PersonBuild.fromJson(element);
                      }

                      // 获取目前的收藏
                      List<Map<String, dynamic>> _ = (Get.find<DataService>()
                              .customBox
                              .read("favorites") as Iterable)
                          .cast<Map<String, dynamic>>()
                          .toList();

                      for (var _item in json) {
                        bool searched = _.any((element) =>
                            element["time_stamp"] == _item["time_stamp"]);
                        // 如果恢复的数据不存在则添加(使用time_stamp判断唯一，理论上不可能相同)
                        if (!searched) {
                          _.add(_item);
                        }
                      }

                      Get.find<DataService>().customBox.write("favorites", _);
                      // 刷新收藏页面数据
                      Get.find<FavoritePageController>().refreshData();
                      Utils.showToast("成功");
                    }
                  } catch (e, s) {
                    Utils.showToast("导入失败");

                    Utils.debug("导入失败 ${e.toString()}  ${s.toString()}");
                  }
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
    );
  }
}
