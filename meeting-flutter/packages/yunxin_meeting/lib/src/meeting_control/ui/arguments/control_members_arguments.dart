// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

typedef ActionCallback = void Function(int actionType, int? roomUid, InMeetingMemberInfo? member);

class ControlMembersArguments {
  final String meetingId;

  final ActionCallback callback;

  final MembersDataSource memberSource;

  ControlMembersArguments({
    required this.meetingId,
    required this.memberSource,
    required this.callback,
  });

  bool isHost() {
    return hostAccountId == ControlProfile.pairedAccountId;
  }

  bool isFocus() {
    return focusAccountId == ControlProfile.pairedAccountId;
  }

  String? get hostAccountId => memberSource.hostAccountId;

  String? get focusAccountId => memberSource.focusAccountId;

  int get joinControlType => memberSource.joinControlType;

  bool showRename(String? userId) => false;

  InMeetingMemberInfo? findMemberInfo(int roomUid, {fake = false}) {
    return memberSource.roomUid2Members[roomUid];
  }

  bool isScreenShare(String? userId) {
    return memberSource.screenSharersUid.contains(userId);
  }

  bool isWhiteBoardShare(int? avRoomUid) {
    return memberSource.whiteboardAvRoomUid.contains('$avRoomUid');
  }

  bool isWhiteBoardOwner(int? avRoomUid) {
    var whiteboardAvRoomUid = memberSource.whiteboardAvRoomUid;
    return whiteboardAvRoomUid.isNotEmpty &&
        findMemberInfo(int.parse(whiteboardAvRoomUid.first))?.accountId ==
            UserProfile.accountId;
  }
}

class MembersDataSource {
  StreamController<dynamic> membersNotify = StreamController.broadcast();

  List<int> uidMembers;

  List<int> searchUidMembers = <int>[];

  bool inSearch = false;

  MeetingInfo? meetingInfo;

  Map<int, InMeetingMemberInfo> roomUid2Members = <int, InMeetingMemberInfo>{};

  MembersDataSource.empty() : this([], null);

  MembersDataSource(this.uidMembers, this.meetingInfo);

  String? get hostAccountId => meetingInfo?.hostAccountId;

  String? get focusAccountId => meetingInfo?.focusAccountId;

  int get joinControlType => meetingInfo?.joinControlType ?? JoinControlType.allowJoin;

  int get length => inSearch ? searchUidMembers.length : uidMembers.length;

  Set<String> get screenSharersUid => meetingInfo?.screenSharersAccountId ?? <String>{};

  Set<String> get whiteboardAvRoomUid => meetingInfo?.whiteboardAvRoomUid ?? <String>{};

  Stream get stream => membersNotify.stream;

  void update(List<int> members, MeetingInfo? meetingInfo, Map<int, InMeetingMemberInfo> roomUid2Members) {
    uidMembers = members;
    this.meetingInfo = meetingInfo;
    this.roomUid2Members = roomUid2Members;
    sortMember();
    membersNotify.add(this);
  }

  void sortMember() {
    InMeetingMemberInfo? temp1, temp2;
    int t;
    uidMembers.sort((value1, value2) {
      temp1 = roomUid2Members[value1];
      temp2 = roomUid2Members[value2];
      if (temp1?.accountId == hostAccountId) {
        return -1;
      }
      if (temp2?.accountId == hostAccountId) {
        return 1;
      }
      t = (temp2?.getAudioHandsUpTime() ?? -1).compareTo((temp1?.getAudioHandsUpTime() ?? -1));
      if (t == 0) {
        return (temp1?.audio ?? AVState.close).compareTo(temp2?.audio ?? AVState.close);
      }
      return t;
    });
  }

  int get(int index) {
    return inSearch ? searchUidMembers[index] : uidMembers[index];
  }

  void onSearch(String? value) {
    var text = value?.trim();
    if (text == null || text.isEmpty) {
      resetSearch();
    } else {
      searchUidMembers.clear();
      inSearch = true;
      roomUid2Members.values.forEach((element) {
        if (element.nickName.contains(text) && uidMembers.contains(element.avRoomUid)) {
          searchUidMembers.add(element.avRoomUid);
        }
      });
    }
  }

  void resetSearch() {
    inSearch = false;
    searchUidMembers.clear();
  }

  void dispose() {
    membersNotify.close();
  }
}
