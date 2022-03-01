// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_core;

class MeetingConfig {
  static final int _focusSwitchInterval = 6;

  /// audio low threshold
  static const int volumeLowThreshold = 10;

  /// join time out
  static const int joinTimeOutInterval = 45;

  static final int _defaultGridSide = 2;

  static int get defaultGridSide => _defaultGridSide;

  /// gridSide * gridSide
  /// /*/*/
  /// /*/*/
  static final int _gridSize = _defaultGridSide * _defaultGridSide;

  /// min show grid size  must bigger than 2, because every page show self
  static final minGridSize = 2;

  /// gallery self render size
  static final int selfRenderSize = 2;

  factory MeetingConfig() => _instance ??= (_instance = MeetingConfig._internal());

  static MeetingConfig? _instance;

  MeetingConfig._internal();

  static SDKConfig? globalConfig;

  int get pageSize{
    var i = SDKConfig.galleryPageSize;

    if (i < minGridSize) {
      i = minGridSize;
    }
    return i;
  }

  ///except me, server push every page size if null show default size,
  int get pageSizeExceptMe {
    return pageSize - 1;
  }

  int get focusSwitchInterval {
    return SDKConfig.focusSwitchInterval;
  }

  /// 会议音频录制开启，true：开启，false：关闭，true由服务器抄送给应用的回调接口
  bool get meetingRecordAudioEnable => SDKConfig.meetingRecordAudioEnable;

  /// 会议视频录制开启，true：开启，false：关闭，true由服务器抄送给应用的回调接口
  bool get meetingRecordVideoEnable => SDKConfig.meetingRecordVideoEnable;

  /// 会议录制模式，0：混合与单人，1：混合，2：单人，但只在有值的时候，才会由服务器抄送给应用的回调接口
  NERtcServerRecordMode get meetingRecordMode {
    var mode = SDKConfig.meetingRecordMode;
    if (mode >= NERtcServerRecordMode.values.length || mode < 0) {
      mode = 0;
    }
    return NERtcServerRecordMode.values[mode];
  }
}
