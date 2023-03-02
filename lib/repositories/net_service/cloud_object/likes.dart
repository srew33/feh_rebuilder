import 'package:leancloud_storage/leancloud.dart';

import 'base.dart';

class NetLikesPO extends LCObject implements BaseNetModel {
  int get count => this['count'];
  set count(int value) => this['count'] = value;

  NetLikesPO() : super('likes');

  @override
  toBusinessModel() {
    // TODO: implement toViewModel
    throw UnimplementedError();
  }
}
