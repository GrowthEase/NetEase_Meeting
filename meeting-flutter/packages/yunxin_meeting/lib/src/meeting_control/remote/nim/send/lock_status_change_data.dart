// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class LockStatusChangeData extends BaseData{
  /// int,1:允许所有人加入,2:不允许任何加入
  int joinControlType;

  LockStatusChangeData(this.joinControlType) : super(TCProtocol.meetingLock, 0);

  @override
  Map toData() {
    return {
      'joinControlType': joinControlType,
    };
  }

}