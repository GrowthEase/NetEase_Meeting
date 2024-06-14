// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'meeting_app_localizations.dart';

/// The translations for Chinese (`zh`).
class MeetingAppLocalizationsZh extends MeetingAppLocalizations {
  MeetingAppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get globalAppName => '网易会议';

  @override
  String get globalSure => '确定';

  @override
  String get globalOK => '确认';

  @override
  String get globalQuit => '退出';

  @override
  String get globalAgree => '同意';

  @override
  String get globalDisagree => '不同意';

  @override
  String get globalCancel => '取消';

  @override
  String get globalCopy => '复制';

  @override
  String get globalCopySuccess => '复制成功';

  @override
  String get globalApplication => '应用';

  @override
  String get globalNo => '否';

  @override
  String get globalYes => '是';

  @override
  String get globalComplete => '完成';

  @override
  String get globalResume => '恢复';

  @override
  String get globalCopyright => '网易公司版权所有©1997-2024';

  @override
  String get globalAppRegistryNO => '浙ICP备17006647号-124A';

  @override
  String get globalNetworkUnavailableCheck => '网络连接失败，请检查你的网络连接！';

  @override
  String get globalNetworkNotAvailable => '当前网络不可用，请检查网络设置';

  @override
  String get globalNetworkNotAvailableTitle => '网络连接不可用';

  @override
  String get globalNetworkNotAvailablePart1 => '未能连接到互联网';

  @override
  String get globalNetworkNotAvailablePart2 => '如需要连接到互联网，可以参照以下方法：';

  @override
  String get globalNetworkNotAvailablePart3 => '如果您已接入Wi-Fi网络：';

  @override
  String get globalNetworkNotAvailableTip1 => '您的设备未启用移动网络或Wi-Fi网络';

  @override
  String get globalNetworkNotAvailableTip2 =>
      '• 在设备的“设置”“Wi-F网络”设置面板中选择一个可用的Wi-Fi热点接入。';

  @override
  String get globalNetworkNotAvailableTip3 =>
      '• 在设备的“设置”“网络”设置面板中启用蜂窝数据（启用后运营商可能会收取数据通信费用）。';

  @override
  String get globalNetworkNotAvailableTip4 =>
      '请检查您所连接的Wi-Fi热点是否已接入互联网，或该热点是否已允许您的设备访问互联网。';

  @override
  String get globalYear => '年';

  @override
  String get globalMonth => '月';

  @override
  String get globalDay => '日';

  @override
  String get globalHours => '小时';

  @override
  String get globalMinutes => '分钟';

  @override
  String get globalSave => '保存';

  @override
  String get globalSunday => '周日';

  @override
  String get globalMonday => '周一';

  @override
  String get globalTuesday => '周二';

  @override
  String get globalWednesday => '周三';

  @override
  String get globalThursday => '周四';

  @override
  String get globalFriday => '周五';

  @override
  String get globalSaturday => '周六';

  @override
  String get globalNotify => '通知';

  @override
  String get globalSubmit => '提交';

  @override
  String get globalEdit => '编辑';

  @override
  String get globalIKnow => '我知道了';

  @override
  String get globalAdd => '添加';

  @override
  String get globalDateFormat => 'yyyy年MM月dd日';

  @override
  String get globalMonthJan => '1月';

  @override
  String get globalMonthFeb => '2月';

  @override
  String get globalMonthMar => '3月';

  @override
  String get globalMonthApr => '4月';

  @override
  String get globalMonthMay => '5月';

  @override
  String get globalMonthJun => '6月';

  @override
  String get globalMonthJul => '7月';

  @override
  String get globalMonthAug => '8月';

  @override
  String get globalMonthSept => '9月';

  @override
  String get globalMonthOct => '10月';

  @override
  String get globalMonthNov => '11月';

  @override
  String get globalMonthDec => '12月';

  @override
  String get authImmediatelyRegister => '立即注册';

  @override
  String get authLoginBySSO => 'SSO登录';

  @override
  String get authPrivacyCheckedTips => '请先勾选同意《隐私协议》和《用户服务协议》';

