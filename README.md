采用 flutter 复刻的 Fire Emblem Heroes 游戏数据查询工具 Builder for FEH ，发布于[https://bbs.nga.cn/read.php?tid=28206759](https://bbs.nga.cn/read.php?tid=28206759https://bbs.nga.cn/read.php?tid=28206759)

数据来源：[GitHub - HertzDevil/feh-assets-json: JSON dumps of Fire Emblem Heroes asset files](https://github.com/HertzDevil/feh-assets-json)

资源文件来源：游戏文件 和 [Feh | Fire Emblem Wiki | Fandom](https://fireemblem.fandom.com/wiki/Feh)

属性算法来源：[Feh | Fire Emblem Wiki | Fandom](https://fireemblem.fandom.com/wiki/Feh)

flutter 版本：>= 3.10

资源文件生成工具：[feh_assets_creator](https://github.com/srew33/feh_assets_creator)

使用说明：

安装配置 flutter

**PC 端&&安卓端**

1. 自行生成一对 RSA 密钥，公钥放在 assets\update.pub，开发必须，仅运行的话生成一个空文件即可
2. flutter pub get
3. PC端需要将[sqlite3.dll](https://github.com/tekartik/sqflite/raw/master/sqflite_common_ffi/lib/src/windows/sqlite3.dll)放到exe的同一文件夹中，参考[sqflite_common_ffi | Dart Package (flutter-io.cn)](https://pub.flutter-io.cn/packages/sqflite_common_ffi)的说明
4. 编译运行

**Web端**

1. flutter pub get
2. 编译运行

**[项目结构](STRUCTURE.md)**

备注：

1. github 仅作为代码开源仓库，不会随时更新。
2. 考虑到安全，网络操作的具体实现没有开源，使用时请注释有关代码。

截图：

![Screenshot_20210928-173104](Screenshots/Screenshot_20210928-173104.png)

![Screenshot_20210928-173120](Screenshots/Screenshot_20210928-173120.png)

![Screenshot_20210928-173123](Screenshots/Screenshot_20210928-173123.png)

![Screenshot_20210928-173127](Screenshots/Screenshot_20210928-173127.png)

![Screenshot_20210928-173131](Screenshots/Screenshot_20210928-173131.png)

![Screenshot_20210928-173226](Screenshots/Screenshot_20210928-173226.png)

MIT License

Copyright (c) <2021> <copyright srew33@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
