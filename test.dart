import 'package:xata_dart/common.dart';
import 'package:xata_dart/main.dart';

import 'test/secret_testing_key.dart';

class MyModel extends XataRecord {
  dynamic json;
  MyModel.fromMap(Map<String, dynamic> map)
      : json = map['json'] ?? "",
        super.fromMap(map);
  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "json": json,
    };
  }
}

void main() async {
  final xata = Xata<MyModel>(key: secretKey);
  xata.inWorkspace("Ali-Saleem-s-workspace-fddo4q");
  xata.inRegion("us-east-1");
  xata.inDatabase("ndb");
  xata.inBranch("main");
  xata.inTable("anothertable");
  xata.withModel(MyModel.fromMap);

  final res = await (xata).records.transaction([
    XataOperation(get: XataGetOp(id: "rec_cs4c2d0hn78847taqjlg", columns: ["json", "something"]))
  ]);

  print(await xata.records.get("rec_cs4c2d0hn78847taqjlg"));
}
