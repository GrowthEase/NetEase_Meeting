// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

///
/// 转写消息对象
///
class NEMeetingTranscriptionMessage {
  const NEMeetingTranscriptionMessage({
    required this.fromUserUuid,
    required this.fromNickname,
    required this.content,
    required this.timestamp,
  });

  ///
  /// 解析转写消息。可用于解析转写文件的每一行
  ///
  factory NEMeetingTranscriptionMessage.parse(String message) {
    final list = jsonDecode(message);
    final [
      String timestamp,
      String fromUserUuid,
      String fromNickname,
      String content,
    ] = list as List;
    return NEMeetingTranscriptionMessage(
      fromUserUuid: fromUserUuid,
      fromNickname: fromNickname,
      content: content,
      timestamp: int.parse(timestamp),
    );
  }

  ///
  /// 讲话者用户唯一 Id
  ///
  final String fromUserUuid;

  ///
  /// 讲话者昵称
  ///
  final String fromNickname;

  ///
  /// 消息内容
  ///
  final String content;

  ///
  /// 消息发送时间，单位为ms
  ///
  final int timestamp;

  Map toJson() {
    return {
      'fromUserUuid': fromUserUuid,
      'fromNickname': fromNickname,
      'content': content,
      'timestamp': timestamp,
    };
  }
}

/// 会议转写时间段
class NEMeetingTranscriptionInterval {
  ///
  /// 转写开始时间戳，单位为ms
  ///
  final int start;

  ///
  /// 转写结束时间戳，单位为ms
  ///
  final int stop;

  NEMeetingTranscriptionInterval(this.start, this.stop);
}

/// 会议转写信息
class NEMeetingTranscriptionInfo {
  ///
  /// 当前实时转写状态：1：生成中；2：已生成；
  ///
  final int state;

  ///
  /// 开关转写的时间范围列表
  ///
  final List<NEMeetingTranscriptionInterval> timeRanges;

  ///
  /// 原始转写文件的 key 列表，可使用 key 获取文件下载地址。
  ///
  /// 通过 [NEPreMeetingService.getHistoryMeetingTranscriptionMessageList] 获取转写文件的消息列表。
  ///
  final List<String> originalNosFileKeys;

  ///
  /// txt 格式转写文件的 key 列表，可使用 key 获取文件下载地址。
  ///
  final List<String> txtNosFileKeys;

  ///
  ///  word 格式的转写文件的 key 列表，可使用 key 获取文件下载地址。
  ///
  final List<String> wordNosFileKeys;

  ///
  ///  pdf 格式的转写文件的 key 列表，可使用 key 获取文件下载地址。
  ///
  final List<String> pdfNosFileKeys;

  ///
  /// 是否正在生成转写
  ///
  bool get isGenerating => state == 1;

  ///
  /// 是否已生成转写
  ///
  bool get isGenerated => state == 2;

  const NEMeetingTranscriptionInfo({
    this.state = 2,
    this.timeRanges = const <NEMeetingTranscriptionInterval>[],
    this.originalNosFileKeys = const <String>[],
    this.txtNosFileKeys = const <String>[],
    this.wordNosFileKeys = const <String>[],
    this.pdfNosFileKeys = const <String>[],
  });

  factory NEMeetingTranscriptionInfo.fromJson(Map map) {
    return NEMeetingTranscriptionInfo(
      state: map['state'] as int,
      timeRanges: (map['timeRanges'] as List? ?? [])
          .cast<Map>()
          .map((e) => NEMeetingTranscriptionInterval(e['start'], e['stop']))
          .toList(),
      originalNosFileKeys:
          (map['originalNosFileKeys'] as List?)?.cast<String>() ?? [],
      txtNosFileKeys: (map['txtNosFileKeys'] as List?)?.cast<String>() ?? [],
      wordNosFileKeys: (map['wordNosFileKeys'] as List?)?.cast<String>() ?? [],
      pdfNosFileKeys: (map['pdfNosFileKeys'] as List?)?.cast<String>() ?? [],
    );
  }

  Map toJson() {
    return {
      'state': state,
      'timeRanges':
          timeRanges.map((e) => {'start': e.start, 'stop': e.stop}).toList(),
      'originalNosFileKeys': originalNosFileKeys,
      'txtNosFileKeys': txtNosFileKeys,
      'wordNosFileKeys': wordNosFileKeys,
      'pdfNosFileKeys': pdfNosFileKeys,
    };
  }
}

///
/// 字幕/转写目标翻译语言枚举
///
enum NEMeetingASRTranslationLanguage {
  ///
  /// 不翻译
  ///
  none,

  ///
  /// 中文
  ///
  chinese,

  ///
  /// 英文
  ///
  english,

  ///
  /// 日文
  ///
  japanese;
}

extension NEMeetingASRTranslationLanguageEx on NEMeetingASRTranslationLanguage {
  NERoomCaptionTranslationLanguage mapToRoomLanguage() {
    const map = {
      NEMeetingASRTranslationLanguage.none:
          NERoomCaptionTranslationLanguage.none,
      NEMeetingASRTranslationLanguage.chinese:
          NERoomCaptionTranslationLanguage.chinese,
      NEMeetingASRTranslationLanguage.english:
          NERoomCaptionTranslationLanguage.english,
      NEMeetingASRTranslationLanguage.japanese:
          NERoomCaptionTranslationLanguage.japanese,
    };
    return map[this]!;
  }
}
