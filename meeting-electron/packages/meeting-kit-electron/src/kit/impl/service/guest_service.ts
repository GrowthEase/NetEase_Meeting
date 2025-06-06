import { BrowserWindow, ipcMain } from 'electron'
import { NEMeetingOptions } from 'nemeeting-core-sdk/dist/web/types/kit/interface'
import NEGuestServiceInterface, {
  NEGuestJoinMeetingParams,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/guest_service'
import { NEResult } from 'neroom-types'
import ElectronBaseService from './meeting_electron_base_service'
import { BUNDLE_NAME } from '../meeting_kit'

const MODULE_NAME = 'NEGuestService'
let seqCount = 0

export default class NEGuestService
  extends ElectronBaseService
  implements NEGuestServiceInterface
{
  constructor(win: BrowserWindow) {
    super(win)
  }

  joinMeetingAsGuest(
    param: NEGuestJoinMeetingParams,
    opts?: NEMeetingOptions
  ): Promise<NEResult<void>> {
    const functionName = 'joinMeetingAsGuest'

    const seqId = this._generateSeqId(functionName)

    console.log('seqId>>>', seqId)
    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [param, opts],
      seqId,
    })

    return this._IpcMainListener<void>(seqId).then((res) => {
      this._win.show()
      this._win.initMainWindowSize?.()
      this._win.inMeeting = true
      return res
    })
  }
  requestSmsCodeForGuestJoin(
    meetingNum: string,
    phoneNumber: string
  ): Promise<NEResult<void>> {
    const functionName = 'requestSmsCodeForGuestJoin'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [meetingNum, phoneNumber],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  private _generateSeqId(functionName: string) {
    seqCount++
    return `${BUNDLE_NAME}::${MODULE_NAME}::${functionName}::${seqCount}`
  }

  private _IpcMainListener<T>(seqId: string): Promise<NEResult<T>> {
    return new Promise((resolve, reject) => {
      ipcMain.once(seqId, (_, res) => {
        console.log('_IpcMainListener>>>', seqId, res)
        if (res.error) {
          reject(res.error)
        } else {
          resolve(res.result)
        }
      })
    })
  }
}
