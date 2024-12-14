// ignore_for_file: non_constant_identifier_names, use_super_parameters

import 'dart:convert';

import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class _WorkspaceBase {
  String id;
  String name;
  String slug;
  String plan;

  bool get free => plan == "free";
  bool get paid => !free;

  _WorkspaceBase.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? "",
        name = map['name'] ?? "",
        slug = map['slug'] ?? "",
        plan = map['plan'] ?? "";
}

class XataWorkspace extends _WorkspaceBase {
  String unique_id;
  String role;

  bool get owner => role == "owner";
  bool get maintainer => !owner;

  XataWorkspace.fromMap(Map<String, String> map)
      : unique_id = map['unique_id'] ?? "",
        role = map['role'] ?? "",
        super.fromMap(map);
}

class XataSingleWorkspace extends _WorkspaceBase {
  int memberCount;
  XataSingleWorkspace.fromMap(Map<String, dynamic> map)
      : memberCount = map['memberCount'] ?? 0,
        super.fromMap(map);
}

class Workspaces extends XataSubClient {
  Workspaces(super.config);

  /// Get the current user's workspaces
  Future<List<XataWorkspace>> list() async {
    http.Response response = await http.get(Uri.parse("$topLevelURL/workspaces"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return List<Map<String, dynamic>>.from(resMap(response.body)["workspaces"])
        .map((e) => XataWorkspace.fromMap(Map<String, String>.from(e)))
        .toList();
  }

  /// Get a single workspace
  Future<XataSingleWorkspace> get(String workspaceID) async {
    http.Response response =
        await http.get(Uri.parse("$topLevelURL/workspaces/$workspaceID"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataSingleWorkspace.fromMap(resMap(response.body));
  }

  /// Create a new workspace
  Future<XataSingleWorkspace> create(String name) async {
    http.Response response = await http.post(Uri.parse("$topLevelURL/workspaces"),
        headers: {...authHeader(config.key)}, body: jsonEncode({"name": name}));
    statusCodeCheck(response);
    return XataSingleWorkspace.fromMap(resMap(response.body));
  }

  /// rename a workspace
  Future<XataSingleWorkspace> rename(String id, String newName) async {
    http.Response response = await http.put(Uri.parse("$topLevelURL/workspaces/$id"),
        headers: {...authHeader(config.key)}, body: jsonEncode({"name": newName}));
    statusCodeCheck(response);
    return XataSingleWorkspace.fromMap(resMap(response.body));
  }

  /// Delete a workspace
  Future<void> delete(String id) async {
    http.Response response =
        await http.delete(Uri.parse("$topLevelURL/workspaces/$id"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
  }
}
