import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cloud_db/cloud_db.dart';
import 'package:date_format/date_format.dart';
import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/home_screens/home/bloc/home_bloc.dart';
import 'package:feh_rebuilder/models/cloud_object/update_table.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/skill_select/page.dart';
import 'package:feh_rebuilder/core/platform_info.dart';
import 'package:feh_rebuilder/repositories/api.dart';
import 'package:feh_rebuilder/repositories/config_cubit/config_cubit.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/picker.dart';
import 'package:feh_rebuilder/widgets/uni_dialog.dart';
import 'package:feh_rebuilder/widgets/update_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class OthersPage extends StatelessWidget {
  const OthersPage({Key? key}) : super(key: key);

  final Map<String, int> skillCategories = const {
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

  @override
  Widget build(BuildContext context) {
    PlatformType platformType = EnvProvider.platformType;
    return ListView(
      controller: ScrollController(),
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "技能",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          alignment: Alignment.centerLeft,
          height: 50,
          color: Colors.grey.shade200,
        ),
        for (String k in skillCategories.keys)
          ListTile(
            title: Text(k),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SkillSelectPage(
                category: skillCategories[k]!,
                selectMode: false,
                exclusiveSkills: const [],
                filters: const {
                  SkillFilterType.noEnemyOnly,
                  SkillFilterType.isRegular
                },
                moveTypefilters: const {},
                weponTypefilters: const {},
              ),
            )),
          ),
        Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "选项和其他",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          alignment: Alignment.centerLeft,
          height: 50,
          color: Colors.grey.shade200,
        ),
        const _LangTile(),

        const _BackUpTile(),

        ListTile(
          title: Row(
            children: const [
              Text("程序版本"),
              Spacer(),
              Text(EnvProvider.appVersion),
            ],
          ),
        ),
        const _DataVersionTile(),

        // todo 随更新生成工具发布时一起添加
        // if (platformType != PlatformType.Web) const _AllowInvalidTile(),
        // 检查更新
        if (platformType != PlatformType.Web) const _UpdateTile(),
        // 设备识别码
        if (platformType != PlatformType.Web) const _DeviceIdTile(),
        if (platformType != PlatformType.Web)
          BlocSelector<ConfigCubit, Config, bool>(
            selector: (state) {
              return state.allowGetSysId;
            },
            builder: (context, allowGetSysId) {
              return SwitchListTile(
                  title: const Text("允许获取系统ID"),
                  subtitle: const Text("用于网络身份识别和鉴权"),
                  value: allowGetSysId,
                  onChanged: (bool newState) async {
                    await context
                        .read<ConfigCubit>()
                        .setAllowGetSysId(newState);
                  });
            },
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
              applicationVersion: EnvProvider.appVersion,
            );
          },
        ),
      ],
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({Key? key}) : super(key: key);
  // final List<Locale> dataLanguages = const [
  //   Locale.fromSubtags(languageCode: "zh", countryCode: "TW"),
  //   Locale.fromSubtags(languageCode: "ja", countryCode: "JP"),
  //   Locale.fromSubtags(languageCode: "en", countryCode: "US"),
  // ];
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          const Text("语言"),
          const Spacer(),
          BlocSelector<ConfigCubit, Config, String>(
            selector: (state) {
              return AppLanguages.values[state.dataLanguage.index].name
                  .toUpperCase();
            },
            builder: (context, state) {
              return Text("CUSTOM_LANG_$state".tr);
            },
          )
        ],
      ),
      onTap: () async {
        List<int>? _newLanguage = await showModalBottomSheet(
            context: context,
            builder: (context) => Picker(
                  body: [
                    {
                      "minValue": 0,
                      "maxValue": 2,
                      "value":
                          context.read<ConfigCubit>().state.dataLanguage.index,
                      "textMapper": (String index) {
                        return "CUSTOM_LANG_${AppLanguages.values[int.parse(index)].name.toUpperCase()}"
                            .tr;
                      }
                    },
                  ],
                  title: const Text("请选择语言"),
                ));

        if (_newLanguage != null) {
          AppLanguages newLang = AppLanguages.values[_newLanguage[0]];
          await context.read<ConfigCubit>().switchLang(context, newLang);
          context.read<HomeBloc>().add(HomeLangChanged());
        }
      },
    );
  }
}

