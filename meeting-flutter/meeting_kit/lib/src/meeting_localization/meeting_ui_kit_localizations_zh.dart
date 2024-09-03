// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'meeting_ui_kit_localizations.dart';

/// The translations for Chinese (`zh`).
class NEMeetingUIKitLocalizationsZh extends NEMeetingUIKitLocalizations {
  NEMeetingUIKitLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get globalAppName => '网易会议';

  @override
  String get globalDelete => '删除';

  @override
  String get globalNothing => '无';

  @override
  String get globalCancel => '取消';

  @override
  String get globalAdd => '添加';

  @override
  String get globalClose => '关闭';

  @override
  String get globalOpen => '打开';

  @override
  String get globalFail => '失败';

  @override
  String get globalYes => '是';

  @override
  String get globalNo => '否';

  @override
  String get globalSave => '保存';

  @override
  String get globalDone => '完成';

  @override
  String get globalNotify => '通知';

  @override
  String get globalSure => '确定';

  @override
  String get globalIKnow => '我知道了';

  @override
  String get globalCopy => '复制';

  @override
  String get globalCopySuccess => '复制成功';

  @override
  String get globalEdit => '编辑';

  @override
  String get globalGotIt => '知道了';

  @override
  String globalNotWork(Object permissionName) {
    return '无法使用$permissionName';
  }

  @override
  String globalNeedPermissionTips(Object permissionName, Object title) {
    return '该功能需要$permissionName,请允许$title访问您的$permissionName权限';
  }

  @override
  String get globalToSetUp => '前往设置';

  @override
  String get globalNoPermission => '权限未授权';

  @override
  String get globalDays => '天';

  @override
  String get globalHours => '小时';

  @override
  String get globalMinutes => '分钟';

  @override
  String get globalViewMessage => '查看消息';

  @override
  String get globalNoLongerRemind => '不再提醒';

  @override
  String get globalOperationFail => '操作失败';

  @override
  String get globalOperationNotSupportedInMeeting => '会议中暂不支持该操作';

  @override
  String get globalClear => '清空';

  @override
  String get globalSearch => '搜索';

  @override
  String get globalReject => '拒绝';

  @override
  String get globalCancelled => '已取消';

  @override
  String get globalClearAll => '清空全部';

  @override
  String get globalStart => '开启';

  @override
  String get globalTips => '提示';

  @override
  String get globalNetworkUnavailableCheck => '网络连接失败，请检查你的网络连接！';

  @override
  String get globalSubmit => '提交';

  @override
  String get globalGotoSettings => '前往设置';

  @override
  String get globalPhotosPermissionRationale => '音视频会议需要申请相册权限，用于上传图片或修改头像';

  @override
  String get globalPhotosPermission => '无法使用相册';

  @override
  String get globalSend => '发送';

  @override
  String get globalPause => '暂停';

  @override
  String get meetingBeauty => '美颜';

  @override
  String get meetingBeautyLevel => '美颜等级';

  @override
  String get meetingJoinTips => '正在进入会议...';

  @override
  String get meetingQuit => '结束会议';

  @override
  String get meetingDefalutTitle => '视频会议';

  @override
  String get meetingJoinFail => '加入会议失败';

  @override
  String get meetingHostKickedYou => '因被主持人移出或切换至其他设备，您已退出会议';

  @override
  String get meetingMicphoneNotWorksDialogTitle => '无法使用麦克风';

  @override
  String get meetingMicphoneNotWorksDialogMessage => '您已静音，请点击\"解除静音\"开启麦克风';

  @override
  String get meetingFinish => '结束';

  @override
  String get meetingLeave => '离开';

  @override
  String get meetingLeaveFull => '离开会议';

  @override
  String get meetingSpeakingPrefix => '正在讲话:';

  @override
  String get meetingLockMeetingByHost => '会议已锁定，新参会者将无法加入会议';

  @override
  String get meetingLockMeetingByHostFail => '会议锁定失败';

  @override
  String get meetingUnLockMeetingByHost => '会议已解锁，新参会者将可以加入会议';

  @override
  String get meetingUnLockMeetingByHostFail => '会议解锁失败';

  @override
  String get meetingLock => '锁定会议';

  @override
  String get meetingMore => '更多';

  @override
  String get meetingPassword => '会议密码';

  @override
  String get meetingEnterPassword => '请输入会议密码';

  @override
  String get meetingWrongPassword => '密码错误';

  @override
  String get meetingNum => '会议号';

  @override
  String get meetingShortNum => '会议短号';

  @override
  String get meetingInfoDesc => '会议正在加密保护中';

  @override
  String get meetingAlreadyHandsUpTips => '您已举手，请等待主持人处理';

  @override
  String get meetingHandsUpApply => '举手申请';

  @override
  String get meetingCancelHandsUp => '取消举手';

  @override
  String get meetingCancelHandsUpConfirm => '是否确定取消举手？';

  @override
  String get meetingHandsUpDown => '手放下';

  @override
  String get meetingInHandsUp => '举手中';

  @override
  String get meetingHandsUpFail => '举手失败';

  @override
  String get meetingHandsUpSuccess => '举手成功，等待主持人处理';

  @override
  String get meetingCancelHandsUpFail => '取消举手失败';

  @override
  String get meetingHostRejectAudioHandsUp => '主持人已将您的手放下';

  @override
  String get meetingSip => 'SIP';

  @override
  String get meetingInviteUrl => '入会链接';

  @override
  String get meetingInvitePageTitle => '添加与会者';

  @override
  String get meetingSipNumber => '内线话机/终端入会';

  @override
  String get meetingMobileDialInTitle => '手机拨号入会';

  @override
  String meetingMobileDialInMsg(Object phoneNumber) {
    return '拨打 $phoneNumber';
  }

  @override
  String meetingInputSipNumber(Object sipNumber) {
    return '输入 $sipNumber 加入会议';
  }

  @override
  String get meetingSipHost => 'SIP地址';

  @override
  String get meetingInvite => '邀请';

  @override
  String get meetingInviteListTitle => '邀请列表';

  @override
  String get meetingInvitationSendSuccess => '已发起邀请';

  @override
  String get meetingInvitationSendFail => '邀请失败';

  @override
  String get meetingRemovedByHost => '您已被主持人移除会议';

  @override
  String get meetingCloseByHost => '会议已结束';

  @override
  String get meetingWasInterrupted => '会议已中断';

  @override
  String get meetingSyncDataError => '房间信息同步失败';

  @override
  String get meetingLeaveMeetingBySelf => '离开会议';

  @override
  String get meetingClosed => '会议被关闭';

  @override
  String get meetingConnectFail => '连接失败';

