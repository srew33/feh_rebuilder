import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:feh_rebuilder/data_service.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/person/stats.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:image_save/image_save.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';

class ShareWidget extends StatefulWidget {
  final PersonBuild build;
  final Stats equipedStats;

  const ShareWidget({Key? key, required this.build, required this.equipedStats})
      : super(key: key);

  @override
  _ShareWidgetState createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  late final Person _person;
  late final String _appPath;

  ///共8个，去掉了专武
  final List<Skill?> _skills = [];
  late final Map<String, int> _stats;
  final DataService _dataService = Get.find<DataService>();
  GlobalKey screenShot = GlobalKey();
  final TextEditingController _textEditingController = TextEditingController();
  String edcodedString = "";
  Uint8List? testBytes;

  Color _getStatColor(String k) {
    if (k == widget.build.advantage) {
      return Colors.green;
    } else if (k == widget.build.disAdvantage) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  Widget _buildSkill(int index) {
    Image image;
    List<String> key = _stats.keys.toList();
    List<int> val = _stats.values.toList();
    switch (index) {
      case 0:
        image = Image.file(
          File(p.join(_appPath, "assets/icons/1.webp")),
          height: 22,
          errorBuilder: (context, obj, s) =>
              Image.asset("assets/static/0.webp"),
        );
        break;
      case 1:
        image = Image.file(
          File(p.join(_appPath, "assets/icons/2.webp")),
          height: 22,
          errorBuilder: (context, obj, s) =>
              Image.asset("assets/static/1.webp"),
        );
        break;
      case 2:
        image = Image.file(
          File(p.join(_appPath, "assets/icons/3.webp")),
          height: 22,
          errorBuilder: (context, obj, s) =>
              Image.asset("assets/static/2.webp"),
        );
        break;
      case 7:
        image = _skills[7] == null
            ? Image.file(
                File(p.join(_appPath, "assets/blessing/0.webp")),
                height: 22,
                errorBuilder: (context, obj, s) => const Icon(
                  Icons.error,
                  size: 22,
                ),
              )
            : Image.file(
                File(p.join(
                    _appPath, "assets/blessing/${_skills[7]!.iconId}.webp")),
                height: 22,
                errorBuilder: (context, obj, s) => const Icon(
                  Icons.error,
                  size: 22,
                ),
              );
        break;
      default:
        image = _skills[index] == null
            ? Image.asset(
                "assets/static/$index.png",
                height: 16,
              )
            : Image.file(
                File(p.join(
                    _appPath, "assets/icons/${_skills[index]!.iconId}.webp")),
                height: 22,
              );
        break;
    }

    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (index < 5)
                Row(
                  children: [
                    Text(
                      "CUSTOM_STATS_${key[index].toUpperCase()}".tr,
                      style: TextStyle(
                          fontSize: 12, color: _getStatColor(key[index])),
                    ),
                    if (key[index] == widget.build.ascendedAsset)
                      Image.asset(
                        "assets/static/Icon_FlowerBud.png",
                        height: 22,
                      ),
                  ],
                ),
              if (index < 5)
                Text(val[index].toString(),
                    style: const TextStyle(fontSize: 12)),
              if (index == 5) const Text("突破", style: TextStyle(fontSize: 12)),
              if (index == 5)
                Text(widget.build.merged.toString(),
                    style: const TextStyle(fontSize: 12)),
              if (index == 6)
                const Text("神龙之花", style: TextStyle(fontSize: 12)),
              if (index == 6)
                Text(widget.build.dragonflowers.toString(),
                    style: const TextStyle(fontSize: 12)),
              if (index == 7)
                const Text("召唤师的羁绊", style: TextStyle(fontSize: 12)),
              if (index == 7)
                widget.build.summonerSupport
                    ? const Icon(Icons.radio_button_checked, size: 15)
                    : const Icon(Icons.circle_outlined, size: 15),
            ],
          ),
        )),
        Expanded(
          child: Row(
            children: [
              image,
              const SizedBox(width: 5),
              Expanded(
                  child: Text(
                _skills[index] == null ? "" : (_skills[index]!.nameId)!.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              )),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 370,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RepaintBoundary(
            key: screenShot,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    child: QrImage(
                      data: edcodedString,
                      version: QrVersions.auto,
                      size: 75.0,
                    ),
                  ),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          widget.build.resplendent
                              ? ClipOval(
                                  child: Image.file(
                                    File(p.join(_appPath, "assets", "faces",
                                        "${_person.faceName!}EX01.webp")),
                                    height: 60,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder: (context, obj, s) =>
                                        const Icon(Icons.error),
                                  ),
                                )
                              : ClipOval(
                                  child: Image.file(
                                    File(p.join(_appPath, "assets", "faces",
                                        "${_person.faceName!}.webp")),
                                    height: 60,
                                    filterQuality: FilterQuality.high,
                                    errorBuilder: (context, obj, s) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(("MPID_HONOR_" +
                                          _person.idTag!.split("_")[1])
                                      .tr),
                                  Row(
                                    children: [
                                      Text(("MPID_" +
                                              _person.idTag!.split("_")[1])
                                          .tr),
                                      if (widget.build.resplendent)
                                        Image.asset(
                                          r"assets/static/godwear.webp",
                                          height: 22,
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.file(
                                        File(p.join(_appPath,
                                            "assets/move/${_person.moveType}.webp")),
                                        height: 20,
                                      ),
                                      Image.file(
                                        File(p.join(_appPath,
                                            "assets/weapon/${_person.weaponType}.webp")),
                                        height: 22,
                                      ),

                                      // Spacer(),
                                      Text(
                                        "竞技场分数：${widget.build.arenaScore}",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (int i = 0; i < 8; i++) _buildSkill(i)
                    ],
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(labelText: "手动复制Build编码"),
              readOnly: true,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () async {
                    RenderRepaintBoundary boundary = screenShot.currentContext!
                        .findRenderObject() as RenderRepaintBoundary;
                    // 从
                    final ui.Image image = await boundary.toImage(
                        pixelRatio: MediaQuery.of(context).devicePixelRatio);
                    final ByteData? byteData = await image.toByteData(
                        format: ui.ImageByteFormat.rawUnmodified);
                    final Uint8List bytes = byteData!.buffer.asUint8List();

                    var screen =
                        img.Image.fromBytes(image.width, image.height, bytes);
                    Uint8List _bytes =
                        Uint8List.fromList(img.encodeJpg(screen));

                    try {
                      bool success = await ImageSave.saveImage(_bytes,
                              "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg",
                              albumName: "feh_rebuilder") ??
                          false;

                      success ? Utils.showToast("成功") : Utils.showToast("失败");
                    } on MissingPluginException catch (e, s) {
                      showDialog(
                          context: context,
                          builder: (context) => const SimpleDialog(
                                title: Text("不支持的平台！"),
                              ));

                      Utils.debug(s.toString());
                    }
                  },
                  child: const Text("保存到相册")),
              TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text("取消")),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    _person =
        Person.fromJson(_dataService.personBox.read(widget.build.personTag));
    _appPath = _dataService.appPath.path;
    _stats = widget.equipedStats.toJson();

    // 这里去掉专武
    for (var skillTag in widget.build.equipSkills.sublist(0, 8)) {
      skillTag == null
          ? _skills.add(null)
          : _skills.add(Skill.fromJson(_dataService.skillBox.read(skillTag)));
    }
    edcodedString = Utils.encodeBuild(widget.build, _skills, _person);
    _textEditingController.text = edcodedString;

    super.initState();
  }
}
