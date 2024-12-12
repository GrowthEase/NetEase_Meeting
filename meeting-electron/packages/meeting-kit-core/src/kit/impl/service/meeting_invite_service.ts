import { z, ZodError, ZodRawShape } from 'zod'
import {
  EventType,
  GetMeetingConfigResponse,
  JoinOptions,
  NECloudRecordStrategyType,
  NEMeetingIdDisplayOption,
} from '../../../types'
import { NEJoinMeetingParams, NEMeetingInviteStatus } from '../../../types/type'
import NEMeetingInviteServiceInterface, {
  NEMeetingInviteStatusListener,
  NERoomSIPCallInfo,
  NERoomSipDeviceInviteProtocolType,
  NERoomSystemDevice,
} from '../../interface/service/meeting_invite_service'
import NEMeetingService from '../../../services/NEMeeting'
import EventEmitter from 'eventemitter3'
import {
  NECustomSessionMessage,
  FailureBody,
  NEResult,
  SuccessBody,
  FailureBodySync,
  NERoomSipDeviceInviteProtocolType as NERoomKitSipDeviceInviteProtocolType,
} from 'neroom-types'
import {
  NEJoinMeetingOptions,
  NEMeetingOptions,
  NEWindowMode,
} from '../../interface/service/meeting_service'

const MODULE_NAME = 'NEMeetingInviteService'
const LISTENER_CHANNEL = `NEMeetingKitListener::${MODULE_NAME}`

interface InitOptions {
  neMeeting: NEMeetingService
  eventEmitter: EventEmitter
}

