import 'dart:convert';

import 'package:xata_dart/column_schema.dart';
import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class XataCreatedTable {
  String branchName;
  String tableName;
  String status;
  XataCreatedTable.fromMap(Map<String, dynamic> map)
      : branchName = map['branchName'] ?? "",
        tableName = map['tableName'] ?? "",
        status = map['status'] ?? "";
}

class XataTableMigration {
  String migrationID;
  String parentMigrationID;
  String status;

  bool get isCompleted => status == "completed";
  bool get isFailed => status == "failed";
  bool get isPending => status == "pending";

  XataTableMigration.fromMap(Map<String, dynamic> map)
      : migrationID = map['migrationID'] ?? "",
        parentMigrationID = map['parentMigrationID'] ?? "",
        status = map['status'] ?? "";
}

class Table extends XataSubClient {
  Table(super.config) {
    if (config.workspace == null) {
      throw Exception("Workspace must be set before accessing a table");
    }
    if (config.region == null) {
      throw Exception("Region must be set before accessing a table");
    }
    if (config.database == null) {
      throw Exception("Database must be set before accessing a table");
    }
    if (config.branch == null) {
      throw Exception("Branch must be set before accessing a table");
    }
  }

  /// create a table
  Future<XataCreatedTable> create(String name) async {
    http.Response response = await http.put(Uri.parse("$branchURL/tables/$name"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataCreatedTable.fromMap(resMap(response.body));
  }

  /// delete table
  Future<void> delete(String name) async {
    http.Response response =
        await http.delete(Uri.parse("$branchURL/tables/$name"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
  }

  /// rename table
  Future<XataTableMigration> rename(String name, String newName) async {
    http.Response response = await http.patch(Uri.parse("$branchURL/tables/$name"),
        headers: {...authHeader(config.key)}, body: jsonEncode({"name": newName}));
    statusCodeCheck(response);
    return XataTableMigration.fromMap(resMap(response.body));
  }

  // get table schema
  Future<List<XataColumn>> getSchema(String name) async {
    http.Response response =
        await http.get(Uri.parse("$branchURL/tables/$name/schema"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return List<Map<String, dynamic>>.from(resMap(response.body)["columns"])
        .map((e) => XataColumn.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// update table schema
  Future<XataTableMigration> updateSchema(String name, List<XataColumn> schema) async {
    http.Response response = await http.put(Uri.parse("$branchURL/tables/$name/schema"),
        headers: {...authHeader(config.key)}, body: jsonEncode({"columns": schema.map((e) => e.toMap()).toList()}));
    statusCodeCheck(response);
    return XataTableMigration.fromMap(resMap(response.body));
  }
}
