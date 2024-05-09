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
    // beforeMeetingWindow.webContents.openDevTools();
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
        beforeMeetingWindow.webContents.send(`windowClosed:${url}`);
        if (url.includes('setting')) {
          beforeMeetingWindow?.webContents.send('previewController', {
            method: 'stopPreview',
            args: [],
          });
        }
        // 通过隐藏处理关闭，关闭有一定概率崩溃
        newWin.hide();
        event.preventDefault();
      });

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
            height: 560,
            trafficLightPosition: {
              x: 10,
              y: 13,
            },
          },
        };
      }
      return { action: 'deny' };
    },
  );

  return beforeMeetingWindow;
}

module.exports = {
  createBeforeMeetingWindow,
  beforeNewWins: newWins,
};
