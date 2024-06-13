// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_kit;

/// 卡片通知数据
///
class NotifyCardData {
  String? tag;
  CardData? data;

  NotifyCardData({tag, body});

  NotifyCardData.fromMap(Map<String, dynamic> json) {
    tag = json['tag'];
    data = json['data'] != null ? CardData.fromMap(json['data']) : null;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> dataMap = Map<String, dynamic>();
    dataMap['tag'] = tag;
    if (data != null) {
      dataMap['body'] = data!.toMap();
    }
    return dataMap;
  }
}

/// 卡片数据
///
class CardData {
  int? meetingId;
  String? meetingNum;
  String? type;
  int? timestamp;

  /// 弹窗持续时间
  int? popupDuration;
  String? pluginId;
  NotifyCard? notifyCard;
  InviteInfo? inviteInfo;
  String? roomUuid;

  CardData({meetingId, type, notifyCard});

  CardData.fromMap(Map<String, dynamic> json) {
    meetingId = json['meetingId'];
    meetingNum = json['meetingNum'];
    type = json['type'];
    timestamp = json['timestamp'];
    pluginId = json['pluginId'];
    notifyCard = json['notifyCard'] != null
        ? NotifyCard.fromMap(json['notifyCard'])
        : null;
    inviteInfo = json['inviteInfo'] != null
        ? InviteInfo.fromMap(json['inviteInfo'])
        : null;
    roomUuid = json['roomUuid'];
    popupDuration = json['popupDuration'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['meetingId'] = meetingId;
    data['meetingNum'] = meetingNum;
    data['timestamp'] = timestamp;
    data['pluginId'] = pluginId;
    data['type'] = type;
    if (notifyCard != null) {
      data['notifyCard'] = notifyCard!.toMap();
    }
    if (inviteInfo != null) {
      data['inviteInfo'] = inviteInfo!.toMap();
    }
    data['roomUuid'] = roomUuid;
    data['popupDuration'] = popupDuration;
    return data;
  }
}

class NotifyCard {
  Header? header;
  Body? body;
  String? notifyCenterCardClickAction;
  bool? popUp;
  List<PopUpCardBottomButton>? popUpCardBottomButton;

  NotifyCard(
      {header,
      body,
      notifyCenterCardClickAction,
      popUp,
      popUpCardBottomButton});

  NotifyCard.fromMap(Map<String, dynamic> json) {
    header = json['header'] != null ? Header.fromMap(json['header']) : null;
    body = json['body'] != null ? Body.fromMap(json['body']) : null;
    notifyCenterCardClickAction = json['notifyCenterCardClickAction'];
    popUp = json['popUp'];
    if (json['popUpCardBottomButton'] != null) {
      popUpCardBottomButton = <PopUpCardBottomButton>[];
      json['popUpCardBottomButton'].forEach((v) {
        popUpCardBottomButton!.add(PopUpCardBottomButton.fromMap(v));
      });
    }
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (header != null) {
      data['header'] = header!.toMap();
    }
    if (body != null) {
      data['body'] = body!.toMap();
    }
    data['notifyCenterCardClickAction'] = notifyCenterCardClickAction;
    data['popUp'] = popUp;
    if (popUpCardBottomButton != null) {
      data['popUpCardBottomButton'] =
          popUpCardBottomButton!.map((v) => v.toMap()).toList();
    }
    return data;
  }
}

class Header {
  String? icon;
  String? subject;

  Header({icon, subject});

  Header.fromMap(Map<String, dynamic> json) {
    icon = json['icon'];
    subject = json['subject'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['icon'] = icon;
    data['subject'] = subject;
    return data;
  }
}

class Body {
  String? title;
  String? content;

  Body({title, content});

  Body.fromMap(Map<String, dynamic> json) {
    title = json['title'] ?? '';
    content = json['content'] ?? '';
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = title;
    data['content'] = content;
    return data;
  }
}

class PopUpCardBottomButton {
  String? name;
  String? action;

  PopUpCardBottomButton({name, action});

  PopUpCardBottomButton.fromMap(Map<String, dynamic> json) {
    name = json['name'];
    action = json['action'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['action'] = action;
    return data;
  }
}

class InviteInfo {
  String? inviterName;
  String? inviterIcon;
  String? subject;
  bool? outOfMeeting;

  InviteInfo({
    required this.inviterName,
    this.inviterIcon,
    required this.subject,
    this.outOfMeeting,
  });

  InviteInfo.fromMap(Map<String, dynamic> json) {
    inviterName = json['inviterName'];
    inviterIcon = json['inviterIcon'];
    subject = json['subject'];
    outOfMeeting = json['outOfMeeting'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['inviterName'] = inviterName;
    data['inviterIcon'] = inviterIcon;
    data['subject'] = subject;
    data['outOfMeeting'] = outOfMeeting;
    return data;
  }
}

class NENotifyCenterCardType {
  /// 会议邀请通知
  static const String meetingInvite = 'MEETING.INVITE';
}