  @override
  String get authLogin => '登录';

  @override
  String get authLoginToNetEase => '登录';

  @override
  String get authRegisterAndLogin => '注册/登录';

  @override
  String get authServiceAgreement => '用户协议';

  @override
  String get authPrivacy => '隐私政策';

  @override
  String get authPrivacyDialogTitle => '用户协议与隐私政策';

  @override
  String get authUserProtocolAndPrivacy => '用户服务协议和隐私协议';

  @override
  String get authNetEaseServiceAgreement => '网易会议用户协议';

  @override
  String get authNeteasePrivacy => '网易会议隐私政策';

  @override
  String authPrivacyDialogMessage(
      Object neteasePrivacy, Object neteaseUserProtocol) {
    return '网易会议是一款由网易公司向您提供的音视频会议软件产品。我们将通过\"$neteaseUserProtocol\"与\"$neteasePrivacy\"来协助您了解会议软件处理个人信息的方式与您的权利与义务。如您同意，点击同意接受我们的服务。';
  }

  @override
  String get authLoginOnOtherDevice => '同时登录设备数超出限制，已自动登出';

  @override
  String get authLoginTokenExpired => '登录状态已过期，请重新登录';

  @override
  String get authInputEmailHint => '请输入完整的邮箱地址';

  @override
  String get authAndLogin => '授权并登录';

  @override
  String get authNoAuth => '请先登录';

  @override
  String authHasReadAndAgreeToPolicy(
      Object neteasePrivacy, Object neteaseUserProtocol) {
    return '已阅读并同意网易会议$neteasePrivacy和$neteaseUserProtocol';
  }

  @override
  String get authHasReadAndAgreeMeeting => '已阅读并同意网易会议';

  @override
  String get authAnd => '和';

  @override
  String get authNextStep => '下一步';

  @override
  String get authMobileNotRegister => '该手机号未注册';

  @override
  String get authVerifyCodeErrorTip => '验证码不正确';

  @override
  String get authEnterCheckCode => '请输入验证码';

  @override
  String get authEnterMobile => '请输入手机号';

  @override
  String get authGetCheckCode => '获取验证码';

  @override
  String get authNewRegister => '新用户注册';

  @override
  String get authCheckMobile => '验证手机号';

  @override
  String get authLoginByPassword => '密码登录';

  @override
  String get authLoginByMobile => '手机验证码登录';

  @override
  String get authRegister => '注册';

  @override
  String get authEnterAccount => '请输入账号';

  @override
  String get authEnterPassword => '请输入密码';

  @override
  String get authEnterNick => '请输入昵称';

  @override
  String get authCompleteSelfInfo => '完善个人信息';

  @override
  String authResendCode(Object second) {
    return '$second后重新发送验证码';
  }

  @override
  String authCheckCodeHasSendToMobile(Object mobile) {
    return '验证码已经发送至$mobile，请在下方输入验证码';
  }

  @override
  String get authResend => '重新发送';

  @override
  String get authEnterCorpCode => '请输入企业代码';

  @override
  String get authSSOTip => '暂无所属企业';

  @override
  String get authSSONotSupport => '当前不支持SSO登录';

  @override
  String get authSSOLoginFail => 'SSO登录失败';

  @override
  String get authEnterCorpMail => '请输入企业邮箱';

  @override
  String get authForgetPassword => '忘记密码';

  @override
  String get authPhoneErrorTip => '手机号不合法';

  @override
  String get authPleaseLoginFirst => '请先登录网易会议';

  @override
  String get authResetInitialPasswordTitle => '设置你的新密码';

  @override
  String get authResetInitialPasswordDialogTitle => '设置新密码';

  @override
  String get authResetInitialPasswordDialogMessage =>
      '当前密码为初始密码，为了安全考虑，建议您前往设置新密码';

  @override
  String get authResetInitialPasswordDialogCancelLabel => '暂不设置';

  @override
  String get authResetInitialPasswordDialogOKLabel => '前往设置';

  @override
  String get authMobileNum => '手机号';

