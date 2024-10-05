import 'dart:convert';
import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class XataUser {
  String id;
  String name;
  String email;
  String image;
  XataUser.fromMap(Map<String, String> json)
      : id = json['id'] ?? "",
        name = json['name'] ?? "",
        email = json['email'] ?? "",
        image = json['image'] ?? "";

  Map<String, String> toMap() => {'id': id, 'name': name, 'email': email, 'image': image};
}

class User extends XataSubClient {
  User(super.config);

  /// Get the current user of the API key
  Future<XataUser> get() async {
    http.Response response = await http.get(Uri.parse("$topLevelURL/user"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataUser.fromMap(Map<String, String>.from(decode(response.body)));
  }

  /// Update the current user of the API key
  Future<XataUser> update(XataUser user) async {
    final newUserData = user.toMap();
    newUserData.remove("id");
    newUserData.remove("email");
    http.Response response = await http.put(
      Uri.parse("$topLevelURL/user"),
      headers: {...authHeader(config.key)},
      body: jsonEncode(newUserData),
    );
    statusCodeCheck(response);
    return XataUser.fromMap(Map<String, String>.from(decode(response.body)));
  }

  /// Delete the current user of the API key
  /// IMPORTANT: This will delete the user, the API key, and all data associated with it.
  Future<void> delete() async {
    http.Response response = await http.delete(Uri.parse("$topLevelURL/user"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
  }
}
