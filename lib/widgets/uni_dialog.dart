// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';

class UniDialog extends StatelessWidget {
  const UniDialog({
    Key? key,
    this.onComfirm,
    this.onCancel,
    this.body,
    required this.title,
    this.confirmText = "确定",
    this.secondConfirm = false,
  }) : super(key: key);

  final FutureOr<void> Function()? onComfirm;
  final FutureOr<void> Function()? onCancel;

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
              onPressed: () {
                onCancel?.call();
                Navigator.of(context).pop();
              },
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
