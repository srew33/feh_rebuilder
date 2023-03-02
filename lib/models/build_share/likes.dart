import 'base.dart';

class NetLikesBusinessModel extends BaseNetBusinessModel {
  NetLikesBusinessModel({
    required this.count,
    super.acl,
    super.objectId,
    super.updatedAt,
    super.createdAt,
  });
  int count;
}
