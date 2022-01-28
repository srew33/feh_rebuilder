// abstract class CloudObject {
//   late String objectId;
//   late DateTime createdAt;
//   late DateTime updatedAt;
//   ACL? acl;
// }

// class ACL {
//   Iterable acls;
//   ACL({
//     required this.acls,
//   }) {
//     if (acls.isEmpty) {
//       // 默认全部只读
//       // acls = Iterable.generate(
//       //   1,
//       //   (index) => AclItem(
//       //     object: "*",
//       //     permission: Permission(
//       //       read: false,
//       //       write: false,
//       //     ),
//       //   ),
//       // );
//     }
//   }

//   factory ACL.fromJson(Map<String, dynamic> json) {
//     // json.forEach((key, value) {
//     //   AclItem.fromJson({key: value});
//     // });
//     return ACL(
//       acls: Iterable.generate(
//         json.length,
//         (index) => AclItem.fromJson(
//           json.entries.elementAt(index),
//         ),
//       ),
//     );
//   }

//   // Map<String, dynamic> toJson() => Map.fromEntries(acls);
// }

// class AclItem {
//   String object;
//   Permission permission;
//   AclItem({
//     required this.object,
//     required this.permission,
//   });
//   factory AclItem.fromJson(MapEntry<String, dynamic> json) => AclItem(
//         object: json.key,
//         permission: Permission.fromJson(json.value),
//       );

//   Map<String, dynamic> toJson() => {
//         object: permission.toJson(),
//       };
// }

// class Permission {
//   bool read;
//   bool write;

//   Permission({
//     required this.read,
//     required this.write,
//   });
//   factory Permission.fromJson(Map<String, dynamic> json) =>
//       Permission(read: json["read"], write: json["write"]);

//   Map<String, dynamic> toJson() => {
//         "read": read,
//         "write": write,
//       };
// }
