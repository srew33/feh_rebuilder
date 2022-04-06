import 'package:cloud_db/cloud_db.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/page_state.dart';
import 'package:feh_rebuilder/core/enum/person_type.dart';
import 'package:feh_rebuilder/core/enum/stats.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filters/skill.dart';
import 'package:feh_rebuilder/home_screens/favourites/bloc/favscreen_bloc.dart';
import 'package:feh_rebuilder/models/person/growth_rates.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/models/skill/skill.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/build_share/page.dart';
import 'package:feh_rebuilder/pages/skill_select/page.dart';
import 'package:feh_rebuilder/repositories/api.dart';
import 'package:feh_rebuilder/repositories/config_cubit/config_cubit.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/styles/text_styles.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/picker.dart';
import 'package:feh_rebuilder/widgets/skill_tile.dart';
import 'package:feh_rebuilder/widgets/uni_dialog.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import 'bloc/herodetail_bloc.dart';

class HeroDetailPage extends StatelessWidget {
  const HeroDetailPage({
    Key? key,
    required this.hero,
    required this.initialBuild,
    this.favKey,
    required this.favBloc,
  }) : super(key: key);

  final Person hero;

  final PersonBuild initialBuild;

  final String? favKey;

  final FavscreenBloc favBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HerodetailBloc>(
      create: (context) => HerodetailBloc(
        repo: context.read<Repository>(),
        hero: hero,
        favKey: favKey,
      )..add(
          HerodetailInited(
            initialBuild: initialBuild,
          ),
        ),
      child: const _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
  }) : super(key: key);

  Future handleClick(BuildContext context, HerodetailAction action) async {
    switch (action) {
      case HerodetailAction.save:
        HerodetailBloc bloc = context.read<HerodetailBloc>();

        Repository repo = context.read<Repository>();

        await repo.favourites.putIfAbsent(
            bloc.state.favKey ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            bloc.state.currentBuild.toJson());
        Utils.showToast("成功");
        context.read<FavscreenBloc>().add(FavscreenStarted());

        break;
      case HerodetailAction.share:
        break;
      case HerodetailAction.upload:
        if (!context.read<ConfigCubit>().state.allowGetSysId) {
          Utils.showToast("请先到“其他”页面打开允许获取系统ID开关");
        } else {
          await Cloud().login();
          await context
              .read<API>()
              .reFreshCache(context.read<ConfigCubit>().state.allowGetSysId);
          List<String>? selected = await showDialog(
              context: context,
              builder: (context) {
                GlobalKey<TagChooseState> s = GlobalKey();
                return UniDialog(
                  title: "添加标签",
                  body: TagChoose(
                    key: s,
                    data: context.read<API>().cloudTags,
                  ),
                  onComfirm: () {
                    Navigator.of(context).pop(s.currentState!.selected);
                  },
                );
              });
          if (selected != null) {
            HerodetailState state = context.read<HerodetailBloc>().state;
            PersonBuild _ = PersonBuild(
              personTag: state.hero.idTag!,
              equipSkills: [
                for (Skill? skill in state.equipSkills) skill?.idTag
              ],
              merged: state.merged,
              advantage: state.advantage,
              disAdvantage: state.disAdvantage,
              rarity: 5,
              dragonflowers: state.dragonflowers,
              summonerSupport: state.summonerSupport,
              ascendedAsset: state.ascendedAsset,
              resplendent: state.resplendent,
            );

            var r = await context.read<API>().upload(
                state.hero.idTag!,
                Utils.encodeBuild(
                    _,
                    [
                      for (Skill? s in state.equipSkills.sublist(0, 8))
                        s == null ? 0 : s.idNum!
                    ],
                    state.hero.idNum!),
                selected);

            if (r?.statusCode == 201) {
              Utils.showToast("成功");
            }
          }
        }

        break;
      case HerodetailAction.webBuild:
        if (!context.read<ConfigCubit>().state.allowGetSysId) {
          Utils.showToast("请先到“其他”页面打开允许获取系统ID开关");
        } else {
          Person hero = context.read<HerodetailBloc>().state.hero;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HeroBuildSharePage(
                hero: hero,
              ),
            ),
          );
        }

        break;
      default:
        throw UnimplementedError("未实现的操作");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HerodetailBloc, HerodetailState>(
      buildWhen: (previous, current) => current.status == StateStatus.initial,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
                """${"MPID_HONOR_${state.hero.idTag!.split("_")[1]}".tr} ${"MPID_${state.hero.idTag!.split("_")[1]}".tr}"""),
            actions: [
              if (!kIsWeb)
                PopupMenuButton(
                    onSelected: (value) async {
                      await handleClick(context, value as HerodetailAction);
                    },
                    itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text(state.favKey != null ? "保存" : "收藏"),
                            value: HerodetailAction.save,
                          ),
                          // const PopupMenuItem(
                          //   child: Text("本地分享"),
                          //   value: HerodetailAction.share,
                          // ),
                          const PopupMenuItem(
                            child: Text("上传"),
                            value: HerodetailAction.upload,
                          ),
                          const PopupMenuItem(
                            child: Text("网上配置"),
                            value: HerodetailAction.webBuild,
                          ),
                        ]),
              if (kIsWeb)
                IconButton(
                    onPressed: () async {
                      await handleClick(context, HerodetailAction.save);
                    },
                    icon: state.favKey == null
                        ? const Icon(Icons.favorite_border)
                        : const Icon(Icons.save))
            ],
          ),
          body: BlocBuilder<HerodetailBloc, HerodetailState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              if (state.status != StateStatus.success) {
                return const SizedBox.shrink();
              } else {
                var hero = context.select<HerodetailBloc, Person>(
                    (value) => value.state.hero);
                return ListView(
                  children: ListTile.divideTiles(context: context, tiles: [
                    // 头像、性格等，
                    const _AttrTile(),
                    const _RarityTile(),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("数值"),
                          TextButton(
                              onPressed: () {
                                int targetLevel = context
                                    .read<HerodetailBloc>()
                                    .state
                                    .targetLevel;
                                targetLevel == 40
                                    ? context.read<HerodetailBloc>().add(
                                        const HerodetailPropChanged(
                                            targetLevel: 1))
                                    : context.read<HerodetailBloc>().add(
                                        const HerodetailPropChanged(
                                            targetLevel: 40));
                              },
                              child: const Text("1/40")),
                        ],
                      ),
                      tileColor: Colors.grey.shade200,
                    ),

                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("召唤师的羁绊"),
                          BlocSelector<HerodetailBloc, HerodetailState, bool>(
                            selector: (state) {
                              return state.summonerSupport;
                            },
                            builder: (context, selectedState) {
                              return Switch(
                                value: selectedState,
                                onChanged: (bool newVal) {
                                  context.read<HerodetailBloc>().add(
                                        HerodetailPropChanged(
                                          summonerSupport: newVal,
                                        ),
                                      );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("神装英雄"),
                          BlocSelector<HerodetailBloc, HerodetailState, bool>(
                            selector: (state) {
                              return state.resplendent;
                            },
                            builder: (context, resplendent) {
                              return Switch(
                                value: resplendent,
                                // onChanged: (value) => print(value),
                                onChanged: hero.resplendentHero ?? false
                                    ? (bool newVal) =>
                                        context.read<HerodetailBloc>().add(
                                              HerodetailPropChanged(
                                                resplendent: newVal,
                                              ),
                                            )
                                    : null,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("绽放个性"),
                          BlocBuilder<HerodetailBloc, HerodetailState>(
                            builder: (context, state) {
                              return DropdownButton<String?>(
                                value: state.ascendedAsset?.toUpperCase(),
                                underline: const SizedBox.shrink(),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text("N/A"),
                                  ),
                                  for (var key
                                      in StatsEnum.values.getRange(0, 5))
                                    DropdownMenuItem(
                                      value: key.name,
                                      child:
                                          Text("CUSTOM_STATS_${key.name}".tr),
                                      enabled: key.name !=
                                          state.advantage?.toUpperCase(),
                                    ),
                                ],
                                onChanged: (obj) {
                                  context
                                      .read<HerodetailBloc>()
                                      .add(HerodetailPropChanged(
                                        // 属性值保存时是小写的
                                        ascendedAsset: () => obj?.toLowerCase(),
                                      ));
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // 数值显示组件
                    const _StatsTile(),
                    // 特殊效果组件
                    const _LegendaryTile(),
                    // 武器炼成组件
                    const _WeaponRefineTile(),
                    _SkillTiles(
                      hasLegendEffect:
                          hero.legendary != null && hero.legendary?.kind == 1,
                    ),
                  ]).toList(),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _AttrTile extends StatelessWidget {
  /// 显示属性的tile，包括头像，类型，性格，突破等
  const _AttrTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Person hero =
        context.select<HerodetailBloc, Person>((bloc) => bloc.state.hero);
    return Row(
      children: [
        const Padding(padding: EdgeInsets.only(left: 10)),
        BlocSelector<HerodetailBloc, HerodetailState, bool>(
          selector: (state) {
            return state.resplendent;
          },
          builder: (context, resplendent) {
            return hero.resplendentHero!
                ? IndexedStack(
                    index: resplendent ? 0 : 1,
                    children: [
                      _DescWidget(
                        heroTag: hero.idTag!,
                        resplendent: true,
                        version: hero.versionNum!,
                        type: (hero.minRarity == 0 && hero.maxRarity == 0)
                            ? null
                            : PersonType.values[hero.type],
                        child: ClipOval(
                          child: UniImage(
                              path: p
                                  .join("assets", "faces",
                                      "${hero.faceName ?? ""}EX01.webp")
                                  .replaceAll(r"\", "/"),
                              height: 50),
                        ),
                      ),
                      _DescWidget(
                        heroTag: hero.idTag!,
                        resplendent: false,
                        version: hero.versionNum!,
                        type: (hero.minRarity == 0 && hero.maxRarity == 0)
                            ? null
                            : PersonType.values[hero.type],
                        child: ClipOval(
                          child: UniImage(
                              path: p
                                  .join("assets", "faces",
                                      "${hero.faceName ?? ""}.webp")
                                  .replaceAll(r"\", "/"),
                              height: 50),
                        ),
                      ),
                    ],
                  )
                : _DescWidget(
                    heroTag: hero.idTag!,
                    resplendent: false,
                    version: hero.versionNum!,
                    type: (hero.minRarity == 0 && hero.maxRarity == 0)
                        ? null
                        : PersonType.values[hero.type],
                    child: ClipOval(
                      child: UniImage(
                          path: p
                              .join("assets", "faces",
                                  "${hero.faceName ?? ""}.webp")
                              .replaceAll(r"\", "/"),
                          height: 50),
                    ),
                  );
          },
        ),

        const SizedBox(
          width: 5,
        ),
        // 武器和移动类型
        Column(
          children: [
            UniImage(
                path: p
                    .join("assets", "move", "${hero.moveType ?? ""}.webp")
                    .replaceAll(r"\", "/"),
                height: 25),
            const SizedBox(
              height: 5,
            ),
            UniImage(
                path: p
                    .join("assets", "weapon", "${hero.weaponType ?? ""}.webp")
                    .replaceAll(r"\", "/"),
                height: 25),
          ],
        ),
        BlocSelector<HerodetailBloc, HerodetailState, int>(
          selector: (state) {
            return state.merged;
          },
          builder: (context, merged) {
            return _CircleBtn(
              title: "突破极限",
              text: merged.toString(),
              onPressed: () async {
                List<int?>? _ = await showModalBottomSheet(
                    context: context,
                    builder: (_context) => Picker(
                          title: const Text("突破极限"),
                          body: [
                            {
                              "minValue": 0,
                              "maxValue": 10,
                              "value": merged,
                              "textMapper": (String key) {
                                return key;
                              }
                            }
                          ],
                        ));
                if (_ != null) {
                  context.read<HerodetailBloc>().add(
                        HerodetailPropChanged(merged: _[0]),
                      );
                }
              },
            );
          },
        ),
        const SizedBox(
          width: 5,
        ),
        // 性格按钮
        BlocBuilder<HerodetailBloc, HerodetailState>(
          buildWhen: (previous, current) =>
              previous.advantage != current.advantage ||
              previous.disAdvantage != current.disAdvantage ||
              previous.ascendedAsset != current.ascendedAsset,
          builder: (context, state) {
            return SizedBox(
              width: 110,
              child: TextButton(
                child: state.advantage == null && state.disAdvantage == null
                    ? Text("CUSTOM_STATS_NULL".tr)
                    : Text("+%s-%s".fill([
                        "CUSTOM_STATS_${(state.advantage ?? "NULL").toUpperCase()}"
                            .tr,
                        "CUSTOM_STATS_${(state.disAdvantage ?? "NULL").toUpperCase()}"
                            .tr
                      ])),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                  side: MaterialStateProperty.all(const BorderSide()),
                ),
                onPressed: () async {
                  List<String> statsList = [
                    "N/A",
                    for (var stat in StatsEnum.values.sublist(0, 5))
                      stat.name.toLowerCase()
                  ];
                  List<int?>? _ = await showModalBottomSheet(
                      context: context,
                      builder: (_context) => Picker(
                            nullIndex: 0,
                            title: const Text("优势/劣势"),
                            body: [
                              {
                                "minValue": 0,
                                "maxValue": 5,
                                "value":
                                    statsList.indexOf(state.advantage ?? "N/A"),
                                "textMapper": (String key) {
                                  return int.parse(key) == 0
                                      ? statsList[int.parse(key)]
                                      : "+" +
                                          "CUSTOM_STATS_${statsList[int.parse(key)].toUpperCase()}"
                                              .tr;
                                }
                              },
                              {
                                "minValue": 0,
                                "maxValue": 5,
                                "value": statsList
                                    .indexOf(state.disAdvantage ?? "N/A"),
                                "textMapper": (String key) {
                                  return int.parse(key) == 0
                                      ? statsList[int.parse(key)]
                                      : "-" +
                                          "CUSTOM_STATS_${statsList[int.parse(key)].toUpperCase()}"
                                              .tr;
                                }
                              },
                            ],
                          ));
                  if (_ != null) {
                    if (statsList[_[0]!].toLowerCase() != state.ascendedAsset) {
                      context.read<HerodetailBloc>().add(HerodetailPropChanged(
                            advantage: () =>
                                _[0] == 0 ? null : statsList[_[0]!],
                            disAdvantage: () =>
                                _[1] == 0 ? null : statsList[_[1]!],
                          ));
                    } else {
                      Utils.showToast("开花属性和优势属性不能相同");
                    }
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(
          width: 5,
        ),
        BlocSelector<HerodetailBloc, HerodetailState, int>(
          selector: (state) {
            return state.dragonflowers;
          },
          builder: (context, dragonflowers) {
            return _CircleBtn(
              title: "神龙之花",
              text: dragonflowers.toString(),
              onPressed: () async {
                List<int?>? _ = await showModalBottomSheet(
                    context: context,
                    builder: (_context) => Picker(
                          title: const Text("神龙之花"),
                          body: [
                            {
                              "minValue": 0,
                              "maxValue": hero.dragonflowers!.maxCount!,
                              "value": dragonflowers,
                              "textMapper": (String key) {
                                return key;
                              }
                            }
                          ],
                        ));
                if (_ != null) {
                  context.read<HerodetailBloc>().add(
                        HerodetailPropChanged(dragonflowers: _[0]),
                      );
                }
              },
            );
          },
        ),
      ],
    );
  }
}

class _RarityTile extends StatelessWidget {
  /// 稀有度
  const _RarityTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var hero =
        context.select<HerodetailBloc, Person>((value) => value.state.hero);
    return ListTile(
      tileColor: Colors.grey.shade200,
      title: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("稀有度"),
          Expanded(
            child: BlocSelector<HerodetailBloc, HerodetailState, int>(
              selector: (state) {
                return state.rarity;
              },
              builder: (context, rarity) {
                return Slider(
                  value: rarity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: rarity.toString(),
                  onChanged: (double value) {
                    // print(value);
                  },
                  onChangeEnd: (double value) {
                    context
                        .read<HerodetailBloc>()
                        .add(HerodetailPropChanged(rarity: value.round()));
                  },
                );
              },
            ),
          ),
          hero.minRarity == 0
              ? hero.maxRarity == 0
                  ? const Text("暂未添加")
                  : Tooltip(
                      message: PersonType.values[hero.type].name,
                      child: Row(
                        children: [
                          UniImage(
                              path: p.join("assets", "static",
                                  "Rarity${hero.maxRarity}.png"),
                              height: 20),
                        ],
                      ),
                    )
              : Tooltip(
                  message: PersonType.values[hero.type].name,
                  child: Row(
                    children: [
                      UniImage(
                          path: p.join("assets", "static",
                              "Rarity${hero.minRarity}.png"),
                          height: 20),
                      const Text("--"),
                      UniImage(
                          path: p.join("assets", "static",
                              "Rarity${hero.maxRarity}.png"),
                          height: 20),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  /// 显示属性数值
  const _StatsTile({Key? key}) : super(key: key);

  ///根据属性成长率设定文字颜色
  Color? getPropColor(GrowthRates rates, String statsName) {
    if (Utils.advantageList.contains(rates.toJson()[statsName.toLowerCase()])) {
      return Colors.green.shade800;
    }
    if (Utils.disAdvantageList
        .contains(rates.toJson()[statsName.toLowerCase()])) {
      return Colors.red;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<HerodetailBloc, HerodetailState>(
                builder: (context, state) {
                  return Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "竞技场", style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: state.bst.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ]));
                },
              ),
              FittedBox(
                child: Row(
                  children: [
                    for (var key in StatsEnum.values.getRange(0, 5))
                      SizedBox(
                        width: 40,
                        child: Center(
                            child: Text(
                          "CUSTOM_STATS_${key.name}".tr,
                          style: TextStyle(
                              color: getPropColor(
                                  context
                                      .read<HerodetailBloc>()
                                      .state
                                      .hero
                                      .growthRates!,
                                  key.name)),
                        )),
                      ),
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("基础数值"),
              BlocBuilder<HerodetailBloc, HerodetailState>(
                builder: (context, state) {
                  return FittedBox(
                    child: Row(
                      children: [
                        for (int num in state.baseStats.toJson().values)
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(num.toString()),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("装备数值"),
              BlocBuilder<HerodetailBloc, HerodetailState>(
                builder: (context, state) {
                  return FittedBox(
                    child: Row(
                      children: [
                        for (int num in state.equipStats.toJson().values)
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(num.toString()),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeaponRefineTile extends StatelessWidget {
  /// 显示武器炼成和效果
  const _WeaponRefineTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state =
        context.select<HerodetailBloc, HerodetailState>((value) => value.state);

    return state.hasRefinedWeapon
        ? Column(
            children: [
              ListTile(
                title: const Text("武器炼成"),
                tileColor: Colors.grey.shade200,
              ),
              for (MapEntry<Skill, Skill?> s in state.exclusiveList.entries)
                if (s.key.category! == 0 && s.key.refineId != null)
                  ExpansionTile(title: Text(s.key.nameId!.tr), children: [
                    ListTile(
                        title: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: (s.key.descId!.tr).replaceAll(r"$a", ""),
                        style: Theme.of(context).textTheme.descStyle,
                      ),
                      const TextSpan(text: "\n"),
                      TextSpan(
                        text: ((s.value?.descId! ?? "").tr).replaceAll(r"", ""),
                        style: Theme.of(context).textTheme.descStyle.merge(
                              const TextStyle(color: Colors.green),
                            ),
                      ),
                    ])))
                  ]),
            ],
          )
        : const SizedBox.shrink();
  }
}

class _LegendaryTile extends StatelessWidget {
  /// 显示特殊技能,与人物LEGEND字段有关
  const _LegendaryTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var hero =
        context.select<HerodetailBloc, Person>((value) => value.state.hero);
    return (hero.legendary?.kind ?? 4) != 4
        ? Column(
            children: [
              ListTile(
                title: const Text("常驻效果"),
                tileColor: Colors.grey.shade200,
              ),
              ListTile(
                title: Text(
                  "MPID_LEGEND_${hero.idTag!.split("_")[1]}".tr,
                  style: Theme.of(context).textTheme.descStyle,
                ),
              ),
              if (hero.legendary?.duoSkillId != null)
                ExpansionTile(
                  title: const Text("特殊技能效果"),
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(
                        "MSID_H_${hero.legendary!.duoSkillId!.split("_")[1]}"
                            .tr
                            .replaceAll(r"$a", ""),
                        style: Theme.of(context).textTheme.descStyle,
                      ),
                    )
                  ],
                )
            ],
          )
        : const SizedBox.shrink();
  }
}

class _CircleBtn extends StatelessWidget {
  /// 突破极限和神龙之花使用的按钮
  const _CircleBtn({
    Key? key,
    required this.title,
    required this.text,
    required this.onPressed,
  }) : super(key: key);
  final String title;
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              "+$text",
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10),
        )
      ],
    );
  }
}

class _SkillTiles extends StatelessWidget {
  /// 技能配置的列表项
  const _SkillTiles({
    Key? key,
    required this.hasLegendEffect,
  }) : super(key: key);

  final bool hasLegendEffect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text("技能配置"),
          tileColor: Colors.grey.shade200,
        ),
        for (int index = 0; index < (hasLegendEffect ? 7 : 8); index++)
          BlocBuilder<HerodetailBloc, HerodetailState>(
            builder: (context, state) {
              Skill? s = state.equipSkills[index];

              return s != null
                  ? SkillTile(
                      skill: s,
                      iconHeight: 30,
                      heroHeight: 40,
                      onClick: (String idtag) {
                        FavscreenBloc bloc = context.read<FavscreenBloc>();
                        Person hero =
                            context.read<Repository>().cachePersons[idtag]!;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HeroDetailPage(
                              hero: hero,
                              favBloc: bloc,
                              initialBuild: PersonBuild(
                                personTag: idtag,
                                equipSkills: const [],
                              ),
                            ),
                          ),
                        );
                      },
                      tailBtn: IconButton(
                          onPressed: () {
                            context.read<HerodetailBloc>().add(
                                  HerodetailSkillsChanged(
                                      skill: null, index: index),
                                );
                          },
                          icon: const Icon(Icons.delete)),
                    )
                  : ListTile(
                      title: Row(
                        children: [
                          UniImage(
                              path: p
                                  .join("assets", "skill_placeholder",
                                      "$index.webp")
                                  .replaceAll(r"\", "/"),
                              height: 30),
                        ],
                      ),
                      onTap: () async {
                        var hero = context.read<HerodetailBloc>().state.hero;
                        var newSkill =
                            await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SkillSelectPage(
                            category: index == 7 ? 15 : index,
                            selectMode: true,
                            exclusiveSkills: state.exclusiveList.keys.toList(),
                            filters: const {
                              SkillFilterType.isRegular,
                              SkillFilterType.noEnemyOnly,
                              SkillFilterType.noExclusive
                            },
                            moveTypefilters: {
                              MoveTypeEnum.values[hero.moveType!]
                            },
                            weponTypefilters: {
                              WeaponTypeEnum.values[hero.weaponType!]
                            },
                          ),
                        ));
                        if (newSkill is Skill) {
                          context.read<HerodetailBloc>().add(
                                HerodetailSkillsChanged(
                                    skill: newSkill, index: index),
                              );
                        }
                      },
                    );
            },
          ),
        BlocBuilder<HerodetailBloc, HerodetailState>(
          builder: (context, state) {
            return ListTile(
              title: Row(
                children: [
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "竞技场分数 ", style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: state.arenaScore.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ])),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text.rich(
                      TextSpan(children: <InlineSpan>[
                        const TextSpan(
                            text: "总SP ",
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: state.allSpCost.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}

class TagChoose extends StatefulWidget {
  const TagChoose({
    Key? key,
    required this.data,
  }) : super(key: key);
  final Map<String, String> data;
  @override
  TagChooseState createState() => TagChooseState();
}

class TagChooseState extends State<TagChoose> {
  List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var entry in widget.data.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: selected.contains(entry.key),
            onSelected: (value) {
              setState(() {
                selected.contains(entry.key)
                    ? selected.remove(entry.key)
                    : selected.add(entry.key);
              });
            },
          )
      ],
    );
  }
}

class _DescWidget extends StatefulWidget implements PreferredSizeWidget {
  const _DescWidget({
    Key? key,
    required this.child,
    required this.heroTag,
    required this.resplendent,
    required this.version,
    this.type,
  }) : super(key: key);
  final Widget child;
  final String heroTag;
  final bool resplendent;
  final int version;
  final PersonType? type;
  @override
  State<_DescWidget> createState() => _DescWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DescWidgetState extends State<_DescWidget>
    with TickerProviderStateMixin {
  late AnimationController _aniController;

  late Animation<double> _animation;

  OverlayEntry? overlayEntry;

  late String tagWithoutPrefix;

  void _showOverlay(BuildContext context) {
    overlayEntry = _createOverlayEntry(context);
    _aniController.reset();
    _aniController.forward();
    Overlay.of(context)!.insert(overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Offset offset = itemBox.localToGlobal(
      Offset.zero,
    );

    return OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            _aniController.reverse();
            // overlayEntry.remove();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.transparent,
              ),
              Positioned(
                left: offset.dx + itemBox.size.width / 2 - 6,
                top: offset.dy + itemBox.size.height,
                child: ScaleTransition(
                  scale: _animation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width -
                          offset.dx -
                          itemBox.size.width / 2 +
                          6,
                    ),
                    child: Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MPID_H_$tagWithoutPrefix".tr,
                            ),
                            widget.resplendent
                                ? Text(
                                    "声优：" +
                                        "MPID_VOICE_${tagWithoutPrefix}EX01".tr,
                                  )
                                : Text(
                                    "声优：" + "MPID_VOICE_$tagWithoutPrefix".tr,
                                  ),
                            widget.resplendent
                                ? Text(
                                    "画师：" +
                                        "MPID_ILLUST_${tagWithoutPrefix}EX01"
                                            .tr,
                                  )
                                : Text(
                                    "画师：" + "MPID_ILLUST_$tagWithoutPrefix".tr,
                                  ),
                            Text(
                              "登场版本:${(widget.version / 100).floor()}.${widget.version % 100}",
                            ),
                            if (widget.type != null)
                              Text("获取方式：${widget.type!.name}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _aniController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _aniController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // overlayEntry.remove();
      } else if (status == AnimationStatus.dismissed) {
        overlayEntry?.remove();
      }
    });

    _animation = CurvedAnimation(parent: _aniController, curve: Curves.ease);

    tagWithoutPrefix = widget.heroTag.split("_")[1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 截获返回事件，返回时移除overlayEntry
      onWillPop: () async {
        if (_aniController.isCompleted || (overlayEntry?.mounted ?? false)) {
          overlayEntry?.remove();
        }
        return true;
      },
      child: InkWell(
        onTap: () {
          _showOverlay(context);
        },
        child: widget.child,
      ),
    );
  }
}
