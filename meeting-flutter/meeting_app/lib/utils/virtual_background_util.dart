// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../base/util/global_preferences.dart';

class VirtualBackgroundManager {
  static const _tag = 'VirtualBackgroundManager';

  static final _singleton = VirtualBackgroundManager._internal();

  factory VirtualBackgroundManager() => _singleton;

  VirtualBackgroundManager._internal();

  /// 解压缩虚拟背景资源,并设置为内置虚拟背景
  var _builtInVirtualBackgroundCompleter = Completer<List<String>?>();
  String? _md5Value;
  Future<void> _initBuiltInVirtualBackgroundRes() async {
    if (_builtInVirtualBackgroundCompleter.isCompleted) {
      Alog.d(tag: _tag, content: 'initBuiltInVirtualBackgroundRes isCompleted');
      return;
    }
    Directory? cache;
    if (Platform.isAndroid) {
      cache = await getExternalStorageDirectory();
    } else {
      cache = await getApplicationDocumentsDirectory();
    }
    // Read the Zip file from disk.
    final value =
        await rootBundle.load('assets/virtual_background_images/images.zip');
    // Decode the Zip file
    var bytes =
        value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes);
    final archive = ZipDecoder().decodeBytes(bytes);

    /// 计算虚拟背景资源文件的md5值, 如果md5值相同且本地内置虚拟背景列表不为空,则不需要解压缩
    _md5Value = md5.convert(bytes).toString();
    if (_md5Value == await GlobalPreferences().getVirtualBackgroundResMd5()) {
      Alog.d(tag: _tag, content: 'initBuiltInVirtualBackgroundRes md5 is same');
      _builtInVirtualBackgroundCompleter.complete(null);
      return;
    }

    // Extract the contents of the Zip archive to disk.
    List<String> sourceList = [];
    for (final file in archive) {
      final filename = file.name;

      /// mac系统会生成.DS_Store和__MACOSX文件夹,需要过滤掉
      if (!filename.contains('.DS_Store') && !filename.contains('__MACOSX')) {
        try {
          if (file.isFile) {
            final data = file.content as List<int>;
            final virtualBackgroundFile = File('${cache?.path}/$filename')
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
            if (const {'jpg', 'png', 'jpeg'}
                .contains(virtualBackgroundFile.path.split('.').last)) {
              sourceList.add(virtualBackgroundFile.path);
            }
          } else {
            await Directory('${cache?.path}/' + filename)
                .create(recursive: true);
          }
        } catch (e) {
          Alog.e(
              tag: _tag, content: 'initBuiltInVirtualBackgroundRes error=$e');
        }
      }
    }
    Alog.d(
        tag: _tag,
        content:
            'initBuiltInVirtualBackgroundRes complete size=${sourceList.length}');
    _builtInVirtualBackgroundCompleter.complete(sourceList);
    _setBuiltinVirtualBackgroundList(sourceList);
  }

  /// 登录之后调用，设置内置虚拟背景
  void ensureInit() async {
    final list = await NEMeetingKit.instance
        .getSettingsService()
        .getBuiltinVirtualBackgroundList();
    if (list.isEmpty) {
      _builtInVirtualBackgroundCompleter = Completer<List<String>?>();
      await GlobalPreferences().setVirtualBackgroundResMd5('');
    }
    _initBuiltInVirtualBackgroundRes();
  }

  void _setBuiltinVirtualBackgroundList(List<String> pathList) {
    GlobalPreferences().setVirtualBackgroundResMd5(_md5Value ?? '');
    NEMeetingKit.instance
        .getSettingsService()
        .setBuiltinVirtualBackgroundList(pathList);
  }
}
