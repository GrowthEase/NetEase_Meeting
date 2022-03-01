// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class LeaveMeetingData extends BaseData{

  int reason;

  LeaveMeetingData(this.reason) : super(TCProtocol.leaveMeeting, 0);

  @override
  Map toData() {
    return {
      'reason': reason,
    };
  }

}