  @override
  String get meetingJoinTimeout => '加入会议超时，请重试';

  @override
  String get meetingEndOfLife => '会议时长已达上限，会议关闭';

  @override
  String get meetingEndTip => '距离会议关闭仅剩';

  @override
  String get meetingReuseIMNotSupportAnonymousJoinMeeting => 'IM复用不支持匿名入会';

  @override
  String get meetingInviteDialogTitle => '会议邀请';

  @override
  String get meetingInviteContentCopySuccess => '已复制会议邀请内容';

  @override
  String get meetingInviteTitle => '邀请您参加会议';

  @override
  String get meetingSubject => '会议主题';

  @override
  String get meetingTime => '会议时间';

  @override
  String get meetingInvitationUrl => '入会链接';

  @override
  String get meetingCopyInvite => '复制邀请';

  @override
  String get meetingInternalSpecial => '内部专用';

  @override
  String get loginOnOtherDevice => '已切换至其他设备';

  @override
  String get authInfoExpired => '登录状态已过期，请重新登录';

  @override
  String get meetingCamera => '相机';

  @override
  String get meetingMicrophone => '麦克风';

  @override
  String get meetingBluetooth => '蓝牙';

  @override
  String get meetingPhoneState => '电话';

  @override
  String meetingNeedRationaleAudioPermission(Object permission) {
    return '音视频会议需要申请$permission权限，用于会议中的音频交流';
  }

  @override
  String meetingNeedRationaleVideoPermission(Object permission) {
    return '音视频会议需要申请$permission权限，用于会议中的视频交流';
  }

  @override
  String get meetingNeedRationalePhotoPermission =>
      '音视频会议需要申请照片权限，用于会议中的虚拟背景（添加、更换背景图片）功能';

  @override
  String get meetingDisconnectAudio => '断开音频';

  @override
  String get meetingReconnectAudio => '连接音频';

  @override
  String get meetingDisconnectAudioTips => '如需关闭会议声音，您可以点击更多中的“断开音频”';

  @override
  String get meetingNotificationContentTitle => '视频会议';

  @override
  String get meetingNotificationContentText => '视频会议正在进行中';

  @override
  String get meetingNotificationContentTicker => '视频会议';

  @override
  String get meetingNotificationChannelId => 'ne_meeting_channel';

  @override
  String get meetingNotificationChannelName => '视频会议通知';

  @override
  String get meetingNotificationChannelDesc => '视频会议通知';

  @override
  String meetingUserJoin(Object userName) {
    return '$userName加入会议';
  }

  @override
  String meetingUserLeave(Object userName) {
    return '$userName离开会议';
  }

  @override
  String get meetingStartAudioShare => '开启音频共享';

  @override
  String get meetingStopAudioShare => '关闭音频共享';

  @override
  String get meetingSwitchFcusView => '切换至演讲者视图';

  @override
  String get meetingSwitchGalleryView => '切换至画廊视图';

  @override
  String get meetingNoSupportSwitch => '该设备不支持切换模式';

  @override
  String get meetingFuncNotAvailableWhenInCallState => '系统通话中，无法使用该功能';

  @override
  String get meetingRejoining => '重新入会';

  @override
  String get meetingSecurity => '安全';

  @override
  String get meetingManagement => '会议管理';

  @override
  String get meetingWatermark => '会议水印';

  @override
  String get meetingBeKickedOutByHost => '主持人已将您从会议中移除';

  @override
  String get meetingBeKickedOut => '被移除会议';

  @override
  String get meetingClickOkToClose => '点击确定，该页面自动关闭';

  @override
  String get meetingLeaveConfirm => '确定要离开会议吗?';

  @override
  String get meetingWatermarkEnabled => '水印已开启';

  @override
  String get meetingWatermarkDisabled => '水印已关闭';

  @override
  String get meetingInfo => '会议信息';

  @override
  String get meetingNickname => '会议昵称';

  @override
  String get meetingHostChangeYourMeetingName => '主持人修改了你的会中名称';

  @override
  String get meetingIsInCall => '正在接听系统电话';

  @override
  String get meetingPinView => '锁定视频';

  @override
  String meetingPinViewTip(Object corner) {
    return '画面已锁定，点击$corner取消锁定';
  }

  @override
  String get meetingTopLeftCorner => '左上角';

  @override
  String get meetingBottomRightCorner => '右下角';

  @override
  String get meetingUnpinView => '取消锁定视频';

  @override
  String get meetingUnpinViewTip => '画面已解锁';

  @override
  String get meetingUnpin => '取消锁定';

  @override
  String get meetingPinFailedByFocus => '主持人已设置焦点视频，不支持该操作';

  @override
  String get meetingBlacklist => '会议黑名单';

  @override
  String get meetingBlacklistDetail => '开启后，被标记“不允许再次加入”的用户将无法加入该会议';

  @override
  String get unableMeetingBlacklistTitle => '确认关闭会议黑名单？';

  @override
  String get unableMeetingBlacklistTip => '关闭后将清空黑名单，被标记“不允许再次加入”的用户可重新加入会议';

  @override
  String get meetingNotAllowedToRejoin => '不允许再次加入该会议';

  @override
  String get meetingAllowMembersTo => '允许参会人员';

  @override
  String get meetingChat => '会中聊天';

  @override
  String get meetingChatEnabled => '会中聊天已开启';

  @override
  String get meetingChatDisabled => '会中聊天已关闭';

  @override
  String get meetingReclaimHost => '收回主持人';

  @override
  String get meetingReclaimHostCancel => '暂不收回';

  @override
  String meetingReclaimHostTip(Object user) {
    return '$user目前是主持人，收回主持人权限可能会中断屏幕共享等';
  }

  @override
  String meetingUserIsNowTheHost(Object user) {
    return '$user已经成为主持人';
  }

  @override
  String get meetingGuestJoin => '访客入会';

  @override
  String get meetingGuestJoinSecurityNotice => '已开启访客入会，请注意会议信息安全';

  @override
  String get meetingGuestJoinEnableTip => '开启后允许外部人员参会';

  @override
  String get meetingGuestJoinEnabled => '访客入会已开启';

  @override
  String get meetingGuestJoinDisabled => '访客入会已关闭';

  @override
  String get meetingGuestJoinConfirm => '确认开启访客入会？';

  @override
  String get meetingGuestJoinConfirmTip => '开启后允许外部人员参会';

  @override
  String get meetingSearchNotFound => '暂无搜索结果';

  @override
  String get meetingGuestJoinSupported => '该会议支持外部访客入会';

  @override
  String get meetingGuest => '外部访客';

  @override
  String get meetingGuestJoinNamePlaceholder => '请输入入会昵称';

