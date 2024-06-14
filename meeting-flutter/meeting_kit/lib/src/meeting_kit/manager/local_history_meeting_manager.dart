// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

class LocalHistoryMeetingManager {
  String TAG = "LocalHistoryMeetingManager";

  /// 私有构造函数
  LocalHistoryMeetingManager._internal() {
    ensureInit();
  }

  /// 保存单例
  static LocalHistoryMeetingManager _singleton =
      LocalHistoryMeetingManager._internal();

  /// 工厂构造函数
  factory LocalHistoryMeetingManager() => _singleton;

  bool get hasLocalMeetingHistory => _localHistoryMeetingCache.isNotEmpty;

  static late SharedPreferences _sharedPreferences;
  String? _userId;
  late String _key;
  final List<NELocalHistoryMeeting> _localHistoryMeetingCache = [];

  Future<List<NELocalHistoryMeeting>> ensureInit() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (_userId != _getCurrentUserId()) {
      _userId = _getCurrentUserId();
      _key = '${_userId}_local_history_meeting';
      var localHistoryMeeting = _sharedPreferences.getStringList(_key);
      _localHistoryMeetingCache.clear();
      if (localHistoryMeeting != null && localHistoryMeeting.isNotEmpty) {
        final list = (localHistoryMeeting as List)
            .map((e) => NELocalHistoryMeeting.fromJson(json.decode(e) as Map))
            .whereType<NELocalHistoryMeeting>()
            .toList();
        _localHistoryMeetingCache.addAll(list);
      }
    }
    return _localHistoryMeetingCache;
  }

  String _getCurrentUserId() {
    final accountService = NEMeetingKit.instance.getAccountService();
    final id = accountService.getAccountInfo()?.userUuid;
    final anonymous = accountService.isAnonymous;
    return id == null || id.isEmpty || anonymous ? '0' : id;
  }

  /// 获取最近10条的会议记录
  List<NELocalHistoryMeeting> get localHistoryMeetingList =>
      _localHistoryMeetingCache;

  /// 添加会议记录，如果已经存在则更新，不存在则插入，最多保存10条
  Future<void> addLocalHistoryMeeting(
      NELocalHistoryMeeting localHistoryMeeting) async {
    if (_localHistoryMeetingCache
        .any((record) => record.meetingNum == localHistoryMeeting.meetingNum)) {
      /// 记录里面已经存在，移除旧的，插入新的
      Alog.i(
          tag: TAG,
          content:
              "addLocalHistoryMeeting meetingNum = ${localHistoryMeeting.meetingNum} already exists");
      _localHistoryMeetingCache.removeWhere(
          (record) => record.meetingNum == localHistoryMeeting.meetingNum);
      _localHistoryMeetingCache.insert(0, localHistoryMeeting);
    } else {
      /// 记录里面不存在，直接插入
      Alog.i(
          tag: TAG,
          content:
              "addLocalHistoryMeeting meetingNum = ${localHistoryMeeting.meetingNum}");
      _localHistoryMeetingCache.insert(0, localHistoryMeeting);
      if (_localHistoryMeetingCache.length > 10) {
        _localHistoryMeetingCache.removeLast();
      }
    }
    saveLocalHistoryMeeting(_localHistoryMeetingCache);
  }

  /// 移除会议记录
  void clearAll() async {
    Alog.i(tag: TAG, content: "clearAll");
    _localHistoryMeetingCache.clear();
    saveLocalHistoryMeeting(_localHistoryMeetingCache);
  }

  /// 保存会议记录至本地存储
  void saveLocalHistoryMeeting(List<NELocalHistoryMeeting> list) {
    List<String> records = list.map((e) => jsonEncode(e.toJson())).toList();
    _sharedPreferences.setStringList(_key, records);
  }
}

/// 会议历史记录对象
class NELocalHistoryMeeting {
  /// 会议号
  final String meetingNum;

  /// 会议唯一标识
  final int meetingId;

  /// 会议短号
  final String? shortMeetingNum;

  /// 会议主题
  final String subject;

  /// 会议密码
  final String? password;

  /// 会议昵称
  String nickname;

  /// sipId
  String? sipId;

  NELocalHistoryMeeting({
    required this.meetingId,
    required this.meetingNum,
    this.shortMeetingNum,
    required this.subject,
    this.password,
    this.sipId,
    required this.nickname,
  });

  static NELocalHistoryMeeting? fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) return null;
    try {
      return NELocalHistoryMeeting(
        meetingId: json['meetingId'] as int,
        meetingNum: json['meetingNum'] as String,
        shortMeetingNum: json['shortMeetingNum'] as String?,
        password: json['password'] as String?,
        subject: json['subject'] as String,
        nickname: json['nickname'] as String,
        sipId: json['sipId'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'meetingId': meetingId,
        'meetingNum': meetingNum,
        if (shortMeetingNum != null) 'shortMeetingNum': shortMeetingNum,
        if (password != null) 'password': password,
        'subject': subject,
        'nickname': nickname,
        if (sipId != null) 'sipId': sipId,
      };
}
