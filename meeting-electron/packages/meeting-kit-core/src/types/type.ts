import {
  Roomkit,
  NERoomLiveState,
  NERoomMemberInviteState,
  NERoomMemberInviteType,
  NECustomSessionMessage,
  NERtcEx,
  NERoomWhiteboardAppConfig,
} from 'neroom-types'

import NEMeetingService from '../services/NEMeeting'
import {
  LayoutTypeEnum,
  LiveBackgroundInfo,
  MeetingSetting,
  NEChatPermission,
  NECloudRecordConfig,
  NEWaitingRoomChatPermission,
  RecordState,
  LocalRecordState,
  SearchAccountInfo,
  ServerError,
  WatermarkInfo,
} from './innerType'
import NEMeetingInviteService from '../services/NEMeetingInviteService'
import { IM } from './NEMeetingKit'
import {
  NECheckableMenuItem,
  NEMeetingMenuItem,
  NEMenuVisibility,
  NESingleStateMenuItem,
} from '../kit/interface/service/meeting_service'
import { NEChatMessageNotificationType } from '../kit/interface'

export interface NEMember {
  /**
   * 音频是否连接
   */
  isAudioConnected: boolean
  /**
   * 音频是否打开
   */
  isAudioOn: boolean
  /**
   * 当前成员是否在聊天室内
   */
  isInChatroom: boolean
  /**
   * 当前成员是否在RTC房间内
   */
  isInRtcChannel: boolean
  /**
   * 当前成员是否正在屏幕共享中
   */
  isSharingScreen: boolean
  /**
   * 当前成员是否正在屏幕共享中
   */
  isSharingSystemAudio: boolean
  /**
   * 是否是屏幕共享的视图
   */
  isSharingScreenView: boolean
  /**
   * 视频是否打开
   */
  isVideoOn: boolean
  /**
   * 当前成员是否正在共享白板
   */
  isSharingWhiteboard: boolean
  /**
   * 当前成员是否正在共享白板
   */
  isSharingWhiteboardView: boolean
  /**
   * 当前成员是否正在本地录制
   */
  isLocalRecording: boolean
  /**
   * 当前成员是否有本地录制权限
   */
  localRecordAvailable: boolean
  /**
   * 用户名
   */
  name: string
  /**
   * 属性
   */
  properties: {
    wbDrawable?: { value: '1' | '0' }
    /** 当前成员是否在系统通过状态 */
    phoneState?: { value: '1' | '0' }
    /** 当前成员标签 */
    tag?: { value: string }
    [key: string]: NEProps
  }
  /**
   * 角色
   */
  role: Role
  /**
   * 用户id
   */
  uuid: string
  /**
   * 用户的终端类型[NEClientType]
   */
  clientType: NEClientType
  /**
   * 当前成员邀请状态
   */
  inviteState: NEMeetingInviteStatus | NERoomMemberInviteState
  inviteType?: NERoomMemberInviteType
  /**
   * @ignore 不对外暴露
   */
  rtcUid?: number
  isHandsUp?: boolean
  /**
   * @ignore 不对外暴露
   */
  hide?: boolean
  volume?: number
  avatar?: string
}

export type NEError = ServerError | Error

export enum NEClientInnerType {
  WEB = 'web',
  ANDROID = 'android',
  IOS = 'ios',
  PC = 'pc',
  MINIAPP = 'miniApp',
  MAC = 'mac',
  SIP = 'SIP',
  UNKNOWN = 'unknown',
}

export enum NEClientReportType {
  WEB = 'Web',
  PC = 'Windows',
  MINIAPP = 'miniApp',
  MAC = 'macOS',
  LINUX = 'linux',
  UNKNOWN = 'unknown',
}

export enum NEClientType {
  UNKNOWN,
  IOS,
  ANDROID,
  PC,
  WEB,
  SIP,
  MAC,
  MINIAPP,
  H323,
  LINUX,
}
export enum NEMeetingRole {
  /** 参会者 */
  participant = 'member',
  /** 主持人 */
  host = 'host',
  /** 联席主持人 */
  coHost = 'cohost',
  /** 影子用户 */
  ghost = 'ghost',
}

export enum AttendeeOffType {
  /** 打开全体关闭视频, 允许自行打开 */
  offNotAllowSelfOn = 'offNotAllowSelfOn',
  /** 打开全体关闭视频，不允许自行打开 */
  offAllowSelfOn = 'offAllowSelfOn',
  /** 关闭全体关闭视频 */
  disable = 'disable',
}

export type MembersMap = Map<string, NEMember>
// 存储外部用户配置，非sdk获取到的会议信息
export interface NEMeetingInfo extends NEMeetingSDKInfo {
  /** 主画面，实际画面长宽非画布长宽 */
  mainVideoSize: {
    width: number
    height: number
  }
  /** 是否根据声音大小进行排序 */
  enableSortByVoice?: boolean
  layout: LayoutTypeEnum
  speakerLayoutPlacement: 'top' | 'right'
  /** 配置是否开启透明白板 */
  enableTransparentWhiteboard?: boolean
  /** 当前房间属性是否是透明白板 */
  isWhiteboardTransparent?: boolean
  /**
   * 是否能够通过长按空格解除静音
   */
  enableUnmuteBySpace?: boolean
  /**
   *  是否共享电脑音频
   */
  startSystemAudioLoopbackCapture?: boolean
  chatroomConfig?: {
    /**
     * 聊天室是否开启文件上传
     */
    enableFileMessage?: boolean
    /**
     * 聊天室是否开启图片上传
     */
    enableImageMessage?: boolean
  }
  /**
   * 是否显示说话者列表
   */
  showSpeaker?: boolean
  /**
   * 是否显示会议剩余时间提醒
   */
  showMeetingRemainingTip?: boolean
  /** 主画面渲染方式：小画面布局还是大画面布局（小布局适用于面试间） */
  renderModel?: 'small' | 'big'
  /** 聊天室未读消息数量 */
  unReadChatroomMsgCount?: number
  /** 是否隐藏控制栏 */
  hiddenControlBar?: boolean
  /**
   * 控制栏按钮配置
   */
  toolBarList: ToolBarList
  /**
   * 更多按钮配置
   */
  moreBarList: MoreBarList
  /**
   * 成员列名会控菜单
   */
  memberActionMenuItems: Array<
    NEMeetingMenuItem | NESingleStateMenuItem | NECheckableMenuItem
  >
  /**
   * 成员自定义标签
   */
  memberTag?: string
  /**
   * 当前使用环境Electron或者web
   */
  env?: 'electron' | 'web'
  /**
   * 是否显示成员tag，默认关闭
   */
  showMemberTag?: boolean
  /**
   * 是否显示成员列表顶部的房间最大成员数量
   */
  showMaxCount?: boolean
  /**
   * 是否始终固定任务栏 默认固定
   */
  enableFixedToolbar?: boolean
  /**
   * 是否开启本端镜像 默认为true 镜像
   */
  enableVideoMirror?: boolean
  /**
   * 画廊模式下，最大画面数量
   */
  galleryModeMaxCount?: number
  /**
   * 本地画面排序
   */
  localViewOrder?: string
  /**
   * 是否显示会议持续时间，默认为false 不显示
   */
  showDurationTime?: boolean
  /**
   * 设置项
   */
  setting: MeetingSetting
  /**
   * 最后一个说话者
   */
  lastActiveSpeakerUuid?: string
  /**
   *  是否是Rooms应用
   */
  isRooms?: boolean
  /**
   * 右侧菜单
   */

