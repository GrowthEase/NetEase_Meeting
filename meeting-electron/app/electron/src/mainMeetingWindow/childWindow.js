const { screen, shell } = require('electron');
const { sharingScreen } = require('../sharingScreen');
const path = require('path');

const isWin32 = process.platform === 'win32';
const MEETING_HEADER_HEIGHT = isWin32 ? 31 : 28;

let selfWindow = null;

const newWins = {};

function setExcludeWindowList() {
  selfWindow.webContents.send('setExcludeWindowList', [
    [...Object.values(newWins), selfWindow]
      .filter((item) => item && !item.isDestroyed())
      .map((item) =>
        isWin32
          ? item.getNativeWindowHandle()
          : Number(item.getMediaSourceId().split(':')[1]),
      ),
    isWin32,
  ]);
}

function openNewWindow(url) {
  const newWin = newWins[url];

  if (!newWin || newWin.isDestroyed()) return;

  if (url.includes('screenSharing/video')) {
    newWin.setWindowButtonVisibility?.(false);

    const mousePosition = screen.getCursorScreenPoint();
    const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
    // 通过位置信息获取对应的屏幕
    const currentScreen = sharingScreen.shareScreen || nowDisplay;

    // 获取屏幕的位置，宽度和高度
    const screenX = currentScreen.bounds.x;
    const screenY = currentScreen.bounds.y;
    const screenWidth = currentScreen.bounds.width;
    // 计算窗口的新位置
    const newX = screenX + screenWidth - newWin.getSize()[0] - 20;
    const newY = screenY;

    // 将窗口移动到新位置
    newWin.setPosition(newX, newY);

    newWin.setAlwaysOnTop(true, 'screen-saver');
  } else if (url.includes('notification/card')) {
    newWin.setWindowButtonVisibility?.(false);
    // 获取主窗口的位置信息
    const mousePosition = screen.getCursorScreenPoint();
    const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
    // 通过位置信息获取对应的屏幕
    const currentScreen = sharingScreen.shareScreen || nowDisplay;
    // 获取屏幕的位置，宽度和高度
    const screenX = currentScreen.bounds.x;
    const screenY = currentScreen.bounds.y;
    const screenWidth = currentScreen.bounds.width;
    const screenHeight = currentScreen.bounds.height;
    // 计算窗口的新位置
    const newX = screenX + screenWidth - newWin.getSize()[0] - 60;
    const newY = screenY + screenHeight - newWin.getSize()[1] - 60;

    // 将窗口移动到新位置
    newWin.setPosition(newX, newY);
    newWin.setAlwaysOnTop(true, 'screen-saver');
  } else if (url.includes('/screenSharing/screenMarker')) {
    const index = url.split('/').pop();
    const display = screen.getAllDisplays()[Number(index)];

    if (display) {
      const { x, y } = display.workArea;

      newWin.setBounds({
        x: x + 30,
        y: y + 30,
      });
      newWin.setWindowButtonVisibility?.(false);
      newWin.show();
    }
  } else if (url.includes('/annotation')) {
    newWin.setWindowButtonVisibility?.(false);
    newWin.setIgnoreMouseEvents(true);
    newWin.setAlwaysOnTop(true, 'normal', 99);
    if (sharingScreen.shareScreen) {
      newWin.setBounds(sharingScreen.shareScreen.bounds);
    }

    // newWin.webContents.openDevTools();
  }

  setExcludeWindowList();
}

