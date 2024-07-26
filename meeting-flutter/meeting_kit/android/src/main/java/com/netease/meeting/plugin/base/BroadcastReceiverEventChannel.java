// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.base;

import android.content.BroadcastReceiver;
import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;

public abstract class BroadcastReceiverEventChannel extends BaseEventChannel {

  private BroadcastReceiver receiver;

  public BroadcastReceiverEventChannel(
      Context context,
      FlutterPlugin.FlutterPluginBinding flutterPluginBinding,
      String eventChannelName) {
    super(context, flutterPluginBinding, eventChannelName);
  }

  public void dispose() {
    super.dispose();
    if (receiver != null) {
      context.unregisterReceiver(receiver);
      receiver = null;
    }
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    super.onListen(arguments, events);
    initReceiver();
  }

  private void initReceiver() {
    if (receiver == null) {
      receiver = registerReceiver();
    }
  }

  protected abstract BroadcastReceiver registerReceiver();
}
