// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.base;

import android.content.Context;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Created by hzsunyj on 2019-08-09.
 */
public abstract class Handler {

    protected final MethodChannel channel;

    protected final Context context;

    public Handler(MethodChannel channel, Context context) {
        this.channel = channel;
        this.context = context;
    }

    public void register(Map<String, Handler> map) {
        map.put(moduleName(), this);
        init();
    }

    public void init() {
        postInit();
        registerObserver();
    }

    public abstract void unInit();

    public abstract void postInit();

    public abstract void registerObserver();

    public abstract String moduleName();

    public abstract String observerModuleName();

    public String getReceiptId(MethodCall call) {
        return call.argument("receiptId");
    }

    public abstract void handle(String method, MethodCall call, MethodChannel.Result result);

    public static MapBuilder buildArg(String receiptId, String moduleName) {
        MapBuilder builder = Handler.map().put("receiptId", receiptId).put("module", moduleName);
        return builder;
    }

    public static MapBuilder buildArg(String moduleName) {
        MapBuilder builder = Handler.map().put("module", moduleName);
        return builder;
    }

    public static MapBuilder map(int size) {
        return new MapBuilder(size);
    }

    public static MapBuilder map() {
        return new MapBuilder();
    }

    public static class MapBuilder {

        private Map<String, Object> map;

        public MapBuilder(int size) {
            map = new HashMap<>(size);
        }

        public MapBuilder() {
            map = new HashMap<>();
        }

        public MapBuilder put(String key, Object value) {
            map.put(key, value);
            return this;
        }

        public Map<String, Object> build() {
            return map;
        }
    }
}
