import WebRoomkit, {
  NERoomLiveState,
  NERoomMemberInviteState,
  NERoomMemberInviteType,
} from 'neroom-web-sdk'
import { NECustomSessionMessage } from 'neroom-web-sdk/dist/types/types/messageChannelService'
import NEMeetingService from '../services/NEMeeting'
import {
  LayoutTypeEnum,
  LiveBackgroundInfo,
  MeetingSetting,
  NEChatPermission,
  NEWaitingRoomChatPermission,
  RecordState,
  SearchAccountInfo,
  ServerError,
  WatermarkInfo,
} from './innerType'
import NEMeetingInviteService from '../services/NEMeetingInviteService'

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
   * 视频是否打开
   */
  isVideoOn: boolean
  /**
   * 当前成员是否正在共享白板
   */
  isSharingWhiteboard: boolean
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
    [key: string]: any
  }
  /**
   * 角色
   */
  role: string
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

type NEError = ServerError | Error

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
export enum NEClientType {
  UNKNOWN,
  IOS,
  ANDROID,
  PC,
  WEB,
  SIP,
  MAC,
  MINIAPP,
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
}
export interface NEMeetingJoinOptions {
  /** 配置会议中成员列表是否不显示"全体关闭/打开视频"，默认为true，即不显示 */
  noMuteAllVideo?: boolean

  /** 配置会议中成员列表是否不显示"全体禁音/解除全体静音"，默认为false，即显示 */
  noMuteAllAudio?: boolean

  /** 配置入会时是否关闭本端视频，默认为true，即关闭视频，但在会议中可重新打开 */
  noVideo?: boolean

  /** 配置入会时是否关闭本端音频，默认为true，即关闭音频，但在会议中可重新打开 */
  noAudio?: boolean

  /** 配置是否在会议界面中显示会议时长，默认为false，入会前设置，会议中无法设置 */
  showMeetingTime?: boolean

  /** 配置是否开启语音激励，默认为true */
  enableSpeakerSpotlight?: boolean

  /** 配置会议中是否显示"邀请"按钮，默认为false，即显示*/
  noInvite?: boolean

  /** 配置会议中是否显示"sip"功能菜单，默认为false，即显示*/
  noSip?: boolean

  /** 配置会议中是否显示"聊天"按钮，默认为false，即显示*/
  noChat?: false

  /** 配置会议中是否显示"切换摄像头"按钮，默认为false，即显示 */
  noSwitchCamera?: boolean

  /** 配置会议中是否开启前置摄像头视频镜像，默认开启 */
  enableFrontCameraMirror?: boolean

  /** 配置会议中是否显示"切换音频模式"按钮，默认为false，即显示 */
  noSwitchAudioMode?: boolean

  /** 配置会议中是否包含画廊模式, 默认为false*/
  noGallery?: boolean

  /** 配置会议中是否显示"共享白板"按钮, 默认false，即显示*/
  noWhiteBoard?: boolean

  /** 配置会议中是否显示"改名"菜单, 默认false，即显示 */
  noRename?: boolean

  /** 配置是否在会议界面中显示"直播"入口, 默认false，即显示  */
  noLive?: boolean

  /** 配置会议中是否开启剩余时间提醒, 默认false */
  showMeetingRemainingTip?: boolean

  /** 配置会议中主页是否显示屏幕共享者的摄像头画面，默认为true，当前正在共享的内容画面不受影响。 如果设置为关闭，屏幕共享者的摄像头画面会被隐藏，不会遮挡共享内容画面。 */
  showScreenShareUserVideo?: boolean

  /**
   * 开启/关闭音频共享功能。 默认为true, 开启后，在发起屏幕共享时，会同时自动开启设备的音频共享； 关闭后，在发起屏幕共享时，不会自动打开音频共享，但可以通过UI手动开启音频共享。 该设置默认为关闭。
   */
  enableAudioShare?: boolean

  /** 配置会议中主页是否显示白板共享者的摄像头画面。 默认为false，如果设置为开启，白板共享者的摄像头画面会以小窗口的方法覆盖在白板画面上显示。 */
  showWhiteboardShareUserVideo?: boolean

  /** 配置会议中白板共享时是否开启标注模式。 默认为false*/
  enableTransparentWhiteboard?: boolean

  /** 配置会议内是否显示 {@link NEMeetingParams#tag}。 */
  showMemberTag: boolean

  /** 是否开启麦克风静音检测，默认开启。 开启该功能后，SDK 在检测到麦克风有音频输入，但此时处于静音打开的状态时，会提示用户关闭静音。 */
  detectMutedMic?: boolean

  /** 会中"会议号"显示规则，默认为 {@link NEMeetingIdDisplayOption#DISPLAY_ALL} */
  meetingIdDisplayOption?: NEMeetingIdDisplayOption

