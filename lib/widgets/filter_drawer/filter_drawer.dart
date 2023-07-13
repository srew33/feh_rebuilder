// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:feh_rebuilder/core/enum/game_version.dart';
import 'package:feh_rebuilder/core/enum/move_type.dart';
import 'package:feh_rebuilder/core/enum/series.dart';
import 'package:feh_rebuilder/core/enum/weapon_type.dart';
import 'package:feh_rebuilder/core/filters/person.dart';
import 'package:feh_rebuilder/models/weapon_type/weapon_type.dart';
import 'package:feh_rebuilder/repositories/repo_provider.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';

import 'controller.dart';

class FilterDraw extends ConsumerStatefulWidget {
  const FilterDraw({
    super.key,
    required this.id,
    this.onComfirmed,
    this.showRecent = true,
  });

  /// 当前[FilterDraw]的唯一标识，也可以用key，考虑到方便控制，这里用int
  final int id;

  final bool showRecent;

  /// 点击确定时的操作
  final void Function(Set filters)? onComfirmed;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FilterDrawState();
}

class _FilterDrawState extends ConsumerState<FilterDraw> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WeaponType>>(
      future: () async {
        List<WeaponType> weaponTypes =
            (await ref.read(repoProvider).requireValue.weapon.getAll())
                .values
                .toList();

        weaponTypes.sort((a, b) => a.sortId.compareTo(b.sortId));
        return weaponTypes;
      }(),
      builder: (context, snapshot) => !snapshot.hasData
          ? const SizedBox.shrink()
          : Drawer(
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
                                .headlineSmall!
                                .merge(const TextStyle(color: Colors.white)),
                          ),
                          tileColor:
                              Theme.of(context).primaryColor.withAlpha(200),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 移动类型chip
                                for (int i = 0; i < 4; i++)
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: _TagChip(
                                      label: UniImage(
                                        path: p
                                            .join("assets", "move", "$i.webp")
                                            .replaceAll(r"\", "/"),
                                        height: 40,
                                      ),
                                      filterType: MoveTypeEnum.values[i],
                                      id: widget.id,
                                    ),
                                  ),
                              ],
                            ),
                            // 武器类型chip
                            for (int i = 0; i < 6; i++)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int j = 0; j < 4; j++)
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: _TagChip(
                                        label: UniImage(
                                          path: p
                                              .join("assets", "weapon",
                                                  "${snapshot.data![i * 4 + j].index}.webp")
                                              .replaceAll(r"\", "/"),
                                          height: 40,
                                        ),
                                        filterType: WeaponTypeEnum.values[
                                            snapshot.data![i * 4 + j].index],
                                        id: widget.id,
                                      ),
                                    ),
                                ],
                              ),

                            if (widget.showRecent)
                              _CheckChip(
                                label: "最新",
                                filterType: PersonFilterEnum.recentlyUpdated,
                                id: widget.id,
                              ),
                            if (widget.showRecent)
                              _CheckChip(
                                label: "圣杯",
                                filterType: PersonFilterEnum.redeemable,
                                id: widget.id,
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
                                      _TagChip(
                                        label: const Text("神装"),
                                        filterType:
                                            PersonTypeEnum.isResplendent,
                                        id: widget.id,
                                      ),
                                      _TagChip(
                                        label: const Text("舞娘"),
                                        filterType: PersonTypeEnum.isRefersher,
                                        id: widget.id,
                                      ),
                                      _TagChip(
                                        label: const Text("比翼"),
                                        filterType: PersonTypeEnum.isDuo,
                                        id: widget.id,
                                      ),
                                      _TagChip(
                                        label: const Text("双界"),
                                        filterType: PersonTypeEnum.isHarmonic,
                                        id: widget.id,
                                      ),
                                      _TagChip(
                                        label: const Text("神阶"),
                                        filterType: PersonTypeEnum.isMythic,
                                        id: widget.id,
                                      ),
                                      _TagChip(
                                        label: const Text("传承"),
                                        filterType: PersonTypeEnum.isLegend,
                                        id: widget.id,
                                      ),
                                      _TagChip(
                                        label: const Text("开花"),
                                        filterType: PersonTypeEnum.isAscendant,
                                        id: widget.id,
                                      ),
                                      _TagChip(
                                        label: const Text("魔器"),
                                        filterType: PersonTypeEnum.isRearmed,
                                        id: widget.id,
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
                                        Tooltip(
                                          preferBelow: false,
                                          message: SeriesEnum.values[i].name,
                                          child: _TagChip(
                                            label: UniImage(
                                              path: p
                                                  .join("assets", "series",
                                                      "$i.webp")
                                                  .replaceAll(r"\", "/"),
                                              height: 25,
                                            ),
                                            filterType: SeriesEnum.values[i],
                                            id: widget.id,
                                          ),
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
                                        _TagChip(
                                          label: Text("${i + 1}"),
                                          filterType: GameVersionEnum.values[i],
                                          id: widget.id,
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
                            ref.read(fProvider(widget.id).notifier).clear();
                          },
                          child: const Text("清除")),
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            ref.read(fProvider(widget.id).notifier).confirm();

                            widget.onComfirmed
                                ?.call(ref.read(fProvider(widget.id)).filters);

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

class _CheckChip extends ConsumerWidget {
  const _CheckChip({
    required this.label,
    required this.filterType,
    required this.id,
  });
  final String label;
  final dynamic filterType;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool selected = ref.watch(fProvider(id).select((value) =>
        value.cacheFilters.contains(filterType) ||
        value.filters.contains(filterType)));

    return CheckboxListTile(
      title: Text(label),
      value: selected,
      // activeColor: Colors.blue.shade200,
      onChanged: (newVal) =>
          ref.read(fProvider(id).notifier).change(newVal ?? false, filterType),
    );
  }
}

class _TagChip extends ConsumerWidget {
  const _TagChip({
    required this.label,
    required this.filterType,
    required this.id,
  });
  final Widget label;
  final dynamic filterType;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool selected = ref.watch(fProvider(id).select((value) =>
        value.cacheFilters.contains(filterType) ||
        value.filters.contains(filterType)));

    return FilterChip(
      label: label,
      padding: const EdgeInsets.all(2),
      selected: selected,
      selectedColor: Colors.blue.shade200,
      // backgroundColor: Colors.black12,
      showCheckmark: false,
      onSelected: (newVal) =>
          ref.read(fProvider(id).notifier).change(newVal, filterType),
    );
  }
}
