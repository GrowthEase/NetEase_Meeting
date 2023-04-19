// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

class AppNotifications {
  static const _keyNotifications = 'tips';
  static const _keyTime = 'curTime';

  final String appKey;
  final List<AppNotification> notifications = [];
  final int time;

  AppNotifications.fromJson(this.appKey, Map json)
      : time = (json[_keyTime] ?? 0) as int {
    if (json[_keyNotifications] != null) {
      json[_keyNotifications].forEach((v) {
        notifications.add(AppNotification.fromJson((v as Map).cast()));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[_keyNotifications] = notifications.map((v) => v.toJson()).toList();
    data[_keyTime] = time;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class AppNotification {
  static const kTypeTxt = 1;
  static const kTypeUrl = 2;

  String? content;
  String? title;
  String? okBtnLabel;
  String? url;
  int? type;
  int? time;
  bool? enable;

  AppNotification.fromJson(Map<String, dynamic> json) {
    content = (json['content'] ?? '') as String;
    title = (json['title'] ?? '') as String;
    okBtnLabel = (json['okBtnLabel'] ?? '') as String;
    url = json['url'] as String?;
    type = (json['type'] ?? 1) as int;
    time = (json['time'] ?? 0) as int;
    enable = (json['enable'] ?? false) as bool;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['content'] = content;
    data['title'] = title;
    data['okBtnLabel'] = okBtnLabel;
    if (url != null) data['url'] = url;
    data['type'] = type;
    data['time'] = time;
    data['enable'] = enable;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}
