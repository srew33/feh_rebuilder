import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class Picker extends StatefulWidget {
  final Widget? title;
  final List<Map> body;
  final int? nullIndex;
  const Picker({Key? key, this.title, required this.body, this.nullIndex})
      : super(key: key);

  @override
  _PickerState createState() => _PickerState();
}

class _PickerState extends State<Picker> {
  List<int> current = [];

  _PickerState();
  @override
  void initState() {
    for (var element in widget.body) {
      current.add(element["value"]);
    }
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
                  child: const Text("取消")),
              widget.title ?? const SizedBox.shrink(),
              TextButton(
                  onPressed: () {
                    if (widget.nullIndex != null) {
                      // 全不为null(且全不相等)或全为null
                      if ((!current.any(
                                  (element) => element == widget.nullIndex) &&
                              current.length == current.toSet().length) ||
                          !current
                              .any((element) => element != widget.nullIndex)) {
                        Navigator.of(context).pop(current);
                      }
                    } else {
                      Navigator.of(context).pop(current);
                    }
                  },
                  child: const Text(
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
