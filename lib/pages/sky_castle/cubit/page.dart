import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:feh_rebuilder/models/personBuild/person_build.dart';
import 'package:feh_rebuilder/pages/sky_castle/cubit/skycastle_cubit.dart';
import 'package:path/path.dart' as p;

class SkyCastlePage extends StatelessWidget {
  const SkyCastlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SkycastleCubit(),
      child: _Content(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key}) : super(key: key);

  final double ratio = 720 / 540;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width > 540
        ? 540
        : MediaQuery.of(context).size.width;
    // double height =
    //     ratio * width > (MediaQuery.of(context).size.height - kToolbarHeight)
    //         ? (MediaQuery.of(context).size.height - kToolbarHeight)
    //         : ratio * width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Spacer(),
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Image(
                  fit: BoxFit.contain,
                  // todo 需要scale?
                  image: FileImage(
                    File(r"assets\SkyCastle\Field\K0001.png"),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 540, maxHeight: 720),
                  child: Wrap(
                    children: [
                      for (var i = 0; i < 48; i++)
                        _DragItem(
                          data: [5, 10].contains(i)
                              ? p.join(r"assets\SkyCastle\Chip",
                                  "Deco" + "$i".padLeft(2, "0"), "Default.png")
                              : "",
                          width: width,
                        )
                    ],
                  ),
                ),
              )
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class _DragMsg {
  final String data;
  final PersonBuild? build;
  final void Function(String data, PersonBuild? build)? setData;

  _DragMsg(
    this.data,
    this.build,
    this.setData,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _DragMsg && other.data == data && other.build == build;
  }

  @override
  int get hashCode => data.hashCode ^ build.hashCode;
}

class _DragItem extends StatefulWidget {
  const _DragItem({
    Key? key,
    required this.width,
    required this.data,
  }) : super(key: key);

  final double width;
  final String data;

  @override
  State<_DragItem> createState() => __DragItemState();
}

class __DragItemState extends State<_DragItem> {
  // String _data = "";
  // PersonBuild? _build;

  _DragMsg current = _DragMsg("", null, null);

  bool get containsItem => current.data.isNotEmpty;

  void setData(String data, PersonBuild? build) {
    setState(() {
      current = _DragMsg(data, build, setData);
    });
  }

  @override
  void initState() {
    current = _DragMsg(widget.data, null, setData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<_DragMsg>(
      onWillAccept: (data) {
        // todo 检测坐标是否可接受
        if (data != current) {
          return true;
        }
        return false;
      },
      onAccept: (data) {
        data.setData?.call(current.data, current.build);

        setState(() {
          current = _DragMsg(data.data, data.build, setData);
        });
      },
      builder: (context, candidateData, rejectedData) {
        if (containsItem) {
          return Draggable<_DragMsg>(
            data: current,
            child: Container(
              width: ((widget.width - 1) / 6),
              height: widget.width / 6,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 1)),
              child: Image(
                image: FileImage(
                  File(current.data),
                ),
              ),
            ),
            feedback: Container(
              width: ((widget.width - 1) / 6),
              height: widget.width / 6,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 1)),
              child: Image(
                image: FileImage(
                  File(current.data),
                ),
              ),
            ),
          );
        } else {
          return Container(
            width: ((widget.width - 1) / 6),
            height: widget.width / 6,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 1)),
          );
        }
      },
    );
    // return Draggable<String>(
    //   data: _data,
    //   feedback: Container(
    //     width: ((widget.width - 1) / 6),
    //     height: widget.width / 6,
    //     decoration:
    //         BoxDecoration(border: Border.all(color: Colors.orange, width: 1)),
    //     child: Center(
    //       child: Image(
    //         image: FileImage(
    //           File(_data),
    //         ),
    //       ),
    //     ),
    //   ),
    //   child: DragTarget<String>(
    //     onAccept: (data) {
    //       if (data != _data) {
    //         setState(() {
    //           _data = data;
    //         });
    //       }
    //     },
    //     builder: (context, candidateData, rejectedData) {
    //       return Container(
    //         width: ((widget.width - 1) / 6),
    //         height: widget.width / 6,
    //         decoration: BoxDecoration(
    //             border: Border.all(color: Colors.orange, width: 1)),
    //         child: Center(
    //           child: Image(
    //             image: FileImage(
    //               File(_data),
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}


// class _DragItem extends StatelessWidget {
//   const _DragItem({
//     Key? key,
//   }) : super(key: key);

//   String data;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(data),
//     );
//   }
// }
