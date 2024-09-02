import { BrowserWindow, ipcMain } from 'electron'
import { NEResult } from 'neroom-types'
import NEFeedbackServiceInterface, {
  NEFeedback,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/feedback_service'
import { BUNDLE_NAME } from '../meeting_kit'
import ElectronBaseService from './meeting_electron_base_service'

const MODULE_NAME = 'NEFeedbackService'

let seqCount = 0

export default class NEFeedbackService
  extends ElectronBaseService
  implements NEFeedbackServiceInterface
{
  constructor(_win: BrowserWindow) {
    super(_win)
  }

  feedback(feedback: NEFeedback): Promise<NEResult<void>> {
    const functionName = 'feedback'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [feedback],
      seqId,
    })

    return this._IpcMainListener<void>(seqId)
  }

  showFeedbackView(): Promise<NEResult<void>> {
    const functionName = 'showFeedbackView'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [],
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
        if (res.error) {
          reject(res.error)
        } else {
          resolve(res.result)
        }
      })
    })
  }
}
