// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';

import '../../language/localizations.dart';

extension StringWeekday on int {
  String toWeekday(BuildContext context) {
    switch (this) {
      case 0:
        return getAppLocalizations().globalSunday;
      case 1:
        return getAppLocalizations().globalMonday;
      case 2:
        return getAppLocalizations().globalTuesday;
      case 3:
        return getAppLocalizations().globalWednesday;
      case 4:
        return getAppLocalizations().globalThursday;
      case 5:
        return getAppLocalizations().globalFriday;
      case 6:
        return getAppLocalizations().globalSaturday;
      default:
        return getAppLocalizations().globalSunday;
    }
  }
}
