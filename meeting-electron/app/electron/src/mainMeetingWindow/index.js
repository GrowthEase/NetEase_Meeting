const { BrowserWindow, screen, shell, nativeTheme, app } = require('electron');
const path = require('path');
const {
  addScreenSharingIpc,
  closeScreenSharingWindow,
} = require('../sharingScreen');
const { setWindowOpenHandler } = require('./childWindow');
const { addIpcMainListeners, removeIpcMainListeners } = require('./ipcMain');
const { MINI_WIDTH, MINI_HEIGHT, isLocal, isWin32 } = require('../constant');

// 窗口数量
app.commandLine.appendSwitch('--max-active-webgl-contexts', 1000);

if (process.platform === 'win32') {
  app.commandLine.appendSwitch('high-dpi-support', 'true');
  app.commandLine.appendSwitch('force-device-scale-factor', '1');
}

let mainWindow = null;

function displayChanged() {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow?.webContents.send('display-changed');
  }
}

function openMeetingWindow(data) {
  // 设置进入会议页面窗口大小及其他属性
  function initMainWindowSize() {
    const mousePosition = screen.getCursorScreenPoint();
    const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
    const { x, y, width, height } = nowDisplay.workArea;

    mainWindow.setBounds({
      width: Math.round(MINI_WIDTH),
      height: Math.round(MINI_HEIGHT),
      x: Math.round(x + (width - MINI_WIDTH) / 2),
      y: Math.round(y + (height - MINI_HEIGHT) / 2),
    });
    mainWindow.setMinimumSize(MINI_WIDTH, MINI_HEIGHT);
  }

  function setThemeColor() {
    if (!mainWindow.isDestroyed()) {
      mainWindow?.webContents.send(
        'set-theme-color',
        nativeTheme.shouldUseDarkColors ?? true,
      );
      nativeTheme.on('updated', () => {
        mainWindow?.webContents.send(
          'set-theme-color',
          nativeTheme.shouldUseDarkColors ?? true,
        );
      });
    }
  }

  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.destroy();
  }

  mainWindow = new BrowserWindow({
    titleBarStyle: 'hidden',
    title: '网易会议',
    trafficLightPosition: {
      x: 10,
      y: 7,
    },
    hasShadow: true,
    backgroundColor: '#fff',
    transparent: true,
    show: false,
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      enableRemoteModule: true,
      preload: path.join(__dirname, '../preload.js'),
    },
  });

  if (isLocal) {
    mainWindow.loadURL(`https://localhost:8000/#/meeting`);
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../../build/index.html'), {
      hash: 'meeting',
    });
  }

  // 最大化
  mainWindow.on('maximize', () => {
    mainWindow?.webContents.send('maximize-window', true);
  });

  // 取消最大化
  mainWindow.on('unmaximize', () => {
    mainWindow?.webContents.send('maximize-window', false);
  });

  mainWindow.webContents.session.removeAllListeners('will-download');
  mainWindow.webContents.session.on('will-download', (event, item) => {
    item.on('done', (event, state) => {
      if (state === 'completed') {
        console.log('mainWindow will-download');
        const path = event.sender.getSavePath();

        shell.showItemInFolder(path);
      }
    });
  });

  mainWindow.on('close', function (event) {
    event.preventDefault();
    mainWindow?.webContents.send('main-close-before');
  });

  mainWindow.on('leave-full-screen', () => {
    mainWindow.setTitle('网易会议');
  });
  mainWindow.on('enter-full-screen', () => {
    mainWindow.setTitle('');
  });

  mainWindow.webContents.once('dom-ready', () => {
    mainWindow?.webContents.send('nemeeting-open-meeting', data);
    mainWindow?.show();
  });

  if (isWin32) {
    mainWindow.setBackgroundColor('rgba(255, 255, 255,0)');
  }

  mainWindow.webContents.send(
    'set-theme-color',
    nativeTheme.shouldUseDarkColors ?? true,
  );

  screen.on('display-removed', displayChanged);

  screen.on('display-added', displayChanged);

  setWindowOpenHandler(mainWindow);

  initMainWindowSize();

  addScreenSharingIpc({
    mainWindow,
    initMainWindowSize,
  });

  setThemeColor();
  addIpcMainListeners(mainWindow);
  return mainWindow;
}

function closeMeetingWindow() {
  mainWindow?.destroy();
  mainWindow = null;
  closeScreenSharingWindow();
  removeIpcMainListeners();

  screen.removeListener('display-removed', displayChanged);
  screen.removeListener('display-added', displayChanged);
}

module.exports = {
  openMeetingWindow,
  closeMeetingWindow,
};
