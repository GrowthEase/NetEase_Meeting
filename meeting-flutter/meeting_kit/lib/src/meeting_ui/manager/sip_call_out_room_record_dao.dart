// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class _SipCallOutRoomRecord extends NERoomSystemDevice {
  int? id;

  _SipCallOutRoomRecord(
      {this.id,
      required super.name,
      required super.deviceAddress,
      required super.protocol});

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'deviceAddress': deviceAddress,
      'protocol': protocol.value,
    };
  }

  factory _SipCallOutRoomRecord.fromMap(Map json) {
    return _SipCallOutRoomRecord(
      id: json['id'] as int?,
      name: json['name'] as String?,
      deviceAddress: json['deviceAddress'] as String? ?? '',
      protocol: NERoomSipDeviceInviteProtocolTypeExtension.type(
          json['protocol'] as int?),
    );
  }
}

/// 会议室呼叫记录
class _SipCallOutRoomRecordsSQLManager {
  final _tableName = _DatabaseHelper().callOutRoomRecordsTableName;

  Future<void> close() async {
    await _DatabaseHelper().close();
  }

  Future<void> addCallOutRoomRecord(_SipCallOutRoomRecord record) async {
    await _DatabaseHelper().insert(_tableName, record.toMap());

    /// 只保留最新的10条
    final List<Map<String, dynamic>> maps =
        await _DatabaseHelper().query(_tableName);
    if (maps.length > 10) {
      await _DatabaseHelper().delete(_tableName, maps.first['id']);
    }
  }

  Future<List<_SipCallOutRoomRecord>> getAllCallOutRoomRecords() async {
    final List<Map<String, dynamic>> maps =
        await _DatabaseHelper().query(_tableName);
    return List.generate(maps.length, (i) {
      return _SipCallOutRoomRecord.fromMap(maps[i]);
    });
  }

  Future<void> clearCallOutRoomRecords() async {
    await _DatabaseHelper().deleteAll(_tableName);
  }

  Future<void> deleteCallOutRoomRecord(int? id) async {
    if (id == null) return;
    await _DatabaseHelper().delete(_tableName, id);
  }
}
