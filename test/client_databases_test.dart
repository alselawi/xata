import 'package:test/test.dart';
import 'package:xata_dart/main.dart';
import 'secret_testing_key.dart';

void main() {
  group("Workspaces client", () {
    final xata = Xata(key: secretKey);
    String region = "";

    setUpAll(() async {
      final ws = await xata.workspaces.create("test-workspace");
      xata.inWorkspace(ws.id);
    });

    test("listRegions", () async {
      final regions = await xata.databases.listRegions();
      expect(regions.isNotEmpty, true);
      region = regions.first.id;
    });
    test("create", () async {
      xata.inRegion(region);
      final db = await xata.databases.create("test-database");
      expect(db.databaseName, "test-database");
    });
    test("list", () async {
      final dbs = await xata.databases.list();
      expect(dbs.isNotEmpty, true);
      expect(dbs.where((db) => db.name == "test-database").length, 1);
    });
    test("get", () async {
      final db = await xata.databases.get("test-database");
      expect(db.name, "test-database");
    });
    test("getSettings", () async {
      final settings = await xata.databases.getSettings("test-database");
      expect(settings.searchEnabled, true);
    });
    test("updateSettings", () async {
      await xata.databases.updateSettings("test-database", XataDatabaseSettings(searchEnabled: true));
      final settings = await xata.databases.getSettings("test-database");
      expect(settings.searchEnabled, true);
    });
    test("rename", () async {
      await xata.databases.rename("test-database", "test-database-renamed");
      final db = await xata.databases.get("test-database-renamed");
      expect(db.name, "test-database-renamed");
    });
    test("delete", () async {
      await xata.databases.delete("test-database-renamed");
      expect(
          await xata.databases.list().then((dbs) => dbs.where((db) => db.name == "test-database-renamed").length), 0);
    });

    tearDownAll(() {
      xata.workspaces.delete(xata.config.workspace!);
    });
  });
}
