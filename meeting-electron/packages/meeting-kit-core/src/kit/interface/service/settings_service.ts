import { NEResult } from 'neroom-types'
import { NECloudRecordConfig, NELocalRecordConfig } from '../../../types'

export { NECloudRecordConfig, NELocalRecordConfig }

/**
 * 字幕/转写目标翻译语言枚举
 */
export enum NEMeetingASRTranslationLanguage {
  ///
  /// 不翻译
  ///
  none = 0,

  ///
  /// 中文
  ///
  chinese = 1,

  ///
  /// 英文
  ///
  english = 2,

  ///
  /// 日文
  ///
  japanese = 3,
}

/// 聊天消息提醒类型
export enum NEChatMessageNotificationType {
  /// 弹幕
  barrage = 0,

  /// 气泡
  bubble = 1,

  /// 不提醒
  noRemind = 2,
}

interface NESettingsService {
  /**
   * 打开设置窗口
   */
  openSettingsWindow(type?: string): Promise<NEResult<void>>
  /**
   * 设置聊天新消息提醒类型
   *
   * @param type 聊天新消息提醒类型
   */
  setChatMessageNotificationType: (
    type: NEChatMessageNotificationType
  ) => Promise<NEResult<void>>
  /**
   * 查询聊天新消息提醒类型
   *
   * @param type 聊天新消息提醒类型
   */
  getChatMessageNotificationType: () => Promise<
    NEResult<NEChatMessageNotificationType>
  >
  /**
   * 设置是否显示参会时长
   *
   * @param enable true-开启，false-关闭
   */
  enableShowMyMeetingParticipationTime: (
    enable: boolean
  ) => Promise<NEResult<void>>
  /**
   * 查询显示参会时长功能开启状态
   */
  isShowMyMeetingParticipationTimeEnabled: () => Promise<NEResult<boolean>>
  /**
   * 设置是否显示会议时长
   *
   * @param enable true-开启，false-关闭
   */
  enableShowMyMeetingElapseTime: (enable: boolean) => Promise<NEResult<void>>
  /**
   * 查询显示会议时长功能开启状态
   */
  isShowMyMeetingElapseTimeEnabled: () => Promise<NEResult<boolean>>
  /**
   *  开启或关闭音频智能降噪
   * @param enable
   */
  enableAudioAINS: (enable: boolean) => Promise<NEResult<void>>
  /**
   * 查询音频智能降噪开启状态
   */
  isAudioAINSEnabled: () => Promise<NEResult<boolean>>
  /**
   * 设置入会时是否打开本地视频
   *
   * @param enable true: 开启本地视频 false: 关闭本地视频
   */
  enableTurnOnMyVideoWhenJoinMeeting: (
    enable: boolean
  ) => Promise<NEResult<void>>
  /**
   * 查询入会时本地视频开关状态
   */
  isTurnOnMyVideoWhenJoinMeetingEnabled: () => Promise<NEResult<boolean>>
  /**
   * 设置入会时是否打开本地音频
   *
   * enable true-入会时打开音频，false-入会时关闭音频
   */
  enableTurnOnMyAudioWhenJoinMeeting: (
    enable: boolean
  ) => Promise<NEResult<void>>
  /*
   * 查询入会时本地音频开关状态
   */
  isTurnOnMyAudioWhenJoinMeetingEnabled: () => Promise<NEResult<boolean>>
  /**
   * 查询美颜服务开关状态，关闭在隐藏会中美颜按钮
   */
  isBeautyFaceSupported: () => Promise<NEResult<boolean>>
  /**
   * 设置美颜服务开关状态
   */
  getBeautyFaceValue: () => Promise<NEResult<number>>
  /**
   * 设置美颜参数
   * @param value 传入美颜等级，参数规则为[0,10]整数
   */
  setBeautyFaceValue: (value: number) => Promise<NEResult<void>>
  /**
   * 查询会议是否拥有直播权限
   */
  isMeetingLiveSupported: () => Promise<NEResult<boolean>>
  /**
   * 查询是否拥有上传头像权限
   */
  isAvatarUpdateSupported: () => Promise<NEResult<boolean>>

  /**
   * 查询是否支持字幕
   */
  isCaptionsSupported: () => Promise<NEResult<boolean>>

  /**
   * 查询是否支持转写
   */
  isTranscriptionSupported: () => Promise<NEResult<boolean>>

  /**
   * 查询是否拥有修改昵称权限
   */
  isNicknameUpdateSupported: () => Promise<NEResult<boolean>>
  /**
   * 是否支持访客入会
   */
  isGuestJoinSupported: () => Promise<NEResult<boolean>>
  /**
   * 查询应用是否支持聊天室服务
   */
  isMeetingChatSupported: () => Promise<NEResult<boolean>>

