import { FailureBodySync } from 'neroom-types'
import NEMeetingService from '../../../kit/impl/service/meeting_service'
import { InvokeCallback } from '../meeting_kit'

export default class NEMeetingServiceHandle {
  private _meetingService: NEMeetingService
  private _listenerInvokeCallback: InvokeCallback

  constructor(
    meetingService: NEMeetingService,
    listenerInvokeCallback: InvokeCallback
  ) {
    this._listenerInvokeCallback = listenerInvokeCallback
    this._meetingService = meetingService

    this._meetingService.addMeetingStatusListener({
      onMeetingStatusChanged: (event) => {
        this._listenerInvokeCallback(2, 101, JSON.stringify({ event }), 0)
      },
    })

    this._meetingService.setOnInjectedMenuItemClickListener({
      onInjectedMenuItemClick: (clickInfo, meetingInfo) => {
        this._listenerInvokeCallback(
          2,
          102,
          JSON.stringify({ clickInfo, meetingInfo }),
          0
        )
      },
    })
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    let res: unknown

    switch (cid) {
      case 1:
        res = await this.startMeeting(data)
        break
      case 3:
        res = await this.joinMeeting(data)
        break
      case 5:
        res = await this.anonymousJoinMeeting(data)
        break
      case 7:
        res = await this.getMeetingStatus()
        break
      case 9:
        res = await this.leaveCurrentMeeting(data)
        break
      case 11:
        res = await this.getCurrentMeetingInfo()
        break
      case 15:
        res = await this.updateInjectedMenuItem(data)
        break
      case 17:
        res = await this.getLocalHistoryMeetingList()
        break

      default:
        return JSON.stringify(FailureBodySync(undefined, 'method not found'))
    }

    return JSON.stringify(res)
  }

  async joinMeeting(data: string) {
    const { param, opts } = JSON.parse(data)

    return await this._meetingService.joinMeeting(param, opts)
  }

  async startMeeting(data: string) {
    const { param, opts } = JSON.parse(data)

    return await this._meetingService.startMeeting(param, opts)
  }

  async anonymousJoinMeeting(data: string) {
    const { param, opts } = JSON.parse(data)

    return await this._meetingService.anonymousJoinMeeting(param, opts)
  }

  async getMeetingStatus() {
    return await this._meetingService.getMeetingStatus()
  }

  async getCurrentMeetingInfo() {
    return await this._meetingService.getCurrentMeetingInfo()
  }

  async updateInjectedMenuItem(data: string) {
    const { item } = JSON.parse(data)

    return await this._meetingService.updateInjectedMenuItem(item)
  }

  async leaveCurrentMeeting(data: string) {
    const { closeIfHost } = JSON.parse(data)

    return await this._meetingService.leaveCurrentMeeting(closeIfHost)
  }

  async getLocalHistoryMeetingList() {
    return await this._meetingService.getLocalHistoryMeetingList()
  }
}
