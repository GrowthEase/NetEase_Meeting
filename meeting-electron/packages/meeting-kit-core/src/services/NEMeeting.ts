import { EventPriority, XKitReporter } from '@xkit-yx/utils'
import axios, { AxiosInstance } from 'axios'
import EventEmitter from 'eventemitter3'
import dayjs from 'dayjs'
import {
  AudioProfile,
  DeviceType,
  NEAuthEvent,
  NEAuthService,
  NECrossAppAuthorization,
  NEDeviceBaseInfo,
  NEDeviceSwitchInfo,
  NEMediaTypes,
  NEMessageChannelService,
  NENosService,
  NEPreviewController,
  NEResult,
  NERoomChatController,
  NERoomContext,
  NERoomEndReason,
  NERoomLanguage,
  NERoomLiveController,
  NERoomLiveInfo,
  NERoomLiveRequest,
  NERoomMember,
  NERoomMemberBase,
  NERoomRtcController,
  NERoomRtcScreenCaptureSource,
  NERoomRtcVideoRecvStats,
  NERoomRtcVideoSendStats,
  NERoomService,
  NERoomSipCallResponse,
  NERoomWhiteboardController,
  NERoomAnnotationController,
  Roomkit,
  VideoFrameRate,
  VideoResolution,
  NERoomRtcVideoLayerRecvStats,
  NERoomSIPController,
  NEWaitingRoomMember,
  NECustomSessionMessage,
  NEMessageSearchOrder,
  NEWaitingRoomController,
  NERoomAppInviteController,
  NECommonError,
  SuccessBody,
  NIMImage,
  NERoomKitOptions,
  NERoomCaptionTranslationLanguage,
  NERoomScreenConfig,
  NERoomSystemDevice,
} from 'neroom-types'

import { Md5 } from 'ts-md5/dist/md5'
import { IPCEvent } from '../app/src/types'
import pkg from '../../package.json'
import {
  AccountInfo,
  ActionType,
  AnonymousLoginResponse,
  AttendeeOffType,
  CreateMeetingResponse,
  Dispatch,
  EventType,
  GetMeetingConfigResponse,
  hostAction,
  IMInfo,
  MeetingErrorCode,
  memberAction,
  NEMeetingCreateOptions,
  NEMeetingGetListOptions,
  NEMeetingInitConfig,
  NEMeetingJoinOptions,
  NEMeetingLoginByPasswordOptions,
  NEMeetingLoginByTokenOptions,
  NEMeetingRole,
  NEMember,
  Role,
  SearchAccountInfo,
  StaticReportType,
} from '../types'
import {
  EndRoomReason,
  GetAccountInfoListResponse,
  MeetingEventType,
  PlatformInfo,
  RecordState,
  tagNERoomRtcAudioProfileType,
  tagNERoomRtcAudioScenarioType,
  UserEventType,
  WaitingRoomContextInterface,
  WATERMARK_STRATEGY,
  WATERMARK_STYLE,
} from '../types/innerType'
import {
  EnterPriseInfo,
  InterpretationRes,
  MeetingListItem,
  NEAccountInfo,
  NEClientType,
  NEEncryptionConfig,
  NEHistoryMeetingDetail,
  NEMeetingAppNoticeTip,
  NEMeetingCode,
  NEMeetingInterpretationSettings,
  NEMeetingInterpreter,
  NEMeetingInviteStatus,
  NEMeetingSDK,
  NEMeetingStatus,
  NERoomRecord,
  NEScheduledMember,
  SipMember,
  NEResult as ApiResult,
  NEClientReportType,
  SaveSettingInterface,
  InnerAccountInfo,
  GuestMeetingInfo,
} from '../types/type'
import {
  debounce,
  getDefaultDeviceId,
  getDefaultLanguage,
  getLocalStorageSetting,
  getMeetingPermission,
  getThumbnailUrl,
  md5Password,
  parsePrivateConfig,
  serverLanguageToSettingASRTranslationLanguage,
  setDefaultDevice,
  setLocalStorageSetting,
} from '../utils'
import { Logger } from '../utils/Logger'
import { IntervalEvent } from '../utils/report'
import { getWindow } from '../utils/windowsProxy'
import {
  ACCOUNT_INFO_KEY,
  IM_VERSION,
  MAJOR_AUDIO,
  MAJOR_DEFAULT_VOLUME,
  RTC_VERSION,
} from '../config'
import NEMeetingLiveTranscriptionController from './controller/NEMeetingLiveTranscriptionController'
import {
  NEChatroomHistoryMessageSearchOption,
  NEMeetingChatMessage,
  NEMeetingChatMessageType,
  NEMeetingTranscriptionInfo,
  NEMeetingWebAppItem,
} from '../kit/interface/service/pre_meeting_service'
import { createDefaultCaptionSetting } from '.'
import RendererManager from '../libs/Renderer/RendererManager'

const logger = new Logger('Meeting-NeMeeting', true)

export function updateMeetingService(
  neMeeting: NEMeetingService | null,
  dispatch: Dispatch
): void {
  const meeting = neMeeting?.getMeetingInfo()

  console.log('获取会议信息', meeting)
  meeting &&
    dispatch({
      type: ActionType.SET_MEETING,
      data: meeting,
    })
}

interface ResponseData {
  code: number
  data
  msg: string
  requestId: string
  cost: string
}

export type MonitoringDataItem = {
  time: number
  value: number
}

export type MonitoringData = {
  network: {
    rtt: MonitoringDataItem[]
    packetLossRate: MonitoringDataItem[]
  }
  audio: {
    recordVolume: MonitoringDataItem[]
    playVolume: MonitoringDataItem[]
    audioTxBitrate: MonitoringDataItem[]
    audioRxBitrate: MonitoringDataItem[]
  }
  video: {
    videoTxBitrate: MonitoringDataItem[]
    videoRxBitrate: MonitoringDataItem[]
  }
  screen: {
    screenTxBitrate: MonitoringDataItem[]
    screenRxBitrate: MonitoringDataItem[]
  }
}

const monitoringData: MonitoringData = {
  network: {
    rtt: [],
    packetLossRate: [],
  },
  audio: {
    recordVolume: [],
    playVolume: [],
    audioTxBitrate: [],
    audioRxBitrate: [],
  },
  video: {
    videoTxBitrate: [],
    videoRxBitrate: [],
  },
  screen: {
    screenTxBitrate: [],
    screenRxBitrate: [],
  },
}

interface JoinControllerParams {
  role: string
  roomUuid: string
  nickname: string
  password?: string
  crossAppAuthorization?: NECrossAppAuthorization
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  initialProperties?: any
  createRoomReport?: IntervalEvent
  videoProfile?: {
    resolution: VideoResolution
    frameRate: VideoFrameRate
  }
  encryptionConfig?: NEEncryptionConfig
  reporter?: IntervalEvent
  avatar?: string
  type: 'create' | 'join' | 'joinByInvite'
  joinTimeout?: number
}
export default class NEMeetingService {
  roomContext: NERoomContext | null = null
  rtcController: NERoomRtcController | undefined
  chatController: NERoomChatController | undefined
  waitingRoomController: NEWaitingRoomController | undefined
  whiteboardController: NERoomWhiteboardController | undefined
  annotationController?: NERoomAnnotationController
  liveController: NERoomLiveController | null = null
  previewController: NEPreviewController | null = null
  sipController: NERoomSIPController | null = null
  inviteController: NERoomAppInviteController | null = null
  roomService: NERoomService | null = null
  nosService: NENosService | null = null
  liveTranscriptionController:
    | NEMeetingLiveTranscriptionController
    | undefined = undefined
  isUnMutedAudio = false // 入会是否开启音频
  isUnMutedVideo = false // 入会是否开启视频
  alreadyJoin = false
  globalConfig: GetMeetingConfigResponse | undefined
  _meetingInfo: Partial<CreateMeetingResponse> = {} // 会议接口返回的会议信息，未包含sdk中的信息
  subscribeMembersMap: Record<string, 0 | 1> = {}
  outEventEmitter: EventEmitter
  appKey = ''
  public _meetingServerDomain = 'https://meeting.yunxinroom.com'
  private _screenSharingSourceId = ''
  private _isAnonymous = false
  private _isLoginedByAccount = false // 是否已通过账号登录
  private _meetingStatus = 'unlogin'
  private authService: NEAuthService | null = null
  private messageService: NEMessageChannelService | null = null
  private _roomkit: Roomkit
  private _eventEmitter: EventEmitter
  private _userUuid = ''
  private _token = ''
  private _authType
  private _privateMeetingNum = '' // 个人id
  private _request: AxiosInstance
  private _meetingType = 0 // 1.随机会议，2.个人会议，3.预约会议
  private _isReuseIM = false // 是否复用im
  private _language = getDefaultLanguage()
  private _logger: Logger
  private _accountInfo: (NEAccountInfo & InnerAccountInfo) | null = null
  private _noChat = false
  private _xkitReport: XKitReporter
  private _meetingStartTime = 0
  private _leaveRoomTimer: null | ReturnType<typeof setTimeout> = null
  // 超过6s子频道没有声音则自动放大主频道
  private _audioVolumeIndicationTimer: null | ReturnType<
    typeof setTimeout
  > = null
  // 超过6s子频道没有声音则自动2s内放大主频道音量到正常值
  private _audioVolumeIndicationIntervalTimer: null | ReturnType<
    typeof setInterval
  > = null
  private _joinRoomkitOptions: Partial<JoinControllerParams> = {}
  private _waitingRoomChangedName = '' // 等候室改名同时被准入，需要入会之后修改昵称
  private _interpretationSetting: NEMeetingInterpretationSettings | null = null
  private _framework = window.ipcRenderer
    ? 'Electron-native'
    : window.h5App
    ? 'H5'
    : ''
  private _previewListener
  private _joinTimeoutTimer: null | ReturnType<typeof setTimeout> = null
  private _isMySelfJoinRtc = false

  constructor(params: {
    roomkit: Roomkit
    eventEmitter: EventEmitter
    outEventEmitter: EventEmitter
    logger?: Logger
  }) {
    this._xkitReport = XKitReporter.getInstance({
      imVersion: IM_VERSION,
      nertcVersion: RTC_VERSION,
      deviceId: window.NERoom.getDeviceId?.(),
    })
    this._xkitReport.common.platform = this.getClientType() || 'Web'
    this._roomkit = params.roomkit
    this._eventEmitter = params.eventEmitter
    this.outEventEmitter = params.outEventEmitter
    this._request = this.createRequest()
    this._logger = logger
    this._eventEmitter.on(
      EventType.onInterpretationSettingChange,
      (setting: NEMeetingInterpretationSettings) => {
        this._interpretationSetting = setting
      }
    )
  }
  get isHostOrCohost(): boolean {
    const role = this.roomContext?.localMember.role.name

    return role === Role.host || role === Role.coHost
  }
  get eventEmitter(): EventEmitter {
    return this._eventEmitter
  }

  get localMember(): NERoomMember | null {
    return this.roomContext ? this.roomContext.localMember : null
  }

  get meetingId(): number | undefined {
    return this._meetingInfo.meetingId
  }
  get meetingNum(): string {
    return this._meetingInfo.meetingNum || ''
  }
  get shortMeetingNum(): string {
    return this._meetingInfo.shortMeetingNum || ''
  }
  get roomDeviceId(): string {
    return window.NERoom.getDeviceId?.()
  }

  get ssoUrl(): string {
    return `${this._meetingServerDomain}/scene/meeting/v2/sso-authorize`
  }

  get sdkLogPath(): string {
    return this._roomkit.getCurrentLogPath?.() || ''
  }

  get accountInfo(): AccountInfo | null {
    if (this._accountInfo) {
      return {
        nickname: this._accountInfo.nickname,
        shortMeetingNum: this._accountInfo.shortMeetingNum,
        meetingNum: this._accountInfo.privateMeetingNum,
        avatar: this._accountInfo.avatar,
        serviceBundle: this._accountInfo.serviceBundle,
      }
    } else {
      return null
    }
  }
  get avRoomUid(): string {
    return this.roomContext ? this.roomContext.localMember.uuid : ''
  }

  get interpretation(): InterpretationRes | undefined {
    const interpretationStr = this.roomContext?.roomProperties.interpretation
    let interpretation = undefined

    if (!interpretationStr) {
      return undefined
    }

    try {
      interpretation = JSON.parse(interpretationStr.value)
    } catch (error) {
      console.log('interpretation error', error)
    }

    return interpretation
  }

  get isInterpretationStarted(): boolean {
    let isStarted = false
    const interpretation = this.interpretation

    if (!interpretation) {
      return false
    }

    isStarted = interpretation.started
    return isStarted
  }

  get meetingStatus(): string {
    return this._meetingStatus
  }
  get microphoneId(): string | undefined {
    return this.rtcController?.getSelectedRecordDevice()
  }

  get cameraId(): string | undefined {
    return this.rtcController?.getSelectedCameraDevice()
  }

  get speakerId(): string | undefined {
    return this.rtcController?.getSelectedPlayoutDevice() || undefined
  }

  async getNetworkType(): Promise<number> {
    return (await this._roomkit?.getNetworkType?.()) ?? Promise.resolve(0)
  }

  switchLanguage(language?: 'zh-CN' | 'en-US' | 'ja-JP'): void {
    this._language = language
      ? ['zh-CN', 'en-US', 'ja-JP'].includes(language)
        ? language
        : getDefaultLanguage()
      : getDefaultLanguage()
    const roomLanguageMap = {
      'zh-CN': 'CHINESE',
      'en-US': 'ENGLISH',
      'ja-JP': 'JAPANESE',
    }

    this._roomkit.switchLanguage(
      roomLanguageMap[this._language] as NERoomLanguage
    )
  }

  async feedbackApi(data?: {
    category?: string
    description?: string
  }): Promise<void> {
    const feedbackUrl =
      'https://statistic.live.126.net/statics/report/common/form'

    const deviceId = this._roomkit.deviceId || window.NERoom.getDeviceId?.()

    const logRes = await this.uploadLog()
    const meeting_id = this._meetingInfo.meetingId
    const nickname = this._accountInfo?.nickname || ''

    return axios.post(
      feedbackUrl,
      {
        event: {
          feedback: {
            app_key: this.appKey,
            device_id: deviceId,
            ver: pkg.version,
            platform: window.systemPlatform || 'Web',
            client: 'Meeting',
            paired_id: '',
            log: logRes?.data,
            meeting_id,
            nickname,
            time: new Date().getTime(),
            ...data,
          },
        },
      },
      {
        headers: {
          sdktype: 'meeting',
          ver: pkg.version,
          appkey: this.appKey,
          deviceId: deviceId,
        },
      }
    )
  }

  async uploadLog(): Promise<NEResult<string> | undefined> {
    return this._roomkit?.uploadLog?.()
  }

  public removeGlobalEventListener(): void {
    this._roomkit?.removeGlobalEventListener({})
  }

  get imInfo(): IMInfo | null {
    if (window.isElectronNative) {
      return {
        nim: {},
        imAccid: '',
        imAppKey: '',
        imToken: '',
        nickName: '',
        chatRoomId: '',
      }
    }

    if (this.meetingStatus !== 'unlogin') {
      return {
        nim: this._roomkit._im.nim,
        imAccid: this.authService ? this.authService.roomAccountId : '',
        imAppKey: this.authService ? this.authService.roomAppKey : '',
        imToken: this.authService ? this.authService.roomAccountToken : '',
        nickName: this.localMember?.name || '',
        chatRoomId: this.roomContext
          ? this.roomContext.roomProperties?.chatRoom?.chatRoomId
          : '',
      }
    }

    return null
  }

  isMySelf(userId: string): boolean {
    return this.localMember?.uuid === userId
  }

  isMySelfInterpreter(): boolean {
    if (!this.isInterpretationStarted) {
      return false
    } else {
      return this.localMember
        ? this.interpretation?.interpreters?.[this.localMember?.uuid]
          ? true
          : false
        : false
    }
  }

