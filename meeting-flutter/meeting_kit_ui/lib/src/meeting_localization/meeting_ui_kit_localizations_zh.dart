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
  String get globalMin => '分钟';

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
  String get meetingSipNumber => 'SIP电话/终端';

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
  String get meetingNoSupportSwitch => 'iPad不支持切换模式';

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
  String get meetingHasScreenShareShare => '屏幕共享时暂不支持白板共享';

  @override
  String get meetingHasWhiteBoardShare => '共享白板时暂不支持屏幕共享';

  @override
  String get meetingStopSharing => '停止共享';

  @override
  String get meetingStopSharingConfirm => '确定停止正在进行的共享?';

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
  String get cloudRecordingEnabledTitle => '是否开启云录制';

  @override
  String get cloudRecordingEnabledMessage =>
      '开启后，将录制会议过程中的音视频与共享屏幕内容到云端，同时告知所有参会成员';

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
  String get chatAllMembersInMeeting => '会议内所有人';

  @override
  String get chatAllMembersInWaitingRoom => '等候室内所有人';

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
  String get networkNotStable => '当前网络状况不佳';

  @override
  String get networkUnavailableCloseFail => '网络异常，结束会议失败';

  @override
  String get networkDisconnectedTryingToReconnect => '网络已断开，正在尝试重新连接…';

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
  String get globalOperationNotSupportedInMeeting => '会议中暂不支持该操作';
}
