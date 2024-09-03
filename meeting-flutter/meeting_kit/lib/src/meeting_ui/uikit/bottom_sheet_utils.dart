// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

class BottomSheetController<T> {
  final Future<T?> result;
  final DismissCallback dismissCallback;

  BottomSheetController(this.result, this.dismissCallback);

  bool dismiss() {
    return dismissCallback();
  }
}

class BottomSheetUtils {
  static BottomSheetController<T> showModalBottomSheet<T>({
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
    final route = ModalBottomSheetRoute<T>(
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
    final result = navigator.push(route);
    DismissCallback callback = () {
      if (route.canPop && route.isActive) {
        Navigator.of(context, rootNavigator: useRootNavigator)
            .removeRoute(route);
        return true;
      }
      return false;
    };
    return BottomSheetController(result, callback);
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
              child: Text(
                inviteContactTitle,
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
                onInviteContact();
              },
            ),
            CupertinoActionSheetAction(
              child: Text(
                linkInfoTitle,
                style: TextStyle(fontSize: 20),
              ),
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

  static BottomSheetController<T> showMeetingBottomDialog<T>({
    required BuildContext buildContext,
    required Widget child,
    String? title,
    RouteSettings? routeSettings,
    BoxConstraints? constraints,
    String? actionText,
    VoidCallback? actionCallback,
    Color? actionColor,
    bool isSubpage = false,
    ScrollPhysics? physics,
  }) {
    actionText ??= NEMeetingUIKit.instance.getUIKitLocalizations().globalCancel;
    return showModalBottomSheet<T>(
      context: buildContext,
      routeSettings: routeSettings,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: constraints,
      builder: (BuildContext context) {
        final isPortrait = MediaQuery.of(context).size.width <
            MediaQuery.of(context).size.height;

        Widget body = AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeIn,
          child: Container(
              constraints:
                  BoxConstraints.tightFor(width: isPortrait ? null : 375),
              child: Container(
                margin: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 8 + MediaQuery.of(context).padding.bottom),
                padding: EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                ),
                decoration: BoxDecoration(
                  color: _UIColors.colorF0F1F5,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                          decoration: BoxDecoration(
                            color: _UIColors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (title != null)
                                Container(
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        color: _UIColors.color8D90A0,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )),
                              Flexible(
                                child: SingleChildScrollView(
                                  physics: physics ?? BouncingScrollPhysics(),
                                  child: child,
                                ),
                              ),
                            ],
                          )),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        actionCallback?.call();
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Text(
                          actionText!,
                          style: TextStyle(
                            color: actionColor ?? _UIColors.color3D3D3D,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        );

        /// 横屏子页面模式，居右显示
        if (!isPortrait && isSubpage) {
          body = Container(
            color: Colors.transparent,
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.only(right: 24),
            child: body,
          );
        }

        /// 横屏居中显示
        else if (!isPortrait) {
          body = Container(
            color: Colors.transparent,
            alignment: Alignment.center,
            child: body,
          );
        }

        /// 默认底部居中
        else {
          body = Container(
            color: Colors.transparent,
            alignment: Alignment.bottomCenter,
            child: body,
          );
        }

        /// 点击其他区域关闭
        body = GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: body,
        );
        return SafeArea(
            child: body, bottom: false, left: isPortrait || !isSubpage);
      },
    );
  }

  static BottomSheetController<T> showMeetingBottomDialogWithTitle<T>({
    required BuildContext buildContext,
    required Widget child,
    required String title,
    RouteSettings? routeSettings,
    String? actionText,
  }) {
    actionText ??= NEMeetingUIKit.instance.getUIKitLocalizations().globalCancel;
    return showModalBottomSheet<T>(
      context: buildContext,
      routeSettings: routeSettings,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _UIColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: _UIColors.color1E1F27,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: _UIColors.colorF0F1F5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                        color: _UIColors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: child),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        actionText!,
                        style: TextStyle(
                          color: _UIColors.color3D3D3D,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
