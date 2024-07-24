// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.impl;

import static android.media.AudioManager.AUDIOFOCUS_GAIN;
import static com.netease.nertc.audiomanagerkit.utils.DeviceUtil.audioDeviceToString;
import static com.netease.nertc.audiomanagerkit.utils.DeviceUtil.audioModeToString;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.media.AudioDeviceInfo;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.webrtc.Logging;
import com.netease.nertc.audiomanagerkit.AudioDevice;
import com.netease.nertc.audiomanagerkit.AudioManagerEvents;
import com.netease.nertc.audiomanagerkit.AudioManagerKit;
import com.netease.nertc.audiomanagerkit.bluetooth.BluetoothManagerWrapper;
import com.netease.nertc.audiomanagerkit.utils.ArrayUtils;
import com.netease.nertc.audiomanagerkit.utils.CompatAudioProfile;
import com.netease.nertc.audiomanagerkit.utils.Compatibility;
import com.netease.nertc.audiomanagerkit.utils.DeviceUtil;
import com.netease.nertc.audiomanagerkit.utils.SystemPermissionUtils;
import com.netease.yunxin.lite.util.CancelableTask;
import com.netease.yunxin.lite.util.LooperUtils;
import java.util.HashSet;
import java.util.Set;

public class AudioManagerImpl implements AudioManagerKit {
  public static String TAG = "DemoAudioManager";
  private static android.media.AudioManager mAudioManager;
  private static WiredHeadsetReceiver mWiredHeadsetReceiver;
  private final Context mContext;
  private int mSavedAudioMode = android.media.AudioManager.MODE_INVALID;
  private boolean mSavedIsSpeakerPhoneOn = false;
  private boolean mSavedIsMicrophoneMute = false;
  private BluetoothManagerWrapper mBluetoothManager;
  private boolean mHasWiredHeadset = false;
  private volatile int mSelectedAudioDevice = AudioDevice.NONE;
  private int mUserSelectedAudioDevice = AudioDevice.NONE;
  private int mDefaultAudioDevice = AudioDevice.NONE;
  private Set<Integer> mAudioDevices = new HashSet<>();
  private AudioManagerEvents mAudioManagerEvents;
  private boolean wiredHeadsetHasMic = false;
  private Handler mHandler;
  private boolean bluetoothTryReconnect;
  private AudioManagerState mAudioManagerState;
  private volatile CancelableTask setModeTask;
  private CompatAudioProfile audioVoipProfile = new CompatAudioProfile(3, 0);
  private CompatAudioProfile audioMusicProfile = new CompatAudioProfile(0, 3);
  private static CompatAudioProfile mAudioProfile = new CompatAudioProfile(3, 0);
  private int mScenario;

  private android.media.AudioManager.OnAudioFocusChangeListener mAudioFocusChangeListener;

  public AudioManagerImpl(Context context, AudioManagerEvents audioManagerEvents) {
    mContext = context;
    mAudioManager = ((android.media.AudioManager) context.getSystemService(Context.AUDIO_SERVICE));
    mBluetoothManager = BluetoothManagerWrapper.create(context, this, 12000);
    mWiredHeadsetReceiver = new WiredHeadsetReceiver();
    mAudioManagerState = AudioManagerState.UNINITIALIZED;
    mAudioManagerEvents = audioManagerEvents;
    start(AudioDevice.SPEAKER_PHONE, AUDIOFOCUS_GAIN, true);
  }

