// ignore_for_file: use_super_parameters

import 'dart:convert';
import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class _XataBranchBase {
  DateTime createdAt;
  String state;
  bool get isActive => state == "active";
  bool get isMoving => state == "moving";
  bool get moveScheduled => state == "move_scheduled";

  _XataBranchBase.fromMap(Map<String, dynamic> json)
      : createdAt = DateTime.parse(json['createdAt'] ?? ""),
        state = json['state'] ?? "";
}

class XataBranch extends _XataBranchBase {
  String name;
  String clusterID;
  bool searchDisabled;
  bool inactiveSharedCluster;

  XataBranch.fromMap(Map<String, dynamic> json)
      : name = json['name'] ?? "",
        clusterID = json['clusterID'] ?? "",
        searchDisabled = json['searchDisabled'] ?? false,
        inactiveSharedCluster = json['inactiveSharedCluster'] ?? false,
        super.fromMap(json);
}

enum XataColumnType {
  bool("bool"),
  int("int"),
  float("float"),
  string("string"),
  text("text"),
  email("email"),
  multiple("multiple"),
  link("link"),
  object("object"),
  datetime("datetime"),
  vector("vector"),
  fileArr("file[]"),
  file("file"),
  json("json");

  final String type;
  const XataColumnType(this.type);
}

class XataRevLink {
  String table;
  String column;
  XataRevLink.fromMap(Map<String, dynamic> json)
      : table = json['table'] ?? "",
        column = json['column'] ?? "";
}

class XataColumnLink {
  String table;
  XataColumnLink.fromMap(Map<String, dynamic> json) : table = json['table'] ?? "";
}

class XataColumnVector {
  double dimension;
  XataColumnVector.fromMap(Map<String, dynamic> json) : dimension = double.parse(json['dimension'] ?? 0);
}

class XataColumnFile {
  bool defaultPublicAccess;
  XataColumnFile.fromMap(Map<String, dynamic> json) : defaultPublicAccess = json['defaultPublicAccess'] ?? false;
}

class XataColumn {
  String name;
  XataColumnType type;
  XataColumnLink? link;
  XataColumnVector? vector;
  XataColumnFile? file;
  XataColumnFile? fileArr;
  bool? notNull;
  String? defaultValue;
  bool? unique;
  List<XataColumn>? columns;

  XataColumn.fromMap(Map<String, dynamic> json)
      : name = json['name'] ?? "",
        type = XataColumnType.values
            .firstWhere((element) => element.type == (json['type'] ?? ""), orElse: () => XataColumnType.string),
        link = json['link'] != null ? XataColumnLink.fromMap(json['link']) : null,
        vector = json['vector'] != null ? XataColumnVector.fromMap(json['vector']) : null,
        file = json['file'] != null ? XataColumnFile.fromMap(json['file']) : null,
        fileArr = json['fileArr'] != null ? XataColumnFile.fromMap(json['fileArr']) : null,
        notNull = json['notNull'] ?? false,
        defaultValue = json['defaultValue'] ?? "",
        unique = json['unique'] ?? false,
        columns =
            json['columns'] != null ? List<XataColumn>.from(json['columns'].map((e) => XataColumn.fromMap(e))) : null;
}

class XataTable {
  String? id;
  String? name;
  List<XataColumn> columns;
  List<XataRevLink> revLinks;

  XataTable.fromMap(Map<String, dynamic> json)
      : id = json['id'] ?? "",
        name = json['name'] ?? "",
        columns = List<XataColumn>.from(json['columns'].map((e) => XataColumn.fromMap(e))),
        revLinks = List<XataRevLink>.from(json['revLinks'].map((e) => XataRevLink.fromMap(e)));
}

class XataDatabaseSchema {
  List<XataTable> tables;
  List<String>? tablesOrder;
  XataDatabaseSchema.fromMap(Map<String, dynamic> json)
      : tables = List<XataTable>.from(json['tables'].map((e) => XataTable.fromMap(e))),
        tablesOrder = json['tablesOrder'] != null ? List<String>.from(json['tablesOrder']) : null;
}

class XataStartMetadata {
  String branchName;
  String dbBranchID;
  String migrationID;
  XataStartMetadata.fromMap(Map<String, dynamic> json)
      : branchName = json['branchName'] ?? "",
        dbBranchID = json['dbBranchID'] ?? "",
        migrationID = json['migrationID'] ?? "";
}