  /** 是否开启字幕 */
  isCaptionsEnabled?: boolean
  /**
   * 鼠标是否hover到字幕上
   */
  isMouseOverCaption?: boolean
  /** 开启字幕loading */
  enableCaptionLoading?: boolean
  /**
   * 用于字幕5s没有说话超时隐藏1
   */
  canShowCaption?: boolean
  rightDrawerTabs: {
    key: string
    isPlugin?: boolean
    label?: string
  }[]
  rightDrawerTabActiveKey?: string
  // plugin Query string
  pluginUrlSearch?: string
  /**
   * 通知消息列表
   */
  notificationMessages: Array<
    NECustomSessionMessage & {
      /** 是否已读 */
      unRead: boolean
      /** 是否已经弹出通知 */
      beNotified: boolean
      /** 是否在通知中心展示 */
      noShowInNotificationCenter: boolean
    }
  >
  // 点击成员列表内部tab
  activeMemberManageTab: 'waitingRoom' | 'room' | 'invite'
  /**
   * 开发模式，展示分辨率
   */
  isDebugMode?: boolean
  /**
   * 直播背景图相关信息
   */
  liveBackgroundInfo?: LiveBackgroundInfo
  /**
   * 成员列表底部按钮配置
   * @ignore
   */
  muteBtnConfig?: {
    /**
     * 显示全体关闭视频按钮
     */
    showMuteAllVideo: boolean
    /**
     * 显示全体开启按钮
     */
    showUnMuteAllVideo: boolean
    /**
     * 显示全体静音按钮
     */
    showMuteAllAudio: boolean
    /**
     * 显示全体解除静音按钮
     */
    showUnMuteAllAudio: boolean
  }
  /**
   * 是否显示设置焦点后画面右上角的按钮， 默认为true
   * @ignore
   */
  showFocusBtn?: boolean
  /**
   * 是否开启会中改名，默认为false（开启）
   * @ignore
   */
  noRename?: boolean
  /**
   * 水印内容
   */
  watermarkConfig?: NEWatermarkConfig
  /**
   * 固定视频
   */
  pinVideoUuid?: string
  /**
   * 私聊对象
   */
  privateChatMemberId?: string
  /** 配置会议中是否展示通知中心菜单，默认展示。 */
  noNotifyCenter?: boolean
  /** 配置会议中是否展示 web 小应用，如签到应用。 默认会拉取小应用列表并展示。 */
  noWebApps?: boolean

  /**
   * 是否本端开启同声传译，用于toast提示
   */
  openInterpretationBySelf?: boolean

  /**
   * 同传收听语言被移除弹窗通知信息
   */
  showLanguageRemovedInfo?: {
    show: boolean
    language: string
  }

  detectMutedMic?: boolean

  /** 当前是否开始屏幕共享批注绘制 */
  annotationDrawEnabled?: boolean

  /** 加入离开会议是否播放提示音*/
  playSound?: boolean

  /** 隐藏头像*/
  avatarHide?: boolean

  /** 表情回应 */
  emoticons?: Record<
    string,
    {
      emojiKey: string
      time: number
    }
  >

  /** 结束会议操作：0:未打开 1:右下角 2:居中 3:关闭按钮 */
  endMeetingAction?: number

  /** 观看屏幕共享的比例 */
  screenZoom?: number

  /** 会议双屏模式模式 */
  dualMonitors?: boolean

  /** 第二显示器的用户  */
  secondMonitorMember?: NEMember

  /** 第二显示器的是否是全屏 */
  secondMonitorFullScreen?: boolean

  /** 是否是暗黑模式 */
  isDarkMode?: boolean
  isOtherLocalRecordingConfirmed?: boolean
  isOtherCloudRecordingStartConfirmed?: boolean
  isOtherCloudRecordingStopConfirmed?: boolean

  /** 白板配置 */
  whiteBoradAddDocConfig?: AddDocConfig[]
  /**
   * 是否开启白板的云录制
   */
  whiteboardCloudRecord?: boolean
  /**
   * 是否开启白板容器的宽高比
   */
  whiteBoradContainerAspectRatio?: AspectRatio
}

export interface NEJoinMeetingParams {
  /**
   * 会议号
   */
  meetingNum: string

  /** 会议中的用户昵称，不能为空 */
  displayName: string
  /** 会议中的用户头像，可空 */
  avatar?: string
  /** 会议中的成员标签，自定义，最大长度1024 */
  tag?: string

  /** 会议密码 */
  password?: string

  /** 媒体流加密配置 */
  encryptionConfig?: NEEncryptionConfig

  /** 水印配置 */
  watermarkConfig: NEWatermarkConfig

}

export interface NEWatermarkConfig {
  name?: string
  phone?: string
  email?: string
  jobNumber?: string
}
export interface LocalRecordPermissionItem {
  host: boolean
  some: boolean
  all: boolean
}
export interface NEMeetingSDKInfo {
  localMember: NEMember
  myUuid: string
  hostUuid: string
  hostName: string
  screenUuid: string
  systemAudioUuid: string
  whiteboardUuid: string
  annotationEnabled: boolean
  focusUuid: string
  activeSpeakerUuid: string
  properties: Record<string, NEProps>
  password?: string
  isSupportChatroom: boolean
  subject: string
  startTime: number
  endTime: number
  type: number
  shortMeetingNum: string
  ownerUserUuid: string
  rtcStartTime: number
  roomArchiveId: string
  timezoneId?: string
  sipCid?: string
  meetingNum: string
  meetingInviteUrl: string
  meetingId?: number
  isUnMutedVideo?: boolean
  isUnMutedAudio?: boolean
  isScreenSharingMeeting?: boolean
  isWaitingRoomEnabled?: boolean
  isAllowParticipantsEnableCaption: boolean
  audioOff: AttendeeOffType
  videoOff: AttendeeOffType
  isLocked: boolean
  inWaitingRoom?: boolean
  /**
   * 远端画面排序
   */
  remoteViewOrder?: string
  /**
   * 是否是预约会议 0否 1 周期会议 2 预约会议
   */
  isScheduledMeeting?: number
  /**
   * 预约会议中保存的会议视图排序
   */
  scheduledMeetingViewOrder?: string
  liveConfig: {
    liveAddress: string
  }
  /** 2表示锁定，1解除锁定 */
  liveState?: NERoomLiveState
  /** 房间最大人数 */
  maxMembers?: number
  remainingSeconds?: number
  /**
   * 会议录制状态
   */
  isCloudRecording: boolean
  cloudRecordState?: RecordState
  watermark?: WatermarkInfo
  enableBlacklist?: boolean
  meetingChatPermission?: NEChatPermission
  waitingRoomChatPermission?: NEWaitingRoomChatPermission
  localRecordState?: LocalRecordState
  /**
   * 访客入会
   */
  enableGuestJoin?: boolean
  interpretation?: InterpretationRes
  isInterpreter?: boolean
  /**
   * 批注权限
   */
  annotationPermission?: boolean
  screenSharePermission?: boolean
  unmuteAudioBySelfPermission?: boolean
  unmuteVideoBySelfPermission?: boolean
  updateNicknamePermission?: boolean
  whiteboardPermission?: boolean
  localRecordPermission?: LocalRecordPermissionItem
  emojiRespPermission?: boolean
  smartSummary?: boolean
  audioAllOff?: boolean // 原先audioOff已废弃
  videoAllOff?: boolean
  /** 是否开启转写 */
  isTranscriptionEnabled?: boolean
  // 缓存当前加入会议的配置，访客断网重新入会需要
  joinOption?: JoinOptions
  //本地录制确认弹框是否确认过
  isCloudRecordingConfirmed?: boolean
  //本地录制状态标识
  isLocalRecording?: boolean
  //本地录制确认弹框是否确认过
  isLocalRecordingConfirmed?: boolean
  /** 加入会议的时间 */
  joinMeetingTime: number
  showHandsUp?: boolean
  showEmojiResponse?: boolean
}

