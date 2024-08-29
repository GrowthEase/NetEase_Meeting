// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

typedef List<String> GetMemberSubTitles(NEScheduledMember member);
typedef Future<bool> OnWillRemoveAttendee(String userId);

class ContactsPopup extends StatefulWidget {
  final String Function(int size) titleBuilder;
  final List<NEScheduledMember> scheduledMemberList;
  final Map<String, NEContact> contactMap;
  final String myUserUuid;
  final String? ownerUuid;
  final Future Function()? addActionClick;
  final Future Function()? loadMoreContacts;
  final GetMemberSubTitles? getMemberSubTitles;
  final OnWillRemoveAttendee? onWillRemoveAttendee;
  final bool editable;
  final ValueListenable<bool> hideAvatar;

  const ContactsPopup({
    super.key,
    required this.titleBuilder,
    required this.scheduledMemberList,
    required this.contactMap,
    required this.myUserUuid,
    required this.ownerUuid,
    required this.editable,
    this.addActionClick,
    this.loadMoreContacts,
    this.getMemberSubTitles,
    this.onWillRemoveAttendee,
    required this.hideAvatar,
  });

  @override
  State<ContactsPopup> createState() => _ContactsPopupState(hideAvatar);
}

class _ContactsPopupState extends PopupBaseState<ContactsPopup>
    with MeetingKitLocalizationsMixin {
  final ValueListenable<bool> hideAvatar;

  _ContactsPopupState(this.hideAvatar);

  @override
  String get title =>
      widget.titleBuilder.call(widget.scheduledMemberList.length);

  List<NEScheduledMember> get scheduledMemberList => widget.scheduledMemberList;
  List<NEContact> get _contactList => scheduledMemberList
      .map((e) => widget.contactMap[e.userUuid])
      .whereType<NEContact>()
      .toList();

  /// 滑动控制器
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          widget.loadMoreContacts?.call().then((value) => setState(() {}));
        }
      });
  }

  @override
  List<Widget> buildActions() => [
        if (widget.editable)
          GestureDetector(
            onTap: () => widget.addActionClick?.call().then((value) {
              setState(() {});
            }),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                meetingUiLocalizations.globalAdd,
                style: TextStyle(
                  color: _UIColors.color_337eff,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ];

  @override
  Widget buildBody() {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true, //去除顶部的空白
        child: ListView.separated(
          controller: _scrollController,
          itemBuilder: (context, index) {
            return buildContactItem(_contactList[index]);
          },
          separatorBuilder: (context, index) => buildSplit(),
          itemCount: _contactList.length,
        ));
  }

  /// 是不是自己
  bool isMySelf(String? uuid) => uuid == widget.myUserUuid;

  /// 是不是会议创建者
  bool isMeetingOwner(String? uuid) => uuid == widget.ownerUuid;

  Widget buildContactItem(NEContact contact) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.editable ? handleMemberItemClick(contact) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          child: Row(
            children: [
              ValueListenableBuilder(
                valueListenable: hideAvatar,
                builder: (context, hideAvatar, child) {
                  return NEMeetingAvatar.medium(
                    name: contact.name,
                    url: contact.avatar,
                    showRoleIcon: isMeetingOwner(contact.userUuid),
                    hideImageAvatar: hideAvatar,
                  );
                },
              ),
              SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contact.name ?? '',
                    style: TextStyle(
                      color: _UIColors.color_333333,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  _memberItemSubTitle(scheduledMemberList
                      .where((element) => element.userUuid == contact.userUuid)
                      .firstOrNull),
                ],
              ))
            ],
          ),
        ));
  }

  /// 用户头衔
  Widget _memberItemSubTitle(NEScheduledMember? member) {
    if (member == null) return SizedBox.shrink();
    var subtitle = <String>[];
    if (member.role == MeetingRoles.kHost) {
      subtitle.add(meetingUiLocalizations.participantHost);
    }
    if (member.role == MeetingRoles.kCohost) {
      subtitle.add(meetingUiLocalizations.participantCoHost);
    }
    subtitle.addAll(widget.getMemberSubTitles?.call(member) ?? []);
    if (member.userUuid == widget.myUserUuid) {
      subtitle.add(meetingUiLocalizations.participantMe);
    }
    if (subtitle.isEmpty) return SizedBox.shrink();
    return Text(
      subtitle.join('，'),
      style: TextStyle(
        color: _UIColors.color_999999,
        fontSize: 12,
      ),
    );
  }

  /// 点击成员出现底部操作菜单
  void handleMemberItemClick(NEContact contact) {
    final isCoHost = scheduledMemberList
        .where((element) => element.userUuid == contact.userUuid)
        .any((element) => element.role == MeetingRoles.kCohost);
    final isMySelf = contact.userUuid == widget.myUserUuid;
    final actions = [
      buildActionSheet(meetingUiLocalizations.participantSetHost, contact,
          ScheduledMemberActionType.setHost),
      if (!isCoHost)
        buildActionSheet(meetingUiLocalizations.participantSetCoHost, contact,
            ScheduledMemberActionType.setCoHost)
      else
        buildActionSheet(meetingUiLocalizations.participantCancelCoHost,
            contact, ScheduledMemberActionType.cancelCoHost),
      if (!isMySelf)
        buildActionSheet(meetingUiLocalizations.participantRemoveAttendee,
            contact, ScheduledMemberActionType.removeAttendee,
            color: _UIColors.colorF24957),
    ];
    DialogUtils.showChildNavigatorPopup<ScheduledMemberAction>(
      context,
      (context) => CupertinoActionSheet(
        title: Text(
          '${contact.name}',
          style: TextStyle(color: _UIColors.grey_8F8F8F, fontSize: 13),
        ),
        actions: actions,
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: buildPopupText(meetingUiLocalizations.globalCancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    ).then<void>((ScheduledMemberAction? value) {
      if (value != null) {
        handleScheduleMemberAction(value);
      }
    });
  }

  /// 处理底部弹窗点击事件
  void handleScheduleMemberAction(ScheduledMemberAction action) {
    switch (action.action) {
      case ScheduledMemberActionType.setHost:
        setHostRole(action.contact.userUuid);
        break;
      case ScheduledMemberActionType.setCoHost:
        setCoHostRole(action.contact.userUuid);
        break;
      case ScheduledMemberActionType.cancelCoHost:
        cancelCoHostRole(action.contact.userUuid);
        break;
      case ScheduledMemberActionType.removeAttendee:
        removeAttendee(action.contact.userUuid);
        break;
    }
  }

  /// 构建底部操作菜单item
  Widget buildActionSheet(String text, NEContact contact,
      ScheduledMemberActionType memberActionType,
      {Color? color}) {
    return CupertinoActionSheetAction(
      child: buildPopupText(text, color: color),
      onPressed: () {
        Navigator.pop(
            context, ScheduledMemberAction(contact, memberActionType));
      },
    );
  }

  /// 构建操作菜单item文本
  Widget buildPopupText(String text, {Color? color}) {
    return Text(text,
        style: TextStyle(color: color ?? _UIColors.color_007AFF, fontSize: 20));
  }

  /// 设置为主持人
  void setHostRole(String userUuid) {
    scheduledMemberList.forEach((value) {
      if (value.role == MeetingRoles.kHost) {
        value.role = MeetingRoles.kMember;
      }
      if (value.userUuid == userUuid) {
        value.role = MeetingRoles.kHost;
      }
    });
    scheduledMemberList.sort((a, b) => NEScheduledMemberExt.compareMember(
        a, b, widget.myUserUuid, widget.ownerUuid));
    setState(() {});
  }

  /// 设置为联席主持人
  void setCoHostRole(String userUuid) {
    /// 判断角色超限
    if (scheduledMemberList
            .where((value) => value.role == MeetingRoles.kCohost)
            .length >=
        NEMeetingKit.instance
            .getSettingsService()
            .getScheduledMemberConfig()
            .coHostLimit) {
      ToastUtils.showToast(
          context, meetingUiLocalizations.participantOverRoleLimitCount);
      return;
    }
    scheduledMemberList.forEach((value) {
      if (value.userUuid == userUuid) {
        value.role = MeetingRoles.kCohost;
      }
    });
    scheduledMemberList.sort((a, b) => NEScheduledMemberExt.compareMember(
        a, b, widget.myUserUuid, widget.ownerUuid));
    setState(() {});
  }

  /// 取消联席主持人
  void cancelCoHostRole(String userUuid) {
    scheduledMemberList.forEach((value) {
      if (value.userUuid == userUuid) {
        value.role = MeetingRoles.kMember;
      }
    });
    scheduledMemberList.sort((a, b) => NEScheduledMemberExt.compareMember(
        a, b, widget.myUserUuid, widget.ownerUuid));
    setState(() {});
  }

  /// 删除参会者
  void removeAttendee(String userUuid) async {
    final willRemove =
        await widget.onWillRemoveAttendee?.call(userUuid) == true;
    if (!willRemove || !mounted) return;
    _contactList.removeWhere((element) => element.userUuid == userUuid);
    scheduledMemberList.removeWhere((element) => element.userUuid == userUuid);
    setState(() {});
  }
}

class ScheduledMemberAction {
  final NEContact contact;
  final ScheduledMemberActionType action;

  ScheduledMemberAction(this.contact, this.action);
}

enum ScheduledMemberActionType {
  setHost,
  setCoHost,
  cancelCoHost,
  removeAttendee,
}
