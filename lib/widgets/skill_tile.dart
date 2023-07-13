import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/styles/text_styles.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class SkillTile extends ConsumerWidget {
  const SkillTile({
    Key? key,
    required this.skill,
    required this.iconHeight,
    this.heroHeight,
    this.tailBtn,
    this.onClick,
  }) : super(key: key);
  final Skill skill;
  final double iconHeight;
  final double? heroHeight;
  final Widget? tailBtn;
  final Function(String idTag)? onClick;

  Future<Person?> getPerson(Repository repo, String tag) async =>
      await repo.person.read(tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String iconPath = skill.category == 15
        ? p.join("blessing", "${skill.iconId}.webp")
        : p.join("icons",
            "${skill.category! < 3 ? (skill.category! + 1) : skill.iconId}.webp");

    final repo = ref.watch(repoProvider).requireValue;

    return ExpansionTile(
      title: Row(
        children: [
          UniImage(
            path: p.join("assets", iconPath).replaceAll(r"\", "/"),
            height: iconHeight,
          ),
          _SkillTitle(
            skill: skill,
          ),
          const Spacer(),
          if (tailBtn != null) tailBtn!
        ],
      ),
      children: heroHeight == null
          ? []
          : [
              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (skill.category != 15)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "SP:${skill.spCost.toString()}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .merge(const TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          // _LimitBtn(
                          //   skill: skill,
                          // ),
                        ],
                      ),
                    // 技能描述
                    Text(
                      skill.descId!.tr.replaceAll(r"$a", ""),
                      style: Theme.of(context).textTheme.descStyle,
                    ),
                    // 技能特效描述
                    if (skill.refineId != null)
                      Text(
                        "MSID_H_${skill.refineId!.replaceAll("SID_", "")}"
                            .tr
                            .replaceAll(r"$a", ""),
                        style: Theme.of(context).textTheme.descStyle.merge(
                              const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                      ),
                    skill.exclusive!
                        ? Text(
                            "无法继承",
                            style: Theme.of(context)
                                .textTheme
                                .descStyle
                                .merge(const TextStyle(color: Colors.red)),
                          )
                        : skill.category != 0
                            ? _LimitWidget(
                                skill: skill,
                              )
                            : const SizedBox.shrink(),
                  ],
                ),
              ),
              if ((skill.rarity3).isNotEmpty)
                ListTile(
                  title: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      UniImage(
                        path: p
                            .join("assets", "static", "Rarity3.png")
                            .replaceAll(r"\", "/"),
                        height: heroHeight!,
                      ),
                      for (int i = 0; i < skill.rarity3.length; i++)
                        InkWell(
                          onTap: () =>
                              onClick?.call(skill.rarity3.elementAt(i)),
                          child: FutureBuilder<Person?>(
                            future: getPerson(repo, skill.rarity3.elementAt(i)),
                            builder: (context, snapshot) =>
                                (snapshot.hasData && !snapshot.hasError)
                                    ? ClipOval(
                                        child: UniImage(
                                        path: p
                                            .join("assets", "faces",
                                                "${snapshot.data?.faceName}.webp")
                                            .replaceAll(r"\", "/"),
                                        height: heroHeight!,
                                      ))
                                    : const SizedBox.shrink(),
                          ),
                        ),
                    ],
                  ),
                ),
              if (skill.rarity4.isNotEmpty)
                ListTile(
                  title: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      UniImage(
                        path: p
                            .join("assets", "static", "Rarity4.png")
                            .replaceAll(r"\", "/"),
                        height: heroHeight!,
                      ),
                      for (int i = 0; i < skill.rarity4.length; i++)
                        InkWell(
                          onTap: () =>
                              onClick?.call(skill.rarity4.elementAt(i)),
                          child: FutureBuilder<Person?>(
                            future: getPerson(repo, skill.rarity4.elementAt(i)),
                            builder: (context, snapshot) =>
                                (snapshot.hasData && !snapshot.hasError)
                                    ? ClipOval(
                                        child: UniImage(
                                        path: p
                                            .join("assets", "faces",
                                                "${snapshot.data?.faceName}.webp")
                                            .replaceAll(r"\", "/"),
                                        height: heroHeight!,
                                      ))
                                    : const SizedBox.shrink(),
                          ),
                          // child: ClipOval(
                          //   child: UniImage(
                          //     path: p
                          //         .join("assets", "faces",
                          //             "${repo.cachePersons[skill.rarity4.elementAt(i)]!.faceName}.webp")
                          //         .replaceAll(r"\", "/"),
                          //     height: heroHeight!,
                          //   ),
                          // ),
                        )
                    ],
                  ),
                ),
              if (skill.rarity5.isNotEmpty)
                ListTile(
                  title: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      UniImage(
                        path: p
                            .join("assets", "static", "Rarity5.png")
                            .replaceAll(r"\", "/"),
                        height: heroHeight!,
                      ),
                      for (int i = 0; i < skill.rarity5.length; i++)
                        InkWell(
                          onTap: () =>
                              onClick?.call(skill.rarity5.elementAt(i)),
                          child: FutureBuilder<Person?>(
                            future: getPerson(repo, skill.rarity5.elementAt(i)),
                            builder: (context, snapshot) =>
                                (snapshot.hasData && !snapshot.hasError)
                                    ? ClipOval(
                                        child: UniImage(
                                        path: p
                                            .join("assets", "faces",
                                                "${snapshot.data?.faceName}.webp")
                                            .replaceAll(r"\", "/"),
                                        height: heroHeight!,
                                      ))
                                    : const SizedBox.shrink(),
                          ),
                          // child: ClipOval(
                          //   child: UniImage(
                          //     path: p
                          //         .join("assets", "faces",
                          //             "${repo.cachePersons[skill.rarity5.elementAt(i)]!.faceName}.webp")
                          //         .replaceAll(r"\", "/"),
                          //     height: heroHeight!,
                          //   ),
                          // ),
                        )
                    ],
                  ),
                ),
            ],
    );
  }
}

