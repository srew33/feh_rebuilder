// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:path/path.dart' as p;

import 'package:feh_rebuilder/pages/fav/body/second/controller.dart';
import 'package:feh_rebuilder/widgets/uni_image.dart';

import '../second/model.dart';
import 'controller.dart';
import 'model.dart';

class FavFixedBar1 extends ConsumerStatefulWidget {
  const FavFixedBar1({
    super.key,
    required this.swipeActionController,
    this.onDel,
  });
  final SwipeActionController swipeActionController;
  final void Function(Set<int> selected)? onDel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FavFixedBar1State();
}

class _FavFixedBar1State extends ConsumerState<FavFixedBar1> {
  @override
  Widget build(BuildContext context) {
    var data =
        ref.watch(favFirstProvider.selectAsync((value) => value.filtered));

    return FutureBuilder<List<PersonBuildVM?>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }

          var s = snapshot.data!;

          return Card(
            elevation: 0.5,
            child: Row(
              children: [
                Text("总数量：${s.length}"),
                const Spacer(),
                if (!widget.swipeActionController.isEditing.value)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        widget.swipeActionController.toggleEditingMode();
                      });
                    },
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ),
                if (!widget.swipeActionController.isEditing.value)
                  IconButton(
                    onPressed: () {
                      ref
                          .read(favFirstIsGroupingProvider.notifier)
                          .update((state) => true);
                    },
                    icon: const Icon(
                      Icons.group_add,
                      color: Colors.green,
                    ),
                  ),
                if (widget.swipeActionController.isEditing.value)
                  Row(
                    children: [
                      TextButton(
                          onPressed: () => widget.onDel
                              ?.call(widget.swipeActionController.selectedSet),
                          child: const Text(
                            "确定",
                            style: TextStyle(color: Colors.red),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                          onPressed: () => widget.swipeActionController
                              .selectAll(dataLength: s.length),
                          child: const Text(
                            "全选",
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              widget.swipeActionController.toggleEditingMode();
                            });
                          },
                          child: const Text("取消"))
                    ],
                  ),
              ],
            ),
          );
        });
  }
}

class FavFixedBar2 extends ConsumerWidget {
  const FavFixedBar2({
    super.key,
    required this.onSave,
  });

  final Future<void> Function(String? key, List<String?> team) onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.watch(favFixedBar2Provider);

    return Card(
      elevation: 0.5,
      child: Row(
        children: [
          const Spacer(),
          Column(
            children: [
              Row(
                children: [
                  _FavFixedBar2Item(
                    vm: state.builds[0],
                    // onTap: () =>
                    //     ref.read(favFixedBar2Provider.notifier).removeElement(0),
                  ),
                  const SizedBox(width: 8),
                  _FavFixedBar2Item(
                    vm: state.builds[1],
                    // onTap: () =>
                    //     ref.read(favFixedBar2Provider.notifier).removeElement(1),
                  ),
                  const SizedBox(width: 8),
                  _FavFixedBar2Item(
                    vm: state.builds[2],
                    // onTap: () =>
                    //     ref.read(favFixedBar2Provider.notifier).removeElement(2),
                  ),
                  const SizedBox(width: 8),
                  _FavFixedBar2Item(
                    vm: state.builds[3],
                    // onTap: () =>
                    //     ref.read(favFixedBar2Provider.notifier).removeElement(3),
                  ),
                ],
              ),
              Text(
                "预计档位：${state.score}",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                var state = ref.read(favFixedBar2Provider);
                onSave.call(
                    state.key, state.builds.map((e) => e?.build.key).toList());
                ref.read(favFixedBar2Provider.notifier).clear();
              },
              icon: const Icon(Icons.save)),
          state.builds.any(
            (element) => element != null,
          )
              ? IconButton(
                  onPressed: () =>
                      ref.read(favFixedBar2Provider.notifier).popElement(),
                  // onPressed: () => ref.read(favFixedBar2Provider.notifier).clear(),
                  icon: const Icon(Icons.cancel))
              : IconButton(
                  onPressed: () {
                    ref
                        .read(favFirstIsGroupingProvider.notifier)
                        .update((state) => false);

                    ref.read(favFixedBar2Provider.notifier).clear();
                  },
                  icon: const Icon(
                    Icons.undo,
                  ),
                ),
        ],
      ),
    );
  }
}

final favFixedBar2Provider =
    NotifierProvider<FavFixedBar2Notifier, FavFixedBar2State>(
        FavFixedBar2Notifier.new);

class FavFixedBar2Notifier extends Notifier<FavFixedBar2State> {
  @override
  build() {
    return FavFixedBar2State(builds: List.filled(4, null, growable: true));
  }

  void setElement(int? index, PersonBuildVM? vm) {
    if (index == null && !state.builds.any((element) => element == null)) {
      return;
    }

    var n = [...state.builds];
    if (index != null) {
      n[index] = vm;
    } else {
      var i = n.indexWhere((element) => element == null);
      if (i != -1) {
        n[i] = vm;
      }
    }
    state = state.copyWith(builds: n);
  }

