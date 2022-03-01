// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';
import 'colors.dart';

class Borders {
  static const BorderSide primaryBorder = BorderSide(
    color: Color.fromARGB(255, 51, 126, 255),
    width: 1,
    style: BorderStyle.solid,
  );
  static const BorderSide secondaryBorder = BorderSide(
    color: AppColors.blue_337eff,
    width: 1,
    style: BorderStyle.solid,
  );

  static const BorderSide textFieldBorder = BorderSide(
    color: AppColors.color_337eff,
    width: 1,
  );
  static const BorderSide noticeBorder = BorderSide(
    color: Color.fromRGBO(255, 191, 0, 0.6),
    width: 1,
    style: BorderStyle.solid,
  );

  static const BorderSide feedbackBorder = BorderSide(
    color: AppColors.color_999999,
    width: 0.5,
    style: BorderStyle.solid,
  );
}
