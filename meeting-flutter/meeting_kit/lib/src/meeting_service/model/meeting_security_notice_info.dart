// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

/// 公告提示
class NEMeetingAppNoticeTips {
  final List<NEMeetingAppNoticeTip> tips = [];
  final int curTime;

  NEMeetingAppNoticeTips.fromJson(Map json)
      : curTime = (json['curTime'] ?? 0) as int {
    if (json['tips'] != null) {
      json['tips'].forEach((v) {
        tips.add(NEMeetingAppNoticeTip.fromJson((v as Map).cast()));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tips'] = tips.map((v) => v.toJson()).toList();
    data['curTime'] = curTime;
    return data;
  }
}

/// 应用消息提示类型
enum NEMeetingAppNoticeTipType {
  /// 未知
  kUnknown,

  /// 文本提示
  kText,

  /// 跳转超链接提示
  kUrl,
}

class NEMeetingAppNoticeTip {
  late final String? content;
  late final String? title;
  late final String? okBtnLabel;
  late final String? url;
  late final NEMeetingAppNoticeTipType type;
  late final int time;
  late final bool enable;

  NEMeetingAppNoticeTip({
    this.content,
    this.title,
    this.okBtnLabel,
    this.url,
    this.type = NEMeetingAppNoticeTipType.kText,
    this.time = 0,
    this.enable = true,
  });

  NEMeetingAppNoticeTip.fromJson(Map<String, dynamic> json) {
    content = (json['content'] ?? '') as String;
    title = (json['title'] ?? '') as String;
    okBtnLabel = (json['okBtnLabel'] ?? '') as String;
    url = json['url'] as String?;
    type = NEMeetingAppNoticeTipType.values[(json['type'] ?? 0) as int];
    time = (json['time'] ?? 0) as int;
    enable = (json['enable'] ?? false) as bool;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['content'] = content;
    data['title'] = title;
    data['okBtnLabel'] = okBtnLabel;
    if (url != null) data['url'] = url;
    data['type'] = type.index;
    data['time'] = time;
    data['enable'] = enable;
    return data;
  }
}
