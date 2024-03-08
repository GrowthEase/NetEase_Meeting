// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.bluetooth;

import android.content.Context;
import android.media.AudioDeviceCallback;
import android.media.AudioDeviceInfo;
import android.os.Build;
import android.util.Log;
import com.netease.nertc.audiomanagerkit.impl.AudioManagerImpl;
import com.netease.nertc.audiomanagerkit.utils.DeviceUtil;

public class FakeBluetoothManager extends BluetoothManagerWrapper {

  private static final String TAG = "FakeBluetoothManager";
  private AudioDeviceCallback mAudioDeviceCallback;

  public FakeBluetoothManager(Context context, AudioManagerImpl manager) {
    super(context, manager);
    mBlueToothSCO = false;
    Log.i(TAG, "ctor");
  }

  @Override
  public void start() {
    mBluetoothState = State.HEADSET_UNAVAILABLE;
    registerAudioDeviceCallback(true);
  }

  @Override
  public void stop() {
    registerAudioDeviceCallback(false);
    mBluetoothState = State.UNINITIALIZED;
  }

  @Override
  public void setAudioBlueToothSCO(boolean blueToothSCO) {
    // always false
    mBlueToothSCO = false;
  }

  private void registerAudioDeviceCallback(boolean register) {
    if (!register && mAudioDeviceCallback != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        mAudioManager.unregisterAudioDeviceCallback(mAudioDeviceCallback);
      }
      mAudioDeviceCallback = null;
      return;
    }

    if (register && mAudioDeviceCallback == null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        mAudioDeviceCallback =
            new AudioDeviceCallback() {
              @Override
              public void onAudioDevicesAdded(AudioDeviceInfo[] addedDevices) {
                if (addedDevices == null || addedDevices.length == 0) {
                  Log.i(TAG, "    Devices info is null!!");
                  return;
                }
                for (AudioDeviceInfo info : addedDevices) {
                  if (info.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP) {
                    Log.i(
                        TAG, "Bluetooth Devices Added " + DeviceUtil.audioDeviceInfoToString(info));
                    mBluetoothState = State.SCO_CONNECTED;
                    updateAudioDeviceState();
                    return;
                  }
                }
              }

              @Override
              public void onAudioDevicesRemoved(AudioDeviceInfo[] removedDevices) {
                if (removedDevices == null || removedDevices.length == 0) {
                  Log.i(TAG, "    Devices info is null!!");
                  return;
                }
                for (AudioDeviceInfo info : removedDevices) {
                  if (info.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP) {
                    Log.i(
                        TAG,
                        "Bluetooth Devices Removed " + DeviceUtil.audioDeviceInfoToString(info));
                    mBluetoothState = State.HEADSET_UNAVAILABLE;
                    updateAudioDeviceState();
                    return;
                  }
                }
              }
            };
      }
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        mAudioManager.registerAudioDeviceCallback(mAudioDeviceCallback, mHandler);
      }
    }
  }

  private void updateAudioDeviceState() {
    mHandler.postDelayed(
        () -> {
          DemoAudioDeviceManager.updateAudioDeviceState();
          mHandler.postDelayed(DemoAudioDeviceManager::updateAudioDeviceState, 1000);
        },
        500);
  }
}
