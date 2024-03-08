// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.utils;

import static android.Manifest.permission.ACCESS_NETWORK_STATE;
import static android.Manifest.permission.ACCESS_WIFI_STATE;
import static android.Manifest.permission.BLUETOOTH;
import static android.Manifest.permission.CAMERA;
import static android.Manifest.permission.INTERNET;
import static android.Manifest.permission.MODIFY_AUDIO_SETTINGS;
import static android.Manifest.permission.RECORD_AUDIO;
import static android.Manifest.permission.WAKE_LOCK;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

import android.content.Context;
import android.content.pm.PackageManager;
import java.util.ArrayList;
import java.util.List;

/**
 * NRTC 运行需要的权限
 *
 * <p>注意: 1, Ringer 可能需要 android.permission.VIBRATE 权限 2, Android M 开始, MODE_IN_CALL 需要新的
 * android.Manifest.permission.MODIFY_PHONE_STATE 权限 3, Android S 开始, 蓝牙相关的需要新的
 * android.Manifest.permission.BLUETOOTH_CONNECT 权限
 */
public class SystemPermissionUtils {

  private static final ArrayList<String> PERMISSIONS = new ArrayList<>(16);
  private static final String BLUETOOTH_CONNECT = "android.permission.BLUETOOTH_CONNECT";

  static {
    PERMISSIONS.add(RECORD_AUDIO);
    PERMISSIONS.add(CAMERA);
    PERMISSIONS.add(INTERNET);
    PERMISSIONS.add(ACCESS_NETWORK_STATE);
    PERMISSIONS.add(ACCESS_WIFI_STATE);
    PERMISSIONS.add(WRITE_EXTERNAL_STORAGE);
    PERMISSIONS.add(WAKE_LOCK);
    PERMISSIONS.add(BLUETOOTH);
    PERMISSIONS.add(MODIFY_AUDIO_SETTINGS);
    if (Compatibility.runningOnSnowConeOrHigher()) {
      PERMISSIONS.add(BLUETOOTH_CONNECT);
    }
  }

  public static boolean checkBluetoothPermission(Context context) {
    return checkPermission(context, BLUETOOTH);
  }

  public static boolean checkBluetoothConnectPermission(Context context) {
    return checkPermission(context, BLUETOOTH_CONNECT);
  }

  public static boolean checkBluetoothScoConnectPermission(Context context) {
    return Compatibility.runningOnSnowConeOrHigher()
        ? checkBluetoothConnectPermission(context)
        : checkBluetoothPermission(context);
  }

  private static boolean checkPermission(Context context, String permission) {
    return context.checkPermission(
            permission, android.os.Process.myPid(), android.os.Process.myUid())
        == PackageManager.PERMISSION_GRANTED;
  }

  public static List<String> checkPermission(Context context) {
    List<String> list = new ArrayList<>();

    for (String permission : PERMISSIONS) {
      if (!checkPermission(context, permission)) {
        list.add(permission);
      }
    }

    return list;
  }
}
