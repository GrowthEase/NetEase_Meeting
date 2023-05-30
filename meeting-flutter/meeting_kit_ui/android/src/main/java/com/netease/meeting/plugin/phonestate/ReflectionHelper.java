// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.meeting.plugin.phonestate;

import java.lang.reflect.Method;

public final class ReflectionHelper {
  private static Class<?>[] getArgsClasses(Object[] objArr) {
    if (objArr == null) {
      return null;
    }
    Class<?>[] clsArr = new Class[objArr.length];
    int length = objArr.length;
    for (int i10 = 0; i10 < length; i10++) {
      Object obj = objArr[i10];
      if (obj != null) {
        clsArr[i10] = obj.getClass();
      } else {
        clsArr[i10] = String.class;
      }
      Class<?> cls = clsArr[i10];
      if (cls == Integer.class) {
        clsArr[i10] = Integer.TYPE;
      } else if (cls == Boolean.class) {
        clsArr[i10] = Boolean.TYPE;
      }
    }
    return clsArr;
  }

  public static Object invokeMethod(Object obj, String str, Object[] objArr) throws Exception {
    return invokeMethod(obj, str, getArgsClasses(objArr), objArr);
  }

  public static Object invokeStaticMethod(
      String str, String str2, Object[] objArr, Class<?>[] clsArr) throws Exception {
    Class<?> cls = Class.forName(str);
    return cls.getDeclaredMethod(str2, clsArr).invoke(cls, objArr);
  }

  public static Object invokeMethod(Object obj, String str, Class<?>[] clsArr, Object[] objArr)
      throws Exception {
    Method method = obj.getClass().getMethod(str, clsArr);
    method.setAccessible(true);
    return method.invoke(obj, objArr);
  }
}
