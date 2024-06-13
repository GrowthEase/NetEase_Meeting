// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/repo/user_repo.dart';
import 'package:nemeeting/widget/ne_widget.dart';
import '../language/localizations.dart';
import '../uikit/state/meeting_base_state.dart';
import '../uikit/values/colors.dart';
import '../uikit/values/dimem.dart';
import '../uikit/const/consts.dart';
import 'package:netease_meeting_ui/meeting_ui.dart';

import '../utils/integration_test.dart';

class NickSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NickSettingState();
  }
}

class _NickSettingState extends AppBaseState<NickSetting> {
  late TextEditingController _textController;

  bool enable = false;
  late String originalNickname;
  final nickNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    originalNickname = MeetingUtil.getNickName();
    _textController = TextEditingController(text: originalNickname);
    enable = _textController.text.isNotEmpty;
    nickNameFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    nickNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget buildBody() {
    return NEGestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: EdgeInsets.only(left: 16.w, right: 16.w),
          child: Column(
            children: <Widget>[
              Container(
                color: AppColors.globalBg,
                height: Dimen.globalHeightPadding,
              ),
              NESettingItemGroup(children: [
                Container(
                  height: 48.h,
                  // padding: EdgeInsets.only(left: Dimen.globalWidthPadding),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    key: MeetingValueKey.editNickName,
                    autofocus: false,
                    controller: _textController,
                    keyboardAppearance: Brightness.light,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (value) {
                      enable = _textController.text.isNotEmpty;
                      setState(() {});
                    },
                    inputFormatters: [
                      MeetingLengthLimitingTextInputFormatter(nickLengthMax),
                    ],
                    focusNode: nickNameFocusNode,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // 确保无边框
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none, // 确保无边框
                        ),
                        suffixIcon: !nickNameFocusNode.hasFocus ||
                                TextUtil.isEmpty(_textController.text)
                            ? null
                            : ClearIconButton(
                                key: MeetingValueKey.clearEdit,
                                onPressed: () {
                                  _textController.clear();
                                  enable = _textController.text.isNotEmpty;
                                  setState(() {});
                                },
                              )),
                    style: TextStyle(
                        color: AppColors.color_333333, fontSize: 14.spMin),
                  ),
                ),
              ]),
              Expanded(
                flex: 1,
                child: Container(
                  color: AppColors.globalBg,
                ),
              )
            ],
          ),
        ));
  }

  @override
  String getTitle() {
    return getAppLocalizations().settingRename;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      TextButton(
        child: Text(
          getAppLocalizations().globalComplete,
          style: TextStyle(
            color: enable ? AppColors.color_337eff : AppColors.blue_50_337eff,
            fontSize: 16.spMin,
          ),
        ),
        onPressed: enable ? _commit : null,
      )
    ];
  }

  void _commit() {
    final nick = _textController.text;
    // if (!StringUtil.isLetterOrDigitalOrZh(nick)) {
    //   _textController.text = '';
    //   ToastUtils.showToast(context, getAppLocalizations().validatorNickTip);
    //   setState(() {});
    //   return;
    // }

    lifecycleExecuteUI(UserRepo().updateNickname(nick)).then((result) {
      if (result == null) return;
      if (result.code == HttpCode.success) {
        AuthManager().saveNick(nick);
        ToastUtils.showToast(
            context, getAppLocalizations().settingModifySuccess);
        updateHistoryMeetingItem(originalNickname, nick);
        Navigator.maybePop(context);
      } else {
        ToastUtils.showToast(
            context, result.msg ?? getAppLocalizations().settingModifyFailed);
      }
    });
  }

  /// 更新历史会议记录中的昵称
  void updateHistoryMeetingItem(String original, String current) {
    if (current != original) {
      LocalHistoryMeetingManager().localHistoryMeetingList.forEach((item) {
        if (item.nickname == originalNickname) {
          item.nickname = current;
        }
      });
      LocalHistoryMeetingManager().saveLocalHistoryMeeting(
          LocalHistoryMeetingManager().localHistoryMeetingList);
    }
  }
}
