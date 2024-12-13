import { NEResult } from 'neroom-types'
import { NECloudRecordConfig, NEMeetingIdDisplayOption } from '../../../types'
import {
  NEJoinMeetingParams,
  NEMeetingStatus,
  NEMeetingStatusListener,
  NEWatermarkConfig,
} from '../../../types/type'
import { NEMeetingControl } from './pre_meeting_service'
import { NEChatMessageNotificationType } from './settings_service'

export { NEJoinMeetingParams }

export type NEMeetingServiceListener = {
  onRoomEnded?: (reason: number) => void
}

export type NEMenuItemInfo = {
  icon: string
  text: string
}

export enum NEMenuVisibility {
  /** 对应菜单始终可见 */
  VISIBLE_ALWAYS = 0,
  /** 对应菜单主持人不可见 */
  VISIBLE_EXCLUDE_HOST = 1,
  /** 对应菜单仅主持人可见 */
  VISIBLE_TO_HOST_ONLY = 2,
  /** SIP/H323不可见 */
  VISIBLE_EXCLUDE_ROOM_SYSTEM_DEVICE = 3,
  /** 仅对会议创建者可见 */
  VISIBLE_TO_OWNER_ONLY = 4,
  /** 仅对会议主持人可见，联席主持人不可见 */
  VISIBLE_TO_HOST_EXCLUDE_COHOST = 5,
}

export type NEMeetingMenuItem = {
  itemId: number
  visibility?: NEMenuVisibility
}

export type NESingleStateMenuItem = NEMeetingMenuItem & {
  singleStateItem: NEMenuItemInfo
}

export type NECheckableMenuItem = NEMeetingMenuItem & {
  checkedStateItem: NEMenuItemInfo
  uncheckStateItem: NEMenuItemInfo
  checked: boolean
}

export enum NEMeetingRoleType {
  /// 主持人
  host = 0,

  /// 联席主持人
  coHost,

  /// 成员
  member,

  /// 外部访客
  guest,
}

export type NEMeetingInfo = {
  /*
   * 会议唯一标识
   */
  meetingId: number
  /*
   * 会议号
   */
  meetingNum: string

  /*
   * 当前用户是否为主持人
   */
  isHost: boolean

  /*
   * 当前会议是否被锁定
   */
  isLocked: boolean

  /*
   * 当前用户是否处于等候室中
   */
  isInWaitingRoom: boolean

  /*
   * 会议主题
   */
  subject: string

  /*
   * 会议密码
   */
  password?: string

  /*
   * SIP号
   */
  sipId?: string

  /*
   * 预约会议的预约开始时间戳，Unix时间戳，单位为ms。非预约会议该时间与<code>startTime</code> 相同
   */
  scheduleStartTime?: number

  /*
   * 预约会议的预约结束时间戳，Unix时间戳，单位为ms。非预约会议值为-1
   */
  scheduleEndTime?: number

  /*
   * 会议开始时间戳
   */
  startTime: number

  /*
   * 会议当前持续时间，会随着会议的进行而更新，单位为ms
   */
  duration: number

  /*
   * 当前会议主持人用户Id
   */
  hostUserId: string

  /*
   * 会议扩展字段，可空，最大长度为 2K。
   *
   */
  extraData: string

  /*
   * 当前会议内用户列表
   */
  //  userList: NEInMeetingUserInfo[]

  /*!
   * 时区Id
   */
  timezoneId: string
}

export enum NEEncryptionMode {
  GMCryptoSM4ECB = 0,
}

export type NEEncryptionConfig = {
  encryptionMode: NEEncryptionMode
  encryptKey: string
}

