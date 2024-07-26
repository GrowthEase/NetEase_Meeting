// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

/// 意见反馈类
class NEFeedback {
  /// 用户选择问题分类。示例： 视频问题#黑屏
  String? category;

  /// 问题描述
  String description;

  /// 反馈时间，单位s
  int? time;

  /// 图片地址列表
  List<String>? imageList;

  /// 是否打开音频dump
  bool? needAudioDump;

  NEFeedback(
      {this.category,
      required this.description,
      this.time,
      this.imageList,
      this.needAudioDump});

  Map toMap() => {
        'category': category,
        'description': description,
        'time': time,
        'imageList': imageList,
        'needAudioDump': needAudioDump,
      };

  factory NEFeedback.fromMap(Map map) => NEFeedback(
        category: map['category'],
        description: map['description'],
        time: map['time'],
        imageList: map['imageList'],
        needAudioDump: map['needAudioDump'],
      );
}
