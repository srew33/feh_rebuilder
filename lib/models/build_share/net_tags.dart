// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:feh_rebuilder/models/build_share/base.dart';

class NetTagsBusinessModel extends BaseNetBusinessModel {
  int seq;
  String value;
  NetTagsBusinessModel({
    required this.seq,
    required this.value,
    super.acl,
    super.objectId,
    super.updatedAt,
    super.createdAt,
  });
}
