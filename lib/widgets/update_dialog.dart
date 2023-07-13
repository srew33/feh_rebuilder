import 'dart:io';

// import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

import 'package:feh_rebuilder/env_provider.dart';
import 'package:feh_rebuilder/models/build_share/update_table.dart';
import 'package:feh_rebuilder/repositories/data_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateWebDialog extends StatelessWidget {
  final List<UpdateTableBusinessModel> updateInfo;

  const UpdateWebDialog({
    Key? key,
    required this.updateInfo,
    required this.db,
  }) : super(key: key);
  final GameDb db;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "发现更新！",
                style: Theme.of(context).textTheme.titleLarge!,
              ),
              Expanded(
                child: _Content(
                  updateInfo: updateInfo,
                  db: db,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  final List<UpdateTableBusinessModel> updateInfo;
  const _Content({
    Key? key,
    required this.updateInfo,
    required this.db,
  }) : super(key: key);
  final GameDb db;
  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool isDownloading = false;
  double downloadProcess = 0;
  // final GlobalKey<_ProcessIndicatorState> _process =
  //     GlobalKey<_ProcessIndicatorState>();
  late UpdateTableBusinessModel selected;
  //使用已被取消的CancelToken会导致任务直接认为已被取消，
  //因此CancelToken每次使用需要重新实例化
  late CancelToken _cancelToken;
  final Map<int, UpdateTableBusinessModel> _updateInfo = {};
  var dio = Dio();
  late GameDb db;

  Map<int, String> typeDict = const {
    0: "APP",
    1: "数据包",
  };
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton(
          value: selected.type,
          isExpanded: true,
          items: [
            for (var type in _updateInfo.keys)
              DropdownMenuItem(
                enabled: !isDownloading,
                value: type,
                child: Text(typeDict[type] ?? ""),
              ),
          ],
          onChanged: (value) {
            setState(() {
              selected = _updateInfo[value]!;
            });
          },
        ),
        ListTile(
          title: Text(
            selected.alias ?? "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("主要更新内容："),
              SelectableText(selected.info ?? "无"),
            ],
          ),
        )),
        Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: () async {
                try {
                  var uri = Uri.parse(selected.url);
                  launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (e) {
                  Utils.showToast(e.toString());
                }
              },
              child: const Text("跳转到下载地址"),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text("密码："),
            SelectableText(selected.downloadSecret),
            const Spacer(),
          ],
        ),
        // github中转加速不稳定，暂时移除在线更新功能，变为跳转到网盘地址手动下载

        // Stack(
        //   alignment: AlignmentDirectional.center,
        //   children: [
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //       children: [
        //         TextButton(
        //             onPressed: !isDownloading ? download : cleanCache,
        //             child:
        //                 !isDownloading ? const Text("下载") : const Text("清除缓存")),
        //         TextButton(
        //             onPressed: !isDownloading
        //                 ? () {
        //                     // 返回
        //                     Navigator.pop(context);
        //                   }
        //                 : () {
        //                     // 取消
        //                     setState(() {
        //                       isDownloading = false;
        //                       _cancelToken.cancel();
        //                     });
        //                   },
        //             child:
        //                 !isDownloading ? const Text("返回") : const Text("取消")),
        //       ],
        //     ),
        //     Visibility(
        //         visible: isDownloading,
        //         child: FittedBox(
        //           child: downloadProcess >= 1
        //               ? TextButton(onPressed: install, child: const Text("安装"))
        //               : Stack(
        //                   alignment: AlignmentDirectional.center,
        //                   children: [
        //                     _ProcessIndicator(
        //                       key: _process,
        //                     )
        //                   ],
        //                 ),
        //         ))
        //   ],
        // )
      ],
    );
  }

  Future<void> cleanCache() async {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel("用户取消");
    }

    Directory target = Directory(p.join(
      EnvProvider.tempDir,
      "download",
    ));
    if (await target.exists()) {
      await for (var item in target.list()) {
        await item.delete();
      }
    }

    setState(() {
      isDownloading = false;
    });
  }

  // Future<void> download() async {
  //   setState(() {
  //     isDownloading = true;
  //     downloadProcess = 0;
  //   });
  //   await _downloadFile([selected]);
  // }

  @override
  void initState() {
    for (var item in widget.updateInfo) {
      // widget.updateInfo是按id降序排好的，这里不再排序直接添加即可
      // item.type:0代表app，1代表数据包
      _updateInfo.putIfAbsent(item.type!, () => item);
    }
    db = widget.db;

    selected = _updateInfo.values.first;
    super.initState();
  }

  // Future<void> install() async {
  //   if (EnvProvider.platformType == PlatformType.Android) {
  //     p.extension(selected.url.toLowerCase()) == ".apk"
  //         ? OpenFilex.open(p.join(
  //             EnvProvider.tempDir,
  //             "download",
  //             p.basename(selected.url),
  //           ))
  //         : await updateGameDb();
  //   } else {
  //     throw UnimplementedError();
  //   }
  // }

  // Future<void> updateGameDb() async {
  //   Utils.showLoading("更新中");
  //   // await Future.delayed(const Duration(milliseconds: 100));
  //   File target = File(
  //     p.join(
  //       EnvProvider.tempDir,
  //       "download",
  //       p.basename(selected.url),
  //     ),
  //   );

  //   final bytes = await target.readAsBytes();
  //   if (bytes.length > 384) {
  //     Uint8List data = bytes.sublist(0, bytes.length - 384);
  //     Uint8List signature = bytes.sublist(bytes.length - 384, bytes.length);

  //     try {
  //       if (await Utils.verifySignature(data, signature)) {
  //         var cacheFolder = Directory(p.join(EnvProvider.tempDir, "update"));
  //         await extractFileToDisk(target.absolute.path, cacheFolder.path);
  //         await for (var entry in cacheFolder.list(recursive: true)) {
  //           if (entry is File) {
  //             if (p.basename(entry.path) == "data.bin") {
  //               var bytes = await File(
  //                 p.join(
  //                   EnvProvider.tempDir,
  //                   "update",
  //                   "data.bin",
  //                 ),
  //               ).readAsBytes();
  //               var decoded = const ZLibDecoder().decodeBytes(bytes);
  //               await db.updateDb(jsonDecode(utf8.decode(decoded)));
  //             } else if (p.extension(entry.path) == ".webp") {
  //               var relativePath = p.join(cacheFolder.path, "update");

  //               String relative = p.relative(entry.path, from: relativePath);

  //               await entry
  //                   .rename(p.join(EnvProvider.rootDir, "assets", relative));
  //             }
  //           }
  //         }

  //         Utils.showToast("更新完成，请重启程序");
  //       } else {
  //         Utils.showToast("非法的更新包");
  //       }
  //     } catch (e) {
  //       Utils.showToast("更新失败: ${e.toString()}");
  //     }
  //   } else {
  //     Utils.showToast("更新包数据错误");
  //   }
  // }

  // Future<bool> _checkFile(String path, String checksum) async {
  //   File target = File(p.join(
  //     EnvProvider.tempDir,
  //     "download",
  //     p.basename(path),
  //   ));
  //   if (checksum.isEmpty || !await target.exists()) {
  //     return false;
  //   }

  //   String computedChecksum = await compute(Utils.getChecksum, target.path);
  //   return computedChecksum == checksum;
  // }

  // Future _downloadFile(List<UpdateTableBusinessModel> tasks) async {
  //   try {
  //     for (var i = 0; i < tasks.length; i++) {
  //       _cancelToken = CancelToken();
  //       UpdateTableBusinessModel task = tasks[i];
  //       Utils.debug("开始下载${task.url}");
  //       File target = File(p.join(
  //         EnvProvider.tempDir,
  //         "download",
  //         p.basename(task.url!),
  //       ));
  //       Response resp;
  //       if (await _checkFile(task.url!, task.checksum ?? "")) {
  //         Utils.debug("使用缓存");
  //         resp = Response(
  //           requestOptions: RequestOptions(path: task.url!),
  //           statusCode: 200,
  //         );
  //         _process.currentState!.setProcess((1 + i) / tasks.length);
  //       } else {
  //         Utils.debug("未发现缓存");
  //         if (await target.exists()) {
  //           await target.delete();
  //         }
  //         try {
  //           resp = await dio.download(
  //             task.url!,
  //             target.path,
  //             onReceiveProgress: (int now, int all) {
  //               _process.currentState!
  //                   .setProcess((now / all + i) / tasks.length);
  //             },
  //             cancelToken: _cancelToken,
  //           );
  //         } on DioError catch (e) {
  //           Utils.debug("下载失败:${e.response?.statusCode}");
  //           if (e.type == DioErrorType.cancel) {
  //             Utils.showToast("下载失败：用户取消请求");
  //             Utils.debug("下载失败:${e.response?.statusCode}");
  //           } else {
  //             Utils.showToast("下载失败:无法下载");
  //             Utils.debug("下载失败:${e.response?.statusCode}");
  //           }
  //           return;
  //         }
  //       }
  //       if (resp.statusCode != 200 ||
  //           !await _checkFile(task.url, task.checksum.trim())) {
  //         Utils.showToast("下载失败：无法下载或签名错误");
  //         throw "下载验证失败";
  //       }
  //     }
  //     setState(() {
  //       downloadProcess = 1;
  //     });
  //   } on Exception catch (e, s) {
  //     Utils.showToast("下载失败：${e.toString()}");
  //     Utils.debug("下载失败:${s.toString()}");
  //   }
  // }
}

// class _ProcessIndicator extends StatefulWidget {
//   const _ProcessIndicator({Key? key}) : super(key: key);

//   @override
//   _ProcessIndicatorState createState() => _ProcessIndicatorState();
// }

// class _ProcessIndicatorState extends State<_ProcessIndicator> {
//   double downloadProcess = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: AlignmentDirectional.center,
//       children: [
//         CircularProgressIndicator(
//           value: downloadProcess,
//         ),
//         Text((downloadProcess * 100).floor().toString()),
//       ],
//     );
//   }

//   void setProcess(double value) {
//     setState(() {
//       downloadProcess = value;
//     });
//   }
// }
