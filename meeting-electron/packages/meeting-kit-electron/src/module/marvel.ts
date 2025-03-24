import { ipcMain } from 'electron'
import { startWinMarvel } from 'marvel-node'

function registerMarvel() {
  // 仅在 Windows 上注册
  if (process.platform === 'win32') {
    ipcMain.on('startMarvel', (event, config) => {
      startWinMarvel(config)
    })
  }
}

export { registerMarvel }
