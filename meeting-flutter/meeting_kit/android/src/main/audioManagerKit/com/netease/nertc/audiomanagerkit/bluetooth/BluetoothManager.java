// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.bluetooth;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothClass;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothHeadset;
import android.bluetooth.BluetoothProfile;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.media.MediaRecorder;
import android.util.Log;
import com.netease.lava.webrtc.Logging;
import com.netease.nertc.audiomanagerkit.impl.AudioManagerImpl;
import com.netease.nertc.audiomanagerkit.utils.BluetoothUtil;
import com.netease.nertc.audiomanagerkit.utils.DeviceUtil;
import com.netease.nertc.audiomanagerkit.utils.SystemPermissionUtils;
import com.netease.yunxin.lite.audio.AudioDeviceCompatibility;
import java.util.List;
import java.util.Set;

public class BluetoothManager extends BluetoothManagerWrapper {
  private static final String TAG = "BluetoothManager";
  private static final int MIN_BLUETOOTH_SCO_TIMEOUT_MS = 2000;
  private static final int MAX_SCO_CONNECTION_ATTEMPTS = 3;
  private int mBluetoothSCOTimeoutMs = 12000;

  private int mScoConnectionAttempts;

  private final BluetoothProfile.ServiceListener mBluetoothServiceListener;
  private BluetoothAdapter mBluetoothAdapter;
  private BluetoothHeadset mBluetoothHeadset;
  private BluetoothDevice mBluetoothDevice;
  private final BroadcastReceiver mBluetoothHeadsetReceiver;
  private boolean needStopSco = false;

  public BluetoothManager(Context context, AudioManagerImpl manager, int bluetoothSCOTimeoutMs) {
    super(context, manager);
    Logging.i(TAG, "ctor");
    mBluetoothServiceListener = new BluetoothServiceListener();
    mBluetoothHeadsetReceiver = new BluetoothHeadsetBroadcastReceiver();
    mBluetoothSCOTimeoutMs = Math.max(MIN_BLUETOOTH_SCO_TIMEOUT_MS, bluetoothSCOTimeoutMs);
    mBlueToothSCO = true;
  }

  public void start() {
    if (!SystemPermissionUtils.checkBluetoothScoConnectPermission(mContext)) {
      Logging.e(TAG, "no  bluetooth  permission for start");
      return;
    }

    if (!mAudioManager.isBluetoothScoAvailableOffCall()) {
      Logging.e(TAG, "bluetooth is not available off call");
    }

    if (mBluetoothState != State.UNINITIALIZED) {
      Logging.e(TAG, "Invalid bluetooth state");
      return;
    }

    mBluetoothHeadset = null;
    mBluetoothDevice = null;
    mScoConnectionAttempts = 0;
    mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    if (mBluetoothAdapter == null) {
      Logging.e(TAG, "bluetooth is not supported  on this hardware platform");
      return;
    }

    logBluetoothAdapterInfo(mBluetoothAdapter);

    if (!mBluetoothAdapter.getProfileProxy(
        mContext, mBluetoothServiceListener, BluetoothProfile.HEADSET)) {
      Logging.e(TAG, "BluetoothAdapter.getProfileProxy(HEADSET) failed");
      return;
    }

    IntentFilter filter = new IntentFilter();
    filter.addAction(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED);
    filter.addAction(BluetoothHeadset.ACTION_AUDIO_STATE_CHANGED);
    filter.addAction(android.media.AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED);
    DeviceUtil.safeRegisterReceiver(mContext, mBluetoothHeadsetReceiver, filter);

    setBluetoothState(mBluetoothAdapter.getProfileConnectionState(BluetoothProfile.HEADSET));
  }

  private void setBluetoothState(int state) {
    Logging.i(TAG, "HEADSET profile state: " + connectionStateToString(state));
    switch (state) {
      case BluetoothHeadset.STATE_CONNECTED:
        mBluetoothState = State.HEADSET_AVAILABLE;
        break;
      case BluetoothHeadset.STATE_CONNECTING:
      case BluetoothHeadset.STATE_DISCONNECTED:
      case BluetoothHeadset.STATE_DISCONNECTING:
        mBluetoothState = State.HEADSET_UNAVAILABLE;
        break;
      default:
        Logging.e(TAG, "Invalid BluetoothHeadset state: " + state);
        break;
    }
    Logging.i(TAG, "New headset state: " + mBluetoothState);
  }