class XataSingleDbBranch {
  String databaseName;
  String branchName;
  String id;
  String clusterID;
  String lastMigrationID;
  int version;
  XataBranchMetadata? metadata;
  XataDatabaseSchema schema;
  XataStartMetadata? startedFrom;
  XataSingleDbBranch.fromMap(Map<String, dynamic> json)
      : databaseName = json['databaseName'] ?? "",
        branchName = json['branchName'] ?? "",
        id = json['id'] ?? "",
        clusterID = json['clusterID'] ?? "",
        lastMigrationID = json['lastMigrationID'] ?? "",
        version = json['version'] ?? 0,
        startedFrom = json['startedFrom'] != null ? XataStartMetadata.fromMap(json['startedFrom']) : null,
        metadata = json['metadata'] != null ? XataBranchMetadata.fromMap(json['metadata']) : null,
        schema = XataDatabaseSchema.fromMap(json['schema']);
}

class XataBranchMetadata {
  String repository;
  String branch;
  String stage;
  List<String> labels;

  XataBranchMetadata.fromMap(Map<String, dynamic> json)
      : repository = json['repository'] ?? "",
        branch = json['branch'] ?? "",
        stage = json['stage'] ?? "",
        labels = List<String>.from(json['labels'] ?? []);

  Map<String, dynamic> toMap() => ({
        "repository": repository,
        "branch": branch,
        "stage": stage,
        "labels": labels,
      });
}

class Branches extends XataSubClient {
  Branches(super.config) {
    if (config.workspace == null) {
      throw Exception("Workspace must be set before accessing branches");
    }
    if (config.region == null) {
      throw Exception("Region must be set before accessing branches");
    }
    if (config.database == null) {
      throw Exception("Database must be set before accessing branches");
    }
  }

  /// List all branches in the current database
  Future<List<XataBranch>> list() async {
    http.Response response = await http.get(Uri.parse(dbURL), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return List<Map<String, dynamic>>.from(decode(response.body)["branches"])
        .map((e) => XataBranch.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Create a new branch in the current database
  Future<String> create(String name, String? forkFrom, XataBranchMetadata? metadata) async {
    config.branch = name;
    http.Response response = await http.put(Uri.parse("$branchURL/async"),
        headers: {...authHeader(config.key)},
        body: jsonEncode({
          if (forkFrom != null) "forkFrom": forkFrom,
          if (metadata != null) "metadata": metadata.toMap(),
        }));
    statusCodeCheck(response);
    return decode(response.body)['taskID'];
  }

  /// Synchronously create a new branch in the current database
  Future<String> createSync(String name, String? forkFrom, XataBranchMetadata? metadata) async {
    config.branch = name;
    http.Response response = await http.put(Uri.parse(branchURL),
        headers: {...authHeader(config.key)},
        body: jsonEncode({
          if (forkFrom != null) "forkFrom": forkFrom,
          if (metadata != null) "metadata": metadata.toMap(),
        }));
    statusCodeCheck(response);
    return decode(response.body)['branchName'];
  }

  /// Get a branch in the current database
  Future<XataSingleDbBranch> get(String name) async {
    config.branch = name;
    http.Response response = await http.get(Uri.parse(branchURL), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataSingleDbBranch.fromMap(decode(response.body));
  }

  /// Delete a branch in the current database
  Future<void> delete(String name) async {
    config.branch = name;
    http.Response response = await http.delete(Uri.parse(branchURL), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
  }

  /// Update branch metadata
  Future<void> updateMetadata(XataBranchMetadata metadata) async {
    config.branch = metadata.branch;
    http.Response response = await http.put(Uri.parse("$branchURL/metadata"),
        headers: {...authHeader(config.key)}, body: jsonEncode({"metadata": metadata.toMap()}));
    statusCodeCheck(response);
    return;
  }

  /// Get branch metadata
  Future<XataBranchMetadata> getMetadata(String name) async {
    config.branch = name;
    http.Response response = await http.get(Uri.parse("$branchURL/metadata"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataBranchMetadata.fromMap(decode(response.body));
  }
}
