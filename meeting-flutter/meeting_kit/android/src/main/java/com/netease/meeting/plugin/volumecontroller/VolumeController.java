// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.volumecontroller;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.util.Log;
import com.netease.meeting.plugin.base.BroadcastReceiverEventChannel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

public class VolumeController extends BroadcastReceiverEventChannel {

  private static final String STATE_EVENT_CHANNEL_NAME =
      "meeting_plugin.volume_listener_event.states";

  private static final int STREAM_TYPE = AudioManager.STREAM_VOICE_CALL;

  private AudioManager audioManager;

  private int volume = -1;

  public VolumeController(
      Context context, FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
    super(context, flutterPluginBinding, STATE_EVENT_CHANNEL_NAME);
    audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
  }

  @Override
  protected BroadcastReceiver registerReceiver() {
    BroadcastReceiver receiver =
        new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
            if (intent.getIntExtra("android.media.EXTRA_VOLUME_STREAM_TYPE", -1) == STREAM_TYPE) {
              sendVolumeInfo();
            }
          }
        };
    IntentFilter intent = new IntentFilter("android.media.VOLUME_CHANGED_ACTION");
    context.registerReceiver(receiver, intent);
    volume = -1;
    sendVolumeInfo();
    return receiver;
  }

  private void sendVolumeInfo() {
    int newVolume = audioManager.getStreamVolume(STREAM_TYPE);
    Log.d("VolumeController", "Current volume=" + newVolume);
    if (newVolume != volume) {
      volume = newVolume;
      int maxVolume = audioManager.getStreamMaxVolume(STREAM_TYPE);
      notifyEvent(newVolume * 1.0 / maxVolume);
    }
  }
}
