// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class InMeetingRepository {
  static Future<NEResult<void>> invite(
      String roomId, NERoomInvitation invitation) {
    return HttpApiHelper.execute(_RoomInvitationApi(roomId, invitation));
  }

  static Future<NEResult<List<NERoomInvitation>>> getInviteList(String roomId) {
    return HttpApiHelper.execute(_RoomGetInviteListApi(roomId));
  }

  /// 检查是否有权限
  static Future<NEResult<void>> hasEnableCaptionsPermission(String meetingNum) {
    return HttpApiHelper.execute(_CheckCaptionPermissionApi(meetingNum));
  }
}
