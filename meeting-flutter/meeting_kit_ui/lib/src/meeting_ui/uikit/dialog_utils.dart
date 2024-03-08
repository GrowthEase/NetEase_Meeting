// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef DismissCallback = bool Function();

class DialogUtils {
  static Future showCommonDialog(BuildContext context, String title,
      String content, VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String? cancelText,
      String? acceptText,
      Color? cancelTextColor,
      Color? acceptTextColor,
      bool canBack = true,
      bool isContentCenter = true,
      ValueNotifier<BuildContext?>? contextNotifier}) {
    return showDialog(
        context: context,
        useRootNavigator: false,
        routeSettings: RouteSettings(name: title),
        builder: (BuildContext buildContext) {
          contextNotifier?.value = buildContext;
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return WillPopScope(
              child: CupertinoAlertDialog(
                title: TextUtils.isEmpty(title) ? null : Text(title),
                content: Text(content,
                    textAlign:
                        isContentCenter ? TextAlign.center : TextAlign.left),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(cancelText ??
                        NEMeetingUIKitLocalizations.of(context)!.globalCancel),
                    onPressed: cancelCallback,
                    textStyle: TextStyle(
                        color: cancelTextColor ?? _UIColors.color_666666),
                  ),
                  CupertinoDialogAction(
                    child: Text(acceptText ??
                        NEMeetingUIKitLocalizations.of(context)!.globalSure),
                    onPressed: acceptCallback,
                    textStyle: TextStyle(
                        color: acceptTextColor ?? _UIColors.color_337eff),
                  ),
                ],
              ),
              onWillPop: () async {
                return canBack;
              },
            );
          });
        }).whenComplete(() => contextNotifier?.value = null);
  }

  static Future showOneButtonCommonDialog(BuildContext context, String title,
      String? content, VoidCallback callback,
      {String? acceptText, bool canBack = true, bool isContentCenter = true}) {
    return showDialog(
        context: context,
        useRootNavigator: false,
        routeSettings: RouteSettings(name: title),
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return WillPopScope(
              child: CupertinoAlertDialog(
                title: TextUtils.isEmpty(title) ? null : Text(title),
                content: content != null
                    ? Text(content,
                        textAlign:
                            isContentCenter ? TextAlign.center : TextAlign.left)
                    : null,
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(acceptText ??
                        NEMeetingUIKitLocalizations.of(context)!.globalIKnow),
                    onPressed: callback,
                  ),
                ],
              ),
              onWillPop: () async {
                return canBack;
              },
            );
          });
        });
  }

  /// 展示Dialog并返回关闭回调
  static DismissCallback showOneButtonDialogWithDismissCallback(
      BuildContext context,
      String title,
      String? content,
      VoidCallback callback,
      {String? acceptText,
      bool canBack = true,
      bool isContentCenter = true,
      RouteSettings? routeSettings}) {
    return showDialogWithDismissCallback(
        context: context,
        useRootNavigator: false,
        routeSettings: routeSettings ?? RouteSettings(name: title),
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return WillPopScope(
              child: CupertinoAlertDialog(
                title: TextUtils.isEmpty(title) ? null : Text(title),
                content: content != null
                    ? Text(content,
                        textAlign:
                            isContentCenter ? TextAlign.center : TextAlign.left)
                    : null,
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(acceptText ??
                        NEMeetingUIKitLocalizations.of(context)!.globalIKnow),
                    onPressed: callback,
                  ),
                ],
              ),
              onWillPop: () async {
                return canBack;
              },
            );
          });
        });
  }

  static DismissCallback showDialogWithDismissCallback<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    assert(debugCheckHasMaterialLocalizations(context));

    final CapturedThemes themes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(
        context,
        rootNavigator: useRootNavigator,
      ).context,
    );
    final route = DialogRoute<T>(
      context: context,
      builder: builder,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      settings: routeSettings,
      themes: themes,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior:
          traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
    );
    Navigator.of(context, rootNavigator: useRootNavigator).push<T>(route);
    return () {
      if (route.canPop) {
        Navigator.of(context, rootNavigator: useRootNavigator)
            .removeRoute(route);
        return true;
      }
      return false;
    };
  }

  static void showInviteDialog(
      BuildContext context, String contentBuilder(BuildContext context)) {
    showCupertinoDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      routeSettings: RouteSettings(name: 'InviteDialog'),
      builder: (_) {
        return NEMeetingUIKitLocalizationsScope(builder: (context) {
          final content = contentBuilder(context);
          return _InviteDialog(
            title: NEMeetingUIKitLocalizations.of(context)!
                .meetingInviteDialogTitle,
            content: content,
            onOK: () async {
              Clipboard.setData(ClipboardData(text: content));
              ToastUtils.showToast(
                  context,
                  NEMeetingUIKitLocalizations.of(context)!
                      .meetingInviteContentCopySuccess);
              Navigator.pop(context);
            },
          );
        });
      },
    );
  }

  static void showNetworkAbnormalityAlertDialog(
      {required BuildContext context,
      required VoidCallback onLeaveMeetingCallback,
      required VoidCallback onRejoinMeetingCallback}) {
    showCommonDialog(
      context,
      NEMeetingUIKitLocalizations.of(context)!.networkAbnormality,
      NEMeetingUIKitLocalizations.of(context)!
          .networkDisconnectedPleaseCheckYourNetworkStatusOrTryToRejoin,
      onLeaveMeetingCallback,
      onRejoinMeetingCallback,
      cancelText: NEMeetingUIKitLocalizations.of(context)!.meetingLeaveFull,
      acceptText: NEMeetingUIKitLocalizations.of(context)!.meetingRejoining,
      cancelTextColor: _UIColors.colorFE3B30,
      canBack: false,
    );
  }

  static Future showOpenAudioDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback cancelCallback,
      VoidCallback acceptCallback) {
    return showCommonDialog(
        context, title, content, cancelCallback, acceptCallback,
        cancelText: NEMeetingUIKitLocalizations.of(context)!.globalClose,
        acceptText: NEMeetingUIKitLocalizations.of(context)!.globalOpen,
        canBack: false);
  }

  static Future showOpenVideoDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback cancelCallback,
      VoidCallback acceptCallback) {
    return showCommonDialog(
        context, title, content, cancelCallback, acceptCallback,
        cancelText: NEMeetingUIKitLocalizations.of(context)!.globalClose,
        acceptText: NEMeetingUIKitLocalizations.of(context)!.globalOpen,
        canBack: false);
  }

  static Future<bool?> showStopSharingDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        useRootNavigator: false,
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (context) {
              final meetingAppLocalizations =
                  NEMeetingUIKitLocalizations.of(context)!;
              return CupertinoAlertDialog(
                title: Text(meetingAppLocalizations.meetingStopSharing),
                content:
                    Text(meetingAppLocalizations.meetingStopSharingConfirm),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                        NEMeetingUIKitLocalizations.of(context)!.globalCancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(
                        NEMeetingUIKitLocalizations.of(context)!.globalSure),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );
        });
  }

  static void showShareScreenDialog(
      BuildContext context,
      String title,
      String content,
      VoidCallback acceptCallback,
      bool isShowOpenScreenShareDialog) {
    showDialog(
        context: context,
        useRootNavigator: false,
        routeSettings: RouteSettings(name: title),
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child:
                        Text(NEMeetingUIKitLocalizations.of(context)!.globalNo),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(
                        NEMeetingUIKitLocalizations.of(context)!.globalYes),
                    onPressed: acceptCallback,
                  ),
                ],
              );
            },
          );
        }).then((value) => isShowOpenScreenShareDialog = value != null);
  }

  static Future<T?> showChildNavigatorDialog<T extends Object>(
      BuildContext context, WidgetBuilder builder,
      {RouteSettings? routeSettings}) {
    return showCupertinoDialog(
        context: context,
        useRootNavigator: false,
        routeSettings: routeSettings,
        builder: (BuildContext context) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (context) => builder(context),
          );
        });
  }

  static Future<T?> showChildNavigatorPopup<T extends Object>(
      BuildContext context, WidgetBuilder builder,
      {RouteSettings? routeSettings}) {
    return showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        routeSettings: routeSettings,
        builder: (BuildContext context) {
          return NEMeetingUIKitLocalizationsScope(
            builder: (context) => builder(context),
          );
        });
  }

  static DismissCallback showCustomContentOverlay(
    BuildContext context,
    String title,
    String content,
    VoidCallback cancelCallback,
    VoidCallback acceptCallback, {
    String? cancelText,
    String? acceptText,
    Color? cancelTextColor,
    Color? acceptTextColor,
    bool isContentCenter = true,
    Widget? contentWidget,
  }) {
    final overlayEntry = OverlayEntry(builder: (_) {
      return Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) {},
          ),
          NEMeetingUIKitLocalizationsScope(
              builder: (context) => CupertinoAlertDialog(
                    title: TextUtils.isEmpty(title) ? null : Text(title),
                    content: contentWidget ??
                        Text(content,
                            textAlign: isContentCenter
                                ? TextAlign.center
                                : TextAlign.left),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text(cancelText ??
                            NEMeetingUIKitLocalizations.of(context)!
                                .globalCancel),
                        onPressed: cancelCallback,
                        textStyle: TextStyle(
                            color: cancelTextColor ?? _UIColors.color_666666),
                      ),
                      CupertinoDialogAction(
                        child: Text(acceptText ??
                            NEMeetingUIKitLocalizations.of(context)!
                                .globalSure),
                        onPressed: acceptCallback,
                        textStyle: TextStyle(
                            color: acceptTextColor ?? _UIColors.color_337eff),
                      ),
                    ],
                  )),
        ],
      );
    });
    Overlay.of(context).insert(overlayEntry);
    return () => dismissOverlayEntry(overlayEntry);
  }

  static DismissCallback showOneTimerButtonOverlay(
    BuildContext context,
    String title,
    String content,
    VoidCallback callback, {
    String? acceptText,
    bool isContentCenter = true,
  }) {
    final overlayEntry = OverlayEntry(builder: (_) {
      return Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) {},
          ),
          NEMeetingUIKitLocalizationsScope(builder: (_) {
            return NEMeetingUIKitLocalizationsScope(
                builder: (context) => CupertinoAlertDialog(
                      title: TextUtils.isEmpty(title) ? null : Text(title),
                      content: Text(content,
                          textAlign: isContentCenter
                              ? TextAlign.center
                              : TextAlign.left),
                      actions: <Widget>[
                        CountdownButton(
                          countdownDuration: 3,
                          buttonText: NEMeetingUIKitLocalizations.of(context)!
                              .globalIKnow,
                          onPressed: callback,
                          closeDialog: callback,
                        ),
                      ],
                    ));
          }),
        ],
      );
    });
    Overlay.of(context).insert(overlayEntry);
    return () => dismissOverlayEntry(overlayEntry);
  }

  static bool dismissOverlayEntry(OverlayEntry overlayEntry) {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
      return true;
    }
    return false;
  }
}

