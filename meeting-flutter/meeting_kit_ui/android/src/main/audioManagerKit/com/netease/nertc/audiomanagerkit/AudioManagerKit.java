// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit;

import java.util.Set;

/** 注意： 1.程序中不能有外部音频渲染 2.将程序中sdk的setAudioProfile全部用该类中的setAudioProfile替换 */
public interface AudioManagerKit {
  //包装sdk的setAudioProfile
  int setAudioProfile(int profile, int scenario);
  // 切换音频设备
  void selectAudioDevice(int device);
  // 获取当前选中的音频设备
  int getSelectedAudioDevice();
  // 列举当前连接的所有音频设备
  Set<Integer> enumAudioDevices();
}
