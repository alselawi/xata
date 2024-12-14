import 'package:xata_dart/client_branches.dart';
import 'package:xata_dart/client_column.dart';
import 'package:xata_dart/client_databases.dart';
import 'package:xata_dart/client_records.dart';
import 'package:xata_dart/client_table.dart';
import 'package:xata_dart/client_workspaces.dart';
import 'package:xata_dart/common.dart';
import 'package:xata_dart/client_keys.dart';
import 'package:xata_dart/client_user.dart';

class Xata<R extends XataRecord> {
  // configuration
  RequestConfiguration config;

  // clients

  /// ### User client
  /// ##### Required Configuration: key
  /// Concerning the user of the API key you're using to authenticate this request
  User get user => User(config);

  /// ### Keys client
  /// #### Required Configuration: key
  /// Concerning API keys (including the one you used to authenticate this request)
  Keys get keys => Keys(config);

  /// ### Workspaces client
  /// ##### Required Configuration: key
  /// Concerning workspaces and their members
  Workspaces get workspaces => Workspaces(config);

  /// ### Databases client
  /// ##### Required Configuration: key, workspace, and region if you're creating a new database
  /// Concerning databases and their management
  Databases get databases => Databases(config);

  /// ### Branches client
  /// ###### Required Configuration: key, workspace, region, and database
  /// Concerning branches and their management
  Branches get branches => Branches(config);

  /// ### Table client
  /// ###### Required Configuration: key, workspace, region, database, and branch
  /// Concerning tables and their management
  Table get table => Table(config);

  /// ### Column client
  /// ###### Required Configuration: key, workspace, region, database, branch, and table
  /// Concerning columns and their management
  Column get column => Column(config);

  /// ### Records client
  /// ##### Required Configuration: key, workspace, region, database, branch, and table
  /// For executing queries and managing records
  Records<R> get records => Records<R>(config);

  // helper methods to set configuration
  Xata withKey(String key) => this..config.key = key;
  Xata inRegion(String region) => this..config.region = region;
  Xata inWorkspace(String workspace) => this..config.workspace = workspace;
  Xata inDatabase(String database) => this..config.database = database;
  Xata inBranch(String branch) => this..config.branch = branch;
  Xata inTable(String table) => this..config.table = table;
  Xata inColumn(String column) => this..config.column = column;
  Xata inRecord(String record) => this..config.record = record;
  Xata inFile(String file) => this..config.file = file;
  Xata withModel(Model<R> model) => this..config.model = model;

  Xata({
    required String key,
    String? region,
    String? workspace,
    String? database,
    String? branch,
    String? table,
    String? column,
    String? record,
    String? file,
    Model<R>? model,
  }) : config = RequestConfiguration(
          key: key,
          region: region,
          workspace: workspace,
          database: database,
          branch: branch,
          table: table,
          column: column,
          record: record,
          file: file,
          model: model,
        );
}
