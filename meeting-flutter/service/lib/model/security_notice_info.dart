// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class SecurityNoticeInfo {
  List<Configs>? configs;
  int? time = 0;

  SecurityNoticeInfo({required this.configs, required this.time});

  SecurityNoticeInfo.fromJson(Map json) {
    if (json['configs'] != null) {
      configs = <Configs>[];
      json['configs'].forEach((v) {
        configs!.add(Configs.fromJson(v as Map<String, dynamic>));
      });
    }
    time = (json['time'] ?? 0) as int;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['configs'] = configs!.map((v) => v.toJson()).toList();
    data['time'] = time;
    return data;
  }

  @override
  String toString() {
    return 'SecurityNoticeInfo{configs: $configs, time: $time}';
  }
}

class Configs {
  String? content;
  String? title;
  String? okBtnLabel;
  int? type;
  int? time;
  bool? enable;

  Configs(
      {required this.content,
      required this.title,
      required this.okBtnLabel,
      required this.type,
      this.time,
      this.enable});

  Configs.fromJson(Map<String, dynamic> json) {
    content = (json['content'] ?? '') as String;
    title = (json['title'] ?? '') as String;
    okBtnLabel = (json['okBtnLabel'] ?? '') as String;
    type = (json['type'] ?? 1) as int;
    time = (json['time'] ?? 0) as int;
    enable = (json['enable'] ?? false) as bool;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['content'] = content;
    data['title'] = title;
    data['okBtnLabel'] = okBtnLabel;
    data['type'] = type;
    data['time'] = time;
    data['enable'] = enable;
    return data;
  }

  @override
  String toString() {
    return 'Configs{content: $content, title: $title, okBtnLabel: $okBtnLabel, type: $type, time: $time,enable: $enable}';
  }
}
