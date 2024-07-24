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

  MeetingLocalContactsPage(
      {required this.onContactItemClick,
      required this.isMySelfManagerListenable});

  @override
  State<MeetingLocalContactsPage> createState() =>
      _MeetingLocalContactsPageState(
          onContactItemClick: onContactItemClick,
          isMySelfManagerListenable: isMySelfManagerListenable);
}

class _MeetingLocalContactsPageState
    extends LifecycleBaseState<MeetingLocalContactsPage>
    with MeetingKitLocalizationsMixin {
  /// 当前展示的通讯录成员
  List<ContactInfo> _contacts = [];

  /// 所有的通讯录成员
  List<ContactInfo> _fullContacts = [];
  double susItemHeight = 25;
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _searchTextEditingController;
  final ValueListenable<bool> isMySelfManagerListenable;

  final void Function(ContactInfo contact) onContactItemClick;

  _MeetingLocalContactsPageState(
      {required this.onContactItemClick,
      required this.isMySelfManagerListenable});

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
      child: Scaffold(
          appBar: TitleBar(
            title: TitleBarTitle(meetingUiLocalizations.sipLocalContacts),
            showBottomDivider: true,
          ),
          body: PopScope(
            child: SafeArea(
                top: false,
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _focusNode.unfocus();
                    },
                    child: DefaultTextStyle(
                      style: TextStyle(decoration: TextDecoration.none),
                      child: Column(
                        children: <Widget>[
                          _buildSearch(),
                          Divider(height: .0),
                          Expanded(
                            child: _contacts.isEmpty
                                ? _buildEmptyContacts()
                                : _buildListView(),
                          ),
                        ],
                      ),
                    ))),
            onPopInvoked: (didPop) async {
              if (didPop) {
                return;
              }
              final navigator = Navigator.of(context);
              if (onWillPop()) {
                navigator.pop();
              }
            },
          )),
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
      margin: EdgeInsets.only(top: 20.0, right: 40),
      height: susItemHeight,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Divider(height: .0),
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
          margin: EdgeInsets.only(left: 20),
          child: Column(
            children: <Widget>[
              Offstage(
                offstage: model.isShowSuspension != true,
                child: _buildSusWidget(susTag),
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5, right: 10),
                    child: NEMeetingAvatar.xxlarge(
                        name: model.displayName, url: null),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        model.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _UIColors.black_333333,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400),
                      ),
                      if (model.phones != null && model.phones!.isNotEmpty)
                        Text(
                          model.phones!.first.number,
                          style: TextStyle(
                              color: _UIColors.color_999999, fontSize: 12.0),
                        ),
                    ],
                  )),
                  SizedBox(width: 20),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildSearch() {
    return Container(
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
