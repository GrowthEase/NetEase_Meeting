// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ContactsAddPopup extends StatefulWidget {
  final String Function(int size) titleBuilder;
  final List<NEScheduledMember> scheduledMemberList;
  final Map<String, NEContact> contactMap;
  final String myUserUuid;
  final ContactItemClickCallback itemClickCallback;
  final NEMeetingLiveTranscriptionController? transcriptionController;

  const ContactsAddPopup({
    super.key,
    required this.titleBuilder,
    required this.scheduledMemberList,
    required this.contactMap,
    required this.myUserUuid,
    required this.itemClickCallback,
    this.transcriptionController,
  });

  @override
  State<ContactsAddPopup> createState() => _ContactsAddPopupState();
}

class _ContactsAddPopupState extends PopupBaseState<ContactsAddPopup>
    with
        MeetingKitLocalizationsMixin,
        NEMeetingLiveTranscriptionControllerListener {
  List<NEContact> newContactList = [];
  final hideAvatar = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    widget.transcriptionController?.addListener(this);
    hideAvatar.value = widget.transcriptionController?.isAvatarHidden ?? false;
  }

  @override
  void onAvatarHiddenChanged(bool hide) {
    hideAvatar.value = hide;
  }

  @override
  String get title => widget.titleBuilder.call(newContactList.length);

  @override
  List<Widget> buildActions() {
    return [
      GestureDetector(
        onTap: () {
          if (newContactList.length <= 0) {
            return;
          }
          addScheduledMembers();
          Navigator.maybePop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            meetingUiLocalizations.globalSure,
            style: TextStyle(
              color: newContactList.length <= 0
                  ? _UIColors.color_999999
                  : _UIColors.color_337eff,
              fontSize: 16,
            ),
          ),
        ),
      )
    ];
  }

  /// 添加参会者
  void addScheduledMembers() {
    newContactList.forEach((element) {
      widget.scheduledMemberList.add(NEScheduledMember(
        userUuid: element.userUuid,
        role: MeetingRoles.kMember,
      ));
      widget.contactMap[element.userUuid] = element;
    });
  }

  @override
  Widget buildBody() {
    return ContactList(
      alreadySelectedUserUuids:
          widget.scheduledMemberList.map((e) => e.userUuid).toList(),
      onSelectedContactListChanged: (selectedContacts) {
        setState(() {
          newContactList = selectedContacts;
        });
      },
      itemClickCallback: widget.itemClickCallback,
      hideAvatar: hideAvatar,
    );
  }
}