  /** 查询应用session会话Id */
  getAppNotifySessionId: () => Promise<NEResult<string>>
  /**
   * 查询应用是否支持等候室
   */
  isWaitingRoomSupported: () => Promise<NEResult<boolean>>
  /**
   * 查询白板功能是否开启
   */
  isMeetingWhiteboardSupported: () => Promise<NEResult<boolean>>
  /**
   * 查询云端录制服务开关状态
   */
  isMeetingCloudRecordSupported: () => Promise<NEResult<boolean>>
  /**
   * 虚拟背景是否显示
   * @param enable
   */
  enableVirtualBackground: (enable: boolean) => Promise<NEResult<void>>
  /**
   * 查询虚拟背景是否开启
   */
  isVirtualBackgroundEnabled: () => Promise<NEResult<boolean>>
  /**
   * 查询虚拟背景是否支持
   */
  isVirtualBackgroundSupported: () => Promise<NEResult<boolean>>
  /**
   * 设置内置虚拟背景图片路径列表
   *
   * @param pathList 虚拟背景图片路径列表
   */
  setBuiltinVirtualBackgroundList: (
    pathList: string[]
  ) => Promise<NEResult<void>>
  /**
   * 获取内置虚拟背景图片路径列表
   */
  getBuiltinVirtualBackgroundList(): Promise<NEResult<string[]>>
  /**
   * 设置最近选择的虚拟背景图片路径
   *
   * @param path 虚拟背景图片路径,为空代表不设置虚拟背景
   */
  setCurrentVirtualBackground(path: string): Promise<NEResult<void>>
  /**
   * 获取最近选择的虚拟背景图片路径
   */
  getCurrentVirtualBackground(): Promise<NEResult<string>>
  /**
   * 设置外部虚拟背景图片路径列表
   *
   * @param pathList 虚拟背景图片路径列表
   */
  setExternalVirtualBackgroundList(pathList: string[]): Promise<NEResult<void>>
  /**
   * 获取外部虚拟背景图片路径列表
   */
  getExternalVirtualBackgroundList(): Promise<NEResult<string[]>>
  /**
   * 设置是否打开语音激励
   *
   * @param enable true-开启，false-关闭
   */
  enableSpeakerSpotlight: (enable: boolean) => Promise<NEResult<void>>

  /**
   * 设置是否隐藏未入会成员
   *
   * @param enable true-开启，false-关闭
   */
  enableShowNotYetJoinedMembers: (enable: boolean) => Promise<NEResult<void>>

  /**
   * 查询是否设置隐藏未入会成员
   */
  isShowNotYetJoinedMembersEnabled(): Promise<NEResult<boolean>>

  /**
   * 查询是否打开语音激励
   */
  isSpeakerSpotlightEnabled: () => Promise<NEResult<boolean>>

  /**
   * 设置是否打开白板透明
   *
   * @param enable true-开启，false-关闭
   */
  enableTransparentWhiteboard(enable: boolean): Promise<NEResult<void>>
  /**
   * 查询是否开启透明白板
   */
  isTransparentWhiteboardEnabled: () => Promise<NEResult<boolean>>
  /**
   * 设置是否打开摄像头镜像
   *
   * @param enable true-开启，false-关闭
   */
  enableCameraMirror(enable: boolean): Promise<NEResult<void>>
  /**
   * 查询摄像头镜像是否打开
   */
  isCameraMirrorEnabled(): Promise<NEResult<boolean>>
  /**
   * 设置是否打开前置摄像头镜像(仅H5支持)
   *
   * @param enable true-开启，false-关闭
   */
  enableFrontCameraMirror(enable: boolean): Promise<NEResult<void>>
  /**
   * 查询是否开启共享时开启摄像头
   */
  isFrontCameraMirrorEnabled: () => Promise<NEResult<boolean>>

  /** 查询应用同声传译配置 */
  getInterpretationConfig(): Promise<NEResult<NEInterpretationConfig>>

  /** 查询应用预约会议指定成员配置 */
  getScheduledMemberConfig(): Promise<NEResult<ScheduledMemberConfig>>

  /** 获取云录制配置 */
  getCloudRecordConfig(): Promise<NEResult<NECloudRecordConfig>>
  /**
   * 设置云录制配置
   * @param config 云录制配置
   */
  setCloudRecordConfig(config: NECloudRecordConfig): Promise<NEResult<void>>

