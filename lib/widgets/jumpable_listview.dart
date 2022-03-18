import 'package:flutter/material.dart';

class JumpListScrollController {
  _JumpableListViewState? _state;

  void jumpToNext() {
    _state!.jumpToNext();
  }

  void jumpToprevious() {
    _state!.jumpToprevious();
  }

  void jumpToGroup(int index) {
    _state!.jumpToGroup(index);
  }

  void setData(Map<String, List> newData) {
    _state!.setData(newData);
  }

  void _attach(_JumpableListViewState state) {
    assert(_state == null);
    _state = state;
  }

  void _detach() {
    _state = null;
  }
}

typedef ItemBuilder<T> = Widget Function(BuildContext, T);

class JumpableListView<T> extends StatefulWidget {
  const JumpableListView({
    Key? key,
    this.scrollController,
    required this.groupData,
    required this.itemBuilder,
    required this.itemExtent,
  }) : super(key: key);

  final Map<String, List<T>> groupData;
  final ItemBuilder<T> itemBuilder;
  final double itemExtent;
  final JumpListScrollController? scrollController;

  @override
  _JumpableListViewState<T> createState() => _JumpableListViewState<T>();
}

class _JumpableListViewState<T> extends State<JumpableListView<T>> {
  int currentGroupIndex = 0;
  final List _data = [];
  List<double> _groupesSector = [0];
  final ScrollController _scrollController = ScrollController();
  final List<String> _headers = [];
  final GlobalKey<_IndexBarState> _indexBar = GlobalKey<_IndexBarState>();
  late double offsetLimit;
  late Map<String, List<T>> _groupData;

  void _refreshGroupesData() {
    _groupesSector = [0];
    _headers.clear();
    _data.clear();
    _groupData.forEach((key, value) {
      _groupesSector
          .add(_groupesSector.last + widget.itemExtent * (value.length + 1));
      _data.add(key);
      _data.addAll(value);
      _headers.add(key);
    });
    offsetLimit = _groupesSector.last;

    // newGroupIndex = 0;

    if (_scrollController.hasClients) {
      for (var i = 0; i < _groupesSector.length; i++) {
        if (_groupesSector[i] >= _scrollController.offset) {
          newGroupIndex = i - 1;
          break;
        }
      }
    } else {
      newGroupIndex = 0;
    }
    // newGroupIndex = index;
  }

  void setData(Map<String, List<T>> groupData) {
    setState(() {
      _groupData = groupData;
      _refreshGroupesData();
    });
  }

  set newGroupIndex(int newIndex) {
    if (currentGroupIndex != newIndex) {
      currentGroupIndex = newIndex;
      _indexBar.currentState!.currentIndex.value = newIndex;
    }
  }

  void jumpToIndex(int index) {
    _scrollController.jumpTo(index * widget.itemExtent);
  }

  void jumpToGroup(int index) {
    _groupesSector[index] + context.size!.height < offsetLimit
        ? _scrollController.jumpTo(_groupesSector[index])
        : _scrollController.jumpTo(offsetLimit - context.size!.height);
    newGroupIndex = index;
  }

  void jumpToNext() {
    if (currentGroupIndex + 1 < _groupesSector.length - 1) {
      _groupesSector[currentGroupIndex] + context.size!.height < offsetLimit
          ? _scrollController.jumpTo(_groupesSector[currentGroupIndex + 1])
          : _scrollController.jumpTo(offsetLimit - context.size!.height);
    }

    if (currentGroupIndex < _groupesSector.length - 2) {
      currentGroupIndex++;
    }
  }

  void jumpToprevious() {
    if (currentGroupIndex > 0) {
      _scrollController.jumpTo(_groupesSector[currentGroupIndex - 1]);
    } else {
      _scrollController.jumpTo(0);
    }
    if (currentGroupIndex > 0) {
      currentGroupIndex--;
    }
  }

  void listenScroll() {
    int index = _groupesSector
        .indexWhere((sectorPos) => _scrollController.offset < sectorPos);

    if (index > 1) {
      newGroupIndex = index - 1;
    } else {
      newGroupIndex = 0;
    }
  }

  @override
  void initState() {
    widget.scrollController?._attach(this);
    _groupData = widget.groupData;
    _refreshGroupesData();

    _scrollController.addListener(listenScroll);

    super.initState();
  }

  @override
  void deactivate() {
    _scrollController.removeListener(listenScroll);
    widget.scrollController?._detach();

    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.removeListener(listenScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _groupData.isEmpty
        ? const SizedBox.shrink()
        : Stack(
            children: [
              // ?
              // Scrollbar(
              //   child:
              CustomScrollView(
                slivers: [
                  SliverFixedExtentList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _data[index] is String
                          ? Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                // todo 根据光暗选择颜色
                                color: Colors.grey.shade300,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      _data[index],
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ),
                            )
                          : widget.itemBuilder.call(context, _data[index]),
                      childCount: _data.length,
                    ),
                    itemExtent: 80,
                  )
                ],
                controller: _scrollController,
              ),

              // 右侧滑动条
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _groupData.isNotEmpty
                      ? FittedBox(
                          child: Column(
                            children: [
                              IndexBar(
                                key: _indexBar,
                                items: _headers,
                                onTapDown: (int newGroupIndex) =>
                                    jumpToGroup(newGroupIndex),
                                onScrollTo: (int newGroupIndex) =>
                                    jumpToGroup(newGroupIndex),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              )
            ],
          );
  }
}

// 自定义类似微信联系人右侧带index的列表
typedef ScrollTo = Function(int index);
typedef TapDown = Function(int index);

class IndexBar extends StatefulWidget {
  final List<String> items;
  final ScrollTo? onScrollTo;
  final TapDown? onTapDown;

  const IndexBar({
    Key? key,
    required this.items,
    this.onScrollTo,
    this.onTapDown,
  }) : super(key: key);

  @override
  _IndexBarState createState() => _IndexBarState();
}

class _IndexBarState extends State<IndexBar> {
  double barHeight = 0;
  double position = 0;

  final ValueNotifier<int> currentIndex = ValueNotifier<int>(0);

  double singleHeight = 0;
  List<String> _items = [];

  @override
  void initState() {
    _items = widget.items;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.items.isNotEmpty
        ? FittedBox(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (TapDownDetails detail) {
                barHeight = context.size!.height;
                singleHeight = barHeight / widget.items.length;
                currentIndex.value =
                    (detail.localPosition.dy / singleHeight).truncate();

                widget.onTapDown?.call(currentIndex.value);
              },
              onPanStart: (DragStartDetails start) {
                position = start.localPosition.dy;
              },
              onPanUpdate: (DragUpdateDetails detail) {
                position += detail.delta.dy;
                if (position >= 0 && position < barHeight) {
                  if (currentIndex.value !=
                      (detail.localPosition.dy / singleHeight).truncate()) {
                    currentIndex.value =
                        (detail.localPosition.dy / singleHeight).truncate();
                    widget.onScrollTo?.call(currentIndex.value);
                  }
                }
              },
              child: SizedBox(
                width: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _items.length; i++)
                      //  currentIndex变化时会导致其他所有对象重建，
                      ValueListenableBuilder<int>(
                        valueListenable: currentIndex,
                        builder: (context, value, child) => Text(
                          _items[i],
                          style: TextStyle(
                            color: value == i ? Colors.blue : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
