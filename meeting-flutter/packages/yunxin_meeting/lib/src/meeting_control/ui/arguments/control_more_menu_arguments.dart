// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

typedef MoreMenuActionCallback = void Function(NEMenuClickInfo clickInfo);

class ControlMoreMenuArguments {
  ControlMeetingArguments? controlMeetingArguments;
  MoreMenuActionCallback? moreMenuActionCallback;
  Map<int, ControllerCyclicStateListController>? menuId2Controller;
  String? hostAccountId;

  ControlMoreMenuArguments({
    this.controlMeetingArguments,
    this.moreMenuActionCallback,
    this.menuId2Controller,
    this.hostAccountId,
  });
}

class ControllerCyclicStateListController extends ControllerMenuStateController<NEMenuItemState> {
  final List<NEMenuItemState> stateList;

  late int _currentIndex;

  ControllerCyclicStateListController({required this.stateList, required NEMenuItemState initialState, ValueListenable? listenTo})
      : assert(stateList.isNotEmpty),
        assert(Set.from(stateList).length == stateList.length),
        assert(stateList.contains(initialState)),
        super(
        initialState: initialState,
        listenTo: listenTo,
      ) {
    _currentIndex = stateList.indexOf(initialState);
    value = initialState;
  }

  @override
  void moveState() {
    _currentIndex = (_currentIndex + 1) % stateList.length;
    value = stateList[_currentIndex];
  }
}

abstract class ControllerMenuStateController<T> extends ValueNotifier<T> {
  final ValueListenable? listenTo;

  int _transitionVersion = 0;

  ControllerMenuStateController({
    required T initialState,
    this.listenTo,
  }) : super(initialState) {
    listenTo?.addListener(moveState);
  }

  void didStateTransition(Future<bool>? transitionController) {
    if (transitionController != null) {
      final ver = ++_transitionVersion;
      transitionController.then((bool didTransition) {
        if (didTransition && ver == _transitionVersion) {
          moveState();
        }
      });
    }
  }

  void moveState();
}
