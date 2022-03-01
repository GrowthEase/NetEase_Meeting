// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.netease.meeting.plugin.base.Handler;
import com.netease.meeting.plugin.base.asset.AssetService;
import com.netease.meeting.plugin.base.notification.NotificationService;
import com.netease.meeting.plugin.images.ImageLoader;

import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * MeetingPlugin
 */
public class MeetingPlugin implements FlutterPlugin, MethodCallHandler {

    public static final String TAG = "MeetingPlugin";

    private MethodChannel channel;

    private Context context;

    private Map<String, Handler> handlerMap;

    public static final String PLUGIN_NAME = "meeting_plugin";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), PLUGIN_NAME);
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        initService();
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
    }

    void initService() {
        handlerMap = new HashMap<>();
        new NotificationService(channel, context).register(handlerMap);
        new AssetService(channel, context).register(handlerMap);
        new ImageLoader(channel, context).register(handlerMap);
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
