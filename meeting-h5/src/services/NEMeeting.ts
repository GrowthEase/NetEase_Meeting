import {
  AccountInfo,
  ActionType,
  AnonymousLoginResponse,
  AttendeeOffType,
  CreateMeetingResponse,
  Dispatch,
  EventType,
  hostAction,
  IMInfo,
  LayoutTypeEnum,
  LoginResponse,
  MeetingAccountInfo,
  MeetingErrorCode,
  memberAction,
  NEMeeting,
  NEMeetingCreateOptions,
  NEMeetingGetListOptions,
  NEMeetingInitConfig,
  NEMeetingJoinOptions,
  NEMeetingLoginByPasswordOptions,
  NEMeetingLoginByTokenOptions,
  NEMeetingRole,
  NEMember,
  Role,
  GetMeetingConfigResponse,
  JoinHandlerOptions,
  StaticReportType,
} from '../types'
import WebRoomkit, {
  AudioProfile,
  ConnectStateChange,
  DeviceType,
  NEAuthService,
  NECrossAppAuthorization,
  NEMediaTypes,
  NEMessageChannelService,
  NEPreviewController,
  NERoomChatController,
  NERoomContext,
  NERoomEndReason,
  NERoomLanguage,
  NERoomLiveController,
  NERoomLiveInfo,
  NERoomLiveRequest,
  NERoomRtcController,
  NERoomService,
  NERoomVideoConfig,
  NERoomWhiteboardController,
  Roomkit,
  VideoFrameRate,
  VideoResolution,
} from 'neroom-web-sdk'
import EventEmitter from 'eventemitter3'
import axios, { AxiosInstance } from 'axios'
import { Md5 } from 'ts-md5/dist/md5'
import { debounce, getDefaultLanguage } from '../utils'
import { Logger } from '../utils/Logger'
import DataReporter from '../utils/DataReporter'
import { MeetingList, NEMeetingSDK, SipMember } from '../types/type'
import pkg from '../../package.json'
import { EventPriority, XKitReporter } from '@xkit-yx/utils'
import { IntervalEvent } from '../utils/report'

const logger = new Logger('Meeting-NeMeeting', true)
const reporter = DataReporter.getInstance()

const IM_VERSION = '9.11.0'
const RTC_VERSION = '5.4.0'
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

export default class NEMeetingService {
  roomContext: NERoomContext | null = null
  rtcController: NERoomRtcController | null = null
  chatController: NERoomChatController | null = null
  whiteboardController: NERoomWhiteboardController | null = null
  liveController: NERoomLiveController | null = null
  previewController: NEPreviewController | null = null
  isUnMutedAudio = false // 入会是否开启音频
  isUnMutedVideo = false // 入会是否开启视频
  private _isAnonymous = false
  private _isLoginedByAccount = false // 是否已通过账号登录
  private _meetingStatus = 'unlogin'
  private roomService: NERoomService | null = null
  private authService: NEAuthService | null = null
  private messageService: NEMessageChannelService | null = null
  private _roomkit: Roomkit
  private _eventEmitter: EventEmitter
  private _userUuid = ''
  private _appKey = ''
  private _token = ''
  private _meetingServerDomain = 'https://roomkit.netease.im'
  private _privateMeetingNum = '' // 个人id
  private _request: AxiosInstance
  private _meetingInfo: CreateMeetingResponse | Record<string, any> = {} // 会议接口返回的会议信息，未包含sdk中的信息
  private _meetingType = 0 // 1.随机会议，2.个人会议，3.预约会议
  private _isReuseIM = false // 是否复用im
  private _language = getDefaultLanguage()
  private _logger: Logger
  private _accountInfo: MeetingAccountInfo | null = null
  private _noChat = false
  private _xkitReport: XKitReporter
  private _meetingStartTime = 0

  constructor(params: {
    roomkit: Roomkit
    eventEmitter: EventEmitter
    logger: Logger
  }) {
    this._xkitReport = XKitReporter.getInstance({
      imVersion: IM_VERSION,
      nertcVersion: RTC_VERSION,
      deviceId: WebRoomkit.getDeviceId(),
    })
    this._roomkit = params.roomkit
    this._eventEmitter = params.eventEmitter
    this._request = this.createRequest()
    this._logger = logger
  }

