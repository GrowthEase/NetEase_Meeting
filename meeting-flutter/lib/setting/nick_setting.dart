// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:base/util/stringutil.dart';
import 'package:base/util/textutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nemeeting/utils/meeting_util.dart';
import 'package:nemeeting/widget/length_text_input_formatter.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:service/client/http_code.dart';
import 'package:service/repo/user_repo.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/dimem.dart';
import 'package:uikit/values/strings.dart';
import 'package:uikit/const/consts.dart';
import 'package:yunxin_meeting/meeting_uikit.dart';

class NickSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NickSettingState();
  }
}

class _NickSettingState extends MeetingBaseState<NickSetting> {
  late TextEditingController _textController;

  bool enable = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: MeetingUtil.getNickName());
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
    return Strings.nickSetting;
  }

  @override
  List<Widget> buildActions() {
    return <Widget>[
      TextButton(
        child: Text(
          Strings.done,
          style: TextStyle(
            color: enable ? AppColors.color_337eff : AppColors.blue_50_337eff,
            fontSize: 16.0,
          ),
        ),
        onPressed: enable
            ? () {
                _commit();
              }
            : null,
      )
    ];
  }

  void _commit() {
    final nick = _textController.text;
    if (!StringUtil.isLetterOrDigitalOrZh(nick)) {
      _textController.text = '';
      ToastUtils.showToast(context, Strings.validatorNickTip);
      setState(() {});
      return;
    }

    lifecycleExecuteUI(UserRepo().updateNickname(nick)).then((result) {
      if (result == null) return;
      if (result.code == HttpCode.success) {
        AuthManager().saveNick(nick);
        ToastUtils.showToast(context, Strings.modifySuccess);
        Navigator.maybePop(context);
      } else {
        ToastUtils.showToast(context, result.msg ?? Strings.modifyFailed);
      }
    });
  }
}
