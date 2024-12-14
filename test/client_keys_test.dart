import 'package:test/test.dart';
import 'package:xata_dart/main.dart';
import 'secret_testing_key.dart';

void main() {
  group("Keys client", () {
    final xata = Xata(key: secretKey);
    test("list", () async {
      final listOfKeys = await xata.keys.list();
      expect(listOfKeys.isEmpty, false);
    });

    test("create", () async {
      await xata.keys.create("test-key");
      final listOfKeys = await xata.keys.list();
      expect(listOfKeys.where((key) => key.name == "test-key").length, 1);
    });

    test("delete", () async {
      await xata.keys.delete("test-key");
      final listOfKeys = await xata.keys.list();
      expect(listOfKeys.where((key) => key.name == "test-key").length, 0);
    });
  });
}