export interface InterpretationRes {
  interpreters: {
    [uuid: string]: string[]
  }
  channelNames: {
    [lang: string]: string
  }
  started: boolean
}
export interface NEMeetingSDK {
  memberList: NEMember[]
  inInvitingMemberList: NEMember[]
  meetingInfo: NEMeetingSDKInfo
}
export interface NEMeeting {
  memberList: NEMember[]
  meetingInfo: NEMeetingInfo
}
/**
 * 初始化相关配置
 */
export type NEMeetingInitConfig = {
  /**
   * 是否开启日志打印(默认为true)
   */
  debug?: boolean
  /**
   * 国际化语言
   */
  locale?: string
  /**
   * 是否开启日志上(报默认为true)
   */
  eventTracking?: boolean
  /**
   * 会议appKey
   */
  appKey: string
  /**
   * 会议服务器地址，支持私有化配置
   */
  meetingServerDomain?: string //会议服务器地址，支持私有化部署
  /**
   * IM私有化配置仅限于私有化配置时使用
   */
  imPrivateConf?: NEIMServerConfig
  /**
   * G2 私有化配置仅私有化配置使用
   */
  neRtcServerAddresses?: NERtcServerConfig
  /**
   * 白板私有化配置使用
   */
  whiteboardConfig?: NEWhiteboardServerConfig
  /**
   * @ignore
   */
  globalEventListener?: Record<string, NEProps>
  /**
   * @ignore
   */
  im?: IM
  /**
   * 私有化配置使用，如果配置该字段则会从服务端对应接口拉取配置文件。但是优先级低于其他私有化配置字段，如果配置过其他字段则该配置不生效
   */
  serverUrl?: string
  /**
   * 扩展字段
   */
  extras?: Record<string, NEProps>
  /**
   * 是否读取私有化配置文件
   */
  useAssetServerConfig?: boolean
  /**
   * 白板防盗链配置
   */
  whiteboardAppConfig?: NERoomWhiteboardAppConfig
}
export interface NEMeetingAssetWhiteboardServerConfig
  extends NEWhiteboardServerConfig {
  webServer: string
  fontDownloadServer: string
}
export interface NEMeetingAssetRtcServerConfig extends NERtcServerConfig {
  compatServer: string
  nosLbsServer: string
  nosUploadSever: string
  nosTokenServer: string
}
export interface NEMeetingAssetIMServerConfig {
  appkey: string
  lbsUrl: string
  weblbsUrl: string
  nosReplacement: string
  nosAccess: string
  pubkeyVersion: string
  chatroomDemoListUrl: string
  websdkSsl: boolean
  nosSsl: boolean
  webchatroomAddr: string[]
  module: string
  version: number
  lbs: string
  link: string
  link_web: string
  nos_lbs: string
  nos_uploader: string
  nos_uploader_host: string
  https_enabled: boolean
  nos_downloader: string
  nos_accelerate: string
  nos_accelerate_host: string
  nt_server: string
  kibana_server: string
  statistic_server: string
  report_global_server: string
  multi_video: number
  hand_shake_type: number
  nego_key_neca: number
  nego_key_enca_key_version: number
  nego_key_enca_key_parta: string
  nego_key_enca_key_partb: string
  comm_enca: number
}
export interface NEMeetingPrivateConfig {
  corpCode?: string
  module?: {
    nps: {
      enabled: boolean
    }
    feedback?: {
      enable: boolean
    }
    appUpgrade?: {
      enable: boolean
      iosCheckUrl: string
    }
    about?: {
      privacyUrl: string
      userProtocolUrl: string
    }
    account?: {
      deleteAccountUrl: string
      registryUrl: string
    }
  }
  meeting: {
    serverUrl: string
  }
  roomkit: {
    roomServer: string
  }
  im?: NEMeetingAssetIMServerConfig
  rtc?: NEMeetingAssetRtcServerConfig
  whiteboard?: NEMeetingAssetWhiteboardServerConfig
  appKey?: string
  meetingServerDomain?: string
}

export type NEIMServerConfig = {
  /**
   * lbs连接地址
   */
  lbs: string
  /**
   * link连接地址
   */
  link: string
  /**
   * 是否对link连接进行https处理
   */
  linkSslWeb: boolean
  /**
   * nos上传地址
   */
  nosUploader: string
  /**
   * nos是否开启https
   */
  httpsEnabled: boolean
  /**
   * nos下载地址 这个是用来接到消息后，要按一定模式替换掉文件链接的。给予一个安全下载链接。
   */
  nosDownloader: string

  nosLbs: string
}

export type NERtcServerConfig = {
  /**
   * 通道信息服务器地址
   */
  channelServer?: string
  /**
   * 统计上报服务器地址
   */
  statisticsServer?: string
  /**
   * roomServer服务器地址
   */
  roomServer?: string
  /**
   * 是否使用ipv6
   */
  useIPv6: boolean
}

export type NEWhiteboardServerConfig = {
  /**
   * getChannelInfo接口的地址。用于创建加入白板房间
   */
  roomServer: string
  /**
   * 白板日志上传接口地址
   */
  sdkLogNosServer: string
  /**
   * 白板日志上报地址
   */
  dataReportServer: string
  /**
   * 白板私有化sdk地址
   * WhiteboardUrl ToolCollectionUrl 白板sdk下载地址
   * PPTRendererUrl 如果需要展示动态ppt，需要添加该文件
   */
  privateSDKUrl?: {
    WhiteboardUrl?: string
    ToolCollectionUrl?: string
    PPTRendererUrl?: string
  }
  /**
   * nos直传地址
   */
  directNosServer: string
  /**
   * 音视频，图片上传地址
   */
  mediaUploadServer: string
  /**
   * 文档转码地址
   */
  docTransServer: string
}

