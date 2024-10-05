// ignore_for_file: non_constant_identifier_names, use_super_parameters

import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class _WorkspaceBase {
  String id;
  String name;
  String slug;
  String plan;

  bool get free => plan == "free";
  bool get paid => !free;

  _WorkspaceBase.fromMap(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        name = json['name'] ?? "",
        slug = json['slug'] ?? "",
        plan = json['plan'] ?? "";
}

class XataWorkspace extends _WorkspaceBase {
  String unique_id;
  String role;

  bool get owner => role == "owner";
  bool get maintainer => !owner;

  XataWorkspace.fromMap(Map<String, String> json)
      : unique_id = json['unique_id'] ?? "",
        role = json['role'] ?? "",
        super.fromMap(json);
}

class XataSingleWorkspace extends _WorkspaceBase {
  int memberCount;
  XataSingleWorkspace.fromMap(Map<String, dynamic> json)
      : memberCount = json['memberCount'] ?? 0,
        super.fromMap(json);
}

class Workspaces extends XataSubClient {
  Workspaces(super.config);

  /// Get the current user's workspaces
  Future<List<XataWorkspace>> list() async {
    http.Response response = await http.get(Uri.parse("$topLevelURL/workspaces"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return List<Map<String, dynamic>>.from(decode(response.body)["workspaces"])
        .map((e) => XataWorkspace.fromMap(Map<String, String>.from(e)))
        .toList();
  }

  /// Get a single workspace
  Future<XataSingleWorkspace> get(String workspace) async {
    http.Response response =
        await http.get(Uri.parse("$topLevelURL/workspaces/$workspace"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataSingleWorkspace.fromMap(decode(response.body));
  }

  /// Create a new workspace
  Future<XataSingleWorkspace> create(String name) async {
    http.Response response = await http
        .post(Uri.parse("$topLevelURL/workspaces"), headers: {...authHeader(config.key)}, body: {"name": name});
    statusCodeCheck(response);
    return XataSingleWorkspace.fromMap(decode(response.body));
  }

  /// rename a workspace
  Future<XataSingleWorkspace> rename(String id, String newName) async {
    http.Response response = await http
        .post(Uri.parse("$topLevelURL/workspaces/$id"), headers: {...authHeader(config.key)}, body: {"name": newName});
    statusCodeCheck(response);
    return XataSingleWorkspace.fromMap(decode(response.body));
  }

  /// Delete a workspace
  Future<void> delete(String id) async {
    http.Response response =
        await http.delete(Uri.parse("$topLevelURL/workspaces/$id"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
  }
}
