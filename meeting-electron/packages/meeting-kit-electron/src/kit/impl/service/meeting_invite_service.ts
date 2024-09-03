import { BrowserWindow, ipcMain } from 'electron'
import { NEJoinMeetingParams } from 'nemeeting-core-sdk/dist/web/types/types/type'
import { NEJoinMeetingOptions } from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/meeting_service'
import NEMeetingInviteServiceInterface, {
  NEMeetingInviteStatusListener,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/meeting_invite_service'
import { NEResult } from 'neroom-types'
import { BUNDLE_NAME } from '../meeting_kit'
import ElectronBaseService from './meeting_electron_base_service'

const MODULE_NAME = 'NEMeetingInviteService'

let seqCount = 0

export default class NEMeetingInviteService
  extends ElectronBaseService
  implements NEMeetingInviteServiceInterface
{
  private _listeners: NEMeetingInviteStatusListener[] = []

  constructor(_win: BrowserWindow) {
    super(_win)
    this._addListening()
  }

  async acceptInvite(
    param: NEJoinMeetingParams,
    opts?: NEJoinMeetingOptions
  ): Promise<NEResult<void>> {
    const functionName = 'acceptInvite'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [param, opts],
      seqId,
    })

    return this._IpcMainListener<void>(seqId).then((res) => {
      this._win.show()
      this._win.inMeeting = true
      return res
    })
  }
  async rejectInvite(meetingId: number): Promise<NEResult<void>> {
    const functionName = 'rejectInvite'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingId],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }
  addMeetingInviteStatusListener(
    listener: NEMeetingInviteStatusListener
  ): void {
    if (listener) {
      this._listeners.push(listener)
    }
  }
  removeMeetingInviteStatusListener(
    listener: NEMeetingInviteStatusListener
  ): void {
    const index = this._listeners.indexOf(listener)

    if (index !== -1) {
      this._listeners.splice(index, 1)
    }
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
