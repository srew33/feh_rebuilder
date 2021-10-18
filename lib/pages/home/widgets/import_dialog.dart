import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:r_scan/r_scan.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({Key? key}) : super(key: key);

  @override
  _ImportDialogState createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(labelText: "通过代码导入"),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? image =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  RScanResult result = await RScan.scanImagePath(image.path);

                  if (result.message != null) {
                    _textEditingController.text = result.message!;
                    // PersonBuild? _ = Utils.decodeBuild(
                    //     result.message!, Get.find<DataService>());
                    // if (_ != null) {
                    //   Navigator.of(context).pop(_);
                    // }
                  } else {
                    Utils.showToast("没有找到二维码");
                    Utils.debug("没有找到二维码");
                  }
                }
              },
              child: const Text("通过图片导入"),
            ),
            TextButton(
                onPressed: () {
                  PersonBuild? personBuild = Utils.decodeBuild(
                      _textEditingController.text, Get.find<DataService>());
                  Navigator.of(context).pop(personBuild);
                },
                child: const Text("确定")),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
          ],
        )
      ],
    );
  }
}
