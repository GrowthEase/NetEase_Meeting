import { app } from 'electron'
import { join } from 'path'
import log from 'electron-log/main'
import NEMeetingKitHandle from './handle/meeting_kit'
import NEIPC from 'neipc-node-sdk'

const cacheDirectoryName = 'logs'

const userDataPath = app.getPath('userData')
// 构建日志目录路径
const logPath = join(userDataPath, cacheDirectoryName)

log.initialize({ preload: true })
log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}'
log.transports.file.maxSize = 1024 * 1024 * 10
log.transports.file.fileName = `meeting_${Date.now()}.log`
log.errorHandler.startCatching()
log.eventLogger.startLogging()
log.transports.file.resolvePathFn = (variables) =>
  join(logPath, 'app', variables.fileName || 'log.log')

console.log = log.log
console.error = log.error

const appLock = app.requestSingleInstanceLock({ key: 'nemeet_sdk' })

if (!appLock) {
  app.quit()
}

app.on('window-all-closed', () => {
  // 避免关闭所有窗口后，进程退出
  console.log('window-all-closed')
})

app.dock?.hide()

app.whenReady().then(async () => {
  const portString =
    process.argv.find((item) => item.includes('--port=')) || '--port=53917'
  const port = portString.split('=')[1]

  if (port) {
    const ipc = new NEIPC()

    const meetingKitHandle = new NEMeetingKitHandle((sid, cid, data, sn) => {
      console.log('listern invokeCallback：', sid, cid, sn)
      ipc.invokeCallback(sid, cid, data, sn)
    })

    ipc.addIPCGlobalEventListener({
      onIPCMessageReceived: async (sid, cid, data, sn) => {
        const backString = await meetingKitHandle.onIPCMessageReceived(
          sid,
          cid,
          data
        )

        console.log('invokeCallback：', sid, cid, sn)
        console.log(backString)

        ipc.invokeCallback(sid, cid, backString, sn)
      },
      onException: (exceptionCode) => {
        console.log('onException：', exceptionCode)
        if (exceptionCode === 1) {
          app.quit()
        }
      },
    })

    ipc.setIPCClientPort(Number(port))
  }
})
