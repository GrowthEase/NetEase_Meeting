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
  appName: '网易会议', // 顶部UI展示
  joinMeeting: `加入会议`, // 入会时密码弹窗输入文本
  leaveMeeting: `离开会议`, // 离开会议二次确认弹窗菜单按钮文本
  quitMeeting: `结束会议`, // “结束会议”二次确认弹窗菜单按钮文本
  finish: '结束会议', // 结束会议菜单按钮文本
  leave: '离开会议', // 离开会议菜单按钮文本
  hostExitTips: `您确定要离开这个${meeting}吗？`, // 结束会议二次确认弹窗消息
  leaveTips: `您确定要离开这个${meeting}吗？`, // 离开会议二次确认弹窗消息
  changePresenterTips: `是否移交主持人权限？`,
  networkUnavailableCloseFail: `网络异常，结束${meeting}失败`, //  结束会议失败提示
  cancel: '取消', //通用
  beauty: `美颜`, // 美颜功能名称
  beautyLevel: `美颜等级`, // 美颜等级
  joiningTips: `正在进入${meeting}...`, // 加入会议Loading提示信息
  close: `关闭`, // 通用
  open: `打开`, // 通用
  networkUnavailable: `网络连接失败，请稍后重试！`, // 通用网络连接失败提示1
  networkUnavailableCheck: `网络连接失败，请检查你的网络连接！`, // 通用网络连接失败提示2
  memberListTitle: `${attendee}`, // 会议成员列表标题
  joinMeetingFail: `加入${meeting}失败`, //  加入会议失败提示
  reJoinMeetingFail: `重新加入${meeting}失败`, // 重试加入会议失败提示
  youBecomeTheHost: `您已经成为${host}`, // 被移交主持人的提示
  youBecomeTheCoHost: `您已经成为${coHost}`, // 被移交主持人的提示
  becomeTheCoHost: `已经成为${coHost}`, // 被移交主持人的提示
  looseTheCoHost: `已被取消设为${coHost}`, // 被取消焦点视频提示
  getVideoFocus: '您已被设置为焦点视频', // 被设置为焦点视频提示
  looseVideoFocus: '您已被取消焦点视频', // 被取消焦点视频提示
  muteAudioAll: '全体静音', // 全体静音功能
  muteAudioAllDialogTips: '所有以及新加入成员将被静音', // 全体静音弹窗标题
  muteAllAudioTip: `允许${attendee}自行解除静音`, // 操作全体静音弹窗可选项
  muteAllAudioSuccess: '您已进行全体静音', //主持人端全体静音成功提示消息
  meetingHostMuteAllAudio: `${host}设置了全体静音`, //全体静音时成员端提示消息
  muteAllAudioFail: '全体静音失败', //全体静音失败提示消息
  unMuteAudioAll: '解除全体静音', //解除全体静音功能
  unMuteAllAudioSuccess: '您已请求解除全体静音', //解除全体静音成功提示消息
  unMuteAllAudioFail: '解除全体静音失败', //解除全体静音失败提示消息
  leaveByHost: `您已被${host}移出会议`,
  leaveBySelf: `您已在其他设备登录`,

  muteVideoAll: '全体关闭视频',
  muteVideoAllDialogTips: '所有以及新加入成员将被关闭视频',
  muteAllVideoTip: `允许${attendee}自行开启视频`,
  muteAllVideoSuccess: '您已进行全体关闭视频',
  meetingHostMuteAllVideo: `${host}设置了全体关闭视频`,
  muteAllVideoFail: '全体关闭视频失败',
  unMuteVideoAll: '开启全体视频',
  unMuteAllVideoSuccess: '您已请求开启全体视频',
  unMuteAllVideoFail: '开启全体视频失败',
  muteVideoAndAudio: '关闭音视频',
  unmuteVideoAndAudio: '开启音视频',
  hostAgreeVideoHandsUp: `${host}已将您开启视频`,

  muteAudio: '静音', //主持人操作成员静音功能菜单
  unMuteAudio: '解除静音', //主持人操作成员解除静音功能菜单
  muteVideo: '停止视频', //主持人操作成员停止视频功能菜单
  unMuteVideo: '开启视频', // 主持人操作成员开启视频功能菜单
  unScreenShare: '结束共享', // 主持人操作成员结束共享功能菜单
  hostStopShare: `${host}已终止了您的共享`, //主持人终止共享提示
  focusVideo: '设为焦点视频', //主持人操作成员设置焦点视频菜单项
  unFocusVideo: '取消焦点视频', //主持人操作成员取消焦点视频菜单项
  handOverHost: `移交${host}`, //主持人操作成员移交主持人菜单项
  handSetCoHost: `设为${coHost}`, // 主持人操作设置联席主持人
  handUnSetCoHost: `取消设为${coHost}`, // 主持人操作取消联席主持人
  handOverHostTips: `确认将${host}移交给`, //移交主持人确认弹窗消息
  removeMember: '移除', //主持人操作成员移除成员菜单项
  removeMemberTips: '确认移除', //移除成员确认弹窗消息
  yes: '是', //弹窗通用确认按钮文本静音
  no: '否', //弹窗通用否定按钮文本
  cannotRemoveSelf: '不能移除自己', // 不能移除自己提示消息
  muteAudioFail: '静音失败', //静音失败提示
  unMuteAudioFail: '解除静音失败', //解除静音失败提示
  muteVideoFail: '停止视频失败', //停止视频失败提示
  unMuteVideoFail: '开启视频失败', //开启视频失败提示
  focusVideoFail: '设为焦点视频失败', //设为焦点视频失败提示
  unFocusVideoFail: '取消焦点视频失败', //取消焦点视频失败提示
  putMemberHandsDownFail: '放下成员举手失败', //放下成员举手失败提示
  handOverHostFail: `移交${host}失败`, //移交主持人失败提示
  removeMemberSuccess: '移除成功', //移除成员成功提示
  removeMemberFail: '移除失败', //移除成员失败提示
  save: '保存', //通用功能按钮
  done: '完成', //通用功能按钮
  notify: '通知', //弹窗通用标题
  hostKickedYou: `因被${host}移出或切换至其他设备，您已退出${meeting}`, //从会议中被移除提示
  sure: '确定', //通用
  // forbiddenByHostVideo: `${host}已将您停止视频`, //本地重新打开摄像头失败，原因为被主持人禁用
  openCamera: '打开摄像头', //主持人申请打开成员视频弹窗标题
  hostOpenCameraTips: `${host}已重新打开您的摄像头，确认打开？`, //主持人申请打开成员视频弹窗消息
  openMicro: '打开麦克风', //主持人申请打开成员音频弹窗标题
  hostOpenMicroTips: `${host}已重新打开您的麦克风，确认打开？`, //主持人申请打开成员音频弹窗消息
  meetingHostMuteVideo: '您已被停止视频', //主持人关闭成员视频提示消息
  meetingHostMuteAudio: '您已被静音', //主持人关闭成员音频提示消息
  screenShare: '共享屏幕', //共享屏幕功能菜单文本
  screenShareTips: '将开始截取您的屏幕上显示的所有内容。', //屏幕共享弹窗消息
  shareOverLimit: '已有人在共享，您无法共享', //超出共享人数限制提示消息
  screenShareStartFail: '发起共享屏幕失败', // 屏幕共享失败提示
  hasWhiteBoardShare: '共享白板时暂不支持屏幕共享',
  hasScreenShareShare: '屏幕共享时暂不支持白板共享',
  screenShareStopFail: '关闭共享屏幕失败', //屏幕共享失败提示
  whiteBoard: '共享白板', //共享白板功能菜单
  closeWhiteBoard: '退出白板', //退出白板功能菜单
  whiteBoardShareStopFail: '停止共享白板失败',
  whiteBoardShareStartFail: '发起白板共享失败',
  screenShareLocalTips: '正在共享屏幕', //共享端“正在共享屏幕”提示
  screenShareSuffix: '的共享屏幕', //共享端画面名称后缀
  screenShareInteractionTip: '双指分开放大画面', // 操作共享屏幕的画面提示
  whiteBoardInteractionTip: '您被授予白板互动权限',
  undoWhiteBoardInteractionTip: '您被取消白板互动权限',
  speakingPrefix: '正在讲话: ', //成员正在讲话前缀，后面会拼接用户昵称
  screenShareModeForbiddenOp: '共享屏幕时不能开启/停止视频', //共享屏幕时操作打开/关闭摄像头失败提示
  me: '我',
  audioStateError: '当前音频被其他应用占用，请关闭后重试', //打开音频设备失败提示
  lockMeeting: `锁定${meeting}`, //锁定会议功能
  lockMeetingByHost: `${meeting}已锁定，新${attendee}将无法加入${meeting}`, //锁定会议成功主持人端提示消息
  lockMeetingByHostFail: `${meeting}锁定失败`, //锁定失败提示
  unLockMeetingByHost: `${meeting}已解锁，新${attendee}将可以加入${meeting}`, //解锁会议成功主持人端提示
  unLockMeetingByHostFail: `${meeting}解锁失败`, //解锁会议失败提示
  // 聊天室相关
  // send: '发送', //通用
  // inputMessageHint: '输入消息...', //聊天室输入框hint
  // newMessage: '新消息', //新消息提示
  // chatRoomMessageSendFail: '聊天室消息发送失败', // 聊天室消息发送失败提示
  // cannotSendBlankLetter: '不支持发送空格', //聊天室消息发送失败提示
  chat: '聊天', //聊天功能菜单文本
  // more: '更多', //更多功能菜单文本
  // searchMember: '搜索成员', //成员搜索输入框提示文本
  // enterChatRoomFail: '聊天室进入失败!', //聊天室初始化失败提示
  meetingPassword: `${meeting}密码`, //会议密码弹窗标题
  inputMeetingPassword: `请输入${meeting}密码`, // 会议密码弹窗输入框提示
  wrongPassword: '密码错误', // 会议密码验证失败提示
  headsetState: '您正在使用耳机',
  meetingId: `${meeting}ID`, // 会议ID
  shortMeetingId: `${meeting}短号`, // 会议短号
  copy: '复制邀请', //复制菜单文本
  copyLink: '复制',
  meetingUrl: '入会链接',
  copySuccess: '复制成功', //复制成功提示消息
  defaultMeetingInfoTitle: `邀请您参加会议`, //会议信息标题
  meetingInfoDesc: `${meeting}正在加密保护中`, //会议描述文本
  muteAllAudioHandsUpTips: `${host}已将全体静音，您可以举手申请发言`, //全体静音时打开音频弹窗提示消息
  muteAllVideoHandsUpTips: `${host}已将全体关闭视频，您可以举手申请发言`, //全体关闭视频时打开音频弹窗提示消息
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
  undoWhiteBoardInteract: '撤回白板互动', //主持人操作成员撤回白板功能菜单
  undoWhiteBoardInteractFail: '撤回白板互动失败', //主持人操作成员撤回白板失败提示
  sip: 'SIP电话/终端入会',
  sipTip: 'sip',
  // 直播相关
  live: '直播', //直播功能
  liveUrl: '直播观看地址', //直播功能
  liveLink: '直播链接',
  enableLivePassword: '开启直播密码',
  enableChat: '开启观众互动',
  enableChatTip: '开启后，会议室和直播间消息相互可见',
  liveView: '直播画面（用户开启视频后可出现在列表中）',
  livePreview: '直播画面预览',
  liveSelectTip: '请从左侧选择直播画面',
  livePasswordTip: '请输入6位数字密码',
  liveStatusChange: '直播状态发生变化',
  refreshLiveLayout: '刷新直播布局',
  liveUpdateSetting: '更新直播设置',
  pleaseClick: '请点击',
  onlyEmployeesAllow: '仅本企业员工可观看',
  onlyEmployeesAllowTip: '开启后，非本企业员工无法观看直播',
  living: '直播进行中',
  memberNotInMeeting: `成员不在${meeting}中`,
  cannotSubscribeSelfAudio: '不能订阅自己的音频',
  partMemberNotInMeeting: `部分成员不在${meeting}中`,
  //补充
  commonTitle: '提示', // 通用二次提示title
  inviteBtn: '邀请', // 邀请按钮
  sipBtn: 'sip', // 邀请按钮
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
  closeWhiteShareTips: '的白板共享吗？', // 白板共享二次提示
  closeScreenShareTips: '的屏幕共享吗？', // 屏幕共享二次提示
  galleryBtn: '视图布局', // 视图布局按钮
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
  liveStopFail: '直播停止失败,请稍后重试',
  liveStopSuccess: '直播停止成功',
  livePassword: '直播密码',
  liveSubjectTip: '直播主题不能为空',
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
  speaking: '正在说话',
  notJoinedMeeting: '成员尚未加入',
  disconnected: '网络已断开，正在尝试重新连接…',
  unmute: '暂时取消静音',
  searchName: '输入姓名进行搜索',
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
  internalOnly: '仅对内',
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
  answeringPhone: '正在接听系统电话',
  chatRoomTitle: '消息',
  audioSetting: '音频选项',
  videoSetting: '视频选项',
  imageMsg: '[图片]',
  fileMsg: '[文件]',
  internal: '内部专用',
  openVideoDisable: '您已被停止视频',
  endMeetingTip: '距离会议关闭仅剩',
  min: '分钟',
  networkAbnormalityAndCheck: '网络异常，请检查您的网络',
  networkAbnormality: '网络异常',
  networkDisconnected: '网络已断开，请检查您的网络情况，或尝试重新入会',
  rejoin: '重新入会',
}