export default class NEMeetingInviteService
  implements NEMeetingInviteServiceInterface
{
  private _neMeeting: NEMeetingService
  private _event: EventEmitter
  private _globalConfig: GetMeetingConfigResponse | null = null
  private _listeners: NEMeetingInviteStatusListener[] = []
  private _meetingIdToMeetingNumMap: Map<number, NECustomSessionMessage> =
    new Map()
  private _roomUuidToMeetingNumMap: Map<string, NECustomSessionMessage> =
    new Map()
  constructor(initOptions: InitOptions) {
    this._neMeeting = initOptions.neMeeting
    this._event = initOptions.eventEmitter
    this._initListener()
  }
  async acceptInvite(
    param: NEJoinMeetingParams,
    opts?: NEJoinMeetingOptions
  ): Promise<NEResult<void>> {
    try {
      const paramSchema = this._getJoinParamSchema({
        meetingNum: z.string(),
      })

      const optsSchema = this._getJoinOptsSchema()

      paramSchema.parse(param, {
        path: ['param'],
      })

      optsSchema.parse(opts, {
        path: ['opts'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBodySync(undefined, error.message)
    }

    const options = this._joinMeetingOptionsToJoinOptions(param, opts)

    return new Promise((resolve, reject) => {
      this._neMeeting.eventEmitter.emit(
        EventType.AcceptInvite,
        options,
        (e) => {
          if (e) {
            console.log('acceptInvite error', e)
            reject(e)
          } else {
            this._neMeeting.eventEmitter.emit(
              EventType.AcceptInviteJoinSuccess,
              options.nickName
            )
            resolve(SuccessBody(void 0))
          }
        }
      )
    })
  }
  async rejectInvite(meetingId: number): Promise<NEResult<void>> {
    try {
      const meetingIdSchema = z.number()

      meetingIdSchema.parse(meetingId, {
        path: ['meetingId'],
      })
    } catch (errorUnkown) {
      const error = errorUnkown as ZodError

      throw FailureBody(undefined, error.message)
    }

    const message = this._meetingIdToMeetingNumMap.get(meetingId)
    const roomUuid = message?.data?.data.roomUuid

    if (roomUuid) {
      return this._neMeeting?.rejectInvite(roomUuid).then(() => {
        return SuccessBody(void 0)
      })
    } else {
      throw FailureBodySync(undefined, 'roomUuid not found')
    }
  }

  async callOutRoomSystem(
    device: NERoomSystemDevice
  ): Promise<NEResult<NERoomSIPCallInfo>> {
    if (this._neMeeting.sipController) {
      const protocol =
        device.protocol === NERoomSipDeviceInviteProtocolType.IP
          ? NERoomKitSipDeviceInviteProtocolType.SIP
          : NERoomKitSipDeviceInviteProtocolType.H323
      const deviceInfo = {
        ...device,
        protocol,
      }

      return this._neMeeting.sipController
        ?.callOutRoomSystem(deviceInfo)
        .then((res) => {
          return SuccessBody(res as NERoomSIPCallInfo)
        })
    } else {
      return FailureBody(undefined, 'sipController not found')
    }
  }

  addMeetingInviteStatusListener(
    listener: NEMeetingInviteStatusListener
  ): void {
    this._listeners.push(listener)
  }
  removeMeetingInviteStatusListener(
    listener: NEMeetingInviteStatusListener
  ): void {
    this._listeners = this._listeners.filter((l) => l !== listener)
  }

  on<K extends keyof NEMeetingInviteStatusListener>(
    eventName: K,
    callback: NEMeetingInviteStatusListener[K]
  ): void {
    callback && this._event.on(eventName, callback)
  }

  off<K extends keyof NEMeetingInviteStatusListener>(
    eventName: K,
    callback?: NEMeetingInviteStatusListener[K]
  ): void {
    if (callback) {
      this._event.off(eventName, callback)
    } else {
      this._event.off(eventName)
    }
  }

  destroy(): void {
    this._meetingIdToMeetingNumMap.clear()
    this._roomUuidToMeetingNumMap.clear()
    this._event.removeAllListeners()
  }

  private _handleReceiveSessionMessage(message) {
    if (!this._globalConfig) {
      this._globalConfig = JSON.parse(
        localStorage.getItem('nemeeting-global-config') || '{}'
      )
    }

    const sessionId = this._globalConfig?.appConfig.notifySenderAccid

    if (sessionId && message?.sessionId === sessionId) {
      if (message.data) {
        const data =
          Object.prototype.toString.call(message.data) === '[object Object]'
            ? message.data
            : JSON.parse(message.data)

        message.data = data
      }

      const type = message.data?.data?.type

      // 非会中显示的通知
      if (type === 'MEETING.INVITE') {
        const data = message.data?.data

        message.data?.data?.timestamp
        if (data.inviteInfo) {
          data.inviteInfo.timestamp = message.data?.data?.timestamp
          data.inviteInfo.inviterAvatar = data.inviteInfo.inviterIcon
          data.inviteInfo.preMeetingInvitation = data.inviteInfo.outOfMeeting
          data.inviteInfo.meetingNum = data.meetingNum
        }

        // 第一次需要抛出事件
        this._event.emit(
          EventType.OnMeetingInviteStatusChange,
          NEMeetingInviteStatus.calling,
          data.meetingId,
          data.inviteInfo,
          message
        )

        this._emitInviteInfo(NEMeetingInviteStatus.calling, message)

        this._meetingIdToMeetingNumMap.set(data.meetingId, message)
        this._roomUuidToMeetingNumMap.set(data.roomUuid, message)
      }
    }
  }

  private _handleMeetingInviteStatusChanged(res) {
    if (res.commandId === 82) {
      const { member, roomUuid } = res.data
      const message = this._roomUuidToMeetingNumMap.get(roomUuid)
      const inviteData = message?.data?.data

      if (!inviteData || member.subState !== NEMeetingInviteStatus.calling) {
        console.log('roomUuid not found', inviteData, member.subState)
        return
      }

      this._event.emit(
        EventType.OnMeetingInviteStatusChange,
        member.subState,
        inviteData.meetingId,
        inviteData.inviteInfo,
        message
      )

      this._emitInviteInfo(member.subState, message)
    } else if ([33, 51, 30].includes(res.commandId)) {
      const message = this._roomUuidToMeetingNumMap.get(res.roomUuid)
      const inviteInfo = message?.data?.data

      if (inviteInfo) {
        const status =
          res.commandId === 33 || res.commandId === 30
            ? NEMeetingInviteStatus.removed
            : NEMeetingInviteStatus.canceled

        this._event.emit(
          EventType.OnMeetingInviteStatusChange,
          status,
          inviteInfo.meetingId,
          inviteInfo
        )

        this._emitInviteInfo(status, message)
      }
    }
  }

  private _emitInviteInfo(status, message) {
    const data = message.data?.data

    message.data?.data?.timestamp

    if (data.inviteInfo) {
      data.inviteInfo.timestamp = message.data?.data?.timestamp
      data.inviteInfo.inviterAvatar = data.inviteInfo.inviterIcon
      data.inviteInfo.preMeetingInvitation = data.inviteInfo.outOfMeeting
      data.inviteInfo.meetingNum = data.meetingNum
    }

    this._listeners.forEach((listener) => {
      listener?.onMeetingInviteStatusChanged?.(
        status,
        data.inviteInfo,
        data.meetingId,
        {
          ...message,
          data:
            typeof message.data === 'object'
              ? JSON.stringify(message.data)
              : message.data,
        }
      )
    })

    window.ipcRenderer?.send(LISTENER_CHANNEL, {
      module: 'NEMeetingInviteService',
      event: 'onMeetingInviteStatusChanged',
      payload: [
        status,
        data.inviteInfo,
        data.meetingId,
        {
          ...message,
          data:
            typeof message.data === 'object'
              ? JSON.stringify(message.data)
              : message.data,
        },
      ],
    })
  }

  private _initListener() {
    this._neMeeting.eventEmitter.on(
      EventType.onSessionMessageReceived,
      this._handleReceiveSessionMessage.bind(this)
    )
    this._neMeeting.eventEmitter.on(
      EventType.OnMeetingInviteStatusChange,
      this._handleMeetingInviteStatusChanged.bind(this)
    )
  }

  private _joinMeetingOptionsToJoinOptions(
    param: NEJoinMeetingParams,
    opts?: NEMeetingOptions
  ): JoinOptions {
    let encryptionConfig

    if (param.encryptionConfig) {
      encryptionConfig = {
        encryptionType: 'sm4-128-ecb',
        encryptKey: param.encryptionConfig.encryptKey,
      }
    }

    const options: JoinOptions = {
      ...opts,
      meetingNum: param.meetingNum ?? '',
      nickName: param.displayName.trim(),
      video: opts?.noVideo !== false ? 2 : 1,
      audio: opts?.noAudio !== false ? 2 : 1,
      defaultWindowMode: opts?.defaultWindowMode,
      noRename: opts?.noRename,
      memberTag: param?.tag,
      password: param.password,
      showMemberTag: opts?.showMemberTag,
      muteBtnConfig: {
        showMuteAllAudio: !(opts?.noMuteAllAudio === true),
        showUnMuteAllAudio: !(opts?.noMuteAllAudio === true),
        showMuteAllVideo: !(opts?.noMuteAllVideo === true),
        showUnMuteAllVideo: !(opts?.noMuteAllVideo === true),
      },
      showMeetingRemainingTip: opts?.showMeetingRemainingTip,
      noSip: opts?.noSip,
      enableUnmuteBySpace: opts?.enableUnmuteBySpace,
      enableTransparentWhiteboard: opts?.enableTransparentWhiteboard,
      enableFixedToolbar: opts?.enableFixedToolbar,
      enableVideoMirror: opts?.enableVideoMirror,
      showDurationTime: opts?.showMeetingTime,
      meetingIdDisplayOption: opts?.meetingIdDisplayOption,
      encryptionConfig: encryptionConfig,
      showCloudRecordMenuItem: opts?.showCloudRecordMenuItem,
      showCloudRecordingUI: opts?.showCloudRecordingUI,
      avatar: param.avatar,
      watermarkConfig: param?.watermarkConfig,
      noNotifyCenter: opts?.noNotifyCenter,
      noWebApps: opts?.noWebApps,
      showScreenShareUserVideo: opts?.showScreenShareUserVideo,
      detectMutedMic: opts?.detectMutedMic,
    }

    return options
  }

  private _getJoinParamSchema(zodRawType: ZodRawShape) {
    const paramSchema = z.object({
      displayName: z.string(),
      avatar: z.string().optional(),
      tag: z.string().optional(),
      password: z.string().optional(),
      encryptionConfig: z
        .object({
          encryptionType: z.string(),
          encryptKey: z.string(),
        })
        .optional(),
      watermarkConfig: z
        .object({
          name: z.string().optional(),
          phone: z.string().optional(),
          email: z.string().optional(),
          jobNumber: z.string().optional(),
        })
        .optional(),
      ...zodRawType,
    })

    return paramSchema
  }

  private _getJoinOptsSchema() {
    const optsSchema = z
      .object({
        cloudRecordConfig: z
          .object({
            enable: z.boolean(),
            recordStrategy: z.nativeEnum(NECloudRecordStrategyType),
          })
          .optional(),
        enableWaitingRoom: z.boolean().optional(),
        enableGuestJoin: z.boolean().optional(),
        noMuteAllVideo: z.boolean().optional(),
        noMuteAllAudio: z.boolean().optional(),
        noVideo: z.boolean().optional(),
        noAudio: z.boolean().optional(),
        showMeetingTime: z.boolean().optional(),
        enableSpeakerSpotlight: z.boolean().optional(),
        enableShowNotYetJoinedMembers: z.boolean().optional(),
        noInvite: z.boolean().optional(),
        noSip: z.boolean().optional(),
        noChat: z.boolean().optional(),
        noSwitchAudioMode: z.boolean().optional(),
        noWhiteBoard: z.boolean().optional(),
        noRename: z.boolean().optional(),
        noLive: z.boolean().optional(),
        showMeetingRemainingTip: z.boolean().optional(),
        showScreenShareUserVideo: z.boolean().optional(),
        enableTransparentWhiteboard: z.boolean().optional(),
        showFloatingMicrophone: z.boolean().optional(),
        showMemberTag: z.boolean().optional(),
        detectMutedMic: z.boolean().optional(),
        defaultWindowMode: z.nativeEnum(NEWindowMode).optional(),
        meetingIdDisplayOption: z
          .nativeEnum(NEMeetingIdDisplayOption)
          .optional(),
        // TODO:
        // fullToolbarMenuItems
        // fullMoreMenuItems
        joinTimeout: z.number().optional(),
        // NEMeetingChatroomConfig
        showCloudRecordMenuItem: z.boolean().optional(),
        showCloudRecordingUI: z.boolean().optional(),
        noNotifyCenter: z.boolean().optional(),
        noWebApps: z.boolean().optional(),
      })
      .optional()

    return optsSchema
  }
}
