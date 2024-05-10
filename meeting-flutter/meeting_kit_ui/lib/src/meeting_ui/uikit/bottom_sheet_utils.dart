// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

class BottomSheetUtils {
  static DismissCallback showModalBottomSheet({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
  }) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final NavigatorState navigator =
        Navigator.of(context, rootNavigator: useRootNavigator);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final route = ModalBottomSheetRoute(
      builder: builder,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      isScrollControlled: isScrollControlled,
      scrollControlDisabledMaxHeightRatio:
          _defaultScrollControlDisabledMaxHeightRatio,
      barrierLabel: barrierLabel ?? localizations.scrimLabel,
      barrierOnTapHint:
          localizations.scrimOnTapHint(localizations.bottomSheetLabel),
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      isDismissible: isDismissible,
      modalBarrierColor:
          barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      settings: routeSettings,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
      useSafeArea: useSafeArea,
    );
    navigator.push(route);
    return () {
      if (route.canPop && route.isActive) {
        Navigator.of(context, rootNavigator: useRootNavigator)
            .removeRoute(route);
        return true;
      }
      return false;
    };
  }

  /// 显示邀请弹窗
  /// [buildContext] 上下文
  /// [onInviteLinkInfo] 点击邀请链接信息
  /// [linkInfoTitle] 邀请链接信息标题
  /// [onInviteUser] 点击邀请用户
  /// [inviteUserTitle] 邀请用户标题
  ///

  static void showInviteModalBottomSheet(
      BuildContext buildContext, String title,
      {required Function() onInviteLinkInfo,
      required String linkInfoTitle,
      required Function() onInviteContact,
      required String inviteContactTitle,
      required String cancelTitle}) {
    showCupertinoModalPopup(
      context: buildContext,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(title),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(inviteContactTitle),
              onPressed: () {
                Navigator.pop(context);
                onInviteContact();
              },
            ),
            CupertinoActionSheetAction(
              child: Text(linkInfoTitle),
              onPressed: () {
                Navigator.pop(context);
                onInviteLinkInfo();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(cancelTitle),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}
