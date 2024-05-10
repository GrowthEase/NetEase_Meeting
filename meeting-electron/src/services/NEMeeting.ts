import { EventPriority, XKitReporter } from '@xkit-yx/utils'
import axios, { AxiosInstance } from 'axios'
import EventEmitter from 'eventemitter3'
import WebRoomkit, {
  AudioProfile,
  DeviceType,
  NEAuthService,
  NECrossAppAuthorization,
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
  NERoomRtcController,
  NERoomService,
  NERoomVideoConfig,
  NERoomWhiteboardController,
  Roomkit,
  VideoFrameRate,
  VideoResolution,
} from 'neroom-web-sdk'
import { NEWaitingRoomMember } from 'neroom-web-sdk/dist/types/types/interface'
import {
  NECustomSessionMessage,
  NEMessageSearchOrder,
} from 'neroom-web-sdk/dist/types/types/messageChannelService'
import { NEWaitingRoomController } from 'neroom-web-sdk/dist/types/types/waitingRoomController'
import { NERoomAppInviteController } from 'neroom-web-sdk/packages/types/roomInviteController'
import { NERoomSIPController } from 'neroom-web-sdk/packages/types/roomSipController'
import { Md5 } from 'ts-md5/dist/md5'
import { IPCEvent } from '../../app/src/types'
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
  LoginResponse,
  MeetingAccountInfo,
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
  GetAccountInfoListResponse,
  MeetingEventType,
  RecordState,
  tagNERoomRtcAudioProfileType,
  tagNERoomRtcAudioScenarioType,
  WaitingRoomContextInterface,
  WATERMARK_STRATEGY,
  WATERMARK_STYLE,
} from '../types/innerType'
import {
  MeetingList,
  NEEncryptionConfig,
  NEMeetingCode,
  NEMeetingInviteStatus,
  NEMeetingSDK,
  NEMeetingStatus,
  NERoomRecord,
  SipMember,
} from '../types/type'
import {
  debounce,
  getDefaultDeviceId,
  getDefaultLanguage,
  setDefaultDevice,
} from '../utils'
import DataReporter from '../utils/DataReporter'
import { Logger } from '../utils/Logger'
import { IntervalEvent } from '../utils/report'
import { getWindow } from '../utils/windowsProxy'

const logger = new Logger('Meeting-NeMeeting', true)
const reporter = DataReporter.getInstance()

const IM_VERSION = '9.14.4'
const RTC_VERSION = '5.5.30'
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

export default class NEMeetingService {
  roomContext: NERoomContext | null = null
  rtcController: NERoomRtcController | null = null
  chatController: NERoomChatController | null = null
  waitingRoomController: NEWaitingRoomController | null = null
  whiteboardController: NERoomWhiteboardController | null = null
  liveController: NERoomLiveController | null = null
  previewController: NEPreviewController | null = null
  sipController: NERoomSIPController | null = null
  inviteController: NERoomAppInviteController | null = null
  roomService: NERoomService | null = null
  nosService: NENosService | null = null
  isUnMutedAudio = false // 入会是否开启音频
  isUnMutedVideo = false // 入会是否开启视频
  alreadyJoin = false
  _meetingInfo: CreateMeetingResponse | Record<string, any> = {} // 会议接口返回的会议信息，未包含sdk中的信息
  subscribeMembersMap: Record<string, 0 | 1> = {}
  private _screenSharingSourceId = ''
  private _isAnonymous = false
  private _isLoginedByAccount = false // 是否已通过账号登录
  private _meetingStatus = 'unlogin'
  private authService: NEAuthService | null = null
  private messageService: NEMessageChannelService | null = null
  private _roomkit: Roomkit
  private _eventEmitter: EventEmitter
  private _outEventEmitter: EventEmitter
  private _userUuid = ''
  private _appKey = ''
  private _token = ''
  private _authType
  private _meetingServerDomain = 'https://meeting.yunxinroom.com'
  private _privateMeetingNum = '' // 个人id
  private _request: AxiosInstance
  private _meetingType = 0 // 1.随机会议，2.个人会议，3.预约会议
  private _isReuseIM = false // 是否复用im
  private _language = getDefaultLanguage()
  private _logger: Logger
  private _accountInfo: MeetingAccountInfo | null = null
  private _noChat = false
  private _xkitReport: XKitReporter
  private _meetingStartTime = 0
  private _leaveRoomTimer: any = null
  private _joinRoomkitOptions: any = {}
  private _waitingRoomChangedName = '' // 等候室改名同时被准入，需要入会之后修改昵称
  private _framework = window.ipcRenderer
    ? 'Electron-native'
    : // @ts-ignore
    process.env.PLATFORM === 'h5' || window.isH5
    ? 'H5'
    : ''

  constructor(params: {
    roomkit: Roomkit
    eventEmitter: EventEmitter
    outEventEmitter: EventEmitter
    logger?: Logger
  }) {
    this._xkitReport = XKitReporter.getInstance({
      imVersion: IM_VERSION,
      nertcVersion: RTC_VERSION,
      deviceId: WebRoomkit.getDeviceId(),
    })
    this._roomkit = params.roomkit
    this._eventEmitter = params.eventEmitter
    this._outEventEmitter = params.outEventEmitter
    this._request = this.createRequest()
    this._logger = logger
  }

  get eventEmitter(): EventEmitter {
    return this._eventEmitter
  }

  get localMember(): NERoomMember | null {
    return this.roomContext ? this.roomContext.localMember : null
  }

  get meetingId(): number {
    return this._meetingInfo.meetingId
  }
  get meetingNum(): string {
    return this._meetingInfo.meetingNum
  }
  get shortMeetingNum(): number {
    return this._meetingInfo.shortMeetingNum
  }
  get roomDeviceId() {
    return WebRoomkit.getDeviceId()
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

  switchLanguage(language?: 'zh-CN' | 'en-US' | 'ja-JP') {
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

  uploadLog() {
    // @ts-ignore
    return this._roomkit?.uploadLog()
  }

  public removeGlobalEventListener() {
    ;(this._roomkit as any).removeGlobalEventListener()
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
        nim: (this._roomkit as any)._im.nim,
        imAccid: this.authService
          ? (this.authService as any).roomAccountId
          : '',
        imAppKey: this.authService ? (this.authService as any).roomAppKey : '',
        imToken: this.authService
          ? (this.authService as any).roomAccountToken
          : '',
        nickName: this.localMember?.name || '',
        chatRoomId: this.roomContext
          ? this.roomContext.roomProperties?.chatRoom?.chatRoomId
          : '',
      }
    }
    return null
  }

