import 'dart:io';

import 'package:dio/dio.dart';
import 'package:feh_rebuilder/api_service.dart';
import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/update_resp/update_resp.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

class UpdateWebDialog extends StatelessWidget {
  final UpdateInfo appInfo;
  final UpdateInfo assetsInfo;
  const UpdateWebDialog({
    Key? key,
    required this.appInfo,
    required this.assetsInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: context.heightTransformer(dividedBy: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "发现更新！",
              style: Theme.of(context).textTheme.headline6!,
            ),
            Expanded(
              child: _Content(
                appInfo: appInfo,
                assetsInfo: assetsInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  final UpdateInfo appInfo;
  final UpdateInfo assetsInfo;
  const _Content({
    Key? key,
    required this.appInfo,
    required this.assetsInfo,
  }) : super(key: key);

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final DataService _dataService = Get.find<DataService>();
  final ApiService _apiService = Get.find<ApiService>();
  bool isDownloading = false;
  double downloadProcess = 0;
  final GlobalKey<_ProcessIndicatorState> _process =
      GlobalKey<_ProcessIndicatorState>();
  late UpdateInfo selected;
  //使用已被取消的CancelToken会导致任务直接认为已被取消，
  //因此CancelToken每次使用需要重新实例化
  late CancelToken _cancelToken;

  Future<void> download() async {
    setState(() {
      isDownloading = true;
      downloadProcess = 0;
    });
    _cancelToken = CancelToken();

    Response resp = await _apiService.download(selected.url!,
        checksum: selected.checksum!,
        cancelToken: _cancelToken, onReceiveProgress: (int now, int all) {
      _process.currentState!.setProcess(now / all);
    });

    if (resp.statusCode == 200) {
      if (await _apiService.checkFile(
        selected.url!,
        selected.checksum!,
      )) {
        setState(() {
          downloadProcess = 1;
        });
      } else {
        Utils.showToast("下载失败");
        Utils.debug("下载失败:${resp.statusCode}");
      }
    } else {
      Utils.showToast(resp.statusMessage ?? "未知错误");
      Utils.debug(resp.statusMessage ?? "未知错误");
    }
  }

  Future<void> cleanCache() async {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel("用户取消");
    }
    await _apiService.cleanCache(file: selected.url!);
    setState(() {
      isDownloading = false;
    });
  }

  // void select(UpdateInfo item) {
  //   setState(() {
  //     selected = item;
  //     isDownloading = false;
  //   });
  // }

  Future<void> install() async {
    p.extension(selected.url!.toLowerCase()) == ".apk"
        ? OpenFile.open(p.join(
            _dataService.tempDir.path,
            "download",
            p.basename(selected.url!),
          ))
        : await updateAsset();
  }

  Future<void> updateAsset() async {
    File target = File(
      p.join(
        _dataService.tempDir.path,
        "download",
        p.basename(selected.url!),
      ),
    );
    if (await Utils.verifySignature(target.path)) {
      try {
        if (await compute(
          Utils.unzipAssets,
          [target.path, _dataService.tempDir],
        )) {
          Utils.showToast("更新数据解压完成，请重启软件");
          setState(() {
            isDownloading = false;
          });
        }
      } catch (e, s) {
        Utils.debug(e.toString());
        Utils.debug(s.toString());
        Utils.showToast("更新失败");
      }
    } else {
      Utils.showToast("更新包签名验证失败！");
    }
  }

  @override
  void initState() {
    selected = widget.appInfo.serverVersion > _dataService.appVersion
        ? widget.appInfo
        : widget.assetsInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: (widget.appInfo.serverVersion > _dataService.appVersion)
              ? Text("APP：${widget.appInfo.alias}")
              : Text("资源包：${widget.assetsInfo.alias}"),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: "主要更新：\n"),
                      TextSpan(text: selected.info ?? "无"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: !isDownloading ? download : cleanCache,
                    child:
                        !isDownloading ? const Text("下载") : const Text("清除缓存")),
                TextButton(
                    onPressed: !isDownloading
                        ? () {
                            // 返回
                            Navigator.pop(context);
                          }
                        : () {
                            // 取消
                            setState(() {
                              isDownloading = false;
                              _cancelToken.cancel();
                            });
                          },
                    child:
                        !isDownloading ? const Text("返回") : const Text("取消")),
              ],
            ),
            Visibility(
                visible: isDownloading,
                child: FittedBox(
                  child: downloadProcess >= 1
                      ? TextButton(onPressed: install, child: const Text("安装"))
                      : Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            _ProcessIndicator(
                              key: _process,
                            )
                          ],
                        ),
                ))
          ],
        )
      ],
    );
  }
}

class _ProcessIndicator extends StatefulWidget {
  const _ProcessIndicator({Key? key}) : super(key: key);

  @override
  _ProcessIndicatorState createState() => _ProcessIndicatorState();
}

class _ProcessIndicatorState extends State<_ProcessIndicator> {
  double downloadProcess = 0;

  void setProcess(double value) {
    setState(() {
      downloadProcess = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        CircularProgressIndicator(
          value: downloadProcess,
        ),
        Text((downloadProcess * 100).floor().toString()),
      ],
    );
  }
}