  @override
  String meetingAppInvite(Object userName) {
    return '$userName 邀请你加入';
  }

  @override
  String get meetingAudioJoinAction => '语音入会';

  @override
  String get meetingVideoJoinAction => '视频入会';

  @override
  String get meetingMaxMembers => '最多参会人数';

  @override
  String get speakerVolumeMuteTips =>
      '当前选中的扬声器设备暂无声音效果，请检查系统扬声器是否已解除静音并调至合适音量。';

  @override
  String get meetingAnnotationPermissionEnabled => '互动批注';

  @override
  String get meetingMemberMaxTip => '会议人数达到上限';

  @override
  String get meetingIsUnderGoing => '当前会议还未结束，不能进行此类操作';

  @override
  String get unauthorized => '登录状态已过期，请重新登录';

  @override
  String get meetingIdShouldNotBeEmpty => '会议号不能为空';

  @override
  String get meetingPasswordNotValid => '会议密码不合法';

  @override
  String get displayNameShouldNotBeEmpty => '昵称不能为空';

  @override
  String get meetingLogPathParamsError => '参数错误，日志路径不合法或无创建权限';

  @override
  String get meetingLocked => '会议已锁定';

  @override
  String get meetingNotExist => '会议不存在';

  @override
  String get meetingSaySomeThing => '说点什么…';

  @override
  String get meetingKeepSilence => '当前禁言中';

  @override
  String get reuseIMNotSupportAnonymousLogin => 'IM复用不支持匿名登录';

  @override
  String get unmuteAudioBySelf => '自行解除静音';

  @override
  String get updateNicknameBySelf => '自己改名';

  @override
  String get updateNicknameNoPermission => '主持人不允许成员改名';

  @override
  String get shareNoPermission => '共享失败，仅主持人可共享';

  @override
  String get localRecordPermission => '本地录制权限';

  @override
  String get localRecordOnlyHost => '仅主持人可录制';

  @override
  String get localRecordAll => '所有人可录制';

  @override
  String get sharingStopByHost => '主持人已终止了你的共享';

  @override
  String get suspendParticipantActivities => '暂停参会者活动';

  @override
  String get suspendParticipantActivitiesTips => '所有人都将被静音，视频、屏幕共享将停止，会议将被锁定。';

  @override
  String get alreadySuspendParticipantActivitiesByHost => '主持人已暂停参会者活动';

  @override
  String get alreadySuspendParticipantActivities => '已暂停参会者活动';

  @override
  String get suspendAllParticipantActivities => '暂停所有参会者活动?';

  @override
  String get hideAvatarByHost => '主持人已隐藏所有头像';

  @override
  String get hideAvatar => '隐藏头像';

  @override
  String get screenShare => '共享屏幕';

  @override
  String get screenShareStop => '结束共享';

  @override
  String get screenShareOverLimit => '已有人在共享，您无法共享';

  @override
  String get screenShareNoPermission => '没有屏幕共享权限';

  @override
  String get screenShareTips => '将开始截取您的屏幕上显示的所有内容。';

  @override
  String get screenShareStopFail => '停止共享屏幕失败';

  @override
  String get screenShareStartFail => '发起共享屏幕失败';

  @override
  String screenShareLocalTips(Object userName) {
    return '$userName正在共享屏幕';
  }

  @override
  String screenShareUser(Object userName) {
    return '$userName的共享屏幕';
  }

  @override
  String get screenShareMyself => '你正在共享屏幕';

  @override
  String get screenShareInteractionTip => '双指分开放大画面';

  @override
  String get whiteBoardShareStopFail => '停止共享白板失败';

  @override
  String get whiteBoardShareStartFail => '发起白板共享失败';

  @override
  String get whiteboardShare => '共享白板';

  @override
  String get whiteBoardClose => '退出白板';

  @override
  String get whiteBoardInteractionTip => '您被授予白板互动权限';

  @override
  String get whiteBoardUndoInteractionTip => '您被取消白板互动权限';

  @override
  String get whiteBoardNoAuthority => '暂未开通白板权限，请联系销售开通';

  @override
  String get whiteBoardPackUp => '收起';

  @override
  String get meetingHasScreenShareShare => '屏幕或电脑音频共享时暂不支持白板共享';

  @override
  String get meetingHasWhiteBoardShare => '共享白板时暂不支持屏幕共享';

  @override
  String get meetingStopSharing => '停止共享';

  @override
  String get meetingStopSharingConfirm => '确定停止正在进行的共享?';

  @override
  String get screenShareWarning =>
      '近期有不法分子冒充客服、校园贷和公检法诈骗，请您提高警惕。检测到您的会议有安全风险，已禁用了共享功能。';

  @override
  String get backSharingView => '返回共享内容';

  @override
  String screenSharingViewUserLabel(Object userName) {
    return '$userName的屏幕共享';
  }

  @override
  String whiteBoardSharingViewUserLabel(Object userName) {
    return '$userName的白板共享';
  }

  @override
  String get virtualBackground => '虚拟背景';

  @override
  String get virtualBackgroundImageNotExist => '自定义背景图片不存在';

  @override
  String get virtualBackgroundImageFormatNotSupported => '自定义背景图片的图片格式无效';

  @override
  String get virtualBackgroundImageDeviceNotSupported => '该设备不支持使用虚拟背景';

  @override
  String get virtualBackgroundImageLarge => '自定义背景图片超过5M大小限制';

  @override
  String get virtualBackgroundImageMax => '自定义背景图片超过最大数量';

  @override
  String get virtualBackgroundSelectTip => '所选背景立即生效';

  @override
  String get virtualDefaultBackground => '默认背景';

  @override
  String get virtualCustom => '自定义';

  @override
  String get live => '直播';

  @override
  String get liveMeeting => '会议直播';

  @override
  String get liveMeetingTitle => '会议直播主题';

  @override
  String get liveMeetingUrl => '直播地址';

  @override
  String get liveEnterLivePassword => '请输入直播密码';

  @override
  String get liveEnterLiveSixDigitPassword => '请输入6位数字密码';

  @override
  String get liveInteraction => '直播互动';

  @override
  String get liveInteractionTips => '开启后，会议室和直播间消息互相可见';

  @override
  String get liveLevel => '仅本企业员工可观看';

  @override
  String get liveLevelTip => '开启后，非本企业员工无法观看直播';

  @override
  String get liveViewSetting => '直播视图设置';

  @override
  String get liveViewSettingChange => '主播发生变更';

  @override
  String get liveViewPreviewTips => '当前直播视图预览';

  @override
  String get liveViewPreviewDesc => '请先进行\n直播视图设置';

  @override
  String get liveStart => '开始直播';

