import 'dart:convert';
import 'package:http/http.dart' as http;

class XataAutoData {
  int version;
  DateTime createdAt;
  DateTime updatedAt;
  XataAutoData.fromMap(Map<String, dynamic> map)
      : version = map['version'] ?? 0,
        createdAt = DateTime.parse(map['createdAt'] ?? ""),
        updatedAt = DateTime.parse(map['updatedAt'] ?? "");
  Map<String, dynamic> toMap() {
    return {
      "version": version,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

abstract class XataRecord {
  String id;
  XataAutoData xata;
  XataRecord.fromMap(Map<String, dynamic> map)
      : id = map['id'] ?? "",
        xata = XataAutoData.fromMap(map['xata'] ?? {});
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "xata": xata.toMap(),
    };
  }
}

typedef Model<R extends XataRecord> = R Function(Map<String, dynamic> map);

class RequestConfiguration<R extends XataRecord> {
  String? key;
  String? region;
  String? workspace;
  String? database;
  String? branch;
  String? table;
  String? column;
  String? record;
  String? file;
  Model<R>? model;
  RequestConfiguration({
    this.key,
    this.region,
    this.workspace,
    this.database,
    this.branch,
    this.table,
    this.column,
    this.record,
    this.file,
    this.model,
  });
}

abstract class XataSubClient {
  final RequestConfiguration config;
  final topLevelURL = "https://api.xata.io";
  String get dbURL {
    if (config.workspace == null) {
      throw Exception("Workspace must be set before accessing database");
    }
    if (config.region == null) {
      throw Exception("Region must be set before accessing database");
    }
    if (config.database == null) {
      throw Exception("Database must be set before accessing database");
    }
    return "https://${config.workspace}.${config.region}.xata.sh/dbs/${config.database}";
  }

  String get branchURL {
    if (config.workspace == null) {
      throw Exception("Workspace must be set before accessing database and branch");
    }
    if (config.region == null) {
      throw Exception("Region must be set before accessing database and branch");
    }
    if (config.database == null) {
      throw Exception("Database must be set before accessing database and branch");
    }
    if (config.branch == null) {
      throw Exception("Branch must be set before accessing database and branch");
    }
    return "https://${config.workspace}.${config.region}.xata.sh/db/${config.database}:${config.branch}";
  }

  XataSubClient(this.config);
}

bool successStatusCode(int statusCode) {
  return statusCode >= 200 && statusCode < 300;
}

void statusCodeCheck(http.Response response) {
  if (!successStatusCode(response.statusCode)) {
    throw Exception("Xata API error: ${response.statusCode}: ${response.reasonPhrase} : ${response.body}");
  }
}

Map<String, dynamic> resMap(String input) {
  try {
    return jsonDecode(input);
  } catch (e) {
    throw Exception("Xata API didn't respond with JSON: $input");
  }
}

Map<String, String> authHeader(String? key) {
  if (key == null) {
    throw Exception("Xata API key not set");
  }
  return {'Authorization': 'Bearer $key', "content-type": "application/json"};
}
