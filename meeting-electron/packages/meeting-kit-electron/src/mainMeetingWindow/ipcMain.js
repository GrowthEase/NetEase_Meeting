const { ipcMain, BrowserWindow, screen } = require('electron')
const { newWins, openNewWindow } = require('./childWindow')
const { MINI_WIDTH, MINI_HEIGHT, isWin32 } = require('../constant')

const EventType = {
  OpenChatroomOrMemberList: 'openChatroomOrMemberList',
  OpenChatroomOrMemberListReply: 'openChatroomOrMemberList-reply',
  FocusWindow: 'focusWindow',
  AnnotationWindow: 'annotationWindow',
  InterpreterWindowChange: 'interpreterWindowChange',
  CaptionWindowChange: 'captionWindowChange',
  ChangeSetting: 'changeSetting',
  IgnoreMouseEvents: 'ignoreMouseEvents',
}

let currentWindow = null
let preFloatingWindow = false

function focusWindow(event, url) {
  const win = BrowserWindow.fromWebContents(event.sender)

  if (win === currentWindow) {
    if (url === 'mainWindow') {
      win.show()
    } else if (newWins[url] && !newWins[url].isDestroyed()) {
      openNewWindow(url)
      newWins[url].show()
    }
  }
}

function changeSetting(_, setting) {
  if (currentWindow && !currentWindow.isDestroyed()) {
    currentWindow.webContents.send('changeSetting', setting)
  }

  Object.values(newWins).forEach((win) => {
    if (win && !win.isDestroyed()) {
      win.webContents.send('changeSetting', setting)
    }
  })
}

let annotationWindowSetBoundsTimer = null

function annotationWindow(_, data) {
  const annotationWindow = newWins['#/annotation']

  if (annotationWindow && !annotationWindow.isDestroyed()) {
    const { event, payload } = data

    if (event === 'setBounds') {
      if (!isWin32) {
        const primaryDisplay = screen.getPrimaryDisplay()

        payload.y =
          primaryDisplay.bounds.y +
          primaryDisplay.bounds.height -
          payload.height -
          payload.y
      }

      if (payload.width < 60 || payload.height < 60) {
        annotationWindow.setOpacity(0)
      } else {
        annotationWindow.setOpacity(1)
        if (isWin32) {
          if (annotationWindowSetBoundsTimer) {
            clearTimeout(annotationWindowSetBoundsTimer)
            annotationWindowSetBoundsTimer = null
          }

          const mousePosition = screen.getCursorScreenPoint()
          const nowDisplay = screen.getDisplayNearestPoint(mousePosition)
          const scaleFactor = nowDisplay.scaleFactor

          annotationWindowSetBoundsTimer = setTimeout(() => {
            payload.x = Math.round(payload.x / scaleFactor)
            payload.y = Math.round(payload.y / scaleFactor)
            payload.width = Math.round(payload.width / scaleFactor)
            payload.height = Math.round(payload.height / scaleFactor)

            annotationWindow.setBounds(payload, true)
          }, 300)
        } else {
          annotationWindow.setBounds(payload)
        }
      }
    } else if (event === 'setIgnoreMouseEvents') {
      annotationWindow.setIgnoreMouseEvents(payload)
    }
  }
}

function captionWindowChange(_, data) {
  const newWin = newWins['#/captionWindow']

  if (!newWin) {
    console.log('captionWindowChange: newWin is null')
  }

  const { height } = data

  newWin.setBounds({
    height,
  })
}

function interpreterWindowChange(_, data) {
  const newWin = newWins['#/interpreterWindow']

  if (!newWin) {
    console.log('interpreterWindowChange: newWin is null')
  }

  const { width, height, floatingWindow } = data
  const nowDisplay = screen.getPrimaryDisplay()
  const { width: workWidth, height: workHeight } = nowDisplay.workArea

  if (floatingWindow) {
    newWin.setBounds({
      x: workWidth - 42,
      y: workHeight - 230,
      width,
      height,
    })
  } else {
    if (preFloatingWindow) {
      newWin.setBounds({
        x: workWidth - 225,
        y: workHeight - 390,
        width,
        height,
      })
    } else {
      newWin.setBounds({
        width,
        height,
      })
    }
  }

  preFloatingWindow = floatingWindow
}

