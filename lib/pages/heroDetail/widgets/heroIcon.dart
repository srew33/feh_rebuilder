import 'dart:io';

import 'package:feh_tool/models/person/person.dart';
import 'package:feh_tool/models/skill/skill.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:path/path.dart' as p;

class HeroIcon extends StatefulWidget {
  final Person person;
  final String appPath;
  const HeroIcon({Key? key, required this.person, required this.appPath})
      : super(key: key);

  @override
  _HeroIconState createState() => _HeroIconState();
}

class _HeroIconState extends State<HeroIcon> with TickerProviderStateMixin {
  late AnimationController _aniController;

  late Animation<double> _animation;

  late OverlayEntry overlayEntry;

  void _showOverlay(BuildContext context) {
    overlayEntry = _createOverlayEntry(context);
    _aniController.reset();
    _aniController.forward();
    Overlay.of(context)!.insert(overlayEntry);
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Offset offset = itemBox.localToGlobal(
      Offset.zero,
    );
    return OverlayEntry(
      builder: (context) {
        List<Skill?> skills = widget.person.skills!.getSkills();
        return Positioned(
          left: (offset.dx + itemBox.size.width / 2 + 170) >
                  MediaQuery.of(context).size.width
              ? MediaQuery.of(context).size.width - 170 - 5
              : offset.dx + itemBox.size.width / 2,
          top: (offset.dy - 200) > kToolbarHeight
              ? offset.dy - 200
              : offset.dy + itemBox.size.height,
          width: 170,
          height: 200,
          child: ScaleTransition(
            scale: _animation,
            child: Card(
              elevation: 15,
              child: Column(
                children: [
                  Text(("MPID_" + widget.person.idTag!.split("_")[1]).tr),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Image.file(
                          File(p.join(widget.appPath,
                              "assets/move/${widget.person.moveType}.webp")),
                          height: 20,
                        ),
                        Image.file(
                          File(p.join(widget.appPath,
                              "assets/weapon/${widget.person.weaponType}.webp")),
                          height: 22,
                        ),
                        Spacer(),
                        Text("竞技场：${widget.person.bst}"),
                      ],
                    ),
                  ),
                  // 应该可以通过循环生成
                  Row(
                    children: [
                      SizedBox(width: 5),
                      Image.file(
                        File(p.join(widget.appPath, "assets/icons/1.webp")),
                        height: 22,
                        errorBuilder: (context, obj, s) =>
                            Image.asset("assets/static/0.webp"),
                      ),
                      SizedBox(width: 5),
                      Text(skills[0] == null ? "" : (skills[0]!.nameId)!.tr),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(width: 5),
                      Image.file(
                        File(p.join(widget.appPath, "assets/icons/2.webp")),
                        height: 22,
                        errorBuilder: (context, obj, s) =>
                            Image.asset("assets/static/1.webp"),
                      ),
                      SizedBox(width: 5),
                      Text(skills[1] == null ? "" : (skills[1]!.nameId)!.tr),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(width: 5),
                      Image.file(
                        File(p.join(widget.appPath, "assets/icons/3.webp")),
                        height: 22,
                        errorBuilder: (context, obj, s) =>
                            Image.asset("assets/static/2.webp"),
                      ),
                      SizedBox(width: 5),
                      Text(skills[2] == null ? "" : (skills[2]!.nameId)!.tr),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(width: 5),
                      skills[3] == null
                          ? Image.asset(
                              "assets/static/3.png",
                              height: 20,
                            )
                          : Image.file(
                              File(p.join(widget.appPath,
                                  "assets/icons/${skills[3]!.iconId}.webp")),
                              height: 22,
                            ),
                      SizedBox(width: 5),
                      Text(skills[3] == null ? "" : (skills[3]!.nameId)!.tr),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(width: 5),
                      skills[4] == null
                          ? Image.asset(
                              "assets/static/4.png",
                              height: 20,
                            )
                          : Image.file(
                              File(p.join(widget.appPath,
                                  "assets/icons/${skills[4]!.iconId}.webp")),
                              height: 22,
                            ),
                      SizedBox(width: 5),
                      Text(skills[4] == null ? "" : (skills[4]!.nameId)!.tr),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      SizedBox(width: 5),
                      skills[5] == null
                          ? Image.asset(
                              "assets/static/5.png",
                              height: 20,
                            )
                          : Image.file(
                              File(p.join(widget.appPath,
                                  "assets/icons/${skills[5]!.iconId}.webp")),
                              height: 22,
                            ),
                      SizedBox(width: 5),
                      Text(skills[5] == null ? "" : (skills[5]!.nameId)!.tr),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
          _showOverlay(context);
        },
        onLongPressEnd: (detail) {
          _aniController.reverse();
        },
        child: ClipOval(
          child: Image.file(
            File(p.join(
                widget.appPath, "assets/faces/${widget.person.faceName}.webp")),
            height: 40,
          ),
        ));
  }

  @override
  void initState() {
    _aniController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    _aniController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
      } else if (status == AnimationStatus.dismissed) {
        overlayEntry.remove();
      }
    });

    _animation = CurvedAnimation(parent: _aniController, curve: Curves.ease);
    super.initState();
  }
}
