// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/pages/fav/body/first/ui.dart';
import 'package:feh_rebuilder/pages/fav/body/second/controller.dart';
import 'package:feh_rebuilder/pages/fav/body/second/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feh_rebuilder/main.dart';

import 'package:feh_rebuilder/widgets/filter_drawer/filter_drawer.dart';

import 'body/first/controller.dart';

late final TabController favPageTabController;

class FavPage extends ConsumerStatefulWidget {
  const FavPage({super.key});

  static Map<String, Widget> tabViews = {
    "角色": const FavFirst(),
    "竞技场": const FavSecond(),
  };

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FavPageState();
}

class _FavPageState extends ConsumerState<FavPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: FavPage.tabViews.length, vsync: this);
    controller.addListener(() {
      if (controller.index != controller.previousIndex) {
        setState(() {});
      }
    });
    favPageTabController = controller;
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(
        controller: controller,
      ),
      endDrawer: controller.index == 0
          ? FilterDraw(
              id: 1,
              showRecent: false,
              onComfirmed: (filters) =>
                  ref.read(favFirstProvider.notifier).confirmFilter(filters),
            )
          : FilterDraw(
              id: 2,
              showRecent: false,
              onComfirmed: (filters) =>
                  ref.read(favSecondProvider.notifier).confirmFilter(filters),
            ),
      // endDrawer: FilterDraw(
      //   id: 1,
      //   showRecent: false,
      //   onComfirmed: (filters) => controller.index == 0
      //       ? ref.read(favFirstProvider.notifier).confirmFilter(filters)
      //       : ref.read(favSecondProvider.notifier).confirmFilter(filters),
      // ),
      body: _Body(
        controller: controller,
      ),
      bottomNavigationBar: const _BottomNavigationBar(),
    );
  }
}

class _AppBar extends StatefulWidget with PreferredSizeWidget {
  const _AppBar({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final TabController controller;

  @override
  State<_AppBar> createState() => _AppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kTextTabBarHeight + kToolbarHeight);
}

class _AppBarState extends State<_AppBar> {
  @override
  void initState() {
    var controller = widget.controller;
    controller.addListener(() {
      if (controller.index != controller.previousIndex) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("收藏"),
      actions: [
        IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            icon: const Icon(Icons.filter_list_alt))
      ],
      bottom: TabBar(
        tabs: FavPage.tabViews.keys
            .map((e) => Tab(
                  text: e,
                ))
            .toList(),
        controller: widget.controller,
      ),
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
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "人物"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "收藏"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "其他"),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.controller,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      controller: controller,
      children: FavPage.tabViews.values.map((f) => f).toList(),
    );
  }
}
