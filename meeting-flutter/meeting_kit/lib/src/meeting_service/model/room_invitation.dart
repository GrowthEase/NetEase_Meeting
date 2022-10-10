// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_service;

/// 房间邀请信息
///
class NERoomInvitation {
  /// 被邀请方唯一Id
  final String sipNum;

  /// 被邀请方客户端类型
  ///
  /// [ClientType]
  final String sipHost;

  /// "status": 0, //邀请状态，0:邀请中，1:已加入，2:已拒绝

  NERoomInvitation({
    required this.sipNum,
    required this.sipHost,
  });
}