/**
 * 登录参数
 * @param accountId 用户id
 * @param accountToken 用户token
 */
export type LoginOptions = {
  accountId: string
  accountToken: string
  isTemporary?: boolean
  authType?: string
  loginType?: number
}

export interface NEEncryptionConfig {
  encryptionType: NEEncryptionType
  encryptKey: string
}

export type NEEncryptionType = 'none' | 'sm4-128-ecb'

/**
 * 加入会议参数配置
 */
export interface JoinOptions {
  /**
   * 是否是 Rooms 应用
   * 会议号
   */
  isRooms?: boolean
  /**
   * 会议号（已弃用）
   * ignore
   */
  meetingId?: number
  /**
   * 会议号
   */
  meetingNum: string
  /**
   * 用户昵称
   */
  nickName: string
  /**
   * 是否开启视频入会 1为开启 2为关闭
   */
  video?: number
  /**
   * 是否开启音频入会 1为开启 2为关闭
   */
  audio?: number
  /**
   * 会时模式，1 常规（默认）， 2开启白板入会
   * @ignore
   */
  defaultWindowMode?: number
  /**
   * 是否开启会中改名，默认为false（开启）
   * @ignore
   */
  noRename?: boolean
  /**
   * 开启会议录制，false（默认） 录制 true 不录制
   * @ignore
   */
  noCloudRecord?: boolean
  /**
   * 成员自定义标签
   * @ignore
   */
  memberTag?: string
  /**
   * 入会密码 创建会议传入则创建有密码的会议
   * @ignore
   */
  password?: string
  /**
   * 是否显示会议应进最大人数,需配合extraData字段设置
   * @ignore
   */
  showMaxCount?: boolean
  /**
   * 是否显示会议主题
   */
  showSubject?: boolean
  /**
   * 是否显示成员标签
   * @ignore
   */
  showMemberTag?: boolean
  /**
   * 成员入会后全体关闭视频，且不允许自主打开，默认允许打开
   */
  attendeeVideoOff?: boolean
  /**
   * 成员入会后全体静音，且不允许自主打开，默认允许打开
   */
  attendeeAudioOff?: boolean
  /**
   * 扩展字段，格式为json字符串，如果showMaxCount字段设置为true，且该字段传{maxCount: 100}，会议应进最大人数为100
   * @ignore
   */
  extraData?: string
  /**
   * 成员列表底部按钮配置
   * @ignore
   */
  muteBtnConfig?: {
    /**
     * 显示全体关闭视频按钮
     */
    showMuteAllVideo: boolean
    /**
     * 显示全体开启按钮
     */
    showUnMuteAllVideo: boolean
    /**
     * 显示全体静音按钮
     */
    showMuteAllAudio: boolean
    /**
     * 显示全体解除静音按钮
     */
    showUnMuteAllAudio: boolean
  }
  /**
   * 是否显示会议剩余时间提醒，默认为false 关闭
   */
  showMeetingRemainingTip?: boolean
  /**
   * 是否显示设置焦点后画面右上角的按钮， 默认为true
   * @ignore
   */
  showFocusBtn?: boolean
  /**
   * 视频分辨率及帧率设置
   * @ignore
   */
  videoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  /**
   * 焦点成员分辨率及帧率设置
   * @ignore
   */
  focusVideoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  /**
   * 是否开启根据声音大小排序 默认为true
   * @ignore
   */
  enableSortByVoice?: boolean
  /**
   * 是否设置主持人默认焦点 默认 false
   * @ignore
   */
  enableSetDefaultFocus?: boolean
  /**
   * 是否关闭sip  true为不开启 false为开启，默认为不开启
   * @ignore
   */
  noSip?: boolean

  /**
   * 是否关闭聊天功能 默认为false
   */
  noChat?: boolean
  /**
   * 是否关闭白板 默认为false
   */
  noWhiteboard?: boolean
  /**
   * 入会角色绑定
   * @ignore
   */
  roleBinds?: Record<userUuid, Role>
  /**
   * 是否显示说话者列表，默认显示
   */
  showSpeaker?: boolean
  /**
   * 控制栏按钮配置
   */
  toolBarList?: ToolBarList
  /**
   * 更多按钮配置
   */
  moreBarList?: MoreBarList
  /**
   * 成员列名会控菜单
   */
  memberActionMenuItems?: Array<
    NEMeetingMenuItem | NESingleStateMenuItem | NECheckableMenuItem
  >
  /**
   * 是否能够通过长按空格解除静音
   */
  enableUnmuteBySpace?: boolean
  /**
   * 是否开启透明白板功能，默认为关闭
   */
  enableTransparentWhiteboard?: boolean
  /**
   * 是否始终显示工具栏
   *
   */
  enableFixedToolbar?: boolean
  /**
   * 是否开启本端镜像 默认为true 镜像
   */
  enableVideoMirror?: boolean
  /**
   * 是否显示会议持续时间，默认为false 不显示
   */
  showDurationTime?: boolean

  enableLeaveTheMeetingRequiresConfirmation?: boolean

  showParticipationTime?: boolean

  chatroomConfig?: {
    /**
     * 聊天室是否开启文件上传
     */
    enableFileMessage?: boolean
    /**
     * 聊天室是否开启图片上传
     */
    enableImageMessage?: boolean
  }
  /**
   * 当前集成环境，如果是Electron则设置为electron，其他不需要设置
   */
  env?: 'web' | 'electron'

  /**
   * 会中“会议号”显示规则，默认都显示
   */
  meetingIdDisplayOption?: NEMeetingIdDisplayOption
  /**
   * 设置国密加密, 目前支持sm4-128-ecb
   */
  encryptionConfig?: NEEncryptionConfig
  /**
   * 配置是否展示云录制菜单按钮(默认展示)
   */
  showCloudRecordMenuItem?: boolean
  /**
   * 配置是否展示本地录制菜单按钮(默认展示)
   */
  showLocalRecordMenuItem?: boolean
  /**
   * 配置是否展示云录制过程中的UI提示(默认展示)
   */
  showCloudRecordingUI?: boolean

  /**
   * 配置是否展示本地录制过程中的UI提示(默认展示)
   */
  showLocalRecordingUI?: boolean
  /**
   * 用户头像
   */
  avatar?: string
  /**
   * watermarkConfig
   */
  watermarkConfig?: {
    name?: string
    phone?: string
    email?: string
    jobNumber?: string
  }
  /** 配置会议中是否展示通知中心菜单，默认展示。 */
  noNotifyCenter?: boolean
  /** 配置会议中是否展示 web 小应用，如签到应用。 默认会拉取小应用列表并展示。 */
  noWebApps?: boolean

