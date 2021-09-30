import 'package:flutter/material.dart';
import 'package:feh_tool/oss_licenses.dart';
import 'package:get/get.dart';

class OpenSource extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("开源许可"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("本程序使用了以下开源项目，请遵守各项目的开源协议"),
          ),
          ListTile(
            title: Text("feh_rebuilder"),
            onTap: () {
              Get.toNamed("/openSourceDetail", arguments: {
                "name": "feh_rebuilder",
                "homepage": "https://github.com/srew33/feh_rebuilder",
                "license": """MIT License
Copyright (c) <2021> <copyright srew33@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
""",
              });
            },
          ),
          for (String key in ossLicenses.keys)
            ListTile(
              title: Text(key),
              onTap: () {
                Get.toNamed("/openSourceDetail", arguments: ossLicenses[key]);
              },
              subtitle: Text(
                (ossLicenses[key]["description"] as String)
                    .replaceAll("\n", ""),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
        ],
      ),
    );
  }
}

class OpenSourceDetail extends StatelessWidget {
  const OpenSourceDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(arguments["name"]),
      ),
      body: ListView(
        children: [
          Card(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: "简介：\n", style: Get.textTheme.subtitle1),
              TextSpan(text: arguments["description"] ?? ""),
            ])),
          ),
          Card(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: "项目主页：\n", style: Get.textTheme.subtitle1),
              TextSpan(text: arguments["homepage"] ?? ""),
            ])),
          ),
          Card(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: "开源协议：\n", style: Get.textTheme.subtitle1),
              TextSpan(text: arguments["license"] ?? ""),
            ])),
          ),
        ],
      ),
    );
  }
}
