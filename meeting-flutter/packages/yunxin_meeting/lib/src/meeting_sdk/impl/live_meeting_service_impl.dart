// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_sdk;

/// 直播服务实现类
class _NELiveMeetingServiceImpl extends NELiveMeetingService {
  static final _NELiveMeetingServiceImpl _instance = _NELiveMeetingServiceImpl._();

  factory _NELiveMeetingServiceImpl() => _instance;

  _NELiveMeetingServiceImpl._();
}
