import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../lib/models/user.dart';
import '../lib/repository/user_repository.dart';

/// 数据库管理
/// Date: 2018-08-03

class SqlManager {
  static const _VERSION = 2;

  static const _NAME = "imath.db";

  static Database? _database;

  ///初始化
  static init() async {
    // open the database
    var databasesPath = await getDatabasesPath();
    var userRes = await UserRepository.getUserInfoLocal();
    String dbName = _NAME;
    if (userRes != null && userRes.result) {
      User? user = userRes.data;
      if (user != null && user.login != null) {
        dbName = "${user.login!}_$_NAME";
      }
    }
    String path = databasesPath + dbName;
    if (Platform.isIOS) {
      path = "$databasesPath/$dbName";
    }
    _database = await openDatabase(path, version: _VERSION,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      //await db.execute("CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)");
    });
  }

  /// 表是否存在
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database?.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.isNotEmpty;
  }

  ///获取当前数据库对象
  static Future<Database?> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }
}
