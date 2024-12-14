import 'dart:convert';
import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

class XataOperationBase {
  List<String>? columns;
  XataOperationBase({this.columns}) {
    if (columns != null) {
      columns!.addAll(["id", "xata.*"]);
    }
  }
}

class XataInsertOp<R extends XataRecord> extends XataOperationBase {
  R record;
  int? ifVersion;
  bool? createOnly;
  XataInsertOp({required this.record, this.ifVersion, this.createOnly, super.columns});
  Map<String, dynamic> toMap() {
    return {
      "record": record.toMap(),
      if (ifVersion != null) "ifVersion": ifVersion,
      if (createOnly != null) "createOnly": createOnly,
      if (columns != null) "columns": columns,
    };
  }
}

class XataUpdateOp<R extends XataRecord> extends XataOperationBase {
  String id;
  R fields;
  int? ifVersion;
  bool? upsert;
  XataUpdateOp({required this.id, required this.fields, this.ifVersion, this.upsert, super.columns});
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "fields": fields.toMap(),
      if (ifVersion != null) "ifVersion": ifVersion,
      if (upsert != null) "upsert": upsert,
      if (columns != null) "columns": columns,
    };
  }
}

class XataDeleteOp extends XataOperationBase {
  String id;
  bool? failIfMissing;
  XataDeleteOp({required this.id, this.failIfMissing, super.columns});
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      if (failIfMissing != null) "failIfMissing": failIfMissing,
      if (columns != null) "columns": columns,
    };
  }
}

class XataGetOp extends XataOperationBase {
  String id;
  XataGetOp({required this.id, super.columns});
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      if (columns != null) "columns": columns,
    };
  }
}

class XataOperation {
  XataInsertOp? insert;
  XataUpdateOp? update;
  XataDeleteOp? delete;
  XataGetOp? get;
  XataOperation({this.insert, this.update, this.delete, this.get}) {
    final thisTransaction = [insert, update, delete, get].where((element) => element != null).toList();
    if (thisTransaction.length > 1) throw Exception("One operation must be used in a transaction, no more, no less");
    if (thisTransaction.isEmpty) throw Exception("One operation must be used in a transaction, no more, no less");
  }
  Map<String, dynamic> toMap(String table) {
    if (insert != null) {
      return {
        "insert": {"table": table, ...insert!.toMap()}
      };
    }
    if (update != null) {
      return {
        "update": {"table": table, ...update!.toMap()}
      };
    }
    if (delete != null) {
      return {
        "delete": {"table": table, ...delete!.toMap()}
      };
    }
    if (get != null) {
      return {
        "get": {"table": table, ...get!.toMap()}
      };
    }
    return {};
  }
}

class XataBranchTransaction {
  List<XataOperation> operations;
  XataBranchTransaction(this.operations);
}

class XataOperationResult<R extends XataRecord> {
  String operation;
  String? id;
  int? rows;
  R? columns;
  XataOperationResult.fromMap(Map<String, dynamic> map, Model<R> model)
      : operation = map['operation'] ?? "",
        id = map['id'] ?? "",
        rows = map['rows'] ?? 0,
        columns = map['columns'] == null ? null : model(map['columns']);

  toMap() {
    return {
      "operation": operation,
      "id": id,
      "rows": rows,
      "columns": columns?.toMap(),
    };
  }
}

class Records<R extends XataRecord> extends XataSubClient {
  late Model<R> model;
  Records(super.config) {
    if (config.workspace == null) {
      throw Exception("Workspace must be set before accessing a record");
    }
    if (config.region == null) {
      throw Exception("Region must be set before accessing a record");
    }
    if (config.database == null) {
      throw Exception("Database must be set before accessing a record");
    }
    if (config.branch == null) {
      throw Exception("Branch must be set before accessing a record");
    }
    if (config.table == null) {
      throw Exception("Table must be set before accessing a record");
    }
    if (config.model == null) {
      throw Exception("Model must be set before accessing a record");
    }
    model = config.model! as Model<R>;
  }

  /// Execute a transactions
  /// i.e. a list of operations that are executed in a transaction
  Future<List<XataOperationResult<R>>> transaction(List<XataOperation> transaction) async {
    http.Response response = await http.post(
      Uri.parse("$branchURL/transaction"),
      headers: {...authHeader(config.key)},
      body: jsonEncode({"operations": transaction.map((e) => e.toMap(config.table!)).toList()}),
    );
    statusCodeCheck(response);
    return List<Map<String, dynamic>>.from(resMap(response.body)['results'])
        .map((e) => XataOperationResult<R>.fromMap(e, model))
        .toList();
  }

  /// Get a record by id
  /// You can also pass a list of columns to get
  Future<R> get(String id, [List<String>? columns]) async {
    return (await transaction([
      XataOperation(
        get: XataGetOp(id: id, columns: columns),
      )
    ]))
        .first
        .columns!;
  }

  /// Insert a record if it doesn't exist (create only)
  Future<String> insert(R record) async {
    return (await transaction([
      XataOperation(
        insert: XataInsertOp(record: record),
      )
    ]))
        .first
        .id!;
  }

  /// Insert a record if it doesn't exist, update it if it does
  Future<R> upsert(R record) async {
    return (await transaction([
      XataOperation(
        update: XataUpdateOp(id: record.id, fields: record, upsert: true),
      )
    ]))
        .first
        .columns!;
  }

  /// Update a record if it exists
  Future<Object> update(String id, R record) async {
    return (await transaction([
      XataOperation(
        update: XataUpdateOp(id: id, fields: record, upsert: false),
      )
    ]))
        .first
        .columns!;
  }

  /// Delete a record if it exists
  Future<void> delete(String id) async {
    await transaction([
      XataOperation(
        delete: XataDeleteOp(id: id),
      )
    ]);
  }

  /// Bulk insert records (create only)
  Future<List<String>> bulkInsert(List<R> records) async {
    return (await transaction(
      records.map((r) => XataOperation(insert: XataInsertOp(record: r, createOnly: true))).toList(),
    ))
        .map((e) => e.id!)
        .toList();
  }

  /// Bulk upsert records (insert if it doesn't exist, update if it does)
  Future<List<R>> bulkUpsert(List<R> records) async {
    return (await transaction(
      records.map((r) => XataOperation(update: XataUpdateOp(id: r.id, fields: r, upsert: true))).toList(),
    ))
        .map((e) => e.columns!)
        .toList();
  }

  Future<List<R>> query() async {
    throw UnimplementedError();
  }
}
