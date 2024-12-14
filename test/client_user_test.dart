import 'package:test/test.dart';
import 'package:xata_dart/main.dart';
import 'secret_testing_key.dart';

void main() {
  group("User client", () {
    final xata = Xata(key: secretKey);
    test("get", () async {
      final user = await xata.user.get();
      expect(user.email.endsWith(".com"), true);
    });
    test("update", () async {
      final userA = XataUser(fullname: "alex");
      await xata.user.update(userA);
      expect((await xata.user.get()).fullname, "alex");

      final userB = XataUser(fullname: "ali");
      await xata.user.update(userB);
      expect((await xata.user.get()).fullname, "ali");
    });
  });
}
