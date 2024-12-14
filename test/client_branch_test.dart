import 'package:test/test.dart';
import 'package:xata_dart/main.dart';
import 'secret_testing_key.dart';

void main() {
  group("Branches client", () {
    final xata = Xata(key: secretKey);
    setUpAll(() async {
      final ws = await xata.workspaces.create("test-workspace");
      xata.inWorkspace(ws.id);
      xata.inRegion((await xata.databases.listRegions()).first.id);
      await xata.databases.create("testing-database");
      xata.inDatabase("testing-database");
    });

    test("list", () async {
      final branches = await xata.branches.list();
      expect(branches.isNotEmpty, true);
      expect(branches.length, 1);
    });

    test("get", () async {
      final branch = await xata.branches.get("main");
      expect(branch.branchName, "main");
    });

    test("create", () async {
      await xata.branches.create("test-branch");
      await Future.delayed(Duration(milliseconds: 500));
      final branch = await xata.branches.get("test-branch");
      expect(branch.branchName, "test-branch");
      expect((await xata.branches.list()).length, 2);
    });

    test("delete", () async {
      await xata.branches.delete("test-branch");
      expect((await xata.branches.list()).length, 1);
    });

    test("createSync", () async {
      await xata.branches.createSync("test-branch-sync");
      final branch = await xata.branches.get("test-branch-sync");
      expect(branch.branchName, "test-branch-sync");
      expect((await xata.branches.list()).length, 2);
    });

    test("delete after sync", () async {
      await xata.branches.delete("test-branch-sync");
      expect((await xata.branches.list()).length, 1);
    });

    test("metadata", () async {
      await xata.branches
          .updateMetadata(XataBranchMetadata(branch: "main", repository: "https://github.com/alselawi/xata-dart"));
      final branch = await xata.branches.getMetadata("main");
      expect(branch.repository, "https://github.com/alselawi/xata-dart");
    });

    test("create with metadata", () async {
      await xata.branches.createSync("test-branch-metadata", null,
          XataBranchMetadata(branch: "test-branch-metadata", repository: "https://github.com/alselawi/xata-dart"));
      final branch = await xata.branches.get("test-branch-metadata");
      expect(branch.branchName, "test-branch-metadata");
      final metadata = await xata.branches.getMetadata("test-branch-metadata");
      expect(metadata.repository, "https://github.com/alselawi/xata-dart");
    });

    tearDownAll(() async {
      await xata.workspaces.delete(xata.config.workspace!);
    });
  });
}