  /**
   * 配置会议内"Toolbar"菜单列表中的菜单项。通过提供一个完整的菜单列表，其中可包含SDK内置菜单和自定义注入菜单，SDK会根据该列表排序依次显示对应菜单项，并在自定义菜单点击时触发对应回调。该配置仅会议前设置生效，会议过程中修改列表不会触发更新。如果不配置该列表，默认为{@link
   * NEMenuItems#getBuiltinToolbarMenuItemList()}
   *
   * <p>注意：部分SDK内置菜单<b>只支持</b>在Toolbar菜单列表中显示，不能放入"更多"菜单列表中，且Toolbar菜单列表最多允许同时显示<b>4</b>个菜单项，即max(VISIBLE_ALWAYS
   * + VISIBLE_EXCLUDE_HOST, VISIBLE_ALWAYS + VISIBLE_TO_HOST_ONLY) &le; 4
   *
   * @see NESingleStateMenuItem
   * @see NECheckableMenuItem
   * @ see
   *     NEMeetingService#setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener)
   */
  fullToolbarMenuItems: ToolBarList

  /**
   * 配置会议内"更多"菜单列表中的菜单项。通过提供一个完整的菜单列表，其中可包含SDK内置菜单和自定义注入菜单，SDK会根据该列表排序依次显示对应菜单项，并在自定义菜单点击时触发对应回调。该配置仅会议前设置生效，会议过程中修改列表不会触发更新。如果不配置该列表，默认为{@link
   * NEMenuItems#getBuiltinMoreMenuItemList()}
   *
   * <p>注意：部分SDK内置菜单<b>只支持</b>在"更多"菜单列表中显示，且"更多"菜单列表最多允许配置同时显示<b>10</b>个菜单项，即max(VISIBLE_ALWAYS +
   * VISIBLE_EXCLUDE_HOST, VISIBLE_ALWAYS + VISIBLE_TO_HOST_ONLY) &le; 10
   *
   * @see NESingleStateMenuItem
   * @see NECheckableMenuItem
   * @ see
   *     NEMeetingService#setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener)
   */
  fullMoreMenuItems: MoreBarList

  /** 语音相关参数 {@link NEAudioProfile} */
  // audioProfile: NEAudioProfile

  /** 会议聊天室配置。 */
  // NEMeetingChatroomConfig chatroomConfig;

  /** 菜单按钮是否显示"云录制" */
  showCloudRecordMenuItem?: boolean

  /** 会议中是否展示云录制中UI */
  showCloudRecordingUI?: boolean

  /** 是否允许音频设备切换 */
  // public boolean enableAudioDeviceSwitch = true;

  /** 配置会议中是否展示通知中心菜单，默认展示。 */
  noNotifyCenter?: boolean

  /** 配置会议中是否展示 web 小应用，如签到应用。 默认会拉取小应用列表并展示。 */
  noWebApps?: boolean
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
  encryptionConfig: NEEncryptionConfig

  /** 水印配置 */
  watermarkConfig: NEWatermarkConfig
}
export interface NEWatermarkConfig {
  name?: string
  phone?: string
  email?: string
  jobNumber?: string
}

export interface NEMeetingSDKInfo {
  localMember: NEMember
  myUuid: string
  hostUuid: string
  hostName: string
  screenUuid: string
  whiteboardUuid: string
  annotationEnabled: boolean
  focusUuid: string
  activeSpeakerUuid: string
  properties: Record<string, any>
  password?: string
  isSupportChatroom: boolean
  subject: string
  startTime: number
  endTime: number
  type: number
  shortMeetingNum: string
  ownerUserUuid: string
  rtcStartTime: number
  roomArchiveId: number
  timezoneId?: string
  sipCid?: string
  meetingNum: string
  meetingInviteUrl: string
  meetingId?: string
  isUnMutedVideo?: boolean
  isUnMutedAudio?: boolean
  isScreenSharingMeeting?: boolean
  isWaitingRoomEnabled?: boolean
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
  /**
   * 访客入会
   */
  enableGuestJoin?: boolean
  interpretation?: InterpretationRes
  isInterpreter?: boolean
  /**
   * 批注权限
   */
  annotationPermission?: number
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
  globalEventListener?: Record<string, any>
  /**
   * @ignore
   */
  im?: any
  /**
   * 私有化配置使用，如果配置该字段则会从服务端对应接口拉取配置文件。但是优先级低于其他私有化配置字段，如果配置过其他字段则该配置不生效
   */
  serverUrl?: string
  /**
   * 扩展字段
   */
  extras?: Record<string, any>
  /**
   * 是否读取私有化配置文件
   */
  useAssetServerConfig?: boolean
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
}

