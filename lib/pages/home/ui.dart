import 'package:feh_rebuilder/core/enum/languages.dart';
import 'package:feh_rebuilder/core/enum/sort_key.dart';
import 'package:feh_rebuilder/main.dart';
import 'package:feh_rebuilder/models/person/person.dart';
import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/pages/hero_detail/ui.dart';
import 'package:feh_rebuilder/repositories/config_provider.dart';
import 'package:feh_rebuilder/utils.dart';
import 'package:feh_rebuilder/widgets/filter_drawer/controller.dart';
import 'package:feh_rebuilder/widgets/filter_drawer/filter_drawer.dart';
import 'package:feh_rebuilder/widgets/jumpable_listview.dart';
import 'package:feh_rebuilder/widgets/person_tile.dart';
import 'package:feh_rebuilder/widgets/picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const _AppBar(),
      endDrawer: FilterDraw(
        id: 0,
        onComfirmed: (filters) =>
            ref.read(homeProvider.notifier).confirmFilter(filters),
      ),
      onEndDrawerChanged: (isOpened) {
        // 如果关闭时cacheFilters不为空，表示没有点击确定，这时清空cacheFilters
        if (!isOpened && ref.read(fProvider(0)).cacheFilters.isNotEmpty) {
          ref.read(fProvider(0).notifier).clearCache();
        }
      },
      body: const _Body(),
      bottomNavigationBar: const _BottomNavigationBar(),
    );
  }
}

class _AppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text("人物"),
      actions: [
        IconButton(
            onPressed: () async {
              List<int>? sortKey = await showModalBottomSheet(
                context: context,
                builder: (context1) => Picker(body: [
                  {
                    "minValue": 0,
                    "maxValue": SortKey.values.length - 1,
                    "value": ref.read(homeProvider).sortKey.index,
                    "textMapper": (String key) {
                      return SortKey.values[int.tryParse(key)!].transName.tr;
                    }
                  }
                ]),
              );
              if (sortKey != null) {
                AppLanguages lang = ref.read(configProvider).dataLanguage;
                ref
                    .read(homeProvider.notifier)
                    .sortBy(SortKey.values[sortKey.first], lang);
              }
            },
            icon: const Icon(Icons.sort)),
        Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.filter_list_alt));
        }),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends ConsumerStatefulWidget {
  const _Body();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __BodyState();
}

class __BodyState extends ConsumerState<_Body> {
  @override
  void initState() {
    super.initState();

    Future(() => ref
        .read(homeProvider.notifier)
        .initial(ref.read(configProvider).dataLanguage));
  }

  @override
  Widget build(BuildContext context) {
    bool showVersion = ref.watch(
        homeProvider.select((value) => value.sortKey == SortKey.versionNum));

    return JumpableListView<Person>(
      groupData: const {},
      itemBuilder: (context, person) => PersonTile(
        showVersion: showVersion,
        person: person,
        sum: person.bst.toString(),
        onClick: () async {
          Utils.debug(person.idTag!);

          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HeroDetailPage(
              favKey: null,
              family: PersonBuild(
                personTag: person.idTag!,
                equipSkills: const [],
              ),
            ),
          ));
        },
      ),
      scrollController: ref.read(homeProvider.notifier).controller,
      itemExtent: 80,
    );
  }
}

class _BottomNavigationBar extends ConsumerWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      onTap: (index) =>
          ref.read(homeIndexProvider.notifier).update((state) => state = index),
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "人物"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "收藏"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "其他"),
      ],
    );
  }
}
