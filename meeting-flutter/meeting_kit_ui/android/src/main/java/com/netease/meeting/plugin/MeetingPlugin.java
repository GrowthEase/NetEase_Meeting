// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import androidx.annotation.NonNull;
import com.netease.meeting.plugin.base.Handler;
import com.netease.meeting.plugin.base.asset.AssetService;
import com.netease.meeting.plugin.base.notification.NotificationService;
import com.netease.meeting.plugin.bluetooth.BluetoothService;
import com.netease.meeting.plugin.images.ImageGallerySaver;
import com.netease.meeting.plugin.images.ImageLoader;
import com.netease.meeting.plugin.lifecycle.AppLifecycleDetector;
import com.netease.meeting.plugin.phonestate.PhoneStateService;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.HashMap;
import java.util.Map;

/** MeetingPlugin */
public class MeetingPlugin implements FlutterPlugin, MethodCallHandler {

  public static final String TAG = "MeetingPlugin";

  private MethodChannel channel;

  private Context context;

  private Map<String, Handler> handlerMap;

  public static final String PLUGIN_NAME = "meeting_plugin";

  private BluetoothService bluetoothService;
  private PhoneStateService phoneStateService;

  private AppLifecycleDetector appLifecycleDetector;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), PLUGIN_NAME);
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    initService();
    bluetoothService = new BluetoothService(context, flutterPluginBinding);
    phoneStateService = new PhoneStateService(context, flutterPluginBinding);
    appLifecycleDetector = new AppLifecycleDetector(context, flutterPluginBinding);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
    if (handlerMap != null) {
      for (Map.Entry<String, Handler> entry : handlerMap.entrySet()) {
        entry.getValue().unInit();
      }
      handlerMap.clear();
      handlerMap = null;
    }

    bluetoothService.dispose();
    bluetoothService = null;

    phoneStateService.dispose();
    phoneStateService = null;

    appLifecycleDetector.dispose();
    appLifecycleDetector = null;
  }

  void initService() {
    handlerMap = new HashMap<>();
    new NotificationService(channel, context).register(handlerMap);
    new AssetService(channel, context).register(handlerMap);
    new ImageLoader(channel, context).register(handlerMap);
    new ImageGallerySaver(channel, context).register(handlerMap);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String moduleName = call.argument("module");
    String methodName = call.method;
    Log.i(TAG, "moduleName=" + moduleName + " methodName=" + methodName);
    if (!TextUtils.isEmpty(moduleName)) {
      Handler handler = handlerMap.get(moduleName);
      if (handler != null) {
        handler.handle(methodName, call, result);
      } else {
        result.success(null);
      }
    } else {
      result.notImplemented();
    }
  }
}
