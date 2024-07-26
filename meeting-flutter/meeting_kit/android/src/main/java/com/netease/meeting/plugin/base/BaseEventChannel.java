// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.base;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;

public abstract class BaseEventChannel implements EventChannel.StreamHandler {

  public final Context context;

  private EventChannel.EventSink eventSink;

  public BaseEventChannel(
      Context context,
      FlutterPlugin.FlutterPluginBinding flutterPluginBinding,
      String eventChannelName) {
    this.context = context.getApplicationContext();
    EventChannel eventChannel =
        new EventChannel(flutterPluginBinding.getBinaryMessenger(), eventChannelName);
    eventChannel.setStreamHandler(this);
  }

  public void dispose() {
    if (eventSink != null) {
      try {
        eventSink.endOfStream();
      } catch (Throwable e) {
      }
      eventSink = null;
    }
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
  }

  @Override
  public void onCancel(Object arguments) {
    dispose();
  }

  public void notifyEvent(Object event) {
    if (eventSink != null) {
      eventSink.success(event);
    }
  }
}
