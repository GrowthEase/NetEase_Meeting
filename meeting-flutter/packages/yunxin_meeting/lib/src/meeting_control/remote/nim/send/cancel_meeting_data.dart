// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class CancelMeetingData extends BaseData{
  int action;
  String meetingId;

  CancelMeetingData(this.action, this.meetingId) : super(TCProtocol.cancel2TV, 0);

  @override
  Map toData() => {'action' : action, 'meetingId': meetingId};
}
