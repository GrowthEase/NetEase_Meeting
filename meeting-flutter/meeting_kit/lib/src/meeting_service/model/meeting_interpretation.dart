// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

///
/// 同声传译译员
///
class NEMeetingInterpreter {
  ///
  /// 传译员用户 Id
  ///
  final String userId;

  ///
  /// 译员第一语言，默认为收听语言。支持的内置语言参考 [NEInterpretationLanguages]
  ///
  final String firstLang;

  ///
  /// 译员第二语言，默认为传译语言。支持的内置语言参考 [NEInterpretationLanguages]
  ///
  final String secondLang;

  const NEMeetingInterpreter(this.userId, this.firstLang, this.secondLang);

  @override
  int get hashCode => Object.hash(userId, firstLang, secondLang);

  String flipLanguage(String language) {
    return language == firstLang ? secondLang : firstLang;
  }

  bool get isValid =>
      userId.isNotEmpty &&
      firstLang.isNotEmpty &&
      secondLang.isNotEmpty &&
      firstLang != secondLang;

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NEMeetingInterpreter &&
        userId == other.userId &&
        firstLang == other.firstLang &&
        secondLang == other.secondLang;
  }

  @override
  String toString() {
    return '$userId($firstLang, $secondLang)';
  }
}

///
/// 同声传译设置
///
class NEMeetingInterpretationSettings {
  final _interpreters = <String, NEMeetingInterpreter>{};

  NEMeetingInterpretationSettings([List<NEMeetingInterpreter>? interpreters]) {
    if (interpreters != null) {
      addInterpreters(interpreters);
    }
  }

  ///
  /// 添加译员。如果已经译员已经存在，则会覆盖。
  /// - [userId] 译员用户 Id
  /// - [firstLang] 语言1，参考 [NEInterpretationLanguages]
  /// - [secondLang] 语言2，参考 [NEInterpretationLanguages]
  ///
  bool addInterpreter(String userId, String firstLang, String secondLang) {
    final interpreter = NEMeetingInterpreter(userId, firstLang, secondLang);
    if (interpreter.isValid) {
      _interpreters[userId] = interpreter;
      return true;
    }
    return false;
  }

  ///
  /// 添加多个译员。如果已经译员已经存在，则会覆盖。
  ///
  bool addInterpreters(List<NEMeetingInterpreter> interpreters) {
    if (interpreters.every((element) => element.isValid)) {
      for (var interpreter in interpreters) {
        _interpreters[interpreter.userId] = interpreter;
      }
      return true;
    }
    return false;
  }

  ///
  /// 移除译员。成功返回 true，否则返回 false
  /// [userId] 译员用户 Id
  ///
  bool removeInterpreter(String userId) {
    return _interpreters.remove(userId) != null;
  }

  ///
  /// 获取译员列表
  ///
  List<NEMeetingInterpreter> getInterpreterList() {
    return _interpreters.values.toList();
  }

  ///
  /// 清空译员列表
  ///
  void clearInterpreterList() {
    _interpreters.clear();
  }

  ///
  /// 译员列表是否为空
  ///
  bool get isEmpty => _interpreters.isEmpty;

  NEMeetingInterpretationSettings copy() {
    var copy = NEMeetingInterpretationSettings();
    copy.addInterpreters(getInterpreterList());
    return copy;
  }

  Map<String, dynamic> toJson() {
    return {
      'interpreters': _interpreters.map((userUuid, interpreter) {
        return MapEntry(
            userUuid, [interpreter.firstLang, interpreter.secondLang]);
      })
    };
  }

  factory NEMeetingInterpretationSettings.fromJson(Map? map) {
    final settings = NEMeetingInterpretationSettings();
    var interpreters = map?['interpreters'] as Map?;
    interpreters?.forEach((key, value) {
      if (key is String) {
        if (value case [String firstLang, String secondLang]) {
          settings.addInterpreter(key, firstLang, secondLang);
        }
      }
    });
    return settings;
  }
}

///
/// 同声传译语言定义
///
final class NEInterpretationLanguages {
  NEInterpretationLanguages._();

  static const all = [
    chinese,
    english,
    japanese,
    korean,
    french,
    german,
    spanish,
    russian,
    portuguese,
    italian,
    turkish,
    vietnamese,
    thai,
    indonesian,
    malay,
    arabic,
    hindi,
  ];

  /// 中文
  static const chinese = 'zh';

  /// 英语
  static const english = 'en';

  /// 日语
  static const japanese = 'jp';

  /// 韩语
  static const korean = 'kr';

  /// 法语
  static const french = 'fr';

  /// 德语
  static const german = 'de';

  /// 西班牙语
  static const spanish = 'es';

  /// 俄语
  static const russian = 'ru';

  /// 葡萄牙语
  static const portuguese = 'pt';

  /// 意大利语
  static const italian = 'it';

  /// 土耳其语
  static const turkish = 'tr';

  /// 越南语
  static const vietnamese = 'vi';

  /// 泰语
  static const thai = 'th';

  /// 印尼语
  static const indonesian = 'id';

  /// 马来语
  static const malay = 'ms';

  /// 阿拉伯语
  static const arabic = 'ar';

  /// 印地语
  static const hindi = 'hi';
}

/// 同声传译远端服务
class MeetingInterpretationRepo {
  MeetingInterpretationRepo._();

  /// 开始同声传译
  static Future<NEResult<void>> start(
    String meetingId, {
    NEMeetingInterpretationSettings? settings,
  }) async {
    return HttpApiHelper.sendRequest(
      NEHttpApiRequest(
        path: _buildPath(meetingId),
        body: {
          'started': true,
          if (settings != null) ...settings.toJson(),
        },
      ),
    );
  }

  /// 停止同声传译
  static Future<NEResult<void>> stop(String meetingId) async {
    return HttpApiHelper.sendRequest(
      NEHttpApiRequest(
        path: _buildPath(meetingId),
        body: {'started': false},
      ),
    );
  }

  /// 更新译员设置
  static Future<NEResult<void>> updateSettings(
      String meetingId, NEMeetingInterpretationSettings? settings) async {
    settings ??= NEMeetingInterpretationSettings();
    return HttpApiHelper.sendRequest(
      NEHttpApiRequest(
        path: _buildPath(meetingId),
        body: {
          ...settings.toJson(),
        },
      ),
    );
  }

  static String _buildPath(String meetingId) {
    return '/scene/meeting/v2/interpretation?meetingId=$meetingId';
  }
}
