// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/build_share/ui.dart';
import 'package:feh_rebuilder/pages/fav/body/first/controller.dart';
import 'package:feh_rebuilder/pages/hero_detail/controller.dart';
import 'package:feh_rebuilder/pages/hero_detail/widgets/attr_tile.dart';
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
  const HeroDetailPage({required this.initialState, this.favKey, super.key});

  /// 初始化的build
  final HerodetailState initialState;

  final String? favKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
        heroDetailPageProvider(initialState).select((value) => value.status));
    if (status == PageStatus.initial) {
      return Scaffold(
        appBar: AppBar(),
      );
    }

    return Scaffold(
      appBar: _AppBar(
        initialState,
        favKey,
      ),
      body: _Body(
        initialState,
      ),
    );
  }
}

class _AppBar extends ConsumerWidget with PreferredSizeWidget {
  const _AppBar(
    this.initialState,
    this.favKey,
  );
  final HerodetailState initialState;

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
              body: TagChoose(
                data: netService.tags,
                selected: selected,
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
            ref.read(heroDetailPageProvider(initialState)).currentBuild;
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
          build: ref.read(heroDetailPageProvider(initialState)).currentBuild,
          key: favKey,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroId = ref.watch(heroDetailPageProvider(initialState)
        .select((value) => value.hero.idTag ?? ""));

    return AppBar(
      title: heroId.isEmpty
          ? null
          : Text(
              """${"MPID_HONOR_${heroId.split("_")[1]}".tr} ${"MPID_${heroId.split("_")[1]}".tr}"""),
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
                    await upload(context, ref);

                    break;
                  case HerodetailAction.webBuild:
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            HeroBuildSharePage(heroTag: heroId),
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
        // todo
        if (kIsWeb)
          IconButton(
              onPressed: () async {
                await save(ref);
              },
              icon: favKey == null
                  ? const Icon(Icons.favorite_border)
                  : const Icon(Icons.save))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends StatelessWidget {
  const _Body(
    this.initialState,
  );

  final HerodetailState initialState;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: ListTile.divideTiles(context: context, tiles: [
        // 头像、性格等，
        AttrTile(initialState),
        RarityTile(initialState),
        LevelSwitchTile(initialState),
        SummonSupportTile(initialState),
        ResplendentTile(initialState),
        AscendedAssetTile(initialState),
        // // 数值显示组件
        StatsTile(initialState),
        // // 特殊效果组件
        LegendaryTile(initialState),
        // // 武器炼成组件
        WeaponRefineTile(initialState),
        SkillTiles(initialState),
      ]).toList(),
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
            builder: (context, selected, child) => ChoiceChip(
              label: Text(entry.value),
              selected: (selected as List<String>).contains(entry.key),
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
