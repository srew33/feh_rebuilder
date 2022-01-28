import 'dart:io';

import 'package:feh_rebuilder/global/enum/sort_key.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/pages/home/widgets/jumpable_listview.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'home_page_controller.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.grouped.isNotEmpty) {
      return JumpableListView<Person>(
        groupData: controller.grouped,
        itemBuilder: (context, person) => MyTile(
          path: controller.data.appPath.path,
          person: person,
          showVersion: controller.currentSortKey == SortKey.versionNum,
          sum: controller.currentSortKey == SortKey.bst
              ? person.bst.toString()
              : person.defaultStats!.sum.toString(),
        ),
        scrollController: controller.sc,
        itemExtent: 80,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class MyTile extends StatelessWidget {
  const MyTile({
    Key? key,
    required this.path,
    required this.person,
    required this.sum,
    required this.showVersion,
  }) : super(key: key);
  final String path;
  final Person person;
  final String sum;
  final bool showVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.transparent,
      child: Card(
        elevation: 0,
        child: InkWell(
          onTap: () {
            Utils.debug(person.idTag!);
            Get.toNamed(
              "/heroDetail",
              arguments: PersonBuild(personTag: person.idTag!, equipSkills: []),
            );
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipOval(
                  child: Image.file(
                    File(p.join(
                        path, "assets", "faces", "${person.faceName!}.webp")),
                    height: 60,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (context, obj, s) => const Icon(Icons.error),
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
                      Text(("M${person.idTag!}").tr),
                      // const Spacer(),
                      if (showVersion)
                        Text(
                            " [${(person.versionNum! / 100).floor()}.${person.versionNum! % 100}]"),
                      const SizedBox(
                        width: 40,
                      )
                    ],
                  ),
                  Row(
                    children: [
                      MyTile1(path: path, person: person),
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
      ),
    );
  }
}

class MyTile1 extends StatelessWidget {
  const MyTile1({Key? key, required this.path, required this.person})
      : super(key: key);
  final String path;
  final Person person;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: Row(
        children: [
          Image(
            height: 20,
            image: FileImage(
              File(p.join(path, "assets", "move", "${person.moveType}.webp")),
            ),
          ),
          Image(
            height: 23,
            image: FileImage(
              File(p.join(
                  path, "assets", "weapon", "${person.weaponType}.webp")),
            ),
          ),
        ],
      ),
    );
  }
}
