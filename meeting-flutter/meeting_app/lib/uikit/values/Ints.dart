// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'strings.dart';

extension StringWeekday on int {
  String toWeekday() {
    switch (this) {
      case 0:
        return Strings.sunday;
      case 1:
        return Strings.monday;
      case 2:
        return Strings.tuesday;
      case 3:
        return Strings.wednesday;
      case 4:
        return Strings.thursday;
      case 5:
        return Strings.friday;
      case 6:
        return Strings.saturday;
      default:
        return Strings.sunday;
    }
  }
}
