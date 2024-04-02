// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

const kCropGridColumnCount = 3;
const kCropGridRowCount = 3;
const kCropGridColor = Color.fromRGBO(0xd0, 0xd0, 0xd0, 0.5);
const kCropOverlayActiveOpacity = 0.5;
const kCropOverlayInactiveOpacity = 1;
const kCropAnimationDuration = Duration(milliseconds: 200);
const kCropHandleColor = Colors.white;
const kCropHandleStrokeWidth = 2.0;
const kCropHandleSize = 15.0;
const kCropHandleHitSize = 48.0;
const kCropAreaPadding = kCropHandleSize * 2;
const kMinCropArea = 32.0;
