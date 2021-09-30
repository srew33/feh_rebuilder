import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

typedef ElementBuilder<T> = Widget Function(BuildContext, T);
typedef HeaderBuilder<T> = Widget Function(BuildContext, T);

class CustomListView<T> extends StatefulWidget {
  final double? headerHeight;
  final ElementBuilder<T> elementBuilder;
  final HeaderBuilder<String> headerBuilder;

  final Map<String, List<T>> data;

  CustomListView({
    Key? key,
    this.headerHeight,
    required this.data,
    required this.elementBuilder,
    required this.headerBuilder,
  }) : super(key: key);

  @override
  CustomListViewState<T> createState() => CustomListViewState();
}

class CustomListViewState<T> extends State<CustomListView<T>> {
  ///内部实际起作用的数据，由data生成
  List<_Element> _data = [];

  /// 表头列表
  List<String> _header = [];

  ///每组元素数量，主要用来计算每组数据边界
  List<int> _groupItemsCount = [];

  /// 表头起始位置高度，暂时没用
  double headerEdge = 0;

  /// 上一组表头的index
  int previousIndex = 0;

  /// 下一组表头的index
  int nextIndex = 0;

  /// 当前index
  int currentIndex = 0;

  ///当前表头index
  int currentHeaderIndex = 0;

  ///在设置数据后 有可能currentItem == currentIndex 导致表头不刷新，使用这个flag强制刷新
  bool _forceRefresh = false;

  bool showHeader = true;

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  ///用于控制表头显示
  GlobalKey<__HeaderState> _headerKey = GlobalKey<__HeaderState>();

  _initData(Map<String, List<T>> data) {
    previousIndex = 0;
    nextIndex = 0;
    currentIndex = 0;
    currentHeaderIndex = 0;
    _data.clear();
    _groupItemsCount.clear();
    _header.clear();

    data.forEach((key, value) {
      _data.add(_Element<String>(key, _Type.header));
      _header.add(key);
      int i = 0;
      value.forEach((element) {
        i += 1;
        _data.add(_Element(element, _Type.element));
      });
      _groupItemsCount.add(i);
    });

    // currentHeaderIndex = 0;

    nextIndex = _groupItemsCount[0] + 1;
  }

  ///计算当前位置并刷新有关的参数
  void sumPosition(int scrollIndex) {
    int _ = 0;
    for (int i = 0; i < _groupItemsCount.length; i++) {
      if (_ + (_groupItemsCount[i] + 1) > scrollIndex) {
        previousIndex = _;
        nextIndex = _ + (_groupItemsCount[i] + 1);
        currentHeaderIndex = i;
        return;
      } else {
        _ += (_groupItemsCount[i] + 1);
      }
    }

    throw "sumHeaderIndex计算异常";
  }

  void setData(Map<String, List<T>> newData) {
    setState(() {
      _forceRefresh = true;
      _initData(newData);
    });
  }

  void jumpToHeader(String header) {
    int headerIndex = _header.indexOf(header);

    int _ = 0;
    for (int i = 0; i < headerIndex; i++) {
      _ += (_groupItemsCount[i] + 1);
    }
    itemScrollController.jumpTo(index: _);
  }

  @override
  void initState() {
    _initData(widget.data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    itemPositionsListener.itemPositions.addListener(() {
      // itemPositionsListener.itemPositions.value有时会不按顺序来，使用的时候需要
      // 注意顺序，这里判断的代码来自GITHUB
      int currentItem = itemPositionsListener.itemPositions.value
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
              position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
          .index;
      if (currentItem != currentIndex || _forceRefresh) {
        currentIndex = currentItem;

        if (previousIndex >= currentIndex ||
            currentIndex >= nextIndex ||
            _forceRefresh) {
          sumPosition(currentIndex);
          _headerKey.currentState!.setHeader(
              widget.headerBuilder.call(context, _header[currentHeaderIndex]));
        }
        _forceRefresh = false;
      }
    });

    return Stack(
      children: [
        // 主体
        ScrollablePositionedList.builder(
          itemCount: _data.length,
          minCacheExtent: MediaQuery.of(context).size.height,
          itemBuilder: (context, index) {
            Widget w;
            if (_data[index].type == _Type.header) {
              w = widget.headerBuilder.call(context, _data[index].data);
            } else {
              w = widget.elementBuilder.call(context, _data[index].data);
            }
            return w;
          },
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
        ),
        // 表头
        Positioned(
          top: headerEdge,
          child: Container(
            height: widget.headerHeight,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
            child: _Header(
                key: _headerKey,
                header: widget.headerBuilder
                    .call(context, _header[currentHeaderIndex])),
          ),
        ),
        // 右侧滑动条
        if (showHeader)
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                child: Column(
                  children: [
                    IndexBar(
                      items: _header,
                      onTapDown: (String s) => jumpToHeader(s),
                      onScrollTo: (String s) => jumpToHeader(s),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum _Type { header, element }

class _Element<T> {
  T data;
  _Type type;

  ///自定义类，用于指示数据是表头还是列表元素
  _Element(
    this.data,
    this.type,
  );
}

// 自定义类似微信联系人右侧带index的列表
typedef ScrollTo = Function(String label);
typedef TapDown = Function(String label);

class IndexBar extends StatefulWidget {
  final List items;
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
  int currentIndex = 0;
  double singleHeight = 0;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (TapDownDetails detail) {
          barHeight = context.size!.height;
          singleHeight = barHeight / widget.items.length;
          currentIndex = (detail.localPosition.dy / singleHeight).truncate();
          widget.onTapDown?.call(widget.items[currentIndex]);
        },
        onPanStart: (DragStartDetails start) {
          position = start.localPosition.dy;
        },
        onPanUpdate: (DragUpdateDetails detail) {
          position += detail.delta.dy;
          if (position >= 0 && position < barHeight) {
            if (currentIndex !=
                (detail.localPosition.dy / singleHeight).truncate()) {
              currentIndex =
                  (detail.localPosition.dy / singleHeight).truncate();
              widget.onScrollTo?.call(widget.items[currentIndex]);
            }
          }
        },
        child: Container(
          width: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (String s in widget.items) Text(s),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  final Widget header;
  _Header({Key? key, required this.header}) : super(key: key);

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  late Widget header;
  @override
  void initState() {
    header = widget.header;
    super.initState();
  }

  void setHeader(Widget newHeader) {
    setState(() {
      header = newHeader;
    });
  }

  @override
  Widget build(BuildContext context) {
    return header;
  }
}
