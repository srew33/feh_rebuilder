import 'package:feh_rebuilder/models/build_share/update_table.dart';
import 'package:leancloud_storage/leancloud.dart';

import 'base.dart';

class NetUpdateInfoPO extends LCObject implements BaseNetModel {
  int get id => this['id'];
  set id(int value) => this['id'] = value;

  String get alias => this['alias'];
  set alias(String value) => this['alias'] = value;

  String get checksum => this['checksum'];
  set checksum(String value) => this['checksum'] = value;

  String get info => this['info'];
  set info(String value) => this['info'] = value;

  int get minimalVersion => this['minimal_version'];
  set minimalVersion(int value) => this['minimal_version'] = value;

  int get serverVersion => this['server_version'];
  set serverVersion(int value) => this['server_version'] = value;

  int get type => this['type'];
  set type(int value) => this['type'] = value;

  String get url => this['url'];
  set url(String value) => this['url'] = value;

  String get downloadSecret => this['download_secret'] ?? "";
  set downloadSecret(String value) => this['download_secret'] = value;

  NetUpdateInfoPO() : super('update_info');

  @override
  UpdateTableBusinessModel toBusinessModel() {
    return UpdateTableBusinessModel(
      id: id,
      type: type,
      info: info,
      serverVersion: serverVersion,
      minimalVersion: minimalVersion,
      alias: alias,
      url: url.trim(),
      checksum: checksum.trim(),
      downloadSecret: downloadSecret.trim(),
    );
  }
}