export type NEMeetingParams = {
  /** 房间中的用户昵称，不能为空 */
  displayName: string
  /** 会议中的用户头像，可空 */
  avatar?: string
  /**
   *  指定要创建或加入的目标会议号
   * 加入会议时，该字段必须是一个当前正在进行中的会议号，不能为空
   * 创建会议时，该字段可使用通过{@link NEMeetingAccountService#getAccountInfo}返回的个人会议号，或者不指定(置空)。
   * 当不指定会议号创建会议时，由服务端随机分配一个会议号
   */
  meetingNum?: string
  /** 会议中的成员标签，自定义，最大长度1024 */
  tag?: string
  /** 会议密码 */
  password?: string
  /** 媒体流加密配置 */
  encryptionConfig?: NEEncryptionConfig
  /** 水印配置 */
  watermarkConfig?: NEWatermarkConfig
}
export type NEStartMeetingParams = NEMeetingParams & {
  subject?: string

  /** 透传额外字段，可空，最大长度为 2K。 如果设置，可通过 {@link NEMeetingInfo#extraData} 获取。 */
  extraData?: string

  /** 音视频控制 */
  controls?: NEMeetingControl[]

  /**
   * 成员入会后全体关闭视频，且不允许自主打开，默认允许打开
   */
  attendeeVideoOff?: boolean
  /**
   * 成员入会后全体静音，且不允许自主打开，默认允许打开
   */
  attendeeAudioOff?: boolean

  /** 预设置会议成员角色，key需要设置为成员账号，value设置为成员角色 */
  roleBinds?: Record<string, NEMeetingRoleType>
}

