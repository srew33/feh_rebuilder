import 'package:feh_rebuilder/home_screens/favourites/bloc/favscreen_bloc.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/hero_detail/page.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:path/path.dart' as p;

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(
        height: 5,
      ),
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocSelector<FavscreenBloc, FavscreenState, int>(
                  selector: (state) {
                    return state.all.length;
                  },
                  builder: (context, count) {
                    return Text("共有$count位角色，请选择4位角色");
                  },
                ),
                BlocBuilder<FavscreenBloc, FavscreenState>(
                  buildWhen: ((previous, current) =>
                      (previous.selected.length == 4) ^
                      (current.selected.length == 4)),
                  builder: (context, state) {
                    double score = 0;

                    if (state.selected.length == 4) {
                      Iterable<FavModel> selectedModels = state.all.where(
                        (element) => state.selected.contains(element.key),
                      );
                      Iterable<int> scores = selectedModels.map((e) => context
                          .read<Repository>()
                          .getArenaScoreByBuild(e.personBuild));
                      score = (scores.reduce(
                            (value, element) => value + element,
                          )) /
                          4;
                    }
                    return Text("已选择角色的竞技场分数为${score.floor()}");
                  },
                )
              ],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 5,
      ),
      Expanded(
          child: BlocSelector<FavscreenBloc, FavscreenState, List<FavModel>>(
        selector: (state) {
          return state.all;
        },
        builder: (context, all) {
          return ListView.builder(
            itemCount: all.length,
            itemBuilder: (context, index) => SwipeActionCell(
              key: UniqueKey(),
              trailingActions: <SwipeAction>[
                SwipeAction(
                  nestedAction: SwipeNestedAction(title: "确认删除"),
                  title: "删除",
                  onTap: (CompletionHandler handler) async {
                    await handler(true);
                    context
                        .read<FavscreenBloc>()
                        .add(FavscreenDeleted(key: all[index].key));
                  },
                  color: Colors.red,
                ),
                SwipeAction(
                    title: "编辑",
                    onTap: (CompletionHandler handler) async {
                      handler(false);
                      FavscreenBloc bloc = context.read<FavscreenBloc>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: ((context) => HeroDetailPage(
                                hero: all[index].hero,
                                initialBuild: all[index].personBuild,
                                favKey: all[index].key,
                                favBloc: bloc,
                              )),
                        ),
                      );
                    },
                    color: Colors.blue),
              ],
              child: _FavTile(index: index, model: all[index]),
            ),
          );
        },
      )),
    ]);
  }
}

// }
class _FavTile extends StatelessWidget {
  const _FavTile({
    Key? key,
    required this.index,
    required this.model,
  }) : super(key: key);
  final int index;
  final FavModel model;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavscreenBloc, FavscreenState>(
      builder: (context, state) {
        return CheckboxListTile(
          value: state.selected.contains(model.key),
          onChanged: (bool? state) {
            if (state ?? false) {
              context
                  .read<FavscreenBloc>()
                  .add(FavscreenSelected(key: model.key, isSelected: true));
            } else {
              context
                  .read<FavscreenBloc>()
                  .add(FavscreenSelected(key: model.key, isSelected: false));
            }
          },
          secondary: ClipOval(
            child: UniImage(
                path: p
                    .join(
                        "assets", "faces", "${model.hero.faceName ?? ""}.webp")
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
                    "+${model.personBuild.merged}",
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
                    "+${model.personBuild.dragonflowers}",
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
                        model.personBuild.advantage == null &&
                                model.personBuild.disAdvantage == null
                            ? Text("CUSTOM_STATS_NULL".tr)
                            : Text("+%s-%s".fill([
                                "CUSTOM_STATS_${(model.personBuild.advantage ?? "NULL").toUpperCase()}"
                                    .tr,
                                "CUSTOM_STATS_${(model.personBuild.disAdvantage ?? "NULL").toUpperCase()}"
                                    .tr
                              ])),
                        const Spacer(),
                        Text(context
                            .read<Repository>()
                            .getArenaScoreByBuild(model.personBuild)
                            .toString())
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
