// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

///将room_kit的code返回值，统一处理为meeting code
NEResult translationToMeetingNEResult(NEResult neResult) {
  return NEResult(
    code: neResult.isSuccess() ? NEMeetingErrorCode.success : neResult.code,
    msg: neResult.msg,
    data: neResult.data,
  );
}

Future<NEResult<void>> onDeny() {
  return Future.sync(() => NEResult(
        code: MeetingErrorCode.failed,
        msg: NEMeetingKitStrings.apiCallTooFrequent,
      ));
}