export enum NEWindowMode {
  Normal = 1,
  Whiteboard = 2,
}
export type NEMeetingOptions = {
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

  /** 配置是否在会议界面中显示参会时长，默认为false */
  showParticipationTime?: boolean
  /** 配置是否开启语音激励，默认为true */
  enableSpeakerSpotlight?: boolean

  /** 配置是否开启隐藏未入会成员，默认为false */
  enableShowNotYetJoinedMembers?: boolean

  /** 配置会议中是否显示"邀请"按钮，默认为false，即显示*/
  noInvite?: boolean

  /** 配置新聊天消息提醒类型 */
  chatMessageNotificationType?: NEChatMessageNotificationType

  /** 配置是否始终在视频画面上显示名字，默认显示 */
  showNameInVideo?: boolean

  /** 配置会议中是否显示"sip"功能菜单，默认为false，即显示*/
  noSip?: boolean

  /** 配置会议中是否显示"聊天"按钮，默认为false，即显示*/
  noChat?: boolean

  /** 配置会议中是否显示"切换摄像头"按钮，默认为false，即显示 */
  noSwitchCamera?: boolean

  /** 配置会中是否展示“转写”菜单，默认展示。 */
  noTranscription?: boolean

  /**
   *  配置会中插件通知弹窗持续时间，单位毫秒(ms)，默认5000ms；value=0时，不显示通知弹窗；value<0时，弹窗不自动消失。
   */
  pluginNotifyDuration?: number

  /** 配置会议中是否开启前置摄像头视频镜像，默认开启 */
  enableFrontCameraMirror?: boolean

  /** 配置会议中是否显示"切换音频模式"按钮，默认为false，即显示 */
  noSwitchAudioMode?: boolean

  /** 配置会议中是否显示"共享白板"按钮, 默认false，即显示*/
  noWhiteBoard?: boolean

  /** 配置会议中是否显示"改名"菜单, 默认false，即显示 */
  noRename?: boolean

  /** 配置是否在会议界面中显示"直播"入口, 默认false，即显示  */
  noLive?: boolean

  /**
   * 配置会议中是否展示"字幕"菜单，默认展示。
   */
  noCaptions?: boolean

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
  showMemberTag?: boolean

  /** 是否开启麦克风静音检测，默认开启。 开启该功能后，SDK 在检测到麦克风有音频输入，但此时处于静音打开的状态时，会提示用户关闭静音。 */
  detectMutedMic?: boolean

  /** 配置默认会议模式{@link NEWindowMode} */
  defaultWindowMode?: NEWindowMode

  /** 会中"会议号"显示规则，默认为 {@link NEMeetingIdDisplayOption#DISPLAY_ALL} */
  meetingIdDisplayOption?: NEMeetingIdDisplayOption

  /**
   * 配置会议内"Toolbar"菜单列表中的菜单项。通过提供一个完整的菜单列表，其中可包含SDK内置菜单和自定义注入菜单，SDK会根据该列表排序依次显示对应菜单项，并在自定义菜单点击时触发对应回调。该配置仅会议前设置生效，会议过程中修改列表不会触发更新。
   *
   * <p>注意：部分SDK内置菜单<b>只支持</b>在Toolbar菜单列表中显示，不能放入"更多"菜单列表中，且Toolbar菜单列表最多允许同时显示<b>4</b>个菜单项，即max(VISIBLE_ALWAYS
   * + VISIBLE_EXCLUDE_HOST, VISIBLE_ALWAYS + VISIBLE_TO_HOST_ONLY) &le; 4
   *
   * @see NESingleStateMenuItem
   * @see NECheckableMenuItem
   * @ see
   *     NEMeetingService#setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener)
   */
  fullToolbarMenuItems?: Array<
    NEMeetingMenuItem | NESingleStateMenuItem | NECheckableMenuItem
  >

  /**
   * 配置会议内"更多"菜单列表中的菜单项。通过提供一个完整的菜单列表，其中可包含SDK内置菜单和自定义注入菜单，SDK会根据该列表排序依次显示对应菜单项，并在自定义菜单点击时触发对应回调。该配置仅会议前设置生效，会议过程中修改列表不会触发更新。
   *
   * <p>注意：部分SDK内置菜单<b>只支持</b>在"更多"菜单列表中显示，且"更多"菜单列表最多允许配置同时显示<b>10</b>个菜单项，即max(VISIBLE_ALWAYS +
   * VISIBLE_EXCLUDE_HOST, VISIBLE_ALWAYS + VISIBLE_TO_HOST_ONLY) &le; 10
   *
   * @see NESingleStateMenuItem
   * @see NECheckableMenuItem
   * @ see
   *     NEMeetingService#setOnInjectedMenuItemClickListener(NEMeetingOnInjectedMenuItemClickListener)
   */
  fullMoreMenuItems?: Array<
    NEMeetingMenuItem | NESingleStateMenuItem | NECheckableMenuItem
  >

  /// "成员列表菜单操作项"自定义菜单，可添加监听器处理菜单点击事件
  memberActionMenuItems?: Array<
    NEMeetingMenuItem | NESingleStateMenuItem | NECheckableMenuItem
  >

  /**
   * 超时时间，单位毫秒(ms)，默认为 45000ms。
   */
  joinTimeout?: number

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

  /** 是否能够通过长按空格解除静音 */
  enableUnmuteBySpace?: boolean

  /** 是否始终显示工具栏 */
  enableFixedToolbar?: boolean

  /** 是否开启本端镜像 默认为true 镜像 */
  enableVideoMirror?: boolean

  /*
   * 配置主持人和联席主持人是否可以直接开关参会者的音视频，不需要参会者同意，默认需要参会者同意。
   */
  enableDirectMemberMediaControlByHost?: boolean

  /** 配置成员离开会议是否需要弹窗确认 */
  enableLeaveTheMeetingRequiresConfirmation?: boolean
}

/** 自定义菜单按钮点击事件监听器，通过{@link NEMeetingService#setOnInjectedMenuItemClickListener}方法设置监听器 */
export type NEMeetingOnInjectedMenuItemClickListener = {
  /**
   * 自定义菜单按钮点击事件回调，其中clickInfo携带当前菜单项的点击信息，包括菜单Id与当前状态。
   *
   * @param clickInfo 当前点击的菜单项信息
   * @param meetingInfo 当前会议信息
   */
  onInjectedMenuItemClick(
    clickInfo: NEMenuClickInfo,
    meetingInfo: NEMeetingInfo
  )
}

export type NEMenuClickInfo = {
  /** 菜单Id */
  itemId: number
  /** 菜单状态 */
  state: number
  /** 菜单是否被选中 */
  isChecked: boolean
  /** 菜单类型 */
  type: MenuClickType
}

