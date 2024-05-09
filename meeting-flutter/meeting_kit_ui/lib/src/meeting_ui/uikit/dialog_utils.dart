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
        barrierDismissible: canBack,
        routeSettings: RouteSettings(name: title),
        builder: (BuildContext buildContext) {
          contextNotifier?.value = buildContext;
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return PopScope(
              canPop: canBack,
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
        barrierDismissible: canBack,
        routeSettings: RouteSettings(name: title),
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return PopScope(
              canPop: canBack,
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
        barrierDismissible: canBack,
        routeSettings: routeSettings ?? RouteSettings(name: title),
        builder: (_) {
          return NEMeetingUIKitLocalizationsScope(
              builder: (BuildContext context) {
            return PopScope(
              canPop: canBack,
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
    bool useRootNavigator = false,
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
      if (context.mounted && route.canPop) {
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

  /// 打开企业通讯录底部弹窗
  static Future showContactsPopup({
    required BuildContext context,
    required String Function(int) titleBuilder,
    required List<NEScheduledMember> scheduledMemberList,
    required String myUserUuid,
    required String? ownerUuid,
    bool editable = true,
    Future Function()? addActionClick,
    Future Function()? loadMoreContacts,
  }) {
    return showMeetingPopupPageRoute(
      context: context,
      builder: (_) => NEMeetingUIKitLocalizationsScope(
        child: ContactsPopup(
          titleBuilder: titleBuilder,
          scheduledMemberList: scheduledMemberList,
          myUserUuid: myUserUuid,
          addActionClick: addActionClick,
          editable: editable,
          ownerUuid: ownerUuid,
          loadMoreContacts: loadMoreContacts,
        ),
      ),
      routeSettings: RouteSettings(name: 'ContactsPopup'),
    );
  }

  /// 打开企业通讯录选择联系人底部弹窗
  static Future showContactsAddPopup(
      {required BuildContext context,
      required String Function(int) titleBuilder,
      required List<NEScheduledMember> scheduledMemberList,
      required String myUserUuid,
      required ContactItemClickCallback itemClickCallback}) {
    return showMeetingPopupPageRoute(
      context: context,
      builder: (_) => NEMeetingUIKitLocalizationsScope(
        child: ContactsAddPopup(
          titleBuilder: titleBuilder,
          scheduledMemberList: scheduledMemberList,
          myUserUuid: myUserUuid,
          itemClickCallback: itemClickCallback,
        ),
      ),
      routeSettings: RouteSettings(name: 'ContactsAddPopup'),
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

  static DismissCallback showCustomContentDialog(
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
    return showDialogWithDismissCallback(
      context: context,
      useRootNavigator: false,
      builder: (_) {
        return NEMeetingUIKitLocalizationsScope(
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(title),
              content: contentWidget ??
                  Text(content,
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
            );
          },
        );
      },
    );
  }

  static DismissCallback showOneTimerButtonDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback callback, {
    String? acceptText,
    bool isContentCenter = true,
  }) {
    return showDialogWithDismissCallback(
      context: context,
      useRootNavigator: false,
      builder: (_) {
        return NEMeetingUIKitLocalizationsScope(
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text(title),
              content: Text(content,
                  textAlign:
                      isContentCenter ? TextAlign.center : TextAlign.left),
              actions: <Widget>[
                CountdownButton(
                  countdownDuration: 3,
                  buttonText:
                      NEMeetingUIKitLocalizations.of(context)!.globalIKnow,
                  onPressed: callback,
                  closeDialog: callback,
                ),
              ],
            );
          },
        );
      },
    );
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
  Future<bool?> showConfirmDialog({
    required String title,
    String? message,
    required String cancelLabel,
    required String okLabel,
    ContentWrapperBuilder? contentWrapperBuilder,
  }) {
    return DialogUtils.showChildNavigatorDialog<bool>(
      context,
      (context) {
        final child = CupertinoAlertDialog(
          title:
              Text(title, style: TextStyle(color: Colors.black, fontSize: 17)),
          content: message != null
              ? Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: _UIColors.color_333333,
                  ),
                )
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(cancelLabel),
              onPressed: () {
                Navigator.of(context).pop();
              },
              textStyle: TextStyle(color: _UIColors.color_333333),
            ),
            CupertinoDialogAction(
              child: Text(okLabel),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              textStyle: TextStyle(color: _UIColors.color_337eff),
            ),
          ],
        );
        return contentWrapperBuilder != null
            ? contentWrapperBuilder(child)
            : child;
      },
      routeSettings: RouteSettings(name: title),
    );
  }

  Future<ConfirmDialogResult?> showConfirmDialogWithCheckbox({
    required String title,
    String? message,
    String? checkboxMessage,
    bool initialChecked = false,
    required String cancelLabel,
    required String okLabel,
    Color? cancelTextColor,
    Color? okTextColor,
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
                if (checkboxMessage != null) ...[
                  Container(
                    height: 10,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        result.checked = !result.checked;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NEMeetingImages.assetImage(result.checked
                            ? NEMeetingImages.iconChecked
                            : NEMeetingImages.iconUnchecked),
                        SizedBox(width: 4),
                        Flexible(
                            child: Text(
                          checkboxMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: _UIColors.color_333333,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(cancelLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                textStyle:
                    TextStyle(color: cancelTextColor ?? _UIColors.color_666666),
              ),
              CupertinoDialogAction(
                child: Text(okLabel),
                onPressed: () {
                  Navigator.of(context).pop(result);
                },
                textStyle:
                    TextStyle(color: okTextColor ?? _UIColors.color_337eff),
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
