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
  static Future<NEResult<NEMeetingItem>> _editRoom(
      NEMeetingItem item, bool editRecurringMeeting) {
    if (editRecurringMeeting) {
      return execute(_EditRecurringMeetingApi(item));
    } else {
      return execute(_EditMeetingApi(item));
    }
  }

  ///取消预约会议，开始前可以取消
  static Future<NEResult<void>> _cancelRoom(
      int meetingId, bool cancelRecurringMeeting) {
    return execute(_CancelMeetingApi(meetingId, cancelRecurringMeeting));
  }

  ///删除预约会议
  static Future<NEResult<void>> _deleteRoom(int meetingId) {
    return execute(_DeleteMeetingApi(meetingId));
  }

  ///根据meetingNum获取会议信息
  static Future<NEResult<NEMeetingItem>> _getMeetingItemByNum(
      String meetingNum) {
    return execute(_GetMeetingItemByNumApi(meetingNum));
  }

  /// 根据MeetingId查询会议信息，如果是周期性会议的话，返回的是周期性会议最新的一次会议信息
  static Future<NEResult<NEMeetingItem>> _getMeetingItemById(int meetingId) {
    return execute(_GetMeetingItemByIdApi(meetingId));
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

  /// 获取小应用列表
  static Future<NEResult<NEMeetingWebAppList>> getWebAppList() {
    return execute(_GetWebAppListApi());
  }

  /// 获取JSAPI授权
  static Future<NEResult<void>> jsAPIPermission(
      JSApiPermissionRequest request) {
    return execute(_GetJSApiPermissionApi(request));
  }

  /// 获取授权码
  static Future<NEResult<AuthCodeModel>> getAuthCode(String pluginId) {
    return execute(_GetAuthCodeApi(pluginId));
  }

  /// 获取主持人和联席主持人列表
  static Future<NEResult<List<NERoomMember>>> _getHostAndCoHostList(
      String roomUuid) {
    return execute(_GetHostAndCoHostListApi(roomUuid));
  }

  /// 获取等候室属性
  static Future<NEResult<Map<String, dynamic>>> _getWaitingRoomProperties(
      String roomUuid) {
    return execute(_GetWaitingRoomPropertiesApi(roomUuid));
  }

  /// 通讯录搜索
  static Future<NEResult<List<NEContact>>> _searchContacts(
      String? name, String? phoneNumber, int? pageSize, int? pageNum) {
    return execute(_SearchContactsApi(name, phoneNumber, pageSize, pageNum));
  }

  /// 通讯录用户信息获取, userUuids最大长度50
  static Future<NEResult<NEContactsInfoResponse>> _getContactsInfo(
      List<String> userUuids) {
    return execute(_GetContactsInfoApi(userUuids));
  }

  /// 获取预约会议参会者列表接口
  static Future<NEResult<List<NEScheduledMember>>> _getScheduledMembers(
      String meetingNum) {
    return execute(_GetScheduledMembersApi(meetingNum));
  }
}
