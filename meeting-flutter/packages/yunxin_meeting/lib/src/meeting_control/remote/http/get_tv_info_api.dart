// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class _GetTvInfoApi extends HttpApi<TVInfo> {

  _GetTVInfoRequest request;

  _GetTvInfoApi(this.request);

  @override
  String path() {
    return '/v2/sdk/account/rc/pairingCodeInfoGet';
  }

  @override
  TVInfo result(Map map) => TVInfo.fromJson(map);

  @override
  Map data() => request.data;
}