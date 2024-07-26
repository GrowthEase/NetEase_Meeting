// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_core;

class _LoginInfo {
  final String appKey;
  final String userUuid;
  final String userToken;

  _LoginInfo(this.appKey, this.userUuid, this.userToken);
}

class _LoginInfoCache {
  static const String _keyLoginInfo = 'meeting_sdk_login_info';
  static const String _keyAccountId = 'account';
  static const String _keyAccountToken = 'token';
  static const String _keyAppKey = 'appkey';

  static Future<void> setLoginInfo(_LoginInfo? loginInfo) async {
    if (loginInfo == null) {
      await _setString(_keyLoginInfo, null);
    } else {
      await _setString(
          _keyLoginInfo,
          json.encode({
            _keyAppKey: loginInfo.appKey,
            _keyAccountId: loginInfo.userUuid,
            _keyAccountToken: loginInfo.userToken,
          }));
    }
  }

  static Future<_LoginInfo?> getLoginInfo() async {
    final cache = await _getString(_keyLoginInfo, null);
    if (cache != null) {
      final loginInfoJson = json.decode(cache);
      if (loginInfoJson is Map) {
        return _LoginInfo(
          loginInfoJson[_keyAppKey] as String,
          loginInfoJson[_keyAccountId] as String,
          loginInfoJson[_keyAccountToken] as String,
        );
      }
    }
    return null;
  }

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _ensureSharedPreferences() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<bool> _setString(String key, String? value) async {
    await _ensureSharedPreferences();
    if (value == null) {
      return await _prefs!.remove(key);
    } else {
      return await _prefs!.setString(key, value);
    }
  }

  static Future<String?> _getString(String key, [String? fallback]) async {
    await _ensureSharedPreferences();
    return _prefs!.getString(key) ?? fallback;
  }
}
