// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:nemeeting/base/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/service/auth/auth_manager.dart';
import 'package:nemeeting/service/client/http_code.dart';
import 'package:nemeeting/service/repo/user_repo.dart';
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

class _NickSettingState extends MeetingBaseState<NickSetting>
    with MeetingAppLocalizationsMixin {
  late TextEditingController _textController;

  bool enable = false;
  late String originalNickname;

  @override
  void initState() {
    super.initState();
    originalNickname = MeetingUtil.getNickName();
    _textController = TextEditingController(text: originalNickname);
    enable = _textController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget buildBody() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: <Widget>[
            Container(
              color: AppColors.globalBg,
              height: Dimen.globalPadding,
            ),
            Container(
              height: Dimen.primaryItemHeight,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
              alignment: Alignment.center,
              child: TextField(
                key: MeetingValueKey.editNickName,
                autofocus: false,
                controller: _textController,
                keyboardAppearance: Brightness.light,
                textAlignVertical: TextAlignVertical.bottom,
                onChanged: (value) {
                  enable = _textController.text.isNotEmpty;
                  setState(() {});
                },
                inputFormatters: [
                  MeetingLengthLimitingTextInputFormatter(nickLengthMax),
                ],
                decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    suffixIcon: TextUtil.isEmpty(_textController.text)
                        ? null
                        : ClearIconButton(
                            key: MeetingValueKey.clearEdit,
                            onPressed: () {
                              _textController.clear();
                              enable = _textController.text.isNotEmpty;
                              setState(() {});
                            },
                          )),
                style: TextStyle(color: AppColors.color_222222, fontSize: 16),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: AppColors.globalBg,
              ),
            )
          ],
        ));
  }

  @override
  String getTitle() {
    return meetingAppLocalizations.settingNick;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      TextButton(
        child: Text(
          meetingAppLocalizations.globalComplete,
          style: TextStyle(
            color: enable ? AppColors.color_337eff : AppColors.blue_50_337eff,
            fontSize: 16.0,
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
    //   ToastUtils.showToast(context, meetingAppLocalizations.validatorNickTip);
    //   setState(() {});
    //   return;
    // }

    lifecycleExecuteUI(UserRepo().updateNickname(nick)).then((result) {
      if (result == null) return;
      if (result.code == HttpCode.success) {
        AuthManager().saveNick(nick);
        ToastUtils.showToast(
            context, meetingAppLocalizations.settingModifySuccess);
        updateHistoryMeetingItem(originalNickname, nick);
        Navigator.maybePop(context);
      } else {
        ToastUtils.showToast(
            context, result.msg ?? meetingAppLocalizations.settingModifyFailed);
      }
    });
  }

  void updateHistoryMeetingItem(String original, String current) {
    if (current != original) {
      NEMeetingKit.instance
          .getSettingsService()
          .getHistoryMeetingItem()
          .then((value) {
        if (value?.isNotEmpty ?? false) {
          final item = value![0];
          if (item.nickname == originalNickname) {
            NEMeetingKit.instance
                .getSettingsService()
                .updateHistoryMeetingItem(null);
          }
        }
      });
    }
  }
}
