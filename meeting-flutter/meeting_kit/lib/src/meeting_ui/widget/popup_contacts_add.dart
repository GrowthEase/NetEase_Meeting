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
    return Column(
      children: [
        Expanded(
          child: ContactList(
            alreadySelectedUserUuids:
                widget.scheduledMemberList.map((e) => e.userUuid).toList(),
            onSelectedContactListChanged: (selectedContacts) {
              setState(() {
                newContactList = selectedContacts;
              });
            },
            itemClickCallback: widget.itemClickCallback,
            hideAvatar: hideAvatar,
          ),
        ),
        Container(height: 0.5, color: _UIColors.colorE6E7EB),
        buildActionButton(),
      ],
    );
  }

  Widget buildActionButton() {
    return Container(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 10 + MediaQuery.of(context).padding.bottom),
        color: _UIColors.white,
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                return states.contains(WidgetState.disabled)
                    ? _UIColors.color50337eff
                    : _UIColors.color337eff;
              }),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  side: BorderSide(
                      color: newContactList.length > 0
                          ? _UIColors.color337eff
                          : _UIColors.color50337eff,
                      width: 0),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              )),
          onPressed: newContactList.length > 0
              ? () {
                  if (newContactList.length <= 0) {
                    return;
                  }
                  addScheduledMembers();
                  Navigator.maybePop(context);
                }
              : null,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: Text(
              NEMeetingUIKit.instance.getUIKitLocalizations().globalSure,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }
}
