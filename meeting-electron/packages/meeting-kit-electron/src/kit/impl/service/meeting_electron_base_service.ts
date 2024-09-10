import { BrowserWindow } from 'electron'

class ElectronBaseService {
  protected _win: BrowserWindow & {
    inMeeting?: boolean
    initMainWindowSize?: () => void
  }

  constructor(_win: BrowserWindow) {
    this._win = _win
  }

  setWin(win: BrowserWindow) {
    this._win = win
  }
}

export default ElectronBaseService