  async init(params: NEMeetingInitConfig): Promise<void> {
    // this._siganling.setInitConf(val);
    this.appKey = params.appKey
    IntervalEvent.appKey = this.appKey as string
    params.meetingServerDomain &&
      (this._meetingServerDomain = params.meetingServerDomain)
    this._isReuseIM = !!params.im
    params.globalEventListener &&
      this._roomkit.addGlobalEventListener(params.globalEventListener)
    const options: NERoomKitOptions = {
      appKey: this.appKey,
      im: params.im,
      useInternalVideoRender: false,
      debug: params.debug,
      eventTracking: params.eventTracking,
      extras: params.extras?.noReport
        ? {
            noReport: params.extras?.noReport,
            framework: this._framework,
          }
        : {
            framework: this._framework,
          },
    }

    // 配置私有化优先级更高 > serverUrl
    if (
      params.imPrivateConf ||
      params.neRtcServerAddresses ||
      params.whiteboardConfig ||
      (params.meetingServerDomain &&
        params.meetingServerDomain !== 'https://roomkit.netease.im')
    ) {
      options.serverConfig = {
        roomKitServerConfig: {
          roomServer: this._meetingServerDomain,
        },
        imServerConfig: params.imPrivateConf,
        rtcServerConfig: params.neRtcServerAddresses,
        whiteboardServerConfig: params.whiteboardConfig,
      }
      // options.useAssetServerConfig = true
    } else if (params.useAssetServerConfig) {
      // Electron读取配置文件
      try {
        const privateConfig = await window.ipcRenderer?.invoke(
          IPCEvent.getPrivateConfig
        )

        if (privateConfig) {
          const config = parsePrivateConfig(privateConfig)

          options.serverConfig = {
            roomKitServerConfig: {
              roomServer: this._meetingServerDomain,
            },
            imServerConfig: config.imPrivateConf,
            rtcServerConfig: config.neRtcServerAddresses,
            whiteboardServerConfig: config.whiteboardConfig,
          }
        }
      } catch (error) {
        console.log('privateConfig error', error)
      }
    } else if (params.serverUrl) {
      this._meetingServerDomain = params.serverUrl
      options.serverUrl = params.serverUrl
    }

    if (window.isElectronNative) {
      try {
        const logsPath = await window.ipcRenderer?.invoke(IPCEvent.getLogPath)

        options.logPath = logsPath
      } catch (error) {
        console.log('logsPath error', error)
      }
    }

    if (!this._roomkit.isInitialized) {
      await this._roomkit.initialize(options)
    }

    RendererManager.instance.roomKit = this._roomkit
    // axios.defaults.baseURL = this._meetigServerDomain;
    this._request = this.createRequest()
    this.authService = this._roomkit.authService
    this.roomService = this._roomkit.roomService
    this.previewController = (this
      .roomService as NERoomService).getPreviewRoomContext()?.previewController
    this.messageService = this._roomkit.messageChannelService
    this.nosService = this._roomkit.nosService
    this.messageService.addMessageChannelListener({
      onCustomMessageReceived: (res) => {
        if (res.commandId === 11000 && typeof res.data === 'string') {
          try {
            const data = JSON.parse(res.data)

            this.eventEmitter.emit(EventType.OnEmoticonsReceived, {
              emojiKey: data.emojiTag,
              userUuid: res.senderUuid,
            })
          } catch {
            // 忽略解析错误
          }
        } else if (res.commandId === 99) {
          const body = res.data.body

          if (Object.prototype.toString.call(body) == '[object String]') {
            res.data.body = JSON.parse(body)
          }

          this._eventEmitter.emit(EventType.ReceivePassThroughMessage, res)
        } else if (res.commandId === 98) {
          if (Object.prototype.toString.call(res.data) == '[object String]') {
            try {
              res.data = JSON.parse(res.data)
            } catch (error) {
              console.log('parse meeting update error', error)
            }
          }

          const type = res.data?.type

          // 暂停参会者活动
          if (type === 203) {
            this._eventEmitter.emit(EventType.OnStopMemberActivities, res)
          }

          if (res.data.pluginId) {
            this._eventEmitter.emit(EventType.ReceivePluginMessage, res)
            const pluginId = res.data.pluginId as string

            const win = getWindow(pluginId)

            win?.postMessage(
              {
                event: 'eventEmitter',
                payload: {
                  key: EventType.ReceivePluginMessage,
                  args: [res],
                },
              },
              win.origin
            )
          } else {
            this._eventEmitter.emit(
              EventType.ReceiveScheduledMeetingUpdate,
              res
            )
          }
        } else if (res.commandId >= 200 && res.commandId < 400) {
          this._eventEmitter.emit(EventType.RoomsCustomEvent, res)
          if (res.commandId === 211) {
            try {
              const data =
                typeof res.data === 'string' ? JSON.parse(res.data) : res.data

              if (data.reason === 'CHANGE_SETTINGS') {
                this._syncSettings(data.meetingAccountInfo)
              }

              this._eventEmitter.emit(EventType.ReceiveAccountInfoUpdate, data)
            } catch {
              console.log('parse meeting update error', res.data)
            }
          }
        } else if ([82, 33, 51, 30].includes(res.commandId)) {
          try {
            // native需要转成json
            const data =
              typeof res.data === 'string' ? JSON.parse(res.data) : res.data

            res.data = data
            // 邀请通知
            // electron 不需要监听否则会有重复弹窗
            if (!window.isElectronNative) {
              this._eventEmitter.emit(
                EventType.OnMeetingInviteStatusChange,
                res
              )
            }
          } catch (e) {
            console.log('parse meeting invite error', e)
          }
        }
      },
      onSessionMessageReceived: (data) => {
        this._eventEmitter.emit(EventType.onSessionMessageReceived, data)

        const notificationListWindow = getWindow('notificationListWindow')

        notificationListWindow?.postMessage(
          {
            event: 'eventEmitter',
            payload: {
              key: EventType.onSessionMessageReceived,
              args: [data],
            },
          },
          notificationListWindow.origin
        )
      },
      onSessionMessageRecentChanged: (data) => {
        this._eventEmitter.emit(EventType.onSessionMessageRecentChanged, data)
      },
      onSessionMessageDeleted: (data) => {
        this._eventEmitter.emit(EventType.onSessionMessageDeleted, data)
      },
      onDeleteAllSessionMessage: (sessionId, sessionType) => {
        this._eventEmitter.emit(
          EventType.OnDeleteAllSessionMessage,
          sessionId,
          sessionType
        )
      },
    })
    this._addPreviewListener()
  }
  public async getGlobalConfig(): Promise<GetMeetingConfigResponse> {
    return this._request
      .get(`/scene/meeting/${this.appKey}/v1/config`)
      .then((res) => {
        logger.debug('getGlobalConfig', res)
        const data = (res.data as unknown) as GetMeetingConfigResponse
        let activeSpeakerConfig =
          data.appConfig?.MEETING_CLIENT_CONFIG?.activeSpeakerConfig

        if (activeSpeakerConfig) {
          const {
            activeSpeakerVolumeThreshold,
            enableVideoPreSubscribe,
            maxActiveSpeakerCount,
            validVolumeThreshold,
            volumeIndicationInterval,
            volumeIndicationWindowSize,
          } = activeSpeakerConfig

          activeSpeakerConfig.activeSpeakerVolumeThreshold =
            activeSpeakerVolumeThreshold || 30
          activeSpeakerConfig.enableVideoPreSubscribe = !!enableVideoPreSubscribe
          activeSpeakerConfig.maxActiveSpeakerCount = maxActiveSpeakerCount || 3
          activeSpeakerConfig.validVolumeThreshold = validVolumeThreshold || 10
          activeSpeakerConfig.volumeIndicationInterval =
            volumeIndicationInterval || 200
          activeSpeakerConfig.volumeIndicationWindowSize =
            volumeIndicationWindowSize || 15
        } else {
          activeSpeakerConfig = {
            activeSpeakerVolumeThreshold: 30,
            enableVideoPreSubscribe: true,
            maxActiveSpeakerCount: 3,
            validVolumeThreshold: 10,
            volumeIndicationInterval: 200,
            volumeIndicationWindowSize: 15,
          }
        }

        if (!res.data.appConfig.MEETING_CLIENT_CONFIG) {
          res.data.appConfig.MEETING_CLIENT_CONFIG = {}
        }

        res.data.appConfig.MEETING_CLIENT_CONFIG.activeSpeakerConfig = activeSpeakerConfig
        localStorage.setItem(
          'nemeeting-global-config',
          JSON.stringify(res.data)
        )
        this.globalConfig = res.data
        return (res.data as unknown) as GetMeetingConfigResponse
      })
  }
  async login(
    options: NEMeetingLoginByPasswordOptions | NEMeetingLoginByTokenOptions
  ): Promise<NEAccountInfo> {
    try {
      // await this._siganling.login(options)
      if (options.loginType === 1) {
        const {
          accountId,
          accountToken,
          authType,
        } = options as NEMeetingLoginByTokenOptions
        const step1 = options.loginReport?.beginStep(
          StaticReportType.Account_info
        )

        options.loginReport?.setData({ userId: options.accountId })
        this._userUuid = accountId
        this._token = accountToken
        this._authType = authType
        if (!options.isTemporary) {
          const data = await this._request
            .get(`/scene/meeting/${this.appKey}/v1/account/info`)
            .catch((e) => {
              step1?.endWith({
                code: e.code || -1,
                msg: e.msg || e.message || 'failure',
              })
              throw e
            })

          const res: NEAccountInfo & InnerAccountInfo = data.data

          this._syncSettings(res)
          step1?.endWith({
            serverCost: data.cost ? Number.parseInt(data.cost) : undefined,
            code: data.code,
            msg: data.msg,
            requestId: data.requestId,
          })
          this._accountInfo = res
          this._privateMeetingNum = res.privateMeetingNum
        }

        const step2 = options.loginReport?.beginStep(
          StaticReportType.Roomkit_login
        )

        if (this.authService) {
          let func = this.authService.login.bind(this.authService)

          if (options.authType) {
            func = this.authService.loginByDynamicToken.bind(this.authService)
          }

          const res = await func(
            accountId,
            accountToken,
            options.authType
          ).catch((e) => {
            console.error('login failed', e)
            step2?.endWith({
              code: e.code || -1,
              msg: e.msg || e.message || 'failure',
            })
            throw e
          })

          step2?.endWith({
            code: res.code || 0,
            msg: res.message || 'success',
          })
        }
      } else {
        const step1 = options.loginReport?.beginStep(
          StaticReportType.Account_info
        )
        const {
          username,
          password,
        } = options as NEMeetingLoginByPasswordOptions
        const data = await this._request
          .post(`/scene/meeting/${this.appKey}/v1/login/${username}`, {
            password: Md5.hashStr(password + '@yiyong.im'),
          })
          .catch((e) => {
            step1?.endWith({
              code: e.code || -1,
              msg: e.msg || e.message || 'failure',
            })
            throw e
          })

        step1?.endWith({
          serverCost: data.cost ? Number.parseInt(data.cost) : undefined,
          code: data.code,
          msg: data.msg,
          requestId: data.requestId,
        })
        const res: NEAccountInfo = data.data

        this._accountInfo = res
        this._userUuid = res.userUuid
        this._token = res.userToken
        this._privateMeetingNum = res.privateMeetingNum
        const step2 = options.loginReport?.beginStep(
          StaticReportType.Roomkit_login
        )

        if (this.authService) {
          const data = await this.authService
            .login(res.userUuid, res.userToken)
            .catch((e) => {
              step2?.endWith({
                code: e.code || -1,
                msg: e.msg || e.message || 'failure',
              })
              throw e
            })

          step2?.endWith({
            code: data.code,
            msg: data.message ? data.message : undefined,
          })
        }
      }

      this.authService?.addAuthListener({
        onAuthEvent: (evt: NEAuthEvent) => {
          console.log('onAuthEvent>>>>>>', evt, this._eventEmitter)
          this.outEventEmitter?.emit(EventType.AuthEvent, evt)
        },
      })
      this._isLoginedByAccount = true
      if (!this._accountInfo) {
        this._accountInfo = {
          userUuid: this._userUuid,
          userToken: this._token,
        }
      }

      localStorage.setItem(ACCOUNT_INFO_KEY, JSON.stringify(this._accountInfo))
      return this._accountInfo as NEAccountInfo
    } catch (e) {
      this._isLoginedByAccount = false
      return Promise.reject(e)
    }
  }

  async getAccountInfo(): Promise<NEAccountInfo> {
    const res = await this._request.get(
      `/scene/meeting/${this.appKey}/v1/account/info`
    )

    return res.data
  }

  async getAppInfo(): Promise<{ appName: string }> {
    return await this._request
      .get(`/scene/meeting/${this.appKey}/v1/app/info`)
      .then((res) => {
        return res.data
      })
  }
  async checkCaptionPermission(roomUuid: string): Promise<null> {
    return this._request
      .get(`/scene/apps/v1/${roomUuid}/check-caption-permission`)
      .then((res) => {
        return res.data
      })
  }

  async getAppTips(): Promise<{
    tips: NEMeetingAppNoticeTip[]
    curTime: number
    appKey: string
  }> {
    return await this._request
      .get(`/scene/meeting/${this.appKey}/v1/tips?time=${Date.now()}`)
      .then((res) => {
        return {
          appKey: this.appKey,
          ...res.data,
        }
      })
  }

  async openSettingsWindow(type?: string): Promise<void> {
    this.outEventEmitter.emit(UserEventType.OpenSettingsWindow, type)
    return
  }

  async openFeedbackWindow(): Promise<void> {
    this.outEventEmitter.emit(UserEventType.OpenFeedbackWindow)
    return
  }

  async openPluginWindow(
    meetingId: number,
    item: NEMeetingWebAppItem
  ): Promise<void> {
    this.outEventEmitter.emit(UserEventType.OpenPluginWindow, meetingId, item)
    return
  }

  async openChatWindow(meetingId: number): Promise<void> {
    this.outEventEmitter.emit(UserEventType.OpenChatWindow, meetingId)
    return
  }

  async fetchChatroomHistoryMessageList(
    meetingId: number,
    option: NEChatroomHistoryMessageSearchOption
  ): Promise<NEResult<NEMeetingChatMessage[]>> {
    if (this.roomService) {
      const res = await this.roomService.fetchChatroomHistoryMessages(
        String(meetingId),
        option
      )
      const messageList = res.data
        .filter((item) => item.type !== '')
        .map((item) => {
          console.log('item', item)

          const file = item.file as NIMImage

          return {
            messageUuid: item.idClient,
            messageType:
              {
                text: NEMeetingChatMessageType.NEMeetingChatMessageTypeText,
                file: NEMeetingChatMessageType.NEMeetingChatMessageTypeFile,
                image: NEMeetingChatMessageType.NEMeetingChatMessageTypeImage,
              }[item.type] ??
              NEMeetingChatMessageType.NEMeetingChatMessageTypeCustom,
            fromUserUuid: item.from,
            toUserUuidList: [],
            text: item.text,
            attachStr: item.attach,
            displayName: item.file?.name,
            extension: item.file?.ext,
            md5: item.file?.md5,
            url: item.file?.url,
            size: item.file?.size,
            thumbPath: '',
            path: '',
            width: file?.w,
            height: file?.h,
            ...item,
          }
        })

      return SuccessBody(messageList)
    } else {
      return SuccessBody([])
    }
  }

  async exportChatroomHistoryMessageList(
    meetingId: number
  ): Promise<NEResult<string>> {
    if (this.roomService) {
      return await this.roomService.exportChatroomHistoryMessages(
        String(meetingId)
      )
    } else {
      return SuccessBody('')
    }
  }

  async getAppConfig(): Promise<GetMeetingConfigResponse> {
    return await this._request
      .get(`/scene/meeting/${this.appKey}/v1/config`)
      .then((res) => {
        return res.data
      })
  }

  async updateUserNickname(nickname: string): Promise<void> {
    return this._request.post(
      `/scene/meeting/${this.appKey}/v1/account/nickname`,
      { nickname }
    )
  }

  async getMeetingList(
    options: NEMeetingGetListOptions
  ): Promise<CreateMeetingResponse[]> {
    const {
      startTime = dayjs().startOf('day').valueOf(),
      endTime = dayjs().add(14, 'day').endOf('day').valueOf(),
      states = [1, 2, 3],
    } = options
    const data = await this._request.get(
      `/scene/meeting/${this.appKey}/v1/list/${startTime}/${endTime}`,
      {
        params: { states: states.join(',') },
      }
    )
    const res = data.data

    return res.meetingList
  }

  async getScheduledMembers(meetingNum: string): Promise<NEScheduledMember[]> {
    return this._request
      .get(
        `/scene/meeting/${this.appKey}/v1/info/${meetingNum}/scheduled-members`
      )
      .then((res) => {
        return res.data
      })
  }

  async getAccountInfoList(
    userUuids: string[]
  ): Promise<GetAccountInfoListResponse> {
    const data: { data: GetAccountInfoListResponse } = await this._request.post(
      `/scene/meeting/${this.appKey}/v1/account-list`,
      userUuids
    )

    return data.data
  }

  async getLive3PartInfo(): Promise<PlatformInfo[]> {
    const res = await this._request.get(
      `/scene/apps/v1/rooms/${this.meetingNum}/live/push_info_3party`
    )

    return res.data
  }
  async updateLive3PartInfo(data: {
    thirdParties: PlatformInfo[]
  }): Promise<void> {
    console.log('updateLive3PartInfo', data)
    const res = await this._request.post(
      `/scene/apps/v1/rooms/${this.meetingNum}/live/push_info_3party/batch`,
      data
    )

    return res.data
  }
  async getMeetingInfoByMeetingId(
    meetingId: string | number
  ): Promise<CreateMeetingResponse> {
    const res = await this._request.get(
      `/scene/meeting/${this.appKey}/v1/info/meeting/${meetingId}`
    )

    return res.data
  }
  async getMeetingInfoByFetch(
    meetingId: string
  ): Promise<CreateMeetingResponse> {
    const res = await this._request.get(
      `/scene/meeting/${this.appKey}/v2/info/${meetingId}`
    )

    this._meetingInfo = res.data
    return res.data
  }

  async sendVerifyCodeApi(params: {
    appKey?: string
    mobile?: string
    scene?: number
  }) {
    return await this._request({
      method: 'GET',
      url: `/scene/meeting/${params.appKey || this.appKey}/v1/sms/${
        params.mobile
      }/${params.scene}`,
    })
  }

  anonymousLogin(): Promise<NEAccountInfo> {
    return (this._request.post(
      `/scene/apps/${this.appKey}/v1/anonymous/login`
    ) as unknown) as Promise<NEAccountInfo>
  }

  async resetPassword(params: {
    userUuid: string
    newPassword: string
    oldPassword: string
  }): Promise<void> {
    const { userUuid, newPassword, oldPassword } = params

    await this._request({
      url: `/scene/meeting/v2/password`,
      data: {
        username: userUuid,
        password: md5Password(oldPassword),
        newPassword: md5Password(newPassword),
      },
      method: 'POST',
    })
  }

  generateSSOLoginWebURL(callback: string, ipdId: number): string {
    const clientType = window.isElectronNative
      ? window.isWins32
        ? 'pc'
        : 'mac'
      : 'web'

    const deviceId = this._roomkit.deviceId || window.NERoom.getDeviceId?.()

    return `${this._meetingServerDomain}/scene/meeting/v2/sso-authorize?callback=${callback}&idp=${ipdId}&key=${deviceId}&clientType=${clientType}&appKey=${this.appKey}`
  }

  async loginBySSOUri(param: string): Promise<NEAccountInfo> {
    return this._request
      .get('/scene/meeting/v2/sso-account-info', {
        headers: {
          appKey: this.appKey,
        },
        params: {
          param,
        },
      })
      .then((res) => res.data)
  }

  async loginApi(params: {
    verifyCode?: string
    username?: string
    mobile?: string
    appKey?: string
  }): Promise<NEAccountInfo> {
    const appKey = params.appKey || this.appKey
    const url = params.verifyCode
      ? `/scene/meeting/${appKey}/v1/mobile/${params.mobile}/login` // 验证码登录
      : `/scene/meeting/${appKey}/v1/login/${params.username}` // 账号密码登录

    return this._request({
      url,
      method: 'POST',
      data: params,
    }).then((res) => res.data)
  }

  async loginApiNew(params: {
    password: string
    username?: string
    phone?: string
    email?: string
    appKey?: string
  }): Promise<NEAccountInfo> {
    let url: string = '/scene/meeting/v1/login-username'

    if (params.username) {
      url = `/scene/meeting/v1/login-username` // 账号密码登录
    }

    if (params.phone) {
      url = `/scene/meeting/v1/login-phone` // 手机号登录
    }

    if (params.email) {
      url = `/scene/meeting/v1/login-email` // 邮箱登录
    }

    params.password = md5Password(params.password)

    return this._request({
      url,
      method: 'POST',
      data: params,
    }).then((res) => res.data)
  }

  getEnterPriseInfoApi(params: {
    code?: string
    email?: string
  }): Promise<EnterPriseInfo> {
    return (this._request({
      url: `/scene/meeting/v2/app-info`,
      params,
      method: 'GET',
    }) as unknown) as Promise<EnterPriseInfo>
  }

