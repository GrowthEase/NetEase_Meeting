// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class NESipCallRecord {
  int? id;
  String name;
  String number;

  NESipCallRecord({this.id, required this.name, required this.number});

  toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
    };
  }
}

class NESipCallRecordsSQLManager {
  late Database _database;

  Future<void> initializeDatabase(String userUuid) async {
    final databasesPath = await getDatabasesPath();
    _database = await openDatabase(
      '$databasesPath/$userUuid.db',
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE CallRecords(id INTEGER PRIMARY KEY, name TEXT, number TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> close() async {
    await _database.close();
  }

  Future<void> addCallRecord(NESipCallRecord record) async {
    await _database.insert('CallRecords', record.toMap());

    /// 只保留最新的100条
    final List<Map<String, dynamic>> maps =
        await _database.query('CallRecords');
    if (maps.length > 100) {
      await _database.delete('CallRecords',
          where: 'id = ?', whereArgs: [maps.first['id']]);
    }
  }

  Future<List<NESipCallRecord>> getAllCallRecords() async {
    final List<Map<String, dynamic>> maps =
        await _database.query('CallRecords');
    return List.generate(maps.length, (i) {
      return NESipCallRecord(
        id: maps[i]['id'],
        name: maps[i]['name'],
        number: maps[i]['number'],
      );
    });
  }

  Future<void> clearCallRecords() async {
    await _database.delete('CallRecords');
  }

  Future<void> deleteCallRecord(int? id) async {
    await _database.delete('CallRecords', where: 'id = ?', whereArgs: [id]);
  }
}
