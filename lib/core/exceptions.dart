class PermissionNotAllowedException implements Exception {
  final String? msg;
  PermissionNotAllowedException([
    this.msg,
  ]);
  @override
  String toString() {
    return msg ?? "PermissionNotAllowedException";
  }
}
