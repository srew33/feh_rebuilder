import 'base.dart';

class NetLikes extends BaseShareModel {
  NetLikes({
    required this.count,
    super.acl,
    super.objectId,
    super.updatedAt,
    super.createdAt,
  });
  int count;
}
