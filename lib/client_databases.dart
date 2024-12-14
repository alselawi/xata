import 'dart:convert';

import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class XataDatabaseUI {
  String color;
  XataDatabaseUI.fromMap(Map<String, dynamic>? map) : color = map == null ? "" : map['color'] ?? "";
}

class XataDatabase {
  String name;
  String region;
  DateTime createdAt;
  String defaultClusterID;
  bool postgresEnabled;
  XataDatabaseUI ui;
  XataDatabase.fromMap(Map<String, dynamic> map)
      : name = map['name'] ?? "",
        region = map['region'] ?? "",
        createdAt = DateTime.parse(map['createdAt'] ?? ""),
        defaultClusterID = map['defaultClusterID'] ?? "",
        postgresEnabled = map['postgresEnabled'] ?? false,
        ui = XataDatabaseUI.fromMap(map['ui']);
}

class XataRegion {
  String name;
  String id;
  XataRegion.fromMap(Map<String, dynamic> map)
      : name = map['name'] ?? "",
        id = map['id'] ?? "";
}

class XataCreatedDatabase {
  String databaseName;
  String branchName;
  String status;
  XataCreatedDatabase.fromMap(Map<String, dynamic> map)
      : databaseName = map['databaseName'] ?? "",
        branchName = map['branchName'] ?? "",
        status = map['status'] ?? "";
}

class XataDatabaseSettings {
  bool searchEnabled;
  XataDatabaseSettings({required this.searchEnabled});
  XataDatabaseSettings.fromMap(Map<String, dynamic> map) : searchEnabled = map['searchEnabled'] ?? false;
  Map<String, dynamic> toMap() => {"searchEnabled": searchEnabled};
}

class Databases extends XataSubClient {
  Databases(super.config) {
    if (config.workspace == null) {
      throw Exception("Workspace must be set before accessing databases");
    }
  }

  /// Get a list of databases in the workspace
  Future<List<XataDatabase>> list() async {
    http.Response response = await http
        .get(Uri.parse("$topLevelURL/workspaces/${config.workspace}/dbs"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return List<Map<String, dynamic>>.from(resMap(response.body)["databases"])
        .map((e) => XataDatabase.fromMap(e))
        .toList();
  }

  /// Get a database in the workspace
  Future<XataDatabase> get(String dbName) async {
    http.Response response = await http.get(Uri.parse("$topLevelURL/workspaces/${config.workspace}/dbs/$dbName"),
        headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataDatabase.fromMap(resMap(response.body));
  }

  /// List available regions that you can create a database in
  Future<List<XataRegion>> listRegions() async {
    http.Response response = await http
        .get(Uri.parse("$topLevelURL/workspaces/${config.workspace}/regions"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return List<Map<String, dynamic>>.from(resMap(response.body)["regions"]).map((e) => XataRegion.fromMap(e)).toList();
  }

  /// create new database in the workspace
  Future<XataCreatedDatabase> create(String name) async {
    if (config.region == null) {
      throw Exception("Region must be set before creating a database");
    }

    http.Response response = await http.put(Uri.parse("$topLevelURL/workspaces/${config.workspace}/dbs/$name"),
        headers: {...authHeader(config.key)},
        body: jsonEncode({
          "region": config.region,
        }));
    statusCodeCheck(response);
    return XataCreatedDatabase.fromMap(resMap(response.body));
  }

  /// Delete a database in the workspace
  Future<void> delete(String dbName) async {
    http.Response response = await http.delete(Uri.parse("$topLevelURL/workspaces/${config.workspace}/dbs/$dbName"),
        headers: {...authHeader(config.key)});
    statusCodeCheck(response);
  }

  /// rename database
  Future<XataDatabase> rename(String dbName, String newName) async {
    http.Response response =
        await http.post(Uri.parse("$topLevelURL/workspaces/${config.workspace}/dbs/$dbName/rename"),
            headers: {...authHeader(config.key)},
            body: jsonEncode({
              "newName": newName,
            }));
    statusCodeCheck(response);
    return XataDatabase.fromMap(resMap(response.body));
  }

  /// get database settings
  Future<XataDatabaseSettings> getSettings(String dbName) async {
    config.database = dbName;
    http.Response response = await http.get(Uri.parse("$dbURL/settings"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataDatabaseSettings.fromMap(resMap(response.body));
  }

  /// update database settings
  Future<XataDatabaseSettings> updateSettings(String dbName, XataDatabaseSettings settings) async {
    config.database = dbName;
    http.Response response = await http.patch(Uri.parse("$dbURL/settings"),
        headers: {...authHeader(config.key)}, body: jsonEncode(settings.toMap()));
    statusCodeCheck(response);
    return XataDatabaseSettings.fromMap(resMap(response.body));
  }
}
