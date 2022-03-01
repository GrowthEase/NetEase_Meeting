
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_uikit;

extension MeetingIdFormatter on String {
  String toMeetingIdFormat() {
    return replaceAllMapped(RegExp(r'(\d{3})(\d{3})(\d{3,})'), (match) {
      return '${match[1]}-${match[2]}-${match[3]}';
    });
  }
}