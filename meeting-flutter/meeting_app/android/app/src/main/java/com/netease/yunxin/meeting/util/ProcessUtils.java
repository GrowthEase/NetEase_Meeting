// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.meeting.util;

import android.app.ActivityManager;
import android.content.Context;
import android.text.TextUtils;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.List;

public class ProcessUtils {

  public static boolean isMainProcess(Context context) {
    if (context == null) {
      return false;
    }
    String packageName = context.getApplicationContext().getPackageName();
    String processName = getProcessName(context);
    return packageName.equals(processName);
  }

  public static String getProcessName(Context context) {
    String processName = getProcessFromFile();
    if (processName == null) {
      // 如果装了xposed一类的框架，上面可能会拿不到，回到遍历迭代的方式
      processName = getProcessNameByAM(context);
    }
    return processName;
  }

  private static String getProcessFromFile() {
    BufferedReader reader = null;
    try {
      int pid = android.os.Process.myPid();
      String file = "/proc/" + pid + "/cmdline";
      reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), "iso-8859-1"));
      int c;
      StringBuilder processName = new StringBuilder();
      while ((c = reader.read()) > 0) {
        processName.append((char) c);
      }
      return processName.toString();
    } catch (Exception e) {
      return null;
    } finally {
      if (reader != null) {
        try {
          reader.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }
  }

  private static String getProcessNameByAM(Context context) {
    String processName = null;
    ActivityManager am = ((ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE));
    if (am == null) {
      return null;
    }
    while (true) {
      List<ActivityManager.RunningAppProcessInfo> plist = am.getRunningAppProcesses();
      if (plist != null) {
        for (ActivityManager.RunningAppProcessInfo info : plist) {
          if (info.pid == android.os.Process.myPid()) {
            processName = info.processName;
            break;
          }
        }
      }
      if (!TextUtils.isEmpty(processName)) {
        return processName;
      }
      try {
        Thread.sleep(100L); // take a rest and again
      } catch (InterruptedException ex) {
        ex.printStackTrace();
      }
    }
  }
}
