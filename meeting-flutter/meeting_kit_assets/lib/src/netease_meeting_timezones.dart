// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:netease_meeting_assets/netease_meeting_assets.dart';

class NEMeetingTimezones {
  static const String package = meetingAssetsPackageName;

  /// 根据语言读取assets/timezones中的时区列表,文件格式为txt
  /// Pacific/Midway;(GMT-11:00) Midway Island, Samoa
  static Future<List<String>> getTimezoneList(String languageCode) async {
    /// 默认中文
    if (languageCode != 'en' && languageCode != 'ja') {
      languageCode = 'zh';
    }
    final path =
        'packages/$package/assets/timezones/timezones_$languageCode.txt';
    final data = await rootBundle.loadString(path);
    return data.split('\n');
  }
}