export type NERtcServerConfig = {
  /**
   * 通道信息服务器地址
   */
  channelServer: string
  /**
   * 统计上报服务器地址
   */
  statisticsServer: string
  /**
   * roomServer服务器地址
   */
  roomServer: string
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
   * @ignore
   */
  attendeeVideoOff?: boolean
  /**
   * 成员入会后全体静音，且不允许自主打开，默认允许打开
   * @ignore
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
   * 配置是否展示云录制过程中的UI提示(默认展示)
   */
  showCloudRecordingUI?: boolean
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
export interface NEStartMeetingParams {
  subject?: string
  /**
   * 指定要创建会议号
   * 可指定为个人会议ID或个人会议短号；
   * 当不指定时，由服务端随机分配一个会议ID；
   */
  meetingNum?: string

  /** 房间中的用户昵称，不能为空 */
  displayName?: string

  /// 房间密码;
  /// 创建房间时，如果密码不为空，会创建带指定密码的房间
  /// 加入带密码的房间时，需要指定密码
  password?: string

  /// 会议中的用户成员标签，自定义，最大长度50
  tag?: string

  avatar: string

  /// 透传字段
  extraData?: string

  /// 音视频控制
  controls: NERoomControl[]

  /// 设置会议成员角色
  roleBinds: Record<string, NEMeetingRoleType>

  /// 媒体流加密类型
  encryptionConfig: NEEncryptionConfig
}
export interface NEMeetingAppNoticeTips {
  appKey: string
  tips: NEMeetingAppNoticeTip[]
  curTime: number
}
export enum NEMeetingAppNoticeTipType {}

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
  /// 会议号
  meetingNum: string

  /// 会议唯一标识
  meetingId: number

  /// 会议短号
  shortMeetingNum?: string

  /// 会议主题
  subject: string

  /// 会议密码
  password?: string

  /// 会议昵称
  nickname: string

  /// sipId
  sipId?: string
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
  visibility?: 0 | 1 | 2
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
  roomkit: WebRoomkit
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
    callback: () => void
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
  on: (actionName: EventName, callback: (...data: any) => void) => void
  /**
   * 移除事件监听接口
   * @param actionName 事件名
   * @param callback 事件回调
   */
  off: (actionName: EventName, callback?: (...data: any) => void) => void
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
  reuseIM: (IM: any) => any
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
  ) => Promise<NEResult<NERoomRecord[]>>
  /**
   * 切换语言
   * @param language 对应需要切换语言类型（默认跟随浏览器）
   */
  switchLanguage: (language: NEMeetingLanguage) => void
  /**
   * 上传日志
   * @param callback 上传成功回调
   */
  uploadLog: () => NEResult<string>
  /**
   * 更新会议信息接口
   * @param meetingInfo 会议信息
   */
  updateMeetingInfo: (meetingInfo: Partial<NEMeetingInfo>) => void
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
  attendeeId: number
  roomArchiveId: number
  meetingNum: number
  subject: string
  type: number
  roomStartTime: number
  roomEntryTime: number
  ownerUserUuid: string
  ownerNickname: string
  isFavorite: boolean
  favoriteId: number
  roomEndTime: number
  ownerAvatar?: string
  timezoneId: string
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
  notifySenderAccid?: string
}

export type NEHistoryMeetingDetail = {
  /** 聊天室信息 */
  chatroom?: NEChatroomInfo
  pluginInfoList?: NEMeetingWebAppItem[]
}

/**
 * 组件当前支持的语言类型。通过{@link NEMeetingKit#switchLanguage(NEMeetingLanguage)} 可切换语言。
 * CHINESE 中文；ENGLISH 英文；JAPANESE 日文；
 */
export const enum NEMeetingLanguage {
  CHINESE = 'CHINESE',
  ENGLISH = 'ENGLISH',
  JAPANESE = 'JAPANESE',
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
  rtcEngine: {
    client: any
  }
}

export interface NEMeetingStatusListener {
  /**
   * status: 当前会议状态
   * arg: 该状态附带的额外参数，可参考NEMeetingStatus
   * obj: 该状态附带的额外数据对象，可空
   */
  onMeetingStatusChanged: (
    status: NEMeetingStatus,
    arg?: NEMeetingCode,
    obj?: any
  ) => void
}

export enum NEMeetingStatus {
  /** 当前正在创建或加入会议 */
  MEETING_STATUS_CONNECTING = 0,
  /** 当前正在从会议中断开，断开原因参见NEMeetingCode  */
  MEETING_STATUS_DISCONNECTING = 1,
  /** 创建或加入会议失败 */
  MEETING_STATUS_FAILED = 2,
  /** 当前未处于任何会议中 */
  MEETING_STATUS_IDLE = 3,
  /** 当前处于会议中 */
  MEETING_STATUS_INMEETING = 4,
  /** 当前处于会议最小化状态 */
  MEETING_STATUS_INMEETING_MINIMIZED = 5,
  /** 未知状态 */
  MEETING_STATUS_UNKNOWN = 6,
  /** 当前处于等待状态 */
  MEETING_STATUS_WAITING = 7,
  /** 当前处于等候室状态 */
  MEETING_STATUS_IN_WAITING_ROOM = 8,
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
}

export interface NEMeetingScheduledMember {
  userUuid: string
  role: Role
}

export interface NEMeetingInviteInfo {
  inviterName?: string
  inviterIcon?: string
  subject?: string
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
  /** 会议服务最大人数 */
  meetingMaxMembers: number
  /** 会议服务最大时长 */
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
  /** 会议短号 */
  shortMeetingNum: string
  /** 是否为初始密码 */
  isInitialPassword: boolean
  /** 用户账号 */
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
  role: string
}

export interface NEResult<T = null> {
  code: number | string
  message?: string
  data: T
  requestId?: string
  cost?: number
}