  get eventEmitter(): EventEmitter {
    return this._eventEmitter
  }

  get localMember(): any {
    return this.roomContext ? this.roomContext.localMember : null
  }

  get meetingId(): number {
    return this._meetingInfo.meetingId
  }
  get meetingNum(): string {
    return this._meetingInfo.meetingNum
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
  get microphoneId(): string {
    return this.rtcController
      ? this.rtcController.getSelectedRecordDevice()
      : ''
  }

  get cameraId(): string {
    return this.rtcController
      ? this.rtcController.getSelectedCameraDevice()
      : ''
  }

  get speakerId(): string {
    return this.rtcController
      ? this.rtcController.getSelectedPlayoutDevice()
      : ''
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

  public removeGlobalEventListener() {
    ;(this._roomkit as any).removeGlobalEventListener()
  }

  get imInfo(): IMInfo | null {
    // @ts-ignore
    if (window.NERoomNode) {
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
        nickName: this.localMember.name,
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
      useInternalVideoRender: true,
      debug: params.debug,
      eventTracking: params.eventTracking,
      extras: {
        noReport: params.extras?.noReport,
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
    await this._roomkit.initialize(options)
    // axios.defaults.baseURL = this._meetigServerDomain;
    this._request = this.createRequest()
    this.authService = this._roomkit.authService
    this.roomService = this._roomkit.roomService
    this.previewController = (
      this.roomService as NERoomService
    ).getPreviewRoomContext()?.previewController
    this.messageService = this._roomkit.messageChannelService
    this.messageService.addMessageChannelListener({
      onReceiveCustomMessage: (res) => {
        console.log('onReceiveCustomMessage', res)
        if (res.commandId === 99) {
          const body = res.data.body
          if (Object.prototype.toString.call(body) == '[object String]') {
            res.data.body = JSON.parse(body)
          }
          this._eventEmitter.emit(EventType.ReceivePassThroughMessage, res)
        } else if (res.commandId === 98) {
          this._eventEmitter.emit(EventType.ReceiveScheduledMeetingUpdate)
        }
      },
    })
  }
  public async getGlobalConfig(): Promise<GetMeetingConfigResponse> {
    return this._request
      .get(`/scene/meeting/${this._appKey}/v1/config`)
      .then((res) => {
        logger.debug('getGlobalConfig', res)
        return res.data as unknown as GetMeetingConfigResponse
      })
  }
  async login(
    options: NEMeetingLoginByPasswordOptions | NEMeetingLoginByTokenOptions
  ): Promise<void> {
    try {
      // await this._siganling.login(options)
      if (options.loginType === 1) {
        const { accountId, accountToken } =
          options as NEMeetingLoginByTokenOptions
        const step1 = options.loginReport?.beginStep(
          StaticReportType.Account_info
        )
        options.loginReport?.setData({ userId: options.accountId })
        this._userUuid = accountId
        this._token = accountToken
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
          serverCost: data.cost,
          code: data.code,
          msg: data.msg,
          requestId: data.requestId,
        })
        this._accountInfo = res
        this._privateMeetingNum = res.privateMeetingNum
        const step2 = options.loginReport?.beginStep(
          StaticReportType.Roomkit_login
        )
        if (this.authService) {
          const res = await this.authService
            .login(accountId, accountToken)
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
          serverCost: data.cost,
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
    await this._request.post(
      `/scene/meeting/${this._appKey}/v1/account/nickname`,
      { nickname }
    )
    return
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

  async getMeetingInfoByFetch(
    meetingId: string
  ): Promise<CreateMeetingResponse> {
    const res: any = await this._request.get(
      `/scene/meeting/${this._appKey}/v1/info/${meetingId}`
    )
    return res.data
  }

  async scheduleMeeting(options: NEMeetingCreateOptions): Promise<void> {
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
    } = options
    const data = {
      password,
      subject,
      startTime,
      endTime,
      roleBinds,
      roomConfigId: 40,
      roomConfig: {
        resource: {
          rtc: true,
          live: openLive,
          chatroom: !options.noChat,
          whiteboard: true,
          record: !options.noCloudRecord,
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
        audioOff: options.attendeeAudioOff
          ? {
              value: `${
                AttendeeOffType.offAllowSelfOn
              }__${new Date().getTime()}`,
            }
          : {},
      },
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
      await this._request.post(
        `/scene/meeting/${this._appKey}/v1/edit/${meetingId}`,
        data
      )
    } else {
      await this._request.put(
        `/scene/meeting/${this._appKey}/v1/create/3`,
        data
      )
    }
  }

  async cancelMeeting(meetingId: string): Promise<void> {
    return await this._request
      .delete(`/scene/meeting/${this._appKey}/v1/cancel/${meetingId}`)
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
      const data: any = await this._request
        .put(`/scene/meeting/${this._appKey}/v1/create/${this._meetingType}`, {
          password,
          subject,
          roleBinds,
          roomConfigId: 40,
          roomConfig: {
            resource: {
              rtc: true,
              chatroom: !options.noChat,
              whiteboard: true,
              record: !options.noCloudRecord,
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
              value:
                (options.attendeeAudioOff
                  ? AttendeeOffType.offNotAllowSelfOn
                  : AttendeeOffType.disable) + `_${new Date().getTime()}`,
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
            serverCost: e.cost,
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
        serverCost: data.cost,
        code: data.code,
        msg: data.msg,
        requestId: data.requestId,
      })
      this._meetingInfo = res
      await this._joinRoomkit({
        role: 'host',
        roomUuid: res.roomUuid,
        nickname: options.nickName,
        createRoomReport: options.createMeetingReport,
        initialProperties: {
          tag: { value: options.memberTag },
        },
      })
      this._addRoomListener()
      this._addRtcListener()
      if (options.videoProfile) {
        const { resolution, frameRate } = options.videoProfile
        await this.setVideoProfile(resolution, frameRate)
      }
      if (options.encryptionConfig) {
        console.log('开启流媒体加密', options.encryptionConfig)
        const { encryptionType, encryptKey } = options.encryptionConfig
        this.rtcController?.enableEncryption(encryptKey, encryptionType)
      }

      const joinRtcStep = options.createMeetingReport?.beginStep(
        StaticReportType.Join_rtc
      )
      if (this.rtcController) {
        const joinRtcRes = await this.rtcController
          .joinRtcChannel()
          .catch((e) => {
            joinRtcStep?.endWith({
              serverCost: e.cost,
              code: e.code || -1,
              msg: e.msg || e.message || 'failure',
              requestId: e.requestId,
            })
            this.roomContext?.leaveRoom()
            throw e
          })
        joinRtcStep?.endWith({
          code: joinRtcRes.code,
          msg: joinRtcRes.message,
        })
        await this.rtcController.setLocalAudioProfile(
          'music_standard' as AudioProfile
        )
      }
      console.log('create meeting ', res)
      this._meetingStatus = 'joined'
      this._meetingStartTime = new Date().getTime()
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
            serverCost: e.cost,
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
          serverCost: e.cost,
        })
        console.log('authService.login', e)
      }
      anonymousJoinStep.endWith({
        code: data.code,
        msg: data.msg || 'success',
        requestId: data.requestId,
        serverCost: data.cost,
      })
      return await this._joinHandler(options)
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
      this.roomContext && (await this.roomContext.leaveRoom())
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
  getMeetingInfo(): NEMeetingSDK | null {
    if (!this.roomContext) {
      return null
    }
    const remoteMembers = this.roomContext.remoteMembers
    const localMember = this.roomContext.localMember
    const roomProperties = this.roomContext.roomProperties
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
    const whiteboardUuid = roomProperties.wbSharingUuid
      ? roomProperties.wbSharingUuid.value
      : this.roomContext.whiteboardController.getWhiteboardSharingUserUuid()
    const focusUuid = roomProperties.focus ? roomProperties.focus.value : ''
    localMember.isInChatroom = true
    const members = [localMember, ...remoteMembers]
    const memberList: NEMember[] = []
    let localHandsUp = false
    members.forEach((member) => {
      // 去除只显示加入rtc房间的 ，h5断网之后会重新离开rtc，然后立马恢复，dom元素设置会存在问题，造成黑屏
      // if (member.isInRtcChannel || member.uuid === localMember.uuid) {
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
      memberList.push({ ...member, role: member.role?.name, isHandsUp })
      // }
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
      meetingCode,
    } = this._meetingInfo
    return {
      memberList,
      meetingInfo: {
        localMember: {
          ...localMember,
          role: localMember.role?.name as Role,
          isHandsUp: localHandsUp,
        },
        meetingInviteUrl,
        myUuid: localMember.uuid,
        focusUuid,
        hostUuid,
        hostName,
        screenUuid,
        whiteboardUuid,
        properties: roomProperties,
        password: this.roomContext.password,
        subject,
        startTime,
        endTime,
        type,
        shortMeetingNum: shortMeetingNum,
        sipCid: this.roomContext.sipCid,
        activeSpeakerUuid: '',
        meetingId: meetingId,
        meetingNum: meetingNum,
        remainingSeconds: this.roomContext.remainingSeconds,
        // isUnMutedAudio: this.isUnMutedAudio,
        // isUnMutedVideo: this.isUnMutedVideo,
        videoOff: roomProperties.videoOff
          ? roomProperties.videoOff.value
          : AttendeeOffType.disable,
        audioOff: roomProperties.audioOff
          ? roomProperties.audioOff.value
          : AttendeeOffType.disable,
        isLocked: roomProperties.lock?.value === 1,
        liveConfig: settings.liveConfig,
      },
    }
  }
  // 发送成员会控操作
  sendMemberControl(type: memberAction, uuid?: string) {
    return this._handleMemberAction(type, uuid)
  }
  sendHostControl(type: hostAction, uuid: string) {
    return this._handleHostAction(type, uuid)
  }
  async muteLocalAudio(need = true) {
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
  async unmuteLocalAudio(deviceId?: string, need = true) {
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
          deviceId,
        })
      } else {
        return this.rtcController.unmuteMyAudio()
      }
    } else {
      return false
    }
  }
  switchDevice(options: { type: DeviceType; deviceId: string }) {
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
    return this.rtcController?.unmuteMyVideo()
  }

  async muteLocalScreenShare() {
    logger.debug('muteLocalScreenShare')
    reporter.send({
      action_name: 'screen_share',
      value: 0,
    })
    return this.rtcController?.stopScreenShare()
  }

  async unmuteLocalScreenShare(params?: { sourceId?: string }) {
    logger.debug('unmuteLocalScreenShare %t %o', params)
    reporter.send({
      action_name: 'screen_share',
      value: 1,
    })
    return this.rtcController?.startScreenShare(params)
  }

  async changeLocalAudio(deviceId: string) {
    return this.rtcController?.switchDevice({
      type: 'microphone',
      deviceId,
    })
  }

  async changeLocalVideo(deviceId: string, need = true) {
    return this.rtcController?.switchDevice({
      type: 'camera',
      deviceId,
    })
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
    if (this.rtcController) {
      return this.rtcController.getSelectedRecordDevice()
    }
    return ''
  }
  getSelectedCameraDevice(): string {
    if (this.rtcController) {
      return this.rtcController.getSelectedCameraDevice()
    }
    return ''
  }
  getSelectedPlayoutDevice(): string {
    if (this.rtcController) {
      return this.rtcController.getSelectedPlayoutDevice()
    }
    return ''
  }

  async getMicrophones() {
    if (this.rtcController) {
      const res = await this.rtcController.enumRecordDevices()
      // const devices = await this._webrtc.getMicrophones()
      logger.debug('getMicrophones success, %o %t', res.data)
      return res.data.map((item) => {
        // if (
        //   item.deviceName.indexOf('USB') < 0 &&
        //   item.deviceName.indexOf('Built') < 0 &&
        //   item.deviceName.indexOf('外置') < 0 &&
        //   item.deviceName.indexOf('麦克风') < 0 &&
        //   item.deviceName.indexOf('默认') < 0
        // ) {
        //   const languageMap = {
        //     'zh-CN': '不推荐',
        //     'en-US': 'Unavailable',
        //     'ja-JP': 'お推薦しません',
        //   }
        //   item.deviceName =
        //     item.deviceName + `（${languageMap[this._language]}）`
        // }
        return item
      })
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
      return res.data
    } else {
      logger.warn('getCameras no _webrtc %t')
    }
  }
  async getSpeakers() {
    logger.debug('getSpeakers %t')
    if (this.rtcController) {
      const res = await this.rtcController.enumPlayoutDevices()
      logger.debug('getSpeakers success, %o %t', res.data)
      return res.data.map((item) => {
        /*
        if (
          item.deviceName.indexOf('USB') < 0 &&
          item.deviceName.indexOf('Built') < 0 &&
          item.deviceName.indexOf('外置') < 0 &&
          item.deviceName.indexOf('扬声器') < 0 &&
          item.deviceName.indexOf('默认') < 0
        ) {
          const languageMap = {
            'zh-CN': '不推荐',
            'en-US': 'Unavailable',
            'ja-JP': 'お推薦しません',
          }
          item.deviceName =
            item.deviceName + `（${languageMap[this._language]}）`
        }
        */
        return item
      })
    } else {
      logger.warn('getSpeakers no _webrtc %t')
    }
  }
  //选择要使用的扬声器
  async selectSpeakers(speakerId: string) {
    logger.debug('selectSpeakers %s %t', speakerId)
    return this.rtcController?.switchDevice({
      type: 'speaker',
      deviceId: speakerId,
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
  // 修改会中昵称
  async modifyNickName(options: { nickName: string }) {
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
  collectMeeting(roomArchiveId: number): Promise<any> {
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
  cancelCollectMeeting(roomArchiveId: number): Promise<any> {
    return this._request
      .delete(
        `/scene/meeting/${this._appKey}/v1/meeting/${roomArchiveId}/favorite`
      )
      .then((res) => {
        return res.data
      })
  }

  private _reset(): void {
    this.roomContext = null
    this.rtcController = null
    this.whiteboardController = null
    this.chatController = null
    this._meetingType = 0
    this._isLoginedByAccount = false
  }
  private _addRtcListener() {
    this.roomContext?.addRtcStatsListener({
      onNetworkQuality: (data) => {
        this._eventEmitter.emit(EventType.NetworkQuality, data)
      },
      onRtcStats: (data) => {
        this._eventEmitter.emit(EventType.RtcStats, data)
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
          console.log(EventType.MemberJoinRoom, members)
          this._eventEmitter.emit(EventType.MemberJoinRoom, members)
        },
        onMemberNameChanged: (member, name) => {
          this._eventEmitter.emit(EventType.MemberNameChanged, member, name)
        },
        // onMemberJoinRtcChannel: async (members) => {
        //   console.log(
        //     EventType.MemberJoinRtcChannel,
        //     members,
        //     this._eventEmitter
        //   )
        //   // this._eventEmitter.emit(EventType.MemberJoinRtcChannel, members)
        // },
        onMemberLeaveChatroom: (members) => {
          console.log(EventType.MemberLeaveChatroom, members)
        },
        onMemberLeaveRoom: (members) => {
          console.log('onMemberLeaveRoom', members)
          if (
            members.length == 1 &&
            this.roomContext?.localMember.uuid === members[0].uuid
          ) {
            this._meetingStatus = 'login'
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
          this._eventEmitter.emit(EventType.ReceiveChatroomMessages, messages)
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
        onRoomPropertiesChanged: (properties: any) => {
          this._eventEmitter.emit(EventType.RoomPropertiesChanged, properties)
        },
        onRoomLockStateChanged: (isLocked: boolean) => {
          this._eventEmitter.emit(EventType.RoomLockStateChanged, isLocked)
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
          this._eventEmitter.emit(EventType.RtcActiveSpeakerChanged, speaker)
        },
        onRtcChannelError: (code) => {
          if (
            code === 'SOCKET_ERROR' ||
            code === 'MEDIA_TRANSPORT_DISCONNECT'
          ) {
            if (this._isAnonymous) {
              this._meetingStatus = 'unlogin'
              // this.authService && this.authService.logout()
            } else {
              this._meetingStatus = 'login'
            }
            // @ts-ignore
            this.roomContext?.removeRoomListener()
            // @ts-ignore
            this.roomContext?.removeRtcStatsListener()
            this._eventEmitter.emit(EventType.RoomEnded, 'RTC_CHANNEL_ERROR')
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
        onRtcRemoteAudioVolumeIndication: (data) => {
          if (this.rtcController) {
            const rtc: any = (this.rtcController as any)._rtc
            const localVolume = rtc.localStream?.getAudioLevel()
            data = data.filter((item) => {
              return item.volume > 1
            })
            if (localVolume > 0) {
              const localData = {
                userUuid: this.localMember.uuid,
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
          this._eventEmitter.emit(EventType.RtcAudioVolumeIndication, arr)
        },
        onRoomLiveStateChanged: (state) => {
          this._eventEmitter.emit(EventType.RoomLiveStateChanged, state)
        },
        onRoomRemainingSecondsRenewed: (data) => {
          this._eventEmitter.emit(EventType.roomRemainingSecondsRenewed, data)
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
    joinStep.endWith({
      code: data.code,
      msg: data.msg,
      requestId: data.requestId,
      serverCost: data.cost,
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
    await this._joinRoomkit({
      role: options.role as string,
      roomUuid: res.roomUuid,
      nickname: options.nickName,
      password: options.password,
      crossAppAuthorization,
      initialProperties: {
        tag: { value: options.memberTag },
      },
      createRoomReport: options.joinMeetingReport,
    })
    this._addRoomListener()
    this._addRtcListener()
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
      const joinRtcStep = options.joinMeetingReport?.beginStep(
        StaticReportType.Join_rtc
      )
      const joinRtcRes = await this.rtcController
        .joinRtcChannel()
        .catch((e) => {
          joinRtcStep?.endWith({
            code: e.code || -1,
            msg: e.message || 'Failure',
          })
          this.roomContext?.leaveRoom()
          throw e
        })
      joinRtcStep?.endWith({
        code: joinRtcRes.code,
        msg: joinRtcRes.message,
      })
      await this.rtcController.setLocalAudioProfile(
        'music_standard' as AudioProfile
      )
    }
    this._meetingStatus = 'joined'
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
    userUuid = userUuid || (this.roomContext as NERoomContext)?.localMember.uuid
    const rtcController = (this.roomContext as NERoomContext)?.rtcController
    const whiteboardController = (this.roomContext as NERoomContext)
      .whiteboardController
    switch (type) {
      case memberAction.muteAudio:
        return rtcController.muteMyAudio()
      case memberAction.unmuteAudio:
        return rtcController.unmuteMyAudio()
      case memberAction.muteVideo:
        return rtcController.muteMyVideo()
      case memberAction.unmuteVideo:
        // this.setCanvas(userUuid, 'video');
        return rtcController.unmuteMyVideo()
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
        // todo 需要添加修改逻辑
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
    }
  }

  private async _handleHostAction(type: hostAction, userUuid: string) {
    const roomContext = this.roomContext as NERoomContext
    switch (type) {
      case hostAction.remove:
        return roomContext.kickMemberOut(userUuid)
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
  }) {
    const joinRoomStep = options.createRoomReport?.beginStep(
      StaticReportType.Join_room
    )
    return (this.roomService as NERoomService)
      .joinRoom(
        {
          role: options.role,
          roomUuid: options.roomUuid,
          userName: options.nickname,
          password: options.password,
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
        if (this.roomContext) {
          this.rtcController = this.roomContext.rtcController
          this.whiteboardController = this.roomContext.whiteboardController
          this.liveController = this.roomContext.liveController
          await this.whiteboardController.initWhiteboard().catch((e) => {
            console.error('initWhiteboard failed: ' + e)
          })
          this.chatController = this.roomContext.chatController
          if (!this.roomContext.localMember.role.hide && !this._noChat) {
            await this.chatController.joinChatroom().catch((e) => {
              console.error('joinChatroom failed: ' + e)
            })
          }
        }
        this._meetingStartTime = new Date().getTime()
      })
      .catch((e) => {
        joinRoomStep?.endWith({
          code: e.code || -1,
          msg: e.message || e.msg || 'Failure',
        })
        throw e
      })
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
          versionCode: pkg.version,
          meetingVer: pkg.version,
          deviceId: (this._roomkit as any).deviceId,
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
        return Promise.reject(error)
      }
    )

    return instance
  }
}