  /**
   * h5端是否显示共享者的摄像头画面
   */
  showScreenShareUserVideo?: boolean
  /** 云录制配置 */
  cloudRecordConfig?: NECloudRecordConfig
  noCaptions?: boolean
  noTranscription?: boolean
  pluginNotifyDuration?: number
  /**是否开启语音激励 */
  enableSpeakerSpotlight?: boolean
  /**设置是否隐藏未入会成员 */
  enableShowNotYetJoinedMembers?: boolean
  noInvite?: boolean
  noSwitchAudioMode?: boolean
  noGallery?: boolean
  noLive?: boolean
  enableAudioShare?: boolean
  detectMutedMic?: boolean
  joinTimeout?: number

  enableDirectMemberMediaControlByHost?: boolean

  chatMessageNotificationType?: NEChatMessageNotificationType
  showNameInVideo?: boolean
  /**
   * 入会之前是否进行设备检测
   */
  showDeviceTest?: boolean

  /**
   * 是否开启共享并排模式
   */
  enableSideBySideMode?: boolean

  /**
   * 配置会议中是否显示"会议信息"查看入口，默认显示
   */
  showMeetingInfo?: boolean

  /** 白板配置 */
  whiteBoradAddDocConfig?: AddDocConfig[]

  /**
   * 是否开启白板的云录制
   */
  whiteboardCloudRecord?: boolean
  /**
   * 是否开启白板容器的宽高比
   */
  whiteBoradContainerAspectRatio?: AspectRatio
}

export interface StaticDocParam {
  /**
   * 图片高度
   */
  height: number
  /**
   * 图片宽度
   */
  width: number
  /**
   * index偏移量
   */
  offset: number
  /**
   * 文档页数
   */
  pageCount: number
  /**
   * 图片url的模板。 格式为: "https://??/?{index}.jpg", "https://??/?{index}.png" 如果offset为1，则第5页的图片为: "https://??/?6.jpg", 或者"https://??/?6.png"
   */
  template: string
}
export interface DynamicDocParam {
  /**
   * 图片高度
   */
  height: number
  /**
   * 图片宽度
   */
  width: number
  /**
   * 文档页数
   */
  pageCount: number
  /**
   * 动态文档URL
   */
  url: string
}
export interface MediaDocParam {
  /**
   * 动态文档URL
   */
  url: string
  object: string
  bucket: string
}
export interface UrlDocParam {
  /**
   * URL页面资源参数
   */
  url: string
  trans: string // 填写'url'即可
}
export interface AddDocConfig  {
  /**
   * 文档的唯一id
   */
  docId: string;
  /**
   * 文档类型，会影响弹窗中文档的图标"pdf" | "ppt" | "doc" | "mp4"
   */
  fileType: string;
  /**
   * 文档名称，会影响弹窗中文档名称
   */
  name: string;
  /**
   * 是否在文档弹窗中显示删除按钮
   */
  showDelete: boolean;
  /**
   * 文档具体的数据参数
   */
  params: StaticDocParam | DynamicDocParam | MediaDocParam | UrlDocParam;
}

export enum AspectRatio {
  /**
   * 自适应
   */
  adaption = 0,
  /**
   * 16:9
   */
  aspectRatio_16_9 = 1,
}

export enum NEMeetingIdDisplayOption {
  /** 长短号都显示，默认规则 */
  DISPLAY_ALL = 0,
  /** 只显示长号 */
  DISPLAY_LONG_ID_ONLY = 1,
  /** 长短号都存在时，只显示短号，若无短号，则显示长号 */
  DISPLAY_SHORT_ID_ONLY = 2,
}

export type userUuid = string

/**
 * 角色
 */
export enum Role {
  /** 参会者 */
  member = 'member',
  /** 主持人 */
  host = 'host',
  /** 联席主持人 */
  coHost = 'cohost',
  /** 影子用户 */
  observer = 'observer',
  /** 访客 */
  guest = 'guest',
}
export type NEMeetingRoleType = Role
/**
 * 视频分辨率
 */
export type VideoResolution = 180 | 480 | 720 | 1080
/**
 * 视频帧率
 */
export type VideoFrameRate = 5 | 10 | 15 | 20 | 25

export interface CreateOptions extends JoinOptions {
  enableWaitingRoom?: boolean
}

export interface NERoomControl {
  type: string
  attendeeOff: AttendeeOffType
  state: number
  allowSelfOn: boolean
}

export interface NEMeetingAppNoticeTips {
  appKey: string
  tips: NEMeetingAppNoticeTip[]
  curTime: number
}
export enum NEMeetingAppNoticeTipType {
  /** 未知 */
  NEMeetingAppNoticeTipTypeUnknown = 0,
  /** 文本 */
  NEMeetingAppNoticeTipTypeText = 1,
  /** 链接 */
  NEMeetingAppNoticeTipTypeUrl = 2,
}

export interface NEMeetingAppNoticeTip {
  /**
   * 应用消息提示
   */
  content: string
  /**
   * 应用消息内容
   */
  title: string
  /**
   * 确认按钮文案
   */
  okBtnLabel: string
  /**
   * 跳转链接
   */
  url: string
  /**
   * 应用消息提示类型
   */
  type: NEMeetingAppNoticeTipType
  /**
   * 截止时间
   */
  time: number
  /**
   * 是否可用
   */
  enable: boolean
}

export interface NELocalHistoryMeeting {
  /** 会议号 */
  meetingNum: string

  /** 会议唯一标识 */
  meetingId: number

  /** 会议短号 */
  shortMeetingNum?: string

  /** 会议主题 */
  subject: string

  /** 会议密码 */
  password?: string

  /** 会议昵称 */
  nickname: string

  /** sipId */
  sipId?: string
}

export interface NELocalRecordInfo {
  /** 录制地址 */
  recordPath: string
  /** 会议唯一标识 */
  meetingId: number
}

export type CustomOptions = {
  toolBarList: ToolBarList
  moreBarList: MoreBarList
}

export type BtnConfig = {
  /** 图标 url 地址 */
  icon: string
  /** 按钮文案 */
  text: string
  /** 浅色主题下icon */
  lightIcon?: string
  /** 自定义状态 */
  status?: boolean
}

/**
 * 按钮配置项
 * icon 按钮图标
 * icon 按钮文案
 */
export type BtnConfigList = BtnConfig | BtnConfig[]
/**
 * 控制栏菜单列表配置
 */
export type ToolBarList = CommonBar[]
/**
 * 更多菜单列表配置
 */
export type MoreBarList = CommonBar[]

