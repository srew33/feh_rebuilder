import 'package:feh_rebuilder/models/build_share/base.dart';

class NetFavoriteBusinessModel extends BaseNetBusinessModel {
  NetFavoriteBusinessModel({
    required this.buildId,
    required this.user,
    required this.type,
    super.acl,
    super.objectId,
    super.updatedAt,
    super.createdAt,
  });

  String buildId;
  String user;
  int type;
}
