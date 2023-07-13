import 'dart:io';

import 'package:feh_rebuilder/env_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:transparent_image/transparent_image.dart';

class UniImage extends StatelessWidget {
  final String path;
  final double height;
  const UniImage({
    Key? key,
    required this.path,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        height: height,
        image: AssetImage(path),
        // image: NetworkImage(path.replaceAll(r"\", "/")),
        fadeInDuration: const Duration(milliseconds: 500),
        imageErrorBuilder: (context, obj, s) => Icon(
          Icons.error,
          size: height,
        ),
      );
    }

    return Image(
      image: FileImage(
        File(p.join(EnvProvider.rootDir, path)),
      ),
      height: height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        } else {
          return frame != null
              ? child
              : SizedBox(
                  width: height,
                  height: height,
                );
        }
      },
      errorBuilder: (context, obj, s) => SizedBox(
        width: height,
        height: height,
        child: const Center(child: Icon(Icons.error)),
      ),
    );
  }
}
