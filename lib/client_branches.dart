// ignore_for_file: use_super_parameters

import 'dart:convert';
import 'package:xata_dart/column_schema.dart';
import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class _XataBranchBase {
  DateTime createdAt;
  String state;
  bool get isActive => state == "active";
  bool get isMoving => state == "moving";
  bool get moveScheduled => state == "move_scheduled";

  _XataBranchBase.fromMap(Map<String, dynamic> map)
      : createdAt = DateTime.parse(map['createdAt'] ?? ""),
        state = map['state'] ?? "";
}

class XataBranch extends _XataBranchBase {
  String name;
  String clusterID;
  bool searchDisabled;
  bool inactiveSharedCluster;

  XataBranch.fromMap(Map<String, dynamic> map)
      : name = map['name'] ?? "",
        clusterID = map['clusterID'] ?? "",
        searchDisabled = map['searchDisabled'] ?? false,
        inactiveSharedCluster = map['inactiveSharedCluster'] ?? false,
        super.fromMap(map);
}

class XataRevLink {
  String table;
  String column;
  XataRevLink.fromMap(Map<String, dynamic> map)
      : table = map['table'] ?? "",
        column = map['column'] ?? "";
}

class XataTable {
  String? id;
  String? name;
  List<XataColumn> columns;
  List<XataRevLink> revLinks;

  XataTable.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? "",
        name = map['name'] ?? "",
        columns = List<XataColumn>.from(map['columns'].map((e) => XataColumn.fromMap(e))),
        revLinks = List<XataRevLink>.from(map['revLinks'].map((e) => XataRevLink.fromMap(e)));
}

class XataDatabaseSchema {
  List<XataTable> tables;
  List<String>? tablesOrder;
  XataDatabaseSchema.fromMap(Map<String, dynamic> map)
      : tables = List<XataTable>.from(map['tables'].map((e) => XataTable.fromMap(e))),
        tablesOrder = map['tablesOrder'] != null ? List<String>.from(map['tablesOrder']) : null;
}

class XataStartMetadata {
  String branchName;
  String dbBranchID;
  String migrationID;
  XataStartMetadata.fromMap(Map<String, dynamic> map)
      : branchName = map['branchName'] ?? "",
        dbBranchID = map['dbBranchID'] ?? "",
        migrationID = map['migrationID'] ?? "";
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
  XataSingleDbBranch.fromMap(Map<String, dynamic> map)
      : databaseName = map['databaseName'] ?? "",
        branchName = map['branchName'] ?? "",
        id = map['id'] ?? "",
        clusterID = map['clusterID'] ?? "",
        lastMigrationID = map['lastMigrationID'] ?? "",
        version = map['version'] ?? 0,
        startedFrom = map['startedFrom'] != null ? XataStartMetadata.fromMap(map['startedFrom']) : null,
        metadata = map['metadata'] != null ? XataBranchMetadata.fromMap(map['metadata']) : null,
        schema = XataDatabaseSchema.fromMap(map['schema']);
}

class XataBranchMetadata {
  String repository;
  String branch;
  String stage;
  List<String> labels;

  XataBranchMetadata({
    required this.branch,
    this.repository = "",
    this.stage = "",
    this.labels = const [],
  });

  XataBranchMetadata.fromMap(Map<String, dynamic> map)
      : repository = map['repository'] ?? "",
        branch = map['branch'] ?? "",
        stage = map['stage'] ?? "",
        labels = List<String>.from(map['labels'] ?? []);

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
    return List<Map<String, dynamic>>.from(resMap(response.body)["branches"])
        .map((e) => XataBranch.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Create a new branch in the current database
  Future<String> create(String name, [String? forkFrom, XataBranchMetadata? metadata]) async {
    config.branch = name;
    http.Response response = await http.put(Uri.parse("$branchURL/async"),
        headers: {...authHeader(config.key)},
        body: jsonEncode({
          if (forkFrom != null) "forkFrom": forkFrom,
          if (metadata != null) "metadata": metadata.toMap(),
        }));
    statusCodeCheck(response);
    return resMap(response.body)['taskID'];
  }

  /// Synchronously create a new branch in the current database
  Future<String> createSync(String name, [String? forkFrom, XataBranchMetadata? metadata]) async {
    config.branch = name;
    http.Response response = await http.put(Uri.parse(branchURL),
        headers: {...authHeader(config.key)},
        body: jsonEncode({
          if (forkFrom != null) "forkFrom": forkFrom,
          if (metadata != null) "metadata": metadata.toMap(),
        }));
    statusCodeCheck(response);
    return resMap(response.body)['branchName'];
  }

  /// Get a branch in the current database
  Future<XataSingleDbBranch> get(String name) async {
    config.branch = name;
    http.Response response = await http.get(Uri.parse(branchURL), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataSingleDbBranch.fromMap(resMap(response.body));
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
        headers: {...authHeader(config.key)}, body: jsonEncode(metadata.toMap()));
    statusCodeCheck(response);
    return;
  }

  /// Get branch metadata
  Future<XataBranchMetadata> getMetadata(String name) async {
    config.branch = name;
    http.Response response = await http.get(Uri.parse("$branchURL/metadata"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataBranchMetadata.fromMap(resMap(response.body));
  }
}