export type CommonBar = {
  /**
   * 按钮id
   */
  id: number
  /**
   * 按钮类型，分为单状态按钮和多状态按钮。使用内置按钮可不传。
   */
  type?: 'single' | 'multiple'
  /**
   * 按钮配置项
   */
  btnConfig?: BtnConfigList
  /**
   * 可见范围 0 全体可见 1 主持人可见 2 普通成员可见
   */
  visibility?: NEMenuVisibility
  /**
   * 默认按钮状态
   */
  btnStatus?: boolean
  /**
   * 按钮触发回调
   */
  injectItemClick?: (btnInstance?: CommonBar) => void
}

export type LogName = 'meetingLog' | 'rtcLog' | 'imLog'
/**
 * peerJoin 成员加入: (member) => void
 * peerLeave 成员离开: (uuids: string[]) => void
 * roomEnded 房间结束: (reason: NEMeetingLeaveType) => void
 */
export type EventName =
  | 'peerJoin'
  | 'peerLeave'
  | 'roomEnded'
  | 'authEvent'
  | 'onMeetingStatusChanged'
  | 'onScreenSharingStatusChange'
  | 'onAccessDenied'
/**
 * 会议组件
 */
export interface NEMeetingKit {
  /**
   * NEMeetingInfo 当前会议信息
   */
  // meeting: any

  /**
   * @ignore
   */
  globalEventListener: GlobalEventListener | null

  /**
   *@ignore
   */
  view: HTMLElement | null
  /**
   *@ignore
   */
  isInitialized: boolean

  /**
   *@ignore
   */
  neMeeting?: NEMeetingService

  inviteService?: NEMeetingInviteService
  /**
   *@ignore
   */
  roomkit?: Roomkit
  /**
   *@ignore
   */
  afterLeaveCallback: ((reason: number) => void) | null
  /**
   * NEMeetingInfo 当前会议信息
   */
  NEMeetingInfo: {
    isHost: boolean
    isLocked: boolean
    meetingNum: string
    meetingId: string
    password?: string
    shortMeetingId?: string
    sipId?: string
  }
  /**
   *@ignore
   */
  // NESettingService: any
  /**
   * 控制栏按钮配置
   */
  toolBarList: ToolBarList
  /**
   * 更多按钮配置
   */
  moreBarList: MoreBarList
  /**
   * 当前成员信息
   */
  memberInfo: NEMember
  /**
   * 入会成员信息
   */
  joinMemberInfo: {
    [key: string]: NEMember
  }
  /**
   * 初始化接口
   * @param width 画布宽度
   * @param height 画布高度
   * @param config 配置项
   */
  init: (
    width: number,
    height: number,
    config: NEMeetingInitConfig,
    callback: (e?: Error) => void
  ) => void
  /**
   * 销毁房间方法
   */
  destroy: () => void
  /**
   * 离开房间回调方法
   * @param callback
   */
  afterLeave: (callback: () => void) => void
  /**
   * 登录接口
   * @param options 相应配置项
   * @param callback 接口回调
   */
  login: (options: LoginOptions, callback: (e?: NEError) => void) => void
  /**
   * @ignore
   * 账号密码登录接口
   * @param options 相应配置项
   * @param callback 接口回调
   */
  loginWithPassword: (
    options: { username: string; password: string },
    callback: (e?: NEError) => void
  ) => void

  /**
   * 匿名入会接口
   * @param options 相应配置项
   */
  anonymousJoinMeeting: (
    options: JoinOptions,
    callback: (e?: ServerError | Error) => void
  ) => void
  /**
   * 登出接口
   * @param callback 接口回调
   */
  logout: (callback: () => void) => void
  /**
   * 创建会议接口
   * @param options 相应配置参数
   * @param callback 接口回调
   */
  create: (options: CreateOptions, callback: (e?: NEError) => void) => void
  /**
   * 加入会议接口
   * @param options 相应配置参数
   * @param callback 接口回调
   */
  join: (options: JoinOptions, callback: (e?: NEError) => void) => void
  /**
   * 通过邀请会议接口
   * @param options 相应配置参数
   * @param callback 接口回调
   */
  acceptInvite: (options: JoinOptions, callback: (e?: NEError) => void) => void
  /**
   * 动态更新自定义按钮
   * @param options
   */
  // setCustomList: (options: CustomOptions) => void
  /**
   * 事件监听接口
   * @param actionName 事件名
   * @param callback 事件回调
   */
  on: (actionName: EventName, callback: (...data) => void) => void
  /**
   * 移除事件监听接口
   * @param actionName 事件名
   * @param callback 事件回调
   */
  off: (actionName: EventName, callback?: (...data) => void) => void
  /**
   * 设置默认画面展示模式
   * @param mode big | small
   */
  setDefaultRenderMode: (mode: 'big' | 'small') => void
  /**
   * 上传日志接口
   * @param logNames 日志类型名称
   * @param start 日志开始时间
   * @param end 日志结束时间
   */
  // uploadLog: (logNames?: LogName, start?: number, end?: number) => void
  /**
   * 下载日志接口
   * @param logNames 日志类型类型
   * @param start 日志开始时间
   * @param end 日志结束时间
   */
  // downloadLog: (logNames?: LogName, start?: number, end?: number) => void
  /**
   * 检测浏览器是否兼容
   * @return true表示支持
   */
  checkSystemRequirements: () => boolean
  /**
   * im 复用场景需要调用该方法，入参为IM，该方法会重新处理getInstance并返回一个包装过的IM，然后直接调用IM.getInstance方法
   */
  reuseIM: (IM: IM) => IM
  /**
   * electron环境使用用于设置需要共享的源id
   * @param sourceId
   */
  setScreenSharingSourceId: (sourceId: string) => void
  /**
   * electron环境下有效是否开启共享
   * @param enable
   */
  enableScreenShare: (enable: boolean) => void
  /**
   * 增加全局事件监听
   */
  addGlobalEventListener: (eventListener: GlobalEventListener) => void

  removeGlobalEventListener: () => void
  /**
   * 增加会议状态变更事件监听
   */
  addMeetingStatusListener: (eventListener: NEMeetingStatusListener) => void
  /**
   * 移除会议状态变更事件监听
   */
  removeMeetingStatusListener: () => void
  /**
   * 获取房间云录制列表
   * @param roomArchiveId 房间roomArchiveId
   */
  getRoomCloudRecordList: (
    roomArchiveId: number
  ) => Promise<NEResult<NERoomRecord[]> | undefined>
  /**
   * 切换语言
   * @param language 对应需要切换语言类型（默认跟随浏览器）
   */
  switchLanguage: (language: NEMeetingLanguage) => void
  /**
   * 更新会议信息接口
   * @param meetingInfo 会议信息
   */
  updateMeetingInfo: (meetingInfo: Partial<NEMeetingInfo>) => void

  getReducerMeetingInfo: (callback: (data) => void) => void

  leaveMeeting: (finish: boolean, callback?: (e?: Error) => void) => void
}