function setWindowOpenHandler(mainWindow) {
  selfWindow = mainWindow;

  mainWindow.webContents.setWindowOpenHandler(({ url: originalUrl }) => {
    const url = originalUrl.replace(/.*?(?=#)/, '');
    const commonOptions = {
      width: 375,
      height: 670,
      titleBarStyle: 'hidden',
      maximizable: false,
      minimizable: false,
      resizable: false,
      autoHideMenuBar: true,
      title: '',
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        preload: path.join(__dirname, '../ipc.js'),
      },
    };

    if (url.endsWith('screenSharing/video')) {
      const pW = 215;
      const pH = MEETING_HEADER_HEIGHT + 120;

      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          width: pW - 2,
          height: pH,
          titleBarStyle: 'hidden',
          transparent: true,
        },
      };
    } else if (url.includes('#/plugin?')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          titleBarStyle: 'default',
        },
      };
    } else if (url.includes('#/notification/card')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          width: 360,
          height: 260,
        },
      };
    } else if (url.includes('#/notification/list')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          titleBarStyle: 'default',
        },
      };
    } else if (url.includes('#/setting')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          width: 800,
          height: 600,
          trafficLightPosition: {
            x: 16,
            y: 19,
          },
        },
      };
    } else if (url.includes('#/invite')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          titleBarStyle: 'default',
          width: 498,
          height: 548,
        },
      };
    } else if (url.includes('#/member')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          titleBarStyle: 'default',
          width: 400,
          height: 600,
        },
      };
    } else if (url.includes('#/chat')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          titleBarStyle: 'default',
          width: 400,
          height: 600,
        },
      };
    } else if (url.includes('#/monitoring')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          height: 300,
          width: 455,
          trafficLightPosition: {
            x: 16,
            y: 19,
          },
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
    } else if (url.includes('#/screenSharing/screenMarker')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          height: 100,
          width: 100,
          autoHideMenuBar: true,
          hiddenInMissionControl: true,
          title: '',
          transparent: true,
          hasShadow: false,
          resizable: false,
          minimizable: false,
          skipTaskbar: true,
          show: false,
        },
      };
    } else if (url.includes('#/annotation')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          height: 100,
          width: 100,
          autoHideMenuBar: true,
          hiddenInMissionControl: true,
          title: '',
          transparent: true,
          hasShadow: false,
          resizable: false,
          minimizable: false,
          skipTaskbar: true,
          enableLargerThanScreen: true,
          // 避免 win 下，透明窗口影响底下窗口渲染
          type: 'toolbar',
        },
      };
    } else if (url.includes('#/interpreterSetting')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          width: 520,
          height: 543,
          trafficLightPosition: {
            x: 10,
            y: 13,
          },
        },
      };
    } else if (url.includes('#/interpreterWindow')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          maximizable: false,
          titleBarStyle: 'hidden',
          minimizable: false,
          fullscreenable: false,
          transparent: true,
          alwaysOnTop: 'screen-saver',
          resizable: false,
          skipTaskbar: true,
          width: 220,
          height: 350,
          x: 42,
          y: 42,
        },
      };
    } else if (url.includes('#/feedback')) {
      return {
        action: 'allow',
        overrideBrowserWindowOptions: {
          ...commonOptions,
          width: 375,
          height: 731,
          trafficLightPosition: {
            x: 16,
            y: 19,
          },
        },
      };
    }

    return { action: 'deny' };
  });

  mainWindow.webContents.on(
    'did-create-window',
    (newWin, { url: originalUrl }) => {
      // newWin.setParentWindow(mainWindow);

      const url = originalUrl.replace(/.*?(?=#)/, '');

      newWins[url] = newWin;
      // 通过 openWindow 打开的窗口，需要在关闭时通知主窗口
      newWin.on('close', (event) => {
        mainWindow.webContents.send(`windowClosed:${url}`);

        const needDelay = url.includes('/annotation');

        // 通过隐藏处理关闭，关闭有一定概率崩溃
        setTimeout(
          () => {
            newWin.hide();
          },
          needDelay ? 1000 : 0,
        );
        event.preventDefault();
      });

      if (url.includes('interpreterWindow')) {
        newWin.setWindowButtonVisibility?.(false);
      }

      // windows下alt键会触发菜单栏，需要屏蔽
      if (isWin32) {
        newWin.webContents.on('before-input-event', (event, input) => {
          if (input.alt) {
            event.preventDefault();
          }
        });
      }

      // 聊天窗口打开下载文件夹
      newWin.webContents.session.removeAllListeners('will-download');
      newWin.webContents.session.on('will-download', (event, item) => {
        item.on('done', (event, state) => {
          if (state === 'completed') {
            // 文件下载完成，打开文件所在路径
            const path = event.sender.getSavePath();

            shell.showItemInFolder(path);
          }
        });
      });

      openNewWindow(url);

      // newWin.webContents.openDevTools();
    },
  );
}

module.exports = {
  openNewWindow,
  setWindowOpenHandler,
  newWins,
};
