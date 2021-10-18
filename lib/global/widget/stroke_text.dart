import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  final String label;
  final double fontSize;
  final double shaderHeight;
  final double strokeWidth;
  const StrokeText({
    Key? key,
    required this.label,
    required this.fontSize,
    required this.shaderHeight,
    required this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Stack(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
              // color: Colors.black,
              foreground: Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth,
            ),
            // ..color = Colors.blue.shade700,
          ),
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                foreground: Paint()
                  ..shader = LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.shade700,
                        Colors.white,
                      ]).createShader(Rect.fromLTWH(0, 0, 0, shaderHeight))),
          ),
        ],
      ),
    );
  }
}
