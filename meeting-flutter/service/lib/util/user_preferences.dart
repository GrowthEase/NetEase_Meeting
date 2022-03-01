// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/sp_util.dart';
import 'package:service/profile/app_profile.dart';

class UserPreferences extends Preferences {
  static const String localSetting = 'localSetting';
  static const String serverSetting = 'serverSettings';

  UserPreferences._internal();

  static final UserPreferences _singleton = UserPreferences._internal();

  factory UserPreferences() => _singleton;

  /// save
  @override
  Future<void> setSp(String key, String value) async {
    await super.setSp(_wrapperKey(key), value);
  }

  @override
  Future<String?> getSp(String key) async {
    return super.getSp(_wrapperKey(key));
  }

  Future<String?> get localSettings async {
    return getSp(localSetting);
  }

  Future<void> setLocalSettings(String setting) async {
    await setSp(localSetting, setting);
  }

  Future<String?> get serverSettings async {
    return getSp(serverSetting);
  }

  Future<void> setServerSettings(String setting) async {
    await setSp(serverSetting, setting);
  }

  String _wrapperKey(String key) {
    return '${AppProfile.accountId}_$key';
  }
}
