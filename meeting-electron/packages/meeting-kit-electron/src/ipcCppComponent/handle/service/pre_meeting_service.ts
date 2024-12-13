import { FailureBodySync } from 'neroom-types'
import NEPreMeetingService from '../../../kit/impl/service/pre_meeting_service'
import { InvokeCallback } from '../meeting_kit'

export default class NEPreMeetingServiceHandle {
  private _preMeetingService: NEPreMeetingService
  private _listenerInvokeCallback: InvokeCallback

  constructor(
    preMeetingService: NEPreMeetingService,
    listenerInvokeCallback: InvokeCallback
  ) {
    this._preMeetingService = preMeetingService
    this._listenerInvokeCallback = listenerInvokeCallback

    this._preMeetingService.addListener({
      onMeetingItemInfoChanged: (meetingItemList) => {
        this._listenerInvokeCallback(
          6,
          101,
          JSON.stringify({ meetingItemList }),
          0
        )
      },
    })
  }

  async onMethodHandle(cid: number, data: string): Promise<string> {
    let res

    switch (cid) {
      case 1:
        res = await this.getFavoriteMeetingList(data)
        break
      case 3:
        res = await this.addFavoriteMeeting(data)
        break
      case 5:
        res = await this.removeFavoriteMeeting(data)
        break
      case 7:
        res = await this.getHistoryMeetingList(data)
        break
      case 9:
        res = await this.getHistoryMeetingDetail(data)
        break
      case 11:
        res = await this.getHistoryMeeting(data)
        break
      case 13:
        res = await this.scheduleMeeting(data)
        break
      case 15:
        res = await this.getScheduledMeetingMemberList(data)
        break
      case 17:
        res = await this.getMeetingList(data)
        break
      case 19:
        res = await this.getMeetingItemById(data)
        break
      case 21:
        res = await this.cancelMeeting(data)
        break
      case 23:
        res = await this.editMeeting(data)
        break
      case 25:
        res = await this.getMeetingItemByNum(data)
        break
      // case 27:
      //   res = await this.getMeetingItemByInviteCode(data)
      //   break
      // case 29:
      //   res = await this.getMeetingItemByInviteCodeByItem(data)
      //   break
      case 31:
        res = await this.getLocalHistoryMeetingList()
        break
      case 33:
        res = await this.getMeetingCloudRecordList(data)
        break
      case 35:
        res = await this.getHistoryMeetingTranscriptionInfo(data)
        break
      case 37:
        res = await this.getHistoryMeetingTranscriptionFileUrl(data)
        break
      case 39:
        res = await this.loadWebAppView(data)
        break
      case 41:
        res = await this.fetchChatroomHistoryMessageList(data)
        break
      case 43:
        res = await this.exportChatroomHistoryMessageList(data)
        break
      case 45:
        res = await this.clearLocalHistoryMeetingList()
        break
      case 47:
        res = await this.getHistoryMeetingTranscriptionMessageList(data)
        break
      case 49:
        res = await this.loadChatroomHistoryMessageView(data)
        break
      case 51:
        res = await this.getScheduledMeetingList(data)
        break
      default:
        return JSON.stringify(FailureBodySync(undefined, 'method not found'))
    }

    return JSON.stringify(res)
  }

  async getFavoriteMeetingList(data: string) {
    const { anchorId, limit } = JSON.parse(data)

    return await this._preMeetingService.getFavoriteMeetingList(anchorId, limit)
  }

  async addFavoriteMeeting(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.addFavoriteMeeting(meetingId)
  }

  async removeFavoriteMeeting(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.removeFavoriteMeeting(meetingId)
  }

  async getHistoryMeetingList(data: string) {
    const { anchorId, limit } = JSON.parse(data)

    return await this._preMeetingService.getHistoryMeetingList(anchorId, limit)
  }

  async getHistoryMeetingDetail(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.getHistoryMeetingDetail(meetingId)
  }

  async getHistoryMeeting(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.getHistoryMeeting(meetingId)
  }

  async createScheduleMeetingItem() {
    return await this._preMeetingService.createScheduleMeetingItem()
  }

  async scheduleMeeting(data: string) {
    const { item } = JSON.parse(data)

    return await this._preMeetingService.scheduleMeeting(item)
  }

  async editMeeting(data: string) {
    const { item, editRecurringMeeting } = JSON.parse(data)

    return await this._preMeetingService.editMeeting(item, editRecurringMeeting)
  }

  async cancelMeeting(data: string) {
    const { meetingId, cancelRecurringMeeting } = JSON.parse(data)

    return await this._preMeetingService.cancelMeeting(
      meetingId,
      cancelRecurringMeeting
    )
  }

  async getMeetingItemByNum(data: string) {
    const { meetingNum } = JSON.parse(data)

    return await this._preMeetingService.getMeetingItemByNum(meetingNum)
  }

  async getMeetingItemById(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.getMeetingItemById(meetingId)
  }

  async getMeetingList(data: string) {
    const { status } = JSON.parse(data)

    return await this._preMeetingService.getMeetingList(status)
  }

  async getScheduledMeetingMemberList(data: string) {
    const { meetingNum } = JSON.parse(data)

    return await this._preMeetingService.getScheduledMeetingMemberList(
      meetingNum
    )
  }

  async getLocalHistoryMeetingList() {
    return await this._preMeetingService.getLocalHistoryMeetingList()
  }

  async clearLocalHistoryMeetingList() {
    return await this._preMeetingService.clearLocalHistoryMeetingList()
  }

  async getMeetingCloudRecordList(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.getMeetingCloudRecordList(meetingId)
  }

  async getHistoryMeetingTranscriptionInfo(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.getHistoryMeetingTranscriptionInfo(
      meetingId
    )
  }

  async getHistoryMeetingTranscriptionFileUrl(data: string) {
    const { meetingId, fileKey } = JSON.parse(data)

    return await this._preMeetingService.getHistoryMeetingTranscriptionFileUrl(
      meetingId,
      fileKey
    )
  }

  async loadWebAppView(data: string) {
    const { meetingId, item } = JSON.parse(data)

    return await this._preMeetingService.loadWebAppView(meetingId, item)
  }

  async fetchChatroomHistoryMessageList(data: string) {
    const { meetingId, option } = JSON.parse(data)

    return await this._preMeetingService.fetchChatroomHistoryMessageList(
      meetingId,
      option
    )
  }

  async exportChatroomHistoryMessageList(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.exportChatroomHistoryMessageList(
      meetingId
    )
  }

  async getHistoryMeetingTranscriptionMessageList(data: string) {
    const { meetingId, fileKey } = JSON.parse(data)

    return await this._preMeetingService.getHistoryMeetingTranscriptionMessageList(
      meetingId,
      fileKey
    )
  }

  async loadChatroomHistoryMessageView(data: string) {
    const { meetingId } = JSON.parse(data)

    return await this._preMeetingService.loadChatroomHistoryMessageView(
      meetingId
    )
  }

  async getScheduledMeetingList(data: string) {
    const { status } = JSON.parse(data)

    return await this._preMeetingService.getScheduledMeetingList(status)
  }
}
