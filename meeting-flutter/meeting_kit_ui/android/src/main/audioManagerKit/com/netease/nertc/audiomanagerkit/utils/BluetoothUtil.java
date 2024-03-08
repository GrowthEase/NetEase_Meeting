// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.utils;

import android.bluetooth.BluetoothA2dp;
import android.bluetooth.BluetoothClass;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothHeadset;
import android.util.Log;
import com.netease.lava.webrtc.Logging;
import java.lang.reflect.Method;

public class BluetoothUtil {

  public static final String TAG = "BluetoothUtil";

  public static String getBluetoothDeviceType(BluetoothDevice device) {
    if (device == null || device.getBluetoothClass() == null) {
      return "device is null";
    }
    String deviceType = null;
    switch (device.getBluetoothClass().getMajorDeviceClass()) {
      case BluetoothClass.Device.Major.MISC:
        deviceType = "MISC";
        break;
      case BluetoothClass.Device.Major.COMPUTER:
        deviceType = "COMPUTER";
        break;
      case BluetoothClass.Device.Major.PHONE:
        deviceType = "PHONE";
        break;
      case BluetoothClass.Device.Major.NETWORKING:
        deviceType = "NETWORKING";
        break;
      case BluetoothClass.Device.Major.AUDIO_VIDEO:
        deviceType = "AUDIO_VIDEO";
        break;
      case BluetoothClass.Device.Major.PERIPHERAL:
        deviceType = "PERIPHERAL";
        break;
      case BluetoothClass.Device.Major.IMAGING:
        deviceType = "IMAGING";
        break;
      case BluetoothClass.Device.Major.WEARABLE: // 可穿戴设备
        deviceType = "WEARABLE";
        break;
      case BluetoothClass.Device.Major.TOY:
        deviceType = "TOY";
        break;
      case BluetoothClass.Device.Major.HEALTH:
        deviceType = "HEALTH";
        break;
      case BluetoothClass.Device.Major.UNCATEGORIZED:
      default:
        deviceType = "UNCATEGORIZED";
        break;
    }
    return "[major_type:"
        + deviceType
        + " , minor_type: "
        + Integer.toHexString(device.getBluetoothClass().getDeviceClass())
        + "]";
  }

  // for testing
  public static boolean connectHFP(BluetoothHeadset hfp, BluetoothDevice device) {
    boolean ret = false;
    Method connect = null;
    try {
      connect = BluetoothHeadset.class.getDeclaredMethod("connect", BluetoothDevice.class);
      connect.setAccessible(true);
      ret = (boolean) connect.invoke(hfp, device);
    } catch (Exception e) {
      Logging.e(TAG, "connectHfp exception: " + Log.getStackTraceString(e));
    }
    return ret;
  }

  // for testing
  public static boolean disconnectHFP(BluetoothHeadset hfp, BluetoothDevice device) {
    boolean ret = false;
    Method connect = null;
    try {
      connect = BluetoothHeadset.class.getDeclaredMethod("disconnect", BluetoothDevice.class);
      connect.setAccessible(true);
      ret = (boolean) connect.invoke(hfp, device);
    } catch (Exception e) {
      Logging.e(TAG, "disconnectHFP exception: " + Log.getStackTraceString(e));
    }
    return ret;
  }

  // for testing
  public static boolean connectA2DP(BluetoothA2dp a2dp, BluetoothDevice device) {
    boolean ret = false;
    Method connect = null;
    try {
      connect = BluetoothA2dp.class.getDeclaredMethod("connect", BluetoothDevice.class);
      connect.setAccessible(true);
      ret = (boolean) connect.invoke(a2dp, device);
    } catch (Exception e) {
      Logging.e(TAG, "connectA2dp exception: " + Log.getStackTraceString(e));
    }
    return ret;
  }

  // for testing
  public static boolean disconnectA2DP(BluetoothA2dp a2dp, BluetoothDevice device) {
    boolean ret = false;
    Method connect = null;
    try {
      connect = BluetoothA2dp.class.getDeclaredMethod("disconnect", BluetoothDevice.class);
      connect.setAccessible(true);
      ret = (boolean) connect.invoke(a2dp, device);
    } catch (Exception e) {
      Logging.e(TAG, "disconnectA2DP exception: " + Log.getStackTraceString(e));
    }
    return ret;
  }
}
