// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/build_share/ui.dart';
import 'package:feh_rebuilder/pages/fav/body/first/controller.dart';
import 'package:feh_rebuilder/pages/hero_detail/controller.dart';
import 'package:feh_rebuilder/pages/hero_detail/widgets/attr_tile.dart';
import 'package:feh_rebuilder/pages/local_builds/ui.dart';
import 'package:feh_rebuilder/repositories/config_provider.dart';
import 'package:feh_rebuilder/repositories/net_service/service.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/uni_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';
import 'widgets/skill_tile.dart';
import 'widgets/tiles.dart';

class HeroDetailPage extends ConsumerWidget {
  const HeroDetailPage({required this.family, this.favKey, super.key});

  /// 初始化的build
  final PersonBuild family;

  final String? favKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _AppBar(
        family,
        favKey,
      ),
      body: _Body(
        family,
      ),
    );
  }
}

class _AppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _AppBar(
    this.family,
    this.favKey,
  );
  final PersonBuild family;

  final String? favKey;

  Future<void> upload(BuildContext context, WidgetRef ref) async {
    var netService = ref.read(netProvider);
    await netService.initService();

    var selected = ValueNotifier<List<String>>([]);

    bool canceled = false;

    if (context.mounted) {
      await showDialog(
          context: context,
          builder: (context) {
            return UniDialog(
              title: "添加标签",
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TagChoose(
                  data: netService.tags,
                  selected: selected,
                ),
              ),
              onComfirm: () {
                Navigator.of(context).pop();
              },
              onCancel: () => canceled = true,
            );
          });

      if (canceled == true) {
        // Utils.showToast("上传完成");
        return;
      }
      if (selected.value.isNotEmpty) {
        PersonBuild current =
            ref.read(heroDetailPageProvider(family)).requireValue.currentBuild;
        await netService.uploadBuild(
          current.personTag,
          current.toNetBuild(),
          selected.value,
        );
        Utils.showToast("上传完成");
      }
    }
  }

  Future<void> save(WidgetRef ref) async {
    await ref.read(favFirstProvider.notifier).saveBuild(
          build: ref
              .read(heroDetailPageProvider(family))
              .requireValue
              .currentBuild,
          key: favKey,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: family.personTag.isEmpty
          ? const SizedBox.shrink()
          : Text(
              """${"MPID_HONOR_${family.personTag.split("_")[1]}".tr} ${"MPID_${family.personTag.split("_")[1]}".tr}"""),
      actions: [
        if (!kIsWeb)
          PopupMenuButton(
              onSelected: (HerodetailAction value) async {
                switch (value) {
                  case HerodetailAction.save:
                    await save(ref);
                    Utils.showToast("收藏完成");
                    break;
                  case HerodetailAction.upload:
                    if (ref.read(configProvider).allowCustomGameDB) {
                      Utils.showToast("使用自定义数据时不允许上传数据");
                      return;
                    }
                    await upload(context, ref);

                    break;
                  case HerodetailAction.webBuild:
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            HeroBuildSharePage(heroTag: family.personTag),
                      ),
                    );

                    break;
                  default:
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: HerodetailAction.save,
                      child: Text(favKey == null ? "收藏" : "保存"),
                    ),
                    const PopupMenuItem(
                      value: HerodetailAction.upload,
                      child: Text("上传"),
                    ),
                    const PopupMenuItem(
                      value: HerodetailAction.webBuild,
                      child: Text("网上配置"),
                    ),
                  ]),
        if (kIsWeb)
          PopupMenuButton(
              onSelected: (HerodetailAction value) async {
                switch (value) {
                  case HerodetailAction.save:
                    await save(ref);
                    Utils.showToast("收藏完成");
                    break;
                  case HerodetailAction.webBuild:
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            LocalBuildsPage(heroTag: family.personTag),
                      ),
                    );

                    break;
                  default:
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: HerodetailAction.save,
                      child: Text(favKey == null ? "收藏" : "保存"),
                    ),
                    const PopupMenuItem(
                      value: HerodetailAction.webBuild,
                      child: Text("参考配置"),
                    ),
                  ])
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends ConsumerWidget {
  const _Body(
    this.family,
  );

  final PersonBuild family;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var s = ref.watch(heroDetailPageProvider(family));

    return s.when(
      data: (data) => ListView(
        children: ListTile.divideTiles(context: context, tiles: [
          // 头像、性格等，
          AttrTile(family),
          RarityTile(family),
          LevelSwitchTile(family),
          SummonSupportTile(family),
          ResplendentTile(family),
          AscendedAssetTile(family),
          // // 数值显示组件
          StatsTile(family),
          // // 特殊效果组件
          LegendaryTile(family),
          // // 武器炼成组件
          WeaponRefineTile(family),
          SkillTiles(family),
        ]).toList(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class TagChoose extends StatefulWidget {
  const TagChoose({
    Key? key,
    required this.data,
    required this.selected,
  }) : super(key: key);
  final Map<String, String> data;
  final ValueNotifier<List<String>> selected;
  @override
  TagChooseState createState() => TagChooseState();
}

class TagChooseState extends State<TagChoose> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var entry in widget.data.entries)
          ValueListenableBuilder(
            valueListenable: widget.selected,
            builder: (context, selected, child) => FilterChip(
              label: Text(entry.value),
              selected: (selected).contains(entry.key),
              showCheckmark: false,
              selectedColor: Colors.blue.shade200,
              onSelected: (value) {
                setState(() {
                  selected.contains(entry.key)
                      ? selected.remove(entry.key)
                      : selected.add(entry.key);
                });
              },
            ),
          )
      ],
    );
  }
}
