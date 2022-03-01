// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class CreateMeetingData extends MeetingBaseData{
  CreateMeetingData(String nick, bool muteVideo, bool muteAudio, String meetingId) : super(TCProtocol
      .createMeeting2TV, 0, nick, muteVideo, muteAudio, meetingId);
}
