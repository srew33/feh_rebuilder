import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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

  static final Dio _dio = Dio();

  Future<Uint8List?> _getImg(String url, String savePath) async {
    try {
      var target = File(savePath);
      if (await target.exists()) {
        return await target.readAsBytes();
      } else {
        var r = await _dio.get(url,
            options: Options(
              responseType: ResponseType.bytes,
            ));
        await target.create();
        await target.writeAsBytes(r.data);

        return r.data as Uint8List;
      }
    } on Exception {
      return null;
    }
  }

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
    } else {
      // return Image(
      //   image: AssetImage(path),
      //   frameBuilder: (context, child, frame, loaded) {
      //     if (loaded) {
      //       return child;
      //     }
      //     return frame != null
      //         ? child
      //         : SizedBox(
      //             width: height,
      //             height: height,
      //           );
      //   },
      //   height: height,
      //   errorBuilder: (context, obj, trace) {
      //     // List<String> splited = p.split(path).reversed.toList();
      //     return CachedNetworkImage(
      //       imageUrl:
      //           // p.join(cdnPath, splited[1], splited[0]).replaceAll(r"\", "/"),
      //           p
      //               .join(
      //                 "https://cdn.jsdelivr.net/gh/srew33/feh_rebuild_web/assets",
      //                 path,
      //               )
      //               .replaceAll(r"\", "/"),
      //       width: height,
      //       height: height,
      //       placeholder: (context, url) => const CircularProgressIndicator(),
      //       errorWidget: (context, url, error) => const Icon(Icons.error),
      //     );
      //   },
      // );
      // return Image(
      //   image: FileImage(File(p.join(EnvProvider.rootDir, path))),
      //   height: height,
      //   frameBuilder: (context, child, frame, loaded) {
      //     if (loaded) {
      //       return child;
      //     }
      //     return frame != null
      //         ? child
      //         : SizedBox(
      //             width: height,
      //             height: height,
      //           );
      //   },
      //   errorBuilder: (context, obj, trace) {
      //     return ExtendedImage.network(
      //       p
      //           .join(
      //             "https://cdn.jsdelivr.net/gh/srew33/feh_rebuild_web/assets",
      //             path,
      //           )
      //           .replaceAll(r"\", "/"),
      //       width: height,
      //       height: height,
      //       loadStateChanged: (state) {
      //         if (state.extendedImageLoadState == LoadState.loading) {
      //           return const CircularProgressIndicator();
      //         }
      //         if (state.extendedImageLoadState == LoadState.failed) {
      //           return Icon(
      //             Icons.error,
      //             size: height,
      //           );
      //         }
      //         return null;
      //       },
      //     );
      //   },
      // );

      return Image(
        image: FileImage(
          File(p.join(EnvProvider.rootDir, path)),
        ),
        frameBuilder: (context, child, frame, loaded) {
          if (loaded) {
            return child;
          }
          return frame != null
              ? child
              : SizedBox(
                  width: height,
                  height: height,
                );
        },
        height: height,
        errorBuilder: (context, obj, s) => FutureBuilder(
            future: _getImg(
              p
                  .join(
                    "https://cdn.jsdelivr.net/gh/srew33/feh_rebuild_web/assets",
                    path,
                  )
                  .replaceAll(r"\", "/"),
              p.join(EnvProvider.rootDir, path),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return snapshot.hasData
                    ? Image(
                        image: MemoryImage(snapshot.data as Uint8List),
                        width: height,
                        height: height,
                      )
                    : Icon(
                        Icons.error,
                        size: height,
                      );
              } else {
                return SizedBox(
                  width: height,
                  height: height,
                  child: const CircularProgressIndicator(),
                );
              }
            }),
      );
    }
  }
}
