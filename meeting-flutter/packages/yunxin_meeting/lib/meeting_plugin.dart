// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_plugin;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';

part 'src/meeting_plugin/ne_meeting_plugin.dart';
part 'src/meeting_plugin/base/base.dart';
part 'src/meeting_plugin/base/base_observer.dart';
part 'src/meeting_plugin/base/base_service.dart';
part 'src/meeting_plugin/notification/notification_model.dart';
part 'src/meeting_plugin/notification/notification_service.dart';
part 'src/meeting_plugin/asset/asset_service.dart';
part 'src/meeting_plugin/strings.dart';
part 'src/meeting_plugin/platform_image/platform_image.dart';