  @Override
  public void stop() {
    try {
      mContext.unregisterReceiver(mBluetoothHeadsetReceiver);
    } catch (Exception ignore) {

    }
    Logging.i(TAG, "stop: bluetooth state=" + mBluetoothState);
    if (mBluetoothAdapter != null) {
      stopScoAudio();
      if (mBluetoothState != State.UNINITIALIZED) {
        cancelTimer();
        if (mBluetoothHeadset != null) {
          mBluetoothAdapter.closeProfileProxy(BluetoothProfile.HEADSET, mBluetoothHeadset);
          mBluetoothHeadset = null;
        }
        mBluetoothAdapter = null;
        mBluetoothDevice = null;
        mBluetoothState = State.UNINITIALIZED;
      }
    }
    Logging.i(TAG, "stop done: bluetooth state=" + mBluetoothState);
  }

  public State getState() {
    return mBluetoothState;
  }

  private class BluetoothServiceListener implements BluetoothProfile.ServiceListener {

    @Override
    public void onServiceConnected(int profile, BluetoothProfile proxy) {
      if (profile != BluetoothProfile.HEADSET || mBluetoothState == State.UNINITIALIZED) {
        return;
      }
      Logging.i(
          TAG, "BluetoothServiceListener.onServiceConnected: bluetooth state=" + mBluetoothState);
      mBluetoothHeadset = (BluetoothHeadset) proxy;
      mBluetoothState = State.HEADSET_AVAILABLE;
      updateAudioDeviceState();
      Logging.i(
          TAG,
          "BluetoothServiceListener.onServiceConnected done: bluetooth state=" + mBluetoothState);
    }

    @Override
    public void onServiceDisconnected(int profile) {
      if (profile != BluetoothProfile.HEADSET || mBluetoothState == State.UNINITIALIZED) {
        return;
      }
      Logging.i(
          TAG,
          "BluetoothServiceListener.onServiceDisconnected: bluetooth state=" + mBluetoothState);
      stopScoAudio();
      mBluetoothHeadset = null;
      mBluetoothDevice = null;
      mBluetoothState = State.HEADSET_UNAVAILABLE;
      updateAudioDeviceState();
      Logging.i(
          TAG,
          "BluetoothServiceListener.onServiceDisconnected done: bluetooth state="
              + mBluetoothState);
    }
  }

  private class BluetoothHeadsetBroadcastReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
      if (mBluetoothState == State.UNINITIALIZED) {
        return;
      }
      final String action = intent.getAction();

