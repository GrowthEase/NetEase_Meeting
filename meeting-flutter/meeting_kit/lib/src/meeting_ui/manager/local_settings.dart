// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

final class _LocalStorage {
  factory _LocalStorage() => _instance;

  static final _LocalStorage _instance = _LocalStorage._();

  final _sharedPreferencesMemo = AsyncMemoizer<SharedPreferences>();

  _LocalStorage._() {
    _sharedPreferencesMemo.runOnce(() async {
      return await SharedPreferences.getInstance();
    });
  }

  Future<int?> getInt(String key, {int? defaultValue}) async {
    return _sharedPreferencesMemo.future
        .then((sp) => sp.getInt(key) ?? defaultValue);
  }

  Future<bool> setInt(String key, int? value) {
    return _sharedPreferencesMemo.future
        .then((sp) => value == null ? sp.remove(key) : sp.setInt(key, value));
  }

  Future<String?> getString(String key, {String? defaultValue}) async {
    return _sharedPreferencesMemo.future
        .then((sp) => sp.getString(key) ?? defaultValue);
  }

  Future<bool> setString(String key, String? value) {
    return _sharedPreferencesMemo.future.then(
        (sp) => value == null ? sp.remove(key) : sp.setString(key, value));
  }

  Future<bool?> getBool(String key, {bool? defaultValue}) async {
    return _sharedPreferencesMemo.future
        .then((sp) => sp.getBool(key) ?? defaultValue);
  }

  Future<bool> setBool(String key, bool? value) {
    return _sharedPreferencesMemo.future
        .then((sp) => value == null ? sp.remove(key) : sp.setBool(key, value));
  }
}

///
/// 会议本地设置
///
final class _LocalSettings {
  factory _LocalSettings() => _instance;

  static final _LocalSettings _instance = _LocalSettings._();

  _LocalSettings._() {
    isBarrageShow();
  }

  final _LocalStorage _localStorage = _LocalStorage();

  static const _requestPermissionInterval = Duration(days: 2);
  static const _requestPhoneStatePermissionTimeKey =
      'phone_state_permission_time';
  static const _requestBluetoothConnectPermissionTimeKey =
      'bluetooth_connect_permission_time';
  static const _showBulletScreenKey = 'show_bullet_screen';

  bool _isBulletScreenShow = true;
  StreamController<bool> _isBulletScreenShowStream =
      StreamController.broadcast();

  /// 更新请求获取手机状态权限时间
  void updatePhoneStatePermissionTime() {
    _localStorage.setInt(_requestPhoneStatePermissionTimeKey,
        DateTime.now().millisecondsSinceEpoch);
  }

  /// 是否需要请求手机状态权限
  Future<bool> shouldRequestPhoneStatePermission() async {
    final lastTime =
        await _localStorage.getInt(_requestPhoneStatePermissionTimeKey);
    if (lastTime == null) {
      return true;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - lastTime >= _requestPermissionInterval.inMilliseconds;
  }

  /// 更新请求蓝牙连接权限时间
  void updateBluetoothConnectPermissionTime() {
    _localStorage.setInt(_requestBluetoothConnectPermissionTimeKey,
        DateTime.now().millisecondsSinceEpoch);
  }

  /// 是否需要请求蓝牙连接权限
  Future<bool> shouldRequestBluetoothConnectPermission() async {
    final lastTime =
        await _localStorage.getInt(_requestBluetoothConnectPermissionTimeKey);
    if (lastTime == null) {
      return true;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - lastTime >= _requestPermissionInterval.inMilliseconds;
  }

  /// 是否显示弹幕
  Future<bool> isBarrageShow() async {
    final value = await _localStorage.getBool(_showBulletScreenKey);
    _isBulletScreenShow = value ?? true;
    return _isBulletScreenShow;
  }

  /// 是否显示弹幕stream
  Stream<bool> getIsBarrageShowStream() {
    return _isBulletScreenShowStream.stream.addInitial(_isBulletScreenShow);
  }

  /// 设置是否显示弹幕
  Future<bool> setBarrageShow(bool show) {
    _isBulletScreenShow = show;
    _isBulletScreenShowStream.add(show);
    return _localStorage.setBool(_showBulletScreenKey, show);
  }
}