  async getHostAndCohostList(): Promise<NEMember[]> {
    const res = await this.waitingRoomController?.getWaitingRoomManagerList()

    if (res?.data) {
      return res.data.map((item: NERoomMemberBase) => {
        return {
          ...item,
          role: item.role.name,
          isAudioConnected: false,
          isAudioOn: false,
          isInChatroom: true,
          isInRtcChannel: true,
          isSharingScreen: false,
          isVideoOn: false,
          isSharingWhiteboard: false,
          properties: {},
          clientType: NEClientType.UNKNOWN,
          inviteState: NEMeetingInviteStatus.unknown,
        }
      })
    }

    return []
  }

  async getWaitingRoomConfig(roomUuid: string): Promise<{ wtPrChat: number }> {
    const res = await this._request.get(
      `/scene/apps/${this.appKey}/v1/rooms/${roomUuid}/waiting-room-config`
    )

    return {
      wtPrChat: Number(res.data.wtPrChat?.value || 1),
    }
  }

  setScreenSharingSourceId(sourceId: string): void {
    this._screenSharingSourceId = sourceId
  }

  async saveViewOrderInMeeting(data: string): Promise<void> {
    return await this._request.post(
      `/scene/meeting/${this.appKey}/v1/edit/${this.meetingId}/unSync`,
      {
        viewOrder: data,
      }
    )
  }

  async scheduleMeeting(
    options: NEMeetingCreateOptions
  ): Promise<CreateMeetingResponse> {
    const audioOff = this._formatAudioOff(
      options.attendeeAudioOffType,
      !!options.attendeeAudioOff
    )
    const {
      meetingId,
      startTime,
      endTime,
      openLive,
      liveOnlyEmployees,
      liveChatRoomEnable,
      liveConfig,
      password,
      subject,
      roleBinds,
      noSip,
      recurringRule,
      scheduledMembers,
      enableGuestJoin,
      interpretation,
      timezoneId,
    } = options
    const data = {
      password,
      subject,
      startTime,
      endTime,
      roleBinds,
      roomConfigId: 40,
      openWaitingRoom: !!options.enableWaitingRoom,
      recurringRule,
      enableJoinBeforeHost:
        options.enableJoinBeforeHost === false ? false : true,
      roomConfig: {
        resource: {
          rtc: true,
          live: openLive,
          chatroom: !options.noChat,
          whiteboard: true,
          record: options.cloudRecordConfig?.enable === true,
          sip: noSip === undefined ? false : !noSip,
        },
      },
      live: {
        enable: openLive,
      },
      roomProperties: {
        cloudRecord: {
          mode: 0,
          videoEnable: true,
          audioEnable: true,
        },
        extraData: { value: options.extraData },
        lock: {
          value: 0,
        },
        audioOff: {
          value: audioOff,
        },
        guest: {
          value: enableGuestJoin ? '1' : '0',
        },
      },
      scheduledMembers,
      interpretation,
      timezoneId,
      recordConfig: {
        recordStrategy: options.cloudRecordConfig?.recordStrategy,
      },
      livePrivateConfig: liveConfig,
    }

    console.log('scheduleMeeting', data)

    if (openLive) {
      const extensionConfig = {
        liveChatRoomEnable: liveChatRoomEnable,
        onlyEmployeesAllow: liveOnlyEmployees,
      }

      data.roomProperties['live'] = {
        extensionConfig: JSON.stringify(extensionConfig),
      }

      if (liveConfig?.background?.backgroundFile) {
        let res: NEResult<string> | undefined

        if (window.isElectronNative) {
          res = await this.nosService?.uploadResource(
            liveConfig?.background?.backgroundFile
          )
        } else {
          res = await this.nosService?.uploadResource({
            blob: liveConfig?.background?.backgroundFile as Blob,
            type: 'image',
          })
        }

        liveConfig.background.backgroundUrl = res?.data

        if (res?.data) {
          const thumbnailUrl = getThumbnailUrl(res.data)

          liveConfig.background.thumbnailBackUrl = thumbnailUrl
        }

        delete liveConfig.background.backgroundFile
      }

      if (liveConfig?.background?.thumbnailBackFile) {
        let res: NEResult<string> | undefined

        if (window.isElectronNative) {
          res = await this.nosService?.uploadResource(
            liveConfig?.background?.thumbnailBackFile
          )
        } else {
          res = await this.nosService?.uploadResource({
            blob: liveConfig?.background?.thumbnailBackFile as Blob,
            type: 'image',
          })
        }

        liveConfig.background.notStartCoverUrl = res?.data
        if (res?.data) {
          const thumbnailUrl = getThumbnailUrl(res.data)

          liveConfig.background.notStartThumbnailUrl = thumbnailUrl
        }

        delete liveConfig.background.thumbnailBackFile
      }
    } else {
      delete data.livePrivateConfig
    }

    let res

    if (meetingId) {
      if (recurringRule) {
        res = await this._request.patch(
          `/scene/meeting/${this.appKey}/v1/recurring-meeting/${meetingId}`,
          data
        )
      } else {
        res = await this._request.post(
          `/scene/meeting/${this.appKey}/v1/edit/${meetingId}`,
          data
        )
      }
    } else {
      res = await this._request.put(
        `/scene/meeting/${this.appKey}/v1/create/3`,
        data
      )
    }

    if (res && res.code === 0) {
      return res.data
    } else {
      throw res
    }
  }

  async cancelMeeting(
    meetingId: number | string,
    cancelRecurringMeeting?: boolean
  ): Promise<void> {
    return await this._request
      .delete(
        `/scene/meeting/${
          this.appKey
        }/v1/cancel/${meetingId}?cancelRecurringMeeting=${!!cancelRecurringMeeting}`
      )
      .then((res) => {
        return res.data
      })
  }

  async create(options: NEMeetingCreateOptions): Promise<void> {
    const settings = getLocalStorageSetting()

    try {
      const {
        meetingId,
        meetingNum,
        password,
        subject,
        roleBinds,
        noSip,
        noChat,
        noWhiteBoard,
        enableGuestJoin,
        cloudRecordConfig = {
          enable: settings?.recordSetting.autoCloudRecord || false,
          recordStrategy: settings?.recordSetting.autoCloudRecordStrategy || 0,
        },
        joinTimeout,
      } = options

      logger.debug(
        'create()',
        options,
        this._accountInfo,
        meetingNum,
        this._accountInfo?.privateMeetingNum,
        meetingNum != this._accountInfo?.shortMeetingNum
      )
      // this.isUnMutedAudio = options.audio == 1
      // this.isUnMutedVideo = options.video == 1
      if (meetingNum !== undefined) {
        if (meetingNum) {
          if (
            meetingNum != this._accountInfo?.privateMeetingNum &&
            meetingNum != this._accountInfo?.shortMeetingNum
          ) {
            return Promise.reject({
              code: MeetingErrorCode.MeetingNumIncorrect,
              message: 'MeetingNum is incorrect',
            })
          }
        }

        this._meetingType = meetingNum ? 2 : 1
      } else if (meetingId !== undefined) {
        // 兼容老的meetingId
        this._meetingType = meetingId
      }

      this._noChat = !!noChat
      const createRoomStep = options.createMeetingReport?.beginStep(
        StaticReportType.Create_room
      )
      const audioOff = this._formatAudioOff(
        options.attendeeAudioOffType,
        !!options.attendeeAudioOff
      )
      const data = await this._request
        .put<string, ResponseData>(
          `/scene/meeting/${this.appKey}/v1/create/${this._meetingType}`,
          {
            password,
            subject,
            roleBinds,
            roomConfigId: 40,
            openWaitingRoom: !!options.enableWaitingRoom,
            roomConfig: {
              resource: {
                rtc: true,
                chatroom: !options.noChat,
                whiteboard: !noWhiteBoard,
                record: cloudRecordConfig?.enable === true,
                sip: noSip === undefined ? false : !noSip,
              },
            },
            roomProperties: {
              cloudRecord: {
                mode: 0,
                videoEnable: true,
                audioEnable: true,
              },
              extraData: { value: options.extraData },
              lock: {
                value: 0,
              },
              audioOff: {
                value: audioOff,
              },
              videoOff: {
                value:
                  (options.attendeeVideoOff
                    ? AttendeeOffType.offNotAllowSelfOn
                    : AttendeeOffType.disable) + `_${new Date().getTime()}`,
              },
              guest: {
                value: enableGuestJoin ? '1' : '0',
              },
            },
            recordConfig: {
              recordStrategy: cloudRecordConfig?.recordStrategy,
            },
          }
        )
        .catch((e) => {
          createRoomStep?.endWith({
            serverCost: e.cost ? Number.parseInt(e.cost) : undefined,
            code: e.code || -1,
            msg: e.msg || e.message || 'failure',
            requestId: e.requestId,
          })
          throw e
        })
      const res: CreateMeetingResponse = data.data

      options.createMeetingReport?.setData({
        userId: this._userUuid,
      })
      options.createMeetingReport?.addParams({
        meetingNum: res.meetingNum,
        roomArchiveId: res.roomArchiveId,
        meetingId: res.meetingId,
      })
      createRoomStep?.endWith({
        serverCost: data.cost ? Number.parseInt(data.cost) : undefined,
        code: data.code,
        msg: data.msg,
        requestId: data.requestId,
      })
      this._meetingInfo = res
      const initialProperties = {}

      if (options.memberTag) {
        initialProperties['tag'] = { value: options.memberTag }
      }

      return this._joinRoomkit({
        role: 'host',
        roomUuid: res.roomUuid,
        nickname: options.nickName,
        createRoomReport: options.createMeetingReport,
        initialProperties,
        videoProfile: options.videoProfile,
        encryptionConfig: options.encryptionConfig,
        reporter: options.createMeetingReport,
        avatar: options.avatar,
        type: 'create',
        joinTimeout,
      }).then(() => {
        this._meetingStartTime = new Date().getTime()
      })
    } catch (e: unknown) {
      const error = e as NECommonError

      if (error.code === 3100) {
        // 房间已经存在
        this._meetingType = 2
      } else {
        this._meetingType = 0
      }

      this._meetingStatus =
        this._meetingStatus === 'login' ? 'login' : 'unlogin'
      return Promise.reject(e)
    }
  }

  async queryUnreadMessageList(
    sessionId: string
  ): Promise<NECustomSessionMessage[]> {
    const res = await this.messageService?.queryUnreadMessageList(sessionId, 0)

    if (res && res.code === 0) {
      return res.data
    }

    return []
  }

  async getSessionMessagesHistory(options: {
    sessionId: string
    fromTime?: number
    toTime?: number
    limit?: number
    order?: NEMessageSearchOrder
  }): Promise<NECustomSessionMessage[]> {
    const res = await this.messageService?.getSessionMessagesHistory({
      sessionType: 0,
      ...options,
    })

    if (res && res.code === 0) {
      return res.data
    }

    return []
  }

  async clearUnreadCount(
    sessionId: string
  ): Promise<NEResult<null> | undefined> {
    return await this.messageService?.clearUnreadCount(sessionId, 0)
  }

  async deleteAllSessionMessage(
    sessionId: string
  ): Promise<NEResult<null> | undefined> {
    return await this.messageService?.deleteAllSessionMessage(sessionId, 0)
  }

  getMeetingPluginList(): Promise<{
    pluginInfos: NEMeetingWebAppItem[]
  }> {
    return this._request.get(`/plugin_sdk/v1/list`).then((res) => {
      return res.data
    })
  }

  getMeetingPluginAuthCode(params: {
    pluginId: string
  }): Promise<{ authCode: string }> {
    return this._request
      .post(`/plugin_sdk/v1/auth_code`, params)
      .then((res) => {
        return res.data
      })
  }

  /*
  addSipMember(sipNum: string, sipHost: string) {
    return this._request
      .post(`/scene/meeting/${this._appKey}/v1/sip/${this.meetingNum}/invite`, {
        sipNum,
        sipHost,
      })
      .then((res) => {
        return res.data
      })
  }
  */

  async startLive(
    options: NERoomLiveRequest
  ): Promise<NEResult<NERoomLiveInfo> | undefined> {
    return await this.liveController?.startLive(options)
  }

  async stopLive(): Promise<NEResult<null> | undefined> {
    return await this.liveController?.stopLive()
  }

  async updateLive(
    options: NERoomLiveRequest
  ): Promise<NEResult<NERoomLiveInfo> | undefined> {
    return await this.liveController?.updateLive(options)
  }
  async handsDownAll(): Promise<null> {
    return this._request
      .post(`/scene/apps/v1/rooms/${this.meetingNum}/members/hands-down`)
      .then((res) => {
        return res.data
      })
  }

  getLiveInfo(): NERoomLiveInfo | null {
    if (!this.liveController) {
      return null
    }

    return this.liveController.getLiveInfo()
  }
  getSipMemberList(): Promise<{ list: SipMember[] }> {
    return this._request
      .get(`/scene/meeting/${this.appKey}/v1/sip/${this.meetingNum}/list`)
      .then((res) => {
        return res.data
      })
  }

  getMeetingInfoForGuest(meetingNum: string): Promise<GuestMeetingInfo> {
    return (this._request({
      url: `/scene/meeting/v2/meetingInfoForGuest/${meetingNum}`,
      method: 'GET',
    }).then((res) => {
      return res.data
    }) as unknown) as Promise<GuestMeetingInfo>
  }

  sendVerifyCodeApiByGuest(
    meetingNum: string,
    phoneNum: string
  ): Promise<void> {
    return (this._request({
      url: `/scene/meeting/v2/smsForGuestJoinWithMeetingNum/${meetingNum}`,
      params: {
        phoneNum,
      },
      method: 'GET',
    }).then((res) => {
      return res.data
    }) as unknown) as Promise<void>
  }

  getMeetingInfoForGuestByPhoneNum(data: {
    meetingNum: string
    phoneNum: string
    verifyCode: string
  }): Promise<GuestMeetingInfo> {
    const { meetingNum, phoneNum, verifyCode } = data

    return (this._request({
      url: `/scene/meeting/v2/meetingInfoForGuest/${meetingNum}`,
      params: {
        phoneNum,
        verifyCode,
      },
      method: 'GET',
    }).then((res) => {
      return res.data
    }) as unknown) as Promise<GuestMeetingInfo>
  }

  startAudioDump(type: number): Promise<void> {
    this.rtcController?.startAudioDump?.(type)
    return Promise.resolve()
  }

  stopAudioDump(): Promise<void> {
    this.rtcController?.stopAudioDump?.()
    return Promise.resolve()
  }

  // 获取本端视频信息
  async getLocalVideoStats(): Promise<NERoomRtcVideoSendStats | undefined> {
    return await this.rtcController?.getLocalVideoStats()
  }

  // 获取远端视频信息
  async getRemoteVideoStats(): Promise<NERoomRtcVideoRecvStats[] | undefined> {
    return await this.rtcController?.getRemoteVideoStats()
  }

  // 获取远端视频信息
  async getRemoteScreenStats(): Promise<
    NERoomRtcVideoLayerRecvStats | undefined
  > {
    return await this.rtcController?.getRemoteScreenStats()
  }

  async anonymousJoin(options: NEMeetingJoinOptions): Promise<NEResult<void>> {
    if (this._isReuseIM) {
      console.warn('im复用不支持匿名入会')
      return {
        code: MeetingErrorCode.ReuseIMError,
        message: 'reuseIM not support anonymous join',
        data: undefined,
      }
    }

    if (this._isLoginedByAccount) {
      console.warn('已通过账号登录，建议直接入会。或者登出后再匿名入会')
      return {
        code: -102,
        message: '已通过账号登录，建议直接入会。或者登出后再匿名入会',
        data: undefined,
      }
    }

    // this.isUnMutedAudio = options.audio == 1
    // this.isUnMutedVideo = options.video == 1
    this._noChat = !!options.noChat
    this._isAnonymous = true
    console.log('anonymousJoin', options)
    try {
      const anonymousJoinStep = options.joinMeetingReport?.beginStep(
        StaticReportType.Anonymous_login
      )
      const data = await this._request
        .post<string, ResponseData>(
          `/scene/apps/${this.appKey}/v1/anonymous/login`
        )
        .catch((e) => {
          anonymousJoinStep?.endWith({
            code: e.code || -1,
            msg: e.msg || 'Failure',
            requestId: e.requestId,
            serverCost: e.cost ? Number.parseInt(e.cost) : undefined,
          })
          throw e
        })

      options.role = options.role || Role.member
      const res: AnonymousLoginResponse = data.data

      options.joinMeetingReport?.setData({
        userId: res.userUuid,
      })
      this._userUuid = res.userUuid
      this._token = res.userToken
      this._privateMeetingNum = res.privateMeetingNum || ''
      try {
        await this.authService?.login(res.userUuid, res.userToken)
      } catch (e: unknown) {
        const error = e as NECommonError & { cost: string; requestId: string }

        anonymousJoinStep?.endWith({
          code: error.code || -1,
          msg: error.msg || 'Failure',
          requestId: error.requestId,
          serverCost: error.cost ? Number.parseInt(error.cost) : undefined,
        })
        console.log('authService.login', error)
      }

      anonymousJoinStep?.endWith({
        code: data.code,
        msg: data.msg || 'success',
        requestId: data.requestId,
        serverCost: data.cost ? Number.parseInt(data.cost) : undefined,
      })
      return this._joinHandler(options)
    } catch (e) {
      console.log('anonymousJoin', e)
      throw e
    }
  }

  async logout(): Promise<void> {
    try {
      await this.authService?.logout()
      this._isLoginedByAccount = false
      this._isAnonymous = false
      this._meetingStatus = 'unlogin'
    } catch (e) {
      console.log('logout', e)
      throw e
    }
  }

  async leave(role?: string): Promise<void> {
    logger.debug('leave() %t')
    const leaveRoom = this.roomContext
      ?.leaveRoom()
      .then(() => {
        logger.debug('leave() successed %t')
      })
      .finally(() => {
        if (role === 'AnonymousParticipant' || this._isAnonymous) {
          this._meetingStatus = 'unlogin'
        } else {
          this._meetingStatus = 'login'
        }
      })

    this._reset()

    return leaveRoom
  }

  async end(): Promise<void> {
    try {
      logger.debug('end():  %s %t', this._isAnonymous)
      this.roomContext && (await this.roomContext.endRoom())
      if (this._isAnonymous) {
        this._meetingStatus = 'unlogin'
      } else {
        this._meetingStatus = 'login'
      }

      this._reset()
      logger.debug('end() successed:  %s %t', this._meetingStatus)
    } catch (e) {
      return Promise.reject(e)
    }
  }

  resetStatus(): void {
    if (this._isAnonymous) {
      this._meetingStatus = 'unlogin'
      // this.authService && this.authService.logout()
      this._isAnonymous = false
    } else {
      this._meetingStatus = 'login'
    }
  }