  @override
  String get liveUpdate => '更新直播设置';

  @override
  String get liveStop => '停止直播';

  @override
  String get liveGalleryView => '画廊视图';

  @override
  String get liveFocusView => '焦点视图';

  @override
  String get liveScreenShareView => '屏幕共享视图';

  @override
  String get liveChooseView => '选择视图样式';

  @override
  String get liveChooseCountTips => '选择参会者作为主播，最多选择4人';

  @override
  String get liveStartFail => '直播开始失败,请稍后重试';

  @override
  String get liveStartSuccess => '直播开始成功';

  @override
  String livePickerCount(Object length) {
    return '已选择$length人';
  }

  @override
  String get liveUpdateFail => '直播更新失败,请稍后重试';

  @override
  String get liveUpdateSuccess => '直播更新成功';

  @override
  String get liveStopFail => '直播停止失败,请稍后重试';

  @override
  String get liveStopSuccess => '直播停止成功';

  @override
  String get livePassword => '直播密码';

  @override
  String get liveDisableAuthLevel => '直播过程中，不能修改观看直播权限';

  @override
  String get liveStreaming => '直播中';

  @override
  String get participants => '参会者';

  @override
  String get participantsManager => '管理参会者';

  @override
  String get participantAssignedHost => '您已经成为主持人';

  @override
  String get participantAssignedCoHost => '您已被设为联席主持人';

  @override
  String get participantUnassignedCoHost => '您已被取消设为联席主持人';

  @override
  String get participantAssignedActiveSpeaker => '您已被设置为焦点视频';

  @override
  String get participantUnassignedActiveSpeaker => '您已被取消焦点视频';

  @override
  String get participantMuteAudioAll => '全体静音';

  @override
  String get participantMuteAudioAllDialogTips => '所有以及新加入成员将被静音';

  @override
  String get participantMuteVideoAllDialogTips => '所有以及新加入成员将被关闭摄像头';

  @override
  String get participantUnmuteAll => '解除全体静音';

  @override
  String get participantMute => '静音';

  @override
  String get participantUnmute => '解除静音';

  @override
  String get participantTurnOffVideos => '全体关闭视频';

  @override
  String get participantTurnOnVideos => '全体打开视频';

  @override
  String get participantStopVideo => '停止视频';

  @override
  String get participantStartVideo => '开启视频';

  @override
  String get participantTurnOffAudioAndVideo => '关闭音视频';

  @override
  String get participantTurnOnAudioAndVideo => '打开音视频';

  @override
  String get participantHostStoppedShare => '主持人已终止了您的共享';

  @override
  String get participantHostStopWhiteboard => '主持人已终止您的白板共享';

  @override
  String get participantAssignActiveSpeaker => '设为焦点视频';

  @override
  String get participantUnassignActiveSpeaker => '取消焦点视频';

  @override
  String get participantTransferHost => '移交主持人';

  @override
  String participantTransferHostConfirm(Object userName) {
    return '确认将主持人移交给$userName?';
  }

  @override
  String get participantRemove => '移除';

  @override
  String get participantRename => '改名';

  @override
  String get participantRenameDialogTitle => '修改参会姓名';

  @override
  String get participantAssignCoHost => '设置联席主持人';

  @override
  String get participantUnassignCoHost => '取消联席主持人';

  @override
  String get participantRenameTips => '请输入新的昵称';

  @override
  String get participantRenameSuccess => '改名成功';

  @override
  String get participantRenameFail => '改名失败';

  @override
  String get participantRemoveConfirm => '确认移除';

  @override
  String get participantCannotRemoveSelf => '不能移除自己';

  @override
  String get participantMuteAudioFail => '静音失败';

  @override
  String get participantUnMuteAudioFail => '解除静音失败';

  @override
  String get participantMuteVideoFail => '停止视频失败';

  @override
  String get participantUnMuteVideoFail => '开启视频失败';

  @override
  String get participantFailedToAssignActiveSpeaker => '设为焦点视频失败';

  @override
  String get participantFailedToUnassignActiveSpeaker => '取消焦点视频失败';

  @override
  String get participantFailedToLowerHand => '放下成员举手失败';

  @override
  String get participantFailedToTransferHost => '移交主持人失败';

  @override
  String get participantFailedToRemove => '移除失败';

  @override
  String get participantOpenCamera => '打开摄像头';

  @override
  String get participantOpenMicrophone => '打开麦克风';

  @override
  String get participantHostOpenCameraTips => '主持人已重新打开您的摄像头，确认打开？';

  @override
  String get participantHostOpenMicroTips => '主持人已重新打开您的麦克风，确认打开？';

  @override
  String get participantMuteAllAudioTip => '允许参会者自行解除静音';

  @override
  String get participantMuteAllVideoTip => '允许参会者自行开启视频';

  @override
  String get participantMuteAllAudioSuccess => '您已进行全体静音';

  @override
  String get participantMuteAllAudioFail => '全体静音失败';

  @override
  String get participantMuteAllVideoSuccess => '您已进行全体关闭视频';

  @override
  String get participantMuteAllVideoFail => '全体关闭视频失败';

  @override
  String get participantUnMuteAllAudioSuccess => '您已请求解除全体静音';

  @override
  String get participantUnMuteAllAudioFail => '解除全体静音失败';

  @override
  String get participantUnMuteAllVideoSuccess => '您已请求全体打开视频';

  @override
  String get participantUnMuteAllVideoFail => '全体打开视频失败';

  @override
  String get participantHostMuteVideo => '您已被停止视频';

  @override
  String get participantHostMuteAudio => '您已被静音';

  @override
  String get participantHostMuteAllAudio => '主持人设置了全体静音';

  @override
  String get participantHostMuteAllVideo => '主持人设置了全体关闭视频';

  @override
  String get participantMuteAudioHandsUpOnTips => '主持人已将您解除静音，你可以自由发言';

  @override
  String get participantOverRoleLimitCount => '分配角色超过人数限制';

  @override
  String get participantMe => '我';

  @override
  String get participantSearchMember => '搜索成员';

  @override
  String get participantHost => '主持人';

  @override
  String get participantCoHost => '联席主持人';

  @override
  String get participantMuteAllHandsUpTips => '主持人已将全体静音，您可以举手申请发言';

  @override
  String get participantTurnOffAllVideoHandsUpTips => '主持人已将全体视频关闭，您可以举手申请开启视频';

  @override
  String get participantWhiteBoardInteract => '授权白板互动';

  @override
  String get participantWhiteBoardInteractFail => '授权白板互动失败';

  @override
  String get participantUndoWhiteBoardInteract => '撤回白板互动';

  @override
  String get participantUndoWhiteBoardInteractFail => '撤回白板互动失败';