  @override
  String get authUnavailable => '暂无';

  @override
  String get authNoCorpCode => '没有企业代码？';

  @override
  String get authCreateAccountByPC => '可前往桌面端创建企业';

  @override
  String get authCreateNow => '立即创建';

  @override
  String get authLoginToCorpEdition => '前往正式版';

  @override
  String get authLoginToTrialEdition => '前往体验版';

  @override
  String get authCorpNotFound => '未匹配企业';

  @override
  String get authHasCorpCode => '已有企业代码？';

  @override
  String get authLoginByCorpCode => '企业代码登录';

  @override
  String get authLoginByCorpMail => '企业邮箱登录';

  @override
  String get authOldPasswordError => '当前密码错误，请重新输入';

  @override
  String get authEnterOldPassword => '请输入原密码';

  @override
  String get authSuggestChrome => '推荐使用Chrome浏览器';

  @override
  String get authLoggingIn => '正在登录会议';

  @override
  String get authHowToGetCorpCode => '如何获取企业代码？';

  @override
  String get authGetCorpCodeFromAdmin => '可与企业管理员咨询您的企业代码';

  @override
  String get authIKnowCorpCode => '我知道企业代码';

  @override
  String get authIDontKnowCorpCode => '我不知道企业代码';

  @override
  String get authTypeAccountPwd => '账号密码';

  @override
  String get authLoginByAccountPwd => '账号密码登录';

  @override
  String get authLoginByMobilePwd => '手机密码登录';

  @override
  String get authLoginByEmailPwd => '邮箱密码登录';

  @override
  String get authOtherLoginTypes => '其他登录方式';

  @override
  String get authEnterEmail => '请输入邮箱';

  @override
  String get authEmail => '邮箱';

  @override
  String get oldPassword => '旧密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '再次输入';

  @override
  String get meetingCreate => '即刻会议';

  @override
  String get meetingHold => '发起会议';

  @override
  String get meetingNetworkAbnormalityCheckAndRejoin => '网络异常，请检查网络连接后重新入会';

  @override
  String get meetingRecover => '检测到您上次异常退出，是否要恢复会议？';

  @override
  String get meetingJoin => '加入会议';

  @override
  String get meetingSchedule => '预约会议';

  @override
  String get meetingScheduleListEmpty => '暂无会议';

  @override
  String get meetingToday => '今天';

  @override
  String get meetingTomorrow => '明天';

  @override
  String get meetingNum => '会议号';

  @override
  String get meetingStatusInit => '待开始';

  @override
  String get meetingStatusStarted => '进行中';

  @override
  String get meetingStatusEnded => '已结束';

  @override
  String get meetingStatusRecycle => '已回收';

  @override
  String get meetingStatusCancel => '已取消';

  @override
  String get meetingOperationNotSupportedInMeeting => '会议中暂不支持该操作';

  @override
  String get meetingPersonalMeetingID => '个人会议号';

  @override
  String get meetingPersonalShortMeetingID => '个人会议短号';

  @override
  String get meetingUsePersonalMeetId => '使用个人会议号';

  @override
  String get meetingPassword => '会议密码';

  @override
  String get meetingEnterSixDigitPassword => '请输入6位数字密码';

  @override
  String get meetingJoinCameraOn => '入会时打开摄像头';

  @override
  String get meetingJoinMicrophoneOn => '入会时打开麦克风';

  @override
  String get meetingJoinCloudRecordOn => '入会时打开会议录制';

  @override
  String get meetingCreateAlreadyInTip => '这个会议还在进行中，要加入这个会议吗？';

  @override
  String get meetingCreateFail => '创建会议失败';

  @override
  String get meetingJoinFail => '加入会议失败';

  @override
  String get meetingEnterId => '请输入会议号';

  @override
  String meetingSubject(Object userName) {
    return '$userName预约的会议';
  }

  @override
  String get meetingScheduleNow => '立即预约';

  @override
  String get meetingEnterPassword => '请输入会议密码';

  @override
  String get meetingScheduleTimeIllegal => '预约时间不能早于当前时间';

