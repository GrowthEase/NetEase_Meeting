import { BrowserWindow, ipcMain } from 'electron'
import { NEResult } from 'neroom-types'
import {
  NEJoinMeetingParams,
  NEMeetingStatus,
  NEMeetingStatusListener,
  NELocalHistoryMeeting,
} from 'nemeeting-core-sdk'
import NEMeetingServiceInterface, {
  NEJoinMeetingOptions,
  NEStartMeetingOptions,
  NEStartMeetingParams,
  NEMeetingInfo,
  NESingleStateMenuItem,
  NECheckableMenuItem,
  NEMeetingOnInjectedMenuItemClickListener,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/meeting_service'
import { BUNDLE_NAME } from '../meeting_kit'
import ElectronBaseService from './meeting_electron_base_service'

const MODULE_NAME = 'NEMeetingService'

let seqCount = 0

export default class NEMeetingService
  extends ElectronBaseService
  implements NEMeetingServiceInterface
{
  private _meetingStatusListeners: NEMeetingStatusListener[] = []
  private _menuItemClickListeners: NEMeetingOnInjectedMenuItemClickListener[] =
    []

  constructor(_win: BrowserWindow) {
    super(_win)
    this._addListening()
  }

  async startMeeting(
    param: NEStartMeetingParams,
    opts?: NEStartMeetingOptions
  ): Promise<NEResult<void>> {
    const functionName = 'startMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [param, opts],
      seqId,
    })

    return this._IpcMainListener<NEResult<void>>(seqId).then((res) => {
      this._win.show()
      this._win.initMainWindowSize?.()
      this._win.inMeeting = true
      return res
    })
  }

  async joinMeeting(
    param: NEJoinMeetingParams,
    opts?: NEJoinMeetingOptions
  ): Promise<NEResult<void>> {
    const functionName = 'joinMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [param, opts],
      seqId,
    })

    return this._IpcMainListener<NEResult<void>>(seqId).then((res) => {
      this._win.show()
      this._win.initMainWindowSize?.()
      this._win.inMeeting = true
      return res
    })
  }
  async anonymousJoinMeeting(
    param: NEJoinMeetingParams,
    opts?: NEJoinMeetingOptions
  ): Promise<NEResult<void>> {
    const functionName = 'anonymousJoinMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [param, opts],
      seqId,
    })

    return this._IpcMainListener<NEResult<void>>(seqId).then((res) => {
      this._win.show()
      this._win.initMainWindowSize?.()
      this._win.inMeeting = true
      return res
    })
  }
  async updateInjectedMenuItem(
    item: NESingleStateMenuItem | NECheckableMenuItem
  ): Promise<NEResult<void>> {
    const functionName = 'updateInjectedMenuItem'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [item],
      seqId,
    })

    return this._IpcMainListener<NEResult<void>>(seqId)
  }
  async getMeetingStatus(): Promise<NEResult<NEMeetingStatus>> {
    const functionName = 'getMeetingStatus'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
      seqId,
    })

    return this._IpcMainListener<NEResult<NEMeetingStatus>>(seqId)
  }

  getCurrentMeetingInfo(): Promise<NEResult<NEMeetingInfo>> {
    const functionName = 'getCurrentMeetingInfo'

    const seqId = this._generateSeqId(functionName)

    if (!this._win.isDestroyed()) {
      this._win.webContents.send(BUNDLE_NAME, {
        module: MODULE_NAME,
        method: functionName,
        args: [],
        seqId,
      })
    }

    return this._IpcMainListener<NEResult<NEMeetingInfo>>(seqId)
  }
  setOnInjectedMenuItemClickListener(
    listener: NEMeetingOnInjectedMenuItemClickListener
  ): void {
    this._menuItemClickListeners.push(listener)
  }

  addMeetingStatusListener(listener: NEMeetingStatusListener): void {
    this._meetingStatusListeners.push(listener)
  }
  removeMeetingStatusListener(listener: NEMeetingStatusListener): void {
    const index = this._meetingStatusListeners.indexOf(listener)

    if (index > -1) {
      this._meetingStatusListeners.splice(index, 1)
    }
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

    return this._IpcMainListener<NEResult<NELocalHistoryMeeting[]>>(seqId)
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

    return this._IpcMainListener<NEResult<void>>(seqId)
  }

  leaveCurrentMeeting(closeIfHost: boolean): Promise<NEResult<void>> {
    const functionName = 'leaveCurrentMeeting'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [closeIfHost],
      seqId,
    })

    return this._IpcMainListener<NEResult<void>>(seqId)
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

      if (event === 'onMeetingStatusChanged') {
        this._meetingStatusListeners.forEach((l) => {
          l[event]?.(...payload)
        })
      } else if (event === 'onInjectedMenuItemClick') {
        this._menuItemClickListeners.forEach((l) => {
          l[event]?.(...payload)
        })
      }
    })
  }

  private _generateSeqId(functionName: string) {
    seqCount++
    return `${BUNDLE_NAME}::${MODULE_NAME}::${functionName}::${seqCount}`
  }

  private _IpcMainListener<T>(seqId: string): Promise<T> {
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
