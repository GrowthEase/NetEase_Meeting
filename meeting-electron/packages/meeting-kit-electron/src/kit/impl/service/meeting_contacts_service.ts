import { BrowserWindow, ipcMain } from 'electron'
import { NEResult } from 'neroom-types'
import NEContactsServiceInterface, {
  NEContactsInfoResult,
  NEContact,
} from 'nemeeting-core-sdk/dist/web/types/kit/interface/service/meeting_contacts_service'
import { BUNDLE_NAME } from '../meeting_kit'
import ElectronBaseService from './meeting_electron_base_service'

const MODULE_NAME = 'NEContactsService'

let seqCount = 0

export default class NEContactsService
  extends ElectronBaseService
  implements NEContactsServiceInterface
{
  constructor(_win: BrowserWindow) {
    super(_win)
  }

  async searchContactListByName(
    name: string,
    pageSize: number,
    pageNum: number
  ): Promise<NEResult<NEContact[]>> {
    const functionName = 'searchContactListByName'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [name, pageSize, pageNum],
      seqId,
    })

    return this._IpcMainListener<NEContact[]>(seqId)
  }
  async searchContactListByPhoneNumber(
    phoneNumber: string,
    pageSize: number,
    pageNum: number
  ): Promise<NEResult<NEContact[]>> {
    const functionName = 'searchContactListByPhoneNumber'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [phoneNumber, pageSize, pageNum],
      seqId,
    })

    return this._IpcMainListener<NEContact[]>(seqId)
  }
  async getContactsInfo(
    userUuids: string[]
  ): Promise<NEResult<NEContactsInfoResult>> {
    const functionName = 'getContactsInfo'

    const seqId = this._generateSeqId(functionName)

    this._win.webContents.send(BUNDLE_NAME, {
      module: MODULE_NAME,
      method: functionName,
      args: [userUuids],
      seqId,
    })

    return this._IpcMainListener<NEContactsInfoResult>(seqId)
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
