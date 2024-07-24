// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.utils;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Build;
import java.lang.reflect.Field;

/**
 * Android版本
 *
 * @author Liu Qijun
 * @version 3.4.0, Sep 01, 2017
 * @since Sep 12, 2013
 */
public class Compatibility {
  private static boolean isCompatible(int apiLevel) {
    return Build.VERSION.SDK_INT >= apiLevel;
  }

  public static boolean isTabletScreen(Context ctxt) {
    boolean isTablet = false;
    if (!isCompatible(4)) {
      return false;
    }
    Configuration cfg = ctxt.getResources().getConfiguration();
    int screenLayoutVal = 0;
    try {
      Field f = Configuration.class.getDeclaredField("screenLayout");
      screenLayoutVal = (Integer) f.get(cfg);
    } catch (Exception e) {
      return false;
    }
    int screenLayout = (screenLayoutVal & 0xF);
    if (screenLayout == 0x3 || screenLayout == 0x4) {
      isTablet = true;
    }
    return isTablet;
  }

  public static boolean runningOnJellyBeanMR2OrHigher() {
    // July 24, 2013: Android 4.3, API Level 18.
    return isCompatible(Build.VERSION_CODES.JELLY_BEAN_MR2);
  }

  public static boolean runningOnKitkatOrHigher() {
    // October 2013: Android 4.4, API Level 19.
    return isCompatible(Build.VERSION_CODES.KITKAT);
  }

  public static boolean runningOnKitkatWatchOrHigher() {
    // June 2014: Android 4.4W, API Level 20.
    return isCompatible(Build.VERSION_CODES.KITKAT_WATCH);
  }

  public static boolean runningOnLollipopOrHigher() {
    // November 2014: Android 5.0, API Level 21.
    return isCompatible(Build.VERSION_CODES.LOLLIPOP);
  }

  public static boolean runningOnLollipopMR1OrHigher() {
    // March 2015: Android 5.1.1, API Level 22.
    return isCompatible(Build.VERSION_CODES.LOLLIPOP_MR1);
  }

  public static boolean runningOnMarshmallowOrHigher() {
    // October 2015: Android 6.0, API Level 23.
    return isCompatible(Build.VERSION_CODES.M);
  }

  public static boolean runningOnNougatOrHigher() {
    // August 2016: Android 7.0, API Level 24.
    return isCompatible(Build.VERSION_CODES.N);
  }

  public static boolean runningOnNougatMR1OrHigher() {
    // December 2016: Android 7.1, API Level 25.
    return isCompatible(Build.VERSION_CODES.N_MR1);
  }

  public static boolean runningOnOreoOrHigher() {
    // August 2017: Android 8.0, API Level 26.
    return isCompatible(Build.VERSION_CODES.O);
  }

  public static boolean runningOnOreoMR1OrHigher() {
    return isCompatible(Build.VERSION_CODES.O_MR1);
  }

  public static boolean runningOnSnowConeOrHigher() {
    return isCompatible(31);
  }

  public static boolean runningOnPieOrHigher() {
    return isCompatible(Build.VERSION_CODES.P);
  }
}
