import { BrowserWindow, ipcMain } from 'electron'
import { NEResult } from 'neroom-types'

import NEPreMeetingServiceInterface, {
  NERemoteHistoryMeeting,
  NERemoteHistoryMeetingDetail,
  NEMeetingItem,
  NEMeetingItemStatus,
  NEPreMeetingListener,
  NEScheduledMember,
  NEMeetingRecord,
  NEMeetingTranscriptionInfo,
  NEMeetingTranscriptionMessage,
  NEChatroomHistoryMessageSearchOption,
  NEMeetingChatMessage,
  NELocalHistoryMeeting,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/pre_meeting_service'
import { BUNDLE_NAME } from '../meeting_kit'
import ElectronBaseService from './meeting_electron_base_service'
import { NEMeetingWebAppItem } from 'nemeeting-core-sdk'

const MODULE_NAME = 'NEPreMeetingService'

let seqCount = 0

class NEPreMeetingService
  extends ElectronBaseService
  implements NEPreMeetingServiceInterface
{
  private _listeners: NEPreMeetingListener[] = []

  constructor(_win: BrowserWindow) {
    super(_win)
    this._addListening()
  }

  async getFavoriteMeetingList(
    anchorId: number,
    limit: number
  ): Promise<NEResult<NERemoteHistoryMeeting[]>> {
    const functionName = 'getFavoriteMeetingList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [anchorId, limit],
      seqId,
    })

    return this._IpcMainListener<NERemoteHistoryMeeting[]>(seqId)
  }

  async addFavoriteMeeting(meetingId: number): Promise<NEResult<number>> {
    const functionName = 'addFavoriteMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<number>(seqId)
  }

  async removeFavoriteMeeting(meetingId: number): Promise<NEResult<void>> {
    const functionName = 'removeFavoriteMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async getHistoryMeetingList(
    anchorId: number,
    limit: number
  ): Promise<NEResult<NERemoteHistoryMeeting[]>> {
    const functionName = 'getHistoryMeetingList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [anchorId, limit],
      seqId,
    })

    return this._IpcMainListener<NERemoteHistoryMeeting[]>(seqId)
  }

  async getHistoryMeetingDetail(
    meetingId: number
  ): Promise<NEResult<NERemoteHistoryMeetingDetail>> {
    const functionName = 'getHistoryMeetingDetail'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<NERemoteHistoryMeetingDetail>(seqId)
  }

  async getHistoryMeeting(
    meetingId: number
  ): Promise<NEResult<NERemoteHistoryMeeting>> {
    const functionName = 'getHistoryMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<NERemoteHistoryMeeting>(seqId)
  }

  async createScheduleMeetingItem(): Promise<NEResult<NEMeetingItem>> {
    const functionName = 'createScheduleMeetingItem'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NEMeetingItem>(seqId)
  }

  async scheduleMeeting(item: NEMeetingItem): Promise<NEResult<NEMeetingItem>> {
    const functionName = 'scheduleMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [item],
      seqId,
    })

    return this._IpcMainListener<NEMeetingItem>(seqId)
  }

  async editMeeting(
    item: NEMeetingItem,
    editRecurringMeeting: boolean
  ): Promise<NEResult<NEMeetingItem>> {
    const functionName = 'editMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [item, editRecurringMeeting],
      seqId,
    })

    return this._IpcMainListener<NEMeetingItem>(seqId)
  }

  async cancelMeeting(
    meetingId: number,
    cancelRecurringMeeting: boolean
  ): Promise<NEResult<void>> {
    const functionName = 'cancelMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId, cancelRecurringMeeting],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async getMeetingItemByNum(
    meetingNum: string
  ): Promise<NEResult<NEMeetingItem>> {
    const functionName = 'getMeetingItemByNum'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingNum],
      seqId,
    })

    return this._IpcMainListener<NEMeetingItem>(seqId)
  }

  async getMeetingItemById(
    meetingId: number
  ): Promise<NEResult<NEMeetingItem>> {
    const functionName = 'getMeetingItemById'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<NEMeetingItem>(seqId)
  }

  async getMeetingList(
    status: NEMeetingItemStatus[]
  ): Promise<NEResult<NEMeetingItem[]>> {
    const functionName = 'getMeetingList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [status],
      seqId,
    })

    return this._IpcMainListener<NEMeetingItem[]>(seqId)
  }

  async getScheduledMeetingMemberList(
    meetingNum: string
  ): Promise<NEResult<NEScheduledMember[]>> {
    const functionName = 'getScheduledMeetingMemberList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingNum],
      seqId,
    })

    return this._IpcMainListener<NEScheduledMember[]>(seqId)
  }

  async getMeetingCloudRecordList(
    meetingId: number
  ): Promise<NEResult<NEMeetingRecord[]>> {
    const functionName = 'getMeetingCloudRecordList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<NEMeetingRecord[]>(seqId)
  }

  async getLocalHistoryMeetingList(): Promise<
    NEResult<NELocalHistoryMeeting[]>
  > {
    const functionName = 'getLocalHistoryMeetingList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NELocalHistoryMeeting[]>(seqId)
  }

  async clearLocalHistoryMeetingList(): Promise<NEResult<void>> {
    const functionName = 'clearLocalHistoryMeetingList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async getHistoryMeetingTranscriptionInfo(
    meetingId: number
  ): Promise<NEResult<NEMeetingTranscriptionInfo[]>> {
    const functionName = 'getHistoryMeetingTranscriptionInfo'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<NEMeetingTranscriptionInfo[]>(seqId)
  }

  async getHistoryMeetingTranscriptionFileUrl(
    meetingId: number,
    fileKey: string
  ): Promise<NEResult<string>> {
    const functionName = 'getHistoryMeetingTranscriptionFileUrl'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId, fileKey],
      seqId,
    })

    return this._IpcMainListener<string>(seqId)
  }

  async getHistoryMeetingTranscriptionMessageList(
    meetingId: number,
    fileKey: string
  ): Promise<NEResult<NEMeetingTranscriptionMessage[]>> {
    const functionName = 'getHistoryMeetingTranscriptionMessageList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId, fileKey],
      seqId,
    })

    return this._IpcMainListener<NEMeetingTranscriptionMessage[]>(seqId)
  }

  async loadWebAppView(
    meetingId: number,
    item: NEMeetingWebAppItem
  ): Promise<NEResult<void>> {
    const functionName = 'loadWebAppView'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId, item],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async loadChatroomHistoryMessageView(
    meetingId: number
  ): Promise<NEResult<void>> {
    const functionName = 'loadChatroomHistoryMessageView'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  async fetchChatroomHistoryMessageList(
    meetingId: number,
    option: NEChatroomHistoryMessageSearchOption
  ): Promise<NEResult<NEMeetingChatMessage[]>> {
    console.log('fetchChatroomHistoryMessageList')

    const functionName = 'fetchChatroomHistoryMessageList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId, option],
      seqId,
    })

    return this._IpcMainListener<NEMeetingChatMessage[]>(seqId)
  }

  async exportChatroomHistoryMessageList(
    meetingId: number
  ): Promise<NEResult<string>> {
    const functionName = 'exportChatroomHistoryMessageList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<string>(seqId)
  }

  addListener(listener: NEPreMeetingListener): void {
    this._listeners.push(listener)
  }

  removeListener(listener: NEPreMeetingListener): void {
    this._listeners = this._listeners.filter((l) => l !== listener)
  }

  private _addListening(): void {
    const channel = `NEMeetingKitListener::${MODULE_NAME}`

    ipcMain.removeAllListeners(channel)
    ipcMain.removeHandler(channel)

    ipcMain.on(channel, (_, data) => {
      const { module, event, payload } = data

      if (module !== MODULE_NAME) {
        return
      }

      this._listeners.forEach((l) => {
        l[event]?.(...payload)
      })
    })
  }

  private _generateSeqId(functionName: string) {
    seqCount++
    return `${BUNDLE_NAME}::${MODULE_NAME}::${functionName}::${seqCount}`
  }

  private _IpcMainListener<T>(seqId: string): Promise<NEResult<T>> {
    return new Promise((resolve, reject) => {
      ipcMain.once(seqId, (_, res) => {
        if (res.error) {
          reject(res.error)
        } else {
          resolve(res.result)
        }
      })
    })
  }
}

export default NEPreMeetingService