  @override
  String get participantUserHasBeenAssignCoHostRole => '已被设为联席主持人';

  @override
  String get participantUserHasBeenRevokeCoHostRole => '已被取消联席主持人';

  @override
  String get participantInMeeting => '会议中';

  @override
  String get participantNotJoined => '未入会';

  @override
  String get participantJoining => '加入中...';

  @override
  String get participantAttendees => '成员管理';

  @override
  String get participantAdmit => '准入';

  @override
  String get participantWaitingTimePrefix => '已等待';

  @override
  String get participantPutInWaitingRoom => '移至等候室';

  @override
  String get participantDisallowMemberRejoinMeeting => '不允许用户再次加入该会议';

  @override
  String participantVideoIsPinned(Object corner) {
    return '画面已锁定，点击$corner取消锁定';
  }

  @override
  String get participantVideoIsUnpinned => '画面已解锁';

  @override
  String get participantNotFound => '未找到相关成员';

  @override
  String get participantSetHost => '设为主持人';

  @override
  String get participantSetCoHost => '设为联席主持人';

  @override
  String get participantCancelCoHost => '撤销联席主持人';

  @override
  String get participantRemoveAttendee => '删除参会者';

  @override
  String get participantUpperLimitWaitingRoomTip => '当前会议已达人数上限，建议开启等候室。';

  @override
  String get participantUpperLimitReleaseSeatsTip =>
      '当前会议已达到人数上限，新参会者将无法加入会议，您可以尝试移除未入会成员或释放会议中的一个席位。';

  @override
  String get participantUpperLimitTipAdmitOtherTip =>
      '当前会议已达到人数上限，请先移除未入会成员或释放会议中的一个席位，然后再准入等候室成员。';

  @override
  String get cloudRecordingEnabledTitle => '是否开启云录制';

  @override
  String get cloudRecordingEnabledMessage => '开启后，所有参会成员将收到录制开始提醒';

  @override
  String get cloudRecordingEnabledMessageWithoutNotice =>
      '开启后，将录制会议过程中的音视频与共享屏幕内容到云端';

  @override
  String get cloudRecordingTitle => '该会议正在被录制中';

  @override
  String get cloudRecordingMessage =>
      '主持人开启了会议云录制，会议的创建者可以观看云录制文件，你可以在会议结束后联系创建者获取查看链接';

  @override
  String get cloudRecordingAgree => '如果留在会议中，表示你同意录制';

  @override
  String get cloudRecordingWhetherEndedTitle => '是否结束录制';

  @override
  String get cloudRecordingEndedMessage => '录制文件将会在会议结束后同步至“历史会议-会议详情”中';

  @override
  String get cloudRecordingEndedTitle => '云录制已结束';

  @override
  String get cloudRecordingEndedAndGetUrl => '你可以在会议结束后联系会议创建者获取查看链接';

  @override
  String get cloudRecordingStart => '云录制';

  @override
  String get cloudRecordingStop => '停止录制';

  @override
  String get cloudRecording => '录制中';

  @override
  String get cloudRecordingStartFail => '开启录制失败';

  @override
  String get cloudRecordingStopFail => '停止录制失败';

  @override
  String get cloudRecordingStarting => '正在开启录制...';

  @override
  String get chat => '聊天';

  @override
  String get chatInputMessageHint => '输入消息...';

  @override
  String get chatCannotSendBlankLetter => '不支持发送空消息';

  @override
  String get chatJoinFail => '聊天室进入失败!';

  @override
  String get chatNewMessage => '新消息';

  @override
  String get chatUnsupportedFileExtension => '暂不支持发送此类文件';

  @override
  String get chatFileSizeExceedTheLimit => '文件大小不能超过200MB';

  @override
  String get chatImageSizeExceedTheLimit => '图片大小不能超过20MB';

  @override
  String get chatImageMessageTip => '[图片]';

  @override
  String get chatFileMessageTip => '[文件]';

  @override
  String get chatSaveToGallerySuccess => '已保存到系统相册';

  @override
  String get chatOperationFailNoPermission => '无操作权限';

  @override
  String get chatOpenFileFail => '打开文件失败';

  @override
  String get chatOpenFileFailNoPermission => '打开文件失败：无权限';

  @override
  String get chatOpenFileFailFileNotFound => '打开文件失败：文件不存在';

  @override
  String get chatOpenFileFailAppNotFound => '打开文件失败：无法找到打开此文件的应用';

  @override
  String get chatRecall => '撤回';

  @override
  String get chatAboveIsHistoryMessage => '以上为历史消息';

  @override
  String get chatYou => '你';

  @override
  String get chatRecallAMessage => '撤回一条消息';

  @override
  String get chatMessageRecalled => '消息已被撤回';

  @override
  String get chatMessage => '消息';

  @override
  String get chatSendTo => '发送至';

  @override
  String get chatAllMembersInMeeting => '会议中所有人';

  @override
  String get chatAllMembersInWaitingRoom => '等候室所有人';

  @override
  String get chatHistory => '聊天记录';

  @override
  String get chatMessageSendToWaitingRoom => '发给等候室的消息';

  @override
  String get chatNoChatHistory => '无聊天记录';

  @override
  String get chatAllMembers => '所有人';

  @override
  String get chatPrivate => '私聊';

  @override
  String get chatPrivateInWaitingRoom => '等候室-私聊';

  @override
  String get chatPermission => '聊天权限';

  @override
  String get chatFree => '允许自由聊天';

  @override
  String get chatPublicOnly => '仅允许公开聊天';

  @override
  String get chatPrivateHostOnly => '仅允许私聊主持人';

  @override
  String get chatMuted => '全体成员禁言';

  @override
  String get chatPermissionInMeeting => '会议中聊天权限';

  @override
  String get chatPermissionInWaitingRoom => '等候室聊天权限';

  @override
  String get chatWaitingRoomPrivateHostOnly => '允许等候室成员私聊主持人';

  @override
  String get chatHostMutedEveryone => '主持人已设置为全员禁言';

  @override
  String get chatHostLeft => '主持人已离会，无法发送私聊消息';

  @override
  String chatSaidToMe(Object userName) {
    return '$userName 对我说';
  }

  @override
  String chatISaidTo(Object userName) {
    return '我对$userName说';
  }

  @override
  String chatSaidToWaitingRoom(Object userName) {
    return '$userName 对等候室所有人说';
  }

  @override
  String get chatISaidToWaitingRoom => '我对等候室所有人说';

  @override
  String get chatSendFailed => '发送失败';

  @override
  String get chatMemberLeft => '参会者已离开会议';

  @override
  String get chatWaitingRoomMuted => '主持人暂未开放等候室聊天';

