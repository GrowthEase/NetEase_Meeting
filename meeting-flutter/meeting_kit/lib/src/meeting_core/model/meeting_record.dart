// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class NEMeetingRecordFileInfo {
  final String type;
  final bool mix;
  final String filename;
  final String md5;
  final int size;
  final String url;
  final int vid;
  final int pieceIndex;
  final String? userUuid;
  final String? nickname;

  NEMeetingRecordFileInfo({
    required this.type,
    required this.mix,
    required this.filename,
    required this.md5,
    required this.size,
    required this.url,
    required this.vid,
    required this.pieceIndex,
    this.userUuid,
    this.nickname,
  });

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['type'] = type;
    map['mix'] = mix;
    map['filename'] = filename;
    map['md5'] = md5;
    map['size'] = size;
    map['url'] = url;
    map['vid'] = vid;
    map['pieceIndex'] = pieceIndex;
    map['userUuid'] = userUuid;
    map['nickname'] = nickname;
    return map;
  }
}

class NEMeetingRecord {
  final String recordId;
  final int recordStartTime;
  final int recordEndTime;
  final List<NEMeetingRecordFileInfo> infoList;

  NEMeetingRecord({
    required this.recordId,
    required this.recordStartTime,
    required this.recordEndTime,
    required this.infoList,
  });

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['recordId'] = recordId;
    map['recordStartTime'] = recordStartTime;
    map['recordEndTime'] = recordEndTime;
    map['infoList'] = infoList.map((e) => e.toJson()).toList();
    return map;
  }
}