  @override
  String get meetingScheduleSuccess => '会议预约成功';

  @override
  String get meetingDurationTooLong => '会议持续时间过长';

  @override
  String get meetingInfo => '会议信息';

  @override
  String get meetingSecurity => '安全';

  @override
  String get meetingWaitingRoomHint => '参会者加入会议时先进入等候室';

  @override
  String get meetingAttendeeAudioOff => '参会者加入会议时自动静音';

  @override
  String get meetingAttendeeAudioOffAllowOn => '自动静音且允许自主开麦';

  @override
  String get meetingAttendeeAudioOffNotAllowOn => '自动静音且不允许自主开麦';

  @override
  String get meetingEnterTopic => '请输入会议主题';

  @override
  String get meetingEndTime => '结束时间';

  @override
  String get meetingChooseDate => '选择日期';

  @override
  String get meetingLiveOn => '开启直播';

  @override
  String get meetingLiveUrl => '直播地址';

  @override
  String get meetingLiveLevelTip => '仅本企业员工可观看';

  @override
  String get meetingRecordOn => '参会者加入会议时打开会议录制';

  @override
  String get meetingInviteUrl => '邀请链接';

  @override
  String get meetingLiveLevel => '直播模式';

  @override
  String get meetingCancel => '取消会议';

  @override
  String get meetingCancelConfirm => '是否确定要取消会议？';

  @override
  String get meetingNotCancel => '暂不取消';

  @override
  String get meetingEdit => '编辑会议';

  @override
  String get meetingScheduleEditSuccess => '会议修改成功';

  @override
  String get meetingInfoDialogMeetingTitle => '会议主题';

  @override
  String get meetingDeepLinkTipAlreadyInMeeting => '您已在对应会议中';

  @override
  String get meetingDeepLinkTipAlreadyInDifferentMeeting =>
      '您已在其他会议中，请退出当前会议后重试';

  @override
  String get meetingShareScreenTips =>
      '您屏幕上包括通知在内的所有内容，均将被录制。请警惕仿冒客服、校园贷和公检法的诈骗，不要在“共享屏幕”时进行财务转账操作。';

  @override
  String get meetingForegroundContentText => '网易会议正在运行中';

  @override
  String get meetingId => '会议号:';

  @override
  String get meetingShortId => '会议号:';

  @override
  String get meetingStartTime => '开始时间';

  @override
  String get meetingCloseByHost => '主持人已结束会议';

  @override
  String get meetingEndOfLife => '会议时长已达上限，会议关闭';

  @override
  String get meetingSwitchOtherDevice => '因被主持人移出或切换至其他设备，您已退出会议';

  @override
  String get meetingSyncDataError => '房间信息同步失败';

  @override
  String get meetingEnd => '会议已结束';

  @override
  String get meetingMicrophone => '麦克风';

  @override
  String get meetingCamera => '摄像头';

  @override
  String get meetingDetail => '会议详情';

  @override
  String get meetingInfoDialogMeetingDateFormat => 'yyyy年MM月dd日';

  @override
  String get meetingHasBeenCanceled => '会议已被其他登录设备取消';

  @override
  String get meetingHasBeenCanceledByOwner => '会议被创建者取消';

  @override
  String get meetingRepeat => '周期';

  @override
  String get meetingFrequency => '重复频率';

  @override
  String get meetingNoRepeat => '不重复';

  @override
  String get meetingRepeatEveryday => '每天';

  @override
  String get meetingRepeatEveryWeekday => '每个工作日';

  @override
  String get meetingRepeatEveryWeek => '每周';

  @override
  String get meetingRepeatEveryTwoWeek => '每两周';

  @override
  String get meetingRepeatEveryMonth => '每月';

  @override
  String get meetingRepeatCustom => '自定义';

  @override
  String get meetingRepeatEndAt => '结束于';

  @override
  String get meetingRepeatEndAtOneday => '结束于某天';

  @override
  String get meetingRepeatTimes => '限定会议次数';

  @override
  String get meetingRepeatStop => '结束重复';

