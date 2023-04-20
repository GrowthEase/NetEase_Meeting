// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.phonestate;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Process;
import android.telecom.TelecomManager;
import android.telephony.TelephonyManager;
import android.util.Log;
import com.netease.meeting.plugin.base.BroadcastReceiverEventChannel;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import java.util.HashMap;
import java.util.Map;

public class PhoneStateService extends BroadcastReceiverEventChannel {

  private static final String TAG = "PhoneStateService";

  private static final String STATE_EVENT_CHANNEL_NAME =
      "meeting_plugin.phone_state_service.states";

  private final TelecomManager telecomManager;

  public PhoneStateService(
      Context context, FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
    super(context, flutterPluginBinding, STATE_EVENT_CHANNEL_NAME);
    telecomManager = (TelecomManager) context.getSystemService(Context.TELECOM_SERVICE);
  }

  @Override
  protected BroadcastReceiver registerReceiver() {
    if (telecomManager == null) {
      return null;
    }
    notifyInCallState();
    BroadcastReceiver receiver =
        new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
            notifyInCallState();
          }
        };
    IntentFilter intent = new IntentFilter(TelephonyManager.ACTION_PHONE_STATE_CHANGED);
    context.registerReceiver(receiver, intent);
    Log.d(TAG, "Phone state receiver registered.");
    return receiver;
  }

  private void notifyInCallState() {
    final boolean isInCall = hasPhoneStatePermission() && telecomManager.isInCall();
    Log.d(TAG, "notifyInCallState=" + isInCall);
    Map<String, Boolean> map = new HashMap<>();
    map.put("isInCall", isInCall);
    notifyEvent(map);
  }

  private boolean hasPhoneStatePermission() {
    return context.checkPermission(
            Manifest.permission.READ_PHONE_STATE, Process.myPid(), Process.myUid())
        == PackageManager.PERMISSION_GRANTED;
  }
}