      if (BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED.equals(action)) {
        final int state =
            intent.getIntExtra(BluetoothHeadset.EXTRA_STATE, BluetoothHeadset.STATE_DISCONNECTED);
        final int preState =
            intent.getIntExtra(
                BluetoothHeadset.EXTRA_PREVIOUS_STATE, BluetoothHeadset.STATE_DISCONNECTED);
        final BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

        Logging.i(
            TAG,
            "BluetoothHeadsetReceiver.onReceive: "
                + "a=ACTION_CONNECTION_STATE_CHANGED, "
                + "s="
                + connectionStateToString(state)
                + ", "
                + "ps="
                + connectionStateToString(preState)
                + ", "
                + "sb="
                + isInitialStickyBroadcast()
                + ", "
                + "bluetooth state="
                + mBluetoothState
                + ", "
                + "d="
                + (device == null ? "null" : device.getName())
                + ", "
                + "ds="
                + connectionStateToString(
                    mBluetoothHeadset == null ? -1 : mBluetoothHeadset.getConnectionState(device)));

        if (state == BluetoothHeadset.STATE_CONNECTED) {
          mScoConnectionAttempts = 0;
          updateAudioDeviceState();
        } else if (state == BluetoothHeadset.STATE_DISCONNECTED) {
          stopScoAudio();
          updateAudioDeviceState();
        }
      } else if (action.equals(BluetoothHeadset.ACTION_AUDIO_STATE_CHANGED)) {
        final int state =
            intent.getIntExtra(
                BluetoothHeadset.EXTRA_STATE, BluetoothHeadset.STATE_AUDIO_DISCONNECTED);
        final int preState =
            intent.getIntExtra(
                BluetoothHeadset.EXTRA_PREVIOUS_STATE, BluetoothHeadset.STATE_AUDIO_DISCONNECTED);
        final BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

        Logging.i(
            TAG,
            "BluetoothHeadsetReceiver.onReceive: "
                + "a=ACTION_AUDIO_STATE_CHANGED, "
                + "s="
                + audioStateToString(state)
                + ", "
                + "ps="
                + audioStateToString(preState)
                + ", "
                + "sb="
                + isInitialStickyBroadcast()
                + ", "
                + "bluetooth state="
                + mBluetoothState
                + ", "
                + "d="
                + (device == null ? "null" : device.getName())
                + ", "
                + "d_type ="
                + BluetoothUtil.getBluetoothDeviceType(device)
                + ", "
                + "sco="
                + (mBluetoothHeadset == null
                    ? "false"
                    : mBluetoothHeadset.isAudioConnected(device)));

        if (state == BluetoothHeadset.STATE_AUDIO_CONNECTED) {
          cancelTimer();
          if (mBluetoothState == State.SCO_CONNECTING) {
            mBluetoothState = State.SCO_CONNECTED;
            mScoConnectionAttempts = 0;
            updateAudioDeviceState();
          } else {
            Logging.e(
                TAG,
                "BluetoothHeadsetReceiver.Unexpected state BluetoothHeadset.STATE_AUDIO_CONNECTED");
          }
        } else if (state == BluetoothHeadset.STATE_AUDIO_DISCONNECTED) {
          Logging.i(TAG, "BluetoothHeadsetReceiver.bluetooth audio sco is now disconnected");
          if (isInitialStickyBroadcast()) {
            Logging.i(
                TAG,
                "BluetoothHeadsetReceiver.Ignore STATE_AUDIO_DISCONNECTED initial sticky broadcast.");
            return;
          }
          updateAudioDeviceState();
        }
      } else if (action.equals(android.media.AudioManager.ACTION_SCO_AUDIO_STATE_UPDATED)) {
        final int state =
            intent.getIntExtra(
                android.media.AudioManager.EXTRA_SCO_AUDIO_STATE,
                android.media.AudioManager.SCO_AUDIO_STATE_DISCONNECTED);
        final int preState =
            intent.getIntExtra(
                android.media.AudioManager.EXTRA_SCO_AUDIO_PREVIOUS_STATE,
                android.media.AudioManager.SCO_AUDIO_STATE_DISCONNECTED);
        Logging.i(
            TAG,
            "BluetoothHeadsetReceiver.onReceive: "
                + "a=ACTION_SCO_AUDIO_STATE_UPDATED, "
                + "s="
                + scoStateToString(state)
                + ", "
                + "ps="
                + scoStateToString(preState)
                + ", "
                + "sb="
                + isInitialStickyBroadcast()
                + ", "
                + "bluetooth state="
                + mBluetoothState);
      }
    }
  }

  @Override
  public boolean startScoAudio() {
    Logging.i(
        TAG,
        "startScoAudio: bluetooth state="
            + mBluetoothState
            + ", attempts: "
            + mScoConnectionAttempts
            + ", sco is on: "
            + mAudioManager.isBluetoothScoOn());
    if (mScoConnectionAttempts >= MAX_SCO_CONNECTION_ATTEMPTS) {
      Logging.e(TAG, "bluetooth sco connection fails - no more attempts");
      return false;
    }
    if (mBluetoothState != State.HEADSET_AVAILABLE) {
      Logging.e(TAG, "bluetooth sco connection fails - no headset available");
      return false;
    }
    mBluetoothState = State.SCO_CONNECTING;

    if (!mBlueToothSCO) {
      Logging.i(TAG, "sco will not enabled , need stop sco:" + needStopSco);
      if (needStopSco) {
        mAudioManager.stopBluetoothSco();
        needStopSco = false;
      }
      mAudioManager.setBluetoothScoOn(false);
      // 将 A2DP 模式打开
      mAudioManager.setBluetoothA2dpOn(true);
    } else {
      //启动 SCO 连接
      mAudioManager.startBluetoothSco();
      //将音频路由到 SCO 连接
      mAudioManager.setBluetoothScoOn(true);
      mScoConnectionAttempts++;
      startTimer();
      needStopSco = true;
    }
    Logging.i(
        TAG,
        "startScoAudio done: bluetooth state = "
            + mBluetoothState
            + " , sco is on: "
            + mBlueToothSCO);
    return true;
  }

  @Override
  public void stopScoAudio() {
    Logging.i(
        TAG,
        "stopScoAudio: bluetooth state="
            + mBluetoothState
            + ", sco is on: "
            + mAudioManager.isBluetoothScoOn()
            + " , needStopSco:"
            + needStopSco);
    if (mBluetoothState != State.SCO_CONNECTING && mBluetoothState != State.SCO_CONNECTED) {
      return;
    }
    cancelTimer();
    if (needStopSco) {
      mAudioManager.stopBluetoothSco();
      needStopSco = false;
    }
    mBluetoothState = State.SCO_DISCONNECTING;
  }

  private void logBluetoothAdapterInfo(BluetoothAdapter localAdapter) {
    try {
      Logging.i(
          TAG,
          "BluetoothAdapter: "
              + "enabled="
              + localAdapter.isEnabled()
              + ", "
              + "state="
              + adapterStateToString(localAdapter.getState())
              + ", "
              + "name="
              + localAdapter.getName());
      Set<BluetoothDevice> pairedDevices = localAdapter.getBondedDevices();
      if (!pairedDevices.isEmpty()) {
        Logging.i(TAG, "paired devices:");
        for (BluetoothDevice device : pairedDevices) {
          Logging.i(
              TAG,
              "name="
                  + device.getName()
                  + " , type = "
                  + BluetoothUtil.getBluetoothDeviceType(device));
        }
      }
    } catch (Exception e) {
      Logging.e(TAG, "logBluetoothAdapterInfo error : " + Log.getStackTraceString(e));
    }
  }

  private String connectionStateToString(int state) {
    switch (state) {
      case BluetoothProfile.STATE_DISCONNECTED:
        return "DISCONNECTED";
      case BluetoothProfile.STATE_CONNECTING:
        return "CONNECTING";
      case BluetoothProfile.STATE_CONNECTED:
        return "CONNECTED";
      case BluetoothProfile.STATE_DISCONNECTING:
        return "DISCONNECTING";
      default:
        return "INVALID(" + state + ")";
    }
  }

  private String audioStateToString(int state) {
    switch (state) {
      case BluetoothHeadset.STATE_AUDIO_CONNECTED:
        return "CONNECTED";
      case BluetoothHeadset.STATE_AUDIO_CONNECTING:
        return "CONNECTING";
      case BluetoothHeadset.STATE_AUDIO_DISCONNECTED:
        return "DISCONNECTED";
      default:
        return "INVALID(" + state + ")";
    }
  }

  @Override
  public void setAudioBlueToothSCO(boolean blueToothSCO) {
    Logging.i(TAG, "setAudioBlueToothSCO: " + blueToothSCO);
    mBlueToothSCO = blueToothSCO;
  }

  public boolean blueToothIsSCO() {
    return mBlueToothSCO;
  }

  private String scoStateToString(int state) {
    switch (state) {
      case android.media.AudioManager.SCO_AUDIO_STATE_DISCONNECTED:
        return "DISCONNECTED";
      case android.media.AudioManager.SCO_AUDIO_STATE_CONNECTED:
        return "CONNECTED";
      case android.media.AudioManager.SCO_AUDIO_STATE_CONNECTING:
        return "CONNECTING";
      default:
        return "ERROR (" + state + ")";
    }
  }

  private String adapterStateToString(int state) {
    switch (state) {
      case BluetoothAdapter.STATE_OFF:
        return "OFF";
      case BluetoothAdapter.STATE_ON:
        return "ON";
      case BluetoothAdapter.STATE_TURNING_OFF:
        return "TURNING_OFF";
      case BluetoothAdapter.STATE_TURNING_ON:
        return "TURNING_ON";
      default:
        return "INVALID(" + state + ")";
    }
  }

  private void startTimer() {
    Logging.i(TAG, "startTimer , time out: " + mBluetoothSCOTimeoutMs);
    mHandler.postDelayed(mBluetoothTimeoutRunnable, mBluetoothSCOTimeoutMs);
  }

  private void cancelTimer() {
    Logging.i(TAG, "cancelTimer");
    mHandler.removeCallbacks(mBluetoothTimeoutRunnable);
  }

  private final Runnable mBluetoothTimeoutRunnable =
      new Runnable() {
        @Override
        public void run() {
          bluetoothTimeout();
        }
      };

  private void bluetoothTimeout() {
    if (mBluetoothState == State.UNINITIALIZED || mBluetoothHeadset == null) {
      return;
    }
    Logging.e(
        TAG,
        "bluetoothTimeout: bluetooth state="
            + mBluetoothState
            + ", "
            + "attempts: "
            + mScoConnectionAttempts
            + ", "
            + "sco is on: "
            + mAudioManager.isBluetoothScoOn());
    if (mBluetoothState != State.SCO_CONNECTING) {
      return;
    }
    boolean scoConnected = false;
    List<BluetoothDevice> devices = mBluetoothHeadset.getConnectedDevices();
    if (!devices.isEmpty()) {
      mBluetoothDevice = devices.get(0);
      // Check if bluetooth sco audio is connected.
      if (mBluetoothHeadset.isAudioConnected(mBluetoothDevice)) {
        Logging.i(
            TAG,
            "sco connected with "
                + mBluetoothDevice.getName()
                + " , type: "
                + BluetoothUtil.getBluetoothDeviceType(mBluetoothDevice));
        scoConnected = true;
      } else {
        if (!mBlueToothSCO
            && (AudioDeviceCompatibility.getAudioSource() == MediaRecorder.AudioSource.MIC
                || AudioDeviceCompatibility.getAudioSource() == MediaRecorder.AudioSource.DEFAULT)
            && AudioManagerImpl.getmAudioProfile().getStreamType() == AudioManager.STREAM_MUSIC
            && AudioManagerImpl.getmAudioProfile().getAudioMode() == AudioManager.MODE_NORMAL) {
          //音频策略，不从蓝牙耳机的麦克风采集，不能打开SCO
          Logging.i(TAG, "sco is not connected ,fake connection " + mBluetoothDevice.getName());
          scoConnected = true;
        }
        Logging.i(TAG, "sco is not connected with " + mBluetoothDevice.getName());
      }
    }

    if (scoConnected) {
      mBluetoothState = State.SCO_CONNECTED;
      mScoConnectionAttempts = 0;
    } else {
      Logging.e(TAG, "bluetooth failed to connect after timeout");
      stopScoAudio();
    }
    updateAudioDeviceState();
  }

  private void updateAudioDeviceState() {
    DemoAudioDeviceManager.updateAudioDeviceState();
  }

  @Override
  public void updateDevice() {
    if (mBluetoothState == State.UNINITIALIZED || mBluetoothHeadset == null) {
      return;
    }
    List<BluetoothDevice> devices = mBluetoothHeadset.getConnectedDevices();
    if (devices.isEmpty()) {
      mBluetoothDevice = null;
      mBluetoothState = State.HEADSET_UNAVAILABLE;
      Logging.w(TAG, "updateDevice no connected bluetooth headset");
    } else {
      for (BluetoothDevice device : devices) {
        int deviceType = device.getBluetoothClass().getMajorDeviceClass();
        Logging.i(
            TAG,
            "updateDevice connected bluetooth headset: "
                + ", name="
                + device.getName()
                + ", "
                + ", state="
                + connectionStateToString(mBluetoothHeadset.getConnectionState(device))
                + ", type="
                + BluetoothUtil.getBluetoothDeviceType(device)
                + ", sco audio="
                + mBluetoothHeadset.isAudioConnected(device));
        if (deviceType == BluetoothClass.Device.Major.AUDIO_VIDEO
            || deviceType == BluetoothClass.Device.Major.MISC
            || deviceType == BluetoothClass.Device.Major.UNCATEGORIZED) {
          mBluetoothDevice = device;
          mBluetoothState = State.HEADSET_AVAILABLE;
          return;
        }
      }
      mBluetoothDevice = null;
      mBluetoothState = State.HEADSET_UNAVAILABLE;
    }
  }
}
