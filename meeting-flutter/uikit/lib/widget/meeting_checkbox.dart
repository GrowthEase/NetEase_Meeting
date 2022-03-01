// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uikit/values/colors.dart';
import 'package:uikit/values/strings.dart';

class MeetingCheckBox extends StatefulWidget {
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final double? width;
  final double? height;
  final GestureTapCallback? tapPrivacy;
  final GestureTapCallback? tapUserProtocol;

  MeetingCheckBox({
    this.width,
    this.height,
    required this.value,
    required this.onChanged,
    required this.tapPrivacy,
    required this.tapUserProtocol,
  });

  @override
  State<StatefulWidget> createState() {
    return MeetingCheckBoxState();
  }
}

class MeetingCheckBoxState extends State<MeetingCheckBox> {
  final TapGestureRecognizer _tapPrivacy = TapGestureRecognizer();
  final TapGestureRecognizer _tapUserProtocol = TapGestureRecognizer();
  late bool _value;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _value = widget.value ?? false;
    return Container(
        width: widget.width ?? MediaQuery.of(context).size.width,
        height: widget.height ?? MediaQuery.of(context).size.height,
        // margin: const EdgeInsets.only(bottom: 41),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 40,
              child: Scaffold(
                  body: InkWell(
                onTap: () {
                  setState(() {
                    _value = !_value;
                  });
                  if (widget.onChanged != null) {
                    widget.onChanged!(_value);
                  }
                },
                child: Container(
                  // width: 100,
                  // height: 100,
                  color: Colors.white,
                  padding: EdgeInsets.only(right: 2),
                  alignment: Alignment.centerRight,
                  child:checkIcon(),
              )))),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: Strings.joinAppTipsPrefix,
                style: buildTextStyle(AppColors.color_999999),
                ),
            TextSpan(
                text: Strings.joinAppPrivacy,
                style: buildTextStyle(AppColors.blue_337eff),
                recognizer: _tapPrivacy
                  ..onTap = () {
                    if (widget.tapPrivacy != null) {
                      widget.tapPrivacy!();
                    }
                  }),
            TextSpan(
                text: Strings.joinAppAnd.trim(),
                style: buildTextStyle(AppColors.color_999999)),
            TextSpan(
                text: Strings.joinAppUserProtocol,
                style: buildTextStyle(AppColors.blue_337eff),
                recognizer: _tapUserProtocol
                  ..onTap = () {
                    if (widget.tapUserProtocol != null) {
                      widget.tapUserProtocol!();
                    }
                  }),
          ]))
        ]));
  }

  @override
  void dispose() {
    _tapPrivacy.dispose();
    _tapUserProtocol.dispose();
    super.dispose();
  }

  TextStyle buildTextStyle(Color color) {
    return TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  Widget checkIcon() {
    return _value
        ? Icon(
      Icons.check_box_outlined,
      color: AppColors.blue_337eff,
      size: 18,
    ) : Icon(
      Icons.check_box_outline_blank,
      color: AppColors.color_999999,
      size: 18,
    );
  }
}