  async rejoinAfterAdmittedToRoom(): Promise<void> {
    if (!this.roomContext) {
      return
    }

    return this.roomContext
      .rejoinAfterAdmittedToRoom()
      .then(async () => {
        try {
          // 需要更新主题信息
          this._meetingInfo.meetingNum &&
            (await this.getMeetingInfoByFetch(this._meetingInfo.meetingNum))
        } catch (error) {
          console.log('getMeetingInfoByFetch error', error)
        }

        await this._joinController(this._joinRoomkitOptions)
      })
      .catch((e) => {
        throw e
      })
  }

  async getWaitingRoomInfo(): Promise<WaitingRoomContextInterface | null> {
    if (!this.roomContext) {
      return null
    }

    const waitingRoomController = this.roomContext.waitingRoomController
    let memberList: NEWaitingRoomMember[] = []
    const role = this.localMember?.role.name

    if (role === Role.host || role === Role.coHost) {
      try {
        memberList = (await waitingRoomController.getMemberList(0, 20, true))
          .data
      } catch (error) {
        console.log('getWaitingRoom member error', error)
      }
    }

    const info = waitingRoomController.getWaitingRoomInfo()

    return {
      waitingRoomInfo: {
        memberCount: info.memberCount,
        isEnabledOnEntry: info.isEnabledOnEntry,
        backgroundImageUrl: info.backgroundImageUrl,
      },
      memberList,
    }
  }
  updateWaitingRoomUnReadCount(count: number): void {
    this._eventEmitter.emit(
      MeetingEventType.updateWaitingRoomUnReadCount,
      count
    )
  }
  updateMeetingInfo(meetingInfo): void {
    this._eventEmitter.emit(MeetingEventType.updateMeetingInfo, meetingInfo)
  }
  getIsAllowParticipantsEnableCaption(): boolean {
    const roomProperties = this.roomContext?.roomProperties

    return roomProperties?.capPerm?.value !== '0'
  }

  getMeetingInfo(): NEMeetingSDK | null {
    if (!this.roomContext) {
      return null
    }

    const remoteMembers = this.roomContext.remoteMembers
    const localMember = this.roomContext.localMember
    const roomProperties = this.roomContext.roomProperties
    const inSipInvitingMembers = this.roomContext.inSIPInvitingMembers
    const inAppInvitingMembers = this.roomContext.inAppInvitingMembers

    if (roomProperties.audioOff) {
      roomProperties.audioOff.value =
        roomProperties.audioOff.value?.split('_')[0] || 'disable'
    }

    if (roomProperties.videoOff) {
      roomProperties.videoOff.value =
        roomProperties.videoOff.value?.split('_')[0] || 'disable'
    }

    // 筛选在rtc房间中的用户
    let hostUuid = ''
    let hostName = ''
    let systemAudioUuid = ''
    const screenUuid = (this
      .rtcController as NERoomRtcController)?.getScreenSharingUserUuid()

    let whiteboardUuid =
      roomProperties.wbSharingUuid && roomProperties.wbSharingUuid.value

    if (!whiteboardUuid) {
      try {
        whiteboardUuid = this.roomContext.whiteboardController?.getWhiteboardSharingUserUuid()
      } catch (e) {
        console.warn('getWhiteboardSharingUserUuid error', e)
      }
    }

    const annotationEnabled =
      this.roomContext.annotationController?.isAnnotationEnabled() || false

    const meetingChatPermission = roomProperties.crPerm?.value
      ? Number(roomProperties.crPerm?.value)
      : 1

    const waitingRoomChatPermission = roomProperties.wtPrChat?.value
      ? Number(roomProperties.wtPrChat?.value)
      : 1

    const remoteViewOrder = roomProperties.viewOrder?.value

    let interpretation: InterpretationRes | undefined = undefined
    let isInterpreter = false

    if (roomProperties.interpretation) {
      try {
        interpretation = JSON.parse(roomProperties.interpretation.value)
        if (interpretation && interpretation.interpreters?.[localMember.uuid]) {
          isInterpreter = true
        }
      } catch (error) {
        console.log('interpretation error', error)
      }
    }

    const focusUuid = roomProperties.focus ? roomProperties.focus.value : ''

    localMember.isInChatroom = true
    const members = [localMember, ...remoteMembers]
    const memberList: NEMember[] = []
    const inSipInvitingMemberList: NEMember[] = []

    ;[...inSipInvitingMembers, ...inAppInvitingMembers].forEach((member) => {
      inSipInvitingMemberList.push({
        ...member,
        role: member.role?.name,
        isHandsUp: false,
      })
    })
    let localHandsUp = false

    members.forEach((member) => {
      // 去除只显示加入rtc房间的 ，h5断网之后会重新离开rtc，然后立马恢复，dom元素设置会存在问题，造成黑屏
      // if (member.isInRtcChannel || member.uuid === localMember.uuid) {
      if (member.hide) {
        return
      }

      if (member.isSharingSystemAudio) {
        systemAudioUuid = member.uuid
      }

      if (member.role?.name === NEMeetingRole.host) {
        hostUuid = member.uuid
        hostName = member.name
      }

      const handsUpStatus: { value: number } = member.properties?.handsUp
      // 主持人|联席主持人直接隐藏举手

      const isHandsUp =
        handsUpStatus && handsUpStatus.value ? handsUpStatus.value == 1 : false

      // member.isHandsUp = isHandUp
      if (member.uuid === localMember.uuid) {
        localHandsUp = isHandsUp
      }

      if (whiteboardUuid && member.uuid === whiteboardUuid) {
        member.isSharingWhiteboard = true
        member.properties = {
          ...member.properties,
          wbDrawable: { value: '1' },
        }
      }

      memberList.push({ ...member, role: member.role?.name, isHandsUp })
    })
    const {
      subject,
      startTime,
      endTime,
      type,
      settings,
      shortMeetingNum,
      meetingNum,
      meetingId,
      meetingInviteUrl = '',
      roomArchiveId,
      ownerUserUuid,
      recurringRule,
      timezoneId,
    } = this._meetingInfo
    let isScheduledMeeting = 0

    if (recurringRule) {
      isScheduledMeeting = 2
    } else if (type === 3) {
      isScheduledMeeting = 1
    }

    let watermark = {}

    try {
      watermark =
        Object.prototype.toString.call(roomProperties.watermark?.value) ===
        '[object Object]'
          ? roomProperties.watermark?.value
          : JSON.parse(roomProperties.watermark?.value || {})
    } catch (error) {
      console.log('watermark error', error)
    }

    const permissionConfig = getMeetingPermission(
      Number(roomProperties.securityCtrl?.value || 0) || 0
    )

    return {
      memberList,
      inInvitingMemberList: inSipInvitingMemberList,
      meetingInfo: {
        localMember: {
          ...localMember,
          role: localMember.role?.name as Role,
          isHandsUp: localHandsUp,
          inviteState: (localMember.inviteState as unknown) as NEMeetingInviteStatus,
        },
        meetingInviteUrl,
        myUuid: localMember.uuid,
        focusUuid,
        hostUuid,
        systemAudioUuid,
        hostName,
        isSupportChatroom: !!this.chatController?.isSupported,
        screenUuid,
        whiteboardUuid,
        annotationEnabled,
        meetingChatPermission,
        waitingRoomChatPermission,
        isAllowParticipantsEnableCaption: this.getIsAllowParticipantsEnableCaption(),
        remoteViewOrder,
        isScheduledMeeting: isScheduledMeeting,
        scheduledMeetingViewOrder: settings.roomInfo.viewOrder,
        isWaitingRoomEnabled: this.waitingRoomController?.isWaitingRoomEnabledOnEntry(),
        properties: roomProperties,
        password: this.roomContext.password,
        ...permissionConfig,
        subject: subject || '',
        startTime: startTime || 0,
        roomArchiveId: roomArchiveId || '',
        endTime: endTime || 0,
        type: type || 0,
        shortMeetingNum: shortMeetingNum || '',
        ownerUserUuid: ownerUserUuid || '',
        timezoneId,
        sipCid: this.roomContext.sipCid,
        rtcStartTime: this.roomContext.rtcStartTime,
        isScreenSharingMeeting:
          roomProperties.rooms_screen_share_mode?.value === '1',
        activeSpeakerUuid: '',
        meetingId: meetingId,
        meetingNum: meetingNum || '',
        isTranscriptionEnabled: roomProperties.transcript?.value === '1',
        inWaitingRoom: this.roomContext.isInWaitingRoom(),
        maxMembers: this.roomContext.maxMembers,
        remainingSeconds: this.roomContext.remainingSeconds,
        isCloudRecording: this.roomContext.isCloudRecording,
        cloudRecordState: this.roomContext.isCloudRecording
          ? RecordState.Recording
          : RecordState.NotStart,
        // isUnMutedAudio: this.isUnMutedAudio,
        // isUnMutedVideo: this.isUnMutedVideo,
        videoOff: roomProperties.videoOff
          ? roomProperties.videoOff.value
          : AttendeeOffType.disable,
        audioOff: roomProperties.audioOff
          ? roomProperties.audioOff.value
          : AttendeeOffType.disable,
        isLocked:
          roomProperties.lock?.value === 1 || this.roomContext.isRoomLocked,
        enableGuestJoin: roomProperties.guest?.value === '1',
        liveConfig: settings.liveConfig,
        watermark,
        enableBlacklist: !!this.roomContext?.isRoomBlacklistEnabled,
        interpretation: interpretation,
        isInterpreter: isInterpreter,
      },
    }
  }
  // 发送成员会控操作
  sendMemberControl(
    type: memberAction,
    uuid?: string
  ): Promise<NEResult<null> | undefined> {
    return this._handleMemberAction(type, uuid)
  }
  async putInWaitingRoom(uuid: string): Promise<NEResult<null> | undefined> {
    return this.waitingRoomController?.putInWaitingRoom(uuid)
  }
  async admitMember(
    uuid: string,
    autoAdmit?: boolean
  ): Promise<NEResult<null> | undefined> {
    return this.waitingRoomController?.admitMember(uuid, autoAdmit)
  }
  async admitAllMembers(): Promise<NEResult<null> | undefined> {
    return this.waitingRoomController?.admitAllMembers()
  }
  async expelMember(
    uuid: string,
    notAllowJoin?: boolean
  ): Promise<NEResult<null> | undefined> {
    return this.waitingRoomController?.expelMember(uuid, notAllowJoin)
  }
  async expelAllMembers(
    disallowRejoin: boolean
  ): Promise<NEResult<null> | undefined> {
    return this.waitingRoomController?.expelAllMembers(disallowRejoin)
  }
  async waitingRoomChangeMemberName(
    uuid: string,
    name: string
  ): Promise<NEResult<null> | undefined> {
    return this.waitingRoomController?.changeMemberName(uuid, name)
  }
  async waitingRoomGetMemberList(
    time: number,
    limit: number,
    asc: boolean
  ): Promise<NEResult<Array<NEWaitingRoomMember>> | undefined> {
    return this.waitingRoomController
      ?.getMemberList(time, limit, asc)
      .then((res) => {
        this.eventEmitter.emit(
          MeetingEventType.waitingRoomMemberListChange,
          res.data
        )
        return res
      })
  }
  async enableRoomBlackList(
    enable: boolean
  ): Promise<NEResult<null> | undefined> {
    return this.roomContext?.enableRoomBlacklist(enable)
  }
  sendHostControl(
    type: hostAction,
    uuid: string,
    extraData?
  ): Promise<NEResult<null> | undefined> {
    return this._handleHostAction(type, uuid, extraData)
  }
  async startShareSystemAudio(): Promise<NEResult<null> | undefined> {
    return this.rtcController?.startShareSystemAudio?.()
  }
  async stopShareSystemAudio(): Promise<NEResult<null> | undefined> {
    return this.rtcController?.stopShareSystemAudio?.()
  }
  async getScreenCaptureSourceList(): Promise<
    NEResult<NERoomRtcScreenCaptureSource[]> | undefined
  > {
    return this.rtcController?.getScreenCaptureSourceList?.()
  }
  async enableInterpreterAudioPub(
    enable: boolean,
    needCheckAudio = true,
    channelName?: string
  ) {
    this._logger.debug('enableInterpreterAudioPub', channelName, enable)
    if (this.isMySelfInterpreter() && this.interpretation && this.localMember) {
      const speakerLang = this._interpretationSetting?.speakerLanguage

      if (speakerLang) {
        const speakerChannel =
          channelName || this.interpretation.channelNames[speakerLang]

        if (speakerChannel) {
          try {
            await this.enableAndPubAudio(enable, speakerChannel, needCheckAudio)
          } catch (error) {
            this._logger.debug('muteLocalAudio enableLocalAudio error', error)
          }
        }
      }
    }
  }

  async muteMajorAudio(mute: boolean, volume?: number) {
    volume = volume || volume === 0 ? volume : MAJOR_DEFAULT_VOLUME
    return this.rtcController?.adjustChannelPlaybackSignalVolume(
      '',
      mute ? 0 : volume
    )
  }
  async enableAndPubAudio(
    enable: boolean,
    channelName: string,
    needCheckAudio = true
  ) {
    this._logger.debug(
      'enableAndPubAudio local audio',
      enable,
      channelName,
      needCheckAudio,
      this.localMember?.isAudioOn
    )
    if (needCheckAudio && !this.localMember?.isAudioOn) {
      this._logger.debug('enableAndPubAudio local audio is off')
      return
    }

    try {
      await this.rtcController?.enableLocalAudio(channelName, enable)
      if (channelName) {
        this.rtcController?.enableAudioVolumeIndication(
          true,
          500,
          enable,
          channelName
        )
      }
    } catch (error) {
      this._logger.debug('muteLocalAudio enableLocalAudio error', error)
    }

    // web没有独立的unpub 音频。不需要走。enable对应流即可
    if (window.isElectronNative) {
      await this.rtcController?.enableMediaPub(channelName, 0, enable)
    }
  }
  async muteLocalAudio(): Promise<NEResult<null> | undefined | boolean> {
    // 如果本地音频没有连接则不执行
    if (!this.localMember?.isAudioConnected) {
      return
    }

    logger.debug('muteLocalAudio %t')

    if (this.rtcController) {
      // 如果是译员同时不是翻译主频道，需要把对应频道也关闭
      return this.rtcController
        .muteMyAudio()
        .then(async (res) => {
          return res
        })
        .finally(() => {
          // 这个时候音频已关闭状态，不能根据isAudio判断是否enableLocalAudio
          this.enableInterpreterAudioPub(false, false)
        })
    } else {
      return false
    }
  }
  async reconnectMyAudio(): Promise<NEResult<null>> {
    if (this.rtcController) {
      // 如果开启了同传 需要处理传译频道
      if (this.interpretation?.started) {
        if (
          this.localMember?.isAudioOn &&
          this.isMySelfInterpreter() &&
          this._interpretationSetting?.speakerLanguage !== MAJOR_AUDIO
        ) {
          const channelName = this.interpretation?.channelNames[
            this._interpretationSetting?.speakerLanguage || ''
          ]

          try {
            channelName &&
              this.enableInterpreterAudioPub(true, true, channelName)
          } catch (error) {
            this._logger.debug('connectMyAudio enableLocalAudio error', error)
          }
        }

        if (this._interpretationSetting?.listenLanguage !== MAJOR_AUDIO) {
          const channelName = this.interpretation?.channelNames[
            this._interpretationSetting?.listenLanguage || ''
          ]
          let listeningVolume = getLocalStorageSetting()?.audioSetting
            ?.playouOutputtVolume

          if (!listeningVolume && listeningVolume !== 0) {
            listeningVolume = 70
          }

          channelName &&
            this.rtcController.adjustChannelPlaybackSignalVolume(
              channelName,
              listeningVolume
            )
        }
      }

      return this.rtcController.reconnectMyAudio()
    }

    return Promise.reject({
      code: 400,
      message: 'rtcController is null',
    })
  }
  async disconnectMyAudio(): Promise<NEResult<null>> {
    if (this.rtcController) {
      if (this.interpretation?.started) {
        if (
          this.localMember?.isAudioOn &&
          this.isMySelfInterpreter() &&
          this._interpretationSetting?.speakerLanguage !== MAJOR_AUDIO
        ) {
          const channelName = this.interpretation?.channelNames[
            this._interpretationSetting?.speakerLanguage || ''
          ]

          try {
            channelName &&
              this.enableInterpreterAudioPub(false, true, channelName)
          } catch (error) {
            this._logger.debug(
              'disconnectMyAudio enableLocalAudio error',
              error
            )
          }
        }

        if (this._interpretationSetting?.listenLanguage !== MAJOR_AUDIO) {
          const channelName = this.interpretation?.channelNames[
            this._interpretationSetting?.listenLanguage || ''
          ]

          channelName &&
            this.rtcController.adjustChannelPlaybackSignalVolume(channelName, 0)
        }
      }

      return this.rtcController.disconnectMyAudio()
    }

    return Promise.reject({
      code: 400,
      message: 'rtcController is null',
    })
  }
  async takeRemoteScreenSnapshot(
    uuid: string
  ): Promise<NEResult<string | Uint8Array | undefined> | undefined> {
    return await this.rtcController?.takeRemoteSnapshot(uuid, 1)
  }
  async takeLocalScreenSnapshot(): Promise<
    NEResult<string | Uint8Array | undefined> | undefined
  > {
    return await this.rtcController?.takeLocalSnapshot?.(1)
  }
  async sendEmoticon(key: string) {
    const commandId = 11000
    const data = {
      cmdId: commandId,
      emojiTag: key,
    }

    if (this.chatController?.isSupported) {
      this.chatController?.sendBroadcastCustomMessage(JSON.stringify(data))
      // 自己显示
      this.eventEmitter?.emit(EventType.OnEmoticonsReceived, {
        userUuid: this.localMember?.uuid,
        emojiKey: key,
      })
    } else {
      const roomUuid = this._meetingInfo.roomUuid

      roomUuid &&
        this.messageService?.sendCustomMessageToRoom(
          roomUuid,
          commandId,
          JSON.stringify(data)
        )
    }
  }

  annotationLogin(): void {
    this.annotationController?.login()
  }
  annotationAuth(): void {
    this.annotationController?.auth()
  }
  async getAnnotationUrl(): Promise<string | undefined> {
    return this.annotationController?.getWhiteboardUrl()
  }
  setAnnotationEnableDraw(enable: boolean): void {
    this.annotationController?.setEnableDraw(enable)
    window.ipcRenderer?.send(IPCEvent.annotationWindow, {
      event: 'setIgnoreMouseEvents',
      payload: !enable,
    })
  }

