import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestConfiguration {
  String? key;
  String? region;
  String? workspace;
  String? database;
  String? branch;
  String? table;
  String? column;
  String? record;
  String? file;
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
    return "https://${config.workspace}.${config.region}.xata.sh/dbs/${config.database}/";
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
    return "https://${config.workspace}.${config.region}.xata.sh/db/${config.database}:${config.branch}/";
  }

  XataSubClient(this.config);
}

successStatusCode(int statusCode) {
  return statusCode >= 200 && statusCode < 300;
}

statusCodeCheck(http.Response response) {
  if (successStatusCode(response.statusCode)) {
    throw Exception("Xata API error: ${response.statusCode}: ${response.body}");
  }
}

Map<String, dynamic> decode(String input) {
  try {
    return jsonDecode(input);
  } catch (e) {
    throw Exception("Xata API didn't respond with JSON: $input");
  }
}

authHeader(String? key) {
  if (key == null) {
    throw Exception("Xata API key not set");
  }
  return {'Authorization': 'Bearer $key'};
}
