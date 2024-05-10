// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
part of meeting_service;

class _CreateMeetingApi extends HttpApi<MeetingInfo> {
  NEMeetingType meetingType;

  _CreateMeetingRequest request;

  _CreateMeetingApi(this.meetingType, this.request);

  @override
  String get method => 'PUT';

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/create/${meetingType.type}';

  @override
  MeetingInfo result(Map map) => MeetingInfo.fromMap(map);

  @override
  Map data() => request.data;
}

class _GetMeetingInfoApi extends HttpApi<MeetingInfo> {
  final String meetingNum;

  _GetMeetingInfoApi(this.meetingNum);

  @override
  String get method => 'GET';

  @override
  String path() =>
      'scene/meeting/${ServiceRepository().appKey}/v1/info/$meetingNum';

  @override
  MeetingInfo result(Map map) => MeetingInfo.fromMap(map);

  @override
  Map data() => {};
}

class _GetMeetingInfoApi2 extends HttpApi<MeetingInfo> {
  final String meetingCode;

  _GetMeetingInfoApi2(this.meetingCode);

  @override
  String get method => 'GET';

  @override
  String path() => 'scene/meeting/v1/invite/info/$meetingCode';

  @override
  MeetingInfo result(Map map) => MeetingInfo.fromMap(map);

  @override
  Map data() => {};
}
