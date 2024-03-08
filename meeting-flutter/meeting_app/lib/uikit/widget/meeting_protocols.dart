// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../language/meeting_localization/meeting_app_localizations.dart';
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
    final meetingAppLocalizations = MeetingAppLocalizations.of(context)!;
    final tips = meetingAppLocalizations.authHasReadAndAgreeToPolicy(
        '##privacy##', '##userProtocol##');
    final tipList = tips.split('##');
    return Container(
        alignment: Alignment.center,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Material(
              key: ValueKey('protocolCheckBox'),
              child: InkWell(
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
                    child: checkIcon(),
                  ))),
          Flexible(
            child: Text.rich(TextSpan(children: [
              for (int i = 0; i < tipList.length; i++)
                if ('privacy' == tipList[i])
                  TextSpan(
                      text: ' ${meetingAppLocalizations.authPrivacy} ',
                      style: buildTextStyle(AppColors.blue_337eff),
                      recognizer: _tapPrivacy
                        ..onTap = () {
                          if (widget.tapPrivacy != null) {
                            widget.tapPrivacy!();
                          }
                        })
                else if ('userProtocol' == tipList[i])
                  TextSpan(
                      text: ' ${meetingAppLocalizations.authServiceAgreement}',
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
            ])),
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
          )
        : Icon(
            Icons.check_box_outline_blank,
            color: AppColors.color_999999,
            size: 18,
          );
  }
}