  @override
  String get chatHistoryNotEnabled => '聊天历史记录功能尚未开通，请联系管理员';

  @override
  String get waitingRoomJoinMeeting => '加入会议';

  @override
  String get waitingRoom => '等候室';

  @override
  String get waitingRoomJoinMeetingOption => '入会选项';

  @override
  String get waitingRoomWaitHostToInviteJoinMeeting => '请等待，主持人即将拉您进入会议';

  @override
  String get waitingRoomWaitMeetingToStart => '请等待，会议尚未开始';

  @override
  String get waitingRoomTurnOnMicrophone => '开启麦克风';

  @override
  String get waitingRoomTurnOnVideo => '开启摄像头';

  @override
  String get waitingRoomEnabledOnEntry => '等候室已开启';

  @override
  String get waitingRoomDisabledOnEntry => '等候室已关闭';

  @override
  String get waitingRoomDisableDialogTitle => '关闭等候室';

  @override
  String get waitingRoomDisableDialogMessage => '等候室关闭后，新成员将直接进入会议室';

  @override
  String get waitingRoomDisableDialogAdmitAll => '允许现有等候室成员全部进入会议';

  @override
  String get waitingRoomCloseRightNow => '立即关闭';

  @override
  String waitingRoomCount(Object count) {
    return '当前等候室已有$count人等候';
  }

  @override
  String get waitingRoomAutoAdmit => '本次会议自动准入';

  @override
  String get movedToWaitingRoom => '主持人已将您移至等候室';

  @override
  String get waitingRoomAdmitAll => '全部准入';

  @override
  String get waitingRoomRemoveAll => '全部移除';

  @override
  String get waitingRoomAdmitMember => '准入等候成员';

  @override
  String get waitingRoomAdmitAllMembersTip => '是否允许等候室所有成员加入会议?';

  @override
  String get waitingRoomRemoveAllMemberTip => '将等候室的所有成员都移除?';

  @override
  String get waitingRoomExpelWaitingMember => '移除等候成员';

  @override
  String get waiting => '等候中';

  @override
  String get waitingRoomEnable => '开启等候室';

  @override
  String get deviceSpeaker => '扬声器';

  @override
  String get deviceReceiver => '手机听筒';

  @override
  String get deviceBluetooth => '蓝牙耳机';

  @override
  String get deviceHeadphones => '有线耳机';

  @override
  String get deviceOutput => '输出设备';

  @override
  String get deviceHeadsetState => '您正在使用耳机';

  @override
  String get networkConnectionGood => '网络连接良好';

  @override
  String get networkConnectionGeneral => '网络连接一般';

  @override
  String get networkConnectionPoor => '网络连接较差';

  @override
  String get nan => '网络连接未知';

  @override
  String get networkLocalLatency => '延迟：';

  @override
  String get networkPacketLossRate => '丢包率：';

  @override
  String get networkReconnectionSuccessful => '网络重连成功';

  @override
  String get networkAbnormalityPleaseCheckYourNetwork => '网络异常，请检查您的网络';

  @override
  String get networkAbnormality => '网络异常';

  @override
  String get networkDisconnectedPleaseCheckYourNetworkStatusOrTryToRejoin =>
      '网络已断开，请检查您的网络情况，或尝试重新入会';

  @override
  String get networkNotStable => '当前网络状态不佳';

  @override
  String get networkUnavailableCloseFail => '网络异常，结束会议失败';

  @override
  String get networkDisconnectedTryingToReconnect => '网络已断开，正在尝试重新连接…';

  @override
  String get networkUnavailableCheck => '网络连接失败，请检查你的网络连接！';

  @override
  String get networkUnstableTip => '网络不稳定，正在连接...';

  @override
  String get notifyCenter => '通知中心';

  @override
  String get notifyCenterAllClear => '确认清空所有通知?';

  @override
  String get notifyCenterNoMessage => '暂无消息';

  @override
  String get notifyCenterViewDetailsUnsupported => '该消息不支持查看详情';

  @override
  String get notifyCenterViewingDetails => '查看详情';

  @override
  String get sipCallByNumber => '拨号入会';

  @override
  String get sipCall => '呼叫';

  @override
  String get sipContacts => '会议通讯录';

  @override
  String get sipNumberPlaceholder => '请输入手机号';

  @override
  String get sipName => '受邀者名称';

  @override
  String get sipNamePlaceholder => '名字将会在会议中展示';

  @override
  String get sipCallNumber => '拨出号码：';

  @override
  String get sipNumberError => '请输入正确的手机号';

  @override
  String get sipCallIsCalling => '该号码已在呼叫中';

  @override
  String get sipLocalContacts => '本地通讯录';

  @override
  String get sipContactsClear => '清空';

  @override
  String get sipCalling => '正在呼叫中...';

  @override
  String get sipCallTerm => '挂断';

  @override
  String get sipCallOthers => '呼叫其他成员';

  @override
  String get sipCallFailed => '呼叫失败';

  @override
  String get sipCallAgain => '重新拨打';

  @override
  String get sipSearch => '搜索';

  @override
  String get sipSearchContacts => '搜索并添加参会人';

  @override
  String get sipCallPhone => '电话呼叫';

  @override
  String get sipCallingNumber => '未入会';

  @override
  String get sipCallCancel => '取消呼叫';

  @override
  String get sipCallAgainEx => '再次呼叫';

  @override
  String get sipCallStatusCalling => '电话呼叫中';

  @override
  String get callStatusCalling => '呼叫中…';

  @override
  String get sipCallStatusWaiting => '等待呼叫中';

  @override
  String get callStatusWaitingJoin => '待入会';

  @override
  String get sipCallStatusTermed => '已挂断';

  @override
  String get sipCallStatusUnaccepted => '未接听';

  @override
  String get sipCallStatusRejected => '已拒接';

  @override
  String get sipCallStatusCanceled => '呼叫已取消';

  @override
  String get sipCallStatusError => '呼叫异常';

  @override
  String get sipPhoneNumber => '电话号码';

  @override
  String sipCallMemberSelected(Object count) {
    return '已选：$count';
  }

  @override
  String get sipContactsPrivacy => '请授权访问您的通讯录，用于呼叫联系人以电话方式入会';

  @override
  String get memberCountOutOfRange => '已达会议人数上限';

  @override
  String get sipContactNoNumber => '该成员无电话信息，暂不支持选择';

  @override
  String get sipCallIsInMeeting => '该成员已在会议中';

  @override
  String get callInWaitingMeeting => '该成员已在等候室中';

  @override
  String get sipCallIsInInviting => '该成员正在呼叫中';

