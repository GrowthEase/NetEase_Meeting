// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class _LoginByPwdRequest {
  final String username;
  final String password;

  const _LoginByPwdRequest(this.username, this.password);

  Map get data => {
        'password': '$password@yiyong.im'.md5,
      };
}