  /** 获取本地录制配置 */
  getLocalRecordConfig(): Promise<NEResult<NELocalRecordConfig>>
  /**
   * 设置本地录制配置
   * @param config 本地录制配置
   */
  setLocalRecordConfig(config: NELocalRecordConfig): Promise<NEResult<void>>
  /**
   * 设置应用聊天室默认文件下载保存路径
   * @param filePath 聊天室文件保存路径
   */
  setChatroomDefaultFileSavePath: (filePath: string) => Promise<NEResult<void>>
  /**
   * 查询应用聊天室文件下载默认保存路径
   */
  getChatroomDefaultFileSavePath: () => Promise<NEResult<string>>
  /**
   * 设置画廊模式下单屏显示最大画面数量
   * @param count 最大显示人数目前支持9人或者16人
   */
  setGalleryModeMaxMemberCount: (count: 9 | 16) => Promise<NEResult<void>>
  /**
   * 设置是否支持静音时长按空格暂时开启麦克风
   * @param enable 是否开启
   */
  enableUnmuteAudioByPressSpaceBar: (enable: boolean) => Promise<NEResult<void>>
  /**
   * 查询是否支持静音时长按空格暂时开启麦克风
   */
  isUnmuteAudioByPressSpaceBarEnabled: () => Promise<NEResult<boolean>>
  /**
   * 设置会中字幕/转写翻译语言
   * @param language
   */
  setASRTranslationLanguage(
    language: NEMeetingASRTranslationLanguage
  ): Promise<NEResult<number>>
  /**
   * 获取会中字幕/转写翻译语言
   */
  getASRTranslationLanguage(): Promise<
    NEResult<NEMeetingASRTranslationLanguage>
  >
  /**
   * 开启会中字幕同时显示双语
   * @param enable true-开启，false-关闭
   */
  enableCaptionBilingual(enable: boolean): Promise<NEResult<number>>

  /**
   * 查询会中字幕同时显示双语是否开启
   */
  isCaptionBilingualEnabled(): Promise<NEResult<boolean>>
  /**
   * 开启会中转写同时显示双语
   * @param enable true-开启，false-关闭
   */
  enableTranscriptionBilingual(enable: boolean): Promise<NEResult<number>>

  /**
   * 查询会中转写同时显示双语是否开启
   */
  isTranscriptionBilingualEnabled(): Promise<NEResult<boolean>>
  /**
   * 设置是否在视频中显示用户名
   * @param enable 是否显示
   */
  enableShowNameInVideo(enable: boolean): Promise<NEResult<void>>
  /**
   * 查询是否在视频中显示用户名
   */
  isShowNameInVideoEnabled(): Promise<NEResult<boolean>>
  /**
   * 设置开启/关闭隐藏非视频参会者
   * @param enable 是否显示
   */
  enableHideVideoOffAttendees(enable: boolean): Promise<NEResult<void>>
  /**
   * 查询是否开启隐藏非视频参会者
   */
  isHideVideoOffAttendeesEnabled(): Promise<NEResult<boolean>>
  /**
   * 设置开启/关闭隐藏本人视图
   * @param enable 是否显示
   */
  enableHideMyVideo(enable: boolean): Promise<NEResult<void>>
  /**
   * 查询是否开启隐藏本人视图
   */
  isHideMyVideoEnabled(): Promise<NEResult<boolean>>
  /**
   * 设置是否离开会议需要弹窗确认
   * @param enable 是否显示
   */
  enableLeaveTheMeetingRequiresConfirmation(
    enable: boolean
  ): Promise<NEResult<void>>
  /**
   * 查询是否离开会议需要弹窗确认
   */
  isLeaveTheMeetingRequiresConfirmationEnabled(): Promise<NEResult<boolean>>
  /**
   * 查询应用是否支持会议设备邀请
   */
  isCallOutRoomSystemDeviceSupported(): Promise<NEResult<boolean>>
  /**
   * 获取第三方推流最大设置个数
   */
  getLiveMaxThirdPartyCount(): Promise<NEResult<number>>

  /**
   * 是否屏幕共享开启并排模式
   * @param enable 是否开启
   */
  enableSideBySideMode(enable: boolean): Promise<NEResult<void>>
  /**
   * 查询是否开启并排模式
   */
  isSideBySideModeEnabled(): Promise<NEResult<boolean>>
  /**
   * 查询直播官方推流是否支持
   */
  isMeetingLiveOfficialPushSupported: () => Promise<NEResult<boolean>>
  /**
   * 查询直播第三方推流是否支持
   */
  isMeetingLiveThirdPartyPushSupported: () => Promise<NEResult<boolean>>
}

export type NEInterpretationConfig = {
  enable: boolean
  maxInterpreters: number
  enableCustomLang: boolean
  maxCustomLangNameLen: number
  defMajorAudioVolume: number
}
export type ScheduledMemberConfig = {
  /** 应用是否支持预约会议指定成员 */
  enable: boolean
  /** 预约会议指定成员最大数量 */
  scheduleMemberMax: number
  /** 预约会议指定联席主持人最大数量 */
  coHostLimit: number
}
export default NESettingsService
