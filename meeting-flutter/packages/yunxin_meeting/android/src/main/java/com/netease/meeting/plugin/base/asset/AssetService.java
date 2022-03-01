// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.base.asset;

import android.content.Context;
import android.content.res.AssetManager;
import android.text.TextUtils;

import com.netease.meeting.plugin.base.Handler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Created by hzsunyj on 2020/9/27.
 */
public class AssetService extends Handler {

    public AssetService(MethodChannel channel, Context context) {
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
        return "NEAssetService";
    }
    @Override
    public String observerModuleName() {
        return "NEAssetObserver";
    }
    @Override
    public void handle(String method, MethodCall call, MethodChannel.Result result) {
        if (TextUtils.isEmpty(method)) {
            return;
        }
        switch (method) {
            case "loadCustomServer":
                onLoadCustomServer(call, result);
                break;
        }

    }

    private void onLoadCustomServer(MethodCall call, MethodChannel.Result result) {
        String config = getConfig();
        if (TextUtils.isEmpty(config)) {
            result.success("");
        } else {
            try {
                JSONObject jsonObject = new JSONObject(config);
                if (jsonObject == null) {
                    result.success("");
                } else {
                    JSONObject meeting = jsonObject.getJSONObject("meeting");
                    result.success(meeting != null ? meeting.toString() : "");
                }
            } catch (JSONException e) {
                result.success("");
            }
        }
    }

    private String getConfig() {
        AssetManager assetManager = context.getAssets();
        BufferedReader reader = null;
        StringBuffer stringBuffer = null;
        try {
            if (!Arrays.asList(assetManager.list("")).contains("server.conf")) {
                return null;
            }
            reader = new BufferedReader(new InputStreamReader(assetManager.open("server.conf")));
            stringBuffer = new StringBuffer();
            String mLine;
            while ((mLine = reader.readLine()) != null) {
                //process line
                stringBuffer.append(mLine);
            }
            if (TextUtils.isEmpty(stringBuffer)) {
                return null;
            }
        } catch (IOException e) {
            //log the exception
            e.printStackTrace();
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    //log the exception
                }
            }
        }
        return stringBuffer.toString();
    }
}
