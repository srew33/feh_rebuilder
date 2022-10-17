import 'package:feh_rebuilder/core/enum/game_version.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/series.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filters/person.dart';
import 'package:feh_rebuilder/home_screens/home/bloc/home_bloc.dart';
import 'package:feh_rebuilder/models/weapon_type/weapon_type.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class FilterDraw extends StatelessWidget {
  const FilterDraw({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<WeaponType> weaponTypes =
        context.read<Repository>().cacheWeaponTypes.values.toList();
    weaponTypes.sort(
      (a, b) => a.sortId.compareTo(b.sortId),
    );
    return SizedBox(
      width: 276,
      child: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: ScrollController(),
                children: [
                  ListTile(
                    title: Text(
                      "角色过滤",
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .merge(const TextStyle(color: Colors.white)),
                    ),
                    tileColor: Colors.blue,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 移动类型chip
                          for (int i = 0; i < 4; i++)
                            BlocSelector<HomeBloc, HomeState, bool>(
                              selector: (state) {
                                return state.cacheFilters
                                    .contains(MoveTypeEnum.values[i]);
                              },
                              builder: (context, selected) {
                                return ChoiceChip(
                                  visualDensity: VisualDensity.comfortable,
                                  label: UniImage(
                                    // // windows平台下join会使用\导致错误，要替换为/
                                    path: p
                                        .join("assets", "move", "$i.webp")
                                        .replaceAll(r"\", "/"),
                                    height: 45,
                                  ),
                                  selected: selected,
                                  selectedColor: Colors.blue,
                                  backgroundColor: Colors.transparent,
                                  elevation: 5,
                                  labelPadding:
                                      const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                  shape: const RoundedRectangleBorder(),
                                  onSelected: (bool val) {
                                    context.read<HomeBloc>().add(
                                        HomeFilterChanged(
                                            operation: val,
                                            filterType:
                                                MoveTypeEnum.values[i]));
                                  },
                                );
                              },
                            )
                        ],
                      ),
                      // 武器类型chip
                      for (int i = 0; i < 6; i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int j = 0; j < 4; j++)
                              BlocSelector<HomeBloc, HomeState, bool>(
                                selector: (state) {
                                  return state.cacheFilters.contains(
                                      WeaponTypeEnum.values[
                                          weaponTypes[i * 4 + j].index]);
                                },
                                builder: (context, selected) {
                                  return ChoiceChip(
                                    label: UniImage(
                                      path: p
                                          .join("assets", "weapon",
                                              "${weaponTypes[4 * i + j].index}.webp")
                                          .replaceAll(r"\", "/"),
                                      height: 45,
                                    ),
                                    selected: selected,
                                    selectedColor: Colors.blue,
                                    backgroundColor: Colors.transparent,
                                    labelPadding:
                                        const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                    elevation: 5,
                                    shape: const RoundedRectangleBorder(),
                                    // showCheckmark: false,
                                    onSelected: (bool val) {
                                      context
                                          .read<HomeBloc>()
                                          .add(HomeFilterChanged(
                                            operation: val,
                                            filterType: WeaponTypeEnum.values[
                                                weaponTypes[i * 4 + j].index],
                                          ));
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      BlocSelector<HomeBloc, HomeState, bool>(
                        selector: (state) {
                          return state.cacheFilters
                              .contains(PersonFilterType.recentlyUpdated);
                        },
                        builder: (context, selected) {
                          return CheckboxListTile(
                            title: const Text("最新"),
                            value: selected,
                            onChanged: (newVal) {
                              context.read<HomeBloc>().add(HomeFilterChanged(
                                    operation: newVal ?? false,
                                    filterType:
                                        PersonFilterType.recentlyUpdated,
                                  ));
                            },
                          );
                        },
                      ),
                      ExpansionTile(
                        title: const Text("更多"),
                        children: [
                          const ListTile(
                            title: Text("类型"),
                          ),
                          ListTile(
                            title: Wrap(
                              runSpacing: 10,
                              spacing: 6,
                              children: [
                                BlocSelector<HomeBloc, HomeState, bool>(
                                  selector: (state) {
                                    return state.cacheFilters.contains(
                                        PersonFilterType.isResplendent);
                                  },
                                  builder: (context, selected) {
                                    return ChoiceChip(
                                      label: const Text("神装"),
                                      selected: selected,
                                      onSelected: (bool val) {
                                        context
                                            .read<HomeBloc>()
                                            .add(HomeFilterChanged(
                                              operation: val,
                                              filterType: PersonFilterType
                                                  .isResplendent,
                                            ));
                                      },
                                    );
                                  },
                                ),
                                BlocSelector<HomeBloc, HomeState, bool>(
                                  selector: (state) {
                                    return state.cacheFilters
                                        .contains(PersonFilterType.isRefersher);
                                  },
                                  builder: (context, selected) {
                                    return ChoiceChip(
                                      label: const Text("舞娘"),
                                      selected: selected,
                                      onSelected: (bool val) {
                                        context
                                            .read<HomeBloc>()
                                            .add(HomeFilterChanged(
                                              operation: val,
                                              filterType:
                                                  PersonFilterType.isRefersher,
                                            ));
                                      },
                                    );
                                  },
                                ),
                                BlocSelector<HomeBloc, HomeState, bool>(
                                  selector: (state) {
                                    return state.cacheFilters
                                        .contains(PersonFilterType.isDuo);
                                  },
                                  builder: (context, selected) {
                                    return ChoiceChip(
                                      label: const Text("比翼"),
                                      selected: selected,
                                      onSelected: (bool val) {
                                        context
                                            .read<HomeBloc>()
                                            .add(HomeFilterChanged(
                                              operation: val,
                                              filterType:
                                                  PersonFilterType.isDuo,
                                            ));
                                      },
                                    );
                                  },
                                ),
                                BlocSelector<HomeBloc, HomeState, bool>(
                                  selector: (state) {
                                    return state.cacheFilters
                                        .contains(PersonFilterType.isHarmonic);
                                  },
                                  builder: (context, selected) {
                                    return ChoiceChip(
                                      label: const Text("双界"),
                                      selected: selected,
                                      onSelected: (bool val) {
                                        context
                                            .read<HomeBloc>()
                                            .add(HomeFilterChanged(
                                              operation: val,
                                              filterType:
                                                  PersonFilterType.isHarmonic,
                                            ));
                                      },
                                    );
                                  },
                                ),
                                BlocSelector<HomeBloc, HomeState, bool>(
                                  selector: (state) {
                                    return state.cacheFilters
                                        .contains(PersonFilterType.isMythic);
                                  },
                                  builder: (context, selected) {
                                    return ChoiceChip(
                                      label: const Text("神阶"),
                                      selected: selected,
                                      onSelected: (bool val) {
                                        context
                                            .read<HomeBloc>()
                                            .add(HomeFilterChanged(
                                              operation: val,
                                              filterType:
                                                  PersonFilterType.isMythic,
                                            ));
                                      },
                                    );
                                  },
                                ),
                                BlocSelector<HomeBloc, HomeState, bool>(
                                  selector: (state) {
                                    return state.cacheFilters
                                        .contains(PersonFilterType.isLegend);
                                  },
                                  builder: (context, selected) {
                                    return ChoiceChip(
                                      label: const Text("传承"),
                                      selected: selected,
                                      onSelected: (bool val) {
                                        context
                                            .read<HomeBloc>()
                                            .add(HomeFilterChanged(
                                              operation: val,
                                              filterType:
                                                  PersonFilterType.isLegend,
                                            ));
                                      },
                                    );
                                  },
                                ),
                                BlocSelector<HomeBloc, HomeState, bool>(
                                  selector: (state) {
                                    return state.cacheFilters
                                        .contains(PersonFilterType.isAscendant);
                                  },
                                  builder: (context, selected) {
                                    return ChoiceChip(
                                      label: const Text("开花"),
                                      selected: selected,
                                      onSelected: (bool val) {
                                        context
                                            .read<HomeBloc>()
                                            .add(HomeFilterChanged(
                                              operation: val,
                                              filterType:
                                                  PersonFilterType.isAscendant,
                                            ));
                                      },
                                    );
                                  },
                                ),
                                BlocSelector<HomeBloc, HomeState, bool>(
                                  selector: (state) {
                                    return state.cacheFilters
                                        .contains(PersonFilterType.isAscendant);
                                  },
                                  builder: (context, selected) {
                                    return ChoiceChip(
                                      label: const Text("魔器"),
                                      selected: selected,
                                      onSelected: (bool val) {
                                        context
                                            .read<HomeBloc>()
                                            .add(HomeFilterChanged(
                                              operation: val,
                                              filterType:
                                                  PersonFilterType.isRearmed,
                                            ));
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const ListTile(
                            title: Text("出处"),
                          ),
                          ListTile(
                            title: Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                for (int i = 0;
                                    i < SeriesEnum.values.length;
                                    i++)
                                  BlocSelector<HomeBloc, HomeState, bool>(
                                    selector: (state) {
                                      return state.cacheFilters
                                          .contains(SeriesEnum.values[i]);
                                    },
                                    builder: (context, selected) {
                                      return Tooltip(
                                        preferBelow: false,
                                        message: SeriesEnum.values[i].name,
                                        child: ChoiceChip(
                                          label: UniImage(
                                            path: p
                                                .join("assets", "series",
                                                    "$i.webp")
                                                .replaceAll(r"\", "/"),
                                            height: 25,
                                          ),
                                          selected: selected,
                                          onSelected: (bool val) {
                                            context
                                                .read<HomeBloc>()
                                                .add(HomeFilterChanged(
                                                  operation: val,
                                                  filterType:
                                                      SeriesEnum.values[i],
                                                ));
                                          },
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const ListTile(
                            title: Text("登场"),
                          ),
                          ListTile(
                            title: Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                for (int i = 0;
                                    i < GameVersionEnum.values.length;
                                    i++)
                                  BlocSelector<HomeBloc, HomeState, bool>(
                                    selector: (state) {
                                      return state.cacheFilters
                                          .contains(GameVersionEnum.values[i]);
                                    },
                                    builder: (context, selected) {
                                      return ChoiceChip(
                                        label: Text("${i + 1}"),
                                        selected: selected,
                                        onSelected: (bool val) {
                                          context
                                              .read<HomeBloc>()
                                              .add(HomeFilterChanged(
                                                operation: val,
                                                filterType:
                                                    GameVersionEnum.values[i],
                                              ));
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          // todo 也许以后版本完成
                          // ListTile(
                          //   title: Text("数值大于"),
                          // ),
                          // ListTile(title: Text("HP"), dense: true),
                          // ListTile(title: Text("HP"), dense: true),
                          // ListTile(title: Text("HP"), dense: true),
                          // ListTile(title: Text("HP"), dense: true),
                          // ListTile(title: Text("HP"), dense: true),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              children: [
                const Spacer(),
                TextButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(HomeFilterCleared());
                    },
                    child: const Text("清除")),
                const Spacer(),
                TextButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(HomeFilterConfirmed());
                      // context.read<HomeBloc>().add(HomeDrawerClosed());
                      Navigator.of(context).pop();
                    },
                    child: const Text("确定")),
                const Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
