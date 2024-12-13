import { FailureBodySync } from 'neroom-types'
import NEMeetingInviteService from '../../../kit/impl/service/meeting_invite_service'
import { InvokeCallback } from '../meeting_kit'

export default class NEMeetingInviteServiceHandle {
  private _meetingInviteService: NEMeetingInviteService
  private _listenerInvokeCallback: InvokeCallback

  constructor(
    meetingInviteService: NEMeetingInviteService,
    listenerInvokeCallback: InvokeCallback
  ) {
    this._meetingInviteService = meetingInviteService
    this._listenerInvokeCallback = listenerInvokeCallback

    this._meetingInviteService.addMeetingInviteStatusListener({
      onMeetingInviteStatusChanged: (
        status,
        inviteInfo,
        meetingId,
        message
      ) => {
        this._listenerInvokeCallback(
          7,
          101,
          JSON.stringify({
            status,
            inviteInfo,
            meetingId,
            message,
          }),
          0
        )
      },
    })
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    let res

    switch (cid) {
      case 1:
        res = await this.rejectInvite(data)
        break
      case 3:
        res = await this.acceptInvite(data)
        break
      case 9:
        res = await this.callOutRoomSystem(data)
        break
      default:
        return JSON.stringify(FailureBodySync(undefined, 'method not found'))
    }

    return JSON.stringify(res)
  }

  async acceptInvite(data: string) {
    const { param, opts } = JSON.parse(data)

    return await this._meetingInviteService.acceptInvite(param, opts)
  }

  async rejectInvite(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._meetingInviteService.rejectInvite(meetingId)
  }

  async callOutRoomSystem(data: string) {
    const { device } = JSON.parse(data)

    return await this._meetingInviteService.callOutRoomSystem(device)
  }
}
