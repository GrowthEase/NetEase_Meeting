// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_ui;

/// 点击成员的回调事件
/// [contact] 当前点击的成员
/// [currentSelectedSize] 当前已选中的成员数量
/// [maxSelectedSizeTip] 最大可选中的提示信息
/// 返回false表示无法选中
typedef ContactItemClickCallback = bool Function(
    NEContact contact, int currentSelectedSize, String? maxSelectedSizeTip);

class ContactList extends StatefulWidget {
  /// item点击事件，返回false表示无法选中
  final ContactItemClickCallback? itemClickCallback;

  /// 选择用户变更
  final ValueChanged<List<NEContact>>? onSelectedContactListChanged;

  /// 之前已保存的成员uuid列表
  final List<String> alreadySelectedUserUuids;

  /// 选中添加成员的缓存数据
  final List<NEContact> selectedContactsCache;

  /// 是否为单选模式。如果为单选模式，则在选择一个成员后，自动退出页面
  final bool singleMode;

  /// 是否展示搜索提示，默认展示
  final bool showSearchHint;

  final ValueListenable<bool>? hideAvatar;

  ContactList({
    super.key,
    this.itemClickCallback,
    this.alreadySelectedUserUuids = const [],
    this.selectedContactsCache = const [],
    this.onSelectedContactListChanged,
    this.singleMode = false,
    this.showSearchHint = true,
    this.hideAvatar,
  });

  @override
  State<ContactList> createState() => _ContactListState(hideAvatar);
}

