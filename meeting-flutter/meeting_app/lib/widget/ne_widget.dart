// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/uikit/values/dimem.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import '../uikit/values/colors.dart';

class NEGestureDetector extends GestureDetector {
  NEGestureDetector({
    Key? key,
    required GestureTapCallback onTap,
    required Widget child,
  }) : super(
          key: key,
          onTap: onTap,
          child: child,
          behavior: HitTestBehavior.opaque,
        );
}

class NESettingItemGroup extends StatelessWidget {
  final List<Widget> children;

  NESettingItemGroup({
    Key? key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        child: Column(children: children));
  }
}

class NESettingItem extends StatelessWidget {
  final String title;
  final String? arrowTip;
  final String? tag;
  final bool showArrow;
  final VoidCallback? onTap;

  NESettingItem(
    this.title, {
    this.arrowTip,
    this.tag,
    this.showArrow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NEGestureDetector(
      child: Container(
        height: Dimen.settingItemHeight,
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalWidthPadding),
        child: Row(
          children: <Widget>[
            NESettingItemTitle(title),
            if (tag != null && tag!.isNotEmpty)
              NESettingItemTag(getAppLocalizations().settingInternalDedicated),
            Expanded(
              child: (arrowTip != null && arrowTip!.isNotEmpty)
                  ? Container(
                      alignment: Alignment.centerRight,
                      child: NESettingItemContent(arrowTip!),
                    )
                  : Container(),
            ),
            SizedBox(
              width: 8.w,
            ),
            if (showArrow) NESettingItemArrow(),
          ],
        ),
      ),
      onTap: () {
        onTap?.call();
      },
    );
  }
}

class NESettingItemArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      IconFont.iconyx_allowx_2,
      size: 14.spMin,
      color: AppColors.color_8D90A0,
    );
  }
}

class NESettingItemTitle extends StatelessWidget {
  final String title;

  NESettingItemTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return NEText(
      title,
      style: TextStyle(
          fontSize: 14.spMin,
          color: AppColors.color_1E1E27,
          fontWeight: FontWeight.w500),
    );
  }
}

class NESettingItemContent extends StatelessWidget {
  final String content;

  NESettingItemContent(this.content);

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: 14.spMin,
          color: AppColors.color_53576A,
          fontWeight: FontWeight.w400),
    );
  }
}

class NESettingItemTag extends StatelessWidget {
  final String tag;

  NESettingItemTag(this.tag);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 6),
      padding: EdgeInsets.only(left: 6, right: 6, bottom: 2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: AppColors.color_1a337eff,
          border: Border.all(color: AppColors.color_33337eff)),
      child: Text(
        tag,
        style: TextStyle(fontSize: 12, color: AppColors.color_337eff),
      ),
    );
  }
}

class NESettingItemGap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.globalBg, height: 16.h);
  }
}

class NEText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  NEText(
    this.text, {
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      strutStyle: Platform.isAndroid
          ? StrutStyle(
              forceStrutHeight: true,
              // leading: 0.01,
              height: 1,
              fontSize: style?.fontSize,
            )
          : null,
      textHeightBehavior: Platform.isAndroid
          ? TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            )
          : null,
    );
  }
}
