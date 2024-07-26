// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class _LogService {
  static final _LogService _instance = _LogService._();

  _LogService._();

  factory _LogService() => _instance;

  String? _rootPath;

  Future<bool> init() async {
    if (_rootPath != null) {
      return true;
    }
    var logRootPath = await _defaultSDKRootPath;
    //此处适配iOS，传入路径后缀无分隔符'/'；
    logRootPath = logRootPath.endsWith('/') ? logRootPath : '$logRootPath/';
    if (!(await _createDirectory(logRootPath))) return false;

    final success = Alog.init(ALogLevel.info, logRootPath, 'meeting_kit');
    print('RoomLogService init with path: $logRootPath, success: $success');
    if (success) {
      _rootPath = logRootPath;
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
      return '${directory.path}/NIMSDK/Logs/extra_log/xkit/';
    } else {
      directory = await getExternalStorageDirectory();
      return '${directory.path}/nim/extra_log/xkit/';
    }
  }
}
