
// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/rendering.dart';


class Gradients {
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment(0.5, 0.02764),
    end: Alignment(0.5, 0.99613),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 255, 111, 111),
      Color.fromARGB(255, 222, 58, 58),
    ],
  );
}