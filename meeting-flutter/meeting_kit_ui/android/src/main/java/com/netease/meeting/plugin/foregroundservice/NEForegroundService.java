// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.foregroundservice;

import android.app.Notification;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import com.netease.yunxin.flutter.plugins.roomkit.RoomKitEventDispatcher;
import com.netease.yunxin.flutter.plugins.roomkit.RoomKitEventListener;
import java.util.Map;

public class NEForegroundService extends Service {

  private static final String TAG = "NEForegroundService";

  public static final int ONGOING_NOTIFICATION_ID = 0x9527;

  private static ForegroundServiceConfig foregroundServiceConfig;

  private static final StartForegroundServiceListener startForegroundServiceListener =
      new StartForegroundServiceListener();

  static ForegroundServiceConfig getForegroundServiceConfig() {
    return foregroundServiceConfig;
  }

  public static void start(Context context, Map config) {
    ForegroundServiceConfig fsc = ForegroundServiceConfig.fromMap(config);
    if (fsc == null) {
      return;
    }
    foregroundServiceConfig = fsc;
    if (NENotificationManager.getInstance().ensureNotification(context) == null) {
      Log.i(TAG, "ensure notification fail, ignore start service.");
      return;
    }
    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        // Android 14 or later：在用户授权后才能开启前台 Service
        if (Build.VERSION.SDK_INT >= 34) {
          startForegroundServiceListener.register(
              () -> {
                Log.e(TAG, "startForegroundService after permission granted");
                context.startForegroundService(new Intent(context, NEForegroundService.class));
              });
          return;
        }
        Log.e(TAG, "startForegroundService");
        context.startForegroundService(new Intent(context, NEForegroundService.class));
      } else {
        Log.e(TAG, "startService");
        context.startService(new Intent(context, NEForegroundService.class));
      }
    } catch (Throwable throwable) {
      Log.e(TAG, "startService error", throwable);
    }
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

  @Override
  public void onCreate() {
    Log.i(TAG, "onCreate");
    super.onCreate();
  }

  @Override
  public void onDestroy() {
    Log.i(TAG, "onDestroy");
    super.onDestroy();
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    Log.i(TAG, "onStartCommand");
    onStartForeground();
    super.onStartCommand(intent, flags, startId);
    return START_NOT_STICKY;
  }

  private void onStartForeground() {
    Notification notification = NENotificationManager.getInstance().getNotification();
    if (notification == null) {
      Log.i(TAG, "onStartForeground without notification");
      return;
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      startForeground(
          ONGOING_NOTIFICATION_ID,
          notification,
          ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION);
    } else {
      startForeground(ONGOING_NOTIFICATION_ID, notification);
    }

    Log.i(TAG, "onStartForeground");
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
