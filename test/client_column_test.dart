import 'package:test/test.dart';
import 'package:xata_dart/main.dart';
import 'secret_testing_key.dart';

void main() {
  group("Column client", () {
    final xata = Xata(key: secretKey);

    setUpAll(() async {
      final ws = await xata.workspaces.create("test-workspace");
      xata.inWorkspace(ws.id);
      xata.inRegion((await xata.databases.listRegions()).first.id);
      await xata.databases.create("testing-database");
      xata.inDatabase("testing-database");
      xata.inBranch("main");
      await xata.table.create("my-table");
      xata.inTable("my-table");
    });

    test("create column", () async {
      await xata.column.create(XataColumn(name: "name", type: XataColumnType.text));
      await xata.column.create(XataColumn(name: "age", type: XataColumnType.int));
      await xata.column.create(XataColumn(name: "is_active", type: XataColumnType.bool));
      await xata.column.create(XataColumn(name: "updated_at", type: XataColumnType.datetime));
    });
    test("get column", () async {
      final name = await xata.column.get("name");
      expect(name.name, "name");
      expect(name.type, XataColumnType.text);
      final age = await xata.column.get("age");
      expect(age.name, "age");
      expect(age.type, XataColumnType.int);
      final isActive = await xata.column.get("is_active");
      expect(isActive.name, "is_active");
      expect(isActive.type, XataColumnType.bool);
      final updatedAt = await xata.column.get("updated_at");
      expect(updatedAt.name, "updated_at");
      expect(updatedAt.type, XataColumnType.datetime);
    });
    test("rename column", () async {
      await xata.column.rename("name", "fullname");
      expect(() async => xata.column.get("name"), throwsException);
      final fullname = await xata.column.get("fullname");
      expect(fullname.name, "fullname");
      expect(fullname.type, XataColumnType.text);
    });
    test("delete column", () async {
      await xata.column.delete("fullname");
      expect(() async => xata.column.get("fullname"), throwsException);
    });
    // TODO: list columns???
    // TODO: update column schema??
    tearDownAll(() async {
      await xata.workspaces.delete(xata.config.workspace!);
    });
  });
}