class _ContactListState extends State<ContactList>
    with MeetingKitLocalizationsMixin {
  /// 通讯录成员列表，本次选择的成员列表
  List<NEContact> _selectedContacts = [];

  /// 搜索匹配到的成员列表
  List<NEContact> _searchedContacts = [];

  /// 通讯录滑动控制器
  ScrollController _scrollController = ScrollController();

  /// 当前页码数，用于分页加载
  var _currentPage = 1;

  final _searchTextEditingController = TextEditingController();

  final _focusNode = FocusNode();

  final ValueListenable<bool>? hideAvatar;

  _ContactListState(this.hideAvatar);

  @override
  void initState() {
    super.initState();

    _selectedContacts.addAll(widget.selectedContactsCache);
    if (widget.singleMode) {
      _searchedContacts.addAll(widget.selectedContactsCache);
    }

    /// 通讯录搜索框
    _searchTextEditingController
        .addListener(() => searchContacts(_searchTextEditingController.text));

    final text = _searchTextEditingController.text;
    if (text.isNotEmpty) {
      searchContacts(text);
    }
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          /// 加载更多
          ContactsRepository.searchContacts(
                  _searchTextEditingController.text, null, 20, ++_currentPage)
              .then((value) => {
                    setState(() {
                      _searchedContacts.addAll(value.data ?? []);
                    })
                  });
        }
      });
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  /// 搜索通讯录
  void searchContacts(String text) {
    if (!mounted) return;
    if (text.isEmpty) {
      setState(() {
        _searchedContacts.clear();
        if (widget.singleMode) {
          _searchedContacts.addAll(widget.selectedContactsCache);
        }
      });
    } else {
      /// 变换关键字之后重新搜索
      _currentPage = 1;
      ContactsRepository.searchContacts(text, null, 20, _currentPage)
          .then((value) {
        /// 解决请求时序返回问题
        if (text == _searchTextEditingController.text) {
          if (!mounted) return;
          setState(() {
            _searchedContacts = value.data ?? [];
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _focusNode.unfocus();
      },
      child: _buildContacts(),
    );
  }

  /// 通讯录页面
  Widget _buildContacts() {
    return Container(
      decoration: BoxDecoration(
          color: _UIColors.white,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Column(
        children: [
          _buildSearch(),
          if (_selectedContacts.isNotEmpty && !widget.singleMode)
            _buildSelected(),
          Container(height: 1, color: _UIColors.globalBg),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: _buildContactsList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 未搜索到通讯录成员
  Widget _buildEmptyContacts() {
    final searchTextEmpty = _searchTextEditingController.text.isEmpty;
    if (searchTextEmpty && !widget.showSearchHint) {
      return Container();
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(NEMeetingImages.iconNoContacts,
              package: NEMeetingImages.package),
          SizedBox(height: 10),
          Text(
              searchTextEmpty
                  ? meetingUiLocalizations.sipSearchContacts
                  : meetingUiLocalizations.meetingSearchNotFound,
              style: TextStyle(fontSize: 14, color: _UIColors.color_666666)),
        ],
      ),
    );
  }

  /// 搜索框
  Widget _buildSearch() {
    return Material(
      color: Colors.white,
      child: Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: Border.all(width: 1, color: _UIColors.colorE6E7EB)),
          height: 36,
          alignment: Alignment.center,
          child: TextField(
            key: MeetingUIValueKeys.searchTextFieldKey,
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
                    color: _UIColors.colorCDCFD7,
                    decoration: TextDecoration.none),
                border: InputBorder.none,
                prefixIcon: Icon(
                  NEMeetingIconFont.icon_search2_line1x,
                  size: 16,
                  color: _UIColors.colorA6ADB6,
                ),
                prefixIconConstraints: BoxConstraints(
                    minWidth: 32, minHeight: 32, maxHeight: 32, maxWidth: 32),
                suffixIcon: !_focusNode.hasFocus ||
                        TextUtils.isEmpty(_searchTextEditingController.text)
                    ? null
                    : ClearIconButton(
                        onPressed: () {
                          _searchTextEditingController.clear();
                        },
                      )),
          )),
    );
  }

  /// 已选成员列表
  Widget _buildSelected() {
    return Container(
      height: 48,
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: true,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final contact = _selectedContacts[index];
                  return Container(
                    margin: EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: () => _reverseSelectContact(contact),
                      child: ValueListenableBuilder(
                        valueListenable: hideAvatar ?? ValueNotifier(false),
                        builder: (context, hideAvatar, child) {
                          return NEMeetingAvatar.medium(
                            name: contact.name,
                            url: contact.avatar,
                            hideImageAvatar: hideAvatar,
                          );
                        },
                      ),
                    ),
                  );
                },
                itemCount: _selectedContacts.length,
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
              onTap: () {
                setState(() {
                  _selectedContacts.clear();
                  notifySelectedContactsChanged();
                });
              },
              child: Text(meetingUiLocalizations.sipContactsClear,
                  style:
                      TextStyle(fontSize: 14, color: _UIColors.color8D90A0))),
        ],
      ),
    );
  }

  /// 添加或移除已选联系人
  void _reverseSelectContact(NEContact contact) {
    if (_isContactSelected(contact)) {
      _selectedContacts
          .removeWhere((element) => element.userUuid == contact.userUuid);
    } else {
      _selectedContacts.add(contact);
    }
    setState(() {});
    notifySelectedContactsChanged();
  }

  /// 对外通知已选中的联系人发生变化
  void notifySelectedContactsChanged() {
    widget.onSelectedContactListChanged?.call(_selectedContacts);
  }

  /// 通讯录列表
  Widget _buildContactsList() {
    if (_searchedContacts.isEmpty) {
      return _buildEmptyContacts();
    } else {
      return MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final contact = _searchedContacts[index];
              return GestureDetector(
                  onTap: () {
                    if (widget.alreadySelectedUserUuids
                        .contains(contact.userUuid)) {
                      return;
                    }

                    /// 单选模式
                    if (widget.singleMode) {
                      if (widget.itemClickCallback
                              ?.call(contact, _selectedContacts.length, null) !=
                          false) {
                        Navigator.of(context).pop(contact);
                      }
                      return;
                    }

                    /// 取消选择或者外部允许选择的判断
                    if (_isContactSelected(contact) ||
                        widget.itemClickCallback?.call(
                                contact,
                                _selectedContacts.length,
                                meetingUiLocalizations.memberCountOutOfRange) !=
                            false) {
                      _reverseSelectContact(contact);
                    }
                  },
                  child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          if (widget.alreadySelectedUserUuids
                              .contains(contact.userUuid))
                            NEMeetingImages.assetImage(
                                NEMeetingImages.iconCircleCheckedImmutable)
                          else if (_isContactSelected(contact))
                            NEMeetingImages.assetImage(
                                NEMeetingImages.iconCircleChecked)
                          else
                            NEMeetingImages.assetImage(
                                NEMeetingImages.iconCircleUnchecked),
                          SizedBox(width: 8),
                          ValueListenableBuilder(
                            valueListenable: hideAvatar ?? ValueNotifier(false),
                            builder: (context, hideAvatar, child) {
                              return NEMeetingAvatar.large(
                                name: contact.name,
                                url: contact.avatar,
                                hideImageAvatar: hideAvatar,
                              );
                            },
                          ),
                          SizedBox(width: 12),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contact.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: _UIColors.black_333333,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400)),
                              if (TextUtils.isNotEmpty(contact.dept))
                                Text(contact.dept ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: _UIColors.color_999999,
                                        fontSize: 12.0)),
                            ],
                          )),
                        ],
                      )));
            },
            itemCount: _searchedContacts.length,
          ));
    }
  }

  /// 联系人是否是已选中状态
  bool _isContactSelected(NEContact contact) {
    return _selectedContacts
        .any((element) => element.userUuid == contact.userUuid);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchTextEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
