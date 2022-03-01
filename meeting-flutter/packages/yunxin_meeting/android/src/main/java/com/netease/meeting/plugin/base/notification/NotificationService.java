// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.base.notification;

import android.content.Context;
import android.text.TextUtils;

import com.netease.meeting.plugin.base.Handler;
import com.netease.meeting.plugin.foregroundservice.NEForegroundService;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Created by hzsunyj on 2020/9/27.
 */
public class NotificationService extends Handler {

    public NotificationService(MethodChannel channel, Context context) {
        super(channel, context);
    }
    @Override
    public void unInit() {
    }
    @Override
    public void postInit() {
    }
    @Override
    public void registerObserver() {
    }
    @Override
    public String moduleName() {
        return "NENotificationService";
    }
    @Override
    public String observerModuleName() {
        return "NENotificationObserver";
    }
    @Override
    public void handle(String method, MethodCall call, MethodChannel.Result result) {
        if (TextUtils.isEmpty(method)) {
            return;
        }
        switch (method) {
            case "startForegroundService":
                onStartForegroundService(call);
                result.success(null);
                break;
            case "stopForegroundService":
                NEForegroundService.cancel(context);
                result.success(null);
                break;
        }
    }

    private void onStartForegroundService(MethodCall call) {
        NEForegroundService.start(context, call.<Map>argument("config"));
    }
}
