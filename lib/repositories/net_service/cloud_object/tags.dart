import 'package:leancloud_storage/leancloud.dart';

import 'base.dart';

class NetTagsPO extends LCObject implements BaseNetModel {
  int get seq => this['seq'];
  set seq(int value) => this['seq'] = value;

  String get value => this['value'];
  set value(String value) => this['value'] = value;

  NetTagsPO() : super('tags');

  @override
  toBusinessModel() {
    // TODO: implement toViewModel
    throw UnimplementedError();
  }
}
