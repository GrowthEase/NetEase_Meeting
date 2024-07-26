// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library feedback;

import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'meeting_core.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:netease_common/netease_common.dart';
import 'package:netease_meeting_kit/meeting_ui.dart';

part 'src/meeting_feedback/src/feedback_repository.dart';
part 'src/meeting_feedback/src/ui/feedback_page.dart';
part 'src/meeting_feedback/src/ui/feedback_in_meeting.dart';
part 'src/meeting_feedback/src/module_name.dart';
part 'src/meeting_feedback/src/ui/values/colors.dart';