  @override
  String meetingDayInMonth(Object day) {
    return '$day日';
  }

  @override
  String get meetingRepeatSelectDate => '选择日期';

  @override
  String meetingRepeatDayInWeek(Object day, Object week) {
    return '每$week周的$day重复';
  }

  @override
  String meetingRepeatDay(Object day) {
    return '每$day天重复';
  }

  @override
  String meetingRepeatDayInMonth(Object day, Object month) {
    return '每$month个月的$day重复';
  }

  @override
  String meetingRepeatDayInWeekInMonth(
      Object month, Object week, Object weekday) {
    return '每$month个月的第$week个$weekday重复';
  }

  @override
  String get meetingRepeatDate => '日期';

  @override
  String get meetingRepeatWeekday => '星期';

  @override
  String meetingRepeatOrderWeekday(Object week, Object weekday) {
    return '第$week个$weekday';
  }

  @override
  String get meetingRepeatEditing => '你正在编辑周期性会议';

  @override
  String get meetingRepeatEditCurrent => '编辑本次会议';

  @override
  String get meetingRepeatEditAll => '编辑所有会议';

  @override
  String get meetingRepeatEditTips => '修改以下信息，将影响该系列周期性会议';

  @override
  String get meetingLeaveEditTips => '确认退出会议编辑吗？';

  @override
  String get meetingRepeatCancelAll => '同时取消该系列周期性会议';

  @override
  String get meetingCancelCancel => '暂不取消';

  @override
  String get meetingCancelConfirm2 => '取消会议';

  @override
  String get meetingLeaveEditTips2 => '退出后，将无法保存当前会议的更改';

  @override
  String get meetingEditContinue => '继续编辑';

  @override
  String get meetingEditLeave => '退出';

  @override
  String get meetingRepeatUnitEvery => '每';

  @override
  String get meetingRepeatUnitDay => '天';

  @override
  String get meetingRepeatUnitWeek => '周';

  @override
  String get meetingRepeatUnitMonth => '个月';

  @override
  String meetingRepeatLimitTimes(Object times) {
    return '限定会议次数$times次';
  }

  @override
  String get meetingJoinBeforeHost => '允许参会者在主持人进会前加入会议';

  @override
  String get meetingRepeatMeetings => '周期性会议';

  @override
  String get meetingRepeatLabel => '重复';

  @override
  String get meetingRepeatEnd => '结束';

  @override
  String get meetingRepeatOneDay => '某天';

  @override
  String get meetingRepeatFrequency => '频率';

  @override
  String get meetingRepeatAt => '位于';

  @override
  String meetingRepeatUncheckTips(Object date) {
    return '当前日程为$date，无法取消选择';
  }

  @override
  String get meetingRepeatCancelEdit => '取消编辑';

  @override
  String get meetingGuestJoin => '访客入会';

  @override
  String get meetingGuestJoinSecurityNotice => '已开启访客入会，请注意会议信息安全';

  @override
  String get meetingGuestJoinEnableTip => '开启后允许外部人员参会';

  @override
  String get meetingAttendees => '参会者';

  @override
  String meetingAttendeeCount(Object count) {
    return '$count人';
  }

  @override
  String get meetingAddAttendee => '添加参会者';

  @override
  String get meetingSearchAndAddAttendee => '搜索并添加参会人';

  @override
  String get meetingOpen => '展开';

  @override
  String get meetingClose => '收起';

  @override
  String get meetingClearRecord => '清空记录';

  @override
  String get meetingPickTimezone => '选择时区';

  @override
  String get meetingTimezone => '时区';

  @override
  String get meetingName => '会议名称';

  @override
  String get meetingTime => '时间';

  @override
  String get historyMeeting => '历史会议';

  @override
  String get historyAllMeeting => '全部会议';

  @override
  String get historyCollectMeeting => '收藏会议';

  @override
  String get historyMeetingListEmpty => '暂无历史会议';

  @override
  String get historyCollectMeetingListEmpty => '暂无收藏会议';

  @override
  String get historyChat => '聊天记录';

