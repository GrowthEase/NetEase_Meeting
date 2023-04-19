// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.base;

import android.content.BroadcastReceiver;
import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;

public abstract class BroadcastReceiverEventChannel implements EventChannel.StreamHandler {

  public final Context context;

  private EventChannel.EventSink eventSink;

  private BroadcastReceiver receiver;

  public BroadcastReceiverEventChannel(
      Context context,
      FlutterPlugin.FlutterPluginBinding flutterPluginBinding,
      String eventChannelName) {
    this.context = context.getApplicationContext();
    EventChannel eventChannel =
        new EventChannel(flutterPluginBinding.getBinaryMessenger(), eventChannelName);
    eventChannel.setStreamHandler(this);
  }

  public void dispose() {
    eventSink = null;
    if (receiver != null) {
      context.unregisterReceiver(receiver);
      receiver = null;
    }
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
    initReceiver();
  }

  @Override
  public void onCancel(Object arguments) {
    dispose();
  }

  private void initReceiver() {
    if (receiver == null) {
      receiver = registerReceiver();
    }
  }

  protected abstract BroadcastReceiver registerReceiver();

  public void notifyEvent(Object event) {
    if (eventSink != null) {
      eventSink.success(event);
    }
  }
}
