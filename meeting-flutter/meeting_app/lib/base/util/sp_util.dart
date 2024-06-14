// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

abstract class Preferences {
  static SharedPreferences? instance;

  Future prepare() async {
    instance ??= await SharedPreferences.getInstance();
  }

  /// save
  Future<bool> remove(String key) async {
    await prepare();
    return instance!.remove(key);
  }

  /// save
  Future<bool> setSp(String key, String value) async {
    await prepare();
    return instance!.setString(key, value);
  }

  Future<bool> setBoolSp(String key, bool value) async {
    await prepare();
    return instance!.setBool(key, value);
  }

  /// get
  Future<String?> getSp(String key) async {
    await prepare();
    return instance!.get(key) as String?;
  }

  Future<bool?> getBoolSp(String key) async {
    await prepare();
    return instance!.getBool(key);
  }

  Future<bool?> setStringList(String key, List<String> value) async {
    await prepare();
    return instance!.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await prepare();
    return instance!.getStringList(key);
  }
}