  @override
  String get sipCallIsInBlacklist => '该成员已被标记不允许再次加入，如需邀请，请关闭会议黑名单';

  @override
  String get sipCallByPhone => '电话呼叫';

  @override
  String get sipKeypad => '拨号';

  @override
  String get sipBatchCall => '批量呼叫';

  @override
  String get sipLocalContactsEmpty => '本地通讯录为空';

  @override
  String sipCallMaxCount(Object count) {
    return '单次最多选择$count人';
  }

  @override
  String get sipInviteInfo => '邀请信息';

  @override
  String get sipAddressInvite => '通讯录邀请';

  @override
  String get sipJoinOtherMeetingTip => '加入后将离开当前会议';

  @override
  String get sipRoom => '会议室';

  @override
  String get sipCallOutPhone => '呼叫电话';

  @override
  String get sipCallOutRoom => '呼叫SIP/H.323会议室';

  @override
  String get sipCallOutRoomInputTip => '请输入IP地址 或 SIP URI 或 已注册设备号码';

  @override
  String get sipDisplayName => '入会名称';

  @override
  String get sipDeviceIsInCalling => '该设备已在呼叫中';

  @override
  String get sipDeviceIsInMeeting => '该设备已在会议中';

  @override
  String get monitoring => '质量监控';

  @override
  String get overall => '总体';

  @override
  String get soundAndVideo => '音视频';

  @override
  String get cpu => 'CPU';

  @override
  String get memory => '内存';

  @override
  String get network => '网络';

  @override
  String get bandwidth => '带宽';

  @override
  String get networkType => '网络类型';

  @override
  String get networkState => '网络状况';

  @override
  String get delay => '延迟';

  @override
  String get packageLossRate => '丢包率';

  @override
  String get recently => '近';

  @override
  String get audio => '音频';

  @override
  String get microphone => '麦克风';

  @override
  String get speaker => '扬声器';

  @override
  String get bitrate => '码率';

  @override
  String get speakerPlayback => '扬声器播放';

  @override
  String get microphoneAcquisition => '麦克风采集';

  @override
  String get resolution => '分辨率';

  @override
  String get frameRate => '帧率';

  @override
  String get moreMonitoring => '查看更多数据';

  @override
  String get layoutSettings => '布局设置';

  @override
  String get galleryModeMaxCount => '画廊模式下单屏显示的最大画面数';

  @override
  String galleryModeScreens(Object count) {
    return '$count 画面';
  }

  @override
  String get followGalleryLayout => '跟随主持人视频顺序';

  @override
  String get resetGalleryLayout => '重置视频顺序';

  @override
  String get followGalleryLayoutTips => '将主持人画廊模式前25个视频顺序同步给所有参会者，且不允许参会者自行改变。';

  @override
  String get followGalleryLayoutConfirm => '主持人已设置“跟随主持人视频顺序”，无法移动视频。';

  @override
  String get followGalleryLayoutResetConfirm => '主持人已设置“跟随主持人视频顺序”，无法重置视频顺序。';

  @override
  String get saveGalleryLayoutTitle => '保存视频顺序';

  @override
  String get saveGalleryLayoutContent => '将当前视频顺序保存到该预约会议，可供后续会议使用，确定保存？';

  @override
  String get replaceGalleryLayoutContent => '该预约会议已有一份旧的视频顺序，是否替换并保存为新的视频顺序？';

  @override
  String get loadGalleryLayoutTitle => '加载视频顺序';

  @override
  String get loadGalleryLayoutContent => '该预约会议已有一份视频顺序，是否加载？';

  @override
  String get load => '加载';

  @override
  String get noLoadGalleryLayout => '暂无可加载的视频顺序';

  @override
  String get loadSuccess => '加载成功';

  @override
  String get loadFail => '加载失败';

  @override
  String get globalUpdate => '更新';

  @override
  String get globalLang => '语言';

  @override
  String get globalView => '查看';

  @override
  String get interpretation => '同声传译';

  @override
  String get interpInterpreter => '译员';

  @override
  String get interpSelectInterpreter => '选择译员';

  @override
  String get interpInterpreterAlreadyExists => '用户已被选为译员，无法重复选择';

  @override
  String get interpInfoIncompleteTitle => '译员信息不完整';

  @override
  String get interpInfoIncompleteMsg => '退出将删除信息不完整的译员';

  @override
  String get interpStart => '开始同声传译';

  @override
  String get interpStartNotification => '主持人已开启同声传译';

  @override
  String get interpStop => '关闭同声传译';

  @override
  String get interpStopNotification => '主持人已关闭同声传译';

  @override
  String get interpConfirmStopMsg => '关闭同声传译将关闭所有收听的频道，是否关闭？';

  @override
  String get interpConfirmUpdateMsg => '是否更新？';

  @override
  String get interpConfirmCancelEditMsg => '确定取消同声传译设置吗？';

  @override
  String get interpSelectListenLanguage => '请选择收听语言';

  @override
  String get interpSelectLanguage => '选择语言';

  @override
  String get interpAddLanguage => '添加语言';

  @override
  String get interpInputLanguage => '输入语言';

  @override
  String get interpLanguageAlreadyExists => '语言已存在';

  @override
  String get interpListenMajorAudioMeanwhile => '同时收听原声';

  @override
  String get interpManagement => '管理同声传译';

  @override
  String get interpSettings => '设置同声传译';

  @override
  String get interpMajorAudio => '原声';

  @override
  String get interpMajorChannel => '主频道';

  @override
  String get interpMajorAudioVolume => '原声音量';

  @override
  String get interpAddInterpreter => '添加译员';

  @override
  String get interpJoinChannelErrorMsg => '加入传译频道失败，是否重新加入？';

  @override
  String get interpReJoinChannel => '重新加入';

  @override
  String get interpAssignInterpreter => '您已成为本场会议的同传译员';

  @override
  String get interpAssignLanguage => '当前语言';

  @override
  String get interpAssignInterpreterTip => '您可以在“同声传译”中设置收听语言与传译语言';

  @override
  String get interpUnassignInterpreter => '您已被主持人从同传译员中移除';

  @override
  String interpLanguageRemoved(Object language) {
    return '主持人已删除收听语言“$language”';
  }

  @override
  String get interpInterpreterOffline => '当前收听的频道中，译员已全部离开，是否为您切换回原声？';

  @override
  String get interpDontSwitch => '暂不切换';

  @override
  String get interpSwitchToMajorAudio => '切回原声';

  @override
  String get interpAudioShareIsForbiddenDesktop => '作为译员，您共享屏幕时将无法同时共享电脑声音';

  @override
  String get interpAudioShareIsForbiddenMobile => '作为译员，您共享屏幕时将无法同时共享设备音频';