  public void start(int defaultAudioDevice, int focusMode, boolean isHFP) {

    Log.i(
        TAG,
        "start , defaultAudioDevice: "
            + defaultAudioDevice
            + " , focusMode: "
            + focusMode
            + " , isHFP: "
            + isHFP);
    if (mAudioManagerState == AudioManagerState.RUNNING) {
      Logging.e(TAG, "AudioManager is already active");
      return;
    }
    if (mHandler != null) {
      LooperUtils.quitSafely(mHandler);
      mHandler = null;
    }
    HandlerThread handlerThread = new HandlerThread(TAG);
    handlerThread.start();
    mHandler = new Handler(handlerThread.getLooper());
    mAudioManagerState = AudioManagerState.RUNNING;
    bluetoothTryReconnect = false;
    saveAudioStatus();
    mHasWiredHeadset = hasWiredHeadset();
    UpdateAudioProfileConfig();
    registerAudioFocusRequest(true, mAudioProfile.getStreamType(), focusMode);
    setMicrophoneMute(false);
    mUserSelectedAudioDevice = AudioDevice.NONE;
    mSelectedAudioDevice = AudioDevice.NONE;
    if (mDefaultAudioDevice == AudioDevice.NONE) {
      mDefaultAudioDevice = defaultAudioDevice;
    }
    mAudioDevices.clear();
    setAudioBlueToothSCO(isHFP);
    mBluetoothManager.start();
    mContext.registerReceiver(mWiredHeadsetReceiver, new IntentFilter(Intent.ACTION_HEADSET_PLUG));
    updateAudioDeviceState();
  }

  public void setAudioBlueToothSCO(boolean blueToothSCO) {
    if (mBluetoothManager == null) {
      Logging.w(TAG, "setAudioBlueToothSCO but NPL: " + blueToothSCO);
      return;
    }
    if (blueToothSCO && !SystemPermissionUtils.checkBluetoothScoConnectPermission(mContext)) {
      blueToothSCO = false;
      Logging.e(TAG, "setAudioBlueToothSCO no permission");
    }

    boolean reStartBlueTooth =
        (mSelectedAudioDevice == AudioDevice.BLUETOOTH)
            && (blueToothSCO != mBluetoothManager.blueToothIsSCO());
    mBluetoothManager.setAudioBlueToothSCO(blueToothSCO);
    if (reStartBlueTooth) {
      reconnectBlueTooth();
    }
    Logging.i(TAG, "setAudioBlueToothSCO: " + blueToothSCO + " , re start: " + reStartBlueTooth);
  }

  public void reconnectBlueTooth() {
    bluetoothTryReconnect = true;
    updateAudioDeviceState();
    bluetoothTryReconnect = false;
  }

