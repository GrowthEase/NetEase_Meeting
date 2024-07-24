// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class ServiceRepository {
  static const tag = 'ServiceRepository';

  ServiceRepository._();

  factory ServiceRepository() => _instance;

  static final _instance = ServiceRepository._();

  String? _appKey;

  String get appKey => _appKey ?? 'AppKeyNotSet';

  /// 服务初始化
  Future<bool> initialize(String appKey, MeetingServerConfig? serverConfig,
      Map<String, dynamic>? extras) async {
    return await DeviceInfo.initialize().then((value) async {
      await _initServerUrl(serverConfig);
      DebugOptions().parseOptions(extras);
      _appKey = appKey;
      return true;
    }).catchError((e, s) {
      Alog.e(
        tag: tag,
        moduleName: _moduleName,
        content: 'initialize error: $e\n$s',
      );
      return false;
    });
  }

  Future<bool> _initServerUrl(MeetingServerConfig? serverConfig) async {
    if (serverConfig != null && serverConfig.serverUrl.isNotEmpty) {
      assert(() {
        print('custom server config: ${serverConfig.serverUrl}');
        return true;
      }());
      ServersConfig().serverUrl = serverConfig.serverUrl;
      return true;
    }
    return false;
  }
}

class MeetingServerConfig {
  final String serverUrl;

  MeetingServerConfig(this.serverUrl);

  static MeetingServerConfig? parse(String? serverUrl) {
    final url = serverUrl;
    if (url == null) return null;
    if (url.startsWith(r'http')) {
      return MeetingServerConfig(url);
    } else if (url.toLowerCase() == 'test') {
      return MeetingServerConfig('https://roomkit-dev.netease.im/');
    }
    return null;
  }
}
