import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class XataKey {
  String name;
  DateTime createdAt;
  XataKey.fromMap(Map<String, String> json)
      : name = json['name'] ?? "",
        createdAt = DateTime.parse(json['createdAt'] ?? "");
}

class Keys extends XataSubClient {
  Keys(super.config);

  /// Get the current user's API keys
  Future<List<XataKey>> list() async {
    http.Response response = await http.get(Uri.parse("$topLevelURL/user/keys"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return (decode(response.body) as List).map((e) => XataKey.fromMap(e)).toList();
  }

  /// Create a new API key for the current user.
  /// this key will only be shown once, you will not be able to retrieve it again
  Future<String> create(String name) async {
    http.Response response =
        await http.post(Uri.parse("$topLevelURL/user/keys/$name"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return decode(response.body)['key'];
  }

  /// Delete an API key for the current user
  Future<void> delete(String name) async {
    http.Response response =
        await http.delete(Uri.parse("$topLevelURL/user/keys/$name"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
  }
}
