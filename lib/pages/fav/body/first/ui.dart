// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/pages/hero_detail/model.dart';
import 'package:feh_rebuilder/pages/hero_detail/ui.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:path/path.dart' as p;

import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/fav/body/second/controller.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';

import 'controller.dart';
import 'favfixedbar.dart';
import 'model.dart';

class FavFirst extends ConsumerStatefulWidget {
  const FavFirst({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FavFirstState();
}

class _FavFirstState extends ConsumerState<FavFirst>
    with AutomaticKeepAliveClientMixin {
  final SwipeActionController swipeActionController = SwipeActionController();
  @override
  Widget build(BuildContext context) {
    super.build(context);
// 会重复构建
    var data = ref.watch(favFirstProvider.select((value) => value.filtered));

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => swipeActionController.closeAllOpenCell(),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => Consumer(
                builder: (context, ref, child) {
                  return SwipeActionCell(
                    key: UniqueKey(),
                    index: index,
                    controller: swipeActionController,
                    trailingActions: <SwipeAction>[
                      SwipeAction(
                        nestedAction: SwipeNestedAction(title: "确认删除"),
                        title: "删除",
                        onTap: (CompletionHandler handler) async {
                          await handler(true);
                          await ref
                              .read(favFirstProvider.notifier)
                              .delete({index});
                        },
                        color: Colors.red,
                      ),
                      SwipeAction(
                          title: "编辑",
                          onTap: (CompletionHandler handler) async {
                            handler(false);
                            var initial = await HerodetailState.initial(
                                data[index].build,
                                ref.read(repoProvider).requireValue);

                            if (context.mounted) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HeroDetailPage(
                                    initialState: initial,
                                    favKey: data[index].build.key,
                                  ),
                                ),
                              );
                            }
                          },
                          color: Colors.blue),
                    ],
                    child: _FavTile(
                      index: index,
                      model: data[index],
                      // ref.read(favFirstProvider.notifier).select(true, index),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(
          height: 70,
          child: Consumer(
            builder: (context, ref, child) {
              var s = ref.watch(favFirstIsGroupingProvider);
              if (s) {
                return FavFixedBar2(
                  onSave: (key, team) =>
                      ref.read(favSecondProvider.notifier).save(team, key),
                );
              } else {
                return FavFixedBar1(
                  swipeActionController: swipeActionController,
                  onDel: (selected) async {
                    await ref.read(favFirstProvider.notifier).delete(selected);
                    swipeActionController.deselectAll();
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _FavTile extends ConsumerWidget {
  const _FavTile({
    Key? key,
    required this.index,
    required this.model,
  }) : super(key: key);
  final int index;
  final PersonBuildVM model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () {
        var groupMode = ref.read(favFirstIsGroupingProvider);
        if (groupMode) {
          ref.read(favFixedBar2Provider.notifier).setElement(null, model);
        }
      },
      leading: ClipOval(
        child: UniImage(
            path: p
                .join("assets", "faces", "${model.hero.faceName ?? ""}.webp")
                .replaceAll(r"\", "/"),
            height: 50),
      ),
      title: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(17))),
            child: Center(
              child: Text(
                "+${model.build.merged}",
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(17))),
            child: Center(
              child: Text(
                "+${model.build.dragonflowers}",
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Text("M${model.hero.idTag}".tr),
                  ],
                ),
                Row(
                  children: [
                    model.build.advantage == null &&
                            model.build.disAdvantage == null
                        ? Text("CUSTOM_STATS_NULL".tr)
                        : Text("+%s-%s".fill([
                            "CUSTOM_STATS_${(model.build.advantage ?? "NULL").toUpperCase()}"
                                .tr,
                            "CUSTOM_STATS_${(model.build.disAdvantage ?? "NULL").toUpperCase()}"
                                .tr
                          ])),
                    const Spacer(),
                  ],
                )
              ],
            ),
          ),
          // arenaScore是个人分，这里计算团队分
          Text("预计档位: ${(150 + model.arenaScore).floor() * 2}"),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_back_ios_new,
            size: 10,
            color: Colors.black45,
          ),
          const SizedBox(
            width: 4,
          )
        ],
      ),
    );
  }
}
