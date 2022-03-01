// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:service/model/security_notice_info.dart';
import 'package:uikit/const/packages.dart';
import 'package:uikit/values/asset_name.dart';
import 'package:uikit/values/borders.dart';
import 'package:uikit/values/colors.dart';

class MeetingSecurityNotice extends StatefulWidget {
  final ValueChanged<bool>? onChanged;
  final double? width;
  final double? height;
  final bool value;
  final Configs configs;

  MeetingSecurityNotice({
    this.width,
    this.height,
    required this.value,
    required this.onChanged,
    required this.configs,
  });

  @override
  State<StatefulWidget> createState() {
    return MeetingSecurityNoticeState();
  }
}

class MeetingSecurityNoticeState extends State<MeetingSecurityNotice> {
  final TapGestureRecognizer _tapPrivacy = TapGestureRecognizer();
  late bool _value;
  late Configs _configs;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _value = widget.value;
    _configs = widget.configs;
    return Column(
      children: [
        Container(
            // constraints: BoxConstraints(
            //     minHeight: 100
            // ),
            padding: EdgeInsets.only(left: 13, right: 13, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.noticeBg,
              border: Border.fromBorderSide(Borders.noticeBorder),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: _value
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        buildIconBy(AssetName.iconWarning),
                        Expanded(
                          child: RichText(
                            textDirection: TextDirection.ltr,
                            text: TextSpan(children: [
                              TextSpan(children: [
                                TextSpan(
                                  text: '【${_configs.title}】',
                                  style: buildTextStyle(AppColors.color_666666),
                                ),
                                TextSpan(
                                    text: _configs.content,
                                    style:
                                        buildTextStyle(AppColors.color_666666),
                                    recognizer: _tapPrivacy
                                      ..onTap = () => showLogoutDialog()),
                              ]),
                            ]),
                          ),
                        ),
                        buildIconBy(AssetName.iconClose,
                            onChanged: widget.onChanged, paddingLeft: 2)
                      ])
                : Container()),
      ],
    );
  }

  @override
  void dispose() {
    _tapPrivacy.dispose();
    super.dispose();
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  Align buildIconBy(String assetName, {ValueChanged<bool>? onChanged,double paddingLeft = 0,double paddingRight = 0}) {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: EdgeInsets.only(top: 3,right: paddingRight,left:paddingLeft),
          child: GestureDetector(
            onTap: () {
              if (onChanged == null) return;
              _value = false;
              setState(() {});
              onChanged(_value);
            },
            child: Image.asset(
              assetName,
              package: Packages.uiKit,
              fit: BoxFit.fill,
            ),
          ),
        ));
  }

  void showLogoutDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(_configs.title ?? ''),
            content: Text(_configs.content ?? ''),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(_configs.okBtnLabel ?? ''),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