export enum MenuClickType {
  Base,
  Stateful,
}

/**
 * 提供创建和加入会议时必要的基本配置信息和选项开关，通过这些配置和选项可控制入会时的行为，如音视频的开启状态等
 */
export type NEStartMeetingOptions = NEMeetingOptions & {
  /** @deprecated 请使用 {@link NEStartMeetingOptions#cloudRecordConfig} */
  noCloudRecord?: boolean
  /** 云录制配置 */
  cloudRecordConfig?: NECloudRecordConfig
  /** 配置会议是否默认开启等候室。如果初始设置为不开启，管理员也可以后续在会中手动开启/关闭等候室。 开启等候室后，参会者需要管理员同意后才能加入会议。默认为false */
  enableWaitingRoom?: boolean

  /** 配置是否允许访客入会 默认为false*/
  enableGuestJoin?: boolean
}
export type NEJoinMeetingOptions = NEMeetingOptions

interface NEMeetingService {
  /**
   * 开始一个新的会议，只有完成SDK的登录鉴权操作才允许创建会议。
   * @param param 会议参数对象，不能为空
   * @param opts 会议选项对象，可空；当未指定时，会使用默认的选项
   */
  startMeeting(
    param: NEStartMeetingParams,
    opts?: NEStartMeetingOptions
  ): Promise<NEResult<void>>
  /**
   * 加入一个当前正在进行中的会议，已登录或未登录均可加入会议。
   * 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
   * @param param 会议参数对象，不能为空
   * @param opts 会议选项对象，可空；当未指定时，会使用默认的选项
   */
  joinMeeting(
    param: NEJoinMeetingParams,
    opts?: NEJoinMeetingOptions
  ): Promise<NEResult<void>>
  /**
   * 匿名加入一个当前正在进行中的会议
   * 加入会议成功后，SDK会拉起会议页面，调用方不用做其他操作
   * @param param 会议参数对象，不能为空
   * @param opts 会议选项对象，可空；当未指定时，会使用默认的选项
   */
  anonymousJoinMeeting(
    param: NEJoinMeetingParams,
    opts?: NEJoinMeetingOptions
  ): Promise<NEResult<void>>
  /**
   * 添加自定义注入菜单按钮的点击事件监听
   *
   * @param listener 事件监听器
   */
  setOnInjectedMenuItemClickListener(
    listener: NEMeetingOnInjectedMenuItemClickListener
  ): void

  /**
   * 更新当前存在的自定义菜单项的状态 注意：该接口更新菜单项的文本(最长为10，超过不生效)
   *
   * @param item 当前已存在的菜单项
   */
  updateInjectedMenuItem(
    item: NEMeetingMenuItem | NESingleStateMenuItem | NECheckableMenuItem
  ): Promise<NEResult<void>>
  /**
   * 获取当前的会议状态，会议状态的定义参考
   *
   * @return 会议状态
   */
  getMeetingStatus(): Promise<NEResult<NEMeetingStatus>>

  /**
   * 获取当前会议详情。如果当前无正在进行中的会议，则返回undefined
   *
   */
  getCurrentMeetingInfo(): Promise<NEResult<NEMeetingInfo>>
  /**
   * 添加会议状态监听实例，用于接收会议状态变更通知
   *
   * @param listener 要添加的监听实例
   */
  addMeetingStatusListener(listener: NEMeetingStatusListener): void
  /**
   * 移除对应的会议状态的监听实例
   *
   * @param listener 要移除的监听实例
   */
  removeMeetingStatusListener(listener: NEMeetingStatusListener): void
  /**
   * 离开当前进行中的会议，并通过参数控制是否同时结束当前会议；
   *
   * 只有主持人才能结束会议，其他用户设置结束会议无效；
   *
   * 如果退出当前会议后，会议中再无其他成员，则该会议也会结束；
   *
   * @param closeIfHost true：结束会议；false：不结束会议；
   */
  leaveCurrentMeeting(closeIfHost: boolean): Promise<NEResult<void>>
}

export default NEMeetingService
