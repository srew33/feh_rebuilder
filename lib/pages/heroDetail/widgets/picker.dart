import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class Picker extends StatefulWidget {
  final Widget? title;
  final List<Map> body;
  final int? nullIndex;
  Picker({this.title, required this.body, this.nullIndex});

  @override
  _PickerState createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  List<int> current = [];

  _PickerState();
  @override
  void initState() {
    widget.body.forEach((element) {
      current.add(element["value"]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("取消")),
              widget.title ?? SizedBox.shrink(),
              TextButton(
                  onPressed: () {
                    if (widget.nullIndex != null) {
                      List<int?> _current = [...current];
                      // 检测是否都是null或都不是null
                      current.removeWhere(
                          (element) => element == widget.nullIndex);
                      if (current.isEmpty ||
                          current.length == _current.length) {
                        // 非null的元素必须全部不等
                        if (Set.from(current).length == current.length) {
                          _current.forEach((element) {
                            if (element == widget.nullIndex) {
                              element = null;
                            }
                          });
                          Navigator.of(context).pop(_current);
                        }
                      }
                    } else {
                      Navigator.of(context).pop(current);
                    }
                  },
                  child: Text(
                    "确认",
                  )),
            ],
          ),
          Row(
            children: [
              for (int i = 0; i < widget.body.length; i++)
                Expanded(
                    child: NumberPicker(
                        minValue: widget.body[i]["minValue"],
                        maxValue: widget.body[i]["maxValue"],
                        value: current[i],
                        textMapper: widget.body[i]["textMapper"],
                        onChanged: (newValue) {
                          setState(() {
                            current[i] = newValue;
                          });
                        }))
            ],
          )
        ],
      ),
    );
  }
}
