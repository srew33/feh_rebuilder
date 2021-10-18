import 'package:flutter/material.dart';

typedef Pressed = Function();

class CircleBtn extends StatefulWidget {
  final String? displayValue;
  final String? title;
  final double? titleSize;
  final double? height;
  final Pressed? onPressed;

  const CircleBtn({
    Key? key,
    this.displayValue,
    this.title,
    this.height,
    this.titleSize,
    required this.onPressed,
  }) : super(key: key);

  @override
  CircleBtnState createState() => CircleBtnState();
}

class CircleBtnState extends State<CircleBtn> {
  late String displayValue;
  Pressed? _onPressed;

  void setNewDisplay(String val) {
    // displayValue = val;
    setState(() {
      displayValue = val;
    });
  }

  @override
  void initState() {
    displayValue = widget.displayValue ?? "";
    _onPressed = widget.onPressed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: _onPressed,
          child: Text(displayValue),
          style: ButtonStyle(
              padding: widget.height != null
                  ? MaterialStateProperty.all(EdgeInsets.all(widget.height!))
                  : null,
              side: MaterialStateProperty.all(const BorderSide()),
              shape: MaterialStateProperty.all(const CircleBorder())),
        ),
        Text(
          widget.title ?? "",
          style: TextStyle(fontSize: widget.titleSize),
        )
      ],
    );
  }
}

class TraitsBtn extends StatefulWidget {
  final String? displayValue;
  final String? title;
  final double? titleSize;
  final double? height;
  final Pressed? onPressed;

  const TraitsBtn({
    Key? key,
    this.displayValue,
    this.title,
    this.height,
    this.titleSize,
    required this.onPressed,
  }) : super(key: key);

  @override
  TraitsBtnState createState() => TraitsBtnState();
}

class TraitsBtnState extends State<TraitsBtn> {
  late String displayValue;
  Pressed? _onPressed;

  void setNewDisplay(String val) {
    // displayValue = val;
    setState(() {
      displayValue = val;
    });
  }

  @override
  void initState() {
    displayValue = widget.displayValue ?? "";
    _onPressed = widget.onPressed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _onPressed,
      child: Text(displayValue),
      style: ButtonStyle(
        padding: widget.height != null
            ? MaterialStateProperty.all(EdgeInsets.all(widget.height!))
            : null,
        side: MaterialStateProperty.all(const BorderSide()),
        // shape: MaterialStateProperty.all(CircleBorder()),
      ),
    );
  }
}
