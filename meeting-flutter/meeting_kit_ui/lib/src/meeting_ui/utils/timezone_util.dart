// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class TimezonesUtil {
  /// 默认时区
  static String get defaultTimezone => 'Asia/Shanghai';

  /// 本地时区
  static Future<String> get localTimezone => FlutterTimezone.getLocalTimezone();

  /// 根据语言读取assets/timezones中的时区列表,文件格式为txt
  /// Pacific/Midway;(GMT-11:00) Midway Island, Samoa
  static Future<List<NETimezone>> getTimezones() async {
    final local = NEMeetingUIKit.instance.localeListenable.value;
    var languageCode = local.languageCode;
    final lines = await NEMeetingTimezones.getTimezoneList(languageCode);
    return lines
        .map((e) {
          final regex = RegExp(r'(\w+/\w+);(\(GMT[+\-]\d+:\d+\))\s(.+)');
          final match = regex.firstMatch(e);
          if (match != null && match.groupCount == 3) {
            return NETimezone(
                match.group(1)!, match.group(2)!, match.group(3)!);
          }
          return null;
        })
        .whereType<NETimezone>()
        .toList();
  }

  /// 根据时区id获取时区信息
  static Future<NETimezone> getTimezoneById(String? timezoneId) async {
    final timezones = await getTimezones();
    timezoneId = timezoneId ?? await localTimezone;
    NETimezone? resultZone;
    for (var zone in timezones) {
      if (zone.id == timezoneId) {
        return zone;
      }
      if (zone.id == defaultTimezone) {
        resultZone = zone;
      }
    }
    return resultZone!;
  }

  /// 根据时区id，计算和本地时区的差值,转化成时区时间
  static int convertTimezoneDateTime(int timestamp, NETimezone? timezone) {
    if (timezone == null) {
      return timestamp;
    }

    return timestamp +
        calculateTimeDifference(timezone.time) -
        DateTime.now().timeZoneOffset.inMilliseconds;
  }

  /// 根据时区id，计算和本地时区的差值，转化成本地时间
  static int convertToLocalDateTime(int timestamp, NETimezone? timezone) {
    if (timezone == null) {
      return timestamp;
    }

    return timestamp -
        calculateTimeDifference(timezone.time) +
        DateTime.now().timeZoneOffset.inMilliseconds;
  }

  static int calculateTimeDifference(String timezoneInfo) {
    // 解析时区信息
    RegExp regExp = RegExp(r'GMT([+-])(\d{1,2}):?(\d{2})');
    if (regExp.hasMatch(timezoneInfo)) {
      Match match = regExp.firstMatch(timezoneInfo)!;
      int hours = int.parse(match.group(2)!);
      int minutes = int.parse(match.group(3)!);
      int sign = match.group(1) == '+' ? 1 : -1;
      return (hours * 60 + minutes) * sign * 60 * 1000;
    }
    return 0;
  }
}

/// 时区类
class NETimezone {
  final String id;
  final String time;
  final String zone;

  NETimezone(this.id, this.time, this.zone);

  factory NETimezone.fromJson(Map<String, dynamic> json) {
    return NETimezone(json['id'], json['time'], json['zone']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'zone': zone,
    };
  }
}
