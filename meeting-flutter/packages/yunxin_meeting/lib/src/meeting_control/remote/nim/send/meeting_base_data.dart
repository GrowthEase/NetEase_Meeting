// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class MeetingBaseData extends BaseData {
  String nick;
  bool muteVideo;
  bool muteAudio;
  String meetingId;
  String? password;

  MeetingBaseData(int type, int requestId, this.nick, this.muteVideo, this.muteAudio,
      this.meetingId, {this.password}) : super(type, requestId);

  @override
  Map toData() => {
        'requestId': requestId,
        'nickName': nick,
        'video': muteVideo,
        'audio': muteAudio,
        'meetingId': meetingId,
        'password': password ?? '',
      };
}
