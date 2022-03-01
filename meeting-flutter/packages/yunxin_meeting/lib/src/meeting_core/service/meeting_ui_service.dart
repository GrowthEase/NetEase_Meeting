// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingUIService {
  static final MeetingUIService _instance = MeetingUIService._();

  factory MeetingUIService() => _instance;

  MeetingUIService._();

  NEMenuItemClickHandler? injectedMenuItemClickHandler;
}
