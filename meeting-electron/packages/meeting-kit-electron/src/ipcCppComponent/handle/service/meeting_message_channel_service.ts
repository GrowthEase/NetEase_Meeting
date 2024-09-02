import { FailureBodySync } from 'neroom-types'
import NEMeetingMessageChannelService from '../../../kit/impl/service/meeting_message_channel_service'
import { InvokeCallback } from '../meeting_kit'

export default class NEMeetingMessageChannelServiceHandle {
  private _meetingMessageChannelService: NEMeetingMessageChannelService
  private _listenerInvokeCallback: InvokeCallback

  constructor(
    meetingMessageChannelService: NEMeetingMessageChannelService,
    listenerInvokeCallback: InvokeCallback
  ) {
    this._meetingMessageChannelService = meetingMessageChannelService
    this._listenerInvokeCallback = listenerInvokeCallback

    this._meetingMessageChannelService.addMeetingMessageChannelListener({
      onSessionMessageReceived: (message) => {
        this._listenerInvokeCallback(
          9,
          101,
          JSON.stringify({
            message,
          }),
          0
        )
      },
      onSessionMessageRecentChanged: (messages) => {
        this._listenerInvokeCallback(
          9,
          102,
          JSON.stringify({
            messages,
          }),
          0
        )
      },
      onSessionMessageDeleted: (message) => {
        this._listenerInvokeCallback(
          9,
          103,
          JSON.stringify({
            message,
          }),
          0
        )
      },
      onSessionMessageAllDeleted: (sessionId, sessionType) => {
        this._listenerInvokeCallback(
          9,
          104,
          JSON.stringify({
            sessionId,
            sessionType,
          }),
          0
        )
      },
    })
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    let res

    switch (cid) {
      case 5:
        res = await this.queryUnreadMessageList(data)
        break
      case 7:
        res = await this.clearUnreadCount(data)
        break
      case 9:
        res = await this.deleteAllSessionMessage(data)
        break
      case 11:
        res = await this.getSessionMessagesHistory(data)
        break
      default:
        return JSON.stringify(FailureBodySync(undefined, 'method not found'))
    }

    return JSON.stringify(res)
  }

  async queryUnreadMessageList(data: string) {
    const { sessionId } = JSON.parse(data)

    return await this._meetingMessageChannelService.queryUnreadMessageList(
      sessionId
    )
  }

  async clearUnreadCount(data: string) {
    const { sessionId } = JSON.parse(data)

    return await this._meetingMessageChannelService.clearUnreadCount(sessionId)
  }

  async deleteAllSessionMessage(data: string) {
    const { sessionId } = JSON.parse(data)

    return await this._meetingMessageChannelService.deleteAllSessionMessage(
      sessionId
    )
  }

  async getSessionMessagesHistory(data: string) {
    const { param } = JSON.parse(data)

    return await this._meetingMessageChannelService.getSessionMessagesHistory(
      param
    )
  }
}