  async unmuteLocalAudio(
    deviceId?: string,
    ignoreAudioConnectedState: boolean = false
  ): Promise<
    NEResult<null> | NEResult<NEDeviceSwitchInfo> | undefined | boolean
  > {
    // 如果本地音频没有连接则不执行
    if (!this.localMember?.isAudioConnected && !ignoreAudioConnectedState) {
      return
    }

    this._logger.debug('unmuteLocalAudio %t')

    if (this.rtcController) {
      if (deviceId) {
        return this.rtcController.switchDevice({
          type: 'microphone',
          deviceId: getDefaultDeviceId(deviceId),
        })
      } else {
        const needPub =
          !this.isMySelfInterpreter() ||
          (this.isMySelfInterpreter() &&
            this._interpretationSetting?.speakerLanguage === MAJOR_AUDIO) ||
          !this._interpretationSetting?.speakerLanguage

        this._logger.debug(
          'unmuteLocalAudio needPub',
          needPub,
          this.isMySelfInterpreter(),
          this._interpretationSetting
        )
        return this.rtcController
          .unmuteMyAudio(needPub)
          .then(async (res) => {
            this.enableInterpreterAudioPub(true)
            return res
          })
          .catch((e) => {
            if (e.code === 50000) {
              this.eventEmitter.emit(MeetingEventType.noMicPermission)
            }

            if (e.code === 10212) {
              this.rtcController?.muteMyAudio().catch((e) => {
                console.log('10212 muteMyAudio error', e)
              })
            }

            throw e
          })
      }
    } else {
      return false
    }
  }
  switchDevice(options: {
    type: DeviceType
    deviceId: string
  }): Promise<NEResult<NEDeviceSwitchInfo>> {
    if (this.rtcController) {
      options.deviceId = getDefaultDeviceId(options.deviceId)
      return this.rtcController.switchDevice(options)
    }

    return Promise.reject({
      code: 400,
      message: 'rtcController is null',
    })
  }
  async muteLocalVideo(need = true): Promise<NEResult<null> | undefined> {
    logger.debug('muteLocalVideo %t')

    if (need) {
      return this.sendMemberControl(memberAction.muteVideo)
    }

    return this.rtcController?.muteMyVideo()
  }

  async unmuteLocalVideo(
    facingMode?: 'user' | 'environment'
  ): Promise<NEResult<null> | undefined> {
    return this.rtcController?.unmuteMyVideo(true, facingMode).catch((e) => {
      // 没有权限
      if (e.code == 50000) {
        console.log('权限错误')
        this.eventEmitter.emit(MeetingEventType.noCameraPermission)
      }

      if (e.code === 10212 && !window.isElectronNative) {
        this.rtcController?.muteMyVideo().catch((e) => {
          console.log('10212 muteMyVideo error', e)
        })
      }

      throw e
    })
  }

  async startCloudRecord(): Promise<NEResult<null> | undefined> {
    return this.roomContext?.startCloudRecord()
  }

  async stopCloudRecord(): Promise<NEResult<null> | undefined> {
    return this.roomContext?.stopCloudRecord()
  }
  /**
   *
   * @param enable 开启或关闭
   * @param videoOrder 视频排序
   */
  async syncViewOrder(
    enable: boolean,
    videoOrder: string
  ): Promise<NEResult<null> | undefined> {
    if (enable) {
      return this.roomContext?.updateRoomProperty('viewOrder', videoOrder)
    } else {
      return this.roomContext?.deleteRoomProperty('viewOrder')
    }
  }

  async enableTranscription(enable: boolean) {
    return this.liveTranscriptionController?.enableTranscription(enable)
  }

  async allowParticipantsEnableCaption(
    allow: boolean
  ): Promise<NEResult<null> | undefined> {
    if (allow) {
      return this.roomContext?.deleteRoomProperty('capPerm')
    } else {
      return this.roomContext?.updateRoomProperty('capPerm', '0')
    }
  }

  async getRoomCloudRecordList(
    roomArchiveId: number
  ): Promise<NEResult<NERoomRecord[]>> {
    if (this.roomService) {
      return await this.roomService.getRoomCloudRecordList(
        String(roomArchiveId)
      )
    }

    return SuccessBody([])
  }

  async muteLocalScreenShare(): Promise<NEResult<null> | undefined> {
    logger.debug('muteLocalScreenShare')

    return this.rtcController?.stopScreenShare().then(() => {
      if (window.isElectronNative) {
        return this.annotationController?.stopAnnotation()
      }
    })
  }

  async startAnnotation(): Promise<NEResult<null> | undefined> {
    return this.annotationController?.startAnnotation()
  }

  async unmuteLocalScreenShare(
    params?: NERoomScreenConfig
  ): Promise<NEResult<null> | undefined> {
    logger.debug('unmuteLocalScreenShare %t %o', params)

    let options = params

    if (!window.isElectronNative) {
      options = { ...params, sourceId: this._screenSharingSourceId }
    }

    return this.rtcController?.startScreenShare(options)
  }

  async changeLocalAudio(
    deviceId: string
  ): Promise<NEResult<NEDeviceSwitchInfo> | undefined> {
    return this.rtcController?.switchDevice({
      type: 'microphone',
      deviceId: getDefaultDeviceId(deviceId),
    })
  }

  async changeLocalVideo(
    deviceId: string
  ): Promise<NEResult<NEDeviceSwitchInfo> | undefined> {
    return this.rtcController?.switchDevice({
      type: 'camera',
      deviceId: getDefaultDeviceId(deviceId),
    })
  }
  // 邀请加入
  async acceptInvite(options: NEMeetingJoinOptions): Promise<void> {
    try {
      logger.debug('acceptInvite')
      const joinOptions = {
        ...options,
        role: options.role || Role.member,
        type: 'joinByInvite',
      }

      // 如果是自己创建会议时候提示会议已经存在且是个人会议则使用个人会议号
      return this._joinHandler(joinOptions)
    } catch (e: unknown) {
      logger.debug('acceptInvite() failed: %o', e)
      return Promise.reject(e)
    }
  }
  async join(options: NEMeetingJoinOptions): Promise<void> {
    try {
      options.role = options.role || Role.member
      // this.isUnMutedAudio = options.audio == 1
      // this.isUnMutedVideo = options.video == 1
      logger.debug('_meetingStatus:  %s %t', this._meetingStatus)
      if (
        this._meetingStatus === 'created' ||
        this._meetingStatus === 'login'
      ) {
        logger.debug('join() %o %t', options)
        // 如果是自己创建会议时候提示会议已经存在且是个人会议则使用个人会议号
      }

      // 如果是自己创建会议时候提示会议已经存在且是个人会议则使用个人会议号
      this._noChat = !!options.noChat
      console.log('start join')
      return this._joinHandler(options)
    } catch (e: unknown) {
      logger.debug('join() failed: %o', e)
      return Promise.reject(e)
    }
  }
  getSelectedRecordDevice(): string {
    return this.rtcController?.getSelectedRecordDevice() || ''
  }
  getSelectedCameraDevice(): string {
    return this.rtcController?.getSelectedCameraDevice() || ''
  }
  getSelectedPlayoutDevice(): string {
    return this.rtcController?.getSelectedPlayoutDevice() || ''
  }

  async getMicrophones(): Promise<NEDeviceBaseInfo[]> {
    if (this.rtcController) {
      const res = await this.rtcController.enumRecordDevices()

      logger.debug('getMicrophones success, %o %t', res.data)
      const data = setDefaultDevice(res.data)

      return data
    } else {
      logger.warn('getMicrophones no previewController %t')
      return []
    }
  }
  async getCameras(): Promise<NEDeviceBaseInfo[]> {
    logger.debug('getCameras')
    if (this.rtcController) {
      const res = await this.rtcController.enumCameraDevices()

      logger.debug('getCameras success, %o %t', res.data)
      const data = setDefaultDevice(res.data)

      return data
    } else {
      logger.warn('getCameras no _webrtc %t')
      return []
    }
  }
  async getSpeakers(): Promise<NEDeviceBaseInfo[]> {
    logger.debug('getSpeakers %t')
    if (this.rtcController) {
      const res = await this.rtcController.enumPlayoutDevices()

      logger.debug('getSpeakers success, %o %t', res.data)
      const data = setDefaultDevice(res.data)

      return data
    } else {
      logger.warn('getSpeakers no _webrtc %t')
      return []
    }
  }
  //选择要使用的扬声器
  async selectSpeakers(
    speakerId: string
  ): Promise<NEResult<NEDeviceSwitchInfo> | undefined> {
    logger.debug('selectSpeakers %s %t', speakerId)
    return this.rtcController?.switchDevice({
      type: 'speaker',
      deviceId: getDefaultDeviceId(speakerId),
    })
  }

  setVideoProfile(
    resolution: VideoResolution,
    frameRate?: VideoFrameRate
  ): void | undefined {
    logger.debug('setVideoProfile success %o %o %t', resolution, frameRate)
    const options = {
      resolution,
      frameRate: frameRate,
    }

    return this.rtcController?.setLocalVideoConfig(options)
  }
  setAudioProfile(profile: AudioProfile): void | undefined {
    return this.rtcController?.setLocalAudioProfile(profile)
  }
  setAudioProfileInEle(
    profile: tagNERoomRtcAudioProfileType,
    scenario: tagNERoomRtcAudioScenarioType
  ): void | undefined {
    return this.rtcController?.setAudioProfileInEle?.(profile, scenario)
  }
  // 是否开启AI降噪
  enableAudioAINS(enable: boolean): number | undefined {
    return this.rtcController?.enableAudioAINS?.(enable)
  }
  // 是否开启回音消除
  enableAudioEchoCancellation(enable: boolean): number | undefined {
    return this.rtcController?.enableAudioEchoCancellation?.(enable)
  }
  // 是否开启自动调节麦克风音量
  enableAudioVolumeAutoAdjust(enable: boolean): number | undefined {
    return this.rtcController?.enableAudioVolumeAutoAdjust?.(enable)
  }
  // 修改会中昵称
  async modifyNickName(options: {
    nickName: string
    userUuid?: string
  }): Promise<NEResult<null> | undefined> {
    // 如果有userUuid则修改指定用户的昵称
    if (options.userUuid) {
      return this.roomContext?.changeMemberName(
        options.userUuid,
        options.nickName
      )
    }

    return this.roomContext?.changeMyName(options.nickName).then((res) => {
      if (options.userUuid === this.localMember?.uuid) {
        //修改自己昵称 保存昵称，会议逻辑
        localStorage.setItem(
          'ne-meeting-nickname-' + this.localMember?.uuid,
          JSON.stringify({
            [this.meetingNum]: options.nickName,
            [this.shortMeetingNum]: options.nickName,
          })
        )
      }

      return res
    })
  }

  async replayRemoteStream(options: {
    userUuid: string
    type: NEMediaTypes
    isRestricted?: boolean
  }): Promise<NEResult<null> | undefined> {
    logger.debug('replayRemoteStream %s %t', options.userUuid, options.type)
    return this.rtcController?.replayRemoteStream(options)
  }

  checkSystemRequirements(): boolean | undefined {
    return this.previewController?.checkSystemRequirements()
  }

  async destroy(): Promise<void> {
    logger.debug('destroy() %t')
    // this._unbindWebrtcEvent()
    // this._unbindSignalEvent()
    // await this._siganling.destroy()
    // if (this.rtcController) {
    //   if (this._meetingStatus === 'joined') {
    //     await this._webrtc.leave();
    //   }
    //   await this._webrtc.destroy();
    // }
    this.subscribeMembersMap = {}
    await this.destroyRoomContext()
    // this.authService?.logout()
    // this._meetingStatus = 'unlogin'
  }

  async release(): Promise<void> {
    // 避免缓存
    this.authService = null
    this.roomService = null
    this.previewController = null
    this.messageService = null
    this.nosService = null
    await this._roomkit.release()
  }

  destroyRoomContext(): void {
    logger.debug('destroyRoomContext() %t')
    // this.roomContext && (await this.roomContext.destroy())
    if (this._isAnonymous) {
      this._meetingStatus = 'unlogin'
      // this.authService && this.authService.logout()
      this._isAnonymous = false
    }

    this._reset()
  }
  /**
   * guest info
   */
  getGuestInfo(params: {
    meetingNum: string
    phoneNum?: string
    verifyCode?: string
  }): Promise<{
    meetingAuthType: string
    meetingUserUuid: string
    meetingUserToken: string
  }> {
    let url = `/scene/meeting/${this.appKey}/v1/info/${params.meetingNum}/guest`

    if (params.phoneNum && params.verifyCode) {
      url = `${url}?phoneNum=${params.phoneNum}&verifyCode=${params.verifyCode}`
    }

    return this._request.get(url).then((res) => {
      return res.data
    })
  }
  /**
   * 获取参会记录列表
   */
  getHistoryMeetingList(
    params: {
      startId?: number
      limit?: number
    } = {}
  ): Promise<{ meetingList: MeetingListItem[] }> {
    if (params.startId === 0) {
      delete params.startId
    }

    return this._request
      .get(`/scene/meeting/${this.appKey}/v1/meeting/history/list`, {
        params,
      })
      .then((res) => {
        return res.data
      })
  }

  startAISummaryApi(): Promise<void> {
    return this._request.post(
      `/scene/meeting/v1/ai-summary-task/start?meetingId=${this.meetingId}`
    )
  }

  saveSettings(settings: SaveSettingInterface): Promise<void> {
    return this._request.patch(
      `/scene/meeting/${this.appKey}/v1/account/settings`,
      {
        settings,
      }
    )
  }

  /*
   * 获取历史会议的转写信息
   * @param meetingId 会议唯一 Id
   */
  getHistoryMeetingTranscriptionInfo(
    meetingId: number
  ): Promise<NEMeetingTranscriptionInfo[]> {
    return this._request
      .get(`/scene/meeting/v1/${meetingId}/transcript-record`)
      .then((res) => {
        return res.data
      })
  }

  // key: SecurityCtrlEnum
  securityControl(params: { [key: string]: boolean }) {
    return this._request
      .put(
        `/scene/apps/${this.appKey}/v1/rooms/${this.meetingNum}/securityCtrl`,
        {
          ...params,
        }
      )
      .then((res) => {
        return res.data
      })
  }

  // 暂停参会者活动
  stopMemberActivities() {
    return this._request
      .post(
        `/scene/meeting/v1/stop_member_activities?meetingId=${this.meetingId}`,
        {
          meetingId: this.meetingId,
        }
      )
      .then((res) => {
        return res.data
      })
  }

  /*
   * 获取历史会议的转写文件下载地址
   * @param meetingId 会议唯一 Id
   * @param fileKey 转写文件的文件 key
   */
  getHistoryMeetingTranscriptionFileUrl(
    meetingId: number,
    fileKey: string
  ): Promise<string> {
    return this._request
      .get(
        `/scene/meeting/v1/${meetingId}/transcript-file/download-url?nosFileKey=${fileKey}`
      )
      .then((res) => {
        return res.data
      })
  }

  /**
   * 获取参会记录列表
   */
  getHistoryMeetingDetail(params: {
    roomArchiveId: number | string
  }): Promise<NEHistoryMeetingDetail> {
    return this._request
      .get(`/scene/meeting/${this.appKey}/v1/meeting-history-detail`, {
        params,
      })
      .then((res) => {
        return {
          chatroomInfo: res.data.chatroom,
          pluginInfoList: res.data.pluginInfoList?.map((item) => {
            return {
              ...item,
              sessionId: item.sessionId || item.notifySenderAccid,
            }
          }),
        }
      })
  }
  /**
   * 获取历史参会记录
   */
  getHistoryMeeting(params: {
    meetingId: string | number
  }): Promise<MeetingListItem> {
    return this._request
      .get(
        `/scene/meeting/${this.appKey}/v1/meeting/history/${params.meetingId}`
      )
      .then((res) => {
        return res.data ?? {}
      })
  }

  /**
   * 获取收藏参会列表
   */
  getCollectMeetingList(
    params: {
      startId?: number
      limit?: number
    } = {}
  ): Promise<{ favoriteList: MeetingListItem[] }> {
    if (params.startId === 0) {
      delete params.startId
    }

    return this._request
      .get(`/scene/meeting/${this.appKey}/v1/meeting/favorite/list`, {
        params,
      })
      .then((res) => {
        return res.data
      })
  }

  /**
   * 收藏会议
   */
  collectMeeting(roomArchiveId: number | string): Promise<number> {
    return this._request
      .put(
        `/scene/meeting/${this.appKey}/v1/meeting/${roomArchiveId}/favorite`,
        {},
        {
          headers: {
            'Content-Type': 'application/json;charset=utf-8',
          },
        }
      )
      .then((res) => {
        return res.data.favoriteId
      })
  }

  /**
   * 取消收藏会议
   */
  cancelCollectMeeting(roomArchiveId: number | string): Promise<void> {
    return this._request
      .delete(
        `/scene/meeting/${this.appKey}/v1/meeting/${roomArchiveId}/favorite`
      )
      .then((res) => {
        return res.data
      })
  }
  /**
   * 更新用户头像
   * @param avatar
   * @returns
   */
  async updateAccountAvatar(avatar: string | Blob): Promise<string> {
    let url

    if (typeof avatar === 'string') {
      const res = await this.nosService?.uploadResource(avatar)

      url = res?.data
    } else {
      const res = await this.nosService?.uploadResource({
        blob: avatar,
        type: 'image',
      })

      url = res?.data
    }

    return this._request
      .post(`/scene/meeting/${this.appKey}/v1/account/avatar`, {
        avatar: url,
      })
      .then(() => {
        return url
      })
  }

  isEnableWaitingRoom(): boolean | undefined {
    return this.waitingRoomController?.getWaitingRoomInfo().isEnabledOnEntry
  }

  async setupLocalVideoCanvas(uuid, isRemove: boolean) {
    //屏幕共享画面处理
    const shareVideoWindow = getWindow('shareVideoWindow')

    if (shareVideoWindow) {
      if (isRemove) {
        const context = {
          userUuid: uuid,
          sourceType: 'video',
        }

        RendererManager.instance.removeRenderer(context)
      } else {
        const view = shareVideoWindow?.document.getElementById(
          `nemeeting-${uuid}-video-card`
        )

        if (view) {
          const context = {
            view: view,
            userUuid: uuid,
            sourceType: 'video',
          }

          RendererManager.instance.createRenderer(context)
        }
      }
    }
  }

