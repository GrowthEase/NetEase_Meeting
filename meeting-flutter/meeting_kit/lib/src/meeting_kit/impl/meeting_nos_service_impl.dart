// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class _NEMeetingNosServiceImpl extends NEMeetingNosService {
  static final _NEMeetingNosServiceImpl _instance =
      _NEMeetingNosServiceImpl._();

  factory _NEMeetingNosServiceImpl() => _instance;

  _NEMeetingNosServiceImpl._();

  @override
  Future<NEResult<String?>> uploadResource(String filePath,
      {Function(double)? progress}) {
    return NERoomKit.instance.nosService
        .uploadResource(filePath, progress: progress);
  }
}
