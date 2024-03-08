// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class HttpApiHelper {
  HttpApiHelper._();

  static Future<NEResult<T>> execute<T>(BaseApi api) {
    // var completer = Completer<NEResult<T>>();
    // if (isCheckIM) {
    //   _AuthManager()._imLoginCheck().then((code) {
    //     if (code == MeetingErrorCode.success) {
    //       completer.complete(_ApiHelper._execute(api));
    //     } else {
    //       completer
    //           .complete(Future.value(NEResult(code: MeetingErrorCode.notLogin)));
    //     }
    //   });
    // } else {
    //   completer.complete(_ApiHelper._execute(api));
    // }
    //
    // return completer.future;
    return _ApiHelper._execute(api);
  }

  static Future<NEResult<dynamic>> sendRequest(NEHttpApiRequest request) {
    return execute(_GenericHttpApiRequest(request));
  }

  static Future<NEResult<AnonymousLoginInfo>> _anonymousLogin() =>
      execute(_AnonymousLoginApi());

  /// 获取全局配置
  static Future<NEResult<_SDKGlobalConfig>> _getSDKGlobalConfig(
      String appKey) async {
    return execute(_GetConfigApi(appKey));
  }

  /// 预约会议
  static Future<NEResult<NEMeetingItem>> _scheduleRoom(NEMeetingItem item) {
    return execute(_ScheduleMeetingApi(item));
  }

  /// 编辑预约会议
  static Future<NEResult<NEMeetingItem>> _editRoom(NEMeetingItem item) {
    return execute(_EditMeetingApi(item));
  }

  ///取消预约会议，开始前可以取消
  static Future<NEResult<void>> _cancelRoom(int meetingId) {
    return execute(_CancelMeetingApi(meetingId));
  }

  ///删除预约会议
  static Future<NEResult<void>> _deleteRoom(int meetingId) {
    return execute(_DeleteMeetingApi(meetingId));
  }

  ///根据唯一id获取会议信息
  static Future<NEResult<NEMeetingItem>> _getRoomItemById(String meetingNum) {
    return execute(_GetMeetingItemByIdApi(meetingNum));
  }

  ///根据会议状态查询会议信息列表
  static Future<NEResult<List<NEMeetingItem>>> _getRoomList(
      List<NEMeetingState> status) {
    return execute(_GetMeetingListByStatusApi(status));
  }

  ///保存用户信息配置
  static Future<NEResult<void>> _saveSettingsApi(BeautySettings obj) {
    return execute(_SaveSettingsApi(obj));
  }

  ///获取用户信息配置
  static Future<NEResult<AccountSettings>> _getSettingsApi() {
    return execute(_GetSettingsApi());
  }
}