class ConfirmDialogResult {
  bool checked;
  ConfirmDialogResult(this.checked);
}

class InputDialogResult {
  String value;
  InputDialogResult(this.value);
}

typedef ContentWrapperBuilder = Widget Function(Widget child);

extension MeetingUIDialogUtils on State {
  Future<ConfirmDialogResult?> showConfirmDialogWithCheckbox({
    required String title,
    String? message,
    required String checkboxMessage,
    bool initialChecked = false,
    required String cancelLabel,
    required String okLabel,
    ContentWrapperBuilder? contentWrapperBuilder,
  }) {
    final result = ConfirmDialogResult(initialChecked);
    return DialogUtils.showChildNavigatorDialog<ConfirmDialogResult>(
      context,
      (context) => StatefulBuilder(
        builder: (context, setState) {
          final child = CupertinoAlertDialog(
            title: Text(title,
                style: TextStyle(color: Colors.black, fontSize: 17)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message != null)
                  FittedBox(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: _UIColors.color_333333,
                      ),
                    ),
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      result.checked = !result.checked;
                    });
                  },
                  child: Text.rich(
                    TextSpan(children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.check_box,
                          size: 14,
                          color: result.checked
                              ? _UIColors.blue_337eff
                              : _UIColors.colorB3B3B3,
                        ),
                      ),
                      TextSpan(
                        text: checkboxMessage,
                      ),
                    ]),
                    style:
                        TextStyle(fontSize: 13, color: _UIColors.color_666666),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(cancelLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                textStyle: TextStyle(color: _UIColors.color_666666),
              ),
              CupertinoDialogAction(
                child: Text(okLabel),
                onPressed: () {
                  Navigator.of(context).pop(result);
                },
                textStyle: TextStyle(color: _UIColors.color_337eff),
              ),
            ],
          );
          return contentWrapperBuilder != null
              ? contentWrapperBuilder(child)
              : child;
        },
      ),
      routeSettings: RouteSettings(name: title),
    );
  }

  Future<InputDialogResult?> showInputDialog({
    required String title,
    required String cancelLabel,
    required String okLabel,
    String? initialInput,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    bool allowEmpty = false,
    Key? textFieldKey,
    ContentWrapperBuilder? contentWrapperBuilder,
  }) {
    final controller = TextEditingController(text: initialInput);
    if (initialInput != null) {
      controller.selection =
          TextSelection.fromPosition(TextPosition(offset: initialInput.length));
    }
    bool isInputValid() =>
        allowEmpty ||
        (controller.text.isNotBlank && controller.text.isNotEmpty);
    return showCupertinoDialog<InputDialogResult?>(
      routeSettings: RouteSettings(name: title),
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (_, setState) =>
              NEMeetingUIKitLocalizationsScope(builder: (BuildContext context) {
            final child = CupertinoAlertDialog(
              title: Text(title),
              content: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoTextField(
                        key: textFieldKey,
                        autofocus: true,
                        controller: controller,
                        placeholder: hintText,
                        placeholderStyle: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.placeholderText,
                        ),
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: isInputValid()
                            ? () => Navigator.of(context)
                                .pop(InputDialogResult(controller.text))
                            : null,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        inputFormatters: inputFormatters,
                      ),
                    ],
                  )),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                      NEMeetingUIKitLocalizations.of(context)!.globalCancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child:
                      Text(NEMeetingUIKitLocalizations.of(context)!.globalDone),
                  onPressed: isInputValid()
                      ? () => Navigator.of(context)
                          .pop(InputDialogResult(controller.text))
                      : null,
                ),
              ],
            );
            return contentWrapperBuilder != null
                ? contentWrapperBuilder(child)
                : child;
          }),
        );
      },
    );
  }
}
