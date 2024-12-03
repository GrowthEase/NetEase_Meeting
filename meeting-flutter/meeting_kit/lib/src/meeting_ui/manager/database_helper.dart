// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class _DatabaseHelper {
  static final _DatabaseHelper _instance = _DatabaseHelper.internal();
  factory _DatabaseHelper() => _instance;
  static Database? _db;

  _DatabaseHelper.internal();

  final callRecordsTableName = 'CallRecords';
  final callOutRoomRecordsTableName = 'CallOutRoomRecords';

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    final accountInfo = AccountRepository().getAccountInfo();
    _db = await initDb('${accountInfo?.userUuid}');
    return _db!;
  }

  Future<Database> initDb(String dbName) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = path.join(databasesPath, '$dbName.db');
    var theDb = await openDatabase(dbPath,
        version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  Future<void> _onCreate(Database db, int version) {
    return _createTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
    return _createTable(db);
  }

  Future<void> _createTable(Database db) async {
    await db.execute(
      "CREATE TABLE IF NOT EXISTS $callRecordsTableName (id INTEGER PRIMARY KEY, name TEXT, number TEXT)",
    );
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $callOutRoomRecordsTableName (id INTEGER PRIMARY KEY, name TEXT, deviceAddress TEXT, protocol INTEGER)');
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    final dbClient = await db;
    return await dbClient.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> row) async {
    final dbClient = await db;
    return await dbClient
        .update(table, row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> delete(String table, int id) async {
    final dbClient = await db;
    return await dbClient.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll(String table) async {
    final dbClient = await db;
    return await dbClient.delete(table);
  }

  Future close() async {
    _db?.close();
    _db = null;
  }
}
