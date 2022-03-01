// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class MeetingControlUIService {
  static final MeetingControlUIService _instance = MeetingControlUIService._();

  factory MeetingControlUIService() => _instance;

  MeetingControlUIService._();

  NEMenuItemClickHandler? injectedMenuItemClickHandler;
}
