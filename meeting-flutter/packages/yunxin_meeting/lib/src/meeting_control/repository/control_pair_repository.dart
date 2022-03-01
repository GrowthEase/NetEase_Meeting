// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

/// 遥控器
class ControlPairRepo {

  /// 注册账号
  static Future<NEResult<TVInfo>> getTVInfo(String pairingCode) {
    return HttpApiHelper.execute(_GetTvInfoApi(_GetTVInfoRequest(pairingCode)), isCheckIM: true);
  }


}
