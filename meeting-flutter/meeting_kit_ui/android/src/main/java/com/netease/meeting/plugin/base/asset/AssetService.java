// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.base.asset;

import android.content.Context;
import android.content.res.AssetManager;
import android.text.TextUtils;
import com.netease.meeting.plugin.base.Handler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/** Created by hzsunyj on 2020/9/27. */
public class AssetService extends Handler {

  public AssetService(MethodChannel channel, Context context) {
    super(channel, context);
  }

  @Override
  public void unInit() {}

  @Override
  public void postInit() {}

  @Override
  public void registerObserver() {}

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
      case "loadAssetAsString":
        String fileName = call.argument("fileName");
        result.success(loadAssetAsString(fileName));
        break;
    }
  }

  private String loadAssetAsString(String fileName) {
    AssetManager assetManager = context.getAssets();
    BufferedReader reader = null;
    StringBuffer stringBuffer = new StringBuffer();
    try {
      reader = new BufferedReader(new InputStreamReader(assetManager.open(fileName)));
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
    }
    return stringBuffer.toString();
  }
}