  public void updateAudioDeviceState() {
    if (mAudioManagerState != AudioManagerState.RUNNING) {
      Logging.w(TAG, "updateAudioDeviceState , but state is :" + mAudioManagerState);
      return;
    }
    Log.i(
        TAG,
        "updateAudioDeviceState current device status: wired headset="
            + mHasWiredHeadset
            + ", reconnect="
            + bluetoothTryReconnect
            + ", bluetooth state="
            + mBluetoothManager.getState()
            + ", available="
            + audioDeviceToString(ArrayUtils.toPrimitive(mAudioDevices.toArray(new Integer[0])))
            + ", pre worked="
            + audioDeviceToString(mSelectedAudioDevice)
            + ", user selected="
            + audioDeviceToString(mUserSelectedAudioDevice));

    if (bluetoothTryReconnect
        && mBluetoothManager.getState() == BluetoothManagerWrapper.State.UNINITIALIZED) {
      bluetoothTryReconnect = false;
    }

    if (mBluetoothManager.getState() == BluetoothManagerWrapper.State.HEADSET_AVAILABLE
        || mBluetoothManager.getState() == BluetoothManagerWrapper.State.HEADSET_UNAVAILABLE
        || mBluetoothManager.getState() == BluetoothManagerWrapper.State.SCO_DISCONNECTING
        || bluetoothTryReconnect) {
      mBluetoothManager.updateDevice();
    }

    Set<Integer> newAudioDevices = new HashSet<>();

    if (mBluetoothManager.getState() == BluetoothManagerWrapper.State.SCO_CONNECTED
        || mBluetoothManager.getState() == BluetoothManagerWrapper.State.SCO_CONNECTING
        || mBluetoothManager.getState() == BluetoothManagerWrapper.State.HEADSET_AVAILABLE) {
      newAudioDevices.add(AudioDevice.BLUETOOTH);
    }

    if (mHasWiredHeadset) {
      newAudioDevices.add(AudioDevice.WIRED_HEADSET);
    } else {
      newAudioDevices.add(AudioDevice.SPEAKER_PHONE);
      if (hasEarpiece()) {
        newAudioDevices.add(AudioDevice.EARPIECE);
      }
    }

    /// 蓝牙耳机或者有线耳机新增时，重置用户选择的设备
    if (!mAudioDevices.contains(AudioDevice.BLUETOOTH)
        && newAudioDevices.contains(AudioDevice.BLUETOOTH)) {
      mUserSelectedAudioDevice = AudioDevice.NONE;
    }
    if (!mAudioDevices.contains(AudioDevice.WIRED_HEADSET)
        && newAudioDevices.contains(AudioDevice.WIRED_HEADSET)) {
      mUserSelectedAudioDevice = AudioDevice.NONE;
    }

    boolean audioDeviceSetUpdated = !mAudioDevices.equals(newAudioDevices);
    mAudioDevices = newAudioDevices;

    int userSelectedRet = mUserSelectedAudioDevice;
    //no bluetooth headset
    if (mUserSelectedAudioDevice == AudioDevice.BLUETOOTH
        && (mBluetoothManager.getState() == BluetoothManagerWrapper.State.HEADSET_UNAVAILABLE
            || mBluetoothManager.getState() == BluetoothManagerWrapper.State.UNINITIALIZED)) {
      userSelectedRet = AudioDevice.NONE;
    }
    //no wired headset
    if (!mHasWiredHeadset && mUserSelectedAudioDevice == AudioDevice.WIRED_HEADSET) {
      userSelectedRet = AudioDevice.NONE;
    }

    int newAudioDevice = mDefaultAudioDevice;
    if (userSelectedRet != AudioDevice.NONE) {
      newAudioDevice = userSelectedRet;
    } else if (mBluetoothManager.getState() != BluetoothManagerWrapper.State.HEADSET_UNAVAILABLE
        && mBluetoothManager.getState() != BluetoothManagerWrapper.State.UNINITIALIZED
        && mBluetoothManager.canConnectToDevice()) {
      newAudioDevice = AudioDevice.BLUETOOTH;
    } else if (mHasWiredHeadset) {
      newAudioDevice = AudioDevice.WIRED_HEADSET;
    } else if (newAudioDevice == AudioDevice.SPEAKER_PHONE
        && mSelectedAudioDevice == AudioDevice.WIRED_HEADSET) {
      newAudioDevice = AudioDevice.EARPIECE;
    } else if (newAudioDevice == AudioDevice.SPEAKER_PHONE
        && mSelectedAudioDevice == AudioDevice.BLUETOOTH) {
      newAudioDevice = AudioDevice.EARPIECE;
    }
    Log.i(TAG, "newAudioDevice:" + newAudioDevice);

    boolean needStopBluetooth =
        (mBluetoothManager.getState() == BluetoothManagerWrapper.State.SCO_CONNECTED
                || mBluetoothManager.getState() == BluetoothManagerWrapper.State.SCO_CONNECTING)
            && (newAudioDevice != AudioDevice.NONE && newAudioDevice != AudioDevice.BLUETOOTH);

    boolean needStartBluetooth =
        mBluetoothManager.getState() == BluetoothManagerWrapper.State.HEADSET_AVAILABLE
            && (newAudioDevice == AudioDevice.NONE || newAudioDevice == AudioDevice.BLUETOOTH);

    Log.i(
        TAG,
        "updateAudioDeviceState bluetooth audio: start="
            + needStartBluetooth
            + ", stop="
            + needStopBluetooth
            + ", state="
            + mBluetoothManager.getState()
            + ", userSelectedRet="
            + audioDeviceToString(userSelectedRet));

    boolean deviceChanged = newAudioDevice != mSelectedAudioDevice || audioDeviceSetUpdated;
    if (deviceChanged) {
      setAudioDeviceInternal(newAudioDevice);
      Log.i(
          TAG,
          "updateAudioDeviceState new device status: available="
              + audioDeviceToString(ArrayUtils.toPrimitive(mAudioDevices.toArray(new Integer[0])))
              + " , selected="
              + audioDeviceToString(newAudioDevice));
    }

    if (needStopBluetooth) {
      mBluetoothManager.stopScoAudio();
      mBluetoothManager.updateDevice();
    }

    if (bluetoothTryReconnect || needStartBluetooth) {
      if (!mBluetoothManager.startScoAudio()) {
        mAudioDevices.remove(AudioDevice.BLUETOOTH);
      }
    }
    boolean bluetoothReconnected = newAudioDevice == AudioDevice.BLUETOOTH && bluetoothTryReconnect;
    if (deviceChanged || bluetoothReconnected) {
      UpdateAudioProfileConfig();
      if (mAudioManagerEvents != null) {
        mAudioManagerEvents.onAudioDeviceChanged(
            mSelectedAudioDevice, mAudioDevices, hasExternalMic(newAudioDevice));
      }
    }
    Log.i(TAG, "updateAudioDeviceState done");
  }