class _SkillTitle extends StatelessWidget {
  const _SkillTitle({
    Key? key,
    this.skill,
  }) : super(key: key);
  final Skill? skill;

  @override
  Widget build(BuildContext context) {
    if (skill?.category == 0) {
      String effectTag = "";
      if (skill?.refined ?? false) {
        try {
          effectTag = skill!.idTag?.split("_")[2] ?? "";
          // ignore: empty_catches
        } on Exception {}
      }
      return Text(
          "${(skill?.nameId! ?? "").tr} ${effectTag.tr} [${skill!.might}]");
    } else if (skill?.category == 2) {
      return Text("${(skill?.nameId! ?? "").tr} [${skill!.cooldownCount}]");
    } else {
      return Text((skill?.nameId! ?? "").tr);
    }
  }
}

// 限制类型显示的弹出实现，暂时没有使用
// class _LimitBtn extends StatefulWidget {
//   const _LimitBtn({
//     Key? key,
//     required this.skill,
//   }) : super(key: key);
//   final Skill skill;
//   @override
//   State<_LimitBtn> createState() => __LimitBtnState();
// }

// class __LimitBtnState extends State<_LimitBtn> with TickerProviderStateMixin {
//   late AnimationController _aniController;

//   late Animation<double> _animation;

//   late OverlayEntry overlayEntry;

//   void _showOverlay(BuildContext context) {
//     overlayEntry = _createOverlayEntry(context);
//     _aniController.reset();
//     _aniController.forward();
//     Overlay.of(context)!.insert(overlayEntry);
//   }

//   OverlayEntry _createOverlayEntry(BuildContext context) {
//     final RenderBox itemBox = context.findRenderObject()! as RenderBox;
//     final Offset offset = itemBox.localToGlobal(
//       Offset.zero,
//     );
//     final double width = MediaQuery.of(context).size.width;
//     final double height = MediaQuery.of(context).size.height;
//     return OverlayEntry(
//       builder: (context) {
//         return Positioned(
//             left: 0,
//             top: offset.dy - 200,
//             child: ScaleTransition(
//               scale: _animation,
//               child: SizedBox(
//                 width: offset.dx,
//                 height: 200,
//                 child: Align(
//                   alignment: Alignment.bottomCenter,
//                   child: _LimitTile(
//                     skill: widget.skill,
//                   ),
//                 ),
//               ),
//               // child: SizedBox(
//               //   width: offset.dx,
//               //   height: 200,
//               //   child: Card(
//               //     color: Colors.blue,
//               //   ),
//               // ),
//             ));
//       },
//     );
//   }

//   @override
//   void initState() {
//     _aniController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 150));
//     _aniController.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//       } else if (status == AnimationStatus.dismissed) {
//         overlayEntry.remove();
//       }
//     });

