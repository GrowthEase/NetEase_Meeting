// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class _GetTVInfoRequest {
  /// 配对码
  String pairingCode;

  _GetTVInfoRequest(this.pairingCode);

  Map get data => {'pairingCode': pairingCode};
}
