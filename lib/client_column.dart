import 'dart:convert';
import 'package:xata_dart/client_table.dart';
import 'package:xata_dart/common.dart';
import 'package:xata_dart/main.dart';
import "package:http/http.dart" as http;

class Column extends XataSubClient {
  Column(super.config) {
    if (config.workspace == null) {
      throw Exception("Workspace must be set before accessing a column");
    }
    if (config.region == null) {
      throw Exception("Region must be set before accessing a column");
    }
    if (config.database == null) {
      throw Exception("Database must be set before accessing a column");
    }
    if (config.branch == null) {
      throw Exception("Branch must be set before accessing a column");
    }
    if (config.table == null) {
      throw Exception("Table must be set before accessing a column");
    }
  }

  /// create new column
  Future<XataTableMigration> create(XataColumn column) async {
    http.Response response = await http.post(Uri.parse("$branchURL/tables/${config.table}/columns"),
        headers: {...authHeader(config.key)}, body: jsonEncode(column.toMap()));
    statusCodeCheck(response);
    return XataTableMigration.fromMap(resMap(response.body));
  }

  /// get column information
  Future<XataColumn> get(String columnName) async {
    http.Response response = await http
        .get(Uri.parse("$branchURL/tables/${config.table}/columns/$columnName"), headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataColumn.fromMap(resMap(response.body));
  }

  /// rename column
  Future<XataTableMigration> rename(String columnName, String newName) async {
    http.Response response = await http.patch(Uri.parse("$branchURL/tables/${config.table}/columns/$columnName"),
        headers: {...authHeader(config.key)}, body: jsonEncode({"name": newName}));
    statusCodeCheck(response);
    return XataTableMigration.fromMap(resMap(response.body));
  }

  /// delete column
  Future<XataTableMigration> delete(String columnName) async {
    http.Response response = await http.delete(Uri.parse("$branchURL/tables/${config.table}/columns/$columnName"),
        headers: {...authHeader(config.key)});
    statusCodeCheck(response);
    return XataTableMigration.fromMap(resMap(response.body));
  }
}
