// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.lifecycle;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ProcessLifecycleOwner;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import java.util.HashMap;
import java.util.Map;

public class AppLifecycleDetector implements EventChannel.StreamHandler, DefaultLifecycleObserver {

  private static final String STATE_EVENT_CHANNEL_NAME =
      "meeting_plugin.app_lifecycle_service.states";

  private final EventChannel eventChannel;
  private EventChannel.EventSink eventSink;

  public AppLifecycleDetector(
      Context context, FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
    eventChannel =
        new EventChannel(flutterPluginBinding.getBinaryMessenger(), STATE_EVENT_CHANNEL_NAME);
    eventChannel.setStreamHandler(this);
    ProcessLifecycleOwner.get().getLifecycle().addObserver(this);
  }

  @Override
  public void onCreate(@NonNull LifecycleOwner owner) {}

  @Override
  public void onResume(@NonNull LifecycleOwner owner) {}

  @Override
  public void onPause(@NonNull LifecycleOwner owner) {}

  @Override
  public void onDestroy(@NonNull LifecycleOwner owner) {}

  @Override
  public void onStart(@NonNull LifecycleOwner owner) {
    sendEvent(false);
  }

  @Override
  public void onStop(@NonNull LifecycleOwner owner) {
    sendEvent(true);
  }

  private void sendEvent(boolean background) {
    if (eventSink == null) return;
    Map<String, Boolean> data = new HashMap<>();
    data.put("isInBackground", background);
    eventSink.success(data);
  }

  public void dispose() {
    eventSink = null;
    eventChannel.setStreamHandler(null);
    ProcessLifecycleOwner.get().getLifecycle().removeObserver(this);
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
  }

  @Override
  public void onCancel(Object arguments) {
    eventSink = null;
  }
}
