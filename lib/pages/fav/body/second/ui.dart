// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/pages/hero_detail/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:path/path.dart' as p;

import 'package:feh_rebuilder/pages/fav/body/first/favfixedbar.dart';
import 'package:feh_rebuilder/pages/fav/body/first/model.dart';
import 'package:feh_rebuilder/pages/fav/body/second/controller.dart';
import 'package:feh_rebuilder/pages/fav/ui.dart';
import 'package:feh_rebuilder/pages/hero_detail/ui.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';

import '../first/controller.dart';

class FavSecond extends ConsumerStatefulWidget {
  const FavSecond({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FavSecondState();
}

class _FavSecondState extends ConsumerState<FavSecond>
    with AutomaticKeepAliveClientMixin {
  final SwipeActionController swipeActionController = SwipeActionController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var data = ref.watch(favSecondProvider.select((value) => value.filtered));

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            // 事件透传，点击空白区域时可以关闭所有打开的组件
            behavior: HitTestBehavior.opaque,
            onTap: () => swipeActionController.closeAllOpenCell(),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => _Slideable(
                index: index,
                modelKey: data[index].key,
                model: data[index].data,
                tabController: favPageTabController,
                swipeActionController: swipeActionController,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 70,
          child: FavFixedBar3(
            swipeActionController: swipeActionController,
            onDel: (selected) async {
              await ref.read(favSecondProvider.notifier).deleteSome(selected);
              swipeActionController.deselectAll();
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _Slideable extends ConsumerWidget {
  const _Slideable({
    required this.index,
    required this.model,
    required this.tabController,
    required this.modelKey,
    required this.swipeActionController,
  });
  final int index;
  final List<PersonBuildVM?> model;
  final TabController tabController;
  final String modelKey;
  final SwipeActionController swipeActionController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            await ref.read(favSecondProvider.notifier).delete(index);
          },
          color: Colors.red,
        ),
        SwipeAction(
            title: "编辑",
            onTap: (CompletionHandler handler) {
              handler(false);
              var data = ref.read(favSecondProvider).filtered[index];
              ref
                  .read(favFirstIsGroupingProvider.notifier)
                  .update((state) => true);
              ref
                  .read(favFixedBar2Provider.notifier)
                  .setBuilds(data.data, data.key);
              tabController.animateTo(0);
            },
            color: Colors.blue),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _ListTile(
          index: index,
          modelKey: modelKey,
          model: model,
          tabController: favPageTabController,
          swipeActionController: swipeActionController,
        ),
      ),
    );
  }
}

class _ListTile extends ConsumerWidget {
  const _ListTile({
    Key? key,
    required this.index,
    required this.model,
    required this.tabController,
    required this.modelKey,
    required this.swipeActionController,
  }) : super(key: key);
  final int index;
  final List<PersonBuildVM?> model;
  final TabController tabController;
  final String modelKey;
  final SwipeActionController swipeActionController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var score = 0;
    var repo = ref.read(repoProvider).requireValue;
    for (var i = 0; i < 4; i++) {
      if (model[i] == null) {
        score += 0;
      } else {
        score += repo.getArenaScoreByBuild(model[i]!.build);
      }
    }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text("${index + 1}"),
        ),
        for (var i = 0; i < 4; i++)
          model[i] == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25))),
                    child: const Icon(
                      Icons.question_mark,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () async {
                      var initial = await HerodetailState.initial(
                          model[i]!.build, ref.read(repoProvider).requireValue);

                      if (context.mounted) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HeroDetailPage(
                              initialState: initial,
                              favKey: model[i]!.build.key,
                            ),
                          ),
                        );
                      }

                      swipeActionController.closeAllOpenCell();
                    },
                    child: ClipOval(
                      child: UniImage(
                        path: p
                            .join("assets", "faces",
                                "${model[i]!.hero.faceName ?? ""}.webp")
                            .replaceAll(r"\", "/"),
                        height: 50,
                      ),
                    ),
                  ),
                ),
        const Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("预计档位"),
            Text("${score == 0 ? 0 : (150 + score / 4).floor() * 2}"),
          ],
        ),
        const Spacer(),
        const Icon(
          Icons.arrow_back_ios_new,
          size: 10,
          color: Colors.black45,
        ),
        const SizedBox(
          width: 4,
        )
      ],
    );
  }
}