//     _animation = CurvedAnimation(parent: _aniController, curve: Curves.ease);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return InkWell(
//     //   onTap: () {},
//     //   onTapDown: (detail) {
//     //     print("object");
//     //   },
//     //   onTapCancel: () {
//     //     print("objectc");
//     //   },
//     //   child: Icon(Icons.info),
//     // );
//     return GestureDetector(
//       onTapDown: (detail) {
//         _showOverlay(context);
//       },
//       onTapUp: (detail) {
//         _aniController.reverse();
//       },
//       child: Icon(Icons.info),
//     );
//     // return IconButton(

//     //     onPressed: () {
//     //       _showOverlay(context);
//     //     },
//     //     icon: const Icon(Icons.info));
//   }
// }

class _LimitWidget extends StatelessWidget {
  const _LimitWidget({
    Key? key,
    required this.skill,
  }) : super(key: key);
  final Skill skill;

  List<int> getMoveLimit(Skill skill) {
    List<int> result = [];
    if (skill.movEquip != 15) {
      // 15代表不限制，转为二进制后24位全部为1
      List<String> moveLimit = skill.movEquip!
          .toRadixString(2)
          .padLeft(4, "0")
          .split("")
          .reversed
          .toList();
      for (var i = 0; i < moveLimit.length; i++) {
        if (moveLimit[i] == "0") {
          result.add(i);
        }
      }
    }
    return result;
  }

  // int sort2Index(int sortId) {
  //   if (sortId > 3 && sortId <= 15) {
  //     return sortId - 1;
  //   } else if (sortId == 3) {
  //     return 15;
  //   } else {
  //     return sortId;
  //   }
  // }

  // 避免多次从sort转index计算
  // 生成方法
  //for (var i = 0; i < 4; i++) {
  //   for (var j = 0; j < 6; j++) {
  //     int index = sort2Index(i + j * 4);
  //     result.add(index);
  //   }
  // }
  final List<int> limitation = const [
    0,
    3,
    7,
    11,
    16,
    20,
    1,
    4,
    8,
    12,
    17,
    21,
    2,
    5,
    9,
    13,
    18,
    22,
    6,
    10,
    14,
    15,
    19,
    23
  ];

  List<int> getWepLimit(Skill skill) {
    List<int> result = [];
    if (skill.wepEquip != 16777215) {
      // 16777215代表不限制，转为二进制后24位全部为1
      List<String> weaponLimit = skill.wepEquip!
          .toRadixString(2)
          .padLeft(24, "0")
          .split("")
          .reversed
          .toList();
      // 按游戏里显示的顺序排序
      for (var index in limitation) {
        if (weaponLimit[index] == "0") {
          result.add(index);
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // 32768是杖系技能的数值
    if (skill.wepEquip == 32768) {
      return Text(
        "仅限武器为杖者装备",
        style:
            Theme.of(context).textTheme.descStyle.copyWith(color: Colors.red),
      );
    } else {
      List<int> weaponLimit = getWepLimit(skill);
      List<int> moveLimit = getMoveLimit(skill);
      if (weaponLimit.isNotEmpty || moveLimit.isNotEmpty) {
        return Wrap(
          children: [
            Text(
              "无法装备",
              style: Theme.of(context)
                  .textTheme
                  .descStyle
                  .copyWith(color: Colors.red),
            ),
            for (var i in moveLimit)
              UniImage(
                path: p.join("assets", "move", "$i.webp").replaceAll(r"\", "/"),
                height: 20,
              ),
            for (var i in weaponLimit)
              UniImage(
                path:
                    p.join("assets", "weapon", "$i.webp").replaceAll(r"\", "/"),
                height: 20,
              ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    // return Card(
    //   elevation: 5,
    //   child: Column(
    //     children: [
    //       const Text("装备限制"),
    //       // Text(skill.wepEquip.toString()),
    //       Wrap(
    //         children: [
    //           for (var i = 0; i < weaponLimit.length; i++)
    //             if (weaponLimit[i] == "0")
    //               UniImage(
    //                 path: p
    //                     .join("assets", "weapon", "$i.webp")
    //                     .replaceAll(r"\", "/"),
    //                 height: 20,
    //               ),
    //         ],
    //       ),
    //       Wrap(
    //         children: [
    //           for (var i = 0; i < moveLimit.length; i++)
    //             if (moveLimit[i] == "0")
    //               UniImage(
    //                 path: p
    //                     .join("assets", "move", "$i.webp")
    //                     .replaceAll(r"\", "/"),
    //                 height: 20,
    //               ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
