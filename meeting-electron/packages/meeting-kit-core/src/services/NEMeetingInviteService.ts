import { NEResult, NECustomSessionMessage } from 'neroom-types'
import NEMeetingService from './NEMeeting'
import { EventType, GetMeetingConfigResponse } from '../types'
import {
  JoinOptions,
  NEMeetingInviteInfo,
  NEMeetingInviteStatus,
} from '../types/type'
import EventEmitter from 'eventemitter3'

interface InitOptions {
  neMeeting: NEMeetingService
  eventEmitter: EventEmitter
}

export default class NEMeetingInviteService {
  private _neMeeting: NEMeetingService
  private _event: EventEmitter
  private _globalConfig: GetMeetingConfigResponse | null = null
  private _meetingIdToMeetingNumMap: Map<string, NECustomSessionMessage> =
    new Map()
  private _roomUuidToMeetingNumMap: Map<string, NECustomSessionMessage> =
    new Map()
  constructor(initOptions: InitOptions) {
    this._neMeeting = initOptions.neMeeting
    this._event = initOptions.eventEmitter
    this._initListener()
  }
  /**
   * 挂断正在进行的呼叫，无论是正在响铃还是等待响铃都可以使用
   * @param meetingId 会议
   */
  async rejectInvite(meetingId: string): Promise<NEResult<null> | undefined> {
    const message = this._meetingIdToMeetingNumMap.get(meetingId)
    const roomUuid = message?.data?.data.roomUuid

    if (roomUuid) {
      return this._neMeeting?.rejectInvite(roomUuid)
    } else {
      return undefined
    }
  }

  /**
   * @brief 通过邀请加入房间
   * @param params 加入房间参数 {@link NEJoinRoomParams}
   * @param options 加入房间选项 {@link NEJoinRoomOptions}
   * @return void
   */
  acceptInvite(options: JoinOptions): Promise<void> {
    return new Promise((resolve, reject) => {
      this._neMeeting.eventEmitter.emit(
        EventType.AcceptInvite,
        options,
        (e) => {
          if (e) {
            reject(e)
          } else {
            resolve()
          }
        }
      )
    })
  }

  on<K extends keyof NEMeetingInviteListener>(
    eventName: K,
    callback: NEMeetingInviteListener[K]
  ): void {
    callback && this._event.on(eventName, callback)
  }

  off<K extends keyof NEMeetingInviteListener>(
    eventName: K,
    callback?: NEMeetingInviteListener[K]
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
        }

        // 第一次需要抛出事件
        this._event.emit(
          EventType.OnMeetingInviteStatusChange,
          NEMeetingInviteStatus.calling,
          data.meetingId,
          data.inviteInfo,
          message
        )
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
    } else if ([33, 51, 30].includes(res.commandId)) {
      const inviteInfo = this._roomUuidToMeetingNumMap.get(res.roomUuid)?.data
        ?.data

      if (inviteInfo) {
        this._event.emit(
          EventType.OnMeetingInviteStatusChange,
          res.commandId === 33 || res.commandId === 30
            ? NEMeetingInviteStatus.removed
            : NEMeetingInviteStatus.canceled,
          inviteInfo.meetingId,
          inviteInfo
        )
      }
    }
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
}

interface NEMeetingInviteListener {
  // 房间呼出状态改变的回调事件。
  onMeetingInviteStatusChanged(
    status: NEMeetingInviteStatus,
    meetingId: string,
    inviteInfo: NEMeetingInviteInfo
  ): void
}
