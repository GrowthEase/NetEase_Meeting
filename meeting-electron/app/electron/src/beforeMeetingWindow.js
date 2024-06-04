const { BrowserWindow, screen, shell, ipcMain } = require('electron');
const path = require('path');

const isLocal = process.env.MODE === 'local';

const newWins = {};

function createBeforeMeetingWindow() {
  // 获取当前，鼠标所在的屏幕中心
  const mousePosition = screen.getCursorScreenPoint();
  const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
  const { x, y, width, height } = nowDisplay.workArea;
  const beforeMeetingWindow = new BrowserWindow({
    titleBarStyle: 'hidden',
    width: 375,
    height: 670,
    x: Math.round(x + (width - 375) / 2),
    y: Math.round(y + (height - 670) / 2),
    trafficLightPosition: {
      x: 10,
      y: 13,
    },
    resizable: false,
    maximizable: false,
    backgroundColor: '#fff',
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      enableRemoteModule: true,
      preload: path.join(__dirname, './preload.js'),
    },
  });
  if (isLocal) {
    beforeMeetingWindow.loadURL('http://localhost:8000/');
    beforeMeetingWindow.webContents.openDevTools();
  } else {
    beforeMeetingWindow.loadFile(path.join(__dirname, '../build/index.html'));
  }

  beforeMeetingWindow.webContents.on(
    'did-create-window',
    (newWin, { url: originalUrl }) => {
      const url = originalUrl.replace(/.*?(?=#)/, '');
      newWins[url] = newWin;
      // 通过 openWindow 打开的窗口，需要在关闭时通知主窗口
      newWin.on('close', (event) => {
        event.preventDefault();
        if (url.includes('scheduleMeeting')) {
          newWin.webContents.send('scheduleMeetingWindow:close');
          return;
        }
        beforeMeetingWindow.webContents.send(`windowClosed:${url}`);
        if (url.includes('setting')) {
          beforeMeetingWindow?.webContents.send('previewController', {
            method: 'stopPreview',
            args: [],
          });
        }
        newWin.hide();
      });
      if (url.includes('notification/card')) {
        newWin.setWindowButtonVisibility?.(false);
      }

      newWin.webContents.session.removeAllListeners('will-download');
      newWin.webContents.session.on('will-download', (event, item) => {
        item.on('done', (event, state) => {
          if (state === 'completed') {
            const path = event.sender.getSavePath();
            shell.showItemInFolder(path);
          }
        });
      });
      if (isLocal) {
        newWin.webContents.openDevTools();
      }
    },
  );

  beforeMeetingWindow.webContents.setWindowOpenHandler(
    ({ url: originalUrl }) => {
      const url = originalUrl.replace(/.*?(?=#)/, '');
      const { x, y } = beforeMeetingWindow.getBounds();
      const commonOptions = {
        width: 375,
        height: 670,
        titleBarStyle: 'hidden',
        maximizable: false,
        minimizable: false,
        resizable: false,
        trafficLightPosition: {
          x: 10,
          y: 13,
        },
        webPreferences: {
          contextIsolation: false,
          nodeIntegration: true,
          preload: path.join(__dirname, './ipc.js'),
        },
      };
      if (url.includes('#/notification/list')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            x: x + 375,
            y: y,
          },
        };
      } else if (url.includes('#/history')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
          },
        };
      } else if (url.includes('#/imageCrop')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 600,
            height: 380,
          },
        };
      } else if (url.includes('#/about')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            height: 460,
          },
        };
      } else if (url.includes('#/nps')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 800,
            height: 380,
          },
        };
      } else if (url.includes('#/plugin')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
          },
        };
      } else if (url.includes('#/chat')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
          },
        };
      } else if (url.includes('#/setting')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 800,
            height: 680,
            trafficLightPosition: {
              x: 10,
              y: 13,
            },
          },
        };
      } else if (url.includes('#/addressBook')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            width: 498,
            height: 456,
            trafficLightPosition: {
              x: 10,
              y: 13,
            },
          },
        };
      } else if (url.includes('#/notification/card')) {
        const nowDisplay = screen.getPrimaryDisplay();
        const { width, height } = nowDisplay.workArea;
        const notifyWidth = 360;
        const notifyHeight = 260;
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
            maximizable: false,
            titleBarStyle: 'hidden',
            minimizable: false,
            fullscreenable: false,
            alwaysOnTop: 'screen-saver',
            resizable: false,
            skipTaskbar: true,
            width: 360,
            height: 260,
            x: Math.round(width - notifyWidth - 60),
            y: Math.round(height - notifyHeight - 20),
          },
        };
      } else if (url.includes('#/scheduleMeeting')) {
        return {
          action: 'allow',
          overrideBrowserWindowOptions: {
            ...commonOptions,
          },
        };
      }
      return { action: 'deny' };
    },
  );

  function getKeyByValue(obj, value) {
    return Object.keys(obj).find((key) => obj[key] === value);
  }

  ipcMain.on('childWindow:closed', (event) => {
    const win = BrowserWindow.fromWebContents(event.sender);
    const url = getKeyByValue(newWins, win);
    url && beforeMeetingWindow.webContents.send(`windowClosed:${url}`);
    win?.hide();
  });

  return beforeMeetingWindow;
}

module.exports = {
  createBeforeMeetingWindow,
  beforeNewWins: newWins,
};
