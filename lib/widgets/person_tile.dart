import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// 英雄信息显示的tile
class PersonTile extends StatelessWidget {
  /// 英雄信息显示的tile
  const PersonTile({
    Key? key,
    required this.showVersion,
    required this.person,
    required this.sum,
    required this.onClick,
  }) : super(key: key);

  /// 是否显示人物登场游戏版本
  final bool showVersion;
  final Person person;
  final String sum;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () => onClick.call(),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipOval(
                child: UniImage(
                  path: p
                      .join("assets", "faces", "${person.faceName!}.webp")
                      .replaceAll(r"\", "/"),
                  height: 60,
                ),
              ),
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    // Text(("M${person.idTag!}")).tr(),
                    Text(("M${person.idTag!}").tr),
                    if (showVersion)
                      Text(
                          " [${(person.versionNum! / 100).floor()}.${person.versionNum! % 100}]"),
                  ],
                ),
                Row(
                  children: [
                    TypeTile(person: person),
                    const Spacer(),
                    Text(person.defaultStats!.hp.toString()),
                    const Spacer(),
                    Text(person.defaultStats!.atk.toString()),
                    const Spacer(),
                    Text(person.defaultStats!.spd.toString()),
                    const Spacer(),
                    Text(person.defaultStats!.def.toString()),
                    const Spacer(),
                    Text(person.defaultStats!.res.toString()),
                    const Spacer(),
                    Text("[${sum.toString()}]"),
                    const SizedBox(
                      width: 40,
                    )
                  ],
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

class TypeTile extends StatelessWidget {
  /// 显示武器和移动类型图标
  const TypeTile({Key? key, required this.person}) : super(key: key);

  final Person person;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: Row(
        children: [
          UniImage(
            path: p
                .join("assets", "move", "${person.moveType!}.webp")
                .replaceAll(r"\", "/"),
            height: 20,
          ),
          UniImage(
            path: p
                .join("assets", "weapon", "${person.weaponType!}.webp")
                .replaceAll(r"\", "/"),
            height: 20,
          ),
        ],
      ),
    );
  }
}
