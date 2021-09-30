import 'dart:io';

import 'package:feh_tool/global/enum/sortKey.dart';
import 'package:feh_tool/models/person/person.dart';
import 'package:feh_tool/models/personBuild/personBuild.dart';

import 'package:feh_tool/pages/home/widgets/customListView.dart';
import 'package:feh_tool/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:path/path.dart' as p;
import 'homePageController.dart';

class HomePage extends GetView<HomePageController> {
  @override
  Widget build(BuildContext context) {
    ItemPositionsListener.create();
    if (controller.grouped.length > 0) {
      return CustomListView<Person>(
        key: controller.listKey,
        data: controller.grouped,
        elementBuilder: (context, person) => ListTile(
          leading: ClipOval(
            child: Image.file(
              File(
                  "${controller.data.appPath.path}/assets/faces/${person.faceName!}.webp"),
              errorBuilder: (context, obj, s) => Icon(Icons.error),
            ),
          ),
          title: Text(("M${person.idTag!}").tr
              // + "  ${person.roman}"
              ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    Image.file(
                      File(p.join(controller.data.appPath.path, "assets",
                          "move", "${person.moveType}.webp")),
                      height: 20,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (context, obj, s) => Icon(Icons.error),
                    ),
                    Image.file(
                      File(p.join(controller.data.appPath.path, "assets",
                          "weapon", "${person.weaponType}.webp")),
                      filterQuality: FilterQuality.none,
                      height: 23,
                      errorBuilder: (context, obj, s) => Icon(Icons.error),
                    )
                    // Text(person.moveType.toString()),
                    // Text(person.weaponType.toString()),
                  ],
                ),
              ),
              Text(person.defaultStats!.hp.toString()),
              Text(person.defaultStats!.atk.toString()),
              Text(person.defaultStats!.spd.toString()),
              Text(person.defaultStats!.def.toString()),
              Text(person.defaultStats!.res.toString()),
              Text(
                  "[${controller.currentSortKey == SortKey.bst ? person.bst.toString() : person.defaultStats!.sum.toString()}]"),
              Padding(padding: EdgeInsets.only(right: 15))
            ],
          ),
          onTap: () {
            Utils.debug(person.idTag!);
            Get.toNamed(
              "/heroDetail",
              arguments: PersonBuild(idTag: person.idTag!, equipSkills: []),
            );
          },
        ),
        headerBuilder: (context, data) => Container(
          color: Colors.grey.shade300,
          child: Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              data,
              style: Get.textTheme.headline5,
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
