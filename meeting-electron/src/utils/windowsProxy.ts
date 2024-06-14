import { IPCEvent } from '../../app/src/types'

type SelfWindowProxy = WindowProxy & { firstOpen: boolean }

type windows =
  | 'shareVideoWindow'
  | 'pluginWindow'
  | 'notificationWindow'
  | 'imageCropWindow'
  | 'aboutWindow'
  | 'npsWindow'
  | 'historyWindow'
  | 'settingWindow'
  | 'inviteWindow'
  | 'chatWindow'
  | 'memberWindow'
  | 'monitoringWindow'
  | 'addressBook'
  | 'notificationCardWindow'
  | 'scheduleMeetingWindow'
  | 'joinMeetingWindow'
  | 'immediateMeetingWindow'
  | 'interpreterSettingWindow'
  | 'interpreterWindow'
  | 'feedbackWindow'
  | string

const windowsUrl: {
  [key: string]: string
} = {
  shareVideoWindow: '#/screenSharing/video',
  notificationCardWindow: '#/notification/card',
  notificationListWindow: '#/notification/list',
  pluginWindow: '#/plugin',
  aboutWindow: '#/about',
  npsWindow: '#/nps',
  imageCropWindow: '#/imageCrop',
  historyWindow: '#/history',
  settingWindow: '#/setting',
  inviteWindow: '#/invite',
  chatWindow: '#/chat',
  memberWindow: '#/member',
  monitoringWindow: '#/monitoring',
  addressBook: '#/addressBook',
  scheduleMeetingWindow: '#/scheduleMeeting',
  annotationWindow: '#/annotation',
  interpreterSettingWindow: '#/interpreterSetting',
  interpreterWindow: '#/interpreterWindow',
  joinMeetingWindow: '#/joinMeeting',
  immediateMeetingWindow: '#/immediateMeeting',
  feedbackWindow: '#/feedback',
}

const windowsClosed: {
  [key: string]: boolean | undefined
} = {}

const windowsProxy: {
  [key: string]: SelfWindowProxy | null
} = {}

function openWindow(
  name: windows,
  url?: string
): (WindowProxy & { firstOpen: boolean }) | null {
  const openUrl = url ?? windowsUrl[name]
  let windowProxy = windowsProxy[name]

  if (!windowProxy) {
    const childWindow = window.open(openUrl)

    if (childWindow) {
      windowProxy = Object.assign(childWindow, { firstOpen: true })
      windowsProxy[name] = windowProxy
    }

    windowsUrl[name] = openUrl
  } else {
    windowProxy.firstOpen = false
    window.ipcRenderer?.send(IPCEvent.focusWindow, openUrl)
  }

  window.ipcRenderer?.removeAllListeners(`windowClosed:${openUrl}`)
  window.ipcRenderer?.once(`windowClosed:${openUrl}`, () => {
    // 通知子窗口关闭
    windowProxy?.postMessage({ event: 'windowClosed' }, '*')
    windowsClosed[name] = true
    if (name === 'settingWindow') {
      closeWindow('monitoringWindow')
    } else if (name === 'scheduleMeetingWindow') {
      closeWindow('addressBook')
    }

    window.webFrame?.clearCache()
  })
  windowsClosed[name] = false
  return windowProxy
}

function getWindow(name: windows): WindowProxy | null {
  if (!windowsClosed[name]) {
    return windowsProxy[name]
  }

  return null
}

function closeWindow(name: windows): void {
  windowsProxy[name]?.close()
}

function closeAllWindows(excludes?: string[]): void {
  Object.keys(windowsProxy).forEach((key) => {
    if (excludes && excludes.includes(key)) {
      return
    }

    closeWindow(key)
  })
}

function getActiveWindows(): SelfWindowProxy[] {
  const activeWindowKeys = Object.keys(windowsProxy).filter(
    (key) => !windowsClosed[key]
  )
  const activeWindows: SelfWindowProxy[] = []

  for (const key of activeWindowKeys) {
    const selfWindowProxy = windowsProxy[key]

    if (selfWindowProxy) {
      activeWindows.push(selfWindowProxy)
    }
  }

  return activeWindows
}

export { getWindow, openWindow, closeWindow, closeAllWindows, getActiveWindows }