  @override
  String get historyMeetingOwner => '创建人';

  @override
  String get historyMeetingCloudRecord => '云录制';

  @override
  String get historyMeetingCloudRecordingFileBeingGenerated => '云录制文件生成中…';

  @override
  String get settings => '设置';

  @override
  String get settingDefaultCompanyName => '无所属企业';

  @override
  String get settingInternalDedicated => '内部专用';

  @override
  String get settingMeeting => '会议设置';

  @override
  String get settingFeedback => '意见反馈';

  @override
  String get settingBeauty => '美颜';

  @override
  String get settingVirtualBackground => '虚拟背景';

  @override
  String get settingAbout => '关于';

  @override
  String get settingSetMeetingNick => '设置入会昵称';

  @override
  String get settingSetMeetingTips => '请输入中文、英文或数字';

  @override
  String get settingValidatorNickTip => '最多20个字符，支持汉字、字母、数字';

  @override
  String get settingModifySuccess => '修改成功';

  @override
  String get settingModifyFailed => '修改失败';

  @override
  String get settingCheckUpdate => '检查更新';

  @override
  String get settingFindNewVersion => '发现新版本';

  @override
  String get settingAlreadyLatestVersion => '当前已经是最新版';

  @override
  String get settingVersion => 'Version:';

  @override
  String get settingAccountAndSafety => '账号与安全';

  @override
  String get settingModifyPassword => '修改密码';

  @override
  String get settingEnterNewPasswordTips => '请输入新密码';

  @override
  String get settingEnterPasswordConfirm => '请再次输入新密码';

  @override
  String get settingValidatorPwdTip => '长度6-18个字符，需要包含大小写字母与数字';

  @override
  String get settingPasswordDifferent => '两次输入的新密码不一致，请重新输入';

  @override
  String get settingPasswordSameToOld => '新密码与现有密码重复，请重新输入';

  @override
  String get settingPasswordFormatError => '密码格式错误，请重新输入';

  @override
  String get settingCompany => '企业';

  @override
  String get settingSwitchCompanyFail => '切换企业失败，请检查当前网络';

  @override
  String get settingShowShareUserVideo => '共享时开启共享人摄像头';

  @override
  String get settingOpenCameraMeeting => '默认打开摄像头';

  @override
  String get settingOpenMicroMeeting => '默认打开麦克风';

  @override
  String get settingEnableAudioDeviceSwitch => '允许音频设备切换';

  @override
  String get settingRename => '修改昵称';

  @override
  String get settingPackageVersion => '套餐版本';

  @override
  String get settingNick => '昵称';

  @override
  String get settingDeleteAccount => '注销账号';

  @override
  String get settingEmail => '邮箱';

  @override
  String get settingLogout => '退出登录';

  @override
  String get settingLogoutConfirm => '确定要退出登录？';

  @override
  String get settingMobile => '手机';

  @override
  String get settingAvatar => '头像';

  @override
  String get settingAvatarUpdateSuccess => '修改头像成功';

  @override
  String get settingAvatarUpdateFail => '修改头像失败';

  @override
  String get settingAvatarTitle => '头像设置';

  @override
  String get settingTakePicture => '拍照';

  @override
  String get settingChoosePicture => '从手机相册选择';

  @override
  String get settingPersonalCenter => '个人中心';

  @override
  String get settingVersionUpgrade => '版本更新';

  @override
  String get settingUpgradeNow => '立即更新';

  @override
  String get settingUpgradeCancel => '暂不更新';

  @override
  String get settingDownloadFailTryAgain => '下载失败，请重试';

  @override
  String get settingInstallFailTryAgain => '安装失败，请重试';

  @override
  String get settingModifyAndReLogin => '修改后，您需要重新登录';

  @override
  String get settingServiceBundleTitle => '您可召开：';

  @override
  String settingServiceBundleExpireTime(Object expireTime) {
    return '服务到期：$expireTime';
  }

  @override
  String settingServiceBundleDetailLimitedMinutes(
      Object maxCount, Object maxMinutes) {
    return '$maxCount人、限时$maxMinutes分钟会议';
  }

