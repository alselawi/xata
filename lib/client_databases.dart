import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class XataDatabaseUI {
  String color;
  XataDatabaseUI.fromMap(Map<String, dynamic>? json) : color = json == null ? "" : json['color'] ?? "";
}

class XataDatabase {
  String name;
  String region;
  DateTime createdAt;
  String defaultClusterID;
  bool postgresEnabled;
  XataDatabaseUI ui;
  XataDatabase.fromMap(Map<String, dynamic> json)
      : name = json['name'] ?? "",
        region = json['region'] ?? "",
        createdAt = DateTime.parse(json['createdAt'] ?? ""),
        defaultClusterID = json['defaultClusterID'] ?? "",
        postgresEnabled = json['postgresEnabled'] ?? false,
        ui = XataDatabaseUI.fromMap(json['ui']);
}

class XataRegion {
  String name;
  String id;
  XataRegion.fromMap(Map<String, dynamic> json)
      : name = json['name'] ?? "",
        id = json['id'] ?? "";
}

class XataCreatedDatabase {
  String databaseName;
  String branchName;
  String status;
  XataCreatedDatabase.fromMap(Map<String, dynamic> json)
      : databaseName = json['databaseName'] ?? "",
        branchName = json['branchName'] ?? "",
        status = json['status'] ?? "";
}

class XataDatabaseSettings {
  bool searchEnabled;
  XataDatabaseSettings.fromMap(Map<String, dynamic> json) : searchEnabled = json['searchEnabled'] ?? false;
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
    return List<Map<String, dynamic>>.from(decode(response.body)["databases"])
        .map((e) => XataDatabase.fromMap(e))
        .toList();
  }

  /// Get a database in the workspace
  Future<XataDatabase> get(String dbName) async {
    http.Response response = await http.get(Uri.parse("$topLevelURL/workspaces/${config.workspace}/dbs/$dbName"),
        headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataDatabase.fromMap(decode(response.body));
  }

  /// List available regions that you can create a database in
  Future<List<XataRegion>> listRegions() async {
    http.Response response = await http
        .get(Uri.parse("$topLevelURL/workspaces/${config.workspace}/regions"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return List<Map<String, dynamic>>.from(decode(response.body)["regions"]).map((e) => XataRegion.fromMap(e)).toList();
  }

  /// create new database in the workspace
  Future<XataCreatedDatabase> create(String name) async {
    if (config.region == null) {
      throw Exception("Region must be set before creating a database");
    }

    http.Response response =
        await http.put(Uri.parse("$topLevelURL/workspaces/${config.workspace}/dbs/$name"), headers: {
      ...authHeader(config.key)
    }, body: {
      "region": config.region,
    });
    statusCodeCheck(response);
    return XataCreatedDatabase.fromMap(decode(response.body));
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
        await http.post(Uri.parse("$topLevelURL/workspaces/${config.workspace}/dbs/$dbName/rename"), headers: {
      ...authHeader(config.key)
    }, body: {
      "name": newName,
    });
    statusCodeCheck(response);
    return XataDatabase.fromMap(decode(response.body));
  }

  /// get database settings
  Future<XataDatabaseSettings> getSettings(String dbName) async {
    config.database = dbName;
    http.Response response = await http.get(Uri.parse(dbURL), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataDatabaseSettings.fromMap(decode(response.body));
  }

  /// update database settings
  Future<XataDatabaseSettings> updateSettings(String dbName, XataDatabaseSettings settings) async {
    config.database = dbName;
    http.Response response =
        await http.patch(Uri.parse(dbURL), headers: {...authHeader(config.key)}, body: settings.toMap());
    statusCodeCheck(response);
    return XataDatabaseSettings.fromMap(decode(response.body));
  }
}