export enum NEMeetingLeaveType {
  LEAVE_BY_SELF = 0,
  KICK_OUT = 2,
  CLOSE_BY_MEMBER = 3,
  NetworkError = 4,
  UNKNOWN = 6,
  OTHER = 7,
  LOGIN_STATE_ERROR = 8,
  CLOSE_BY_BACKEND = 9,
  SYNC_DATA_ERROR = 10,
  ALL_MEMBERS_OUT = 11,
  END_OF_LIFE = 12,
  kICK_BY_SELF = 13,
  JOIN_TIMEOUT = 14,
}

export interface NEMeetingKitAction {
  actions: NEMeetingKit
}

export interface SipMember {
  sipNum: string
  sipHost: string
  /** 邀请状态。1.邀请中，2.邀请成功，3.拒绝，4.挂断 */
  status: 1 | 2 | 3 | 4
  /** 邀请人id */
  inviterUid: string
}

export interface MeetingListItem {
  /** 参会记录id */
  anchorId: number
  /** 会议唯一id */
  meetingId: number
  /** 会议号 */
  meetingNum: number
  /** 会议主题 */
  subject: string
  /** 会议类型 */
  type: number
  /** 参会时间 */
  roomEntryTime: number
  /** 会议开始时间 */
  roomStartTime: number
  /** 创建人userUuid */
  ownerUserUuid: string
  /** 创建人昵称 */
  ownerNickname: string
  /** 如果未收藏则为null */
  favoriteId?: number
  /** 会议结束时间 */
  roomEndTime: number
  /** 创建人头像 */
  ownerAvatar?: string
  /** 会议时区 */
  timezoneId: string
  /**@deprecated 请使用 meetingId */
  roomArchiveId: number
  /**@deprecated 请使用 anchorId */
  attendeeId: number
  /**@deprecated 请使用 favoriteId 判断 */
  isFavorite: boolean
}

/// 聊天室导出状态
export const enum NEChatroomExportAccess {
  /** 未知 */
  kUnknown = 0,
  /** 可导出 */
  kAvailable,
  /** 无权限导出 */
  kNoPermission,
  /** 已过期 */
  kOutOfDate,
}

export type NEChatroomInfo = {
  /** 聊天室id */
  chatroomId: number
  /** 导出权限 */
  exportAccess: NEChatroomExportAccess
}

export type NEMeetingWebAppIconItem = {
  /** 应用图标url */
  defaultIcon: string
  /** 推送图标url */
  notifyIcon?: string
}

export const enum NEMeetingWebAppItemType {
  /** 官方应用 */
  kOfficial = 0,
  /** 企业自建应用 */
  kCorporate = 1,
}

export type NEMeetingWebAppItem = {
  /** 应用Id */
  pluginId: string
  /** 应用名称 */
  name: string
  /** 应用图标 */
  icon: NEMeetingWebAppIconItem
  /** 应用描述 */
  description?: string
  /** 应用类型 */
  type: NEMeetingWebAppItemType
  /** 应用链接 */
  homeUrl: string
  /** 会话Id */
  sessionId: string
}

export type NEHistoryMeetingDetail = {
  /** 聊天室信息 */
  chatroomInfo?: NEChatroomInfo
  pluginInfoList?: NEMeetingWebAppItem[]
}

/**
 * 组件当前支持的语言类型。通过{@link NEMeetingKit#switchLanguage(NEMeetingLanguage)} 可切换语言。
 * CHINESE 中文；ENGLISH 英文；JAPANESE 日文；
 */
export enum NEMeetingLanguage {
  AUTOMATIC = '*',
  CHINESE = 'zh',
  ENGLISH = 'en',
  JAPANESE = 'ja',
}
// export type NEMeetingLanguage = 'CHINESE' | 'ENGLISH' | 'JAPANESE'

/**
 * 全局事件监听
 */
export interface GlobalEventListener {
  /**
   * rtc engine 初始化前回调
   */
  beforeRtcEngineInitialize: (meetingId: string) => void
  /**
   * rtc engine 初始化后回调
   */
  afterRtcEngineInitialize: (meetingId: string, rtcWrapper: RtcWrapper) => void
  /**
   * rtc engine 销毁前回调
   */
  beforeRtcEngineRelease: (meetingId: string, rtcWrapper: RtcWrapper) => void
}
/**
 * RTC实例包装类，可获取RTC实例，添加/删除RTC回调
 */
export interface RtcWrapper {
  /**
   * 获取RTC实例
   */
  rtcEngine: NERtcEx
}

export interface NEMeetingStatusListener {
  /**
   * status: 当前会议状态
   * arg: 该状态附带的额外参数，可参考NEMeetingStatus
   * obj: 该状态附带的额外数据对象，可空
   */
  onMeetingStatusChanged: (event: {
    status: NEMeetingStatus
    arg?: NEMeetingCode
    obj?: NEProps
  }) => void
}

export enum NEMeetingStatus {
  /** 创建或加入会议失败 */
  MEETING_STATUS_FAILED = -1,
  /** 当前未处于任何会议中 */
  MEETING_STATUS_IDLE = 0,
  /** 当前处于等待状态 */
  MEETING_STATUS_WAITING = 1,
  /** 当前正在创建或加入会议 */
  MEETING_STATUS_CONNECTING = 2,
  /** 当前处于会议中 */
  MEETING_STATUS_INMEETING = 3,
  /** 当前处于等候室 */
  MEETING_STATUS_IN_WAITING_ROOM = 5,
  /** 当前正在从会议中断开，断开原因参见NEMeetingCode  */
  MEETING_STATUS_DISCONNECTING = 6,
  /** 当前处于最小化状态 */
  MEETING_STATUS_INMEETING_MINIMIZED = 4,
  /** 当前初始设备检测状态 */
  MEETING_STATUS_DEVICE_TESTING = 7,
  /** 未知状态 */
  MEETING_STATUS_UNKNOWN = 100,
}

export enum NEMeetingCode {
  /** 当前正在从会议中断开，原因为用户主动断开 */
  MEETING_DISCONNECTING_BY_SELF = 0,
  /** 会议断开的类型之一，当前正在从会议中断开，原因为被会议主持人移除 */
  MEETING_DISCONNECTING_REMOVED_BY_HOST = 1,
  /**当前正在从会议中断开，原因为会议被主持人关闭 */
  MEETING_DISCONNECTING_CLOSED_BY_HOST = 2,
  /** 当前正在从会议中断开，原因为账号在其他设备上登录 */
  MEETING_DISCONNECTING_LOGIN_ON_OTHER_DEVICE = 3,
  /**当前正在从会议中断开，原因为自己作为主持人主动结束了会议 */
  MEETING_DISCONNECTING_CLOSED_BY_SELF_AS_HOST = 4,
  /**当前正在从会议中断开，原因为账号信息已过期 */
  MEETING_DISCONNECTING_AUTH_INFO_EXPIRED = 5,
  /** 会议不存在 */
  MEETING_DISCONNECTING_NOT_EXIST = 7,
  /** 同步房间信息失败 */
  MEETING_DISCONNECTING_SYNC_DATA_ERROR = 8,
  /** rtc 模块初始化失败 */
  MEETING_DISCONNECTING_RTC_INIT_ERROR = 9,
  /** 加入频道失败 */
  MEETING_DISCONNECTING_JOIN_CHANNEL_ERROR = 10,
  /** 入会超时 */
  MEETING_DISCONNECTING_JOIN_TIMEOUT = 11,
  /** 会议时长到达上限 */
  MEETING_DISCONNECTING_END_OF_LIFE = 12,
  /** 正在等待验证会议密码 */
  MEETING_WAITING_VERIFY_PASSWORD = 20,
  /** 开始加入RTC */
  MEETING_JOIN_CHANNEL_START = 21,
  /** 加入RTC成功 */
  MEETING_JOIN_CHANNEL_SUCCESS = 22,
}

