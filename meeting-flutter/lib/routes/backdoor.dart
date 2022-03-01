// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yunxin_meeting/meeting_control.dart';
import 'package:service/auth/auth_manager.dart';
import 'package:service/config/app_config.dart';
import 'package:uikit/state/meeting_base_state.dart';
import 'package:uikit/values/colors.dart';
import 'package:base/util/global_preferences.dart';
import 'package:uikit/values/strings.dart';

class BackdoorRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BackdoorState();
  }
}

class _BackdoorState extends MeetingBaseState<BackdoorRoute> {
  late String _versionCode;
  late String _versionName;
  late String _env;
  late String _buildTime;
  bool meetingDebug = false;
  String _logLevel = 'info';
  final TextEditingController _textController = TextEditingController(text: TCProtocol.controllerProtocolVersion);

  @override
  void initState() {
    super.initState();
    _updateInfo();
  }

  void _updateInfo() {
    GlobalPreferences().meetingDebug.then((value) {
      meetingDebug = value ?? false;
    });
    GlobalPreferences().nertcLogLevel.then((value) {
      _logLevel = _logLevel;
    });
    _versionName = AppConfig().versionName;
    _versionCode = AppConfig().versionCode;
    _buildTime = AppConfig().time;
    _env = AppConfig().env;
  }

  @override
  String getTitle() {
    return '开发者';
  }

  @override
  Widget buildBody() {
    return SingleChildScrollView(
        child: Container(
            color: AppColors.white,
            padding: EdgeInsets.all(20),
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Row(children: <Widget>[
                  Text(
                    '版本名称',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.color_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _versionName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.color_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Row(children: <Widget>[
                  Text(
                    '版本号',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.color_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _versionCode,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.color_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Row(children: <Widget>[
                  Text(
                    '服务器环境',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.color_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Text(
                    _env,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.color_222222,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: 8,
              ),
              buildMeetingDebugItem(),
              SizedBox(
                height: 8,
              ),
              buildTimeItem(),
              SizedBox(
                height: 8,
              ),
              buildNertcLogItem(),
              SizedBox(
                height: 8,
              ),
              buildLoginInfo(),
              SizedBox(
                height: 8,
              ),
              buildControllerProtocolVersion(),
              SizedBox(
                height: 8,
              ),
              feedback(),
            ])));
  }

  Widget buildNertcLogItem() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: logLevel,
      child: Row(children: <Widget>[
        Text(
          'Nertc Log leveal',
          style: TextStyle(color: AppColors.black_222222, fontSize: 20),
        ),
        Spacer(),
        Text(
          _logLevel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.color_222222,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        )
      ]),
    );
  }

  void logLevel() {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text(
                'nertc log level',
                style: TextStyle(color: AppColors.grey_8F8F8F, fontSize: 13),
              ),
              actions: <Widget>[
                buildActionSheetItem(context, false, 'info', AppColors.color_007AFF),
                buildActionSheetItem(context, false, 'warning', AppColors.colorFE3B30),
                buildActionSheetItem(context, false, 'error', AppColors.colorFE3B30),
              ],
              cancelButton: buildActionSheetItem(context, true, Strings.cancel, AppColors.color_007AFF),
            )).then<void>((String? value) {
              if (value != null) GlobalPreferences().setNertcLogLevel(value);
    });
  }

  Widget buildActionSheetItem(BuildContext context, bool defaultAction, String text, Color textColor) {
    return CupertinoActionSheetAction(
        isDefaultAction: defaultAction,
        child: Text(text, style: TextStyle(color: textColor)),
        onPressed: () {
          Navigator.pop(context, text);
        });
  }

  Widget buildMeetingDebugItem() {
    return Align(
        alignment: Alignment.topCenter,
        child: Row(children: <Widget>[
          Text(
            '会议信息',
            style: TextStyle(color: AppColors.black_222222, fontSize: 20),
          ),
          Spacer(),
          Container(
              child: CupertinoSwitch(
            value: meetingDebug,
            onChanged: (bool value) {
              setState(() {
                meetingDebug = value;
              });
              GlobalPreferences().setMeetingDebug(value);
            },
          )),
        ]));
  }

  Widget buildTimeItem() {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(children: <Widget>[
        Text(
          '构建时间',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.color_222222,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        Spacer(),
        Text(
          _buildTime,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.color_222222,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ]),
    );
  }

  Widget feedback() {
    return GestureDetector(
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 30, top: 40, right: 30),
        padding: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          color: AppColors.color_337eff,
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Strings.feedback,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
//        FeedbackArguments arguments = new FeedbackArguments(fromRoute: RouterName.backdoor);
//        NavUtils.pushNamed(context, RouterName.feedback, arguments: arguments);
      },
    );
  }

  Widget buildLoginInfo() {
    return Align(
      alignment: Alignment.topCenter,
      child:Row(children: <Widget>[
            Text(
              'loginInfo：',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.color_222222,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            Spacer(),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
                height: 150,
                width: 200,
                child: Text(
                  'appKey = ${AuthManager().appKey} accountId = ${AuthManager().accountId}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.color_222222,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ))),
          ]),
    );
  }

  Widget buildControllerProtocolVersion() {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(children: <Widget>[
        Text(
          '遥控器的协议版本：',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.color_222222,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        Spacer(),
        Container(
          height: 50,
          width: 50,
          alignment: Alignment.center,
          child: TextField(
            autofocus: false,
            controller: _textController,
            keyboardAppearance: Brightness.light,
            onChanged: (value) {
              TCProtocol.controllerProtocolVersion = value;
            },
            style: TextStyle(color: AppColors.color_222222, fontSize: 16),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
