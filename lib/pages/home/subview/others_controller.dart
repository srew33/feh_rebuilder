import 'dart:convert';

import 'package:feh_rebuilder/api_service.dart';
import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/update_resp/update_resp.dart';

import 'package:feh_rebuilder/pages/home/widgets/update_web.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OthersPageController extends GetxController {
  OthersPageController();

  DataService data = Get.find<DataService>();

  Map<String, int> otherList = const {
    "武器": 0,
    "辅助技能": 1,
    "奥义": 2,
    "技能A": 3,
    "技能B": 4,
    "技能C": 5,
    "圣印": 6,
    "祝福": 15,
    // "双界技能": 8
  };
  final findNewVersion = "".obs;
  final currentLanguage = "".obs;

  String appVersion = "";
  String dataVersion = "";

  bool _ignoreRequest = false;

  /// 切换语言
  void switchLanguage(int localeIndex) {
    DataService data = Get.find<DataService>();
    if (localeIndex == -1) {
      currentLanguage.value = data.customBox.read("dataLanguage");
    } else {
      currentLanguage.value = data.languageDict.keys.toList()[localeIndex];
      try {
        Get.updateLocale(data.languageDict.values.toList()[localeIndex]);
        data.customBox.write("dataLanguage", currentLanguage.value);
      } catch (e) {
        Utils.debug(
            "切换语言失败 from${currentLanguage.value} to ${data.languageDict.values.toList()[localeIndex]}");
      }
    }
  }

  Future<void> checkUpdate() async {
    if (!_ignoreRequest) {
      ApiService api = Get.find<ApiService>();
      _ignoreRequest = true;
      var resp = await api.get(
        "/1/classes/app_update_info",
        queryParameters: {
          "where": jsonEncode(
            {
              "minimal_version": {
                r"$gte": GetPlatform.isDesktop ? 13 : data.appVersion
              },
            },
          )
        },
      );

      if (resp.statusCode == 200) {
        UpdateInfo lastApp;
        UpdateInfo lastAsset;
        try {
          var analysed = UpdateResp.fromJson(resp.data).results;
          // 降序排列
          analysed.sort((a, b) => b.serverVersion.compareTo(a.serverVersion));
          lastApp = analysed.firstWhere(
            (element) =>
                element.type == 0 && element.serverVersion > data.appVersion,
            orElse: () => UpdateInfo(
              serverVersion: -1,
              type: 0,
              minimalVersion: -1,
              id: -1,
            ),
          );
          lastAsset = analysed.firstWhere(
            (element) =>
                element.type == 1 && element.serverVersion > data.assetsVersion,
            orElse: () => UpdateInfo(
              serverVersion: -1,
              type: 1,
              minimalVersion: -1,
              id: -1,
            ),
          );
        } on Exception catch (e) {
          Utils.debug(e.toString());
          Utils.showToast("数据解析失败");
          lastApp = UpdateInfo(
            serverVersion: -2,
            type: 1,
            minimalVersion: -1,
            id: -1,
          );
          lastAsset = UpdateInfo(
            serverVersion: -2,
            type: 1,
            minimalVersion: -1,
            id: -1,
          );
        }
        if (lastApp.serverVersion == -1 && lastAsset.serverVersion == -1) {
          Utils.showToast("未发现更新");
        } else {
          await showDialog(
            context: Get.context!,
            builder: (context) => UpdateWebDialog(
              appInfo: lastApp,
              assetsInfo: lastAsset,
            ),
            barrierDismissible: false,
          );
        }
      }
      _ignoreRequest = false;
    }
  }

  @override
  void onInit() {
    switchLanguage(-1);
    appVersion = data.appVersionAlias;
    dataVersion = data.customBox.read("dataVersion") as String;
    super.onInit();
  }
}