  public int setAudioProfile(int profile, int scenario) {
    mScenario = scenario;
    UpdateAudioProfileConfig();
    return NERtcEx.getInstance().setAudioProfile(profile, scenario);
  }

  public void restartBluetooth() {
    mBluetoothManager.stop();
    mBluetoothManager = BluetoothManagerWrapper.create(mContext, this, 12000);
    mBluetoothManager.start();
  }

  public void selectAudioDevice(int audioDevice) {
    mUserSelectedAudioDevice = audioDevice;
    updateAudioDeviceState();
  }

  public int getSelectedAudioDevice() {
    return mSelectedAudioDevice;
  }

  public Set<Integer> enumAudioDevices() {
    Set<Integer> deviceSet = new HashSet<>();
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
      AudioDeviceInfo[] devices =
          mAudioManager.getDevices(android.media.AudioManager.GET_DEVICES_OUTPUTS);
      for (AudioDeviceInfo deviceInfo : devices) {
        switch (deviceInfo.getType()) {
          case AudioDeviceInfo.TYPE_BUILTIN_SPEAKER:
            deviceSet.add(AudioDevice.SPEAKER_PHONE);
            break;
          case AudioDeviceInfo.TYPE_WIRED_HEADSET:
          case AudioDeviceInfo.TYPE_USB_HEADSET:
            deviceSet.add(AudioDevice.WIRED_HEADSET);
            break;
          case AudioDeviceInfo.TYPE_BUILTIN_EARPIECE:
            deviceSet.add(AudioDevice.EARPIECE);
            break;
          case AudioDeviceInfo.TYPE_BLUETOOTH_A2DP:
          case AudioDeviceInfo.TYPE_BLUETOOTH_SCO:
            deviceSet.add(AudioDevice.BLUETOOTH);
            break;
          default:
            break;
        }
      }
    }
    return deviceSet;
  }

  private void setAudioDeviceInternal(int device) {
    Log.i(TAG, "setAudioDeviceInternal(device=" + audioDeviceToString(device) + ")");
    switch (device) {
      case AudioDevice.SPEAKER_PHONE:
        setSpeakerphoneOn(true);
        break;
      case AudioDevice.EARPIECE:
      case AudioDevice.WIRED_HEADSET:
      case AudioDevice.BLUETOOTH:
        setSpeakerphoneOn(false);
        break;
      default:
        Log.e(TAG, "Invalid audio device selection");
        break;
    }

    mSelectedAudioDevice = device;
  }

  private boolean hasExternalMic(int selectedAudioDevice) {

    boolean hasExternalMic = false;

    if (Compatibility.runningOnMarshmallowOrHigher()) {
      AudioDeviceInfo[] devices =
          mAudioManager.getDevices(android.media.AudioManager.GET_DEVICES_INPUTS);
      for (AudioDeviceInfo deviceInfo : devices) {
        if ((deviceInfo.getType() == AudioDeviceInfo.TYPE_WIRED_HEADSET
                && selectedAudioDevice == AudioDevice.WIRED_HEADSET)
            || (deviceInfo.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_SCO
                && selectedAudioDevice == AudioDevice.BLUETOOTH)) {
          hasExternalMic = true;
          break;
        }
      }
    } else {
      if (selectedAudioDevice == AudioDevice.WIRED_HEADSET) {
        hasExternalMic = wiredHeadsetHasMic;
      } else if (selectedAudioDevice == AudioDevice.BLUETOOTH) {
        //对于 Android 6.0.0 以下的版本 ，如果是蓝牙的话 ， 直接返回true ， 在有些情况下可能有问题
        hasExternalMic = true;
      }
    }
    Logging.i(
        TAG,
        "hasExternalMic : "
            + hasExternalMic
            + " , selectedAudioDevice: "
            + audioDeviceToString(selectedAudioDevice));
    return hasExternalMic;
  }

  private void registerAudioFocusRequest(boolean register, int streamType, int focusMode) {
    if (register) {
      if (mAudioFocusChangeListener == null) {
        mAudioFocusChangeListener =
            focusChange -> {
              String typeOfChange = DeviceUtil.audioFocusChangeToString(focusChange);
              Logging.i(TAG, "onAudioFocusChange: " + typeOfChange);
            };

        int result =
            mAudioManager.requestAudioFocus(mAudioFocusChangeListener, streamType, focusMode);
        if (result == android.media.AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
          Logging.i(
              TAG,
              "Audio focus request granted for " + (DeviceUtil.streamTypeToString(streamType)));
        } else {
          Logging.e(TAG, "Audio focus request failed");
        }
      }
    } else {
      if (mAudioFocusChangeListener != null) {
        mAudioManager.abandonAudioFocus(mAudioFocusChangeListener);
        mAudioFocusChangeListener = null;
        Logging.i(TAG, "Abandoned audio focus ");
      }
    }
  }

  private void UpdateAudioProfileConfig() {
    if (mSelectedAudioDevice == AudioDevice.BLUETOOTH) {
      if (!mBluetoothManager.blueToothIsSCO()) {
        mAudioProfile.setAudioMode(0); // AudioManager.MODE_NORMAL
        mAudioProfile.setStreamType(3); // AudioManager.STREAM_MUSIC
      } else { // USE_HFP
        mAudioProfile.setAudioMode(3); // AudioManager.MODE_IN_COMMUNICATION
        mAudioProfile.setStreamType(0); // AudioManager.STREAM_VOICE_CALL
      }
    } else if (mSelectedAudioDevice == AudioDevice.EARPIECE) {
      mAudioProfile.setAudioMode(3); // AudioManager.MODE_IN_COMMUNICATION
      mAudioProfile.setStreamType(0); // AudioManager.STREAM_VOICE_CALL
    } else {
      if (mScenario == 0 || mScenario == 1 || mScenario == 3) {
        mAudioProfile = audioVoipProfile;
      } else if (mScenario == 2) {
        mAudioProfile = audioMusicProfile;
      }
    }
    if (mAudioProfile != null) setmode(mAudioProfile.getAudioMode());
  }

  private void setmode(int audioMode) {
    if (setModeTask != null) {
      setModeTask.cancel();
    }
    setModeTask =
        new CancelableTask("LavaAudioDeviceManager#setModeAsync") {
          @Override
          public void action() {
            //此处是为了双保险，start play 的时候，也会调用 setMode ，这里打印异常并不代表有问题，防止stop 的时候，还在执行 setMode
            // 参考 WebRtcAudioTrack WebRtcAudioManager 中的setMode
            if (mAudioManagerState != AudioManagerState.RUNNING) {
              Logging.w(
                  TAG,
                  "dynamic set audio mode in incorrect state: "
                      + mAudioManagerState
                      + " , mode: "
                      + audioModeToString(audioMode));
              return;
            }
            if (mAudioManager.getMode() == audioMode) {
              Logging.w(
                  TAG,
                  "dynamic set audio mode no change: " + audioModeToString(audioMode) + "  done");
              return;
            }
            if (isCanceled()) {
              Logging.w(
                  TAG, "dynamic set audio mode but cancel , mode: " + audioModeToString(audioMode));
              return;
            }
            mAudioManager.setMode(audioMode);
            Logging.w(TAG, "dynamic set audio mode: " + audioModeToString(audioMode) + "  done");
          }
        };

    if (mHandler != null) {
      mHandler.post(setModeTask);
    } else {
      setModeTask.run();
    }
    mAudioManager.setMode(audioMode);
  }

  private void setSpeakerphoneOn(boolean on) {
    mAudioManager.setSpeakerphoneOn(on);
    Log.i(TAG, "setSpeakerphoneOn " + on + " ,result -> " + mAudioManager.isSpeakerphoneOn());
  }

  private void saveAudioStatus() {
    mSavedAudioMode = mAudioManager.getMode();
    mSavedIsSpeakerPhoneOn = mAudioManager.isSpeakerphoneOn();
    mSavedIsMicrophoneMute = mAudioManager.isMicrophoneMute();
    Log.i(
        TAG,
        "save system audio state[audio mode:"
            + audioModeToString(mSavedAudioMode)
            + ", microphone mute:"
            + mSavedIsMicrophoneMute
            + ", speakerphone on:"
            + mSavedIsSpeakerPhoneOn
            + "]");
  }

  private boolean hasEarpiece() {
    return mContext.getPackageManager().hasSystemFeature(PackageManager.FEATURE_TELEPHONY);
  }

  @SuppressWarnings("deprecation")
  private boolean hasWiredHeadset() {
    return mAudioManager.isWiredHeadsetOn();
  }

  private void setMicrophoneMute(boolean on) {
    boolean wasMuted = mAudioManager.isMicrophoneMute();
    if (wasMuted == on) {
      return;
    }
    mAudioManager.setMicrophoneMute(on);
  }

  public void stop() {
    Log.i(TAG, "stop");
    mAudioManagerState = AudioManagerState.UNINITIALIZED;
    try {
      mContext.unregisterReceiver(mWiredHeadsetReceiver);
    } catch (Exception e) {
      Log.w(TAG, e.getMessage());
    }
    mBluetoothManager.stop();
    registerAudioFocusRequest(false, 0, 0);
    restoreAudioStatus();
    if (mHandler != null) {
      LooperUtils.quitSafely(mHandler);
      mHandler = null;
    }
    mSelectedAudioDevice = AudioDevice.NONE;
    mAudioManagerEvents = null;
    Log.i(TAG, "AudioManager stopped");
  }

  public static CompatAudioProfile getmAudioProfile() {
    return mAudioProfile;
  }

  private void restoreAudioStatus() {
    Log.i(TAG, "restore audio status");
    setMicrophoneMute(mSavedIsMicrophoneMute);
    Log.i(TAG, "restore setMicrophoneMute done");
    if (mSelectedAudioDevice == AudioDevice.SPEAKER_PHONE
        || mSelectedAudioDevice == AudioDevice.EARPIECE) {
      setSpeakerphoneOn(mSavedIsSpeakerPhoneOn);
      Logging.i(TAG, "restore setSpeakerphoneOn done");
    }
    if (mSavedAudioMode != android.media.AudioManager.MODE_INVALID) {
      mAudioManager.setMode(mSavedAudioMode);
    }
    Log.i(
        TAG,
        "restore system audio state[audio mode:"
            + audioModeToString(mSavedAudioMode)
            + ", microphone mute:"
            + mSavedIsMicrophoneMute
            + ", speakerphone on:"
            + mSavedIsSpeakerPhoneOn
            + "]");
  }

  private class WiredHeadsetReceiver extends BroadcastReceiver {

    private static final int STATE_UNPLUGGED = 0;
    private static final int STATE_PLUGGED = 1;
    private static final int HAS_NO_MIC = 0;
    private static final int HAS_MIC = 1;

    @Override
    public void onReceive(Context context, Intent intent) {
      int state = intent.getIntExtra("state", STATE_UNPLUGGED);
      int microphone = intent.getIntExtra("microphone", HAS_NO_MIC);
      String name = intent.getStringExtra("name");
      Log.i(
          TAG,
          "WiredHeadsetReceiver.onReceive: "
              + "a="
              + intent.getAction()
              + ", s="
              + (state == STATE_UNPLUGGED ? "unplugged" : "plugged")
              + ", m="
              + (microphone == HAS_MIC ? "mic" : "no mic")
              + ", n="
              + name
              + ", sb="
              + isInitialStickyBroadcast());
      mHasWiredHeadset = (state == STATE_PLUGGED);
      wiredHeadsetHasMic = (state == STATE_PLUGGED) && (microphone == HAS_MIC);
      updateAudioDeviceState();
    }
  }

  private enum AudioManagerState {
    UNINITIALIZED,
    RUNNING,
  }
}
