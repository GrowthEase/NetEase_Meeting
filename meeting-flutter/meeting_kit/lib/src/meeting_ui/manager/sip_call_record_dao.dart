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
  final _tableName = _DatabaseHelper().callRecordsTableName;

  Future<void> close() async {
    await _DatabaseHelper().close();
  }

  Future<void> addCallRecord(NESipCallRecord record) async {
    await _DatabaseHelper().insert(_tableName, record.toMap());

    /// 只保留最新的100条
    final List<Map<String, dynamic>> maps =
        await _DatabaseHelper().query(_tableName);
    if (maps.length > 100) {
      await _DatabaseHelper().delete(_tableName, maps.first['id']);
    }
  }

  Future<List<NESipCallRecord>> getAllCallRecords() async {
    final List<Map<String, dynamic>> maps =
        await _DatabaseHelper().query(_tableName);
    return List.generate(maps.length, (i) {
      return NESipCallRecord(
        id: maps[i]['id'],
        name: maps[i]['name'],
        number: maps[i]['number'],
      );
    });
  }

  Future<void> clearCallRecords() async {
    await _DatabaseHelper().deleteAll(_tableName);
  }

  Future<void> deleteCallRecord(int? id) async {
    if (id == null) return;
    await _DatabaseHelper().delete(_tableName, id);
  }
}
