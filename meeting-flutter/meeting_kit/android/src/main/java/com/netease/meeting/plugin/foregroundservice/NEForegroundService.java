// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.foregroundservice;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.text.TextUtils;
import android.util.Log;
import com.netease.yunxin.flutter.plugins.roomkit.RoomKitEventDispatcher;
import com.netease.yunxin.flutter.plugins.roomkit.RoomKitEventListener;
import java.util.HashSet;
import java.util.Map;

public class NEForegroundService extends Service {

  private static final String TAG = "NEForegroundService";

  private static final String KEY_SERVICE_TYPE = "serviceType";
  private static final String SERVICE_TYPE_MEDIA_PROJECTION = "mediaProjection";
  private static final String SERVICE_TYPE_MICROPHONE = "microphone";

  public static final int ONGOING_NOTIFICATION_ID = 0x9527;

  private static ForegroundServiceConfig foregroundServiceConfig;

  private static final StartForegroundServiceListener startForegroundServiceListener =
      new StartForegroundServiceListener();

  static ForegroundServiceConfig getForegroundServiceConfig() {
    return foregroundServiceConfig;
  }

  public static void start(Context context, Map config, String serviceType) {
    ForegroundServiceConfig fsc = ForegroundServiceConfig.fromMap(config);
    if (fsc == null) {
      return;
    }
    foregroundServiceConfig = fsc;
    if (NENotificationManager.getInstance().ensureNotification(context) == null) {
      Log.i(TAG, "ensure notification fail, ignore start service.");
      return;
    }
    Intent intent = getServiceLaunchIntent(context, serviceType);
    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        // Android 14 or later：屏幕共享的前台服务需要在用户授权后才能开启
        if (Build.VERSION.SDK_INT >= 34 && SERVICE_TYPE_MEDIA_PROJECTION.equals(serviceType)) {
          startForegroundServiceListener.register(
              () -> {
                Log.e(TAG, "startForegroundService after permission granted");
                context.startForegroundService(intent);
              });
          return;
        }
        Log.e(TAG, "startForegroundService");
        context.startForegroundService(intent);
      } else {
        Log.e(TAG, "startService");
        context.startService(intent);
      }
    } catch (Throwable throwable) {
      Log.e(TAG, "startService error", throwable);
    }
  }

  private static Intent getServiceLaunchIntent(Context context, String type) {
    Intent intent = new Intent(context, NEForegroundService.class);
    intent.putExtra(KEY_SERVICE_TYPE, type);
    return intent;
  }

  public static void cancel(Context context) {
    // stopService may throw remoteException.
    //
    // if the service had been started as foreground, but
    // being brought down before actually showing a notification.
    // That is not allowed.
    try {
      context.stopService(new Intent(context, NEForegroundService.class));
      NENotificationManager.getInstance().cancelNotification(context, ONGOING_NOTIFICATION_ID);
    } catch (Exception e) {
      Log.e(TAG, "cancel foreground service error", e);
    }
    startForegroundServiceListener.unregister();
  }

  private Notification notification;
  private final HashSet<String> serviceTypes = new HashSet<>();

  @Override
  public void onCreate() {
    Log.i(TAG, "onCreate");
    super.onCreate();
    notification = NENotificationManager.getInstance().getNotification();
  }

  @Override
  public void onDestroy() {
    Log.i(TAG, "onDestroy");
    super.onDestroy();
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    Log.i(TAG, "onStartCommand");
    onStartForeground(intent);
    super.onStartCommand(intent, flags, startId);
    return START_NOT_STICKY;
  }

  @SuppressLint("NewApi")
  private void onStartForeground(Intent intent) {
    if (notification == null) {
      Log.i(TAG, "onStartForeground without notification");
      return;
    }
    String serviceType = intent.getStringExtra(KEY_SERVICE_TYPE);
    if (!TextUtils.isEmpty(serviceType)) {
      serviceTypes.add(serviceType);
    }

    int foregroundServiceType = determineForegroundServiceType();
    if (foregroundServiceType != 0) {
      startForeground(ONGOING_NOTIFICATION_ID, notification, foregroundServiceType);
    } else {
      startForeground(ONGOING_NOTIFICATION_ID, notification);
    }

    Log.i(
        TAG,
        "onStartForeground: serviceType="
            + serviceType
            + ", foregroundServiceType="
            + Long.toHexString(foregroundServiceType));
  }

  private int determineForegroundServiceType() {
    int type = 0;
    for (String serviceType : serviceTypes) {
      if (SERVICE_TYPE_MEDIA_PROJECTION.equals(serviceType)
          && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        type |= ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION;
      } else if (SERVICE_TYPE_MICROPHONE.equals(serviceType)
          && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        type |= ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE;
      }
    }
    return type;
  }

  @Override
  public IBinder onBind(Intent intent) {
    return null;
  }

  private static class StartForegroundServiceListener extends RoomKitEventListener {
    private Runnable action;

    public void register(Runnable action) {
      this.action = action;
      RoomKitEventDispatcher.INSTANCE.addListener(this);
    }

    public void unregister() {
      this.action = null;
      RoomKitEventDispatcher.INSTANCE.removeListener(this);
    }

    @Override
    public void onBeforeStartScreenCapture() {
      if (action != null) action.run();
    }
  }
}