let setIgnoreMouseEventsTimer = null

function handleIgnoreMouseEvents(event, data) {
  const win = BrowserWindow.fromWebContents(event.sender)

  setIgnoreMouseEventsTimer && clearTimeout(setIgnoreMouseEventsTimer)
  if (data) {
    win.setIgnoreMouseEvents(true, { forward: true })
    setIgnoreMouseEventsTimer = setTimeout(() => {
      win.setIgnoreMouseEvents(false, { forward: true })
    }, 1000)
  } else {
    win.setIgnoreMouseEvents(false, { forward: true })
  }
}

function addIpcMainListeners(window) {
  currentWindow = window

  // let alreadySetWidth = false

  ipcMain.on(EventType.FocusWindow, focusWindow)
  ipcMain.on(EventType.AnnotationWindow, annotationWindow)
  ipcMain.on(EventType.InterpreterWindowChange, interpreterWindowChange)
  ipcMain.on(EventType.CaptionWindowChange, captionWindowChange)
  ipcMain.on(EventType.OpenChatroomOrMemberList, (event, isOpen) => {
    const mainWindow = BrowserWindow.fromWebContents(event.sender)

    if (!mainWindow) {
      return
    }

    if (isOpen) {
      mainWindow.setMinimumSize(MINI_WIDTH + 320, MINI_HEIGHT)
    } else {
      mainWindow.setMinimumSize(MINI_WIDTH, MINI_HEIGHT)
    }

    mainWindow?.webContents.send('openChatroomOrMemberList-reply', isOpen)
    // resize结束通知渲染进程
    if (
      mainWindow?.isFullScreen() ||
      mainWindow?.isMaximized() ||
      mainWindow?.isFullScreenPrivate ||
      mainWindow?.isMaximizedPrivate
    ) {
      return
    }

    const mousePosition = screen.getCursorScreenPoint()
    const { x: displayX, width: displayW } = screen.getDisplayNearestPoint(
      mousePosition
    ).workArea // 鼠标所在屏幕的大小
    const { x: mainX, width: mainW } = mainWindow.getBounds() // 当前窗口的大小

    if (isOpen) {
      // alreadySetWidth = true
      const newWidth = mainW + 320
      const exceedW = newWidth + mainX - (displayX + displayW)

      if (exceedW > 0) {
        mainWindow.setBounds({
          x: Math.round(mainX - exceedW),
          width: Math.round(newWidth),
        })
      } else {
        mainWindow.setBounds({
          width: Math.round(newWidth),
        })
      }
    } else {
      // alreadySetWidth = false
      mainWindow.setBounds({ width: Math.round(mainW - 320) })
    }

    event.sender.send(EventType.OpenChatroomOrMemberListReply)
  })

  ipcMain.on(EventType.ChangeSetting, changeSetting)

  ipcMain.on(EventType.IgnoreMouseEvents, handleIgnoreMouseEvents)
}

function removeIpcMainListeners() {
  ipcMain.removeListener(EventType.FocusWindow, focusWindow)
  ipcMain.removeListener(EventType.AnnotationWindow, annotationWindow)
  ipcMain.removeListener(
    EventType.InterpreterWindowChange,
    interpreterWindowChange
  )
  ipcMain.removeListener(EventType.CaptionWindowChange, captionWindowChange)
  ipcMain.removeListener(EventType.changeSetting, changeSetting)
  ipcMain.removeAllListeners(EventType.OpenChatroomOrMemberList)
  ipcMain.removeListener(EventType.IgnoreMouseEvents, handleIgnoreMouseEvents)
}

module.exports = {
  addIpcMainListeners,
  removeIpcMainListeners,
}
