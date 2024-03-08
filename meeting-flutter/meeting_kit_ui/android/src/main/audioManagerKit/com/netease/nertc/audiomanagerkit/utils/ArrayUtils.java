// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.nertc.audiomanagerkit.utils;

public class ArrayUtils {
  public static final int[] EMPTY_INT_ARRAY = new int[0];

  public static int[] toPrimitive(final Integer[] array) {
    if (array == null) {
      return null;
    } else if (array.length == 0) {
      return EMPTY_INT_ARRAY;
    } else {
      int[] result = new int[array.length];

      for (int i = 0; i < array.length; ++i) {
        result[i] = array[i];
      }

      return result;
    }
  }
}
