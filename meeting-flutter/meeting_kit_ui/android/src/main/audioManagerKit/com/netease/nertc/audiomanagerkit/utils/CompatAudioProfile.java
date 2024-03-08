// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.utils;

public class CompatAudioProfile {
  private int audioMode;
  private int streamType;

  public CompatAudioProfile(int audio_mode, int stream_type) {
    audioMode = audio_mode;
    streamType = stream_type;
  }

  public int getAudioMode() {
    return audioMode;
  }

  public void setAudioMode(int audioMode) {
    this.audioMode = audioMode;
  }

  public int getStreamType() {
    return streamType;
  }

  public void setStreamType(int streamType) {
    this.streamType = streamType;
  }
}
