import 'package:test/test.dart';
import 'package:xata_dart/common.dart';
import 'package:http/http.dart' as http;

void main() {
  group('common', () {
    test('authHeader', () {
      expect(authHeader("key"), {"Authorization": "Bearer key"});
    });
    test("successStatusCode", () {
      expect(successStatusCode(0), false);
      expect(successStatusCode(199), false);
      expect(successStatusCode(200), true);
      expect(successStatusCode(299), true);
      expect(successStatusCode(300), false);
      expect(successStatusCode(399), false);
      expect(successStatusCode(400), false);
      expect(successStatusCode(499), false);
      expect(successStatusCode(500), false);
      expect(successStatusCode(599), false);
    });
    test("statusCodeCheck", () {
      expect(() => statusCodeCheck(http.Response("", 199)), throwsException);
      expect(() => statusCodeCheck(http.Response("", 200)), returnsNormally);
      expect(() => statusCodeCheck(http.Response("", 299)), returnsNormally);
      expect(() => statusCodeCheck(http.Response("", 300)), throwsException);
      expect(() => statusCodeCheck(http.Response("", 399)), throwsException);
      expect(() => statusCodeCheck(http.Response("", 400)), throwsException);
      expect(() => statusCodeCheck(http.Response("", 499)), throwsException);
      expect(() => statusCodeCheck(http.Response("", 500)), throwsException);
      expect(() => statusCodeCheck(http.Response("", 599)), throwsException);
    });
    test("resMap", () {
      expect(resMap("""{"a": "b"}""")["a"], "b");
      expect(() => resMap("""any-string"""), throwsException);
    });
  });
}
