import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:date_format/date_format.dart';
import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/core/platform_info.dart';
import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/main.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/my_18n/widget.dart';
import 'package:feh_rebuilder/pages/skills/controller.dart';
import 'package:feh_rebuilder/pages/skills/ui.dart';
import 'package:feh_rebuilder/repositories/config_provider.dart';
import 'package:feh_rebuilder/repositories/net_service/service.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/picker.dart';
import 'package:feh_rebuilder/widgets/uni_dialog.dart';
import 'package:feh_rebuilder/widgets/update_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class OthersPage extends ConsumerWidget {
  const OthersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: _AppBar(),
      body: _Body(),
      bottomNavigationBar: _BottomNavigationBar(),
    );
  }
}

class _AppBar extends StatelessWidget with PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("其他"),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BottomNavigationBar extends ConsumerWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      onTap: (index) =>
          ref.read(homeIndexProvider.notifier).update((state) => state = index),
      currentIndex: 2,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "人物"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "收藏"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "其他"),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

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
          alignment: Alignment.centerLeft,
          height: 50,
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "技能",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        for (String k in skillCategories.keys)
          ListTile(
            title: Text(k),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SkillsPage(
                  initialParam: SkillParam(
                    category: skillCategories[k]!,
                    selectMode: false,
                    exclusiveSkills: const [],
                    filters: const {
                      SkillFilterType.noEnemyOnly,
                      SkillFilterType.isRegular
                    },
                    moveTypeFilters: const {},
                    weaponTypeFilters: const {},
                    categoryFilters: const {},
                  ),
                ),
              ),
            ),
          ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "选项和其他",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
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
          Consumer(
            builder: (context, ref, child) {
              bool allowGetSysId = ref
                  .watch(configProvider.select((value) => value.allowGetSysId));
              return SwitchListTile(
                  title: const Text("允许获取系统ID"),
                  subtitle: const Text("用于网络身份识别和鉴权"),
                  value: allowGetSysId,
                  onChanged: (bool newState) async {
                    await ref
                        .read(repoProvider)
                        .requireValue
                        .config
                        .putIfAbsent("allowGetSysId", newState);
                    ref.read(configProvider.notifier).update(
                        (state) => state.copyWith(allowGetSysId: newState));
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

class _LangTile extends ConsumerWidget {
  const _LangTile({Key? key}) : super(key: key);
  // final List<Locale> dataLanguages = const [
  //   Locale.fromSubtags(languageCode: "zh", countryCode: "TW"),
  //   Locale.fromSubtags(languageCode: "ja", countryCode: "JP"),
  //   Locale.fromSubtags(languageCode: "en", countryCode: "US"),
  // ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String lang = ref.watch(configProvider.select((value) =>
        AppLanguages.values[value.dataLanguage.index].name.toUpperCase()));
    return ListTile(
      title: Row(
        children: [
          const Text("语言"),
          const Spacer(),
          Text("CUSTOM_LANG_$lang".tr),
        ],
      ),
      onTap: () async {
        List<int>? newLanguage = await showModalBottomSheet(
            context: context,
            builder: (context) => Picker(
                  body: [
                    {
                      "minValue": 0,
                      "maxValue": 2,
                      "value": ref.read(configProvider).dataLanguage.index,
                      "textMapper": (String index) {
                        return "CUSTOM_LANG_${AppLanguages.values[int.parse(index)].name.toUpperCase()}"
                            .tr;
                      }
                    },
                  ],
                  title: const Text("请选择语言"),
                ));

        if (newLanguage != null) {
          AppLanguages newLang = AppLanguages.values[newLanguage[0]];
          await ref.read(repoProvider).requireValue.config.putIfAbsent(
                "dataLang",
                newLang.index,
              );

          if (context.mounted) {
            MyI18nWidget.of(context).locale = newLang.localeWithoutCountry;
          }

          ref.read(configProvider.notifier).update(
                (state) => state.copyWith(dataLanguage: newLang),
              );
        }
      },
    );
  }
}

class _BackUpTile extends ConsumerWidget {
  const _BackUpTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: const Text("备份和恢复"),
      onTap: () async {
        TextEditingController controller = TextEditingController();

        String backupString =
            await ref.read(repoProvider).requireValue.getRestoreData();
        if (context.mounted) {
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
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: backupString));
                              Utils.showToast("复制成功");
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
              onComfirm: () async {
                await ref
                    .read(repoProvider)
                    .requireValue
                    .restoreFavourites(controller.text);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          );
        }
      },
    );
  }
}

