import 'dart:convert';
import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class XataUser {
  final String id;
  final String fullname;
  final String email;
  final String image;

  const XataUser({this.id = "", this.fullname = "", this.email = "", this.image = ""});

  XataUser.fromMap(Map<String, String> map)
      : id = map['id'] ?? "",
        fullname = map['fullname'] ?? "",
        email = map['email'] ?? "",
        image = map['image'] ?? "";

  Map<String, String> toMap() => {'id': id, 'fullname': fullname, 'email': email, 'image': image};
}

class User extends XataSubClient {
  User(super.config);

  /// Get the current user of the API key
  Future<XataUser> get() async {
    http.Response response = await http.get(Uri.parse("$topLevelURL/user"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataUser.fromMap(Map<String, String>.from(resMap(response.body)));
  }

  /// Update the current user of the API key
  Future<XataUser> update(XataUser newUser) async {
    final oldUser = await get();
    final newUserMap = newUser.toMap();
    newUserMap.remove("id");
    newUserMap["email"] = oldUser.email;
    if (newUser.fullname.isEmpty) newUserMap["fullname"] = oldUser.fullname;
    if (newUser.image.isEmpty) newUserMap["image"] = oldUser.image;

    http.Response response = await http.put(
      Uri.parse("$topLevelURL/user"),
      headers: {...authHeader(config.key)},
      body: jsonEncode(newUserMap),
    );
    statusCodeCheck(response);
    return XataUser.fromMap(Map<String, String>.from(resMap(response.body)));
  }

  /// Delete the current user of the API key
  /// IMPORTANT: This will delete the user, the API key, and all data associated with it.
  Future<void> delete() async {
    http.Response response = await http.delete(Uri.parse("$topLevelURL/user"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
  }
}
