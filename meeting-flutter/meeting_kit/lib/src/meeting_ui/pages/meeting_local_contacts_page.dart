// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

class ContactInfo extends ISuspensionBean {
  String? name;
  String? namePinyin;
  String? tagIndex;
  String? namePinyinFull;
  List<Phone>? phones;

  ContactInfo({
    this.name,
    this.namePinyin,
    this.tagIndex,
    this.namePinyinFull,
    this.phones,
  });

  get displayName {
    if (TextUtils.isNotEmpty(name)) {
      return name;
    }
    if (phones != null && phones!.isNotEmpty) {
      return phones!.first.number;
    }
    return '';
  }

  @override
  String getSuspensionTag() => tagIndex!;

  @override
  String toString() {
    return 'ContactInfo{name: $name, tagIndex: $tagIndex}';
  }
}

class MeetingLocalContactsPage extends StatefulWidget {
  final void Function(ContactInfo contact) onContactItemClick;
  final ValueListenable<bool> isMySelfManagerListenable;
  final ValueListenable<bool> hideAvatar;

  MeetingLocalContactsPage(
      {required this.onContactItemClick,
      required this.isMySelfManagerListenable,
      required this.hideAvatar});

  @override
  State<MeetingLocalContactsPage> createState() =>
      _MeetingLocalContactsPageState(
          onContactItemClick: onContactItemClick,
          isMySelfManagerListenable: isMySelfManagerListenable,
          hideAvatar: hideAvatar);
}

