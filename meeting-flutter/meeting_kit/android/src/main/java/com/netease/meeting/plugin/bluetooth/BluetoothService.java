// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.bluetooth;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import com.netease.meeting.plugin.base.BroadcastReceiverEventChannel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import java.util.HashMap;
import java.util.Map;

public class BluetoothService extends BroadcastReceiverEventChannel {

  private static final String STATE_EVENT_CHANNEL_NAME = "meeting_plugin.bluetooth_service.states";

  private final BluetoothAdapter bluetoothAdapter;

  public BluetoothService(
      Context context, FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
    super(context, flutterPluginBinding, STATE_EVENT_CHANNEL_NAME);
    BluetoothManager bluetoothManager =
        (BluetoothManager) context.getSystemService(Context.BLUETOOTH_SERVICE);
    bluetoothAdapter = bluetoothManager.getAdapter();
  }

  @Override
  protected BroadcastReceiver registerReceiver() {
    notifyState();

    BroadcastReceiver receiver =
        new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
            notifyState();
          }
        };
    IntentFilter intent = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
    context.registerReceiver(receiver, intent);
    return receiver;
  }

  private void notifyState() {
    Map<String, Boolean> data = new HashMap<>();
    data.put("enabled", bluetoothAdapter.isEnabled());
    notifyEvent(data);
  }
}
