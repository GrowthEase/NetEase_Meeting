// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.phonestate;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Process;
import android.telephony.PhoneStateListener;
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

  public PhoneStateService(
      Context context, FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
    super(context, flutterPluginBinding, STATE_EVENT_CHANNEL_NAME);
  }

  private Boolean isInCall = null;

  @Override
  protected BroadcastReceiver registerReceiver() {
    listen(context, phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE);
    notifyInCallState(isCalling(context));
    return null;
  }

  @Override
  public void dispose() {
    super.dispose();
    listen(context, phoneStateListener, PhoneStateListener.LISTEN_NONE);
  }

  private void notifyInCallState(boolean inCall) {
    Log.e(TAG, "notifyInCallState: " + isInCall + " -> " + inCall);
    if (isInCall == null || isInCall != inCall) {
      isInCall = inCall;
      Map<String, Boolean> map = new HashMap<>();
      map.put("isInCall", isInCall);
      notifyEvent(map);
    }
  }

  private boolean hasPhoneStatePermission() {
    return context.checkPermission(
            Manifest.permission.READ_PHONE_STATE, Process.myPid(), Process.myUid())
        == PackageManager.PERMISSION_GRANTED;
  }

  private final PhoneStateListener phoneStateListener =
      new PhoneStateListener() {
        @Override
        public void onCallStateChanged(int state, String phoneNumber) {
          Log.e(TAG, "onCallStateChanged: " + state + "#" + phoneNumber);
          if (state == TelephonyManager.CALL_STATE_IDLE) {
            if (isInCall == Boolean.TRUE && !isCalling(context)) {
              notifyInCallState(false);
            }
          } else if (state == TelephonyManager.CALL_STATE_RINGING
              || state == TelephonyManager.CALL_STATE_OFFHOOK) {
            notifyInCallState(true);
          }
        }
      };

  @SuppressLint("WrongConstant")
  private static boolean isCalling(Context context) {
    TelephonyManager telephonyManager =
        (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
    if (telephonyManager != null) {
      try {
        int callState = telephonyManager.getCallState();
        Log.e(TAG, "PhoneService getCallState: state=" + callState);
        if (callState != TelephonyManager.CALL_STATE_IDLE) {
          return true;
        }

        for (int index = 0; index < 2; index++) {
          callState =
              (int)
                  ReflectionHelper.invokeMethod(
                      telephonyManager,
                      "getCallStateGemini",
                      new Class[] {Integer.TYPE},
                      new Object[] {index});
          Log.e(TAG, "PhoneService getCallStateGemini: index=" + index + ", state=" + callState);
          if (callState != TelephonyManager.CALL_STATE_IDLE) {
            return true;
          }
        }
      } catch (Throwable e) {
        Log.e(TAG, "PhoneService getCallStateGemini error");
      }
    }

    TelephonyManager telephonyManager2 = (TelephonyManager) context.getSystemService("phone2");
    if (telephonyManager2 != null) {
      try {
        int callState = telephonyManager2.getCallState();
        Log.e(TAG, "Phone2Service getCallState: state=" + callState);
        if (callState != TelephonyManager.CALL_STATE_IDLE) {
          return true;
        }

        for (int index = 0; index < 2; index++) {
          callState =
              (int)
                  ReflectionHelper.invokeMethod(
                      telephonyManager2,
                      "getCallStateGemini",
                      new Class[] {Integer.TYPE},
                      new Object[] {index});
          Log.e(TAG, "Phone2Service getCallStateGemini: index=" + index + ", state=" + callState);
          if (callState != TelephonyManager.CALL_STATE_IDLE) {
            return true;
          }
        }
      } catch (Throwable e) {
        Log.e(TAG, "Phone2Service getCallStateGemini error");
      }
    }

    try {
      Object msimTelephonyManager =
          ReflectionHelper.invokeStaticMethod(
              "android.telephony.MSimTelephonyManager", "getDefault", null, null);
      if (msimTelephonyManager != null) {
        for (int index = 0; index < 2; index++) {
          int callState =
              (int)
                  ReflectionHelper.invokeMethod(
                      msimTelephonyManager, "getCallState", new Object[] {index});
          Log.e(TAG, "MSimTelephonyManager getCallState: index=" + index + ", state=" + callState);
          if (callState != TelephonyManager.CALL_STATE_IDLE) {
            return true;
          }
        }
      }
    } catch (Throwable e) {
      Log.e(TAG, "MSimTelephonyManager getCallState error");
    }

    return false;
  }

  @SuppressLint("WrongConstant")
  private static void listen(Context context, PhoneStateListener phoneStateListener, int flag) {
    TelephonyManager telephonyManager =
        (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
    if (telephonyManager != null) {
      try {
        ReflectionHelper.invokeMethod(
            telephonyManager,
            "listen",
            new Class[] {PhoneStateListener.class, Integer.TYPE},
            new Object[] {phoneStateListener, flag});
        Log.e(TAG, "listen to PhoneService succeed0");
        ReflectionHelper.invokeMethod(
            telephonyManager,
            "listenGemini",
            new Class[] {Integer.TYPE, PhoneStateListener.class, Integer.TYPE},
            new Object[] {0, phoneStateListener, flag});
        ReflectionHelper.invokeMethod(
            telephonyManager,
            "listenGemini",
            new Class[] {Integer.TYPE, PhoneStateListener.class, Integer.TYPE},
            new Object[] {1, phoneStateListener, flag});
        Log.e(TAG, "listen to PhoneService succeed1");
      } catch (Throwable unused) {
      }
    } else {
      Log.e(TAG, "PhoneService not found");
    }

    TelephonyManager telephonyManager2;
    try {
      telephonyManager2 = (TelephonyManager) context.getSystemService("phone2");
    } catch (Throwable unused2) {
      telephonyManager2 = null;
      Log.e(TAG, "Phone2Service not found");
    }
    if (telephonyManager2 != null) {
      try {
        ReflectionHelper.invokeMethod(
            telephonyManager2,
            "listen",
            new Class[] {PhoneStateListener.class, Integer.TYPE},
            new Object[] {phoneStateListener, flag});
        Log.e(TAG, "listen to Phone2Service succeed1");
        ReflectionHelper.invokeMethod(
            telephonyManager2,
            "listenGemini",
            new Class[] {Integer.TYPE, PhoneStateListener.class, Integer.TYPE},
            new Object[] {0, phoneStateListener, flag});
        ReflectionHelper.invokeMethod(
            telephonyManager2,
            "listenGemini",
            new Class[] {Integer.TYPE, PhoneStateListener.class, Integer.TYPE},
            new Object[] {1, phoneStateListener, flag});
        Log.e(TAG, "listen to Phone2Service succeed2");
      } catch (Throwable unused3) {
      }
    }

    try {
      ReflectionHelper.invokeMethod(
          ReflectionHelper.invokeStaticMethod(
              "android.telephony.MSimTelephonyManager", "getDefault", null, null),
          "listen",
          new Class[] {PhoneStateListener.class, Integer.TYPE},
          new Object[] {phoneStateListener, flag});
      Log.e(TAG, "listen to MSimTelephonyManager succeed");
    } catch (Throwable unused4) {
      Log.e(TAG, "listen to MSimTelephonyManager error");
    }
  }
}
