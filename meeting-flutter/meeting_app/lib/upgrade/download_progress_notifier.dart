// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/repo/misc_repo.dart';

typedef ProgressCallback = void Function(int count, int total);

typedef DownloadResult = void Function(int code);

/// down load progress notify
class DownloadProgressNotifier extends ChangeNotifier {
  /// 已下载
  int _count = 0;

  /// 总大小
  int _total = 0;

  /// progress
  double _progress = 0;

  double get downloadProgress => _progress;

  int get count => _count;

  int get total => _total;

  DownloadResult downloadResult;

  bool _cancel = false;

  DownloadProgressNotifier(this.downloadResult);

  void startDownload(String url, File file) {
    MiscRepo().downloadFile(url, file, (int count, int total) {
      _count = count;
      _total = total;
      _progress = count / total;
      if (!_cancel) {
        notifyListeners();
      }
    }).then((result) {
      if (!_cancel) {
        downloadResult(result.code);
      }
    });
  }

  /// 取消
  void cancel({bool cancelNotify = true}) {
    _cancel = true;
    if (cancelNotify) {
      downloadResult(HttpCode.cancel);
    }
  }

  void resume(bool resume) {
    _cancel = !resume;
  }
}
