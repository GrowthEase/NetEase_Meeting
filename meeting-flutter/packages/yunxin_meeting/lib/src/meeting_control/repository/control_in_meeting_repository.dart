// Copyright (c) 2021 NetEase, Inc.  All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of meeting_control;

class ControlInMeetingRepository {
  static Stream<ControlActionData> controlMessageStream() {
    return ControlMessageListener().controlMessageStream;
  }

  /// 同步账号给tv
  static Future<NEResult<void>> bindTV(SyncControlAccountData data) {
    return control(data);
  }

  /// 创建会议
  static Future<NEResult<void>> createMeeting(CreateMeetingData data) {
    return control(data);
  }

  /// 加入会议
  static Future<NEResult<void>> joinMeeting(JoinMeetingData data) {
    return control(data);
  }

  /// 取消创建或者加入会议
  static Future<NEResult<void>> cancelMeeting(CancelMeetingData data) {
    return control(data);
  }

  /// 请求tv会议信息
  static Future<NEResult<void>> requestTVStatus(String accountId) {
    return control(RequestTVStatusData());
  }

  /// 遥控器和tv断开连接
  static Future<NEResult<void>> disconnectTV() {
    return control(DisconnectTVData());
  }

  /// 离开会议
  static Future<NEResult<void>> leaveMeeting(String? accountId) {
    return control(LeaveMeetingData(0));
  }

  /// 结束会议
  static Future<NEResult<void>> stopMeeting(String? accountId) {
    return control(FinishMeetingData(0));
  }

  /// 移除参会者
  static Future<NEResult<void>> removeAttendee(String operaUser) {
    return control(RemoveAttendeeData(operaUser));
  }

  /// 主持人让其他人放下手
  static Future<NEResult<void>> hostRejectAudioHandsUp(String operaUser) {
    return control(HostRejectAudioHandsUpData(operaUser));
  }

  static Future<NEResult<void>> requestJoinersFromTV(String? accountId) {
    return control(RequestJoinersFromTVData());
  }

  static Future<NEResult<void>> changeShowType(int showType) {
    return control(ShowTypeData(showType));
  }

  static Future<NEResult<void>> turnPage(bool isDown) {
    return control(TurnPageData(isDown ? actionTurnPageDown : actionTurnPageUp));
  }

  static Future<NEResult<void>> checkUpdate(int requestId, bool isOnlyCheckForce) {
    return control(RequestUpdateData(requestId, isOnlyCheckForce));
  }

  static Future<NEResult<void>> notifyTVUpdate(String? accountId) {
    return control(NotifyTVUpdateData());
  }

  static Future<NEResult<void>> requestMembers(int requestId, int? avUid) {
    return control(RequestMembersData(requestId, avUid));
  }

  static Future<NEResult<void>> changeLockState(String meetingId, bool isLock) {
    return control(LockStatusChangeData(isLock ? JoinControlType.forbidden : JoinControlType.allowJoin));
  }

  /// 静音
  static Future<NEResult<void>> hostMuteAudio(
      {required String fromUser, int? allowSelfAudioOn, required String operaUser}) {
    return control(HostAudioControlData(fromUser, 3, allowSelfAudioOn, operaUser));
  }

  /// 全体静音
  static Future<NEResult<void>> hostMuteAllAudio({required String fromUser, required int allowSelfAudioOn}) {
    return hostMuteAudio(fromUser: fromUser, allowSelfAudioOn: allowSelfAudioOn, operaUser: '');
  }

  /// 解除静音
  static Future<NEResult<void>> hostUnMuteAudio({required String fromUser, required String operaUser}) {
    return control(HostAudioControlData(fromUser, 4, 1, operaUser));
  }

  /// 解除全体静音
  static Future<NEResult<void>> hostUnMuteAllAudio({required String fromUser}) {
    return hostUnMuteAudio(fromUser: fromUser, operaUser: '');
  }

  /// 成员打开自身声音
  static Future<NEResult<void>> unMuteSelfAudio() {
    return control(SelfAudioControlData(1));
  }

  /// 成员关闭自身声音
  static Future<NEResult<void>> muteSelfAudio() {
    return control(SelfAudioControlData(2));
  }

  /// 关闭视频
  static Future<NEResult<void>> hostMuteVideo({required String? fromUser, required String operaUser}) {
    return control(HostVideoControlData(fromUser, 3, operaUser));
  }

  /// 打开视频
  static Future<NEResult<void>> hostUnMuteVideo({required String? fromUser, required String operaUser}) {
    return control(HostVideoControlData(fromUser, 4, operaUser));
  }

  /// 成员打开自身视频
  static Future<NEResult<void>> unMuteSelfVideo() {
    return control(SelfVideoControlData(1));
  }

  /// 成员关闭自身视频
  static Future<NEResult<void>> muteSelfVideo() {
    return control(SelfVideoControlData(2));
  }

  /// 全体静音成员举手
  static Future<NEResult<void>> muteAllHandsUp(String meetingId) {
    return control(ActionData(TCProtocol.selfHandsUp, 0));
  }

  /// 全体静音成员放手
  static Future<NEResult<void>> muteAllUnHandsUp(String meetingId) {
    return control(ActionData(TCProtocol.selfUnHandsUp, 0));
  }

  /// 更换焦点视频
  static Future<NEResult<void>> changeFocus(String operaUser, bool isFocus) {
    return control(ChangeFocusData(operaUser, isFocus));
  }

  /// 更换主持人
  static Future<NEResult<void>> changeHost(String operaUser) {
    return control(ChangeHostData(operaUser));
  }

  /// 修改昵称
  static Future<NEResult<void>> modifyNick(String userId, String nick) {
    return control(ModifyNickData(userId, nick));
  }

  /// 修改TV昵称
  static Future<NEResult<void>> modifyTVNick(String tvNick) {
    return control(ModifyTVNickData(tvNick));
  }

  /// 意见反馈
  static Future<NEResult<void>> feedback(
      String phone, String category, String description, String deviceId) {
    var time = DateTime.now().millisecondsSinceEpoch;
    return control(FeedbackData(phone, category, description, time, deviceId));
  }

  static Future<NEResult<void>> control(BaseData data) {
    var toAccountId = ControlProfile.pairedAccountId!;
    return NimApiHelper.execute(_ControlApi(_ControlRequest(toAccountId: toAccountId, param: data)));
  }
}
