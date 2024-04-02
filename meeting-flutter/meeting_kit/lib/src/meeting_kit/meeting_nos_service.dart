// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

abstract class NEMeetingNosService {
  /// 上传文件
  /// [filePath] 文件本地路径
  /// [progress] 上传进度回调
  Future<NEResult<String?>> uploadResource(String filePath,
      {Function(double)? progress});
}
