// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_plugin;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:netease_common/netease_common.dart';

part 'src/meeting_plugin/ne_meeting_plugin.dart';
part 'src/meeting_plugin/base/base.dart';
part 'src/meeting_plugin/base/base_observer.dart';
part 'src/meeting_plugin/base/base_service.dart';
part 'src/meeting_plugin/notification/notification_model.dart';
part 'src/meeting_plugin/notification/notification_service.dart';
part 'src/meeting_plugin/asset/asset_service.dart';
part 'src/meeting_plugin/platform_image/platform_image.dart';
part 'src/meeting_plugin/image_gallery_saver/image_gallery_saver.dart';
part 'src/meeting_plugin/bluetooth/bluetooth_service.dart';
part 'src/meeting_plugin/phone_state/phone_state_service.dart';
part 'src/meeting_plugin/lifecycle_detector/lifecycle_detector.dart';
part 'src/meeting_plugin/iPad_check/ipad_check_detector.dart';
