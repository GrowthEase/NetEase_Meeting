// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class JoinMeetingData extends MeetingBaseData{
  JoinMeetingData(int requestId, String nick, bool muteVideo, bool muteAudio, String meetingId,  {String? password}) :
        super(TCProtocol.joinMeeting2TV, requestId, nick, muteVideo, muteAudio, meetingId, password: password);
}
