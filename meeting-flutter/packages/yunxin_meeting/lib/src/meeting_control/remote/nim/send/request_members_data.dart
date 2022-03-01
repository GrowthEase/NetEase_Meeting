// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class RequestMembersData extends BaseData{
  int? avRoomUid;
  RequestMembersData(int requestId, this.avRoomUid) : super(TCProtocol.fetchMemberInfo2TV, requestId);

  @override
  Map toData() {
    return {
      'requestId': requestId,
      'avRoomUid': avRoomUid,
    };
  }

}