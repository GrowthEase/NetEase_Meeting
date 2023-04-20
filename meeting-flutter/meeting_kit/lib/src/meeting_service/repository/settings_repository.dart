// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_service;

class SettingsRepository {
  ///保存用户信息配置
  static Future<NEResult<void>> saveSettingsApi(BeautySettings status) async {
    return await HttpApiHelper._saveSettingsApi(status);
  }

  ///获取用户信息配置
  static Future<NEResult<AccountSettings>> getSettingsApi() async {
    return HttpApiHelper._getSettingsApi();
  }

  /// 美颜等级在[0-10]范围
  static Future<NEResult<void>> saveBeautyFaceValue(int value) async {
    return await SettingsRepository.saveSettingsApi(
        BeautySettings(beauty: Beauty(level: value)));
  }
}
