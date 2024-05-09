// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class MeetingMemberPageView extends StatefulWidget {
  final String Function(PageDataManager pageDataManager)? title;
  final NERoomContext roomContext;
  final WaitingRoomManager? waitingRoomManager;
  final ChatRoomManager? chatRoomManager;
  final Stream? roomInfoUpdatedEventStream;
  final bool Function(_PageData page)? pageFilter;
  final Widget Function(_PageData page, String? searchKey) pageBuilder;
  final int Function(_PageData page, String? searchKey)? memberSize;
  final _MembersPageType? initialPageType;
  final bool showUserEnterHint;

  MeetingMemberPageView({
    this.title,
    required this.roomContext,
    this.waitingRoomManager,
    this.chatRoomManager,
    required this.roomInfoUpdatedEventStream,
    required this.pageBuilder,
    this.memberSize,
    this.initialPageType,
    this.showUserEnterHint = true,
    this.pageFilter,
  });

  @override
  State<StatefulWidget> createState() {
    return _MeetingMemberPageViewState(
      title,
      roomContext,
      waitingRoomManager,
      chatRoomManager,
      roomInfoUpdatedEventStream,
      initialPageType,
      showUserEnterHint,
    );
  }
}

class _MeetingMemberPageViewState
    extends LifecycleBaseState<MeetingMemberPageView>
    with MeetingKitLocalizationsMixin, MeetingStateScope {
  final String Function(PageDataManager pageDataManager)? title;
  final NERoomContext roomContext;
  final WaitingRoomManager? waitingRoomManager;
  final Stream? roomInfoUpdatedEventStream;
  late final PageDataManager pageDataManager;
  final ChatRoomManager? chatRoomManager;
  late final NERoomEventCallback roomEventCallback;
  _MembersPageType? initialPageType;
  final bool showUserEnterHint;

  final _pageIndex = ValueNotifier<int>(0);
  final _pageController = PageController(initialPage: 0);
  _MeetingMemberPageViewState(
    this.title,
    this.roomContext,
    this.waitingRoomManager,
    this.chatRoomManager,
    this.roomInfoUpdatedEventStream,
    this.initialPageType,
    this.showUserEnterHint,
  );
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _searchTextEditingController;

  late void Function() _resetUnreadMemberCount = () {
    if (pageDataManager.pages[_pageIndex.value].type ==
        _MembersPageType.waitingRoom) {
      waitingRoomManager?.resetUnreadMemberCount();
    }
  };

  @override
  void initState() {
    super.initState();
    pageDataManager = PageDataManager(isPageVisible: (pageData) {
      if (!pageData.hasData) return false;
      if (!roomContext.isInWaitingRoom() &&
          pageData.type == _MembersPageType.waitingRoom) {
        return isSelfHostOrCoHost();
      }
      return true;
    });
    roomContext.addEventCallback(roomEventCallback = NERoomEventCallback(
      memberRoleChanged: onMemberRoleChanged,
    ));
    _searchTextEditingController = TextEditingController()
      ..addListener(() {
        pageDataManager.searchKey = _searchTextEditingController.text;
      });
    if (roomInfoUpdatedEventStream != null) {
      lifecycleListen(roomInfoUpdatedEventStream!, (_) {
        setState(() {
          pageDataManager.inMeeting.userList =
              roomContext.getAllUsers().toList();
          _sortNotYetJoinedUserList();

          /// 处理各种异步场景，如果设置过初始化页面却没跳转过，总要跳转过去
          _jumpToInitialPage();
        });
      });
    }
    if (waitingRoomManager != null) {
      lifecycleListen(waitingRoomManager!.userListChanged, (_) {
        setState(() {
          pageDataManager.waitingRoom.userList =
              waitingRoomManager!.userList.toList();
        });
      });
      pageDataManager.waitingRoom.userList =
          waitingRoomManager!.userList.toList();
      waitingRoomManager!.unreadMemberCountListenable
          .addListener(_resetUnreadMemberCount);
    }
    _sortNotYetJoinedUserList();

    if (!roomContext.isInWaitingRoom()) {
      pageDataManager.inMeeting.userList = roomContext.getAllUsers().toList();
    } else if (chatRoomManager != null) {
      pageDataManager.waitingRoom.userList = chatRoomManager!.hostAndCoHost;
      lifecycleListen(chatRoomManager!.waitingRoomHostAndCoHostUpdated, (_) {
        setState(() {
          pageDataManager.waitingRoom.userList = chatRoomManager!.hostAndCoHost;
        });
      });
    }

    _pageIndex.addListener(_resetUnreadMemberCount);

    /// 传入初始页面类型
    _jumpToInitialPage();
    pageDataManager.addListener(() {
      final pages = pageDataManager.pages;

      /// 如果当前选中页面大于总页面数，则跳到第一页
      if (_pageIndex.value >= pages.length) {
        _pageIndex.value = 0;
      }
      _pageController.jumpToPage(_pageIndex.value);
    });
  }

  _sortNotYetJoinedUserList() {
    final userList = [
      ...roomContext.inSIPInvitingMembers,
      ...roomContext.inAppInvitingMembers
    ].toSet().toList();

    /// 未入会列表有排序，呼叫中>等待呼叫>未接听/已拒接/呼叫异常/已取消
    userList.sort((a, b) {
      if (a.inviteState == NERoomMemberInviteState.calling) {
        return -1;
      } else if (b.inviteState == NERoomMemberInviteState.calling) {
        return 1;
      } else if (a.inviteState == NERoomMemberInviteState.waitingCall) {
        return -1;
      } else if (b.inviteState == NERoomMemberInviteState.waitingCall) {
        return 1;
      } else if (a.inviteState == NERoomMemberInviteState.noAnswer ||
          a.inviteState == NERoomMemberInviteState.rejected ||
          a.inviteState == NERoomMemberInviteState.canceled ||
          a.inviteState == NERoomMemberInviteState.error) {
        return 1;
      } else if (b.inviteState == NERoomMemberInviteState.noAnswer ||
          b.inviteState == NERoomMemberInviteState.rejected ||
          b.inviteState == NERoomMemberInviteState.canceled ||
          a.inviteState == NERoomMemberInviteState.error) {
        return -1;
      } else {
        return 0;
      }
    });
    pageDataManager.notYetJoined.userList = userList;
  }

  _jumpToInitialPage() {
    /// 跳过则不跳了
    if (initialPageType == null) return;
    final index = pageDataManager.pages
        .firstIndexOf((page) => page.type == initialPageType);
    if (index != -1) {
      _jumpToPage(index);
      initialPageType = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScopeBuilder(
      child: SafeArea(
        top: false,
        child: Listener(
          onPointerDown: (_) {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
            }
          },
          child: ListenableBuilder(
            listenable: pageDataManager,
            builder: (context, child) {
              return buildContent();
            },
          ),
        ),
      ),
      listenable: _focusNode,
      canPopGetter: (_) => !_focusNode.hasFocus,
      onInterceptPop: () => _focusNode.unfocus(),
      onDidPop: () => _focusNode.unfocus(),
    );
  }

  /// 自己是否是主持人或者联席主持人
  bool isSelfHostOrCoHost() {
    return roomContext.isMySelfHost() || roomContext.isMySelfCoHost();
  }

  void onMemberRoleChanged(
      NERoomMember member, NERoomRole before, NERoomRole after) {
    if (roomContext.isMySelf(member.uuid)) {
      setState(() {});
    }
  }

  Widget buildTitle() {
    return TitleBar(
      title: TitleBarTitle(
        title?.call(pageDataManager) ?? '',
      ),
      showBottomDivider: true,
    );
  }

  Widget buildContent() {
    final pages = pageDataManager.pages.where((page) {
      return widget.pageFilter?.call(page) ?? true;
    }).toList();
    final shouldShowTabBar = pages.length > 1;

    return Column(
      children: <Widget>[
        buildTitle(),
        buildSearch(),
        buildDivider(),
        if (shouldShowTabBar) _buildPageSelector(pages),
        if (shouldShowTabBar) buildDivider(),
        Expanded(
            child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            _pageIndex.value = index;
          },
          children: pages
              .map((page) => widget.pageBuilder
                  .call(page, _searchTextEditingController.text))
              .toList(),
        )),
      ],
    );
  }

  ///构建分割线
  Widget buildDivider({bool isShow = true}) {
    return Visibility(
      visible: isShow,
      child: Container(height: 1, color: _UIColors.globalBg),
    );
  }

  Widget buildSearch() {
    return Material(
      color: Colors.white,
      child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          padding: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
              color: _UIColors.colorF7F8FA,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(width: 1, color: _UIColors.colorF2F3F5)),
          height: 36,
          alignment: Alignment.center,
          child: TextField(
            focusNode: _focusNode,
            controller: _searchTextEditingController,
            cursorColor: _UIColors.blue_337eff,
            keyboardAppearance: Brightness.light,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.transparent,
                hintText: meetingUiLocalizations.participantSearchMember,
                hintStyle: TextStyle(
                    fontSize: 15,
                    color: _UIColors.colorD8D8D8,
                    decoration: TextDecoration.none),
                border: InputBorder.none,
                prefixIcon: Icon(
                  NEMeetingIconFont.icon_search2_line1x,
                  size: 16,
                  color: _UIColors.colorD8D8D8,
                ),
                prefixIconConstraints: BoxConstraints(
                    minWidth: 32, minHeight: 32, maxHeight: 32, maxWidth: 32),
                suffixIcon: TextUtils.isEmpty(_searchTextEditingController.text)
                    ? null
                    : ClearIconButton(
                        onPressed: () {
                          _searchTextEditingController.clear();
                        },
                      )),
          )),
    );
  }

  Widget _buildPageSelector(List<_PageData> pages) {
    return Container(
      height: 38,
      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      decoration: BoxDecoration(
        color: _UIColors.colorEEF0F3,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: _pageIndex,
        builder: (context, value, child) {
          return Row(
            children: [
              for (int i = 0; i < pages.length; i++)
                Expanded(
                    child: GestureDetector(
                        onTap: () => _onPageSelect(i, pages[i].type),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: value == i
                                ? _UIColors.color_337eff
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SafeValueListenableBuilder(
                              valueListenable:
                                  getHintCountListenable(pages[i].type),
                              builder: (BuildContext context,
                                  int unreadMemberCount, _) {
                                return Stack(
                                  children: [
                                    Container(
                                        child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(child: LayoutBuilder(
                                          builder: (BuildContext context,
                                              BoxConstraints constraints) {
                                            return FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                getSubject(pages[i].type),
                                                style: TextStyle(
                                                  color: value == i
                                                      ? _UIColors.white
                                                      : _UIColors.color_333333,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            );
                                          },
                                        )),
                                        _buildMemberSizeWidget(
                                            pages[i], value == i),
                                      ],
                                    )),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Visibility(
                                        visible:
                                            unreadMemberCount > 0 && value != i,
                                        child: ClipOval(
                                            child: Container(
                                                height: 6,
                                                width: 6,
                                                decoration: BoxDecoration(
                                                    color: _UIColors
                                                        .colorFE3B30))),
                                      ),
                                    )
                                  ],
                                );
                              }),
                        )))
            ],
          );
        },
      ),
    );
  }

  void _onPageSelect(int index, _MembersPageType type) {
    _pageIndex.value = index;
    _pageController.jumpToPage(index);
  }

  ValueListenable<int> getHintCountListenable(_MembersPageType type) {
    if (!showUserEnterHint) return ValueNotifier(0);
    switch (type) {
      case _MembersPageType.inMeeting:
        return ValueNotifier(0);
      case _MembersPageType.waitingRoom:
        return waitingRoomManager?.unreadMemberCountListenable ??
            ValueNotifier(0);
      case _MembersPageType.notYetJoined:
        return ValueNotifier(0);
    }
  }

  String getSubject(_MembersPageType type) {
    switch (type) {
      case _MembersPageType.inMeeting:
        return meetingUiLocalizations.participantInMeeting;
      case _MembersPageType.waitingRoom:
        return meetingUiLocalizations.waiting;
      case _MembersPageType.notYetJoined:
        return meetingUiLocalizations.participantNotJoined;
    }
  }

  Widget _buildMemberSizeWidget(_PageData pageData, bool isCurrent) {
    final count =
        widget.memberSize?.call(pageData, _searchTextEditingController.text) ??
            pageData.userCount;
    final textStyle = TextStyle(
      color: isCurrent ? _UIColors.white : _UIColors.color676B73,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    );
    return count > 0
        ? Text(
            '($count)',
            style: textStyle,
          )
        : SizedBox.shrink();
  }

  void _jumpToPage(int index) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _pageIndex.value = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    roomContext.removeEventCallback(roomEventCallback);
    waitingRoomManager?.unreadMemberCountListenable
        .removeListener(_resetUnreadMemberCount);
    _pageIndex.removeListener(_resetUnreadMemberCount);
    pageDataManager.dispose();
    _focusNode.dispose();
    _searchTextEditingController.dispose();
    super.dispose();
  }
}