  async subscribeRemoteVideoStream(
    uuid: string,
    streamType: 0 | 1
  ): Promise<NEResult<null> | undefined> {
    if (this.subscribeMembersMap[uuid] === streamType) {
      return
    }

    const originStreamType = this.subscribeMembersMap[uuid]

    this.subscribeMembersMap[uuid] = streamType
    console.log('>>> 开始订阅 <<<<', uuid, streamType)
    //屏幕共享画面处理
    const shareVideoWindow = getWindow('shareVideoWindow')
    const view = shareVideoWindow?.document.getElementById(
      `nemeeting-${uuid}-video-card`
    )

    if (view) {
      const context = {
        view: view,
        userUuid: uuid,
        sourceType: 'video',
      }

      RendererManager.instance.createRenderer(context)
    }

    return this.rtcController
      ?.subscribeRemoteVideoStream(uuid, streamType)
      .catch((e) => {
        this.subscribeMembersMap[uuid] = originStreamType
        throw e
      })
  }
  async unsubscribeRemoteVideoStream(
    uuid: string,
    streamType: 0 | 1
  ): Promise<NEResult<null> | undefined> {
    if (
      this.subscribeMembersMap[uuid] !== 0 &&
      !this.subscribeMembersMap[uuid]
    ) {
      return
    }

    console.log('>>> 取消订阅 <<<<', uuid, streamType)
    //屏幕共享画面处理
    const shareVideoWindow = getWindow('shareVideoWindow')

    if (shareVideoWindow) {
      const context = {
        userUuid: uuid,
        sourceType: 'video',
      }

      RendererManager.instance.removeRenderer(context)
    }

    return this.rtcController
      ?.unsubscribeRemoteVideoStream(uuid, streamType)
      .then((res) => {
        delete this.subscribeMembersMap[uuid]
        return res
      })
  }

  //根据手机号码进行呼叫
  async callByNumber(data: {
    number: string
    countryCode: string
    name?: string
  }): Promise<NEResult<NERoomSipCallResponse> | undefined> {
    const { number, countryCode, name } = data

    return this.sipController?.callByNumber(number, countryCode, name)
  }

  //根据用户uuid进行呼叫
  async callByUserUuids(
    userUuids: string[]
  ): Promise<NEResult<null> | undefined> {
    return this.sipController?.callByUserUuids(userUuids)
  }

  //根据用户id进行呼叫
  async callByUserUuid(userUuid: string): Promise<NEResult<null> | undefined> {
    return this.sipController?.callByUserUuid(userUuid)
  }

  /**
   * 呼叫指定房间设备
   * @param device 设备信息
   */
  async callOutRoomSystem(
    device: NERoomSystemDevice
  ): Promise<NEResult<NERoomSipCallResponse> | undefined> {
    return this.sipController?.callOutRoomSystem(device)
  }

  //移除呼叫
  async removeCall(userUuid: string): Promise<NEResult<null> | undefined> {
    return this.sipController?.removeCall(userUuid)
  }

  //取消正在进行的呼叫，无论是正在响铃还是等待响铃都可以使用
  async cancelCall(userUuid: string): Promise<NEResult<null> | undefined> {
    return this.sipController?.cancelCall(userUuid)
  }

  // 挂断通话，挂断后成员将被踢出会议并移除列表
  async hangUpCall(userUuid: string): Promise<NEResult<null> | undefined> {
    return this.sipController?.hangUpCall(userUuid)
  }
  async inviteByUserUuids(
    userUuids: string[]
  ): Promise<NEResult<null> | undefined> {
    return this.inviteController?.callByUserUuids(userUuids)
  }

  async inviteByUserUuid(
    userUuid: string
  ): Promise<NEResult<null> | undefined> {
    return this.inviteController?.callByUserUuid(userUuid)
  }

  async cancelInvite(userUuid: string): Promise<NEResult<null> | undefined> {
    return this.inviteController?.cancelCall(userUuid)
  }

  async rejectInvite(roomUuid: string): Promise<NEResult<null> | undefined> {
    return this.roomService?.rejectInvite(roomUuid)
  }

  async joinRtcChannel(channelName: string) {
    return this.rtcController?.joinRtcChannel(channelName).then(() => {
      if (channelName) {
        this.rtcController?.enableAudioVolumeIndication(
          true,
          500,
          false,
          channelName
        )
      }
    })
  }

  async leaveRtcChannel(channelName?: string) {
    if (channelName && channelName !== MAJOR_AUDIO) {
      try {
        await this.enableAndPubAudio(false, channelName)
        await this.rtcController?.enableAudioVolumeIndication(
          false,
          500,
          false,
          channelName
        )
      } catch (e) {
        console.log('enableAudioVolumeIndication error', e)
      }
    }

    return this.rtcController?.leaveRtcChannel(channelName)
  }

  searchAccount(params: {
    name?: string
    phoneNumber?: string
    pageSize?: number
    pageNum?: number
  }): Promise<SearchAccountInfo[]> {
    return this._request
      .get(`/scene/meeting/${this.appKey}/v1/account-search`, {
        params,
      })
      .then((res) => {
        return res.data
      })
  }

  async enableCaption(enable: boolean): Promise<void> {
    this.liveTranscriptionController?.enableCaption(enable)
  }

  async setCaptionTranslationLanguage(lang: NERoomCaptionTranslationLanguage) {
    return this.rtcController?.setCaptionTranslationLanguage(lang)
  }
  getClientType() {
    return window.isElectronNative
      ? window.isWins32
        ? NEClientReportType.PC
        : NEClientReportType.MAC
      : NEClientReportType.WEB
  }
  async updateInterpretation(data: {
    interpreters?: NEMeetingInterpreter[]
  }): Promise<void> {
    const { interpreters } = data
    const interpreterMap: { [key: string]: string[] } = {}

    interpreters?.forEach((item) => {
      item.userId &&
        (interpreterMap[item.userId] = [item.firstLang, item.secondLang])
    })
    return this._request.post(
      `/scene/meeting/v2/interpretation?meetingId=${this.meetingId}`,
      {
        started: true,
        interpreters: interpreterMap,
      }
    )
  }

  async stopInterpretation(): Promise<void> {
    return this._request.post(
      `/scene/meeting/v2/interpretation?meetingId=${this.meetingId}`,
      {
        started: false,
      }
    )
  }

  private _moveToWaitingRoomReset() {
    // this.rtcController = null
    this.whiteboardController = undefined
    this.liveController = null
    this._waitingRoomChangedName = ''
    this.annotationController = undefined
  }

  private _reset(): void {
    RendererManager.instance.rtcController = undefined
    this.roomContext = null
    this.rtcController = undefined
    this.whiteboardController = undefined
    this.waitingRoomController = undefined
    this.chatController = undefined
    this.sipController = null
    this.liveController = null
    this.inviteController = null
    this._meetingType = 0
    this._isLoginedByAccount = false
    this.alreadyJoin = false
    this._waitingRoomChangedName = ''
    this._screenSharingSourceId = ''
    this.annotationController = undefined
    this._isMySelfJoinRtc = false

    this.liveTranscriptionController?.destroy()
    this.liveTranscriptionController = undefined
  }
  private _addRtcListener() {
    this.roomContext?.addRtcStatsListener({
      onNetworkQuality: (data) => {
        getWindow('settingWindow')?.postMessage({
          event: 'onNetworkQuality',
          payload: data,
        })
        this._eventEmitter.emit(EventType.NetworkQuality, data)
      },
      onRtcStats: (data) => {
        this._eventEmitter.emit(EventType.RtcStats, data)
        getWindow('settingWindow')?.postMessage({
          event: 'onRtcStats',
          payload: data,
        })
        if (window.isElectronNative) {
          const time = Math.floor(Date.now() / 1000)
          const rtt = {
            time,
            value: data.downRtt,
          }
          const packetLossRate = {
            time,
            value:
              data.txAudioPacketLossRate +
              data.txVideoPacketLossRate +
              data.rxAudioPacketLossRate +
              data.rxVideoPacketLossRate,
          }
          const audioTxBitrate = {
            time,
            value: data.txAudioKBitRate,
          }
          const audioRxBitrate = {
            time,
            value: data.rxAudioKBitRate,
          }
          const videoTxBitrate = {
            time,
            value: data.txVideoKBitRate,
          }
          const videoRxBitrate = {
            time,
            value: data.rxVideoKBitRate,
          }

          monitoringData.network.rtt.length > 90 &&
            monitoringData.network.rtt.shift()
          monitoringData.network.rtt.push(rtt)
          monitoringData.network.packetLossRate.length > 90 &&
            monitoringData.network.packetLossRate.shift()
          monitoringData.network.packetLossRate.push(packetLossRate)
          monitoringData.audio.audioTxBitrate.length > 90 &&
            monitoringData.audio.audioTxBitrate.shift()
          monitoringData.audio.audioTxBitrate.push(audioTxBitrate)
          monitoringData.audio.audioRxBitrate.length > 90 &&
            monitoringData.audio.audioRxBitrate.shift()
          monitoringData.audio.audioRxBitrate.push(audioRxBitrate)
          monitoringData.video.videoTxBitrate.length > 90 &&
            monitoringData.video.videoTxBitrate.shift()
          monitoringData.video.videoTxBitrate.push(videoTxBitrate)
          monitoringData.video.videoRxBitrate.length > 90 &&
            monitoringData.video.videoRxBitrate.shift()
          monitoringData.video.videoRxBitrate.push(videoRxBitrate)
        }

        getWindow('monitoringWindow')?.postMessage({
          event: 'monitoring',
          payload: monitoringData,
        })
      },
      onLocalAudioStats: (data) => {
        if (window.isElectronNative && Array.isArray(data)) {
          const maxRecordVolume = data.reduce((prev, current) => {
            return prev > current.capVolume ? prev : current.capVolume
          }, 0)
          const time = Math.floor(Date.now() / 1000)

          monitoringData.audio.recordVolume.length > 90 &&
            monitoringData.audio.recordVolume.shift()
          monitoringData.audio.recordVolume.push({
            time,
            value: maxRecordVolume,
          })
        }

        getWindow('settingWindow')?.postMessage({
          event: 'onLocalAudioStats',
          payload: data,
        })
      },
      onRemoteAudioStats: (data) => {
        if (window.isElectronNative) {
          const arr = Object.values(data).flat()

          const maxPlayVolume = arr.reduce((prev, current) => {
            return prev > current.volume ? prev : current.volume
          }, 0)
          const time = Math.floor(Date.now() / 1000)

          monitoringData.audio.playVolume.length > 90 &&
            monitoringData.audio.playVolume.shift()
          monitoringData.audio.playVolume.push({
            time,
            value: maxPlayVolume,
          })
        }

        getWindow('settingWindow')?.postMessage({
          event: 'onRemoteAudioStats',
          payload: data,
        })
      },
      onLocalVideoStats: (data) => {
        if (window.isElectronNative) {
          const screen = data.find((item) => item.layerType === 2)
          const time = Math.floor(Date.now() / 1000)

          if (screen) {
            monitoringData.screen.screenTxBitrate.length > 90 &&
              monitoringData.screen.screenTxBitrate.shift()
            monitoringData.screen.screenTxBitrate.push({
              time,
              value: screen.sentBitRate,
            })
          }
        }

        getWindow('settingWindow')?.postMessage({
          event: 'onLocalVideoStats',
          payload: data,
        })
      },
      onRemoteVideoStats: (data) => {
        if (window.isElectronNative) {
          const videos = Object.values(data).flat()
          const screen = videos.find((item) => item.layerType === 2)
          const time = Math.floor(Date.now() / 1000)

          if (screen) {
            monitoringData.screen.screenTxBitrate.length > 90 &&
              monitoringData.screen.screenTxBitrate.shift()
            monitoringData.screen.screenTxBitrate.push({
              time,
              value: screen.receivedBitRate,
            })
          }
        }

        getWindow('settingWindow')?.postMessage({
          event: 'onRemoteVideoStats',
          payload: data,
        })
      },
    })
  }
  private _addPreviewListener() {
    if (this._previewListener) {
      return
    }

    const previewRoomContext = this.roomService?.getPreviewRoomContext()

    this._previewListener = {
      onLocalAudioVolumeIndication: (volume: number) => {
        const settingWindow = getWindow('settingWindow')

        settingWindow?.postMessage(
          {
            event: EventType.RtcLocalAudioVolumeIndication,
            payload: {
              volume,
            },
          },
          settingWindow.origin
        )
      },
      onRtcVirtualBackgroundSourceEnabled: (enabled, reason) => {
        const settingWindow = getWindow('settingWindow')

        settingWindow?.postMessage(
          {
            event: EventType.rtcVirtualBackgroundSourceEnabled,
            payload: {
              enabled,
              reason,
            },
          },
          settingWindow.origin
        )
      },
    }
    previewRoomContext?.addPreviewRoomListener(this._previewListener)
  }

  private _removePreviewListener() {
    const previewRoomContext = this.roomService?.getPreviewRoomContext()

    if (this._previewListener) {
      previewRoomContext?.removePreviewRoomListener(this._previewListener)
      this._previewListener = null
    }
  }

  private _addWaitRoomListener() {
    this.waitingRoomController?.addListener({
      onMemberJoin: (member, reason) => {
        this._eventEmitter.emit(EventType.MemberJoinWaitingRoom, member, reason)
      },
      onMemberLeave: (memberId, reason) => {
        this._eventEmitter.emit(
          EventType.MemberLeaveWaitingRoom,
          memberId,
          reason
        )
      },
      onMemberAdmitted: (memberId) => {
        this._eventEmitter.emit(EventType.MemberAdmitted, memberId)
      },
      onMemberNameChanged: (memberId, name) => {
        this._eventEmitter.emit(
          EventType.MemberNameChangedInWaitingRoom,
          memberId,
          name
        )
        console.log('>>>>>>>', this.localMember?.inWaitingRoom)
        // 如果是本端则表示，被修改昵称的同事被准入, 不能放到hooks中，可能这个时候消息监听还没起来
        if (this.localMember?.uuid === memberId) {
          this._waitingRoomChangedName = name
        }
      },
      onMyWaitingRoomStatusChanged: (status, reason) => {
        // 被移入等候室
        if (status === 1 && reason == 1) {
          this._moveToWaitingRoomReset()
          this._meetingStatus = 'login'
        }

        this._eventEmitter.emit(
          EventType.MyWaitingRoomStatusChanged,
          status,
          reason
        )
      },
      onWaitingRoomInfoUpdated: (info) => {
        this._eventEmitter.emit(EventType.WaitingRoomInfoUpdated, info)
      },
      onAllMembersKicked: () => {
        this._eventEmitter.emit(EventType.WaitingRoomAllMembersKicked)
      },
      onManagersUpdated: (data) => {
        this._eventEmitter.emit(
          EventType.WaitingRoomOnManagersUpdated,
          data.map((item) => ({
            ...item,
            role: item.role.name,
          }))
        )
      },
    })
  }

  private _addAnnotationView() {
    const sendRoomAnnotationWebJsBridge = (webJsBridge: string) => {
      this._eventEmitter.emit(EventType.RoomAnnotationWebJsBridge, webJsBridge)
      const annotationWindow = getWindow('annotationWindow')

      annotationWindow?.postMessage({
        event: 'eventEmitter',
        payload: {
          key: EventType.RoomAnnotationWebJsBridge,
          args: [webJsBridge],
        },
      })
    }

    this.annotationController?.setupCanvas({
      onLogin: sendRoomAnnotationWebJsBridge,
      onLogout: sendRoomAnnotationWebJsBridge,
      onAuth: sendRoomAnnotationWebJsBridge,
      onDrawEnableChanged: sendRoomAnnotationWebJsBridge,
      onToolConfigChanged: sendRoomAnnotationWebJsBridge,
    })
  }

