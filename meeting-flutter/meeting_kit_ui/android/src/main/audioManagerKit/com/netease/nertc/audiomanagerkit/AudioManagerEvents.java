// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit;

import java.util.Set;

public interface AudioManagerEvents {
  void onAudioDeviceChanged(
      int selectedAudioDevice, Set<Integer> availableAudioDevices, boolean hasExternalMic);
}
