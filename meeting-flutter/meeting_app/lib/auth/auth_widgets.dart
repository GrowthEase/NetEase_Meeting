// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nemeeting/language/localizations.dart';
import 'package:nemeeting/uikit/values/colors.dart';
import 'package:nemeeting/uikit/values/fonts.dart';
import 'package:netease_common/netease_common.dart';

enum LoginItemType {
  mobilePwd,
  accountPwd,
  emailPwd,
  sso,
}

typedef void OnLoginItemTap(LoginItemType type);

class LoginItemRow extends StatelessWidget {
  final double? spacing;
  final List<LoginItemType> types;
  final OnLoginItemTap? onTap;

  const LoginItemRow({
    super.key,
    this.spacing,
    this.types = LoginItemType.values,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = this.spacing ?? 36.w;
    final children = <Widget>[];
    types.forEachIndexed((index, type) {
      if (index > 0) {
        children.add(SizedBox(width: spacing));
      }
      children.add(LoginItem(
        type: type,
        onTap: onTap,
      ));
    });
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// 登录方式
class LoginItem extends StatelessWidget {
  final LoginItemType type;
  final OnLoginItemTap? onTap;

  const LoginItem({
    super.key,
    required this.type,
    this.onTap,
  });

  IconData getIcon(LoginItemType type) {
    return switch (type) {
      LoginItemType.sso => IconFont.icon_key,
      LoginItemType.mobilePwd => IconFont.icon_mobile,
      LoginItemType.emailPwd => IconFont.icon_email,
      _ => IconFont.icon_account,
    };
  }

  String getLabel(LoginItemType type) {
    var appLocalizations = getAppLocalizations();
    return switch (type) {
      LoginItemType.sso => appLocalizations.authLoginBySSO,
      LoginItemType.mobilePwd => appLocalizations.authMobileNum,
      LoginItemType.emailPwd => appLocalizations.settingEmail,
      _ => appLocalizations.authTypeAccountPwd,
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.color_F5F6FA,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            child: IconButton(
              constraints: BoxConstraints.tightFor(
                width: 48.r,
                height: 48.r,
              ),
              icon: Icon(getIcon(type)),
              iconSize: 24.r,
              color: AppColors.color_337eff,
              onPressed: onTap != null ? () => onTap!(type) : null,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        FittedBox(
          child: Text(
            getLabel(type),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.color_999999,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
    return SizedBox(
      width: 56.w,
      child: child,
    );
  }
}