  private _addRoomListener() {
    this.roomContext &&
      this.roomContext.addRoomListener({
        onMemberAudioMuteChanged: (member, mute, operatorMember) => {
          this._eventEmitter.emit(
            EventType.MemberAudioMuteChanged,
            member,
            mute,
            operatorMember
          )
        },
        onMemberJoinChatroom: async (members) => {
          console.log('onMemberJoinChatroom', members[0])
        },
        onMemberJoinRoom: (members) => {
          const inviteWindow = getWindow('inviteWindow')

          inviteWindow?.postMessage({
            event: 'eventEmitter',
            payload: {
              key: EventType.MemberJoinRoom,
              args: [members],
            },
          })
          const interpreterSettingWindow = getWindow('interpreterSettingWindow')

          interpreterSettingWindow?.postMessage({
            event: 'eventEmitter',
            payload: {
              key: EventType.MemberJoinRoom,
              args: [members],
            },
          })
          this._eventEmitter.emit(EventType.MemberJoinRoom, members)
        },
        onMemberNameChanged: (member, name) => {
          if (window.isElectronNative) {
            const interpreterSettingWindow = getWindow(
              'interpreterSettingWindow'
            )

            interpreterSettingWindow?.postMessage({
              event: 'eventEmitter',
              payload: {
                key: EventType.MemberJoinRoom,
                args: [member, name],
              },
            })
          }

          this._eventEmitter.emit(EventType.MemberNameChanged, member, name)
        },
        onMemberJoinRtcChannel: async (members) => {
          if (!this._isMySelfJoinRtc) {
            const member = members?.find((member) => {
              return member.uuid === this.localMember?.uuid
            })

            if (member) {
              this._isMySelfJoinRtc = true
              this._joinTimeoutTimer && clearTimeout(this._joinTimeoutTimer)
              this._joinTimeoutTimer = null
            }
          }

          this._eventEmitter.emit(EventType.MemberJoinRtcChannel, members)
        },
        onMemberLeaveChatroom: (members) => {
          console.log(EventType.MemberLeaveChatroom, members)
        },
        onMemberLeaveRoom: (members) => {
          console.log('onMemberLeaveRoom', members)

          // c++ roomkit 会触发本端离开
          if (window.isElectronNative) {
            const index = members.findIndex((item) => {
              if (typeof item === 'string') return false
              return item.uuid === this._userUuid
            })

            // 当前离开的是本端
            if (index > -1) {
              this._reset()
              this._meetingStatus = 'login'
              this._eventEmitter.emit(EventType.RoomEnded, 'LEAVE_BY_SELF')
              return
            }

            const interpreterSettingWindow = getWindow(
              'interpreterSettingWindow'
            )

            interpreterSettingWindow?.postMessage({
              event: 'eventEmitter',
              payload: {
                key: EventType.MemberJoinRoom,
                args: [members],
              },
            })

            const inviteWindow = getWindow('inviteWindow')

            inviteWindow?.postMessage({
              event: 'eventEmitter',
              payload: {
                key: EventType.MemberLeaveRoom,
                args: [members],
              },
            })
          }

          // if (
          //   members.length == 1 &&
          //   this.roomContext?.localMember.uuid === members[0].uuid
          // ) {
          //   this._meetingStatus = 'login'
          // }
          if (
            this.roomContext?.remoteMembers?.length === 0 &&
            this.roomContext.localMember.role.hide &&
            !this._leaveRoomTimer
          ) {
            this._leaveRoomTimer = setTimeout(() => {
              this._leaveRoomTimer = null
              this._eventEmitter.emit(EventType.RoomEnded, 'LEAVE_BY_SELF')
            }, 60000)
          }

          this._eventEmitter.emit(EventType.MemberLeaveRoom, members)
        },
        // onMemberLeaveRtcChannel: (members) => {
        // this._eventEmitter.emit(EventType.MemberLeaveRoom, members)
        // },
        onMemberRoleChanged: (member, beforeRole, afterRole) => {
          this._eventEmitter.emit(
            EventType.MemberRoleChanged,
            member,
            beforeRole.name,
            afterRole.name
          )
        },
        onMemberScreenShareStateChanged: async (
          member,
          isSharing,
          operator
        ) => {
          this._eventEmitter.emit(
            EventType.MemberScreenShareStateChanged,
            member,
            isSharing,
            operator
          )
        },
        onMemberSystemAudioShareStateChanged: async (
          member,
          isSharing,
          operator
        ) => {
          this._eventEmitter.emit(
            EventType.MemberSystemAudioShareStateChanged,
            member,
            isSharing,
            operator
          )
        },
        onMemberVideoMuteChanged: async (member, mute, operator) => {
          this._eventEmitter.emit(
            EventType.MemberVideoMuteChanged,
            member,
            mute,
            operator
          )
        },
        onMemberWhiteboardStateChanged: async (member, isOpen, operator) => {
          this._eventEmitter.emit(
            EventType.MemberWhiteboardStateChanged,
            member,
            isOpen,
            operator
          )
        },
        onReceiveChatroomMessages: (messages) => {
          this._eventEmitter.emit(EventType.ReceiveChatroomMessages, messages)

          // 表情回应
          const message = messages.find((item) => item.messageType === 'custom')

          if (message) {
            try {
              const attach = JSON.parse(message.attachStr)

              if (attach.emojiTag) {
                this._eventEmitter.emit(EventType.OnEmoticonsReceived, {
                  emojiKey: attach.emojiTag,
                  userUuid: message.fromUserUuid,
                })
              }
            } catch {
              // 不处理解析错误
            }
          }
        },
        onChatroomMessageAttachmentProgress: (
          messageUuid,
          transferred,
          total
        ) => {
          this._eventEmitter.emit(
            EventType.ChatroomMessageAttachmentProgress,
            messageUuid,
            transferred,
            total
          )
        },
        onRtcScreenShareVideoResize: (data) => {
          this._eventEmitter.emit(EventType.RtcScreenShareVideoResize, data)
        },
        onRoomPropertiesChanged: (properties) => {
          const watermark = properties.watermark as { value: string }

          if (watermark && watermark.value) {
            try {
              this._eventEmitter.emit(
                EventType.RoomWatermarkChanged,
                JSON.parse(watermark.value)
              )
            } catch (error) {
              console.error('onRoomPropertiesChanged', error)
            }
          } else {
            this._eventEmitter.emit(EventType.RoomPropertiesChanged, properties)
          }
        },
        onRoomLockStateChanged: (isLocked: boolean) => {
          this._eventEmitter.emit(EventType.RoomLockStateChanged, isLocked)
        },
        onMemberAudioConnectStateChanged: (member, state) => {
          this._eventEmitter.emit(
            EventType.MemberAudioConnectStateChanged,
            member.uuid,
            state
          )
        },
        onMemberPropertiesChanged: (member, properties) => {
          const uuid = typeof member === 'string' ? member : member.uuid

          this._eventEmitter.emit(
            EventType.MemberPropertiesChanged,
            uuid,
            properties
          )
        },
        onMemberPropertiesDeleted: (userUuid: string, properties) => {
          const keys = Object.keys(properties)

          this._eventEmitter.emit(
            EventType.MemberPropertiesDeleted,
            userUuid,
            keys
          )
        },
        onRoomPropertiesDeleted: (properties) => {
          const keys = Object.keys(properties)

          this._eventEmitter.emit(EventType.RoomPropertiesDeleted, keys)
        },
        onRoomEnded: (reason) => {
          this._addPreviewListener()

          console.log('onRoomEnded>>', reason)
          // 屏幕共享的时候被结束需要先恢复窗口
          window.ipcRenderer?.send(IPCEvent.sharingScreen, {
            method: 'stop',
            data: {
              immediately: true,
            },
          })
          this._reset()
          this._meetingStatus = 'login'
          const roomEndReport = new IntervalEvent({
            eventId: StaticReportType.MeetingKit_meeting_end,
            priority: EventPriority.HIGH,
          })
          const _reason = this._transformReason(reason)
          const roomDuration = this._meetingStartTime
            ? Date.now() - this._meetingStartTime
            : 0

          roomEndReport.addParams({
            reason: _reason,
            meetingNum: this._meetingInfo.meetingNum,
            roomArchiveId: this._meetingInfo.roomArchiveId,
            meetingId: this._meetingInfo.meetingId,
            roomDuration,
          })
          roomEndReport.endWithSuccess()
          this._xkitReport?.reportEvent(roomEndReport)
          if (reason === 'kICK_BY_SELF') {
            this._clientBanned()
          } else {
            this._eventEmitter.emit(EventType.RoomEnded, reason)
          }
        },
        onRtcActiveSpeakerChanged: () => {
          // this._eventEmitter.emit(EventType.RtcActiveSpeakerChanged, speaker)
        },
        onRtcChannelDisconnect: (_, channel) => {
          if (channel) {
            this._eventEmitter.emit(EventType.RtcChannelDisconnect, channel)
          }
        },
        onRtcChannelError: async (code) => {
          if (
            code === 'SOCKET_ERROR' ||
            code === 'MEDIA_TRANSPORT_DISCONNECT' ||
            code === 'RELOGIN_ERROR'
          ) {
            if (this._isAnonymous) {
              this._meetingStatus = 'unlogin'
              // this.authService && this.authService.logout()
            } else {
              this._meetingStatus = 'login'
            }

            try {
              this.roomContext?.removeRoomListener()
              this.roomContext?.removeRtcStatsListener()
            } catch (e) {
              console.log('removeListener err', e)
            }

            /*
            try {
              await this.roomContext?.destroy()
            } catch (e) {
              console.log('roomContext destroy err', e)
            }
            */

            this._eventEmitter.emit(EventType.RoomEnded, 'RTC_CHANNEL_ERROR')
          } else if (code == 30121) {
            // c++ 偶现加入rtc token报错
            this._eventEmitter.emit(EventType.RoomEnded, 'UNKNOWN')
          }
        },
        onRoomConnectStateChanged: (data) => {
          console.log(EventType.RoomConnectStateChanged, data)
          this._connectionStateChange(data)
        },
        onCameraDeviceChanged: (data) => {
          // this.emit('onCameraDeviceChanged', data);
          this._deviceChange(data)
        },
        onPlayoutDeviceChanged: (data) => {
          // this.emit('onSpeakerDeviceChanged', data);
          this._deviceChange(data)
        },
        onRecordDeviceChanged: (data) => {
          // this.emit('onRecordDeviceChanged', data);
          this._deviceChange(data)
        },
        onAutoPlayNotAllowed: (data) => {
          this._eventEmitter.emit(EventType.AutoPlayNotAllowed, data)
        },
        onRtcLocalAudioVolumeIndication: (data) => {
          this.handleLocalAudioVolumeIndication(data, true)
        },
        onRtcRemoteAudioVolumeIndication: (data, channelName) => {
          if (data?.length === 0) return
          getWindow('shareVideoWindow')?.postMessage({
            event: 'audioVolumeIndication',
            payload: data[0],
          })
          if (!window.ipcRenderer && this.rtcController) {
            const rtc = this.rtcController._rtc
            const localVolume = rtc?.localStream?.getAudioLevel()

            data = data
              .map((item) => {
                // web 端范围在0-10000之间有效值
                item.volume = item.volume / 100
                return item
              })
              .filter((item) => {
                return item.volume > 1
              })
            if (localVolume > 0) {
              const localData = {
                userUuid: this.localMember?.uuid as string,
                volume: localVolume / 10,
              }

              this._eventEmitter.emit(
                EventType.RtcLocalAudioVolumeIndication,
                localData
              )

              data.unshift(localData)
            }
          }

          // 去除重复人员（同时开启音频辅流和音频）
          const arr = [...new Set(data.map((member) => member.userUuid))].map(
            (uuid) => {
              return data.find((item) => item.userUuid === uuid)
            }
          )

          this.handleAudioVolumeIndication(channelName)

          this._eventEmitter.emit(
            EventType.RtcAudioVolumeIndication,
            [...arr],
            channelName
          )
          if (window.isElectronNative) {
            const inviteWindow = getWindow('memberWindow')

            inviteWindow?.postMessage({
              event: 'eventEmitter',
              payload: {
                key: EventType.RtcAudioVolumeIndication,
                args: [[...arr], channelName],
              },
            })
          }
          // if (arr.length >= 1 && window.isElectronNative) {
          // arr.sort((a, b) => Number(b?.volume) - Number(a?.volume))
          // this._eventEmitter.emit(EventType.RtcActiveSpeakerChanged, arr[0])
          // }
        },
        onRoomLiveStateChanged: (state) => {
          this._eventEmitter.emit(EventType.RoomLiveStateChanged, state)
        },
        onRoomRemainingSecondsRenewed: (data) => {
          this._eventEmitter.emit(EventType.roomRemainingSecondsRenewed, data)
        },
        onLocalAudioVolumeIndication: (data) => {
          this.handleLocalAudioVolumeIndication(data, false)
        },
        onRtcScreenCaptureStatus: (data) => {
          this._eventEmitter.emit(EventType.RtcScreenCaptureStatus, data)
        },
        onRoomCloudRecordStateChanged: (recordState, operatorMember) => {
          this._eventEmitter.emit(
            EventType.roomCloudRecordStateChanged,
            recordState,
            operatorMember
          )
        },
        onRtcVirtualBackgroundSourceEnabled: (enabled, reason) => {
          const settingWindow = getWindow('settingWindow')

          settingWindow?.postMessage(
            {
              event: EventType.rtcVirtualBackgroundSourceEnabled,
              payload: {
                enabled,
                reason,
              },
            },
            settingWindow.origin
          )
        },
        onRoomLiveBackgroundInfoChanged: (sequence) => {
          console.log('onRoomLiveBackgroundInfoChanged>>>>', sequence)
          this._eventEmitter.emit(
            EventType.RoomLiveBackgroundInfoChanged,
            sequence
          )
        },
        onRtcScreenCaptureSourceDataUpdate: (captureRect) => {
          const isNoOpen = !getWindow('annotationWindow')

          setTimeout(
            () => {
              window.ipcRenderer?.send(IPCEvent.annotationWindow, {
                event: 'setBounds',
                payload: captureRect,
              })
            },
            isNoOpen ? 1000 : 0
          )
        },
        onRoomBlacklistStateChanged: (enabled) => {
          this._eventEmitter.emit(EventType.RoomBlacklistStateChanged, enabled)
        },
        onRoomAnnotationEnableChanged: (enabled) => {
          this._eventEmitter.emit(
            EventType.RoomAnnotationEnableChanged,
            enabled
          )
        },
        onMemberSIPInviteStateChanged: (member, operateBy) => {
          if (window.isElectronNative) {
            const inviteWindow = getWindow('inviteWindow')

            inviteWindow?.postMessage({
              event: 'eventEmitter',
              payload: {
                key: EventType.MemberSipInviteStateChanged,
                args: [member, operateBy],
              },
            })
          }

          this._eventEmitter.emit(
            EventType.MemberSipInviteStateChanged,
            member,
            operateBy
          )
        },
        onMemberAppInviteStateChanged: (member, operateBy) => {
          this._eventEmitter.emit(
            EventType.MemberAppInviteStateChanged,
            member,
            operateBy
          )
        },
        onRoomMaxMembersChanged: (maxMembers) => {
          this._eventEmitter.emit(EventType.RoomMaxMembersChanged, maxMembers)
        },
        onAccessDenied: (type) => {
          const accessDenied = new IntervalEvent({
            eventId: StaticReportType.MeetingKit_access_denied,
            priority: EventPriority.HIGH,
          })

          accessDenied.addParams({
            type,
            meetingNum: this._meetingInfo.meetingNum,
            roomArchiveId: this._meetingInfo.roomArchiveId,
            meetingId: this._meetingInfo.meetingId,
          })
          accessDenied.endWithSuccess()
          this._xkitReport?.reportEvent(accessDenied)
          this.outEventEmitter.emit(EventType.OnAccessDenied, type)
        },
        onStartPlayMedia: (data) => {
          this._eventEmitter.emit(EventType.OnStartPlayMedia, data)
        },
        onReceiveCaptionMessages: (messages, channel) => {
          this._eventEmitter.emit(
            EventType.ReceiveCaptionMessages,
            messages,
            channel
          )
        },
        onCaptionStateChanged: (state, code, message) => {
          this._eventEmitter.emit(
            EventType.CaptionStateChanged,
            state,
            code,
            message
          )
        },
      })
  }

  private async _joinHandler(options: NEMeetingJoinOptions) {
    const meetingId =
      this._meetingType === 2
        ? this._privateMeetingNum
        : options.meetingNum || options.meetingId

    const joinStep = options.joinMeetingReport?.beginStep(
      StaticReportType.Meeting_info
    )
    const data: ApiResult<CreateMeetingResponse> = await this._request.get(
      `/scene/meeting/${this.appKey}/v2/info/${meetingId}`
    )
    const res: CreateMeetingResponse = data.data

    console.log('get res', res)
    options.joinMeetingReport?.addParams({
      meetingNum: res.meetingNum,
      meetingId: res.meetingId,
      roomArchiveId: res.roomArchiveId,
    })
    joinStep?.endWith({
      code: data.code,
      msg: data.msg,
      requestId: data.requestId,
      serverCost: data.cost ? Number.parseInt(data.cost) : null,
    })
    this._meetingInfo = res
    // result = await this._siganling.join(options)
    logger.debug('options..', options)
    // 跨应用互通逻辑
    const { meetingAppKey, meetingUserUuid, meetingUserToken } = res
    let crossAppAuthorization: NECrossAppAuthorization | undefined

    if (meetingUserToken && meetingUserUuid && meetingAppKey) {
      crossAppAuthorization = {
        appKey: meetingAppKey,
        user: meetingUserUuid,
        token: meetingUserToken,
      }
    }

    const initialProperties = {}

    if (options.memberTag) {
      initialProperties['tag'] = { value: options.memberTag }
    }

    return this._joinRoomkit({
      role: options.role as string,
      roomUuid: res.roomUuid,
      nickname: options.nickName,
      password: options.password,
      crossAppAuthorization,
      initialProperties: initialProperties,
      createRoomReport: options.joinMeetingReport,
      videoProfile: options.videoProfile,
      encryptionConfig: options.encryptionConfig,
      reporter: options.joinMeetingReport,
      avatar: options.avatar,
      type: options.type === 'joinByInvite' ? 'joinByInvite' : 'join',
      joinTimeout: options.joinTimeout,
    })
    // this._meetingStatus = 'joined'
  }
  private _deviceChange(data) {
    debounce(() => {
      this._eventEmitter.emit(EventType.DeviceChange, data)
    }, 1200)
  }
  private _connectionStateChange(_data: 0 | 1) {
    if (_data === 0 && this._meetingStatus === 'joined') {
      this._logger.debug('正在重连中 %t')
      debounce(this._eventEmitter.emit(EventType.NetworkReconnect))
    } else if (_data === 1 && this._meetingStatus === 'joined') {
      this._logger.debug('重连成功 %t')
      this._logger.debug('join() %t')
      debounce(this._eventEmitter.emit(EventType.NetworkReconnectSuccess))
      // this._siganling.join({})
    }
  }

  private async _handleMemberAction(type: memberAction, userUuid?: string) {
    userUuid =
      userUuid || (this.roomContext as NERoomContext)?.localMember?.uuid
    const rtcController = (this.roomContext as NERoomContext)?.rtcController
    const whiteboardController = (this.roomContext as NERoomContext)
      ?.whiteboardController

    switch (type) {
      case memberAction.muteAudio:
        return rtcController?.muteMyAudio()
      case memberAction.unmuteAudio:
        return rtcController?.unmuteMyAudio().catch((e) => {
          if (e.code === 50000) {
            this.eventEmitter.emit(MeetingEventType.noMicPermission)
            rtcController.muteMyAudio()
          }

          if (e.code === 10212 && !window.isElectronNative) {
            this.rtcController?.muteMyAudio().catch((e) => {
              console.log('10212 muteMyVideo error', e)
            })
          }

          throw e
        })
      case memberAction.takeBackTheHost:
        return this.roomContext?.changeMembersRole({
          [this.localMember?.uuid || '']: Role.host,
          [userUuid]: Role.member,
        })
      case memberAction.muteVideo:
        return rtcController?.muteMyVideo()
      case memberAction.unmuteVideo:
        return rtcController?.unmuteMyVideo().catch((e) => {
          if (e.code === 50000) {
            this.eventEmitter.emit(MeetingEventType.noCameraPermission)
            rtcController.muteMyVideo()
          }

          if (e.code === 10212 && !window.isElectronNative) {
            this.rtcController?.muteMyVideo().catch((e) => {
              console.log('10212 muteMyVideo error', e)
            })
          }

          throw e
        })
      case memberAction.unmuteScreen:
        return rtcController?.startScreenShare()
      case memberAction.muteScreen:
        return rtcController?.stopScreenShare()
      case memberAction.openWhiteShare:
        return whiteboardController?.startWhiteboardShare()
      case memberAction.closeWhiteShare:
        return whiteboardController?.stopWhiteboardShare()
      case memberAction.shareWhiteShare: // 授权白板权限
        return (this.roomContext as NERoomContext).updateMemberProperty(
          userUuid,
          'wbDrawable',
          JSON.stringify({
            value: '1',
          })
        )
      case memberAction.cancelShareWhiteShare:
        return (this.roomContext as NERoomContext).updateMemberProperty(
          userUuid,
          'wbDrawable',
          JSON.stringify({
            value: '0',
          })
        )
      case memberAction.modifyMeetingNickName:
        return
      case memberAction.handsUp:
        return (this.roomContext as NERoomContext).updateMemberProperty(
          userUuid,
          'handsUp',
          JSON.stringify({
            value: '1',
          })
        )
      case memberAction.handsDown:
        return (this.roomContext as NERoomContext).deleteMemberProperty(
          userUuid,
          'handsUp'
        )
      case memberAction.privateChat:
        this._eventEmitter.emit(
          EventType.OnPrivateChatMemberIdSelected,
          userUuid
        )
        return
    }
  }

