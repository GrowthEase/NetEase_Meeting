// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import '../../language/localizations.dart';
import '../values/colors.dart';

class MeetingProtocols extends StatefulWidget {
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final double? width;
  final double? height;
  final GestureTapCallback? tapPrivacy;
  final GestureTapCallback? tapUserProtocol;

  MeetingProtocols({
    this.width,
    this.height,
    required this.value,
    required this.onChanged,
    required this.tapPrivacy,
    required this.tapUserProtocol,
  });

  @override
  State<StatefulWidget> createState() {
    return MeetingProtocolsState();
  }
}

class MeetingProtocolsState extends State<MeetingProtocols> {
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
    final tips = getAppLocalizations()
        .authHasReadAndAgreeToPolicy('##privacy##', '##userProtocol##');
    final tipList = tips.split('##');
    return Container(
        alignment: Alignment.centerLeft,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          GestureDetector(
              key: ValueKey('protocolCheckBox'),
              onTap: () {
                setState(() {
                  _value = !_value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(_value);
                }
              },
              child: Container(
                margin: EdgeInsets.only(right: 12),
                alignment: Alignment.centerRight,
                // color: Colors.white,
                child: checkIcon(),
              )),
          Flexible(
            child: Text.rich(
              TextSpan(children: [
                for (int i = 0; i < tipList.length; i++)
                  if ('privacy' == tipList[i])
                    TextSpan(
                        text: ' ${getAppLocalizations().authPrivacy} ',
                        style: buildTextStyle(AppColors.blue_337eff),
                        recognizer: _tapPrivacy
                          ..onTap = () {
                            if (widget.tapPrivacy != null) {
                              widget.tapPrivacy!();
                            }
                          })
                  else if ('userProtocol' == tipList[i])
                    TextSpan(
                        text: ' ${getAppLocalizations().authServiceAgreement}',
                        style: buildTextStyle(AppColors.blue_337eff),
                        recognizer: _tapUserProtocol
                          ..onTap = () {
                            if (widget.tapUserProtocol != null) {
                              widget.tapUserProtocol!();
                            }
                          })
                  else
                    TextSpan(
                        text: tipList[i],
                        style: buildTextStyle(AppColors.color_999999)),
              ]),
              // 解决中文垂直不居中问题
              strutStyle: StrutStyle(
                forceStrutHeight: true,
                height: 1.23,
              ),
            ),
          )
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
        fontSize: 13,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none);
  }

  Widget checkIcon() {
    return _value
        ? Icon(
            IconFont.icon_checked,
            color: AppColors.blue_337eff,
            size: 16,
          )
        : Icon(
            IconFont.icon_unchecked,
            color: AppColors.greyCCCCCC,
            size: 16,
          );
  }
}