  void removeElement(int index) {
    var n = [...state.builds];
    n.removeAt(index);
    n.add(null);
    state = state.copyWith(builds: n);
  }

  void popElement() {
    var n = state.builds.sublist(0, 4);
    var i = n.lastIndexWhere((element) => element != null);
    if (i != -1) {
      n[i] = null;
      if (n.every((element) => element == null)) {
        state = state.copyWith(builds: n, key: null);
      } else {
        state = state.copyWith(builds: n);
      }
    }
  }

  // void removeElement(PersonBuildVM vm) {
  //   var i = state.builds.indexOf(vm);
  //   if (i != -1) {
  //     var n = [...state.builds];
  //     n.removeAt(i);
  //     n[3] = null;
  //     state = state.copyWith(builds: n);
  //   }
  // }

  void setBuilds(List<PersonBuildVM?> builds, String key) {
    state = state.copyWith(builds: builds, key: () => key);
  }

  void clear() {
    state =
        const FavFixedBar2State(builds: [null, null, null, null], key: null);
  }
}

class FavFixedBar2State extends Equatable {
  final List<PersonBuildVM?> builds;

  final String? key;

  const FavFixedBar2State({
    required this.builds,
    this.key,
  });

  int get score {
    int s = 0;
    for (var element in builds.sublist(0, 4)) {
      if (element != null) {
        s += element.arenaScore;
      }
    }

    return s == 0 ? 0 : (150 + s / 4).floor() * 2;
  }

  FavFixedBar2State copyWith(
      {List<PersonBuildVM?>? builds, int? score, String? Function()? key}) {
    return FavFixedBar2State(
      builds: builds ?? this.builds,
      key: key == null ? this.key : key.call(),
    );
  }

  @override
  List<Object?> get props => [builds, key];
}

class _FavFixedBar2Item extends ConsumerWidget {
  const _FavFixedBar2Item({
    this.vm,
    // ignore: unused_element
    this.onTap,
  });

  final PersonBuildVM? vm;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: vm == null
          ? const Icon(
              Icons.question_mark,
            )
          : InkWell(
              onTap: onTap == null ? null : () => onTap?.call(),
              child: ClipOval(
                child: UniImage(
                  path: p
                      .join(
                          "assets", "faces", "${vm?.hero.faceName ?? ""}.webp")
                      .replaceAll(r"\", "/"),
                  height: 40,
                ),
              ),
            ),
    );
  }
}

class FavFixedBar3 extends ConsumerStatefulWidget {
  const FavFixedBar3({
    super.key,
    required this.swipeActionController,
    this.onDel,
  });

  final SwipeActionController swipeActionController;
  final void Function(Set<int>)? onDel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FavFixedBar3State();
}

class _FavFixedBar3State extends ConsumerState<FavFixedBar3> {
  @override
  Widget build(BuildContext context) {
    var data =
        ref.watch(favSecondProvider.selectAsync((value) => value.filtered));

    return FutureBuilder<List<FavSecondItemModel>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }

          var s = snapshot.requireData;

          return Card(
            elevation: 0.5,
            child: Row(
              children: [
                Text("总数量：${s.length}"),
                const Spacer(),
                if (!widget.swipeActionController.isEditing.value)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        widget.swipeActionController.toggleEditingMode();
                      });
                    },
                    icon: const Icon(
                      Icons.remove_circle,
                      color: Colors.red,
                    ),
                  ),
                if (widget.swipeActionController.isEditing.value)
                  Row(
                    children: [
                      TextButton(
                          onPressed: () => widget.onDel
                              ?.call(widget.swipeActionController.selectedSet),
                          child: const Text(
                            "确定",
                            style: TextStyle(color: Colors.red),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                          onPressed: () => widget.swipeActionController
                              .selectAll(dataLength: s.length),
                          child: const Text(
                            "全选",
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              widget.swipeActionController.toggleEditingMode();
                            });
                          },
                          child: const Text("取消"))
                    ],
                  )
              ],
            ),
          );
        });
  }
}

// class FavFixedBar3 extends ConsumerWidget {
//   const FavFixedBar3({
//     super.key,
//     this.onSelectAll,
//     this.onInvert,
//     this.onDelete,
//   });

//   final void Function()? onSelectAll;
//   final void Function()? onInvert;
//   final void Function()? onDelete;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Card(
//       elevation: 0.5,
//       child: Row(
//         children: [
//           IconButton(
//               onPressed: () {
//                 ref
//                     .read(favPageModeProvider.notifier)
//                     .update((state) => FavPageModeEnum.normal);
//                 ref.read(favFirstProvider.notifier).editClear();
//               },
//               icon: const Icon(Icons.undo)),
//           const Spacer(),
//           TextButton(
//             onPressed: () => onSelectAll?.call(),
//             child: const Text("全选"),
//           ),
//           const Spacer(),
//           TextButton(
//             onPressed: () => onInvert?.call(),
//             child: const Text("反选"),
//           ),
//           const Spacer(),
//           TextButton(
//             onPressed: () => onDelete?.call(),
//             child: const Text("删除"),
//           ),
//           const Spacer(),
//         ],
//       ),
//     );
//   }
// }
