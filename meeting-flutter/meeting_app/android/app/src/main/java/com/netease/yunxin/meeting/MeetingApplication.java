// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.meeting;

import android.app.Application;
import com.netease.yunxin.meeting.util.ProcessUtils;
import io.flutter.embedding.engine.FlutterEngine;

public class MeetingApplication extends Application {
  private FlutterEngine engine;
  private static MeetingApplication application;

  @Override
  public void onCreate() {
    super.onCreate();
    application = this;

    // 华为通知推送初始化
    if (ProcessUtils.isMainProcess(this)) {
      com.huawei.hms.support.common.ActivityMgr.INST.init(this);
    }
  }

  public static MeetingApplication getApplication() {
    return application;
  }

  public FlutterEngine getEngine() {
    if (engine == null) {
      engine = new FlutterEngine(this);
    }
    return engine;
  }
}
