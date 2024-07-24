// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.utils;

import android.annotation.TargetApi;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioDeviceInfo;
import android.os.Handler;
import android.os.Looper;
import com.netease.nertc.audiomanagerkit.AudioDevice;
import java.util.Arrays;

public class DeviceUtil {
  public static String audioDeviceToString(int[] devices) {
    StringBuilder sb = new StringBuilder();
    sb.append("[");
    if (devices == null) {
      return sb.append("null]").toString();
    } else {
      int[] var2 = devices;
      int var3 = devices.length;

      for (int var4 = 0; var4 < var3; ++var4) {
        int device = var2[var4];
        sb.append(audioDeviceToString(device)).append(" ");
      }

      sb.append("]");
      return sb.toString();
    }
  }

  public static String audioDeviceToString(int device) {
    switch (device) {
      case AudioDevice.SPEAKER_PHONE:
        return "SPEAKER_PHONE";
      case AudioDevice.WIRED_HEADSET:
        return "WIRED_HEADSET";
      case AudioDevice.EARPIECE:
        return "EARPIECE";
      case AudioDevice.BLUETOOTH:
        return "BLUETOOTH";
      case AudioDevice.NONE:
        return "NONE";
      default:
        return "UNKNOWN";
    }
  }

  public static String audioModeToString(int mode) {
    switch (mode) {
      case -2:
        return "MODE_INVALID";
      case -1:
        return "MODE_CURRENT";
      case 0:
        return "MODE_NORMAL";
      case 1:
        return "MODE_RINGTONE";
      case 2:
        return "MODE_IN_CALL";
      case 3:
        return "MODE_IN_COMMUNICATION";
      default:
        return "Unknown:" + mode;
    }
  }

  private static String audioDeviceTypeToString(int type) {
    switch (type) {
      case 0:
        return "UNKNOWN";
      case 1:
        return "BUILTIN_EARPIECE";
      case 2:
        return "BUILTIN_SPEAKER";
      case 3:
        return "WIRED_HEADSET";
      case 4:
        return "WIRED_HEADPHONES";
      case 5:
        return "LINE_ANALOG";
      case 6:
        return "LINE_DIGITAL";
      case 7:
        return "BLUETOOTH_SCO";
      case 8:
        return "BLUETOOTH_A2DP";
      case 9:
        return "HDMI";
      case 10:
        return "HDMI_ARC";
      case 11:
        return "USB_DEVICE";
      case 12:
        return "USB_ACCESSORY";
      case 13:
        return "DOCK";
      case 14:
        return "FM";
      case 15:
        return "BUILTIN_MIC";
      case 16:
        return "FM_TUNER";
      case 17:
        return "TV_TUNER";
      case 18:
        return "TELEPHONY";
      case 19:
        return "AUX_LINE";
      case 20:
        return "IP";
      case 21:
        return "BUS";
      case 22:
        return "USB_HEADSET";
      default:
        return "UNKNOWN:" + type;
    }
  }

  @TargetApi(23)
  public static String audioDeviceInfoToString(AudioDeviceInfo info) {
    StringBuilder sb = new StringBuilder();
    if (info != null) {
      sb.append("type:").append(audioDeviceTypeToString(info.getType())).append(", ");
      sb.append("name:").append(info.getProductName()).append(", ");
      sb.append("sink:").append(info.isSink()).append(", ");
      sb.append("source:").append(info.isSource()).append(", ");
      sb.append("sample rate:").append(Arrays.toString(info.getSampleRates())).append(", ");
      sb.append("channels counts:").append(Arrays.toString(info.getChannelCounts())).append(", ");
      sb.append("id:").append(info.getId());
    }

    return sb.toString();
  }

  public static Intent safeRegisterReceiver(
      Context context, BroadcastReceiver receiver, IntentFilter filter) {
    Handler handler = null;
    Looper currentLooper = Looper.myLooper();
    if (currentLooper != null) {
      handler = new Handler(currentLooper);
    }

    return context.registerReceiver(receiver, filter, (String) null, handler);
  }

  public static String audioFocusChangeToString(int focusChange) {
    String typeOfChange;
    switch (focusChange) {
      case -3:
        typeOfChange = "AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK";
        break;
      case -2:
        typeOfChange = "AUDIOFOCUS_LOSS_TRANSIENT";
        break;
      case -1:
        typeOfChange = "AUDIOFOCUS_LOSS";
        break;
      case 0:
      default:
        typeOfChange = "AUDIOFOCUS_INVALID";
        break;
      case 1:
        typeOfChange = "AUDIOFOCUS_GAIN";
        break;
      case 2:
        typeOfChange = "AUDIOFOCUS_GAIN_TRANSIENT";
        break;
      case 3:
        typeOfChange = "AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK";
        break;
      case 4:
        typeOfChange = "AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE";
    }

    return typeOfChange;
  }

  public static String streamTypeToString(int type) {
    switch (type) {
      case 0:
        return "STREAM_VOICE_CALL";
      case 1:
        return "STREAM_SYSTEM";
      case 2:
        return "STREAM_RING";
      case 3:
        return "STREAM_MUSIC";
      case 4:
        return "STREAM_ALARM";
      case 5:
        return "STREAM_NOTIFICATION";
      case 6:
      case 7:
      case 8:
      case 9:
      default:
        return "Unknown:" + type;
      case 10:
        return "STREAM_ACCESSIBILITY";
    }
  }
}
