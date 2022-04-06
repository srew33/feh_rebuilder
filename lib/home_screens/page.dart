import 'package:feh_rebuilder/core/enum/sort_key.dart';
import 'package:feh_rebuilder/home_screens/favourites/bloc/favscreen_bloc.dart';
import 'package:feh_rebuilder/home_screens/favourites/page.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:feh_rebuilder/repositories/config_cubit/config_cubit.dart';
import 'package:feh_rebuilder/repositories/repository.dart';
import 'package:feh_rebuilder/widgets/filter_drawer.dart';
import 'package:feh_rebuilder/widgets/picker.dart';
import 'package:feh_rebuilder/widgets/uni_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/screens_cubit.dart';
import 'home/bloc/home_bloc.dart';
import 'home/page.dart';
import 'others/page.dart';

class Screens extends StatelessWidget {
  const Screens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _AppBar(),
        endDrawer: const FilterDraw(),
        onEndDrawerChanged: (isOpened) {
          if (!isOpened) {
            context.read<HomeBloc>().add(HomeDrawerClosed());
          }
        },
        body: BlocBuilder<ScreensCubit, int>(
          builder: (context, state) {
            return IndexedStack(
              index: state,
              children: const [
                HomePage(),
                FavoritePage(),
                OthersPage(),
              ],
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<ScreensCubit, int>(
          builder: (context, state) {
            return BottomNavigationBar(
              onTap: (index) {
                if (index == 1) {
                  context.read<FavscreenBloc>().add(FavscreenStarted());
                }
                context.read<ScreensCubit>().changeScreen(index);
              },
              currentIndex: state,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "人物"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: "收藏"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: "其他"),
              ],
            );
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
        //     builder: (BuildContext context) => const SkyCastlePage(),
        //   )),
        // ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreensCubit, int>(
      builder: (context, state) {
        if (state == 0) {
          return AppBar(
            title: const Text("人物"),
            actions: [
              IconButton(
                  onPressed: () async {
                    HomeBloc bloc = context.read<HomeBloc>();
                    List<int>? sortKey = await showModalBottomSheet(
                        context: context,
                        builder: (_context) => Picker(body: [
                              {
                                "minValue": 0,
                                "maxValue": SortKey.values.length - 1,
                                "value": bloc.state.sortKey.index,
                                "textMapper": (String key) {
                                  return SortKey
                                      .values[int.tryParse(key)!].transName.tr;
                                }
                              }
                            ]));
                    if (sortKey != null) {
                      bloc.add(HomeSortChanged(SortKey.values[sortKey.first],
                          context.read<ConfigCubit>().state.dataLanguage));
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
        } else if (state == 1) {
          return AppBar(
            title: const Text("收藏"),
            actions: [
              IconButton(
                onPressed: () async {
                  bool confirm = await showDialog(
                        context: context,
                        builder: (context) => UniDialog(
                          title: "清空收藏",
                          body: const Text("你真的要清空收藏吗，此操作不可逆！"),
                          onComfirm: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ) ??
                      false;
                  if (confirm) {
                    await context.read<Repository>().favourites.delFav(null);
                    context.read<FavscreenBloc>().add(FavscreenStarted());
                  }
                },
                icon: const Icon(Icons.delete_forever_outlined),
              )
            ],
          );
        } else if (state == 2) {
          return AppBar(
            title: const Text("其他"),
            actions: const [SizedBox.shrink()],
          );
        }
        throw UnimplementedError();
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
