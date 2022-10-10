// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';
import '../uikit/values/asset_name.dart';
import '../uikit/values/strings.dart';

/// 默认开启白板
const bool openWhiteBoard = true;

///是否展示全体视频开/关入口

const noMuteAllVideo = false;

/// 默认开启录制
const bool noCloudRecord = false;

///
const kNoSip = false;

/// 使用默认的短信验证码：081166
const kUseFakeCheckCode = false;

/// 配置会议中开启剩余时间提醒
const kShowMeetingRemainingTip = true;

/// 开启密码登录
const kEnablePasswordLogin = !kReleaseMode;
