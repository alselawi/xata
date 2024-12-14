import 'package:test/test.dart';
import 'package:xata_dart/main.dart';
import 'secret_testing_key.dart';

void main() {
  group("Workspaces client", () {
    final xata = Xata(key: secretKey);
    String createdID = "";
    test("create", () async {
      final workspace = await xata.workspaces.create("test");
      createdID = workspace.id;
      expect(workspace.id.isNotEmpty, true);
      expect(workspace.name, "test");
      expect(workspace.slug, "test");
      expect(workspace.plan, "free");
      expect(workspace.free, true);
      expect(workspace.paid, false);
      expect(workspace.memberCount, 1);
    });
    test("get", () async {
      final workspace = await xata.workspaces.get(createdID);
      expect(workspace.id.isNotEmpty, true);
      expect(workspace.name, "test");
      expect(workspace.slug, "test");
      expect(workspace.plan, "free");
      expect(workspace.free, true);
      expect(workspace.paid, false);
      expect(workspace.memberCount, 1);
    });
    test("list", () async {
      final workspaces = await xata.workspaces.list();
      expect(workspaces.where((w) => w.name == "test").length, 1);
    });
    test("rename", () async {
      await xata.workspaces.rename(createdID, "test2");
      final workspace = await xata.workspaces.get(createdID);
      expect(workspace.id.isNotEmpty, true);
    });
    test("delete", () async {
      await xata.workspaces.delete(createdID);
      expect((await xata.workspaces.list()).where((w) => w.name == "test2").length, 0);
    });
  });
}
