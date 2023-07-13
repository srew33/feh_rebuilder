import 'package:flutter/material.dart';

class CircleBtn extends StatelessWidget {
  /// 突破极限和神龙之花使用的按钮
  const CircleBtn({
    Key? key,
    required this.title,
    required this.text,
    required this.onPressed,
  }) : super(key: key);
  final String title;
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              "+$text",
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10),
        )
      ],
    );
  }
}