/**
 * 房间录制信息类型
 * @param recordId 录制id
 * @param recordStartTime 录制开始时间，毫秒时间戳
 * @param recordEndTime 录制结束时间，毫秒时间戳
 * @param infoList 录制信息列表
 */
export interface NERoomRecord {
  recordId: string
  recordStartTime: number
  recordEndTime: number
  infoList: NERecordFileInfo[]
}
/**
 * 房间录制文件信息类型
 * @property type 文件的类型，即文件扩展名。aac：实时音频录制文件、mp4：实时视频录制文件、flv：互动直播视频录制文件
 * @property mix 是否为混合录制文件，true：混合录制文件，false：单人录制文件。
 * @property filename 文件名
 * @property md5 文件md5
 * @property size 文件大小，单位为字节
 * @property url 文件下载地址
 * @property vid 点播文件id
 * @property pieceIndex 录制文件分片索引
 * @property userUuid 用户id // 单录用户的uuid
 * @property nickname 会议昵称 // 单录用户的会议中的昵称
 */
export interface NERecordFileInfo {
  type: string
  mix: boolean
  filename: string
  md5: string
  size: number
  url: string
  vid: number
  pieceIndex: number
  userUuid?: string
  nickname?: string
}
export enum NEMeetingInviteStatus {
  /**
   * 未知
   */
  unknown,

  waitingCall,
  calling,
  rejected,
  noAnswer,
  error,
  removed,
  canceled,
  waitingJoin,
  busy,
}

export interface NEMeetingScheduledMember {
  userUuid: string
  role: Role
}

export interface NEMeetingInviteInfo {
  inviterName?: string
  /** @deprecated 请使用 inviterAvatar */
  inviterIcon?: string
  inviterAvatar?: string
  subject?: string
  preMeetingInvitation?: boolean
  meetingNum: string
}

/**
 * 同声传译译员
 */
export interface NEMeetingInterpreter {
  /**
   * 传译员用户 Id
   */
  userId?: string

  /**
   * 第一语言，默认为收听语言
   */
  firstLang: string

  /**
   * 第一语言，默认为收听语言
   */
  secondLang: string
}

export type NEMeetingInterpreterInfo = NEMeetingInterpreter & {
  userInfo?: SearchAccountInfo
}

export interface NEInterpretationEventListener {
  /**
   * 房间内可用语言列表更新通知
   * @param languageList
   */
  onAvailableLanguageListUpdated(languageList: string[]): void

  /**
   * 同声传译开启状态变更通知
   * @param started
   */
  onInterpretationStartStateChanged(started: boolean): void

  /**
   * 同声传译译员列表变更通知
   * @param interpreters
   */
  onInterpreterListChanged(interpreters: NEMeetingInterpreter[]): void

  /**
   * 本端同声传译译员角色变更通知
   * @param myInterpreter
   */
  onMyInterpreterChanged(myInterpreter?: NEMeetingInterpreter): void

  /**
   * 本端传译语言变更通知
   * @param language
   */
  onMySpeakLanguageChanged(language: string): void

  /**
   * 本端收听语言变更通知
   * @param language
   */
  onMyListenLanguageChanged(language: string): void

  /**
   * 本端收听的语言频道不可用通知
   * @param language
   */
  onMyListenLanguageUnavailable(language: string): void
}

export interface NEMeetingInterpretationSettings {
  listenLanguage?: string
  isListenMajor?: boolean
  majorVolume?: number
  muted?: boolean
  speakerLanguage?: string
}

export type SaveSettingInterface = {
  [key: string]:
    | string
    | number
    | boolean
    | Record<
        string,
        string | number | boolean | Record<string, string | number | boolean>
      >
}

export type ServiceBundle = {
  /** 会议服务 */
  name: string
  /** 会议服务过期时间: -1 永不过期 */
  expireTimeStamp: number
  /** 会议服务过期提示 */
  expireTip: string
  /** 会议服务最大人数 */
  maxMembers: number
  /** 套餐支持的最大时长，以分钟为单位，小于0或为空表示不限时长 */
  maxMinutes: number
  /** @deprecated 请使用 maxMembers */
  meetingMaxMembers: number
  /** @deprecated 请使用 maxMinutes */
  meetingMaxMinutes: number
}

export type NEAccountInfo = {
  /** 企业名称 */
  corpName?: string
  /** 用户 */
  userUuid: string
  /** 用户token */
  userToken: string
  /** 用户昵称 */
  nickname: string
  /** 个人会议号 */
  privateMeetingNum: string
  /** 是否为初始密码 */
  isInitialPassword: boolean
  /** @deprecated 请使用 {@link NEAccountInfo#userUuid} */
  account?: string
  /** 用户头像 */
  avatar?: string
  /** 用户手机号 */
  phoneNumber?: string
  /** 用户邮箱 */
  email?: string
  /** 个人会议短号 */
  privateShortMeetingNum?: string
  /** 会议服务 */
  serviceBundle?: ServiceBundle
  /** 是否是匿名账号 */
  isAnonymous?: boolean
  /** @deprecated 请使用 privateMeetingNum */
  shortMeetingNum?: string
}

export type InnerAccountInfo = {
  settings: {
    asrTranslationLanguage: string
    beauty: {
      level: number
    }
    captionBilingual: boolean
    transcriptionBilingual: boolean
  }
}

export interface EnterPriseInfo {
  appKey: string
  appName: string
  idpList: Array<IdpInfo>
  ssoLevel: number
}
export interface IdpInfo {
  id: number
  name: string
  type: number
}

export type NEScheduledMember = {
  userUuid: string
  role: Role
}

export interface NEResult<T = null> {
  code: number
  msg?: string | null
  message?: string | null
  data: T
  requestId?: string
  cost?: number
}

export type NEProps = unknown

export interface GuestMeetingInfo {
  /** 跨应用入会token */
  meetingUserToken: string
  /** 跨应用入会uuid */
  meetingUserUuid: string
  /** 跨应用入会appKey */
  meetingAppKey: string
  /** 跨应用鉴权类型 */
  meetingAuthType: string
  /** 访客跨应用入会类型 0 不允许访客入会 1 实名访客入会 2 匿名访客入会*/
  guestJoinType: string
}
