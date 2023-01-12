// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class SettingsRepository {
  static Uint8List? _beautyKeyCache;

  ///保存用户信息配置
  static Future<NEResult<void>> saveSettingsApi(BeautySettings status) async {
    return await HttpApiHelper._saveSettingsApi(status);
  }

  ///获取用户信息配置
  static Future<NEResult<AccountSettings>> getSettingsApi() async {
    return HttpApiHelper._getSettingsApi();
  }

  /// 获取用户信息配置
  static Future<NEResult<Uint8List>?> getBeautyLicenseApi() async {
    NEResult<Uint8List> result;
    ProgressCallback progressCallback = (int count, int total) async {};
    var url = (SDKConfig.beauty.config as BeautyConfig?)?.licenseUrl;
    if (url == null) {
      return Future.value(null);
    }
    if (!isBeautyFaceSupported()) return null;
    if (_beautyKeyCache != null) {
      result = NEResult<Uint8List>(
          code: MeetingErrorCode.success, data: _beautyKeyCache);
    } else {
      result =
          (await HttpApiHelper._getBeautyLicenseApi(url, progressCallback));
      _beautyKeyCache = result.data;
    }
    return result;
  }

  /// 美颜等级在[0-10]范围
  static Future<NEResult<void>> saveBeautyFaceValue(int value) async {
    return await SettingsRepository.saveSettingsApi(
        BeautySettings(beauty: Beauty(level: value)));
  }

  static bool isBeautyFaceSupported() => SDKConfig.meetingBeautyConfig.enable;

  static bool isVirtualBackgroundFaceSupported() =>
      SDKConfig.meetingVirtualBackgroundConfig.enable;

  static bool isMeetingEndTimeTiSupported() =>
      SDKConfig.meetingEndTimeTipConfig.enable;

  static bool isMeetingLiveSupported() {
    return SDKConfig.appRoomResConfig.live;
  }

  static bool isMeetingWhiteboardSupported() {
    return SDKConfig.appRoomResConfig.whiteboard;
  }

  static bool isMeetingCloudRecordSupported() {
    return SDKConfig.appRoomResConfig.record;
  }

  static bool isMeetingChatSupported() {
    return SDKConfig.appRoomResConfig.chatRoom;
  }

  static bool isSipSupported() {
    return SDKConfig.appRoomResConfig.sip;
  }

  static Future<void> clear() async {
    _beautyKeyCache = null;
  }
}
