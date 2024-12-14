import 'package:test/test.dart';
import 'package:xata_dart/main.dart';
import 'secret_testing_key.dart';

void main() {
  group("Table client", () {
    final xata = Xata(key: secretKey);

    setUpAll(() async {
      final ws = await xata.workspaces.create("test-workspace");
      xata.inWorkspace(ws.id);
      xata.inRegion((await xata.databases.listRegions()).first.id);
      await xata.databases.create("testing-database");
      xata.inDatabase("testing-database");
      xata.inBranch("main");
    });

    test("create", () async {
      final table = await xata.table.create("test-table");
      expect(table.tableName, "test-table");
      expect(table.branchName, "testing-database:main");
      expect(table.status, "completed");
    });
    test("Get schema", () async {
      final schema = await xata.table.getSchema("test-table");
      expect(schema.length, 0);
    });
    test("Update schema", () async {
      await xata.table.create("link-table");
      final schema = await xata.table.updateSchema("test-table", [
        XataColumn(name: "identifier", type: XataColumnType.string, unique: true, primary: true),
        XataColumn(name: "name", type: XataColumnType.text),
        XataColumn(name: "age", type: XataColumnType.int),
        XataColumn(name: "address", type: XataColumnType.json),
        XataColumn(name: "hasChildren", type: XataColumnType.bool),
        XataColumn(name: "createdAt", type: XataColumnType.datetime),
        XataColumn(name: "email", type: XataColumnType.email),
        XataColumn(name: "file", type: XataColumnType.file),
        XataColumn(name: "fileArr", type: XataColumnType.fileArr),
        XataColumn(name: "float", type: XataColumnType.float),
        XataColumn(name: "multiple", type: XataColumnType.multiple),
        XataColumn(name: "vector", type: XataColumnType.vector, vector: XataColumnVector(dimension: 256)),
        XataColumn(name: "link", type: XataColumnType.link, link: XataColumnLink(table: "link-table")),
        XataColumn(name: "object", type: XataColumnType.object, columns: [
          XataColumn(name: "name", type: XataColumnType.string),
          XataColumn(name: "age", type: XataColumnType.int),
        ])

        // TODO: identifier?? should it be id? should it be primary? how to create an indx on it?
        // TODO: also we should be able to list tables somehow?!!!
      ]);
      expect(schema.status, "completed");

      final schema2 = await xata.table.getSchema("test-table");
      schema2.map((s) => s.toMap()).forEach(print);
      expect(schema2.length, 11); // TODO: might need to modify this  number
    });
    test("rename", () async {
      final table2 = await xata.table.rename("test-table", "test-table-2");
      expect(table2.status, "completed");
    });
    test("delete", () async {
      await xata.table.delete("test-table-2");
    });

    tearDownAll(() async {
      await xata.workspaces.delete(xata.config.workspace!);
    });
  });
}
