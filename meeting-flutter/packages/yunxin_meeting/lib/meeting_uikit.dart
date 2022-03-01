// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library meeting_uikit;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:yunxin_base/yunxin_base.dart';
import 'package:yunxin_meeting_assets/yunxin_meeting_assets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

part 'src/meeting_uikit/lifecycle/state_lifecycle.dart';
part 'src/meeting_uikit/state/lifecycle_base_state.dart';
part 'src/meeting_uikit/state/base_state.dart';
part 'src/meeting_uikit/loading.dart';
part 'src/meeting_uikit/values/colors.dart';
part 'src/meeting_uikit/nav_utils.dart';
part 'src/meeting_uikit/dialog_utils.dart';
part 'src/meeting_uikit/values/strings.dart';
part 'src/meeting_uikit/mask_text_input.dart';
part 'src/meeting_uikit/expansion_tile.dart';
part 'src/meeting_uikit/clear_icon_button.dart';
part 'src/meeting_uikit/values/asset_name.dart';
part 'src/meeting_uikit/toast_utils.dart';
part 'src/meeting_uikit/invite_dialog.dart';
part 'src/meeting_uikit/values/event_name.dart';
part 'src/meeting_uikit/style/app_style_util.dart';
part 'src/meeting_uikit/length_text_input_formatter.dart';
part 'src/meeting_uikit/module_name.dart';
part 'src/meeting_uikit/permission/permission_helper.dart';
part 'src/meeting_uikit/helpers.dart';


