import 'dart:io';
import 'package:feh_tool/dataService.dart';
import 'package:feh_tool/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class UpdateDialog extends StatelessWidget {
  UpdateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<UpdateDialogController>(
      init: UpdateDialogController(),
      builder: (_) => Dialog(
        child: Container(
          width: 200,
          height: 200,
          child: Center(
            child: Column(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _.showCircleIndicator.value
                        ? CircularProgressIndicator(
                            value: _.runningValue.value,
                          )
                        : SizedBox.shrink(),
                    Text(
                      _.info.value,
                      style: Get.textTheme.bodyText1,
                    )
                  ],
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _.enable.value ? _.start : null,
                      child: Text("选择文件"),
                    ),
                    TextButton(
                      onPressed: _.enable.value
                          ? () {
                              Get.back();
                            }
                          : null,
                      child: Text("取消"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpdateDialogController extends GetxController {
  final info = "使用非法或不安全的更新文件存在安全风险\n使用更新功能需请求存储读取权限\n同意请点击选择文件按钮".obs;

  final showCircleIndicator = false.obs;

  final runningValue = Rx<double?>(null);

  bool agree = false;

  final enable = true.obs;

  DataService dataService = Get.find<DataService>();

  UpdateDialogController();

  Future<void> start() async {
    enable.value = false;
    agree = true;
    FilePickerResult? filePath =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (filePath != null && p.extension(filePath.files.first.path!) == ".zip") {
      if (await Utils.verifySignature(filePath.files.first.path!)) {
        showCircleIndicator.value = true;
        info.value = "正在解压更新数据";
        await updateAssets(filePath.files.first.path!);
      } else {
        info.value = "更新包签名验证失败！";
      }
    }
    enable.value = true;
  }

  Future<void> updateAssets(String filePath) async {
    try {
      // Directory tempDir = GetPlatform.isMobile
      //     ? await getTemporaryDirectory()
      //     : Directory(r"H:\GitProject\flutter\feh_heroes\feh_tool\cache");
      Directory tempDir = dataService.tempDir;
      if (await compute(
        Utils.unzipAssets,
        [filePath, tempDir],
      )) {
        info.value = "更新数据解压完成，请重启软件";
        runningValue.value = 100;
      } else {
        throw "";
      }
    } catch (e, s) {
      print(e.toString());
      print(s.toString());
      info.value = "更新失败";
    }
  }
}
