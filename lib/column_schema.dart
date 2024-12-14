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

class XataColumnLink {
  String table;
  XataColumnLink({required this.table});
  XataColumnLink.fromMap(Map<String, dynamic> map) : table = map['table'] ?? "";
}

class XataColumnVector {
  int dimension;
  XataColumnVector({required this.dimension});
  XataColumnVector.fromMap(Map<String, dynamic> map) : dimension = map['dimension'] ?? 0;
}

class XataColumnFile {
  bool defaultPublicAccess;
  XataColumnFile.fromMap(Map<String, dynamic> map) : defaultPublicAccess = map['defaultPublicAccess'] ?? false;
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
  bool? primary;
  List<XataColumn>? columns;

  XataColumn({
    required this.name,
    required this.type,
    this.link,
    this.vector,
    this.file,
    this.fileArr,
    this.notNull,
    this.defaultValue,
    this.unique,
    this.primary,
    this.columns,
  });

  XataColumn.fromMap(Map<String, dynamic> map)
      : name = map['name'] ?? "",
        type = XataColumnType.values
            .firstWhere((element) => element.type == (map['type'] ?? ""), orElse: () => XataColumnType.string),
        link = map['link'] != null ? XataColumnLink.fromMap(map['link']) : null,
        vector = map['vector'] != null ? XataColumnVector.fromMap(map['vector']) : null,
        file = map['file'] != null ? XataColumnFile.fromMap(map['file']) : null,
        fileArr = map['file[]'] != null ? XataColumnFile.fromMap(map['file[]']) : null,
        notNull = map['notNull'] ?? false,
        defaultValue = map['defaultValue'] ?? "",
        primary = map['primary'] ?? false,
        unique = map['unique'] ?? false,
        columns =
            map['columns'] != null ? List<XataColumn>.from(map['columns'].map((e) => XataColumn.fromMap(e))) : null;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "name": name,
      "type": type.type,
      "notNull": notNull,
      "defaultValue": defaultValue,
      "unique": unique,
    };
    if (link != null) {
      map["link"] = {"table": link!.table};
    }
    if (vector != null) {
      map["vector"] = {"dimension": vector!.dimension};
    }
    if (file != null) {
      map["file"] = {"defaultPublicAccess": file!.defaultPublicAccess};
    }
    if (fileArr != null) {
      map["file[]"] = {"defaultPublicAccess": fileArr!.defaultPublicAccess};
    }
    if (columns != null) {
      map["columns"] = columns!.map((e) => e.toMap()).toList();
    }
    return map;
  }
}
