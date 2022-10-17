// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/models/build_share/base.dart';

class NetTags extends BaseShareModel {
  int seq;
  String value;
  NetTags({
    required this.seq,
    required this.value,
    super.acl,
    super.objectId,
    super.updatedAt,
    super.createdAt,
  });
}