enum _MembersPageType { inMeeting, waitingRoom, notYetJoined }

class _PageData<T> extends ChangeNotifier {
  final _MembersPageType type;
  final bool Function(T t, String? searchKey) filter;

  _PageData(this.type, this.filter);

  List<T>? _userList;
  List<T>? _filteredUserList;
  set userList(List<T> value) {
    _userList = value;
    _filteredUserList = null;
    notifyListeners();
  }

  List<T> get filteredUserList {
    if (_filteredUserList == null) {
      _filteredUserList =
          _userList?.where((element) => filter(element, _searchKey)).toList();
    }
    return _filteredUserList ?? [];
  }

  int get userCount => _userList?.length ?? 0;

  bool get hasData => _userList?.isNotEmpty ?? false;

  String? _searchKey;
  set searchKey(String? text) {
    _searchKey = text;
    _filteredUserList = null;
    notifyListeners();
  }
}

class PageDataManager extends ChangeNotifier {
  late final inMeeting = _PageData<NEBaseRoomMember>(
    _MembersPageType.inMeeting,
    (user, searchKey) => searchKey == null || user.name.contains(searchKey),
  );

  late final waitingRoom = _PageData<NEBaseRoomMember>(
    _MembersPageType.waitingRoom,
    (user, searchKey) => searchKey == null || user.name.contains(searchKey),
  );

  late final notYetJoined = _PageData<NEBaseRoomMember>(
    _MembersPageType.notYetJoined,
    (user, searchKey) => searchKey == null || user.name.contains(searchKey),
  );

  /// page是否可见
  final _defaultIsPageVisible = (pageData) => pageData.hasData;
  bool Function(_PageData pageData)? isPageVisible;

  PageDataManager({this.isPageVisible}) {
    Listenable.merge([inMeeting, waitingRoom, notYetJoined]).addListener(() {
      notifyListeners();
    });
  }

  List<_PageData> get pages => [
        if ((isPageVisible ?? _defaultIsPageVisible).call(inMeeting)) inMeeting,
        if ((isPageVisible ?? _defaultIsPageVisible).call(waitingRoom))
          waitingRoom,
        if ((isPageVisible ?? _defaultIsPageVisible).call(notYetJoined))
          notYetJoined,
      ];

  set searchKey(String? text) {
    inMeeting.searchKey = text;
    waitingRoom.searchKey = text;
    notYetJoined.searchKey = text;
  }

  bool get shouldShowTabBar => pages.length > 1;
}
