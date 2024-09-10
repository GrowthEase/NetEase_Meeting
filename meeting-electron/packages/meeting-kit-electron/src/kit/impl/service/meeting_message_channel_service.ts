import { BrowserWindow, ipcMain } from 'electron'
import { NEResult } from 'neroom-types'
import NEMeetingMessageChannelServiceInterface, {
  NEMeetingGetMessageHistoryParams,
  NEMeetingMessageChannelListener,
  NEMeetingSessionMessage,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/meeting_message_channel_service'
import { BUNDLE_NAME } from '../meeting_kit'
import ElectronBaseService from './meeting_electron_base_service'

const MODULE_NAME = 'NEMeetingMessageChannelService'

let seqCount = 0

export default class NEMeetingMessageChannelService
  extends ElectronBaseService
  implements NEMeetingMessageChannelServiceInterface
{
  private _listeners: NEMeetingMessageChannelListener[] = []

  constructor(_win: BrowserWindow) {
    super(_win)
    this._addListening()
  }

  addMeetingMessageChannelListener(
    listener: NEMeetingMessageChannelListener
  ): void {
    if (listener) {
      this._listeners.push(listener)
    }
  }
  removeMeetingMessageChannelListener(
    listener: NEMeetingMessageChannelListener
  ): void {
    const index = this._listeners.indexOf(listener)

    if (index !== -1) {
      this._listeners.splice(index, 1)
    }
  }
  queryUnreadMessageList(
    sessionId: string
  ): Promise<NEResult<NEMeetingSessionMessage[]>> {
    const functionName = 'queryUnreadMessageList'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [sessionId],
      seqId,
    })

    return this._IpcMainListener<NEMeetingSessionMessage[]>(seqId)
  }
  clearUnreadCount(sessionId: string): Promise<NEResult<void>> {
    const functionName = 'clearUnreadCount'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [sessionId],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  deleteAllSessionMessage(sessionId: string): Promise<NEResult<void>> {
    const functionName = 'deleteAllSessionMessage'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [sessionId],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  getSessionMessagesHistory(
    param: NEMeetingGetMessageHistoryParams
  ): Promise<NEResult<NEMeetingSessionMessage[]>> {
    const functionName = 'getSessionMessagesHistory'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [param],
      seqId,
    })

    return this._IpcMainListener<NEMeetingSessionMessage[]>(seqId)
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
