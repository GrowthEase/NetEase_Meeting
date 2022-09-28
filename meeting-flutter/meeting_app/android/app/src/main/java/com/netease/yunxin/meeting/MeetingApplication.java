// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.meeting;

import android.app.Application;
import io.flutter.embedding.engine.FlutterEngine;

public class MeetingApplication extends Application {
  private FlutterEngine engine;
  private static MeetingApplication application;

  @Override
  public void onCreate() {
    super.onCreate();
    application = this;
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