  async init(params: NEMeetingInitConfig): Promise<void> {
    // this._siganling.setInitConf(val);
    this._appKey = params.appKey
    IntervalEvent.appKey = this._appKey as string
    params.meetingServerDomain &&
      (this._meetingServerDomain = params.meetingServerDomain)
    this._isReuseIM = !!params.im
    params.globalEventListener &&
      (this._roomkit as any).addGlobalEventListener(params.globalEventListener)
    const options: any = {
      appKey: this._appKey,
      im: params.im,
      useInternalVideoRender: false,
      debug: params.debug,
      eventTracking: params.eventTracking,
      extras: {
        noReport: params.extras?.noReport,
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
    // axios.defaults.baseURL = this._meetigServerDomain;
    this._request = this.createRequest()
    this.authService = this._roomkit.authService
    this.roomService = this._roomkit.roomService
    this.previewController = (
      this.roomService as NERoomService
    ).getPreviewRoomContext()?.previewController
    this.messageService = this._roomkit.messageChannelService
    this.nosService = this._roomkit.nosService
    this.messageService.addMessageChannelListener({
      onReceiveCustomMessage: (res) => {
        if (res.commandId === 99) {
          const body = res.data.body
          if (Object.prototype.toString.call(body) == '[object String]') {
            res.data.body = JSON.parse(body)
          }
          this._eventEmitter.emit(EventType.ReceivePassThroughMessage, res)
        } else if (res.commandId === 98) {
          if (window.isElectronNative) {
            try {
              res.data = JSON.parse(res.data)
            } catch (error) {
              console.log('parse meeting update error', error)
            }
          }
          this._eventEmitter.emit(EventType.ReceiveScheduledMeetingUpdate, res)
        } else if (res.commandId >= 200 && res.commandId < 400) {
          this._eventEmitter.emit(EventType.RoomsCustomEvent, res)
          if (res.commandId === 211) {
            try {
              const data =
                typeof res.data === 'string' ? JSON.parse(res.data) : res.data
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
            this._eventEmitter.emit(EventType.OnMeetingInviteStatusChange, res)
          } catch (e) {}
        }
      },
    })
    this.messageService.addReceiveSessionMessageListener({
      onReceiveSessionMessage: (data) => {
        this._eventEmitter.emit(EventType.OnReceiveSessionMessage, data)

        const notificationListWindow = getWindow('notificationListWindow')
        notificationListWindow?.postMessage(
          {
            event: 'eventEmitter',
            payload: {
              key: EventType.OnReceiveSessionMessage,
              args: [data],
            },
          },
          notificationListWindow.origin
        )
      },
      onChangeRecentSession: (data) => {
        this._eventEmitter.emit(EventType.OnChangeRecentSession, data)
      },
      onDeleteSessionMessage: (data) => {
        this._eventEmitter.emit(EventType.OnDeleteSessionMessage, data)
      },
      onDeleteAllSessionMessage: (sessionId, sessionType) => {
        this._eventEmitter.emit(
          EventType.OnDeleteAllSessionMessage,
          sessionId,
          sessionType
        )
      },
    })
  }
  public async getGlobalConfig(): Promise<GetMeetingConfigResponse> {
    return this._request
      .get(`/scene/meeting/${this._appKey}/v1/config`)
      .then((res) => {
        logger.debug('getGlobalConfig', res)
        const data = res.data as unknown as GetMeetingConfigResponse
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
          activeSpeakerConfig.enableVideoPreSubscribe =
            !!enableVideoPreSubscribe
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
        res.data.appConfig.MEETING_CLIENT_CONFIG.activeSpeakerConfig =
          activeSpeakerConfig
        localStorage.setItem(
          'nemeeting-global-config',
          JSON.stringify(res.data)
        )
        return res.data as unknown as GetMeetingConfigResponse
      })
  }
  async login(
    options: NEMeetingLoginByPasswordOptions | NEMeetingLoginByTokenOptions
  ): Promise<void> {
    try {
      // await this._siganling.login(options)
      if (options.loginType === 1) {
        const { accountId, accountToken, authType } =
          options as NEMeetingLoginByTokenOptions
        const step1 = options.loginReport?.beginStep(
          StaticReportType.Account_info
        )
        options.loginReport?.setData({ userId: options.accountId })
        this._userUuid = accountId
        this._token = accountToken
        this._authType = authType
        if (!options.isTemporary) {
          const data: any = await this._request
            .get(`/scene/meeting/${this._appKey}/v1/account/info`)
            .catch((e) => {
              step1.endWith({
                code: e.code || -1,
                msg: e.msg || e.message || 'failure',
              })
              throw e
            })
          const res: MeetingAccountInfo = data.data
          step1.endWith({
            serverCost: data.cost ? Number.parseInt(data.cost) : null,
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
          const res = await this.authService
            .login(accountId, accountToken, options.authType)
            .catch((e) => {
              step2.endWith({
                code: e.code || -1,
                msg: e.msg || e.message || 'failure',
              })
              throw e
            })
          step2.endWith({
            code: res.code || 0,
            msg: res.message || 'success',
          })
        }
      } else {
        const step1 = options.loginReport?.beginStep(
          StaticReportType.Account_info
        )
        const { username, password } =
          options as NEMeetingLoginByPasswordOptions
        const data: any = await this._request
          .post(`/scene/meeting/${this._appKey}/v1/login/${username}`, {
            password: Md5.hashStr(password + '@yiyong.im'),
          })
          .catch((e) => {
            step1.endWith({
              code: e.code || -1,
              msg: e.msg || e.message || 'failure',
            })
            throw e
          })
        step1.endWith({
          serverCost: data.cost ? Number.parseInt(data.cost) : null,
          code: data.code,
          msg: data.msg,
          requestId: data.requestId,
        })
        const res: LoginResponse = data.data
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
              step2.endWith({
                code: e.code || -1,
                msg: e.msg || e.message || 'failure',
              })
              throw e
            })
          step2.endWith({
            code: data.code,
            msg: data.message,
          })
        }
      }
      this._isLoginedByAccount = true
      return
    } catch (e) {
      this._isLoginedByAccount = false
      return Promise.reject(e)
    }
  }

  async getAccountInfo(): Promise<MeetingAccountInfo> {
    const res = await this._request.get(
      `/scene/meeting/${this._appKey}/v1/account/info`
    )
    return res.data
  }

  async getAppInfo(): Promise<{ appName: string }> {
    return await this._request
      .get(`/scene/meeting/${this._appKey}/v1/app/info`)
      .then((res) => {
        return res.data
      })
  }

  async getAppTips(): Promise<any> {
    return await this._request
      .get(`/scene/meeting/${this._appKey}/v1/tips?time=${Date.now()}`)
      .then((res) => {
        return res.data
      })
  }

  async getAppConfig(): Promise<any> {
    return await this._request
      .get(`/scene/meeting/${this._appKey}/v1/config`)
      .then((res) => {
        return res.data
      })
  }

  async updateUserNickname(nickname: string): Promise<void> {
    return this._request.post(
      `/scene/meeting/${this._appKey}/v1/account/nickname`,
      { nickname }
    )
  }

  async getMeetingList(
    options: NEMeetingGetListOptions
  ): Promise<CreateMeetingResponse[]> {
    const { startTime, endTime } = options
    const data: any = await this._request.get<
      any,
      { meetingList: CreateMeetingResponse[] }
    >(`/scene/meeting/${this._appKey}/v1/list/${startTime}/${endTime}`, {
      params: { states: '1,2,3' },
    })
    const res = data.data
    return res.meetingList.filter((item) => item.type === 3)
  }

  async getScheduledMembers(
    meetingNum: string
  ): Promise<{ userUuid: string; role: string }[]> {
    return this._request
      .get(
        `/scene/meeting/${this._appKey}/v1/info/${meetingNum}/scheduled-members`
      )
      .then((res) => {
        return res.data
      })
  }

  async getAccountInfoList(
    userUuids: string[]
  ): Promise<GetAccountInfoListResponse> {
    const data: any = await this._request.post(
      `/scene/meeting/${this._appKey}/v1/account-list`,
      userUuids
    )
    return data.data
  }

  async getMeetingInfoByMeetingId(meetingId: string) {
    const res = await this._request.get(
      `/scene/meeting/${this._appKey}/v1/info/meeting/${meetingId}`
    )
    return res.data
  }
  async getMeetingInfoByFetch(
    meetingId: string
  ): Promise<CreateMeetingResponse> {
    const res: any = await this._request.get(
      `/scene/meeting/${this._appKey}/v1/info/${meetingId}`
    )
    this._meetingInfo = res.data
    return res.data
  }

  async getHostAndCohostList(roomUuid: string): Promise<NEMember[]> {
    const res: any = await this._request.get(
      `/scene/apps/${this._appKey}/v1/rooms/${roomUuid}/host-cohost-list`
    )
    return res.data.map((item) => ({
      name: item.userName,
      role: item.role,
      avatar: item.userIcon,
      uuid: item.userUuid,
    }))
  }

  async getWaitingRoomConfig(roomUuid: string): Promise<{ wtPrChat: number }> {
    const res: any = await this._request.get(
      `/scene/apps/${this._appKey}/v1/rooms/${roomUuid}/waiting-room-config`
    )
    return {
      wtPrChat: Number(res.data.wtPrChat?.value || 1),
    }
  }

  setScreenSharingSourceId(sourceId: string) {
    this._screenSharingSourceId = sourceId
  }

  async saveViewOrderInMeeting(data: string): Promise<void> {
    return await this._request.post(
      `/scene/meeting/${this._appKey}/v1/edit/${this.meetingId}/unSync`,
      {
        viewOrder: data,
      }
    )
  }

  async scheduleMeeting(options: NEMeetingCreateOptions): Promise<void> {
    const audioOff = this._formatAudioOff(
      options.attendeeAudioOffType,
      !!options.attendeeAudioOff
    )
    const {
      meetingId,
      meetingNum,
      startTime,
      endTime,
      openLive,
      liveOnlyEmployees,
      password,
      subject,
      roleBinds,
      noSip,
      recurringRule,
      scheduledMembers,
      enableGuestJoin,
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
          record: options.noCloudRecord === false ? true : false,
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
    }

    if (openLive) {
      const extensionConfig = {
        liveChatRoomEnable: true,
        onlyEmployeesAllow: liveOnlyEmployees,
      }
      data.roomProperties['live'] = {
        extensionConfig: JSON.stringify(extensionConfig),
      }
    } else {
    }
    if (meetingId) {
      if (recurringRule) {
        await this._request.patch(
          `/scene/meeting/${this._appKey}/v1/recurring-meeting/${meetingId}`,
          data
        )
      } else {
        await this._request.post(
          `/scene/meeting/${this._appKey}/v1/edit/${meetingId}`,
          data
        )
      }
    } else {
      await this._request.put(
        `/scene/meeting/${this._appKey}/v1/create/3`,
        data
      )
    }
  }

  async cancelMeeting(
    meetingId: string,
    cancelRecurringMeeting?: boolean
  ): Promise<void> {
    return await this._request
      .delete(
        `/scene/meeting/${
          this._appKey
        }/v1/cancel/${meetingId}?cancelRecurringMeeting=${!!cancelRecurringMeeting}`
      )
      .then((res) => {
        return res.data
      })
  }

  async create(options: NEMeetingCreateOptions): Promise<void> {
    try {
      const {
        meetingId,
        meetingNum,
        password,
        subject,
        roleBinds,
        noSip,
        noChat,
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
      const data: any = await this._request
        .put(`/scene/meeting/${this._appKey}/v1/create/${this._meetingType}`, {
          password,
          subject,
          roleBinds,
          roomConfigId: 40,
          openWaitingRoom: !!options.enableWaitingRoom,
          roomConfig: {
            resource: {
              rtc: true,
              chatroom: !options.noChat,
              whiteboard: true,
              record: options.noCloudRecord === false ? true : false,
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
          },
        })
        .catch((e) => {
          createRoomStep?.endWith({
            serverCost: e.cost ? Number.parseInt(e.cost) : null,
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
        serverCost: data.cost ? Number.parseInt(data.cost) : null,
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
      }).then(() => {
        this._meetingStartTime = new Date().getTime()
      })
    } catch (e: any) {
      if (e.code === 3100) {
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

  async clearUnreadCount(sessionId: string) {
    return await this.messageService?.clearUnreadCount(sessionId, 0)
  }

  async deleteAllSessionMessage(sessionId: string) {
    return await this.messageService?.deleteAllSessionMessage(sessionId, 0)
  }

  getMeetingPluginList(): Promise<any> {
    return this._request.get(`/plugin_sdk/v1/list`).then((res) => {
      return res.data
    })
  }

  getMeetingPluginAuthCode(params: { pluginId: string }): Promise<any> {
    return this._request
      .post(`/plugin_sdk/v1/auth_code`, params)
      .then((res) => {
        return res.data
      })
  }

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

  startLive(options: NERoomLiveRequest) {
    return this.liveController?.startLive(options)
  }

  stopLive() {
    return this.liveController?.stopLive()
  }

  updateLive(options: NERoomLiveRequest) {
    return this.liveController?.updateLive(options)
  }
  getLiveInfo(): NERoomLiveInfo | null {
    if (!this.liveController) {
      return null
    }
    return this.liveController.getLiveInfo()
  }
  getSipMemberList(): Promise<{ list: SipMember[] }> {
    return this._request
      .get(`/scene/meeting/${this._appKey}/v1/sip/${this.meetingNum}/list`)
      .then((res) => {
        return res.data
      })
  }

  // 获取本端视频信息
  getLocalVideoStats() {
    return this.rtcController?.getLocalVideoStats()
  }

  // 获取远端视频信息
  getRemoteVideoStats() {
    return this.rtcController?.getRemoteVideoStats()
  }
  async anonymousJoin(options: NEMeetingJoinOptions): Promise<any> {
    if (this._isReuseIM) {
      console.warn('im复用不支持匿名入会')
      return {
        code: MeetingErrorCode.ReuseIMError,
        message: 'reuseIM not support anonymous join',
      }
    }
    if (this._isLoginedByAccount) {
      console.warn('已通过账号登录，建议直接入会。或者登出后再匿名入会')
      return {
        code: -102,
        message: '已通过账号登录，建议直接入会。或者登出后再匿名入会',
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
      const data: any = await this._request
        .post(`/scene/apps/${this._appKey}/v1/anonymous/login`)
        .catch((e) => {
          anonymousJoinStep?.endWith({
            code: e.code || -1,
            msg: e.msg || 'Failure',
            requestId: e.requestId,
            serverCost: e.cost ? Number.parseInt(e.cost) : null,
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
      } catch (e: any) {
        anonymousJoinStep.endWith({
          code: e.code || -1,
          msg: e.msg || 'Failure',
          requestId: e.requestId,
          serverCost: e.cost ? Number.parseInt(e.cost) : null,
        })
        console.log('authService.login', e)
      }
      anonymousJoinStep.endWith({
        code: data.code,
        msg: data.msg || 'success',
        requestId: data.requestId,
        serverCost: data.cost ? Number.parseInt(data.cost) : null,
      })
      return this._joinHandler(options)
    } catch (e) {
      console.log('anonymousJoin', e)
      throw e
    }
  }

  async logout(): Promise<void> {
    try {
      this.authService?.logout()
      this._isLoginedByAccount = false
      this._isAnonymous = false
      this._meetingStatus = 'unlogin'
    } catch (e) {
      console.log('logout', e)
      throw e
    }
  }

  async leave(role?: string): Promise<void> {
    try {
      logger.debug('leave() %t')
      try {
        this.roomContext && (await this.roomContext.leaveRoom())
      } catch (e) {
        console.warn('leaveRoom error', e)
      }
      if (role === 'AnonymousParticipant' || this._isAnonymous) {
        this._meetingStatus = 'unlogin'
      } else {
        this._meetingStatus = 'login'
      }
      this._reset()
      logger.debug('leave() successed %t')
    } catch (e) {
      return Promise.reject(e)
    }
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
      DataReporter.destroy()
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

  async rejoinAfterAdmittedToRoom() {
    // this._moveToWaitingRoomReset()
    if (!this.roomContext) {
      return
    }
    return this.roomContext
      .rejoinAfterAdmittedToRoom()
      .then(async () => {
        try {
          // 需要更新主题信息
          await this.getMeetingInfoByFetch(this._meetingInfo.meetingNum)
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
  updateWaitingRoomUnReadCount(count) {
    this._eventEmitter.emit(
      MeetingEventType.updateWaitingRoomUnReadCount,
      count
    )
  }
  updateMeetingInfo(meetingInfo: Record<string, any>) {
    this._eventEmitter.emit(MeetingEventType.updateMeetingInfo, meetingInfo)
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
    const screenUuid = (
      this.rtcController as NERoomRtcController
    )?.getScreenSharingUserUuid()

    let whiteboardUuid =
      roomProperties.wbSharingUuid && roomProperties.wbSharingUuid.value
    if (!whiteboardUuid) {
      try {
        whiteboardUuid =
          this.roomContext.whiteboardController.getWhiteboardSharingUserUuid()
      } catch {}
    }

    const meetingChatPermission = roomProperties.crPerm?.value
      ? Number(roomProperties.crPerm?.value)
      : 1

    const waitingRoomChatPermission = roomProperties.wtPrChat?.value
      ? Number(roomProperties.wtPrChat?.value)
      : 1

    const remoteViewOrder = roomProperties.viewOrder?.value

    const focusUuid = roomProperties.focus ? roomProperties.focus.value : ''
    localMember.isInChatroom = true
    const members = [localMember, ...remoteMembers]
    const memberList: NEMember[] = []
    const inSipInvitingMemberList: NEMember[] = []
    ;[...inSipInvitingMembers, ...inAppInvitingMembers].forEach((member) => {
      //@ts-ignore
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
      if (member.role?.name === NEMeetingRole.host) {
        hostUuid = member.uuid
        hostName = member.name
      }
      const handsUpStatus: any = member.properties?.handsUp
      // 主持人|联席主持人直接隐藏举手
      const isHandsUp =
        member.role?.name === NEMeetingRole.host ||
        member.role?.name === NEMeetingRole.coHost
          ? false
          : handsUpStatus && handsUpStatus.value
          ? handsUpStatus.value == 1
          : false
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
      //@ts-ignore
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
      meetingInviteUrl,
      roomArchiveId,
      ownerUserUuid,
      recurringRule,
    } = this._meetingInfo
    let isScheduledMeeting = 0
    if (recurringRule) {
      isScheduledMeeting = 2
    } else if (type === 3) {
      isScheduledMeeting = 1
    }

    let watermark: any = {}
    try {
      watermark =
        Object.prototype.toString.call(roomProperties.watermark?.value) ===
        '[object Object]'
          ? roomProperties.watermark?.value
          : JSON.parse(roomProperties.watermark?.value || {})
    } catch (error) {
      console.log('watermark error', error)
    }
    return {
      memberList,
      inInvitingMemberList: inSipInvitingMemberList,
      meetingInfo: {
        localMember: {
          ...localMember,
          role: localMember.role?.name as Role,
          isHandsUp: localHandsUp,
          inviteState:
            localMember.inviteState as unknown as NEMeetingInviteStatus,
        },
        meetingInviteUrl,
        myUuid: localMember.uuid,
        focusUuid,
        hostUuid,
        hostName,
        isSupportChatroom: !!this.chatController?.isSupported,
        screenUuid,
        whiteboardUuid,
        meetingChatPermission,
        waitingRoomChatPermission,
        remoteViewOrder,
        isScheduledMeeting: isScheduledMeeting,
        scheduledMeetingViewOrder: settings.roomInfo.viewOrder,
        isWaitingRoomEnabled:
          this.waitingRoomController?.isWaitingRoomEnabledOnEntry(),
        properties: roomProperties,
        password: this.roomContext.password,
        subject,
        startTime,
        roomArchiveId,
        endTime,
        type,
        shortMeetingNum: shortMeetingNum,
        ownerUserUuid,
        sipCid: this.roomContext.sipCid,
        rtcStartTime: this.roomContext.rtcStartTime,
        isScreenSharingMeeting:
          roomProperties.rooms_screen_share_mode?.value === '1',
        activeSpeakerUuid: '',
        meetingId: meetingId,
        meetingNum: meetingNum,
        inWaitingRoom: this.roomContext.isInWaitingRoom(),
        maxMembers: this.roomContext.maxMembers,
        remainingSeconds: this.roomContext.remainingSeconds,
        // @ts-ignore
        isCloudRecording: this.roomContext.isCloudRecording,
        // @ts-ignore
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
      },
    }
  }
  // 发送成员会控操作
  sendMemberControl(type: memberAction, uuid?: string) {
    return this._handleMemberAction(type, uuid)
  }
  putInWaitingRoom(uuid: string) {
    return this.waitingRoomController?.putInWaitingRoom(uuid)
  }
  admitMember(uuid: string, autoAdmit?: boolean) {
    return this.waitingRoomController?.admitMember(uuid, autoAdmit)
  }
  admitAllMembers() {
    return this.waitingRoomController?.admitAllMembers()
  }
  expelMember(uuid: string, notAllowJoin?: boolean) {
    return this.waitingRoomController?.expelMember(uuid, notAllowJoin)
  }
  expelAllMembers(disallowRejoin: boolean) {
    return this.waitingRoomController?.expelAllMembers(disallowRejoin)
  }
  waitingRoomChangeMemberName(uuid: string, name: string) {
    return this.waitingRoomController?.changeMemberName(uuid, name)
  }
  waitingRoomGetMemberList(time: number, limit: number, asc: boolean) {
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
  enableRoomBlackList(enable: boolean) {
    return this.roomContext?.enableRoomBlacklist(enable)
  }
  sendHostControl(type: hostAction, uuid: string, extraData?: any) {
    return this._handleHostAction(type, uuid, extraData)
  }
  async getScreenCaptureSourceList(): Promise<any> {
    // @ts-ignore
    return this.rtcController?.getScreenCaptureSourceList()
  }
  async muteLocalAudio(need = true) {
    // 如果本地音频没有连接则不执行
    if (!this.localMember?.isAudioConnected) {
      return
    }
    logger.debug('muteLocalAudio %t')
    reporter.send({
      action_name: 'switch_audio',
      value: 0,
    })
    if (need) {
      return this.sendMemberControl(memberAction.muteAudio)
    }
    if (this.rtcController) {
      return this.rtcController.muteMyAudio()
    } else {
      return false
    }
  }
  async reconnectMyAudio() {
    return this.rtcController?.reconnectMyAudio()
  }
  async disconnectMyAudio() {
    return this.rtcController?.disconnectMyAudio()
  }
  async unmuteLocalAudio(deviceId?: string, need = true) {
    // 如果本地音频没有连接则不执行
    if (!this.localMember?.isAudioConnected) {
      return
    }
    logger.debug('unmuteLocalAudio %t')
    reporter.send({
      action_name: 'switch_audio',
      value: 1,
    })
    if (need) {
      return this.sendMemberControl(memberAction.unmuteAudio)
    }
    if (this.rtcController) {
      if (deviceId) {
        return this.rtcController.switchDevice({
          type: 'microphone',
          deviceId: getDefaultDeviceId(deviceId),
        })
      } else {
        return this.rtcController.unmuteMyAudio().catch((e) => {
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
  switchDevice(options: { type: DeviceType; deviceId: string }) {
    options.deviceId = getDefaultDeviceId(options.deviceId)
    return this.rtcController?.switchDevice(options)
  }
  async muteLocalVideo(need = true) {
    logger.debug('muteLocalVideo %t')
    reporter.send({
      action_name: 'switch_camera',
      value: 0,
    })
    if (need) {
      return this.sendMemberControl(memberAction.muteVideo)
    }
    return this.rtcController?.muteMyVideo()
  }
  async unmuteLocalVideo(deviceId?: string, need = true) {
    if (need) {
      return this.sendMemberControl(memberAction.unmuteVideo)
    }
    return this.rtcController?.unmuteMyVideo().catch((e) => {
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

  async startCloudRecord() {
    //@ts-ignore
    return this.roomContext.startCloudRecord()
  }

  async stopCloudRecord() {
    //@ts-ignore
    return this.roomContext.stopCloudRecord()
  }
  /**
   *
   * @param enable 开启或关闭
   * @param videoOrder 视频排序
   */
  async syncViewOrder(enable: boolean, videoOrder: string) {
    if (enable) {
      return this.roomContext?.updateRoomProperty('viewOrder', videoOrder)
    } else {
      return this.roomContext?.deleteRoomProperty('viewOrder')
    }
  }

  async getRoomCloudRecordList(
    roomArchiveId: string
  ): Promise<NEResult<NERoomRecord[]>> {
    //@ts-ignore
    return this.roomService.getRoomCloudRecordList(roomArchiveId)
  }

  async muteLocalScreenShare() {
    logger.debug('muteLocalScreenShare')
    reporter.send({
      action_name: 'screen_share',
      value: 0,
    })
    return this.rtcController?.stopScreenShare()
  }

  async unmuteLocalScreenShare(params?: {
    sourceId?: string
    isApp?: boolean
  }) {
    logger.debug('unmuteLocalScreenShare %t %o', params)
    reporter.send({
      action_name: 'screen_share',
      value: 1,
    })
    let options = params
    if (!window.isElectronNative) {
      options = { ...params, sourceId: this._screenSharingSourceId }
    }
    return this.rtcController?.startScreenShare(options)
  }

  async changeLocalAudio(deviceId: string) {
    return this.rtcController?.switchDevice({
      type: 'microphone',
      deviceId: getDefaultDeviceId(deviceId),
    })
  }

  async changeLocalVideo(deviceId: string, need = true) {
    return this.rtcController?.switchDevice({
      type: 'camera',
      deviceId: getDefaultDeviceId(deviceId),
    })
  }
  // 邀请加入
  async acceptInvite(options: NEMeetingJoinOptions): Promise<any> {
    try {
      logger.debug('acceptInvite')
      const joinOptions = {
        ...options,
        role: options.role || Role.member,
        type: 'joinByInvite',
      }
      // 如果是自己创建会议时候提示会议已经存在且是个人会议则使用个人会议号
      return this._joinHandler(joinOptions)
    } catch (e: any) {
      logger.debug('acceptInvite() failed: %o', e)
      return Promise.reject(e)
    }
  }
  async join(options: NEMeetingJoinOptions): Promise<any> {
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
      return this._joinHandler(options)
    } catch (e: any) {
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

  async getMicrophones() {
    if (this.rtcController) {
      const res = await this.rtcController.enumRecordDevices()
      // const devices = await this._webrtc.getMicrophones()
      logger.debug('getMicrophones success, %o %t', res.data)
      const data = setDefaultDevice(res.data)
      return data
    } else {
      logger.warn('getMicrophones no previewController %t')
      return []
    }
  }
  async getCameras() {
    logger.debug('getCameras')
    if (this.rtcController) {
      const res = await this.rtcController.enumCameraDevices()
      // const devices = await this._webrtc.getCameras()
      logger.debug('getCameras success, %o %t', res.data)
      const data = setDefaultDevice(res.data)
      return data
    } else {
      logger.warn('getCameras no _webrtc %t')
    }
  }
  async getSpeakers() {
    logger.debug('getSpeakers %t')
    if (this.rtcController) {
      const res = await this.rtcController.enumPlayoutDevices()
      logger.debug('getSpeakers success, %o %t', res.data)
      const data = setDefaultDevice(res.data)
      return data
    } else {
      logger.warn('getSpeakers no _webrtc %t')
    }
  }
  //选择要使用的扬声器
  async selectSpeakers(speakerId: string) {
    logger.debug('selectSpeakers %s %t', speakerId)
    return this.rtcController?.switchDevice({
      type: 'speaker',
      deviceId: getDefaultDeviceId(speakerId),
    })
  }
  async setVideoProfile(resolution: number, frameRate?: number) {
    logger.debug('setVideoProfile success %o %o %t', resolution, frameRate)
    const options: any = {
      resolution,
    }
    // 没有帧率配置
    if (frameRate) {
      options.frameRate = frameRate
    }
    return this.rtcController?.setLocalVideoConfig(options as NERoomVideoConfig)
  }
  async setAudioProfile(profile: AudioProfile) {
    return this.rtcController?.setLocalAudioProfile(profile)
  }
  async setAudioProfileInEle(
    profile: tagNERoomRtcAudioProfileType,
    scenario: tagNERoomRtcAudioScenarioType
  ) {
    // @ts-ignore
    return this.rtcController?.setAudioProfileInEle(profile, scenario)
  }
  // 是否开启AI降噪
  async enableAudioAINS(enable: boolean) {
    // @ts-ignore
    return this.rtcController?.enableAudioAINS(enable)
  }
  // 是否开启回音消除
  async enableAudioEchoCancellation(enable: boolean) {
    // @ts-ignore
    return this.rtcController?.enableAudioEchoCancellation(enable)
  }
  // 是否开启自动调节麦克风音量
  async enableAudioVolumeAutoAdjust(enable: boolean) {
    // @ts-ignore
    return this.rtcController?.enableAudioVolumeAutoAdjust(enable)
  }
  // 修改会中昵称
  async modifyNickName(options: { nickName: string; userUuid?: string }) {
    // 如果有userUuid则修改指定用户的昵称
    if (options.userUuid) {
      return this.roomContext?.changeMemberName(
        options.userUuid,
        options.nickName
      )
    }
    return this.roomContext?.changeMyName(options.nickName)
  }

  replayRemoteStream(options: { userUuid: string; type: NEMediaTypes }) {
    logger.debug('replayRemoteStream %s %t', options.userUuid, options.type)
    if (this.rtcController) {
      this.rtcController.replayRemoteStream(options)
    }
  }

  async checkSystemRequirements(): Promise<boolean> {
    if (this.previewController) {
      return this.previewController.checkSystemRequirements()
    }
    return Promise.reject('检查异常')
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
    // @ts-ignore
    await this._roomkit.release()
  }

  async destroyRoomContext() {
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
  }): Promise<any> {
    let url = `/scene/meeting/${this._appKey}/v1/info/${params.meetingNum}/guest`
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
  ): Promise<{ meetingList: MeetingList[] }> {
    return this._request
      .get(`/scene/meeting/${this._appKey}/v1/meeting/history/list`, {
        params,
      })
      .then((res) => {
        return res.data
      })
  }
  /**
   * 获取参会记录列表
   */
  getHistoryMeetingDetail(params: {
    roomArchiveId: string
  }): Promise<{ chatroom: { exportAccess: number }; pluginInfoList: any }> {
    return this._request
      .get(`/scene/meeting/${this._appKey}/v1/meeting-history-detail`, {
        params,
      })
      .then((res) => {
        return res.data
      })
  }
  /**
   * 获取历史参会记录
   */
  getHistoryMeeting(params: { meetingId: string }): Promise<MeetingList> {
    return this._request
      .get(
        `/scene/meeting/${this._appKey}/v1/meeting/history/${params.meetingId}`
      )
      .then((res) => {
        return res.data
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
  ): Promise<{ favoriteList: MeetingList[] }> {
    return this._request
      .get(`/scene/meeting/${this._appKey}/v1/meeting/favorite/list`, {
        params,
      })
      .then((res) => {
        return res.data
      })
  }

  /**
   * 收藏会议
   */
  collectMeeting(roomArchiveId: string): Promise<any> {
    return this._request
      .put(
        `/scene/meeting/${this._appKey}/v1/meeting/${roomArchiveId}/favorite`,
        {},
        {
          headers: {
            'Content-Type': 'application/json;charset=utf-8',
          },
        }
      )
      .then((res) => {
        return res.data
      })
  }

  /**
   * 取消收藏会议
   */
  cancelCollectMeeting(roomArchiveId: string): Promise<any> {
    return this._request
      .delete(
        `/scene/meeting/${this._appKey}/v1/meeting/${roomArchiveId}/favorite`
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
      // @ts-ignore
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
      .post(`/scene/meeting/${this._appKey}/v1/account/avatar`, {
        avatar: url,
      })
      .then(() => {
        return url
      })
  }

  isEnableWaitingRoom() {
    return this.waitingRoomController?.getWaitingRoomInfo().isEnabledOnEntry
  }

  async subscribeRemoteVideoStream(uuid: string, streamType: 0 | 1) {
    if (this.subscribeMembersMap[uuid] === streamType) {
      return
    }
    console.log('>>> 开始订阅 <<<<', uuid, streamType)
    return this.rtcController
      ?.subscribeRemoteVideoStream(uuid, streamType)
      .then((res) => {
        this.subscribeMembersMap[uuid] = streamType
        return res
      })
  }
  unsubscribeRemoteVideoStream(uuid: string, streamType: 0 | 1) {
    if (
      this.subscribeMembersMap[uuid] !== 0 &&
      !this.subscribeMembersMap[uuid]
    ) {
      return
    }
    console.log('>>> 取消订阅 <<<<', uuid, streamType)
    return this.rtcController
      ?.unsubscribeRemoteVideoStream(uuid, streamType)
      .then((res) => {
        delete this.subscribeMembersMap[uuid]
        return res
      })
  }

  //根据手机号码进行呼叫
  callByNumber(data: { number: string; countryCode: string; name?: string }) {
    const { number, countryCode, name } = data
    return this.sipController?.callByNumber(number, countryCode, name)
  }

  //根据用户uuid进行呼叫
  callByUserUuids(userUuids: string[]) {
    return this.sipController?.callByUserUuids(userUuids)
  }

  //根据用户id进行呼叫
  callByUserUuid(userUuid: string) {
    return this.sipController?.callByUserUuid(userUuid)
  }

  //移除呼叫
  removeCall(userUuid: string) {
    return this.sipController?.removeCall(userUuid)
  }

  //取消正在进行的呼叫，无论是正在响铃还是等待响铃都可以使用
  cancelCall(userUuid: string) {
    return this.sipController?.cancelCall(userUuid)
  }

  // 挂断通话，挂断后成员将被踢出会议并移除列表
  hangUpCall(userUuid: string) {
    return this.sipController?.hangUpCall(userUuid)
  }

  inviteByUserUuids(userUuids: string[]) {
    return this.inviteController?.callByUserUuids(userUuids)
  }

  inviteByUserUuid(userUuid: string) {
    return this.inviteController?.callByUserUuid(userUuid)
  }

  cancelInvite(userUuid: string) {
    return this.inviteController?.cancelCall(userUuid)
  }

  rejectInvite(roomUuid: string) {
    return this.roomService?.rejectInvite(roomUuid)
  }
  searchAccount(params: {
    name?: string
    phoneNumber?: string
    pageSize?: number
    pageNum?: number
  }): Promise<SearchAccountInfo[]> {
    return this._request
      .get(`/scene/meeting/${this._appKey}/v1/account-search`, {
        params,
      })
      .then((res) => {
        return res.data
      })
  }

  private _moveToWaitingRoomReset() {
    this.rtcController = null
    this.whiteboardController = null
    this.liveController = null
    this._waitingRoomChangedName = ''
  }

  private _reset(): void {
    this.roomContext = null
    this.rtcController = null
    this.whiteboardController = null
    this.chatController = null
    this.liveController = null
    this._meetingType = 0
    this._isLoginedByAccount = false
    this.alreadyJoin = false
    this._waitingRoomChangedName = ''
    this._screenSharingSourceId = ''
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
      onRtcStats: (data: any) => {
        this._eventEmitter.emit(EventType.RtcStats, data)
        getWindow('settingWindow')?.postMessage({
          event: 'onRtcStats',
          payload: data,
        })
        if (window.isElectronNative) {
          const time = Math.floor(Date.now() / 1000)
          const rtt = {
            time,
            value: data.downRtt + data.upRtt,
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
      onLocalAudioStats: (data: any) => {
        if (window.isElectronNative) {
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
      onRemoteAudioStats: (data: any) => {
        if (window.isElectronNative) {
          const arr = Object.values(data).flat() as Array<{ volume: number }>
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
      onLocalVideoStats: (data: any) => {
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
      onRemoteVideoStats: (data: any) => {
        if (window.isElectronNative) {
          const videos = Object.values(data).flat() as Array<{
            layerType: number
            receivedBitRate: number
          }>
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
          this._eventEmitter.emit(EventType.MemberJoinRoom, members)
        },
        onMemberNameChanged: (member, name) => {
          this._eventEmitter.emit(EventType.MemberNameChanged, member, name)
        },
        onMemberJoinRtcChannel: async (members) => {
          if (window.isElectronNative) {
            this._eventEmitter.emit(EventType.MemberJoinRtcChannel, members)
          }
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
          const chatWindow = getWindow('chatWindow')
          chatWindow?.postMessage({
            event: 'eventEmitter',
            payload: {
              key: EventType.ReceiveChatroomMessages,
              args: [messages],
            },
          })
          this._eventEmitter.emit(EventType.ReceiveChatroomMessages, messages)
        },
        onChatroomMessageAttachmentProgress: (
          messageUuid,
          transferred,
          total
        ) => {
          const chatWindow = getWindow('chatWindow')
          chatWindow?.postMessage({
            event: 'eventEmitter',
            payload: {
              key: EventType.ChatroomMessageAttachmentProgress,
              args: [messageUuid, transferred, total],
            },
          })
          this._eventEmitter.emit(
            EventType.ChatroomMessageAttachmentProgress,
            messageUuid,
            transferred,
            total
          )
        },
        onRoomPropertiesChanged: (properties: any) => {
          if (properties.watermark && properties.watermark.value) {
            try {
              this._eventEmitter.emit(
                EventType.RoomWatermarkChanged,
                JSON.parse(properties.watermark.value)
              )
            } catch {}
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
        onMemberPropertiesChanged: (
          member,
          properties: Record<string, any>
        ) => {
          this._eventEmitter.emit(
            EventType.MemberPropertiesChanged,
            member.uuid,
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
          console.log('onRoomEnded>>', reason)
          // 屏幕共享的时候被结束需要先恢复窗口
          window.ipcRenderer?.send('nemeeting-sharing-screen', {
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
        onRtcActiveSpeakerChanged: (speaker: {
          userUuid: string
          volume: number
        }) => {
          // this._eventEmitter.emit(EventType.RtcActiveSpeakerChanged, speaker)
        },
        onRtcChannelError: (code) => {
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
              // @ts-ignore
              this.roomContext?.removeRoomListener()
              // @ts-ignore
              this.roomContext?.removeRtcStatsListener()
            } catch (e) {
              console.log('removeListener err', e)
            }
            this._eventEmitter.emit(EventType.RoomEnded, 'RTC_CHANNEL_ERROR')
          } else if (code == 30121) {
            // c++ 偶现加入rtc token报错
            this._eventEmitter.emit(EventType.RoomEnded, 'UNKNOWN')
          }
        },
        onRoomConnectStateChanged: (data) => {
          console.log(EventType.RoomConnectStateChanged, data)
          // Electron环境，目前c++断网为1 联网为2与其他端相反
          if (window.isElectronNative) {
            if (data === 1) {
              data = 0
            } else if (data === 0) {
              data = 1
            }
          }
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
        onRtcRemoteAudioVolumeIndication: (data) => {
          if (data.length === 0) return
          getWindow('shareVideoWindow')?.postMessage({
            event: 'audioVolumeIndication',
            payload: data[0],
          })
          if (!window.ipcRenderer && this.rtcController) {
            const rtc: any = (this.rtcController as any)._rtc
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
                volume: localVolume,
              }
              data.unshift(localData)
            }
          }
          // 去除重复人员（同时开启音频辅流和音频）
          const arr = [...new Set(data.map((member) => member.userUuid))].map(
            (uuid) => {
              return data.find((item) => item.userUuid === uuid)
            }
          )
          this._eventEmitter.emit(EventType.RtcAudioVolumeIndication, [...arr])
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
        // @ts-ignore
        onLocalAudioVolumeIndication: (data) => {
          if (this.localMember?.isAudioOn) {
            getWindow('shareVideoWindow')?.postMessage({
              event: 'audioVolumeIndication',
              payload: {
                userUuid: this.localMember?.uuid,
                volume: data,
              },
            })
            this._eventEmitter.emit(
              EventType.RtcLocalAudioVolumeIndication,
              data
            )
          }
        },
        onVideoFrameData: (uuid, bSubVideo, data, type, width, height) => {
          this._eventEmitter.emit(
            EventType.onVideoFrameData,
            uuid,
            bSubVideo,
            data,
            type,
            width,
            height
          )
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
          window.ipcRenderer?.send('previewControllerListener', {
            method: EventType.rtcVirtualBackgroundSourceEnabled,
            args: [
              {
                enabled,
                reason,
              },
            ],
          })
        },
        onRoomLiveBackgroundInfoChanged: (sequence) => {
          console.log('onRoomLiveBackgroundInfoChanged>>>>', sequence)
          this._eventEmitter.emit(
            EventType.RoomLiveBackgroundInfoChanged,
            sequence
          )
        },
        onRoomBlacklistStateChanged: (enabled) => {
          console.log('onRoomBlacklistStateChanged', enabled)
          this._eventEmitter.emit(
            EventType.RoomLiveBackgroundInfoChanged,
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
      })
  }

  private async _joinHandler(options: any) {
    const meetingId =
      this._meetingType === 2
        ? this._privateMeetingNum
        : options.meetingNum || options.meetingId

    const joinStep = options.joinMeetingReport?.beginStep(
      StaticReportType.Meeting_info
    )
    const data: any = await this._request.get(
      `/scene/meeting/${this._appKey}/v1/info/${meetingId}`
    )
    const res: CreateMeetingResponse = data.data
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
    })
    // this._meetingStatus = 'joined'
  }
  private _deviceChange(data: any) {
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
        return rtcController.muteMyAudio()
      case memberAction.unmuteAudio:
        return rtcController.unmuteMyAudio().catch((e) => {
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
        const userRoleMap = {
          [this.localMember?.uuid || '']: Role.host,
          [userUuid]: Role.member,
        }
        return this.roomContext?.changeMembersRole(userRoleMap)
      case memberAction.muteVideo:
        return rtcController.muteMyVideo()
      case memberAction.unmuteVideo:
        // this.setCanvas(userUuid, 'video');
        return rtcController.unmuteMyVideo().catch((e) => {
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
        // this.setCanvas(userUuid, 'screen')
        return rtcController.startScreenShare()
      case memberAction.muteScreen:
        return rtcController.stopScreenShare()
      case memberAction.openWhiteShare:
        return whiteboardController.startWhiteboardShare()
      case memberAction.closeWhiteShare:
        return whiteboardController.stopWhiteboardShare()
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
    extraData?: any
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
        return (
          this.messageService as NEMessageChannelService
        ).sendCustomMessage(
          this.meetingNum,
          userUuid,
          99,
          JSON.stringify({
            type: 2,
            category: 'meeting_control',
          })
        )
      case hostAction.unmuteMemberAudio:
        return (
          this.messageService as NEMessageChannelService
        ).sendCustomMessage(
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
        return (
          this.messageService as NEMessageChannelService
        ).sendCustomMessage(
          this.meetingNum,
          userUuid,
          99,
          JSON.stringify({
            type: 3,
            category: 'meeting_control',
          })
        )
      case hostAction.transferHost:
        return roomContext.handOverMyRole(userUuid)
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
        return (
          this.rtcController as NERoomRtcController
        ).stopMemberScreenShare(userUuid)
      case hostAction.openWhiteShare:
        return (
          this.whiteboardController as NERoomWhiteboardController
        ).startWhiteboardShare()
      case hostAction.closeWhiteShare:
        return (
          this.whiteboardController as NERoomWhiteboardController
        ).stopMemberWhiteboardShare(userUuid)
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
  }) {
    const joinRoomStep = options.createRoomReport?.beginStep(
      StaticReportType.Join_room
    )
    this._joinRoomkitOptions = options
    if (!this.authService?.isLoggedIn) {
      await this.authService?.login(this._userUuid, this._token).catch((e) => {
        console.log('login failed', e)
      })
    }
    const roomService = this.roomService as NERoomService
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
        this.roomContext = (this.roomService as NERoomService).getRoomContext(
          options.roomUuid
        )

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
        this._addRoomListener()
        this._addRtcListener()
        this.waitingRoomController = this.roomContext.waitingRoomController
        this._addWaitRoomListener()
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
  private async _joinController(options) {
    if (!this.roomContext) {
      return
    }
    this.rtcController = this.roomContext.rtcController
    this.whiteboardController = this.roomContext.whiteboardController
    this.liveController = this.roomContext.liveController
    this.sipController = this.roomContext.SIPController
    this.inviteController = this.roomContext.appInviteController
    if (this.whiteboardController?.isSupported) {
      this.whiteboardController?.initWhiteboard().catch((e) => {
        console.error('initWhiteboard failed: ' + e)
      })
    }
    if (!this.roomContext?.localMember.role.hide && !this._noChat) {
      this.chatController?.joinChatroom(0).catch((e) => {
        console.error('joinChatroom failed: ' + e)
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
      const joinRtcRes = await this.rtcController
        .joinRtcChannel()
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
      joinRtcStep?.endWith({
        code: joinRtcRes.code,
        msg: joinRtcRes.message,
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
    }
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
          deviceId: (this._roomkit as any).deviceId,
          framework: this._framework,
          appKey: this._appKey,
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
