// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.bluetooth;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import com.netease.lava.webrtc.Logging;
import com.netease.nertc.audiomanagerkit.impl.AudioManagerImpl;
import com.netease.nertc.audiomanagerkit.utils.SystemPermissionUtils;

public abstract class BluetoothManagerWrapper {
  private static final String TAG = "AbsBluetoothManager";

  public enum State {
    UNINITIALIZED,
    HEADSET_UNAVAILABLE,
    HEADSET_AVAILABLE,
    SCO_DISCONNECTING,
    SCO_CONNECTING,
    SCO_CONNECTED
  }

  public static BluetoothManagerWrapper create(
      Context context, AudioManagerImpl manager, int bluetoothSCOTimeoutMs) {
    Logging.i(TAG, "create bluetooth manager");

    //https://developer.android.com/guide/topics/connectivity/bluetooth/permissions
    int targetVersion = context.getApplicationInfo().targetSdkVersion;
    // Android 12 校验 BLUETOOTH_CONNECT 权限
    boolean hasBluetoothPermission =
        SystemPermissionUtils.checkBluetoothScoConnectPermission(context);
    if (!hasBluetoothPermission) {
      Logging.e(TAG, "missing  permission , create FakeBluetoothManager");
      Logging.e(
          TAG,
          "has bluetooth permission: " + SystemPermissionUtils.checkBluetoothPermission(context));
      Logging.e(
          TAG,
          "has bluetoothConnect permission："
              + SystemPermissionUtils.checkBluetoothConnectPermission(context));
      Logging.e(TAG, "targetVersion：" + targetVersion + ", sdk int: " + Build.VERSION.SDK_INT);
      return new FakeBluetoothManager(context, manager);
    }

    return new BluetoothManager(context, manager, bluetoothSCOTimeoutMs);
  }

  protected final Context mContext;
  protected final AudioManagerImpl DemoAudioDeviceManager;
  protected final android.media.AudioManager mAudioManager;
  protected final Handler mHandler;
  protected State mBluetoothState;
  protected volatile boolean mBlueToothSCO;

  public BluetoothManagerWrapper(Context context, AudioManagerImpl manager) {
    mContext = context;
    DemoAudioDeviceManager = manager;
    mAudioManager = (android.media.AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
    mHandler = new Handler(Looper.getMainLooper());
    mBluetoothState = State.UNINITIALIZED;
  }

  public abstract void start();

  public abstract void stop();

  public abstract void setAudioBlueToothSCO(boolean blueToothSCO);

  public boolean blueToothIsSCO() {
    return mBlueToothSCO;
  }

  public void stopScoAudio() {}

  public void updateDevice() {}

  public boolean startScoAudio() {
    return true;
  }

  public State getState() {
    return mBluetoothState;
  }
}
