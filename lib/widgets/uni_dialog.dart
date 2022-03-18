import 'dart:async';

import 'package:flutter/material.dart';

class UniDialog extends StatelessWidget {
  const UniDialog({
    Key? key,
    this.onComfirm,
    this.body,
    this.secondConfirm = false,
    this.confirmText = "确定",
    required this.title,
  }) : super(key: key);

  final FutureOr<void> Function()? onComfirm;

  final Widget? body;

  final String title;

  final String confirmText;

  final bool secondConfirm;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: [
        if (body != null) body!,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: (() async {
                if (secondConfirm) {}
                onComfirm?.call();
              }),
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: (() => Navigator.of(context).pop()),
              child: const Text(
                "取消",
              ),
            ),
          ],
        )
      ],
    );
  }
}