  @override
  String get interpInterpreterInMeetingStatusChanged => '译员参会状态已变更';

  @override
  String interpSpeakerTip(Object language1, Object language2) {
    return '您正在收听$language1，说$language2';
  }

  @override
  String get interpOutputLanguage => '传译语言';

  @override
  String get interpRemoveInterpreterOnly => '仅删除译员';

  @override
  String get interpRemoveInterpreterInMembers => '同时从参会人中删除';

  @override
  String get interpRemoveMemberInInterpreters => '该参会人同时被指派为译员，删除参会者将会同时取消译员指派';

  @override
  String get interpListeningChannelDisconnect => '收听语言频道已断开，正在尝试重连';

  @override
  String get interpSpeakingChannelDisconnect => '传译语言频道已断开，正在尝试重连';

  @override
  String get langChinese => '中文';

  @override
  String get langEnglish => '英语';

  @override
  String get langJapanese => '日语';

  @override
  String get langKorean => '韩语';

  @override
  String get langFrench => '法语';

  @override
  String get langGerman => '德语';

  @override
  String get langSpanish => '西班牙语';

  @override
  String get langRussian => '俄语';

  @override
  String get langPortuguese => '葡萄牙语';

  @override
  String get langItalian => '意大利语';

  @override
  String get langTurkish => '土耳其语';

  @override
  String get langVietnamese => '越南语';

  @override
  String get langThai => '泰语';

  @override
  String get langIndonesian => '印尼语';

  @override
  String get langMalay => '马来语';

  @override
  String get langArabic => '阿拉伯语';

  @override
  String get langHindi => '印地语';

  @override
  String get annotation => '互动批注';

  @override
  String get annotationEnabled => '互动批注已开启';

  @override
  String get annotationDisabled => '互动批注已关闭';

  @override
  String get startAnnotation => '批注';

  @override
  String get stopAnnotation => '退出批注';

  @override
  String get inAnnotation => '正在批注中';

  @override
  String get saveAnnotation => '保存当前批注';

  @override
  String get cancelAnnotation => '取消批注';

  @override
  String get settings => '设置';

  @override
  String get settingAudio => '音频';

  @override
  String get settingVideo => '视频';

  @override
  String get settingCommon => '通用';

  @override
  String get settingAudioAINS => '智能降噪';

  @override
  String get settingEnableTransparentWhiteboard => '设置白板透明';

  @override
  String get settingEnableFrontCameraMirror => '前置摄像头镜像';

  @override
  String get settingShowMeetDuration => '显示会议持续时间';

  @override
  String get settingSpeakerSpotlight => '语音激励';

  @override
  String get settingSpeakerSpotlightTip => '开启后，将优先显示正在说话的参会成员';

  @override
  String get settingShowName => '始终在视频中显示参会者名字';

  @override
  String get settingHideNotYetJoinedMembers => '隐藏未入会成员';

  @override
  String get settingChatMessageNotification => '新聊天消息提醒';

  @override
  String get settingChatMessageNotificationBarrage => '弹幕';

  @override
  String get settingChatMessageNotificationBubble => '气泡';

  @override
  String get settingChatMessageNotificationNoReminder => '不提醒';

  @override
  String get usingComputerAudioInMeeting => '入会时使用电脑麦克风';

  @override
  String get joinMeetingSettings => '入会设置';

  @override
  String get memberJoinWithMute => '成员入会时自动静音';

  @override
  String get ringWhenMemberJoinOrLeave => '成员入会或离开时播放提示音';

  @override
  String get transcriptionEnableCaption => '开启字幕';

  @override
  String get transcriptionEnableCaptionHint => '当前字幕仅自己可见';

  @override
  String get transcriptionDisableCaption => '关闭字幕';

  @override
  String get transcriptionDisableCaptionHint => '您已关闭字幕';

  @override
  String get transcriptionCaptionLoading => '正在开启字幕，机器识别仅供参考...';

  @override
  String get transcriptionDisclaimer => '机器识别仅供参考';

  @override
  String get transcriptionCaptionSettingsHint => '点击进入字幕设置';

  @override
  String get transcriptionCaptionSettings => '字幕设置';

  @override
  String get transcriptionAllowEnableCaption => '使用字幕功能';

  @override
  String get transcriptionCanNotEnableCaption => '字幕暂不可用，请联系主持人或管理员';

  @override
  String get transcriptionCaptionForbidden => '主持人不允许成员使用字幕，已关闭字幕';

  @override
  String get transcriptionCaptionNotAvailableInSubChannel =>
      '当前未收听原声，字幕暂不可用，如需使用请收听原声';

  @override
  String get transcriptionCaptionFontSize => '字号';

  @override
  String get transcriptionCaptionSmall => '小';

  @override
  String get transcriptionCaptionBig => '大';

  @override
  String get transcriptionCaptionEnableWhenJoin => '加入会议时开启字幕';

  @override
  String get transcriptionCaptionExampleSize => '字幕文字大小示例';

  @override
  String get transcriptionCaptionTypeSize => '字号大小';

  @override
  String get transcription => '实时转写';

  @override
  String get transcriptionStart => '开启转写';

  @override
  String get transcriptionStop => '停止转写';

  @override
  String get transcriptionStartConfirmMsg => '是否开启实时转写？';

  @override
  String get transcriptionStartedNotificationMsg => '主持人已开启实时转写，所有成员可查看转写内容';

  @override
  String get transcriptionRunning => '转写中';

  @override
  String get transcriptionStartedTip => '主持人已开启实时转写';

  @override
  String get transcriptionStoppedTip => '主持人已关闭实时转写';

  @override
  String get transcriptionNotStarted => '暂未开启实时转写，请联系主持人开启转写';

  @override
  String get transcriptionStopFailed => '关闭字幕失败';

  @override
  String get transcriptionStartFailed => '开启字幕失败';

  @override
  String get transcriptionTranslationSettings => '翻译设置';

  @override
  String get transcriptionSettings => '转写设置';

  @override
  String get transcriptionTargetLang => '目标翻译语言';

  @override
  String get transcriptionShowBilingual => '同时显示双语';

  @override
  String get transcriptionNotTranslated => '不翻译';

  @override
  String get transcriptionMemberPermission => '查看成员权限';

  @override
  String get transcriptionViewFullContent => '查看完整内容';

  @override
  String get transcriptionViewConferenceContent => '查看参会期间内容';

  @override
  String get feedbackInRoom => '问题反馈';

  @override
  String get feedbackProblemType => '问题类型';

  @override
  String get feedbackSuccess => '反馈提交成功';

  @override
  String get feedbackFail => '反馈提交失败';

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
  String get feedback => '意见反馈';
}
