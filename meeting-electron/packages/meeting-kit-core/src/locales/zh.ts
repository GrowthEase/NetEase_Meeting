const [meeting, host, coHost, attendee] = [
  '会议',
  '主持人',
  '联席主持人',
  '参会者',
]

export default {
  meeting,
  host,
  coHost,
  attendee,
  globalAppName: '网易会议', // 顶部UI展示
  meetingJoin: `加入会议`, // 入会时密码弹窗输入文本
  meetingLeaveFull: `离开会议`, // 离开会议二次确认弹窗菜单按钮文本
  meetingLeave: '离开',
  meetingQuit: '结束会议', // 结束会议菜单按钮文本
  leave: '离开会议', // 离开会议菜单按钮文本
  hostExitTips: `确定要结束这个${meeting}吗？`, // 结束会议二次确认弹窗消息
  meetingLeaveConfirm: `确定要离开会议吗？`, // 离开会议二次确认弹窗消息
  changePresenterTips: `是否移交主持人权限？`,
  networkUnavailableCloseFail: `网络异常，结束会议失败`, //  结束会议失败提示
  globalCancel: '取消', //通用
  globalSure: '确定', //通用
  meetingBeauty: `美颜`, // 美颜功能名称
  meetingBeautyLevel: `美颜等级`, // 美颜等级
  meetingJoinTips: `正在进入${meeting}...`, // 加入会议Loading提示信息
  globalClose: `关闭`, // 通用
  globalOpen: `打开`, // 通用
  globalStart: '开启',
  globalDelete: '删除',
  participants: `${attendee}`, // 会议成员列表标题
  meetingJoinFail: `加入会 议失败`, //  加入会议失败提示
  reJoinMeetingFail: `重新加入${meeting}失败`, // 重试加入会议失败提示
  participantAssignedHost: `您已经成为主持人`, // 被移交主持人的提示
  participantAssignedCoHost: `您已被设为联席主持人`, // 被移交主持人的提示
  becomeTheCoHost: `已经成为${coHost}`, // 被移交主持人的提示x
  participantUnassignedCoHost: `您已被取消设为联席主持人`, // 被取消焦点视频提示
  participantAssignedActiveSpeaker: '您已被设置为焦点视频', // 被设置为焦点视频提示
  participantUnassignedActiveSpeaker: '您已被取消焦点视频', // 被取消焦点视频提示
  participantMuteAudioAll: '全体静音', // 全体静音功能
  participantMuteAudioAllDialogTips: '所有以及新加入成员将被静音', // 全体静音弹窗标题
  participantMuteAllAudioTip: `允许${attendee}自行解除静音`, // 操作全体静音弹窗可选项
  participantMuteAllAudioSuccess: '您已进行全体静音', //主持人端全体静音成功提示消息
  participantHostMuteAllAudio: `${host}设置了全体静音`, //全体静音时成员端提示消息
  participantMuteAllAudioFail: '全体静音失败', //全体静音失败提示消息
  participantUnmuteAll: '解除全体静音', //解除全体静音功能
  participantUnMuteAllAudioSuccess: '您已请求解除全体静音', //解除全体静音成功提示消息
  participantUnMuteAllAudioFail: '解除全体静音失败', //解除全体静音失败提示消息
  leaveByHost: `您已被${host}移出会议`,
  leaveBySelf: `您已在其他设备登录`,
  meetingLiveMode: '直播模式',

  participantTurnOffVideos: '全体关闭视频',
  participantMuteVideoAllDialogTips: '所有以及新加入成员将被关闭视频',
  participantMuteAllVideoTip: `允许${attendee}自行开启视频`,
  participantMuteAllVideoSuccess: '您已进行全体关闭视频',
  participantHostMuteAllVideo: `${host}设置了全体关闭视频`,
  participantMuteAllVideoFail: '全体关闭视频失败',
  unMuteVideoAll: '开启全体视频',
  participantUnMuteAllVideoSuccess: '您已请求全体打开视频',
  unMuteAllVideoFail: '开启全体视频失败',
  participantTurnOffAudioAndVideo: '关闭音视频',
  unmuteVideoAndAudio: '开启音视频',
  hostAgreeVideoHandsUp: `${host}已将您开启视频`,

  participantMute: '静音', //主持人操作成员静音功能菜单
  participantUnmute: '解除静音', //主持人操作成员解除静音功能菜单
  participantStopVideo: '停止视频', //主持人操作成员停止视频功能菜单
  participantStartVideo: '开启视频', // 主持人操作成员开启视频功能菜单
  screenShareStop: '结束共享', // 主持人操作成员结束共享功能菜单
  pauseScreenShare: '共享已暂停，请将窗口置于最上方',
  shareComputerAudio: '同时共享电脑声音',
  participantHostStoppedShare: `${host}已终止了您的共享`, //主持人终止共享提示
  participantAssignActiveSpeaker: '设为焦点视频', //主持人操作成员设置焦点视频菜单项
  participantUnassignActiveSpeaker: '取消焦点视频', //主持人操作成员取消焦点视频菜单项
  participantTransferHost: `移交${host}`, //主持人操作成员移交主持人菜单项
  participantAssignCoHost: `设置联席主持人`, // 主持人操作设置联席主持人
  participantUnassignCoHost: `取消联席主持人`, // 主持人操作取消联席主持人
  participantTransferHostConfirm: `确认将主持人移交给{{userName}}?`, //移交主持人确认弹窗消息
  participantRemove: '移除', //主持人操作成员移除成员菜单项
  participantRemoveConfirm: '确认移除', //移除成员确认弹窗消息
  yes: '是', //弹窗通用确认按钮文本静音
  no: '否', //弹窗通用否定按钮文本
  participantCannotRemoveSelf: '不能移除自己', // 不能移除自己提示消息
  participantMuteAudioFail: '静音失败', //静音失败提示
  participantUnMuteAudioFail: '解除静音失败', //解除静音失败提示
  participantMuteVideoFail: '停止视频失败', //停止视频失败提示
  participantUnMuteVideoFail: '开启视频失败', //开启视频失败提示
  participantFailedToAssignActiveSpeaker: '设为焦点视频失败', //设为焦点视频失败提示
  participantFailedToUnassignActiveSpeaker: '取消焦点视频失败', //取消焦点视频失败提示
  participantFailedToLowerHand: '放下成员举手失败', //放下成员举手失败提示
  participantFailedToTransferHost: `移交${host}失败`, //移交主持人失败提示
  participantOverRoleLimitCount: '分配角色超过人数限制',
  removeMemberSuccess: '移除成功', //移除成员成功提示
  participantFailedToRemove: '移除失败', //移除成员失败提示
  save: '保存', //通用功能按钮
  saveSuccess: '保存成功', //保存成功提示
  saveFail: '保存失败', //保存失败提示
  done: '完成', //通用功能按钮
  notify: '通知', //弹窗通用标题
  meetingSwitchOtherDevice: `因被${host}移出或切换至其他设备，您已退出${meeting}`, //从会议中被移除提示
  sure: '确定', //通用
  // forbiddenByHostVideo: `${host}已将您停止视频`, //本地重新打开摄像头失败，原因为被主持人禁用
  participantOpenCamera: '打开摄像头', //主持人申请打开成员视频弹窗标题
  participantHostOpenCameraTips: `${host}已重新打开您的摄像头，确认打开？`, //主持人申请打开成员视频弹窗消息
  participantOpenMicrophone: '打开麦克风', //主持人申请打开成员音频弹窗标题
  participantHostOpenMicroTips: `${host}已重新打开您的麦克风，确认打开？`, //主持人申请打开成员音频弹窗消息
  participantHostMuteVideo: '您已被停止视频', //主持人关闭成员视频提示消息
  participantHostMuteAudio: '您已被静音', //主持人关闭成员音频提示消息
  participantSetHost: '设为主持人',
  participantSetCoHost: '设为联席主持人',
  participantCancelCoHost: '撤销联席主持人',

  screenShare: '共享屏幕', //共享屏幕功能菜单文本
  screenShareTips: '将开始截取您的屏幕上显示的所有内容。', //屏幕共享弹窗消息
  screenShareOverLimit: '已有人在共享，您无法共享', //超出共享人数限制提示消息
  screenShareStartFail: '发起共享屏幕失败', // 屏幕共享失败提示
  meetingHasWhiteBoardShare: '共享白板时暂不支持屏幕共享',
  meetingHasScreenShareShare: '屏幕或电脑音频共享时暂不支持白板共享',
  screenShareStopFail: '停止共享屏幕失败', //屏幕共享失败提示
  whiteboardShare: '共享白板', //共享白板功能菜单
  whiteBoardClose: '退出白板', //退出白板功能菜单
  whiteBoardShareStopFail: '停止共享白板失败',
  whiteBoardShareStartFail: '发起白板共享失败',
  functionalityLimitedByTheNumberOfPeople: '该功能允许的同时使用人数达到上限',
  screenShareNoPermission: '没有屏幕共享权限',
  screenShareLocalTips: '正在共享屏幕', //共享端“正在共享屏幕”提示
  screenShareMyself: '你正在共享屏幕',
  screenShareSuffix: '的共享屏幕', //共享端画面名称后缀
  screenShareInteractionTip: '双指分开放大画面', // 操作共享屏幕的画面提示
  whiteBoardInteractionTip: '您被授予白板互动权限',
  whiteBoardUndoInteractionTip: '您被取消白板互动权限',
  meetingSpeakingPrefix: '正在讲话', //成员正在讲话前缀，后面会拼接用户昵称
  screenShareModeForbiddenOp: '共享屏幕时不能开启/停止视频', //共享屏幕时操作打开/关闭摄像头失败提示
  participantMe: '我',
  audioStateError: '当前音频被其他应用占用，请关闭后重试', //打开音频设备失败提示
  meetingLock: `锁定${meeting}`, //锁定会议功能
  meetingLocked: '会议已锁定',
  meetingNotExist: '会议不存在',
  unmuteAudioBySelf: '自行解除静音',
  updateNicknameBySelf: '自己改名',
  updateNicknameNoPermission: '主持人不允许成员改名',
  shareNoPermission: '共享失败，仅主持人可共享',
  localRecordPermission: '本地录制权限',
  localRecordOnlyHost: '仅主持人可录制',
  localRecordAll: '所有人可录制',
  meetingLockMeetingByHost: `${meeting}已锁定，新${attendee}将无法加入${meeting}`, //锁定会议成功主持人端提示消息
  meetingLockMeetingByHostFail: `${meeting}锁定失败`, //锁定失败提示
  meetingUnLockMeetingByHost: `${meeting}已解锁，新${attendee}将可以加入${meeting}`, //解锁会议成功主持人端提示
  meetingUnLockMeetingByHostFail: `${meeting}解锁失败`, //解锁会议失败提示
  coHostLimit: `${coHost}已达到上限`,
  nickname: '昵称', //昵称
  // 聊天室相关
  // inputMessageHint: '输入消息...', //聊天室输入框hint
  newMessage: '新消息', //新消息提示
  // chatRoomMessageSendFail: '聊天室消息发送失败', // 聊天室消息发送失败提示
  // cannotSendBlankLetter: '不支持发送空格', //聊天室消息发送失败提示
  chat: '聊天', //聊天功能菜单文本
  // more: '更多', //更多功能菜单文本
  // searchMember: '搜索成员', //成员搜索输入框提示文本
  // enterChatRoomFail: '聊天室进入失败!', //聊天室初始化失败提示
  meetingPassword: `${meeting}密码`, //会议密码弹窗标题
  meetingEnterPassword: `请输入${meeting}密码`, // 会议密码弹窗输入框提示
  meetingWrongPassword: '密码错误', // 会议密码验证失败提示
  deviceHeadsetState: '您正在使用耳机',
  meetingId: `${meeting}号`, // 会议ID
  meetingNumber: `${meeting}号`, // 会议号
  meetingShortNum: `${meeting}短号`, // 会议短号
  meetingCopyInvite: '复制邀请', //复制菜单文本
  meetingCopyInviteInfo: '复制邀请信息',
  scheduleMeetingSuccessTip: '预约成功，去分享会议链接', //预约会议功能
  globalCopy: '复制',
  avatarHide: '隐藏头像',
  hostSetAvatarHide: '主持人已隐藏所有头像',
  meetingInviteUrl: '入会链接',
  meetingSipNumber: '内线话机/终端入会',
  meetingMobileDialInTitle: '手机拨号入会',
  meetingMobileDialInMsg: '拨打 {{phoneNumber}}',
  meetingInputSipNumber: '输入 {{sipNumber}} 加入会议',
  copySuccess: '复制成功', //复制成功提示消息
  defaultMeetingInfoTitle: `邀请您参加会议`, //会议信息标题
  meetingInfoDesc: `${meeting}正在加密保护中`, //会议描述文本
  muteAllAudioHandsUpTips: `${host}已将全体静音，您可以举手申请发言`, //全体静音时打开音频弹窗提示消息
  muteAllVideoHandsUpTips: `${host}已将全体关闭视频，您可以举手申请开启视频`, //全体关闭视频时打开音频弹窗提示消息
  handsUpApply: '举手申请', //举手弹窗确认按钮文本
  cancelHandsUp: '取消举手',
  handsUpDown: '手放下', //主持人操作成员“手放下”菜单
  inHandsUp: '举手中', //举手中状态描述
  handsUpFail: '举手失败',
  handsUpSuccessAlready: `您已举手，等待${host}处理`,
  handsUpSuccess: `举手成功，等待${host}处理`,
  cancelHandsUpFail: '取消举手失败',
  hostRejectAudioHandsUp: `${host}已将您的手放下`,
  hostAgreeAudioHandsUp: `${host}已将您解除静音，您可以自由发言`,
  audioAlreadyOpen: '音频已打开，无需申请举手',
  whiteBoardInteract: '授权白板互动', //主持人操作成员授权白板功能菜单
  whiteBoardInteractFail: '授权白板互动失败', //主持人操作成员授权白板成功提示
  undoWhiteBoardInteract: '取消白板互动', //主持人操作成员撤回白板功能菜单
  undoWhiteBoardInteractFail: '取消白板互动失败', //主持人操作成员撤回白板失败提示
  sip: 'SIP电话/终端入会',
  sipTip: 'sip',
  meetingInviteUrlTips: '邀请链接',
  // 直播相关
  live: '直播', //直播功能
  liveUrl: '直播观看地址', //直播功能
  liveLink: '直播链接',
  enableLivePassword: '开启直播密码',
  enableChat: '开启观众互动',
  enableChatTip: '开启后，会议室和直播间消息相互可见',
  liveView: '直播画面（用户开启视频后可出现在列表中）',
  livePreview: '直播画面预览',
  liveViewPageBackgroundImage: '观看页背景图',
  liveCoverPicture: '直播封面图',
  liveCoverPictureTip: '建议 16:9 的图，不超过 5 M',
  liveSelectTip: '请从左侧选择直播画面',
  livePasswordTip: '请输入6位数字密码',
  liveStatusChange: '直播状态发生变化',
  refreshLiveLayout: '刷新直播布局',
  liveUpdateSetting: '更新直播设置',
  pleaseClick: '请点击',
  onlyEmployeesAllow: '仅本企业员工可观看',
  onlyEmployeesAllowTip: '开启后，非本企业员工无法观看直播',
  living: '直播中',
  memberNotInMeeting: `成员不在${meeting}中`,
  cannotSubscribeSelfAudio: '不能订阅自己的音频',
  partMemberNotInMeeting: `部分成员不在${meeting}中`,
  copyMeetingIdTip: '点击复制会议号',
  copyMeetingIdAndLink: '复制会议号/链接',
  copyAll: '复制全部',
  comingSoon: '即将上线，敬请期待',
  //补充
  commonTitle: '提示', // 通用二次提示title
  inviteBtn: '会议邀请', // 邀请按钮
  sipBtn: 'sip', // sip按钮
  inviteSubject: '会议主题', // 邀请弹窗-会议主题
  inviteTime: '会议时间', // 预约会议时间
  openCameraFailByHost: '已被主持人关闭画面，无法自行打开', // 主持人关闭摄像头成员打开视频提示
  noRename: '改名', // 改名按钮
  addSipMember: '添加参会者', // 改名按钮
  pleaseInputRename: '请输入想要修改的名字', // 改名input占位提示
  placeholderSipMember: 'SIP号码', // 改名input占位提示
  placeholderSipAddr: 'SIP地址', // 改名input占位提示
  reNameSuccessToast: '昵称修改成功', // 修改昵称成功提示
  reNameFailureToast: '昵称修改失败', // 修改昵称成功提示
  closeCommonTips: '确定关闭', // 白板、屏幕共享二次提示前置文案
  closeWhiteShareTips: '白板共享吗？', // 白板共享二次提示
  closeScreenShareTips: '共享吗？', // 屏幕共享二次提示
  galleryBtn: '视图布局', // 视图布局按钮
  layout: '布局', // 视图布局按钮
  galleryLayout: '画廊模式',
  speakerLayout: '演讲者模式',
  galleryLayoutGrid: '宫格',
  speakerLayoutTop: '顶部列表',
  speakerLayoutRight: '右侧列表',
  memberListBtnForHost: '管理参会者', // 底部成员列表按钮-主持人
  memberListBtnForNormal: '参会者', // 底部成员列表按钮-参会者
  moreBtn: '更多', // 更多按钮-底部控制栏
  hostEndMeetingToast: '主持人已结束会议', // 主持人结束会议后全局提示
  UNKNOWN: '未知异常', // 未知异常
  LOGIN_STATE_ERROR: '账号异常', // 账号异常
  CLOSE_BY_BACKEND: '后台关闭房间', // 后台关闭
  ALL_MEMBERS_OUT: '所有成员退出房间', // 所有成员退出
  END_OF_LIFE: '房间时间到期', // 房间到期
  CLOSE_BY_MEMBER: '房间被关闭', // 房间被关闭
  meetingLive: `${meeting}直播`,
  meetingLiveTitle: '直播主题',
  meetingLiveUrl: '直播地址',
  pleaseInputLivePassword: '请输入直播密码',
  pleaseInputLivePasswordHint: '请输入6位数字密码',
  liveInteraction: '直播互动',
  liveInteractionTips: `开启后，${meeting}和直播间消息互相可见`,
  liveViewSetting: '直播视图设置',
  liveViewSettingChange: '主播发生变更',
  liveViewPreviewTips: '当前直播视图预览',
  liveViewPreviewDesc: '请先进行直播视图设置',
  liveStart: '开始直播',
  liveUpdate: '更新直播设置',
  liveStop: '停止直播',
  liveGalleryView: '画廊视图',
  liveFocusView: '焦点视图',
  shareView: '屏幕共享视图',
  liveChooseView: '选择视图样式',
  liveChooseCountTips: `选择${attendee}作为主播，最多选择4人`,
  liveStartFail: '直播开始失败,请稍后重试',
  liveStartSuccess: '直播开始成功',
  livePickerCount: '已选择',
  livePickerCountPrefix: '人',
  liveUpdateFail: '直播更新失败,请稍后重试',
  liveUpdateSuccess: '直播更新成功',
  liveNeedMemberHint: '请重新选择成员',
  liveStopFail: '直播停止失败,请稍后重试',
  liveStopSuccess: '直播停止成功',
  livePassword: '直播密码',
  liveSubjectTip: '直播主题不能为空',
  liveTitlePlaceholder: '请输入直播主题',
  KICK_OUT: `您已被${host}移出会议`, // 被管理员踢出
  SYNC_DATA_ERROR: '数据同步错误', // 数据同步错误
  LEAVE_BY_SELF: '您已离开房间', // 成员主动离开房间
  kICK_BY_SELF: '您已在其他设备登录',
  OTHER: 'OTHER', // 其他
  hostCloseWhiteShareToast: '主持人已终止了您的共享', // 主持人关闭屏幕共享，参会者提示
  enterMeetingToast: '加入会议', // xxx加入会议提示
  more: '更多', // 成员列表-更多操作按钮
  cancelHandUpTips: '确认取消举手申请吗？', // 取消举手申请二次提示
  cancelHandUpSuccess: ' 取消举手成功', // 取消举手成功提示
  meetingRecording: '会议录制中', // 开启录制时提示
  securityInfo: '会议正在加密保护中',
  notJoinedMeeting: '成员尚未加入',
  disconnected: '网络已断开，正在尝试重新连接…',
  unmute: '暂时取消静音',
  searchName: '输入姓名进行搜索',
  meetingRepeatQuit: '结束于',
  lowerHand: '手放下',
  speaker: '扬声器',
  testSpeaker: '检测扬声器',
  outputLevel: '输出级别',
  outputVolume: '输出音量',
  microphone: '麦克风',
  testMicrophone: '检测麦克风',
  selectSpeaker: '请选择扬声器',
  selectMicrophone: '请选择麦克风',
  selectVideoSource: '请选择视频来源',
  camera: '摄像头',
  general: '常规',
  settings: '设置',
  internalOnly: '内部专用',
  meetingExist: '房间已存在',
  joinTheExistMeeting: '该房间已存在，请确认是否直接加入？',
  notSupportScreenShareChange: '共享屏幕时暂不支持切换视图',
  notSupportWhiteboardShareChange: '共享白板时暂不支持切换视图',
  notSupportOperateLayout: '正在进行屏幕分享，无法操作布局',
  screenShareLimit: '共享屏幕数量已达上限',
  cancelScreenShare: '取消开启屏幕共享',
  screenShareFailed: '共享屏幕失败',
  paramsError: '参数缺失',
  leaveFailed: '离开会议失败',
  endFailed: '结束会议失败',
  setSIPFailed: '无法设置SIP设备为主持人',
  requestFailed: '请求失败',
  screenShareNotAllow: '已经有人在共享，您无法共享',
  closeMemberWhiteboard: '关闭成员白板共享：',
  closeMemberScreenShare: '关闭成员屏幕共享：',
  changeFailed: '移交失败',
  removeFailed: '移除失败',
  closeWhiteFailed: '关闭白板失败',
  currentMicDevice: '当前麦克风设备',
  currentSpeakerDevice: '当前扬声器设备',
  currentCameraDevice: '当前视频设备',
  operateFailed: '操作失败',
  setVideoFailed: '设置视频失败',
  video: '视频',
  shortId: `会议短号`, // 会议短号
  networkStateGood: '网络连接良好',
  networkStateGeneral: '网络连接一般',
  networkStatePoor: '网络连接较差',
  latency: '延迟',
  packetLossRate: '丢包率',
  answeringPhone: '正在接听系统电话',
  chatRoomTitle: '消息',
  disconnectAudio: '断开电脑音频',
  connectAudio: '连接电脑音频',
  disconnectAudioFailed: '断开电脑音频失败',
  connectAudioFailed: '连接电脑音频失败',
  connectAudioShort: '连接音频',
  speakerVolumeMuteTips:
    '当前选中的扬声器设备暂无声音效果，请检查系统扬声器是否已解除静音并调至合适音量。',
  audioSetting: '音频选项',
  videoSetting: '视频选项',
  beautySetting: '美颜和虚拟背景选项',
  imageMsg: '[图片]',
  fileMsg: '[文件]',
  internal: '内部专用',
  openVideoDisable: '您已被停止视频',
  endMeetingTip: '距离会议关闭仅剩',
  min: '分钟',
  networkAbnormalityAndCheck: '网络异常，请检查您的网络',
  networkAbnormality: '网络异常',
  networkDisconnected: '网络已断开，请检查您的网络情况，或尝试重新入会',
  networkUnstableTip: '网络不稳定，正在连接...',
  networkNotStable: '当前网络状态不佳',
  rejoin: '重新入会',
  audioMuteOpenTips:
    '无法使用麦克风，检测到您正在讲话，如需发言，请点击“解除静音”按钮后再次发言',
  networkError: '网络错误',
  startCloudRecord: '云录制',
  stopCloudRecord: '停止录制',
  recording: '录制中',
  isStartCloudRecord: '是否开始云录制？',
  startRecordTip: '开启后，将录制会议过程中的音视频与共享屏幕内容到云端',
  startRecordTipNoNotify:
    '开启后，将录制会议过程中的音视频与共享屏幕内容到云端',
  beingMeetingRecorded: '该会议正在录制中',
  startRecordTipByMember:
    '主持人开启了会议云录制，会议的创建者可以观看云录制文件，你可以在会议结束后联系会议创建者获取查看链接。',
  agreeInRecordMeeting: '如果留在会议中，表示你同意录制',
  gotIt: '知道了',
  startingRecording: '正在开启录制...',
  endCloudRecording: '是否结束云录制',
  syncRecordFileAfterMeetingEnd:
    '录制文件将在会议结束后同步至“历史会议-会议详情”中。',
  cloudRecordingHasEnded: '云录制已结束',
  viewingLinkAfterMeetingEnd: '你可以在会议结束后联系会议创建者获取查看链接',
  meetingDetails: '会议详情',
  startTime: '开始时间',
  creator: '创建人',
  cloudRecordingLink: '云录制链接',
  generatingCloudRecordingFile: '云录制文件生成中',
  stopRecordFailed: '停止录制失败',
  startRecordFailed: '开启录制失败',
  messageRecalled: '消息已被撤回',
  microphonePermission: '开启麦克风权限',
  microphonePermissionTips:
    '由于系统安全控制，开启麦克风之前需要先开启系统麦克风权限',
  microphonePermissionTipsStep: '打开 系统偏好设置 > 安全性与隐私 授予访问权限',
  cameraPermission: '开启摄像头权限',
  cameraPermissionTips:
    '由于系统安全控制，开启摄像头之前需要先开启系统摄像头权限',
  cameraPermissionTipsStep: '打开 系统偏好设置 > 安全性与隐私 授予访问权限',
  openSystemPreferences: '打开系统偏好设置',
  meetingTime1Tips: '距离会议关闭仅剩1分钟！',
  meetingTime5Tips: '距离会议关闭仅剩5分钟！',
  meetingTime10Tips: '距离会议关闭仅剩10分钟！',
  alreadyInMeeting: '已经在会议中',
  debug: '调试',
  admit: '准入',
  attendees: '成员管理',
  notJoined: '未入会',
  inMeeting: '会议中',
  confirmLeave: '确定要离开会议吗?',
  waitingForHost: '请等待，主持人即将拉您进入会议',
  closeAutomatically: '点击确定，该页面自动关闭',
  removedFromMeeting: '被移除会议',
  removeFromMeetingByHost: '主持人已将您从会议中移除',
  meetingWatermark: '会议水印',
  waitingRoom: '等候室',
  meetingManagement: '会议管理',
  security: '安全',
  securitySettings: '安全设置',
  waitingMemberCount1: '当前等候室已有',
  waitingMemberCount2: '人等候',
  waitingRoomJoinMeetingOption: '入会选项',
  waitingRoomTurnOnMicrophone: '开启麦克风',
  waitingRoomTurnOnVideo: '开启摄像头',
  notRemindMeAgain: '不再提醒',
  viewMessage: '查看消息',
  closeWaitingRoomTip: '等候室关闭后，新成员将直接进入会议室',
  closeWaitingRoom: '关闭等候室',
  enabledWaitingRoom: '等候室已开启',
  disabledWaitingRoom: '等候室已关闭',
  enabledWatermark: '水印已开启',
  disabledWatermark: '水印已关闭',
  sendTo: '发送至',
  closeRightRow: '立即关闭',
  waitingRoomDisableDialogAdmitAll: '允许现有等候室成员全部进入会议',
  waiting: '已等待',
  days: '天',
  hours: '小时',
  minutes: '分钟',
  meetingWillBeginSoon: '请等待，会议尚未开始',
  meetingEnded: '会议已结束',
  chatMessage: '聊天信息',
  joining: '正在进入会议...',
  joinMeeting: '进入会议',

  notAllowJoin: '不允许用户再次加入该会议',
  participantExpelWaitingMemberDialogTitle: '移除等候成员',
  moveToWaitingRoom: '移至等候室',
  // 暂停会者活动
  stopMemberActivities: '暂停参会者活动',
  stopMemberActivitiesTitle: '暂停所有参会者活动？',
  stopText: '暂停',
  stopMemberActivitiesTip:
    '所有人都将被静音，视频、屏幕共享将停止，会议将被锁定。',
  memberStopActivitiesTip: '主持人已暂停参会者活动',
  hostStopActivitiesTip: '已暂停参会者活动',

  networkReconnectSuccess: '网络重连成功',
  networkErrorAndCheck: '网络异常，请检查网络设置',
  noMediaPermission: '没有摄像头/麦克风权限',
  getMediaPermission: '请在浏览器设置中打开摄像头/麦克风权限，并刷新页面',
  'errorCodes.10001': '10001 浏览器不支持，请使用HTTPS环境或者localhost环境',
  'errorCodes.10119': '10119 服务器认证失败',
  'errorCodes.10229': '10229 关闭麦克风失败',
  'errorCodes.10231': '10231 关闭摄像头失败',
  'errorCodes.10212': '没有摄像头/麦克风权限',
  meetingNickname: '会议昵称',
  imageSizeLimit5: '图片大小不能超过5MB',
  openCameraInMeeting: '入会时打开摄像头',
  openMicInMeeting: '入会时打开麦克风',
  showMeetingTime: '显示会议持续时间',
  showCurrentSpeaker: '显示当前说话者',
  alwaysDisplayToolbar: '始终显示工具栏',
  setWhiteboardTransparency: '设置白板透明',
  alwaysDisplayToolbarTip: '开启后，在会议中始终保持下方工具栏常驻',
  setWhiteboardTransparencyTip: '当设置白板透明时，将直接批注视频画面',
  mirrorVideo: '视频镜像',
  HDMode: '高清模式',
  HDModeTip: '网络与其他情况允许时，拉取高清视频画面',
  stopTest: '停止检测',
  inputVolume: '输入音量',
  autoAdjustMicVolume: '自动调节麦克风音量',
  pressSpaceBarToMute: '静音时长按空格键暂时开启麦克风',
  InputLevel: '输入级别',
  audio: '音频',
  downloadPath: '聊天文件保存至',
  chosePath: '选择路径',
  language: '语言',
  chooseLanguage: '选择语言',
  file: '文件',

  notification: '通知',
  notifyCenter: '通知中心',
  notifyCenterAllClear: '确认清空所有通知',
  notifyCenterNoMessage: '暂无消息',
  notifyCenterViewDetailsUnsupported: '该消息不支持查看详情',
  notifyCenterViewingDetails: '查看详情',

  meetingReclaimHost: '收回主持人',
  meetingReclaimHostCancel: '暂不收回',
  meetingReclaimHostTip:
    '{{user}}目前是主持人，收回主持人权限可能会中断屏幕共享等',
  meetingUserIsNowTheHost: '{{user}}已经成为主持人',
  meetingReclaimHostFailed: '收回主持人失败',

  // 会前
  appTitle: '网易会议',
  immediateMeeting: '发起会议',
  sponsorMeeting: '发起会议',
  scheduleMeeting: '预约会议',
  scheduleMeetingSuccess: '预约会议成功',
  scheduleMeetingFail: '预约会议失败',
  editScheduleMeetingSuccess: '编辑预约会议成功',
  editScheduleMeetingFail: '编辑预约会议失败',
  cancelScheduleMeetingSuccess: '取消预约会议成功',
  tokenExpired: '登录状态已过期，请重新登录',
  cancelScheduleMeetingFail: '取消预约会议失败',
  updateUserNicknameSuccess: '修改昵称成功',
  updateUserNicknameFail: '修改昵称失败',
  emptyScheduleMeeting: '暂无会议',
  globalMonday: '周一',
  globalTuesday: '周二',
  globalWednesday: '周三',
  globalThursday: '周四',
  globalFriday: '周五',
  globalSaturday: '周六',
  globalSunday: '周日',
  globalMonth: '月',
  yesterday: '昨天',
  historyMeeting: '历史会议',
  currentVersion: '当前版本',
  personalMeetingNum: '个人会议号',
  personalShortMeetingNum: '个人会议短号',
  feedback: '意见反馈',
  about: '关于我们',
  logout: '退出登录',
  logoutConfirm: '你确定要退出登录吗？',
  today: '今天',
  tomorrow: '明天',
  join: '加入',
  notStarted: '待开始',
  inProgress: '进行中',
  ended: '已结束',
  restoreMeetingTips: '检测到您上次异常退出，是否要恢复会议',
  restore: '恢复',
  uploadLoadingText: '您的反馈正在上传中，请稍后...',
  privacyAgreement: '隐私协议',
  userAgreement: '用户协议',
  copyRight: 'Copyright ©1997-{{year}} NetEase Inc.\nAll Rights Reserved.',
  chatHistory: '聊天记录',
  allMeeting: '全部会议',
  meetingRoomScreenCasting: '会议室投屏',
  app: '应用',
  collectMeeting: '收藏会议',
  operations: '操作',
  collect: '收藏',
  cancelCollect: '取消收藏',
  collectSuccess: '收藏成功',
  collectFail: '收藏失败',
  cancelCollectSuccess: '取消收藏成功',
  cancelCollectFail: '取消收藏失败',
  noHistory: '暂无历史会议',
  noCollect: '暂无收藏会议',
  scrollEnd: '已经滚动到最底部了',
  openMeetingPassword: '开启会议密码',
  usePersonalMeetingID: '使用个人会议号：',
  meetingIDInputPlaceholder: '请输入会议ID',
  clearAll: '清除全部',
  clearAllSuccess: '历史记录已清空',
  waitingRoomTip: '开启后新成员加入会议时会先加入等候室',
  subjectTitlePlaceholder: '请输入会议主题',
  endTime: '结束时间',
  meetingSetting: '会议设置',
  autoMute: '参会者加入会议时自动静音',
  memberJoinOrLeaveMeetingTip: '参会者入会或离开时播放提示音',
  memberJoinMeetingPlaySoundTip: '参会者入会时将播放提示音',
  openMeetingLive: '开启会议直播',
  cancelScheduleMeetingTips: '取消会议后，其他参会者将无法加入会议。',
  noCancelScheduleMeeting: '暂不取消',
  cancelScheduleMeeting: '取消会议',
  editScheduleMeeting: '编辑会议',
  autoMuteAllowOpen: '自动静音且允许自主开麦',
  autoMuteNotAllowOpen: '自动静音且不允许自主开麦',
  reName: '修改昵称',
  reNamePlaceholder: '请输入新的昵称',
  reNameTips: '不超过10个汉字或20个字母/数字/符号',
  // 美颜设置
  beautySettingTitle: '美颜与虚拟背景',
  beautyEffect: '美颜效果',
  virtualBackground: '虚拟背景',
  addLocalImage: '添加本地图片',
  emptyVirtualBackground: '无',
  virtualBackgroundError1: '自定义背景图片不存在',
  virtualBackgroundError2: '自定义背景图片的图片格式无效',
  virtualBackgroundError3: '自定义背景图片的颜色格式无效',
  virtualBackgroundError4: '该设备不支持使用虚拟背景',
  virtualBackgroundError5: '虚拟背景开启失败',
  // 共享
  selectSharedContent: '选择共享内容',
  startShare: '开始共享',
  desktop: '桌面',
  applicationWindow: '应用窗口',
  shareLocalComputerSound: '同时共享本地电脑声音',
  getScreenCaptureSourceListError: '获取共享列表失败，请给予权限后重试',

  // 意见反馈
  audioProblem: '音频问题',
  aLargeDelay: '对方说话声音延迟很大',
  mechanicalSound: '播放机械音',
  stuck: '对方说话声音很卡',
  noise: '杂音',
  echo: '有回声',
  notHear: '听不到对方声音',
  notHearMe: '对方听不到我的声音',
  lowVolume: '音量小',
  videoProblem: '视频问题',
  longTimeStuck: '对方视频卡顿时间较长',
  videoIsIntermittent: '视频断断续续',
  tearing: '画面撕裂',
  tooBrightTooDark: '画面太亮/太暗',
  blurredImage: '画面模糊',
  obviousNoise: '画面明显噪点',
  notSynchronized: '音画不同步',
  other: '其他',
  unexpectedExit: '意外退出',
  otherProblems: '其他问题',
  otherProblemsTips:
    '请描述您的问题，（当您选中"存在其他问题"时），需填写具体描述才可进行提交',
  thankYourFeedback: '感谢您的反馈',
  uploadFailed: '上传失败',
  submit: '提交',
  // NPS
  npsTitle: '您有多大的可能向同事或合作伙伴推荐网易会议？',
  nps0: '0-肯定不会',
  nps10: '10-非常乐意',
  npsTips1: '0-6：让您不满意或者失望的点有哪些？（选填）',
  npsTips2: '7-8：您觉得哪些方面能做的更好？（选填）',
  npsTips3: '9-10：欢迎分享您体验最好的功能或感受（选填）',
  supportedMeetings: '您可召开：',
  meetingLimit: '{{maxCount}}人、限时{{maxMinutes}}分钟会议',
  meetingNoLimit: '{maxCount}人、单场不限时会议',
  settingServiceBundleExpirationDate: '服务到期：',
  settingServiceBundleExpirationDateTip:
    '服务已到期，如需延长时问，请联系企业管理员。',
  accountAndSecurity: '账号与安全',
  newPwdNotMath: '新密码格式不符，请重新输入',
  newPwdNotMathReEnter: '新密码不一致，请重新输入',
  // 设置音频
  advancedSettings: '高级设置',
  audioNoiseReduction: '音频降噪',
  musicModeAndProfessionalMode: '音乐模式与专业模式',
  musicModeAndProfessionalModeTips:
    '音频降噪开启时，无法使用音乐模式与专业模式',
  echoCancellation: '回声消除',
  activateStereo: '启动立体声',
  defaultDevice: '默认设备',
  authPrivacyCheckedTips: '请先勾选同意《隐私协议》和《用户服务协议》',
  authNoCorpCode: '没有企业代码？',
  authCreateNow: '立即创建',
  authLoginToTrialEdition: '前往体验版',
  authNextStep: '下一步',
  authHasCorpCode: '已有企业代码？',
  authLoginToCorpEdition: '前往正式版',
  authLoginBySSO: 'SSO登录',
  authPrivacy: '隐私政策',
  authUserProtocol: '用户协议',
  authEnterCorpCode: '请输入企业代码',
  authSSOTip: '暂无所属企业',
  authAnd: '和',
  authRegisterAndLogin: '注册/登录',
  authHasReadAndAgreeMeeting: '已阅读并同意网易会议',
  authLoggingIn: '正在登录会议',
  authLoginByMobile: '手机验证码登录',
  authLogin: '登录',
  authEnterMobile: '请输入手机号',
  authEnterAccount: '请输入账号',
  authEnterPassword: '请输入密码',
  authLoginByCorpCode: '企业代码登录',
  authLoginByCorpMail: '企业邮箱登录',
  authEnterCorpMail: '请输入邮箱',
  authResetInitialPasswordDialogTitle: '设置新密码',
  authResetInitialPasswordDialogMessage:
    '当前密码为初始密码，为了安全考虑，建议您前往设置新密码',
  authResetInitialPasswordDialogCancelLabel: '暂不设置',
  authResetInitialPasswordDialogOKLabel: '前往设置',
  authResetInitialPasswordTitle: '设置你的新密码',
  authModifyPasswordSuccess: '密码修改成功',
  authUnavailable: '暂无',
  authMobileNum: '手机号',
  authEnterCheckCode: '请输入验证码',
  authGetCheckCode: '获取验证码',
  authResendCode: '后重新发送验证码',
  authSuggestChrome: '推荐使用Chrome浏览器',
  settingEnterNewPasswordTips: '请输入新密码',
  settingEnterPasswordConfirm: '请再次输入新密码',
  settingValidatorPwdTip: '长度6-18个字符，需要包含大小写字母与数字',
  settingPasswordDifferent: '两次输入的新密码不一致，请重新输入',
  settingPasswordSameToOld: '新密码与现有密码重复，请重新输入',
  settingPasswordFormatError: '密码格式错误，请重新输入',
  settingAccountInfo: '账号信息',
  settingConnectAdmin: '如需修改，请联系管理员后台修改',
  settingUserName: '名称',
  settingEmail: '邮箱',
  settingAccountSecurity: '账号安全',
  settingChangePassword: '修改密码',
  settingChangePasswordTip: '修改后您需要重新登录',
  settingEnterOldPassword: '请输入旧密码',
  settingEnterNewPassword: '请输入新密码',
  settingEnterNewPasswordConfirm: '请再次输入新密码',
  settingHideNotYetJoinedMembers: '隐藏未入会成员',
  settingHideNotYetJoinedMembersTip:
    '开启后，未入会和呼叫中的成员将不会在视图布局中显示',

  settingFindNewVersion: '发现新版本',
  settingUpdateFailed: '更新失败',
  settingTryAgainLater: '下次再试',
  settingRetryNow: '立即重试',
  settingUpdating: '更新中',
  settingCancelUpdate: '取消更新',
  settingExitApp: '退出应用',
  settingNotUpdate: '暂不更新',
  settingUPdateNow: '立即更新',
  settingConfirmExitApp: '确定退出应用',

  meetingPinView: '锁定视频',
  meetingPinViewTip: '画面已锁定，点击{{corner}}取消锁定',
  meetingTopLeftCorner: '左下角',
  meetingBottomRightCorner: '右下角',
  meetingUnpinView: '取消锁定视频',
  meetingUnpinViewTip: '画面已解锁',
  meetingUnpin: '取消锁定',
  meetingPinFailedByFocus: '主持人已设置焦点视频，不支持该操作',
  meetingBlacklist: '会议黑名单',
  meetingBlacklistTip: '开启后，被标记"不允许再次加入”的用户将无法加入该会议',
  meetingNotAllowedToRejoin: '不允许再次加入该会议',
  unableMeetingBlacklistTip:
    '关闭后将清空黑名单，被标记“不允许再次加入”的用户可重新加入会议',
  unableMeetingBlacklistTitle: '确认关闭会议黑名单？',
  meetingJoinBeforeHost: '允许参会者在主持人进会前加入会议',

  waitingRoomAutoAdmit: '本次会议自动准入',
  waitingRoomAdmitAll: '全部准入',
  waitingRoomRemoveAll: '全部移除',
  waitingRoomAdmitMember: '准入等候成员',
  waitingRoomAdmitAllMembersTip: '是否允许等候室所有成员加入会议',
  waitingRoomRemoveAllMemberTip: '将等候室的所有成员都移除',
  meetingRepeatDate: '日期',
  meetingRepeatWeekday: '星期',

  meetingRepeatMeetings: '周期性会议',
  timezone: '时区',
  meetingRepeatLabel: '重复',
  meetingRepeatFrequency: '频率',
  meetingRepeatEnd: '结束',
  meetingRepeatEveryday: '每天',
  meetingRepeatEveryWeekday: '每个工作日',
  meetingRepeatEveryWeek: '每周',
  meetingRepeatEveryTwoWeek: '每两周',
  meetingRepeatEveryMonth: '每月',
  meetingRepeatOneDay: '某天',
  meetingRepeatTimes: '限定会议次数',
  meetingRepeatCustom: '自定义',
  meetingRepeatUnitDay: '天',
  meetingRepeatUnitWeek: '周',
  meetingRepeatUnitMonth: '月',
  meetingRepeatAt: '位于',
  meetingRepeatUnitEvery: '每',
  meetingRepeat: '周期',
  meetingRepeatOrderWeekday: '第{{week}}个 {{weekday}}',
  meetingRepeatEditTips: '修改以下信息，将影响该系列周期性会议',
  meetingRepeatEditing: '你正在编辑周期性会议',
  meetingRepeatEditCurrent: '编辑本次会议',
  meetingRepeatEditAll: '编辑所有会议',
  meetingLeaveEditTips: '确认退出会议编辑吗？',
  meetingRepeatCancelAll: '同时取消该系列周期性会议',
  meetingLeaveEditTips2: '退出后，将无法保存当前会议的更改',
  meetingEditContinue: '继续编辑',
  meetingRepeatCancelEdit: '取消编辑',
  meetingAttendees: '参会者',
  meetingRepeatUncheckTips: '当前日程为{{date}}，无法取消选择',
  settingAvatarTitle: '头像设置',
  settingAvatarUpdateSuccess: '头像更新成功',
  settingAvatarUpdateFail: '头像更新失败',
  updateSuccess: '更新成功',

  // 私聊
  messageLengthLimit: '消息长度不能超过5000',
  fileTypeNotSupport: '文件格式暂不支持',
  chatInputMessageHint: '输入消息...',
  chatCannotSendBlankLetter: '不支持发送空消息',
  chatFileSizeExceedTheLimit: '文件大小不能超过200MB',
  chatImageSizeExceedTheLimit: '图片大小不能超过20MB',
  chatRecall: '撤回',
  chatYou: '你',
  chatRecallAMessage: '撤回一条消息',
  chatMessageRecalled: '消息已被撤回',
  chatPrivate: '私聊',
  chatPrivateInWaitingRoom: '等候室-私聊',
  chatISaidTo: '我对{{userName}}说',
  chatSaidToMe: '{{userName}} 对我说',
  chatSaidToWaitingRoom: '{{userName}} 对等候室说',
  chatISaidToWaitingRoom: '我对等候室所有人说',
  meetingAllowMembersTo: '允许参会人员',
  meetingChat: '会中聊天',
  screenShareDisabledWarning:
    '近期有不法分子冒充客服、校园贷和公检法诈骗，请您提高警惕。检测到您的会议有安全风险，已禁用了共享功能。',
  screenShareWarning:
    '您屏幕上包括通知在内的所有内容，均将被录制。请警惕仿冒客服、校园贷和公检法的诈骗，不要在“共享屏幕”时进行财务转账操作。',
  meetingChatEnabled: '会中聊天已开启',
  meetingChatDisabled: '会中聊天已关闭',
  chatMemberLeft: '参会者已离开会议',
  chatSendTo: '发送至',
  chatAllMembersInMeeting: '会议中所有人',
  chatAllMembersInWaitingRoom: '等候室所有人',
  chatAllMembers: '所有人',
  chatPermission: '聊天权限',
  chatFree: '允许自由聊天',
  chatPublicOnly: '仅允许公开聊天',
  chatPrivateHostOnly: '仅允许私聊主持人',
  chatMuted: '全体成员禁言',
  chatPermissionInMeeting: '会议中聊天权限',
  chatPermissionInWaitingRoom: '等候室聊天权限',
  chatWaitingRoomPrivateHostOnly: '允许等候室成员私聊主持人',
  chatHostMutedEveryone: '主持人已设置为全员禁言',
  chatHostLeft: '主持人已离会，无法发送私聊消息',
  participantNotFound: '未找到相关成员',
  chatWaitingRoomMuted: '主持人暂未开放等候室聊天',
  participantSearchMember: '搜索成员',

  // 质量监控
  monitoring: '质量监控',
  overall: '总体',
  soundAndVideo: '音视频',
  cpu: 'CPU',
  memory: '内存',
  network: '网络',
  bandwidth: '带宽',
  networkType: '网络类型',
  delay: '延迟',
  packageLossRate: '丢包率',
  recently: '近',
  bitrate: '码率',
  speakerPlayback: '扬声器播放',
  microphoneAcquisition: '麦克风采集',
  resolution: '分辨率',
  frameRate: '帧率',
  moreMonitoring: '查看更多数据',
  networkState: '网络状况',
  // 视频布局
  layoutSettings: '布局设置',
  galleryModeMaxCount: '画廊模式下单屏显示的最大画面数',
  galleryModeScreens: '{{count}} 画面',
  followGalleryLayout: '跟随主持人视频顺序',
  resetGalleryLayout: '重置视频顺序',
  followGalleryLayoutTips:
    '将主持人画廊模式前25个视频顺序同步给所有参会者，且不允许参会者自行改变。',
  followGalleryLayoutConfirm:
    '主持人已设置“跟随主持人视频顺序”，无法移动视频。',
  followGalleryLayoutResetConfirm:
    '主持人已设置“跟随主持人视频顺序”，无法重置视频顺序。',
  saveGalleryLayoutTitle: '保存视频顺序',
  saveGalleryLayoutContent:
    '将当前视频顺序保存到该预约会议，可供后续会议使用，确定保存？',
  replaceGalleryLayoutContent:
    '该预约会议已有一份旧的视频顺序，是否替换并保存为新的视频顺序？',
  loadGalleryLayoutTitle: '加载视频顺序',
  loadGalleryLayoutContent: '该预约会议已有一份视频顺序，是否加载？',
  load: '加载',
  noLoadGalleryLayout: '暂无可加载的视频顺序',
  loadSuccess: '加载成功',
  loadFail: '加载失败',
  // sip外呼
  sipCallByNumber: '拨号入会',
  sipCall: '呼叫',
  sipContacts: '会议通讯录',
  sipNumberPlaceholder: '请输入手机号',
  sipName: '受邀者名称',
  sipNamePlaceholder: '名字将会在会议中展示',
  sipCallNumber: '拨出号码',
  sipNumberError: '请输入正确的手机号',
  sipCallIsCalling: '该号码已在呼叫中',
  sipLocalContacts: '本地通讯录',
  sipContactsClear: '清空',
  sipCalling: '呼叫中...',
  sipCallTerm: '挂断',
  sipCallOthers: '呼叫其他成员',
  sipCallFailed: '呼叫失败',
  sipCallAgain: '重新拨打',
  sipSearch: '搜索',
  sipSearchContacts: '搜索并添加参会人',
  sipCallPhone: '电话呼叫',
  participantNotJoined: '未入会',
  participantJoining: '正在加入中...',
  sipCallCancel: '取消呼叫',
  sipCallAgainEx: '再次呼叫',
  sipCallStatusRejected: '已拒接',
  sipCallStatusCanceled: '呼叫已取消',
  sipCallStatusError: '呼叫异常',
  sipCallStatusCalling: '电话呼叫中',
  sipCallStatusWaiting: '等待呼叫中',
  sipCallStatusTermed: '已挂断',
  sipCallStatusUnaccepted: '未接听',
  sipPhoneNumber: '电话号码',
  sipCallMemberSelected: '已选：{{selectedCount}}',
  sipContactsPrivacy: '请授权访问您的通讯录，用于呼叫联系人以电话方式入会',
  sipContactNoNumber: '该成员无电话信息，暂不支持选择',
  sipCallIsInMeeting: '该成员已在会议中',
  sipCallIsInInviting: '该成员正在呼叫中',
  sipCallIsInBlacklist:
    '该成员已被标记不允许再次加入，如需邀请，请关闭会议黑名单',
  sipCallByPhone: '电话呼叫',
  sipKeypad: '拨号',
  sipBatchCall: '批量呼叫',
  sipCallMaxCount: '单次最多选择{{count}}人',
  sipInviteInfo: '邀请信息',
  sipAddressInvite: '通讯录邀请',
  sipJoinOtherMeetingTip: '加入后将离开当前会议',
  callStatusWaitingJoin: '待入会',
  globalReject: '拒绝',
  // todo
  readyPlayOthersAudioAndVideo: '即将开始播放其他成员的音视频',
  readyPlayOthersVideo: '即将开始播放其他成员的视频',
  readyPlayOthersShare: '即将开始播放其他成员的共享画面',
  unsupportedSwitchCamera: '该设备暂不支持切换摄像头',
  // 访客入会
  meetingGuestJoin: '访客入会',
  meetingGuestJoinEnableTip: '开启后允许外部人员参会',
  meetingGuestJoinSecurityNotice: '已开启访客入会，请注意会议信息安全',
  meetingGuestJoinEnabled: '访客入会已开启',
  meetingGuestJoinDisabled: '访客入会已关闭',
  meetingGuestJoinConfirm: '确认开启访客入会？',
  meetingGuestJoinConfirmTip: '开启后允许外部人员参会',
  meetingGuestJoinSupported: '该会议支持外部访客入会',
  meetingGuestJoinAuthTitle: '访客身份验证',
  meetingGuestJoinAuthTip: '为保障会议安全，请输入手机号进行身份验证',
  meetingGuestJoinNamePlaceholder: '请输入入会昵称',
  meetingGuestJoinName: '入会昵称',
  meetingRoleGuest: '外部访客',

  meetingOpen: '展开',
  meetingClose: '收起',
  meetingAttendeeCount: '{{count}}人',

  // 同声传译

  globalUpdate: '更新',
  globalLang: '语言',
  globalView: '查看',
  interpretation: '同声传译',
  interpInterpreter: '译员',
  interpSelectInterpreter: '选择译员',
  interpInfoIncompleteTitle: '译员信息不完整',
  interpInterpreterAlreadyExists: '用户已被选为译员，无法重复选择',
  interpInfoIncompleteMsg: '退出将删除信息不完整的译员',
  interpStart: '开始同声传译',
  interpStartNotification: '主持人已开启同声传译',
  interpStop: '关闭同声传译',
  interpStopNotification: '主持人已关闭同声传译',
  interpConfirmStopMsg: '关闭同声传译将关闭所有收听的频道，是否关闭？',
  interpConfirmUpdateMsg: '是否更新？',
  interpConfirmCancelEditMsg: '确定取消同声传译设置吗？',
  interpSelectListenLanguage: '请选择收听语言',
  interpSelectLanguage: '选择语言',
  interpAddLanguage: '添加语言',
  interpInputLanguage: '输入语言',
  interpLanguageAlreadyExists: '语言已存在',
  interpListenMajorAudioMeanwhile: '同时收听原声',
  interpManagement: '管理同声传译',
  interpSettings: '设置同声传译',
  interpMajorAudio: '原声',
  interpMajorChannel: '主频道',
  interpMajorAudioVolume: '原声音量',
  interpAddInterperter: '添加译员',
  interpJoinChannelErrorMsg: '加入传译频道失败，是否重新加入？',
  interpReJoinChannel: '重新加入',
  interpAssignInterpreter: '您已成为本场会议的同传译员',
  interpAssignLanguage: '当前语言',
  interpSpeakerTip: '您正在收听{{language1}}，说{{language2}}',
  interpOutputLanguage: '传译语言',
  interpRemoveInterpreterOnly: '仅删除译员',
  interpRemoveInterpreterInMembers: '同时从参会人中删除',
  interpRemoveMemberInInterpreters:
    '该参会人同时被指派为译员，删除参会者将会同时取消译员指派',
  interpSettingTip: '您可以在“同声传译”中设置收听语言与传译语言',
  interpUnassignInterpreter: '您已被主持人从同传译员中移除',
  interpLanguageRemoved: '主持人已删除收听语言“{{language}}”',
  interpInterpreterOffline:
    '当前收听的频道中，译员已全部离开，是否为您切换回原声？',
  interpDontSwitch: '暂不切换',
  interpSwitchToMajorAudio: '切回原声',
  interpAudioShareIsForbiddenDesktop:
    '作为译员，您共享屏幕时将无法同时共享电脑声音',
  interpInterpreterInMeetingStatusChanged: '译员参会状态已变更',
  interpListeningChannelDisconnect: '收听语言频道已断开，正在尝试重连',
  interpSpeakingChannelDisconnect: '传译语言频道已断开，正在尝试重连',
  langChinese: '中文',
  langEnglish: '英语',
  langJapanese: '日语',
  langKorean: '韩语',
  langFrench: '法语',
  langGerman: '德语',
  langSpanish: '西班牙语',
  langRussian: '俄语',
  langPortuguese: '葡萄牙语',
  langItalian: '意大利语',
  langTurkish: '土耳其语',
  langVietnamese: '越南语',
  langThai: '泰语',
  langIndonesian: '印尼语',
  langMalay: '马来语',
  langArabic: '阿拉伯语',
  langHindi: '印地语',
  // 批注
  annotation: '互动批注',
  annotationEnabled: '互动批注已开启',
  annotationDisabled: '互动批注已关闭',
  startAnnotation: '批注',
  stopAnnotation: '退出批注',
  inAnnotation: '正在批注中',
  saveAnnotation: '保存当前批注',
  // 登录优化
  authHowToGetCorpCode: '如何获取企业代码？',
  authGetCorpCodeFromAdmin: '可与企业管理员咨询您的企业代码',
  authIKnowCorpCode: '我知道企业代码',
  authIDontKnowCorpCode: '我不知道企业代码',
  authTypeAccountPwd: '账号密码',
  authLoginByAccountPwd: '账号密码登录',
  authLoginByMobilePwd: '手机号密码登录',
  authLoginByEmailPwd: '邮箱密码登录',
  authOtherLoginTypes: '其他登录方式',
  authSSONotSupport: '当前不支持SSO登录',
  IkonwIt: '我知道了',
  unSupportBrowserTitle: '浏览器不兼容',
  unSupportBrowserTip:
    '我们检测到您正在使用的浏览器不支持我们的服务。为了获得最佳体验，推荐使用以下浏览器',

  settingVoicePriorityDisplay: '语音激励',
  settingVoicePriorityDisplayTip: '开启后，将优先显示正在说话的参会成员',
  meetingMaxMembers: '最多参会人数',
  // 人数上限
  openWaitingRoom: '开启等候室',
  participantUpperLimitWaitingRoomTip: '当前会议已达人数上限，建议开启等候室。',
  participantUpperLimitReleaseSeatsTip:
    '当前会议已达到人数上限，新参会者将无法加入会议，您可以尝试移除未入会成员或释放会议中的一个席位。',
  participantUpperLimitTipAdmitOtherTip:
    '当前会议已达到人数上限，请先移除未入会成员或释放会议中的一个席位，然后再准入等候室成员。',
  meetingSearchNotFound: '暂无搜索结果',

  // 周期会议详情
  meetingRepeatDayInWeek: '每{{week}}周的{{day}}重复',
  meetingRepeatDay: '每{{day}}天重复',
  meetingRepeatDayInMonth: '每{{month}}个月的{{day}}重复',
  meetingRepeatDayInWeekInMonth: '每{{month}}个月的第{{week}}个{{weekday}}重复',
  // 权限
  noDevicePermissionTitle: '媒体设备访问受限',
  noDevicePermissionTipContent:
    '当前无系统麦克风/摄像头访问权限，请按以下操作重试：',
  noDevicePermissionTipStep1:
    '1.检查浏览器设置，确保已允许访问麦克风和摄像头；如未解决，请继续下一步。',
  noDevicePermissionTipStep2: '2.关闭并重新打开会议，并赋予相关权限。',

  // 字幕
  transcriptionEnableCaption: '开启字幕',
  transcriptionEnableCaptionHint: '当前字幕仅自己可见',
  transcriptionDisableCaption: '关闭字幕',
  transcriptionDisableCaptionHint: '您已关闭字幕',
  transcriptionCaptionLoading: '正在开启字幕，机器识别仅供参考...',
  transcriptionDisclaimer: '机器识别仅供参考',
  transcriptionCaptionSettingsHint: '点击进入字幕设置',

  transcriptionAllowEnableCaption: '使用字幕功能',
  transcriptionCanNotEnableCaption: '字幕功能当前不可用，请联系主持人或管理员',
  transcriptionCaptionForbidden: '主持人不允许成员使用字幕，已关闭字幕',
  transcriptionCaptionFontSize: '字号',
  transcriptionCaptionSmall: '小',
  transcriptionCaptionBig: '大',
  transcriptionCaptionAndTranslate: '字幕和翻译',
  transcriptionCaptionSettings: '字幕设置',
  transcriptionEnableCaptionOnJoin: '加入会议时开启字幕',
  transcriptionCaptionTypeSize: '字号大小',
  transcriptionCaptionExampleSize: '字幕文字大小示例',
  // 转写
  transcription: '实时转写',
  transcriptionStart: '开启转写',
  transcriptionStop: '停止转写',
  transcriptionStartConfirmMsg: '是否开启实时转写？',
  transcriptionStartedNotificationMsg:
    '主持人已开启实时转写，所有成员可查看转写内容',
  transcriptionRunning: '转写中',
  transcriptionStartedTip: '主持人已开启实时转写',
  transcriptionStoppedTip: '主持人已关闭实时转写',
  transcriptionNotStarted: '暂未开启实时转写，请联系主持人开启转写',
  transcriptionGenerating: '转写生成中',
  transcriptionTiming: '发起转写时间',
  transcriptionExportFile: '导出此转写文件',
  transcriptionStopFailed: '关闭字幕失败',
  transcriptionStartFailed: '开启字幕失败',
  transcriptionTargetLang: '目标翻译语言',
  transcriptionShowBilingual: '同时显示双语',
  transcriptionNotTranslated: '不翻译',
  transcriptionTranslationSettings: '翻译设置',
  transcriptionCaptionShowBilingual: '字幕同时显示双语',
  transcriptionSettingShowBilingual: '转写同时显示双语',
  transcriptionTranslationSettingsTip:
    '对会中字幕和转写生效，翻译内容仅自己可见',
  transcriptionCaptionNotAvailableInSubChannel:
    '当前未收听原声，字幕暂不可用，如需使用请收听原声',

  globalFileSaveAs: '导出为',
  globalFileTypePDF: 'PDF',
  globalFileTypeWord: 'Word',
  globalFileTypeTxt: '纯文本',
  // 设置录制
  record: '录制',
  recordSetting: '录制设置',
  autoRecord: '自动录制',
  meetingCloudRecord: '自动云录制',
  meetingEnableCouldRecordWhenHostJoin: '主持人入会后开启',
  meetingEnableCouldRecordWhenMemberJoin: '成员入会后开启',
  // 新聊天室
  copy: '复制',
  recall: '撤回',
  historyMessage: '以上为历史消息',
  deleteChatroomMsg: '撤回了一条消息',
  fetchHistoryMessages: '查看更多消息',
  noMoreHistory: '暂无历史消息',
  exportChatHistory: '导出聊天记录',
  exportThisChatHistory: '导出此次聊天记录',
  noChatHistory: '无聊天记录',
  exportChatHistoryLoadingTitle: '聊天记录导出',
  exportChatHistoryLoadingContent: '聊天记录有点多，正在生成中，请稍后',
  exportChatHistoryLoadingBtn: '后台生成',
  imageSizeLimit: '图片大小不能超过20MB',
  imageTypeNotSupport: '图片格式暂不支持',
  fileSizeLimit: '文件大小不能超过200MB',
  cancelSend: '取消发送',
  cancelDownload: '取消下载',
  canceledSuccess: '取消成功',
  inputPlaceholder: '请输入信息，并按enter键发送',
  messageEmpty: '消息不能为空',
  newMsg: '新消息',
  fileNotExist: '文件不存在',
  fileNotExistReDownload: '文件不存在，重新下载',
  meetingSaySomeThing: '说点什么…',
  meetingKeepSilence: '当前禁言中',
  settingChatMessageNotification: '新聊天消息提醒',
  settingChatMessageNotificationBarrage: '弹幕',
  settingChatMessageNotificationBubble: '气泡',
  settingChatMessageNotificationNoReminder: '不提醒',
  send: '发送', //通用

  sharingStopByHost: '主持人已终止了你的共享',
  backSharingView: '返回共享内容',
  screenSharingViewUserLabel: '的屏幕共享',
  whiteBoardSharingViewUserLabel: '的白板共享',

  usingComputerAudioInMeeting: '入会时自动使用电脑音频',
  connectAudioTitle: '请选择会议音频的连接方式',
  usingComputerAudioTips:
    '小型会议可直接使用“电脑音频”，以此作为您的会议音频接入方式。',
  usingComputerAudio: '使用电脑音频',
  secondaryConfirmTitle: '请使用音频接入',
  secondaryConfirmContent: '未接入音频，您与其他成员将无法听见彼此的声音。',
  secondaryConfirmOk: '选择电脑音频',
  secondaryConfirmCancel: '继续',

  meetingCrossAppNoPermission:
    '很抱歉，您尝试加入的会议暂未对外部人员开放。如有需要，请联系会议组织者开启访客入会权限。',
  meetingCrossAppJoinTip:
    '该会议由其他团队/组织创建，您将以访客身份加入，是否加入会议？',
  computerSoundOnly: '仅电脑音频',
  sharingComputerSound: '您正在共享电脑音频',

  settingShowName: '始终在视频中显示参会者名字',

  windowSizeWhenSharingTheScreen: '共享屏幕时的窗口大小',
  sideBySideMode: '并排模式',
  sideBySideModeTips:
    '查看其他用户共享屏幕时自动将参会者视频放置在共享屏幕右侧',
  whenIShareMyScreenInMeeting: '当我在会议中共享屏幕时',
  showAllSharingOptions: '显示所有共享选项',
  automaticDesktopSharing: '自动桌面共享',
  automaticDesktopSharingTips: '当你有多个显示器，系统将自动共享你的主桌面',
  onlyShowTheEntireScreen: '仅显示整个屏幕',
  sharedLimitFrameRate: '将你的屏幕共享限制为',
  sharedLimitFrameRateTips:
    '开启后，屏幕共享帧率将不超过设置值。共享视频时推荐使用高帧率可提升观看视频流畅性，其他场景推荐使用低帧率降低CPU消耗',
  sharedLimitFrameRateUnit: '帧/秒',
  preferMotionModel: '视频流畅度优先',
  preferMotionModelTips: '减少性能和带宽占用，优先保障共享流畅度',

  ethernet: '有线',
  wifi: 'Wi-Fi',
}
