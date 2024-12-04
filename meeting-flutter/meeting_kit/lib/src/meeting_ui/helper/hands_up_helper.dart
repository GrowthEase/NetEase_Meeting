// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 举手帮助类，跟随meeting_page生命周期
class HandsUpHelper {
  NERoomContext? roomContext;

  NERoomEventCallback? roomEventCallback;
  final _isHandsUp = ValueNotifier(false);
  final _isHandsUpCount = ValueNotifier(0);

  ValueListenable<bool> get isMySelfHandsUp => _isHandsUp;
  ValueListenable<int> get handsUpCount => _isHandsUpCount;

  ValueNotifier<bool> _showHandsUpCountTip = ValueNotifier(false);
  ValueListenable<bool> get handsUpCountTip => _showHandsUpCountTip;
  Timer? _handsUpCountTipTimer;

  void init(NERoomContext roomContext) {
    this.roomContext = roomContext;
    roomEventCallback = NERoomEventCallback(
      memberPropertiesChanged: handleMemberPropertiesEvent,
      memberPropertiesDeleted: handleMemberPropertiesEvent,
      memberLeaveRoom: memberLeaveRoom,
    );
    _isHandsUp.value = roomContext.localMember.isRaisingHand;
    updateHandsUpCount();
    roomContext.addEventCallback(roomEventCallback!);
  }

  void handleMemberPropertiesEvent(
      NERoomMember member, Map<String, String> properties) {
    if (!properties.containsKey(HandsUpProperty.key)) return;
    if (member.uuid == roomContext?.localMember.uuid) {
      _isHandsUp.value = roomContext!.localMember.isRaisingHand;
    }
    updateHandsUpCount();

    /// 新的举手出现时，显示提示
    if (member.isRaisingHand) {
      showHandsUpCountTip();
    }
  }

  void memberLeaveRoom(List<NERoomMember> userList) {
    updateHandsUpCount();
  }

  void updateHandsUpCount() {
    _isHandsUpCount.value =
        roomContext!.getAllUsers().where((user) => user.isRaisingHand).length;
  }

  void raiseMyHand() async {
    if (roomContext == null) return;
    final result = await roomContext!.raiseMyHand();
    ToastUtils.showBotToast(result.isSuccess()
        ? NEMeetingUIKit.instance.getUIKitLocalizations().meetingHandsUpSuccess
        : (result.msg ??
            NEMeetingUIKit.instance
                .getUIKitLocalizations()
                .meetingHandsUpFail));
  }

  void lowerMyHand() async {
    if (roomContext == null) return;
    final result = await roomContext!.lowerMyHand();
    if (!result.isSuccess()) {
      ToastUtils.showBotToast(result.msg ??
          NEMeetingUIKit.instance
              .getUIKitLocalizations()
              .meetingCancelHandsUpFail);
    }
  }

  void handsUpDownAll(BuildContext context) async {
    if (roomContext == null) return;
    final result = await roomContext!.handsUpDownAll();
    final localizations = NEMeetingUIKit.instance.getUIKitLocalizations();
    ToastUtils.showBotToast(result.isSuccess()
        ? localizations.meetingHandsUpDownAllSuccess
        : localizations.meetingHandsUpDownAllFail);
  }

  /// 展示举手数量，五秒自动消失
  void showHandsUpCountTip() {
    _handsUpCountTipTimer?.cancel();
    _showHandsUpCountTip.value = true;
    _handsUpCountTipTimer = Timer(const Duration(seconds: 5), () {
      _showHandsUpCountTip.value = false;
    });
  }

  /// 取消举手数量提示
  void cancelHandsUpCountTip() {
    _handsUpCountTipTimer?.cancel();
    _showHandsUpCountTip.value = false;
  }

  void dispose() {
    if (roomEventCallback != null) {
      roomContext?.removeEventCallback(roomEventCallback!);
    }
    _handsUpCountTipTimer?.cancel();
  }
}
