import {
  FailureBody,
  NEResult,
  NERoomCaptionTranslationLanguage,
  SuccessBody,
} from 'neroom-types'
import { MAJOR_DEFAULT_VOLUME } from '../../../config'
import {
  createDefaultCaptionSetting,
  createDefaultSetting,
} from '../../../services'
import NEMeetingService from '../../../services/NEMeeting'
import {
  MeetingSetting,
  NECloudRecordConfig,
  NECloudRecordStrategyType,
} from '../../../types'
import {
  ASRTranslationLanguageToString,
  getLocalStorageSetting,
  setLocalStorageSetting,
  toASRTranslationLanguage,
} from '../../../utils'
import { Logger } from '../../../utils/Logger'
import NESettingsServiceInterface, {
  NEChatMessageNotificationType,
  NEInterpretationConfig,
  NEMeetingASRTranslationLanguage,
  ScheduledMemberConfig,
} from '../../interface/service/settings_service'
import { z, ZodError } from 'zod'

export default class NESettingsService implements NESettingsServiceInterface {
  private _logger: Logger
  private _neMeeting: NEMeetingService

  constructor(params: { logger: Logger; neMeeting: NEMeetingService }) {
    this._logger = params.logger
    this._neMeeting = params.neMeeting
  }

  async openSettingsWindow(type?: string): Promise<NEResult<void>> {
    try {
      const enableSchema = z.string().optional()

      enableSchema.parse(type)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      return FailureBody(undefined, error.message)
    }

    this._neMeeting.openSettingsWindow(type)

    return SuccessBody(void 0)
  }

