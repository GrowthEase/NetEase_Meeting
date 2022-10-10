// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

extension ALogLevelExtension on ALogLevel {
  static ALogLevel get(int? mode) {
    return ALogLevel.values.firstWhere(
      (element) => element.index == mode,
      orElse: () => ALogLevel.verbose,
    );
  }
}

class ALoggerConfig {
  final ALogLevel level;
  final String? path;
  final String? namePrefix;

  const ALoggerConfig(
      {this.level = ALogLevel.info, this.path, this.namePrefix});

  static ALoggerConfig? fromMap(Map? map) {
    if (map == null) {
      return null;
    }
    return ALoggerConfig(
      level: ALogLevelExtension.get(map['level'] as int?),
      path: map['path'] as String?,
      namePrefix: map['namePrefix'] as String?,
    );
  }

  @override
  String toString() {
    return 'ALoggerConfig{level: $level, path: $path, namePrefix: $namePrefix}';
  }
}

class NERoomLogService {
  static final NERoomLogService _instance = NERoomLogService._();

  NERoomLogService._();

  factory NERoomLogService() => _instance;

  String? _rootPath;

  ALogLevel _logLevel = ALogLevel.info;

  ALogLevel get logLevel => _logLevel;

  ///_rootPath必须在init接口之后，才能获取日志path
  String get rootPath => _rootPath ?? '';

  String get _roomSDKPath => rootPath;

  // String get _rtcSDKPath => '${rootPath}NERtcSDK/';

  ///nim ios默认增加 [NIMSDK] ，此处增加平台处理
  // String get _nimSDKPath => Platform.isIOS ? rootPath : '${rootPath}NIMSDK/';

  Future<bool> init({ALoggerConfig? loggerConfig}) async {
    if (_rootPath != null) {
      return true;
    }
    loggerConfig ??= ALoggerConfig();
    var logRootPath = loggerConfig.path;
    if (logRootPath?.isEmpty ?? true) {
      logRootPath = await _defaultSDKRootPath;
    }
    //此处适配iOS，传入路径后缀无分隔符'/'；
    _rootPath = logRootPath!.endsWith('/') ? logRootPath : '$logRootPath/';
    if (!(await _createDirectory(rootPath))) return false;
    // if (!(await _createDirectory(_nimSDKPath))) return false;
    // if (!(await _createDirectory(_rtcSDKPath))) return false;

    final success = Alog.init(loggerConfig.level, _roomSDKPath,
        loggerConfig.namePrefix ?? 'meeting_kit');
    print('RoomLogService init with path: $rootPath, success: $success');
    if (!success) {
      _rootPath = null;
    } else {
      _logLevel = loggerConfig.level;
    }
    return success;
  }

  static Future<bool> _createDirectory(String path) async {
    var isCreate = false;
    var filePath = Directory(path);
    try {
      if (!await filePath.exists()) {
        await filePath.create(recursive: true);
        isCreate = true;
      } else {
        isCreate = true;
      }
    } catch (e) {
      isCreate = false;
      print('error $e');
    }
    return isCreate;
  }

  static Future<String> get _defaultSDKRootPath async {
    var directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/NIMSDK/Logs/extra_log/MeetingKit/';
    } else {
      directory = await getExternalStorageDirectory();
      return '${directory.path}/nim/extra_log/MeetingKit/';
    }
  }
}
