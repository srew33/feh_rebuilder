import 'package:feh_rebuilder/core/enum/person_type.dart';
import 'package:feh_rebuilder/my_18n/extension.dart';
import 'package:flutter/material.dart';

class DescWidget extends StatefulWidget implements PreferredSizeWidget {
  const DescWidget({
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
  State<DescWidget> createState() => _DescWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DescWidgetState extends State<DescWidget> with TickerProviderStateMixin {
  late AnimationController _aniController;

  late Animation<double> _animation;

  OverlayEntry? overlayEntry;

  late String tagWithoutPrefix;

  void _showOverlay(BuildContext context) {
    overlayEntry = _createOverlayEntry(context);
    _aniController.reset();
    _aniController.forward();
    Overlay.of(context).insert(overlayEntry!);
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
                                    "声优：${"MPID_VOICE_${tagWithoutPrefix}EX01".tr}",
                                  )
                                : Text(
                                    "声优：${"MPID_VOICE_$tagWithoutPrefix".tr}",
                                  ),
                            widget.resplendent
                                ? Text(
                                    "画师：${"MPID_ILLUST_${tagWithoutPrefix}EX01".tr}",
                                  )
                                : Text(
                                    "画师：${"MPID_ILLUST_$tagWithoutPrefix".tr}",
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
