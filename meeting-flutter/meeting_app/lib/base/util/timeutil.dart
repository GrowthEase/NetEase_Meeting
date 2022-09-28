// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:intl/intl.dart';

class TimeFormat {
  static const dateFormat1 = "yyyy/MM/dd hh:mm";
  static const dateFormat2 = "MM/dd/yyyy";
  static const dateFormat3 = "yyyyMMdd";
  static const dateFormatFull1 = "dd MM yyyy kk:mm:ss";
  static const dateFormatFull2 = "MM:dd:yyyy hh:mm:ss a";
  static const dateFormatFull3 = "yyyy-MM-dd kk:mm:ss";
  static const dateFormatFull4 = "dd/MM/yyyy kk:mm:ss";
  static const dateFormatReadable = "dd MM yyyy hh:mm:ss a";
  static const dateFormatSimple = "kk:mm:ss";
  static const timeFormatWithMinute = "yyyy-MM-dd HH:mm";
  static const timeFormatHourMinute = "kk:mm";
}

class TimeUtil {
  static String getTimeFormatWithMinute() {
    final now = DateTime.now();
    return DateFormat(TimeFormat.timeFormatWithMinute).format(now);
  }

  static String getDayTime2() {
    final now = DateTime.now();
    return DateFormat(TimeFormat.dateFormat3).format(now);
  }

  static String getYesterdayTime() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateFormat(TimeFormat.dateFormat3).format(yesterday);
  }

  static String getCurrentTime() {
    final now = DateTime.now();
    return DateFormat(TimeFormat.dateFormatFull4).format(now);
  }

  static String getTimeFormatMillisecond() {
    final now = DateTime.now();
    return "${DateFormat(TimeFormat.dateFormatFull3).format(now)} ${now.millisecond % 1000}";
  }

  static int getCurrentTimeMilliseconds() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static String timeFormatWithMinute(DateTime time) {
    return DateFormat(TimeFormat.timeFormatWithMinute).format(time);
  }

  static String timeFormatHourMinute(DateTime time) {
    return DateFormat(TimeFormat.timeFormatHourMinute).format(time);
  }

  static String getTimeFormatYMDHM(int milliseconds) {
    return DateFormat(TimeFormat.dateFormat1)
        .format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
  }
}