class _DataVersionTile extends ConsumerWidget {
  const _DataVersionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int version =
        ref.watch(repoProvider.select((value) => value.requireValue.version));

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

                              if (context.mounted) {
                                Navigator.of(context)
                                    .pop(filePath?.files.first.path);
                              }
                            },
                          ),
                        ) ??
                        "";

                    if (updateFilePath.isNotEmpty) {
                      Utils.showLoading("升级中...");

                      String cachePath = p.join(EnvProvider.tempDir, "update");
                      try {
                        var data = await File(updateFilePath).readAsBytes();

                        if (!ref.read(configProvider).ignoreSignature) {
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

                        await ref
                            .read(repoProvider)
                            .requireValue
                            .gameDb
                            .updateDb(json);
                        await for (var file
                            in Directory(cachePath).list(recursive: true)) {
                          // todo 去掉和update的比较
                          if (file is File &&
                              p.basename(file.path) != "data.bin") {
                            String relative = p.relative(file.path,
                                from: p.join(cachePath, "update"));

                            await file.rename(p.join(
                                EnvProvider.rootDir, "assets", relative));
                          }
                        }

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

class _DeviceIdTile extends ConsumerWidget {
  const _DeviceIdTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Row(
        children: const [
          Text("设备识别码"),
          Spacer(),
        ],
      ),
      onTap: () async {
        String deviceId = await ref.read(netProvider).generateDeviceId();
        String? usingDeviceId =
            (await ref.read(netProvider).getCurrentUser())[1];
        TextEditingController controller =
            TextEditingController(text: usingDeviceId ?? deviceId);
        if (context.mounted) {
          await showDialog(
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
                                var r = await ref
                                    .read(netProvider)
                                    .restoreDevice(
                                        controller.text.replaceAll(" ", ""));
                                if (r != null) {
                                  Utils.showToast("成功");
                                }
                                if (context.mounted) {
                                  Navigator.of(context).pop();
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
        }
      },
    );
  }
}

// ignore: unused_element
// class _AllowInvalidTile extends ConsumerWidget {
//   const _AllowInvalidTile({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final bool ignoreSignature = ref.watch(configProvider).ignoreSignature;

//     return SwitchListTile(
//         title: const Text("验证更新包数字签名"),
//         value: !allowInvalidUpdate,
//         onChanged: (bool newState) async {
//           // print(newState);
//           await context.read<ConfigCubit>().setAllowInvalidUpdate(!newState);
//         });
//   }
// }

class _UpdateTile extends ConsumerWidget {
  const _UpdateTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Row(
        children: const [
          Text("检查更新"),
          Spacer(),
        ],
      ),
      onTap: () async {
        var r = await ref.read(netProvider).checkUpdate(
            EnvProvider.appVersionCode,
            ref.read(repoProvider).requireValue.version);

        if (r != null && context.mounted) {
          // var info = [for (var item in r) NetUpdateInfoPO.fromJson(item)];
          if (r.isEmpty) {
            Utils.showToast("未发现更新");
          } else {
            await showDialog(
                context: context,
                builder: (context) => UpdateWebDialog(
                      updateInfo: r.map((e) => e.toBusinessModel()).toList(),
                      db: ref.read(repoProvider).requireValue.gameDb,
                    ));
          }
        }
      },
    );
  }
}