  async isMeetingChatSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE.chatroom
    )
  }

  async setChatMessageNotificationType(
    type: NEChatMessageNotificationType
  ): Promise<NEResult<void>> {
    const settings = this.getLocalSettings()

    settings.normalSetting.chatMessageNotificationType = type

    this.setLocalSettings(settings)
    return SuccessBody(void 0)
  }

  async getChatMessageNotificationType(): Promise<
    NEResult<NEChatMessageNotificationType>
  > {
    const settings = this.getLocalSettings()

    return SuccessBody(settings.normalSetting.chatMessageNotificationType ?? 0)
  }

  async setGalleryModeMaxMemberCount(count: 9 | 16): Promise<NEResult<void>> {
    try {
      const countSchema = z.number()

      countSchema.parse(count)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    if (count !== 9 && count !== 16) {
      throw FailureBody(undefined, 'count must be 9 or 16')
    }

    const settings = this.getLocalSettings()

    settings.videoSetting.galleryModeMaxCount = count

    this.setLocalSettings(settings)
    return SuccessBody(void 0)
  }

  async enableUnmuteAudioByPressSpaceBar(
    enable: boolean
  ): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.audioSetting.enableUnmuteBySpace = enable

    this.setLocalSettings(settings)
    return SuccessBody(void 0)
  }

  async isUnmuteAudioByPressSpaceBarEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.audioSetting.enableUnmuteBySpace)
  }

  async getCloudRecordConfig(): Promise<NEResult<NECloudRecordConfig>> {
    const settings = this.getLocalSettings()

    return SuccessBody({
      enable: settings.recordSetting.autoCloudRecord,
      recordStrategy: settings.recordSetting.autoCloudRecordStrategy,
    })
  }

  async setCloudRecordConfig(
    config: NECloudRecordConfig
  ): Promise<NEResult<void>> {
    try {
      const configSchema = z.object({
        enable: z.boolean(),
        recordStrategy: z.nativeEnum(NECloudRecordStrategyType),
      })

      configSchema.parse(config)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.recordSetting.autoCloudRecord = config.enable
    settings.recordSetting.autoCloudRecordStrategy = config.recordStrategy

    this.setLocalSettings(settings)
    return SuccessBody(void 0)
  }

  /** 查询应用session会话Id */
  async isGuestJoinSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE.guest
    )
  }

  /** 查询应用session会话Id */
  async getAppNotifySessionId(): Promise<NEResult<string>> {
    return SuccessBody(
      this._neMeeting.globalConfig?.appConfig.notifySenderAccid || ''
    )
  }

  /**
   * 查询应用预约会议指定成员配置
   */
  async getScheduledMemberConfig(): Promise<NEResult<ScheduledMemberConfig>> {
    const scheduleConfig = this._neMeeting.globalConfig?.appConfig
      .MEETING_SCHEDULED_MEMBER_CONFIG

    if (scheduleConfig) {
      return SuccessBody({
        enable: scheduleConfig.enable,
        scheduleMemberMax: scheduleConfig.max,
        coHostLimit: scheduleConfig.coHostLimit,
      })
    } else {
      return SuccessBody({
        enable: false,
        scheduleMemberMax: 0,
        coHostLimit: 0,
      })
    }
  }

  /** 查询应用同声传译配置 */
  async getInterpretationConfig(): Promise<NEResult<NEInterpretationConfig>> {
    const interpretationConfig = this._neMeeting.globalConfig?.appConfig
      .APP_ROOM_RESOURCE.interpretation

    if (interpretationConfig) {
      return SuccessBody({
        enable: interpretationConfig.enable,
        maxInterpreters: interpretationConfig.maxInterpreters,
        enableCustomLang: interpretationConfig.enableCustomLang,
        maxCustomLangNameLen: interpretationConfig.maxCustomLanguageLength,
        defMajorAudioVolume: MAJOR_DEFAULT_VOLUME,
      })
    } else {
      return SuccessBody({
        enable: false,
        maxInterpreters: 0,
        enableCustomLang: false,
        maxCustomLangNameLen: 0,
        defMajorAudioVolume: 0,
      })
    }
  }
  /**
   * 设置是否显示会议时长
   * @param enable true-开启，false-关闭
   */
  async enableShowMyMeetingParticipationTime(
    enable: boolean
  ): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.normalSetting.showParticipationTime = enable

    this.setLocalSettings(settings)
    return SuccessBody(void 0)
  }
  /**
   * 查询是否显示参会时长
   */
  async isShowMyMeetingParticipationTimeEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.normalSetting.showParticipationTime)
  }
  /**
   * 设置是否显示会议时长
   * @param enable true-开启，false-关闭
   */
  async enableShowMyMeetingElapseTime(
    enable: boolean
  ): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.normalSetting.showDurationTime = enable

    this.setLocalSettings(settings)
    return SuccessBody(void 0)
  }

  /**
   * 查询是否显示会议时长
   */
  async isShowMyMeetingElapseTimeEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.normalSetting.showDurationTime)
  }

  /**
   * 设置是否打开音频智能降噪
   *
   * @param enable true-开启，false-关闭
   */
  async enableAudioAINS(enable: boolean): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.audioSetting.enableAudioAI = enable

    this.setLocalSettings(settings)
    return SuccessBody(void 0)
  }

  /**
   * 查询音频智能降噪是否打开
   */
  async isAudioAINSEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.audioSetting.enableAudioAI)
  }

  /*
   * 设置入会时是否打开本地视频
   *
   * @param enable true-入会时打开视频，false-入会时关闭视频
   */
  async enableTurnOnMyVideoWhenJoinMeeting(
    enable: boolean
  ): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.normalSetting.openVideo = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 查询入会时是否打开本地视频
   */
  async isTurnOnMyVideoWhenJoinMeetingEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.normalSetting.openVideo)
  }

  /**
   * 查询是否支持转写
   */
  async isTranscriptionSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE.transcript ===
        true
    )
  }

  /**
   * 设置入会时是否打开本地音频
   * @param enable true-入会时打开音频，false-入会时关闭音频
   */
  async enableTurnOnMyAudioWhenJoinMeeting(
    enable: boolean
  ): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.normalSetting.openAudio = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 查询入会时是否打开本地音频
   */
  async isTurnOnMyAudioWhenJoinMeetingEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.normalSetting.openAudio)
  }

  /**
   * 查询应用是否支持美颜
   */
  async isBeautyFaceSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig?.MEETING_BEAUTY?.enable
    )
  }

  /**
   * 获取当前美颜参数，关闭返回0
   */
  async getBeautyFaceValue(): Promise<NEResult<number>> {
    const settings = this.getLocalSettings()

    return SuccessBody(settings.beautySetting.beautyLevel)
  }

  /**
   * 设置美颜参数
   *
   * @param value 传入美颜等级，参数规则为[0,10]整数
   */
  async setBeautyFaceValue(value: number): Promise<NEResult<void>> {
    try {
      const valueSchema = z.number()

      valueSchema.parse(value)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.beautySetting.beautyLevel = value

    this.setLocalSettings(settings)
    return SuccessBody(void 0)
  }

  /**
   * 查询应用是否支持会议直播
   */
  async isMeetingLiveSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE.live
    )
  }

  /*
   * 查询应用是否支持编辑头像
   */
  async isAvatarUpdateSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !this._neMeeting.globalConfig?.appConfig.MEETING_ACCOUNT_CONFIG
        .avatarUpdateDisabled === true
    )
  }

  /**
   *
   * 查询应用是否支持字幕
   */
  async isCaptionsSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE.caption === true
    )
  }

  /*
   * 查询应用是否支持编辑昵称
   */
  async isNicknameUpdateSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !this._neMeeting.globalConfig?.appConfig.MEETING_ACCOUNT_CONFIG
        .nicknameUpdateDisabled === true
    )
  }

  /**
   * 查询应用是否支持等候室
   */
  async isWaitingRoomSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE.waitingRoom
    )
  }

  /**
   * 查询应用是否支持白板共享
   */
  async isMeetingWhiteboardSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE.whiteboard
    )
  }

  /**
   * 查询应用是否支持云端录制服务
   */
  async isMeetingCloudRecordSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE.record
    )
  }

  /**
   * 设置是否显示虚拟背景
   *
   * @param enable true-打开，false-关闭
   */
  async enableVirtualBackground(enable: boolean): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.beautySetting.enableVirtualBackground = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 查询虚拟背景是否支持
   */
  async isVirtualBackgroundEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.beautySetting.enableVirtualBackground)
  }

  /**
   * 查询虚拟背景是否支持
   */
  async isVirtualBackgroundSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig?.MEETING_VIRTUAL_BACKGROUND
        ?.enable
    )
  }

  /**
   * 设置内置虚拟背景图片路径列表
   *
   * @param pathList 虚拟背景图片路径列表
   */
  async setBuiltinVirtualBackgroundList(
    pathList: string[]
  ): Promise<NEResult<void>> {
    try {
      const pathListSchema = z.array(z.string())

      pathListSchema.parse(pathList)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.beautySetting.virtualBackgroundList = pathList

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /*
   * 获取内置虚拟背景图片路径列表
   */
  async getBuiltinVirtualBackgroundList(): Promise<NEResult<string[]>> {
    const settings = this.getLocalSettings()

    return SuccessBody(settings.beautySetting.virtualBackgroundList || [])
  }

  /**
   * 设置最近选择的虚拟背景图片路径
   *
   * @param path 虚拟背景图片路径,为空代表不设置虚拟背景
   */
  async setCurrentVirtualBackground(path: string): Promise<NEResult<void>> {
    try {
      const pathSchema = z.string()

      pathSchema.parse(path)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.beautySetting.virtualBackgroundPath = path

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 获取最近选择的虚拟背景图片路径
   */
  async getCurrentVirtualBackground(): Promise<NEResult<string>> {
    const settings = this.getLocalSettings()

    return SuccessBody(settings.beautySetting.virtualBackgroundPath)
  }

  /**
   * 设置外部虚拟背景图片路径列表
   *
   * @param pathList 虚拟背景图片路径列表
   */
  async setExternalVirtualBackgroundList(
    pathList: string[]
  ): Promise<NEResult<void>> {
    try {
      const pathListSchema = z.array(z.string())

      pathListSchema.parse(pathList)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.beautySetting.externalVirtualBackgroundList = pathList

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 获取外部虚拟背景图片路径列表
   */
  async getExternalVirtualBackgroundList(): Promise<NEResult<string[]>> {
    const settings = this.getLocalSettings()

    return SuccessBody(
      settings.beautySetting.externalVirtualBackgroundList || []
    )
  }

  /**
   * 设置是否打开语音激励
   *
   * @param enable true-开启，false-关闭
   */
  async enableSpeakerSpotlight(enable: boolean): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.normalSetting.enableVoicePriorityDisplay = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 查询是否打开语音激励
   */
  async isSpeakerSpotlightEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.normalSetting.enableVoicePriorityDisplay)
  }

  /**
   * 设置是否隐藏未入会成员
   *
   * @param enable true-开启，false-关闭
   */
  async enableShowNotYetJoinedMembers(
    enable: boolean
  ): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.normalSetting.enableShowNotYetJoinedMembers = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 查询是否设置隐藏未入会成员
   */
  async isShowNotYetJoinedMembersEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.normalSetting.enableShowNotYetJoinedMembers)
  }

  /**
   * 设置是否打开白板透明
   *
   * @param enable true-开启，false-关闭
   */
  async enableTransparentWhiteboard(enable: boolean): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.normalSetting.enableTransparentWhiteboard = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 查询白板透明是否打开
   */
  async isTransparentWhiteboardEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.normalSetting.enableTransparentWhiteboard)
  }

  /**
   * 设置是否打开摄像头镜像
   *
   * @param enable true-开启，false-关闭
   */
  async enableCameraMirror(enable: boolean): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.videoSetting.enableVideoMirroring = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /**
   * 查询摄像头镜像是否打开
   */
  async isCameraMirrorEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.videoSetting.enableVideoMirroring)
  }

  /**
   * 设置是否打开前置摄像头镜像
   *
   * @param enable true-开启，false-关闭
   */
  async enableFrontCameraMirror(enable: boolean): Promise<NEResult<void>> {
    try {
      const enableSchema = z.boolean()

      enableSchema.parse(enable)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.videoSetting.enableFrontCameraMirror = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  /*
   * 查询前置摄像头镜像是否打开
   */
  async isFrontCameraMirrorEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.videoSetting.enableFrontCameraMirror)
  }

  /**
   * 设置应用聊天室默认文件下载保存路径
   * @param filePath 聊天室文件保存路径
   */
  async setChatroomDefaultFileSavePath(
    filePath: string
  ): Promise<NEResult<void>> {
    try {
      const pathSchema = z.string()

      pathSchema.parse(filePath)
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const settings = this.getLocalSettings()

    settings.normalSetting.downloadPath = filePath

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }
  /**
   * 查询应用聊天室文件下载默认保存路径
   */
  async getChatroomDefaultFileSavePath(): Promise<NEResult<string>> {
    const settings = this.getLocalSettings()

    return SuccessBody(settings.normalSetting.downloadPath)
  }
  async setASRTranslationLanguage(
    language: NEMeetingASRTranslationLanguage
  ): Promise<NEResult<number>> {
    const settings = this.getLocalSettings()
    const captionSetting =
      settings.captionSetting || createDefaultCaptionSetting()

    captionSetting.targetLanguage = this.toInnerASRTranslationLanguage(language)
    settings.captionSetting = captionSetting
    await this.saveSettingData(settings)
    this.setLocalSettings(settings)

    return SuccessBody(0)
  }
  async getASRTranslationLanguage(): Promise<
    NEResult<NEMeetingASRTranslationLanguage>
  > {
    const settings = this.getLocalSettings()

    return SuccessBody(
      toASRTranslationLanguage(settings.captionSetting.targetLanguage)
    )
  }
  async enableCaptionBilingual(enable: boolean): Promise<NEResult<number>> {
    const settings = this.getLocalSettings()

    settings.captionSetting.showCaptionBilingual = enable

    this.setLocalSettings(settings)

    await this.saveSettingData(settings)
    return SuccessBody(0)
  }
  async isCaptionBilingualEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.captionSetting.showCaptionBilingual)
  }
  async enableTranscriptionBilingual(
    enable: boolean
  ): Promise<NEResult<number>> {
    const settings = this.getLocalSettings()

    settings.captionSetting.showTranslationBilingual = enable

    this.setLocalSettings(settings)

    await this.saveSettingData(settings)
    return SuccessBody(0)
  }
  async isTranscriptionBilingualEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.captionSetting.showTranslationBilingual)
  }
  async enableShowNameInVideo(enable: boolean): Promise<NEResult<void>> {
    const settings = this.getLocalSettings()

    settings.videoSetting.showMemberName = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  async isShowNameInVideoEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.videoSetting.showMemberName)
  }

  async enableHideVideoOffAttendees(enable: boolean): Promise<NEResult<void>> {
    const settings = this.getLocalSettings()

    settings.videoSetting.enableHideVideoOffAttendees = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  async isHideVideoOffAttendeesEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.videoSetting.enableHideVideoOffAttendees)
  }

  async enableHideMyVideo(enable: boolean): Promise<NEResult<void>> {
    const settings = this.getLocalSettings()

    settings.videoSetting.enableHideMyVideo = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  async isHideMyVideoEnabled(): Promise<NEResult<boolean>> {
    const settings = this.getLocalSettings()

    return SuccessBody(!!settings.videoSetting.enableHideMyVideo)
  }

  async enableLeaveTheMeetingRequiresConfirmation(
    enable: boolean
  ): Promise<NEResult<void>> {
    const settings = this.getLocalSettings()

    settings.normalSetting.leaveTheMeetingRequiresConfirmation = enable

    this.setLocalSettings(settings)

    return SuccessBody(void 0)
  }

  async isLeaveTheMeetingRequiresConfirmationEnabled(): Promise<
    NEResult<boolean>
  > {
    const settings = this.getLocalSettings()

    return SuccessBody(
      !!settings.normalSetting.leaveTheMeetingRequiresConfirmation
    )
  }

  async isCallOutRoomSystemDeviceSupported(): Promise<NEResult<boolean>> {
    return SuccessBody(
      !!this._neMeeting.globalConfig?.appConfig.APP_ROOM_RESOURCE
        .callOutRoomSystemDevice
    )
  }

  async getLiveMaxThirdPartyCount(): Promise<NEResult<number>> {
    return SuccessBody(
      this._neMeeting.globalConfig?.appConfig.MEETING_LIVE?.maxThirdPartyNum ||
        5
    )
  }

  private toInnerASRTranslationLanguage(
    lang: NEMeetingASRTranslationLanguage
  ): NERoomCaptionTranslationLanguage {
    const langMap = {
      [NEMeetingASRTranslationLanguage.none]:
        NERoomCaptionTranslationLanguage.NONE,
      [NEMeetingASRTranslationLanguage.chinese]:
        NERoomCaptionTranslationLanguage.CHINESE,
      [NEMeetingASRTranslationLanguage.english]:
        NERoomCaptionTranslationLanguage.ENGLISH,
      [NEMeetingASRTranslationLanguage.japanese]:
        NERoomCaptionTranslationLanguage.JAPANESE,
    }

    return langMap[lang] || NERoomCaptionTranslationLanguage.NONE
  }

  private saveSettingData(setting: MeetingSetting) {
    const captionSetting = setting.captionSetting

    return this._neMeeting.saveSettings({
      beauty: {
        level: setting.beautySetting?.beautyLevel || 0,
      },
      asrTranslationLanguage: ASRTranslationLanguageToString(
        captionSetting?.targetLanguage
      ),
      captionBilingual: !!captionSetting.showCaptionBilingual,
      transcriptionBilingual: !!captionSetting.showTranslationBilingual,
    })
  }

  private getLocalSettings(): MeetingSetting {
    let localeSettings = getLocalStorageSetting()

    if (!localeSettings) {
      const defaultSetting = createDefaultSetting()

      this.setLocalSettings(defaultSetting)
      localeSettings = defaultSetting
    }

    return localeSettings
  }

  private setLocalSettings(settings: MeetingSetting): void {
    try {
      setLocalStorageSetting(JSON.stringify(settings))
    } catch (error) {
      console.warn('setLocalSettings error:', error)
    }
  }
}