class _BackUpTile extends StatelessWidget {
  const _BackUpTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("备份和恢复"),
      onTap: () async {
        TextEditingController controller = TextEditingController();

        var all = await context.read<Repository>().favourites.getAll();
        String backupString = base64Encode(utf8.encode(jsonEncode(all)));
        await showDialog(
          context: context,
          builder: (context) => UniDialog(
            title: "备份和恢复",
            confirmText: "恢复",
            body: Column(
              children: [
                Row(
                  children: [
                    const Text("下方是恢复代码，请妥善保存"),
                    Tooltip(
                      message: "复制到剪切板",
                      child: IconButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: backupString));
                          },
                          icon: const Icon(Icons.copy)),
                    )
                  ],
                ),
                SelectableText(
                  backupString,
                  maxLines: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: "将恢复代码粘贴到这里"),
                  ),
                )
              ],
            ),
            onComfirm: () {
              context.read<Repository>().restoreFavourites(controller.text);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class _DataVersionTile extends StatefulWidget {
  const _DataVersionTile({Key? key}) : super(key: key);

  @override
  State<_DataVersionTile> createState() => _DataVersionTileState();
}

class _DataVersionTileState extends State<_DataVersionTile> {
  @override
  Widget build(BuildContext context) {
    int version = context.read<Repository>().version;
    return ListTile(
      title: Row(
        children: [
          const Text("数据版本"),
          const Spacer(),
          IconButton(
            onPressed: EnvProvider.platformType != PlatformType.Web
                ? () async {
                    // 本地更新的方法
                    String updateFilePath = await showDialog(
                          context: context,
                          builder: (context) => UniDialog(
                            title: "更新",
                            body: const Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: "使用不安全的更新文件存在安全风险！\n",
                                  style: TextStyle(color: Colors.red),
                                ),
                                TextSpan(text: "使用更新功能需请求存储读取权限\n同意请点击确定选择文件")
                              ]),
                            ),
                            onComfirm: () async {
                              FilePickerResult? filePath = await FilePicker
                                  .platform
                                  .pickFiles(allowMultiple: false);

                              Navigator.of(context)
                                  .pop(filePath?.files.first.path);
                            },
                          ),
                        ) ??
                        "";

                    if (updateFilePath.isNotEmpty) {
                      Utils.showLoading("升级中...");

                      String cachePath = p.join(EnvProvider.tempDir, "update");
                      try {
                        var data = await File(updateFilePath).readAsBytes();

                        if (!context
                            .read<ConfigCubit>()
                            .state
                            .ignoreSignature) {
                          if (!await Utils.verifySignature(
                            data.sublist(0, data.length - 384),
                            data.sublist(data.length - 384),
                          )) {
                            Utils.showToast("更新包签名验证失败！");
                            return;
                          }
                        }

                        final archive =
                            ZipDecoder().decodeBytes(data.buffer.asUint8List());
                        // 释放文件
                        for (var item in archive.files) {
                          if (item.isFile) {
                            File f = File(p.join(cachePath, item.name));
                            await f.create(recursive: true);
                            await f.writeAsBytes(item.content as List<int>);
                          } else {
                            await Directory(p.join(cachePath, item.name))
                                .create(recursive: true);
                          }
                        }
                        File bin = File(p.join(cachePath, "data.bin"));
                        var decoded = const ZLibDecoder()
                            .decodeBytes(await bin.readAsBytes());
                        var json = jsonDecode(utf8.decode(decoded));

                        await context.read<Repository>().gameDb.updateDb(json);
                        await for (var file
                            in Directory(cachePath).list(recursive: true)) {
                          if (file is File &&
                              p.basename(file.path) != "data.bin") {
                            String relative = p.relative(file.path,
                                from: p.join(cachePath, "update"));

                            await file.rename(p.join(
                                EnvProvider.rootDir, "assets", relative));
                          }
                        }
                        setState(() {
                          // 刷新显示版本
                        });

                        Utils.showToast("升级完成，请重启程序");
                      } catch (e) {
                        Utils.showToast("升级出错");
                        Utils.debug(e.toString());
                        if (await Directory(cachePath).exists()) {
                          await Directory(cachePath).delete(recursive: true);
                        }
                      }
                    }
                  }
                : null,
            icon: const Icon(Icons.unarchive),
          ),
        ],
      ),
      subtitle: Text(
          "${formatDate(DateTime.fromMillisecondsSinceEpoch(version), [
            "yyyy",
            "mm",
            "dd"
          ])} ($version)"),
    );
  }
}

class _DeviceIdTile extends StatelessWidget {
  const _DeviceIdTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
                              if (context
                                  .read<ConfigCubit>()
                                  .state
                                  .allowGetSysId) {
                                await Cloud().restoreDevice(
                                    controller.text.replaceAll(" ", ""));
                                Utils.showToast("成功");
                                Navigator.of(context).pop();
                              } else {
                                Utils.showToast("请先到“其他”页面打开允许获取系统ID开关");
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
    );
  }
}

// ignore: unused_element
class _AllowInvalidTile extends StatelessWidget {
  const _AllowInvalidTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ConfigCubit, Config, bool>(
      selector: (state) {
        return state.ignoreSignature;
      },
      builder: (context, allowInvalidUpdate) {
        return SwitchListTile(
            title: const Text("验证更新包数字签名"),
            value: !allowInvalidUpdate,
            onChanged: (bool newState) async {
              // print(newState);
              await context
                  .read<ConfigCubit>()
                  .setAllowInvalidUpdate(!newState);
            });
      },
    );
  }
}

class _UpdateTile extends StatelessWidget {
  const _UpdateTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: const [
          Text("检查更新"),
          Spacer(),
        ],
      ),
      onTap: () async {
        var r = await context.read<API>().query(
          "app_update_info",
          {
            "where": jsonEncode(
              {
                // server_version> 当前数据版本 and  minimal_version<=当前程序版本
                // 结果降序排列
                r"$and": [
                  {
                    "minimal_version": {r"$lte": EnvProvider.appVersionCode}
                  },
                  {
                    "server_version": {
                      r"$gt": context.read<Repository>().version
                      // r"$gte": context.read<Repository>().version
                    }
                  },
                ],
              },
            ),
            "order": "-id",
          },
        );

        if (r != null) {
          var info = [for (var item in r.results) UpdateTable.fromJson(item)];
          if (info.isEmpty) {
            Utils.showToast("未发现更新");
          } else {
            await showDialog(
                context: context,
                builder: (context) => UpdateWebDialog(
                      updateInfo: info,
                    ));
          }
        }
      },
    );
  }
}