  private async _handleHostAction(
    type: hostAction,
    userUuid: string,
    extraData?
  ) {
    const roomContext = this.roomContext as NERoomContext
    const watermarkStr =
      roomContext.roomProperties.watermark?.value ||
      JSON.stringify({
        videoStrategy: WATERMARK_STRATEGY.CLOSE,
        videoStyle: WATERMARK_STYLE.SINGLE,
        videoFormat: '{name}',
      })
    const watermarkProperties = JSON.parse(watermarkStr)

    switch (type) {
      case hostAction.remove:
        return roomContext.kickMemberOut(userUuid, extraData)
      case hostAction.muteMemberVideo:
        return (this.rtcController as NERoomRtcController).muteMemberVideo(
          userUuid
        )
      case hostAction.muteMemberAudio:
        return (this.rtcController as NERoomRtcController).muteMemberAudio(
          userUuid
        )
      case hostAction.muteAllAudio:
        return roomContext.updateRoomProperty(
          'audioOff',
          AttendeeOffType.offAllowSelfOn + `_${new Date().getTime()}`
        )
      case hostAction.lockMeeting:
        return roomContext.lockRoom()
      case hostAction.muteAllVideo:
        return roomContext.updateRoomProperty(
          'videoOff',
          AttendeeOffType.offAllowSelfOn + `_${new Date().getTime()}`
        )
      case hostAction.unmuteMemberVideo:
        return (this
          .messageService as NEMessageChannelService).sendCustomMessage(
          this.meetingNum,
          userUuid,
          99,
          JSON.stringify({
            type: 2,
            category: 'meeting_control',
          })
        )
      case hostAction.unmuteMemberAudio:
        return (this
          .messageService as NEMessageChannelService).sendCustomMessage(
          this.meetingNum,
          userUuid,
          99,
          JSON.stringify({
            type: 1,
            category: 'meeting_control',
          })
        )
      case hostAction.unmuteAllAudio: // 解除全体静音
        return roomContext.updateRoomProperty(
          'audioOff',
          AttendeeOffType.disable + `_${new Date().getTime()}`
        )
      case hostAction.unlockMeeting:
        return roomContext.unlockRoom()
      case hostAction.unmuteAllVideo:
        return roomContext.updateRoomProperty(
          'videoOff',
          AttendeeOffType.disable + `_${new Date().getTime()}`
        )
      case hostAction.muteVideoAndAudio:
        ;(this.rtcController as NERoomRtcController).muteMemberVideo(userUuid)
        ;(this.rtcController as NERoomRtcController).muteMemberAudio(userUuid)
        return
      case hostAction.unmuteVideoAndAudio:
        return (this
          .messageService as NEMessageChannelService).sendCustomMessage(
          this.meetingNum,
          userUuid,
          99,
          JSON.stringify({
            type: 3,
            category: 'meeting_control',
          })
        )
      case hostAction.transferHost:
        return roomContext.handOverMyRole(userUuid, extraData)
      case hostAction.setCoHost: // 设置联席主持人
        return roomContext.changeMemberRole(userUuid, Role.coHost)
      case hostAction.unSetCoHost: // 取消设置联席主持人
        return roomContext.changeMemberRole(userUuid, Role.member)
      case hostAction.setFocus:
        return roomContext.updateRoomProperty('focus', userUuid, userUuid)
      case hostAction.unsetFocus:
        return roomContext.updateRoomProperty('focus', '')
      case hostAction.forceMuteAllAudio:
        return roomContext.updateRoomProperty(
          'audioOff',
          AttendeeOffType.offNotAllowSelfOn + `_${new Date().getTime()}`
        )
      case hostAction.rejectHandsUp:
        return roomContext.updateMemberProperty(
          userUuid,
          'handsUp',
          JSON.stringify({
            value: '2',
          })
        )
      case hostAction.forceMuteAllVideo:
        return roomContext.updateRoomProperty(
          'videoOff',
          AttendeeOffType.offNotAllowSelfOn + `_${new Date().getTime()}`
        )
      case hostAction.closeScreenShare:
        return (this
          .rtcController as NERoomRtcController).stopMemberScreenShare(userUuid)
      case hostAction.closeAudioShare:
        return (this
          .rtcController as NERoomRtcController).stopMemberSystemAudioShare(
          userUuid
        )
      case hostAction.openWhiteShare:
        return (this
          .whiteboardController as NERoomWhiteboardController).startWhiteboardShare()
      case hostAction.closeWhiteShare:
        return (this
          .whiteboardController as NERoomWhiteboardController).stopMemberWhiteboardShare(
          userUuid
        )
      case hostAction.openWatermark:
        return roomContext.updateRoomProperty(
          'watermark',
          JSON.stringify({
            videoStrategy: WATERMARK_STRATEGY.OPEN,
            videoStyle:
              watermarkProperties.videoStyle || WATERMARK_STYLE.SINGLE,
            videoFormat: watermarkProperties.videoFormat || '{name}',
          })
        )
      case hostAction.closeWatermark:
        return roomContext.updateRoomProperty(
          'watermark',
          JSON.stringify({
            videoStrategy: WATERMARK_STRATEGY.CLOSE,
            videoStyle: watermarkProperties.videoStyle,
            videoFormat: watermarkProperties.videoFormat,
          })
        )
      case hostAction.changeChatPermission:
        return roomContext.updateRoomProperty('crPerm', extraData.toString())
      case hostAction.changeWaitingRoomChatPermission:
        return roomContext.updateRoomProperty('wtPrChat', extraData.toString())
      case hostAction.changeGuestJoin:
        return roomContext.updateRoomProperty('guest', extraData.toString())
      case hostAction.annotationPermission:
        return roomContext.updateRoomProperty(
          'annotationPermission',
          extraData.toString()
        )
    }
  }
  private _transformReason(reason: NERoomEndReason): string {
    const reasonMap = {
      UNKNOWN: 'unknown', // 未知异常
      LOGIN_STATE_ERROR: 'loginStateError', // 账号异常
      CLOSE_BY_BACKEND: 'closeByBackend', // 后台关闭
      ALL_MEMBERS_OUT: 'allMemberOut', // 所有成员退出
      END_OF_LIFE: 'endOfLife', // 房间到期
      CLOSE_BY_MEMBER: 'closeByMember', // 房间被关闭
      KICK_OUT: 'kickOut', // 被管理员踢出
      SYNC_DATA_ERROR: 'syncDataError', // 数据同步错误
      LEAVE_BY_SELF: 'leaveBySelf', // 成员主动离开房间
      kICK_BY_SELF: 'kickBySelf',
      DISCONNECTED_FROM_RTC: 'RTC_CHANNEL_ERROR',
    }

    return reasonMap[reason] || 'unknown'
  }
  private async _joinRoomkit(options: {
    role: string
    roomUuid: string
    nickname: string
    password?: string
    crossAppAuthorization?: NECrossAppAuthorization
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    initialProperties?: any
    createRoomReport?: IntervalEvent
    videoProfile?: {
      resolution: VideoResolution
      frameRate: VideoFrameRate
    }
    encryptionConfig?: NEEncryptionConfig
    reporter?: IntervalEvent
    avatar?: string
    type: 'create' | 'join' | 'joinByInvite'
    joinTimeout?: number
  }) {
    const joinRoomStep = options.createRoomReport?.beginStep(
      StaticReportType.Join_room
    )

    console.log('start join roomkit')
    this._joinRoomkitOptions = options
    if (!this.authService?.isLoggedIn) {
      console.log('not login first')
      await this.authService?.login(this._userUuid, this._token).catch((e) => {
        console.log('login failed', e)
      })
    }

    const roomService = this.roomService as NERoomService

    console.log('get roomservice')
    const joinFunc =
      options.type === 'joinByInvite'
        ? roomService.joinRoomByInvite.bind(roomService)
        : roomService.joinRoom.bind(roomService)

    return joinFunc(
      {
        role: options.role,
        roomUuid: options.roomUuid,
        userName: options.nickname,
        password: options.password,
        avatar: options.avatar,
        crossAppAuthorization: options.crossAppAuthorization,
        initialProperties: options.initialProperties,
      },
      {}
    )
      .then(async (res) => {
        joinRoomStep?.endWith({
          code: res.code,
          msg: res.message || 'success',
        })
        console.log(
          'joinRoom success,getRoomContext roomUuid: ',
          options.roomUuid,
          roomService
        )
        this.roomContext = roomService.getRoomContext(options.roomUuid)
        console.log('getRoomContext')
        if (!this.roomContext) {
          return
        }

        if (
          this._waitingRoomChangedName &&
          this.localMember?.name != this._waitingRoomChangedName
        ) {
          this.modifyNickName({ nickName: this._waitingRoomChangedName }).catch(
            (e) => {
              console.log('入会修改昵称失败', e)
            }
          )
          console.warn('入会修改昵称', this._waitingRoomChangedName)
          this._waitingRoomChangedName = ''
        }

        this.nosService = this._roomkit.nosService
        console.log('start addRoomListener')
        this._addRoomListener()
        this._addRtcListener()
        this.waitingRoomController = this.roomContext.waitingRoomController
        this._addWaitRoomListener()
        this._removePreviewListener()

        this.chatController = this.roomContext.chatController
        if (this.roomContext.isInWaitingRoom()) {
          return
        }

        return this._joinController(options)
      })
      .catch((e) => {
        joinRoomStep?.endWith({
          code: e.code || -1,
          msg: e.message || e.msg || 'Failure',
        })
        throw e
      })
  }
  private async _joinController(options: Partial<JoinControllerParams>) {
    if (!this.roomContext) {
      return
    }

    console.log('start get controller')
    this.rtcController = this.roomContext.rtcController
    RendererManager.instance.rtcController = this.rtcController
    this.whiteboardController = this.roomContext.whiteboardController
    this.annotationController = this.roomContext.annotationController
    this._addAnnotationView()
    this.liveController = this.roomContext.liveController
    this.sipController = this.roomContext.SIPController
    this.inviteController = this.roomContext.appInviteController

    this.liveTranscriptionController = new NEMeetingLiveTranscriptionController(
      {
        neMeeting: this,
        isAllowParticipantsEnableCaption: this.getIsAllowParticipantsEnableCaption(),
        isCaptionsEnabled: false,
        logger: this._logger,
        roomUuid: options.roomUuid,
      }
    )
    if (this.whiteboardController?.isSupported) {
      await this.whiteboardController?.initWhiteboard().catch((e) => {
        console.error('initWhiteboard failed: ' + e)
      })
    }

    if (!this.roomContext?.localMember.role.hide && !this._noChat) {
      this.chatController?.joinChatroom(0).catch((e) => {
        console.error('joinChatroom failed: ', e)
      })
    }

    this._meetingStartTime = new Date().getTime()

    if (options.videoProfile) {
      const { resolution, frameRate } = options.videoProfile

      await this.setVideoProfile(resolution, frameRate)
    }

    if (options.encryptionConfig) {
      console.log('开启流媒体加密', options.encryptionConfig)
      const { encryptionType, encryptKey } = options.encryptionConfig

      this.rtcController?.enableEncryption(encryptKey, encryptionType)
    }

    if (this.rtcController) {
      const joinRtcStep = options.reporter?.beginStep(StaticReportType.Join_rtc)

      // 开始加入rtc回调
      this._eventEmitter.emit(EventType.meetingStatusChanged, {
        status: NEMeetingStatus.MEETING_STATUS_CONNECTING,
        arg: NEMeetingCode.MEETING_JOIN_CHANNEL_START,
      })
      this._joinTimeoutTimer && clearTimeout(this._joinTimeoutTimer)
      this._joinTimeoutTimer = setTimeout(() => {
        this.roomContext?.leaveRoom()
        this._eventEmitter.emit(EventType.RoomEnded, EndRoomReason.JOIN_TIMEOUT)
        this._joinTimeoutTimer = null
        Promise.reject('join timeout')
      }, options?.joinTimeout || 45000)
      await this.rtcController
        .joinRtcChannel()
        .then(() => {
          console.log('join rtc success')
          this._joinTimeoutTimer && clearTimeout(this._joinTimeoutTimer)
          this._joinTimeoutTimer = null
        })
        .catch((e) => {
          // 加入rtc失败回调
          this._eventEmitter.emit(EventType.meetingStatusChanged, {
            status: NEMeetingStatus.MEETING_STATUS_FAILED,
            arg: NEMeetingCode.MEETING_DISCONNECTING_JOIN_CHANNEL_ERROR,
          })
          if (options.type === 'create') {
            joinRtcStep?.endWith({
              serverCost: e.cost ? Number.parseInt(e.cost) : null,
              code: e.code || -1,
              msg: e.msg || e.message || 'failure',
              requestId: e.requestId,
            })
          } else {
            joinRtcStep?.endWith({
              code: e.code || -1,
              msg: e.message || 'Failure',
            })
          }

          logger.error('joinRtcChannel failed: ' + e)
          this.roomContext?.leaveRoom()
          throw e
        })

      // 加入rtc成功回调
      this._eventEmitter.emit(EventType.meetingStatusChanged, {
        status: NEMeetingStatus.MEETING_STATUS_CONNECTING,
        arg: NEMeetingCode.MEETING_JOIN_CHANNEL_SUCCESS,
      })

      this._meetingStatus = 'joined'
      try {
        await this.rtcController.setLocalAudioProfile(
          'music_standard' as AudioProfile
        )
      } catch (error) {
        console.log('setLocalAudioProfile err', error)
      }

      this.alreadyJoin = true
      console.log('join end')
    }
  }
  private _syncSettings(accountInfo: InnerAccountInfo) {
    if (!accountInfo.settings) {
      return
    }

    const serverSetting = accountInfo.settings
    const setting = getLocalStorageSetting()
    const captionSetting =
      setting.captionSetting || createDefaultCaptionSetting()

    captionSetting.targetLanguage = serverLanguageToSettingASRTranslationLanguage(
      serverSetting.asrTranslationLanguage
    )

    captionSetting.showCaptionBilingual = serverSetting.captionBilingual
    captionSetting.showTranslationBilingual =
      serverSetting.transcriptionBilingual

    setting.captionSetting = captionSetting
    setLocalStorageSetting(JSON.stringify(setting))
  }
  private _formatAudioOff(
    attendeeAudioOffType: AttendeeOffType | undefined,
    attendeeAudioOff: boolean
  ) {
    let audioOff: string = AttendeeOffType.disable

    if (attendeeAudioOffType) {
      if (attendeeAudioOffType === AttendeeOffType.offAllowSelfOn) {
        audioOff = AttendeeOffType.offAllowSelfOn
      } else if (attendeeAudioOffType === AttendeeOffType.offNotAllowSelfOn) {
        audioOff = AttendeeOffType.offNotAllowSelfOn
      } else {
        audioOff = AttendeeOffType.disable
      }
    } else {
      audioOff = attendeeAudioOff
        ? AttendeeOffType.offNotAllowSelfOn
        : AttendeeOffType.disable
    }

    return audioOff + `_${new Date().getTime()}`
  }
  // 用户被踢
  private _clientBanned() {
    if (this._isAnonymous) {
      this._meetingStatus = 'unlogin'
      // this.authService && this.authService.logout()
    } else {
      this._meetingStatus = 'login'
    }

    this._eventEmitter.emit(EventType.ClientBanned)
  }

  private handleAudioVolumeIndication(channelName) {
    if (!channelName || channelName === MAJOR_AUDIO) {
      return
    }

    const interpretationSetting = this._interpretationSetting
    const setting = getLocalStorageSetting()
    const settingVolume =
      setting?.audioSetting.playouOutputtVolume ||
      setting?.audioSetting.playouOutputtVolume === 0
        ? setting.audioSetting.playouOutputtVolume
        : 100
    let majorVolume =
      interpretationSetting?.majorVolume ||
      interpretationSetting?.majorVolume === 0
        ? interpretationSetting.majorVolume
        : MAJOR_DEFAULT_VOLUME

    // 如果已经调整过音量需要重置回原来的音量
    if (this._audioVolumeIndicationIntervalTimer) {
      clearInterval(this._audioVolumeIndicationIntervalTimer)
      this._audioVolumeIndicationIntervalTimer = null
      this.rtcController?.adjustChannelPlaybackSignalVolume('', majorVolume)
    }

    if (this._audioVolumeIndicationTimer) {
      clearTimeout(this._audioVolumeIndicationTimer)
      this._audioVolumeIndicationTimer = null
    }

    if (!interpretationSetting || !this.interpretation?.started) {
      return
    }

    if (
      interpretationSetting.listenLanguage !== MAJOR_AUDIO &&
      interpretationSetting.isListenMajor &&
      !interpretationSetting.muted
    ) {
      // 超过6s子频道没有声音则主频道自动放大
      this._audioVolumeIndicationTimer = setTimeout(() => {
        this._audioVolumeIndicationTimer = null
        const durationVolume = settingVolume - majorVolume

        console.log('开始调整原声频道音量', durationVolume)

        if (durationVolume > 0) {
          const perVolume = Math.round(durationVolume / 10)

          this._audioVolumeIndicationIntervalTimer = setInterval(() => {
            if (majorVolume < settingVolume && majorVolume <= 100) {
              majorVolume += perVolume
              majorVolume = Math.min(majorVolume, 100)
              this.rtcController?.adjustChannelPlaybackSignalVolume(
                '',
                majorVolume
              )
            } else {
              this._audioVolumeIndicationIntervalTimer &&
                clearInterval(this._audioVolumeIndicationIntervalTimer)
            }
          }, 200)
        }
      }, 6000)
    }
  }
  private handleLocalAudioVolumeIndication(data, isChannel: boolean) {
    if (this.localMember?.isAudioOn) {
      getWindow('shareVideoWindow')?.postMessage({
        event: 'audioVolumeIndication',
        payload: {
          userUuid: this.localMember?.uuid,
          volume: data,
        },
      })
    }

    this._eventEmitter.emit(
      EventType.RtcLocalAudioVolumeIndication,
      data,
      isChannel
    )
  }
  private createRequest(): AxiosInstance {
    const language = this._language
    const instance = axios.create({
      baseURL: this._meetingServerDomain,
    })

    instance.interceptors.request.use(
      (config) => {
        config.headers = {
          ...config.headers,
          clientType: 'web',
          user: this._userUuid,
          token: this._token,
          authType: this._authType,
          versionCode: pkg.version,
          meetingVer: pkg.version,
          appVer: pkg.version,
          deviceId: this._roomkit.deviceId || window.NERoom.getDeviceId?.(),
          framework: this._framework,
          appKey: this._meetingInfo.meetingAppKey || this.appKey,
          'Accept-Language': this._language,
        }
        return config
      },
      function (error) {
        return Promise.reject(error)
      }
    )

    instance.interceptors.response.use(
      function (response) {
        if (response.data.code !== 0) {
          response.data.message = response.data.msg
          return Promise.reject(response.data)
        }

        return response.data
      },
      function (error) {
        // 网络错误需要转成对应语言
        if (error.code === 'ERR_NETWORK') {
          console.log('language', language)
          const networkErrorMsg = {
            'zh-CN': '网络错误',
            'en-US': 'Network Error',
            'ja-JP': 'ネットワークエラー',
          }

          error.message = networkErrorMsg[language] || networkErrorMsg['zh-CN']
        }

        return Promise.reject(error)
      }
    )

    return instance
  }
}