  @override
  String settingServiceBundleDetailUnlimitedMinutes(Object maxCount) {
    return '$maxCount人、单场不限时会议';
  }

  @override
  String get settingServiceBundleExpirationDate => '服务到期：';

  @override
  String get settingServiceBundleExpirationDateTip => '服务已到期，如需延长时问，请联系企业管理员。';

  @override
  String get settingUpdateFailed => '更新失败';

  @override
  String get settingTryAgainLater => '下次再试';

  @override
  String get settingRetryNow => '立即重试';

  @override
  String get settingUpdating => '更新中';

  @override
  String get settingCancelUpdate => '取消更新';

  @override
  String get settingExitApp => '退出应用';

  @override
  String get settingNotUpdate => '暂不更新';

  @override
  String get settingUPdateNow => '立即更新';

  @override
  String get settingComfirmExitApp => '确定退出应用';

  @override
  String get settingSwitchLanguage => '语言切换';

  @override
  String get settingSetLanguage => '设置语言';

  @override
  String get settingLanguageTip => '简体中文';

  @override
  String get feedbackInRoom => '问题反馈';

  @override
  String get feedbackProblemType => '问题类型';

  @override
  String get feedbackSuccess => '反馈提交成功';

  @override
  String get feedbackAudioLatency => '对方说话声音延迟很大';

  @override
  String get feedbackAudioFreeze => '对方说话声音很卡';

  @override
  String get feedbackCannotHearOthers => '听不到对方声音';

  @override
  String get feedbackCannotHearMe => '对方听不到我的声音';

  @override
  String get feedbackTitleExtras => '补充信息';

  @override
  String get feedbackTitleDate => '问题发生时间';

  @override
  String get feedbackContentEmpty => '无';

  @override
  String get feedbackTitleSelectPicture => '本地图片';

  @override
  String get feedbackAudioMechanicalNoise => '播放机械音';

  @override
  String get feedbackAudioNoise => '杂音';

  @override
  String get feedbackAudioEcho => '有回声';

  @override
  String get feedbackAudioVolumeSmall => '音量小';

  @override
  String get feedbackVideoFreeze => '视频长时间卡顿';

  @override
  String get feedbackVideoIntermittent => '视频断断续续';

  @override
  String get feedbackVideoTearing => '画面撕裂';

  @override
  String get feedbackVideoTooBrightOrDark => '画面过亮/过暗';

  @override
  String get feedbackVideoBlurry => '画面模糊';

  @override
  String get feedbackVideoNoise => '画面明显噪点';

  @override
  String get feedbackAudioVideoNotSync => '音画不同步';

  @override
  String get feedbackUnexpectedExit => '意外退出';

  @override
  String get feedbackOthers => '存在其他问题';

  @override
  String get feedbackTitleAudio => '音频问题';

  @override
  String get feedbackTitleVideo => '视频问题';

  @override
  String get feedbackTitleOthers => '其他';

  @override
  String get feedbackTitleDescription => '问题描述';

  @override
  String get feedbackOtherTip => '请描述您的问题，（当您选中\"存在其他问题\"时），需填写具体描述才可进行提交';

  @override
  String get evaluationTitle => '评分';

  @override
  String get evaluationContent => '您有多大的可能向同事或合作伙伴推荐网易会议？';

  @override
  String get evaluationCoreZero => '0-肯定不会';

  @override
  String get evaluationCoreTen => '10-非常乐意';

  @override
  String get evaluationHitTextOne => '0-6：让您不满意或者失望的点有哪些？（选填）';

  @override
  String get evaluationHitTextTwo => '7-8：您觉得哪些方面能做的更好？（选填）';

  @override
  String get evaluationHitTextThree => '9-10：欢迎分享您体验最好的功能或感受（选填）';

  @override
  String get evaluationToast => '请评分后提交喔~';

  @override
  String get evaluationThankFeedback => '感谢您的反馈';

  @override
  String get evaluationGoHome => '返回首页';
}