class _MeetingLocalContactsPageState
    extends LifecycleBaseState<MeetingLocalContactsPage>
    with MeetingKitLocalizationsMixin {
  /// 当前展示的通讯录成员
  List<ContactInfo> _contacts = [];

  /// 所有的通讯录成员
  List<ContactInfo> _fullContacts = [];
  double susItemHeight = 40;
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _searchTextEditingController;
  final ValueListenable<bool> isMySelfManagerListenable;
  final ValueListenable<bool> hideAvatar;

  final void Function(ContactInfo contact) onContactItemClick;

  _MeetingLocalContactsPageState(
      {required this.onContactItemClick,
      required this.isMySelfManagerListenable,
      required this.hideAvatar});

  @override
  void initState() {
    super.initState();
    _searchTextEditingController = TextEditingController()
      ..addListener(() {
        String text = _searchTextEditingController.text;
        if (text.isEmpty) {
          _contacts = _fullContacts;
        } else {
          _contacts = _fullContacts.where((element) {
            return element.displayName.contains(text) ||
                (element.namePinyin?.contains(text) ?? false) ||
                (element.namePinyinFull?.contains(text) ?? false);
          }).toList();
        }
        _handleList(_contacts);
      });
    _loadContacts();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutoPopScope(
      listenable: isMySelfManagerListenable,
      onWillAutoPop: (_) {
        return !isMySelfManagerListenable.value;
      },
      child: PopScope(
        child: Container(
          height: MediaQuery.of(context).size.height * (1.0 - 66.0 / 812) - 100,
          child: MeetingCard(
              margin: EdgeInsets.zero,
              iconData: NEMeetingIconFont.icon_contacts,
              iconColor: _UIColors.color_337eff,
              title: meetingUiLocalizations.sipLocalContacts,
              children: [
                _buildSearch(),
                Container(height: 2, color: _UIColors.colorF0F1F5),
                Expanded(
                  child: _contacts.isEmpty
                      ? _buildEmptyContacts()
                      : _buildListView(),
                ),
              ]),
        ),
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          final navigator = Navigator.of(context);
          if (onWillPop()) {
            navigator.pop();
          }
        },
      ),
    );
  }

  bool onWillPop() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      return false;
    }
    return true;
  }

  _buildEmptyContacts() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(NEMeetingImages.iconEmptyContacts,
              package: NEMeetingImages.package),
          SizedBox(height: 30),
          Text(meetingUiLocalizations.sipLocalContactsEmpty,
              style: TextStyle(fontSize: 14, color: _UIColors.color_999999)),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return AzListView(
      data: _contacts,
      itemCount: _contacts.length,
      itemBuilder: (BuildContext context, int index) {
        ContactInfo model = _contacts[index];
        return _buildListItem(model);
      },
      physics: BouncingScrollPhysics(),
      indexBarData: SuspensionUtil.getTagIndexList(_contacts),
      indexHintBuilder: (context, hint) {
        return Container(
          alignment: Alignment.center,
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: _UIColors.blue_337eff,
            shape: BoxShape.circle,
          ),
          child:
              Text(hint, style: TextStyle(color: Colors.white, fontSize: 30.0)),
        );
      },
      indexBarMargin: EdgeInsets.all(10),
    );
  }

  void _loadContacts() async {
    // Request contact permission
    if (await FlutterContacts.requestPermission(readonly: true)) {
      // Get all contacts (lightly fetched)
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      _fullContacts = contacts
          .map((e) => ContactInfo(name: e.displayName, phones: e.phones))
          .toList();
      _contacts = _fullContacts;
      _handleList(_contacts);
    }
  }

  void _handleList(List<ContactInfo> list) {
    if (list.isEmpty) {
      setState(() {});
      return;
    }
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].displayName);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(list);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(list);

    setState(() {});
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      alignment: Alignment.bottomLeft,
      height: susItemHeight,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$susTag',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 14.0,
              color: _UIColors.colorB3B7BC,
            ),
          ),
          SizedBox(height: 8.0),
          Container(height: 1, color: _UIColors.colorF0F1F5),
        ],
      ),
    );
  }

  Widget _buildListItem(ContactInfo model) {
    String susTag = model.getSuspensionTag();
    return GestureDetector(
      onTap: () {
        if (model.phones?.isNotEmpty == true &&
            TextUtils.isNotEmpty(model.phones!.first.number)) {
          onContactItemClick(model);
          Navigator.of(context).pop();
        } else {
          ToastUtils.showToast(
              context, meetingUiLocalizations.sipContactNoNumber);
        }
      },
      child: Container(
          color: Colors.white,
          margin: EdgeInsets.only(left: 16),
          child: Column(
            children: <Widget>[
              Offstage(
                offstage: model.isShowSuspension != true,
                child: _buildSusWidget(susTag),
              ),
              buildContactItem(model)
            ],
          )),
    );
  }

  Widget buildContactItem(ContactInfo model) {
    return Container(
      height: 56,
      child: Row(
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: hideAvatar,
            builder: (context, hideAvatar, child) {
              return NEMeetingAvatar.large(
                name: model.displayName,
                url: null,
                hideImageAvatar: hideAvatar,
              );
            },
          ),
          SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                model.displayName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _UIColors.black_333333,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 6),
              if (model.phones != null && model.phones!.isNotEmpty)
                Text(
                  model.phones!.first.number,
                  style:
                      TextStyle(color: _UIColors.color_999999, fontSize: 12.0),
                ),
            ],
          )),
          SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
        height: 36,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(
                width: 1,
                color: _focusNode.hasFocus
                    ? _UIColors.color_337eff
                    : _UIColors.colorE6E7EB)),
        child: TextField(
          focusNode: _focusNode,
          controller: _searchTextEditingController,
          cursorColor: _UIColors.blue_337eff,
          keyboardAppearance: Brightness.light,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: 16,
            color: _UIColors.color1E1F27,
          ),
          decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.transparent,
              hintText: meetingUiLocalizations.participantSearchMember,
              hintStyle: TextStyle(
                  fontSize: 16,
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
              suffixIcon: _focusNode.hasFocus &&
                      !TextUtils.isEmpty(_searchTextEditingController.text)
                  ? ClearIconButton(
                      onPressed: () {
                        _searchTextEditingController.clear();
                      },
                    )
                  : null),
        ));
  }

  @override
  void dispose() {
    _searchTextEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
