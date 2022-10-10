// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// appKey : "092dcd94d2c2566d1ed66061891cdf15"
/// appName : "meeting-qa"
/// edition : {"type":1,"name":"免费版","functionList":[{"code":"maxRoomDuration","description":"单次会议最大时长：1440.0分钟","value":"1440.0","status":1},{"code":"maxRoomMemberCount","description":"会议最多容纳：10000人","value":"10000","status":1},{"code":"maxConcurrency","description":"全局最大并发：10000","value":"10000","status":1},{"code":"beauty","description":"美颜：不支持","status":2},{"code":"meetingLive","description":"会议直播：不支持","status":2},{"code":"personalShortId","description":"个人会议短号：不支持","status":2},{"code":"sso","description":"SSO：不支持","status":2},{"code":"sdk","description":"组件调用：不支持","status":2},{"code":"organization","description":"组织架构托管：不支持","status":2}],"expireAt":-1,"extra":"2020年12月15日之前免费版用户可限时享受单场最大参会人数100人、最长24小时会议权益。"}

class AccountAppInfo {
  final String appKey;
  final String appName;
  final int createTime;
  // final Edition edition;

  AccountAppInfo.fromJson(Map json)
      : appKey = json['appKey'] as String,
        appName = json['appName'] as String,
        createTime = json['createTime'] as int? ?? 0;
  // edition = Edition.fromJson(json['edition'] as Map);

}

/// type : 1
/// name : "免费版"
/// functionList : [{"code":"maxRoomDuration","description":"单次会议最大时长：1440.0分钟","value":"1440.0","status":1},{"code":"maxRoomMemberCount","description":"会议最多容纳：10000人","value":"10000","status":1},{"code":"maxConcurrency","description":"全局最大并发：10000","value":"10000","status":1},{"code":"beauty","description":"美颜：不支持","status":2},{"code":"meetingLive","description":"会议直播：不支持","status":2},{"code":"personalShortId","description":"个人会议短号：不支持","status":2},{"code":"sso","description":"SSO：不支持","status":2},{"code":"sdk","description":"组件调用：不支持","status":2},{"code":"organization","description":"组织架构托管：不支持","status":2}]
/// expireAt : -1
/// extra : "2020年12月15日之前免费版用户可限时享受单场最大参会人数100人、最长24小时会议权益。"

class Edition {
  final int type;
  final String name;
  final List<Feature> featureList;
  final int expireAt;
  final String? extra;

  // int get type => _type;
  // String get name => _name;
  // List<FunctionList> get functionList => _functionList;
  // int get expireAt => _expireAt;
  // String get extra => _extra;

//   Edition({
//       int type,
//       String name,
//       List<FunctionList> functionList,
//       int expireAt,
//       String extra}){
//     _type = type;
//     _name = name;
//     _functionList = functionList;
//     _expireAt = expireAt;
//     _extra = extra;
// }

  Edition.fromJson(Map json)
      : type = json['type'] as int,
        name = json['name'] as String,
        featureList = ((json['functionList'] ?? []) as List)
            .map((e) => Feature.fromJson(e as Map))
            .toList(),
        expireAt = (json['expireAt'] ?? 0) as int,
        extra = json['extra'] as String?;

  // Map<String, dynamic> toJson() {
  //   var map = <String, dynamic>{};
  //   map['type'] = _type;
  //   map['name'] = _name;
  //   if (_functionList != null) {
  //     map['functionList'] = _functionList.map((v) => v.toJson()).toList();
  //   }
  //   map['expireAt'] = _expireAt;
  //   map['extra'] = _extra;
  //   return map;
  // }

}

/// code : "maxRoomDuration"
/// description : "单次会议最大时长：1440.0分钟"
/// value : "1440.0"
/// status : 1

class Feature {
  final String code;
  final String description;
  final String? value;
  final int? status;

  // String get code => _code;
  // String get description => _description;
  // String get value => _value;
  // int get status => _status;

//   FunctionList({
//       String code,
//       String description,
//       String value,
//       int status}){
//     _code = code;
//     _description = description;
//     _value = value;
//     _status = status;
// }

  Feature.fromJson(Map json)
      : code = json['code'] as String,
        description = json['description'] as String,
        value = json['value'] as String?,
        status = json['status'] as int?;

  // Map<String, dynamic> toJson() {
  //   var map = <String, dynamic>{};
  //   map['code'] = _code;
  //   map['description'] = _description;
  //   map['value'] = _value;
  //   map['status'] = _status;
  //   return map;
  // }

}
