const {
  app,
  BrowserWindow,
  ipcMain,
  screen,
  systemPreferences,
  powerSaveBlocker,
  shell,
  dialog,
  navigator,
} = require('electron');
const path = require('path');
const { exec } = require('child_process');
const fs = require('fs');
const { checkMacUpdate, getVersionCode } = require('./utils/update');
const os = require('os');
const os_ver = os.release();
const semver = require('semver');
const NERoom = require('neroom-node-sdk');
const schedule = require('node-schedule');
const si = require('systeminformation');
const log = require('electron-log/main');
const { getLogDate } = require('./utils/log');
log.initialize({ preload: true });
log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}';
log.transports.file.maxSize = 1024 * 1024 * 30;
log.transports.file.fileName = `rooms_${getLogDate()}.log`;
log.errorHandler.startCatching();
log.eventLogger.startLogging();

Object.assign(console, log.functions);
const isLocal = process.env.MODE === 'local';

// 处理 win SSO 登录，
const appLock = app.requestSingleInstanceLock();
if (!appLock) {
  app.exit(0);
}

app.setLoginItemSettings({
  openAtLogin: true,
});

app.disableHardwareAcceleration();

let parentWindow;
let mainWindow;
let authorizationWindow;
let videoPreviewWindow;

let localWindowHandle;

let localMirror = true;

let videoWindows = [];

let userDataPath = app.getPath('userData');

let inMeeting = false;

// Windows直接用userPath还不行，要将路径改到local下
if (process.platform === 'win32') {
  userDataPath = path.join(userDataPath, '../../local/Netease/Rooms');
} else {
  userDataPath = path.join(userDataPath, '../Netease/Rooms');
}

if (!fs.existsSync(userDataPath)) {
  try {
    fs.mkdirSync(userDataPath, { recursive: true });
  } catch (err) {
    console.error(err);
  }
}
// const hasShownDialogPath = path.join(userDataPath, 'hasShow');

// 修改应用存储路径
app.setPath('userData', userDataPath);

// 定义日志目录名称
const cacheDirectoryName = 'logs';

// 构建日志目录路径
const logPath = path.join(userDataPath, cacheDirectoryName);

const agentPath = path.join(
  app.getPath('home'),
  './Library/LaunchAgents/com.netease.nmc.rooms.agent.plist',
);

// 创建日志文件夹
if (!fs.existsSync(logPath)) {
  fs.mkdirSync(logPath);
}
log.transports.file.resolvePathFn = (variables) =>
  path.join(logPath, 'app', variables.fileName);

let neRoomObjectMap = {};

function getRoomContext() {
  const roomContext = neRoomObjectMap['neroom-roomService-getRoomContext'];
  if (roomContext && roomContext.isInitialize) {
    return roomContext;
  }
}

function restartApp() {
  try {
    mainWindow.webContents.session.flushStorageData();
  } catch {}
  const neroom = neRoomObjectMap['neroom'];
  if (neroom.isInitialized) {
    neroom.release();
  }
  exec(`launchctl unload ${agentPath}`);
  app.relaunch();
  app.exit(0);
}

function initNERoom() {
  function handleReturnValue(value, target) {
    function fnFormat(value) {
      const obj = {};
      for (const key in value) {
        const element = value[key];
        if (typeof element === 'function') {
          obj[key] = '__FUNCTION__';
        } else if (typeof element === 'object') {
          obj[key] = fnFormat(element);
        } else {
          obj[key] = value[key];
        }
      }
      return obj;
    }
    if (value instanceof Array) {
      neRoomObjectMap[target] = value;
      return value.map((item) => fnFormat(item));
    }
    if (typeof value === 'object') {
      neRoomObjectMap[target] = value;
      return fnFormat(value);
    } else {
      return value;
    }
  }

  ipcMain.on('NERoomNodeProxyInit', (event) => {
    const neroom = neRoomObjectMap['neroom'] || new NERoom();
    event.returnValue = handleReturnValue(neroom, 'neroom');
  });

  ipcMain.on('NERoomNodeProxyMethod', (event, data) => {
    const { target, key, args, isPromise } = data;
    const targetObj = neRoomObjectMap[target];
    const noInitializeNeRoom =
      target.startsWith('neroom-') && !neRoomObjectMap['neroom']?.isInitialized;
    const noInitializeRoomContext =
      target.startsWith('neroom-roomService-getRoomContext') &&
      !getRoomContext();
    if (!targetObj || noInitializeRoomContext || noInitializeNeRoom) {
      event.returnValue = {
        value: null,
      };
      return;
    }
    args.forEach((arg, index) => {
      if (arg instanceof Array) {
        // 传递的是函数
      } else if (typeof arg === 'object') {
        const obj = {};
        for (const key in arg) {
          const element = arg[key];
          if (element === '__LISTENER_FUNCTION__') {
            obj[key] = (...args) => {
              event.sender.send(
                `NERoomNodeListenerProxy-${target}-${key}`,
                args,
              );
            };
          } else {
            obj[key] = element;
          }
        }
        args[index] = obj;
      }
    });
    if (
      key === 'setupRemoteVideoCanvas' ||
      key === 'setupLocalVideoCanvas' ||
      key === 'setupRemoteVideoSubStreamCanvas'
    ) {
      event.returnValue = {
        value: 0,
      };
      return;
    }
    if (target === 'neroom' && key === 'initialize') {
      args[0].logPath = logPath;
    }

    const res = targetObj[key].apply(targetObj, args);

    if (target === 'neroom' && key === 'release') {
      neRoomObjectMap = {
        neroom: new NERoom(),
      };
    }

    if (res instanceof Promise) {
      res
        .then((data) => {
          if (!isPromise) {
            event.returnValue = {
              promise: 'resolve',
              value: data,
            };
          } else {
            event.sender.send(`NERoomNodePromiseProxyReply-${target}-${key}`, {
              promise: 'resolve',
              value: data,
            });
          }
        })
        .catch((err) => {
          if (!isPromise) {
            event.returnValue = {
              promise: 'reject',
              value: err,
            };
          } else {
            event.sender.send(`NERoomNodePromiseProxyReply-${target}-${key}`, {
              promise: 'reject',
              value: err,
            });
          }
        });
    } else {
      const value = handleReturnValue(res, `${target}-${key}`);
      event.returnValue = { value };
    }
  });

  ipcMain.on('NERoomNodeProxyProperty', (event, data) => {
    const { target, key } = data;
    const targetObj = neRoomObjectMap[target];
    const noInitializeNeRoom =
      target.startsWith('neroom-') && !neRoomObjectMap['neroom']?.isInitialized;
    const noInitializeRoomContext =
      target.startsWith('neroom-roomService-getRoomContext') &&
      !getRoomContext();
    if (!targetObj || noInitializeRoomContext || noInitializeNeRoom) {
      event.returnValue = {
        value: null,
      };
      return;
    }
    const value = handleReturnValue(targetObj[key], `${target}-${key}`);
    event.returnValue = { value };
  });

  ipcMain.on('nemeeting-video-card-open', (_, data) => {
    const { uuid, type } = data;
    const key = `${uuid}-${type}`;
    let videoObj = videoWindows.find((item) => item.key === key);
    if (!videoObj) {
      videoObj = videoWindows.find((item) => item.key === '');
    }
    /*
    if (!videoObj) {
      videoObj = videoWindows.find((item) => item.closeMarker);
    }
    */
    if (!videoObj) {
      const window = new BrowserWindow({
        titleBarStyle: 'hidden',
        closable: false,
        roundedCorners: false,
        backgroundColor: '#000000',
        hasShadow: false,
        focusable: false,
        fullscreen: false,
        webPreferences: {
          offscreen: true,
        },
      });
      window.setIgnoreMouseEvents(true);
      window.setWindowButtonVisibility(false);
      videoObj = {
        key,
        window,
        position: data.position,
        isMySelf: data.isMySelf,
        closeMarker: false,
      };
      videoWindows.push(videoObj);
    } else {
      videoObj.closeMarker = false;
      videoObj.position = data.position;
      videoObj.key = key;
      videoObj.isMySelf = data.isMySelf;
    }
    const { window, position, isMySelf } = videoObj;
    if (position.width === 0 || position.height === 0) {
      window.setParentWindow(null);
      window.hide();
      return;
    }
    const rtcController = getRoomContext()?.rtcController;
    if (isMySelf) {
      localWindowHandle = window.getNativeWindowHandle();
      rtcController?.setupLocalVideoCanvas(localWindowHandle, localMirror);
    } else {
      if (type === 'video') {
        if (window.isDestroyed()) return;
        rtcController?.setupRemoteVideoCanvas(
          window.getNativeWindowHandle(),
          uuid,
        );
      } else if (type === 'screen') {
        rtcController?.setupRemoteVideoSubStreamCanvas(
          window.getNativeWindowHandle(),
          uuid,
        );
      }
    }
    const [main_x, main_y] = mainWindow.getPosition();
    window.setBounds({
      x: Math.round(main_x + position.x + 1),
      y: Math.round(main_y + position.y + 1),
      width: position.width - 2,
      height: position.height - 2,
    });
    window.setParentWindow(parentWindow);
    window.show();
    mainWindow.moveTop();
  });

  let videoCardCloseTimer = null;

  ipcMain.on('nemeeting-video-card-close', (_, data) => {
    const { uuid, type } = data;
    const key = `${uuid}-${type}`;
    const videoObj = videoWindows.find((item) => item.key === key);
    if (videoObj) {
      videoObj.closeMarker = true;
    }
    videoCardCloseTimer && clearTimeout(videoCardCloseTimer);
    videoCardCloseTimer = setTimeout(() => {
      videoWindows.forEach((videoObj) => {
        if (videoObj.closeMarker) {
          videoObj.window.setParentWindow(null);
          videoObj.window.hide();
          videoObj.key = '';
          if (videoObj.isMySelf) {
            localWindowHandle = null;
          }
        }
      });
    }, 100);
  });

  ipcMain.on('startPreview', () => {
    const neroom = neRoomObjectMap['neroom'];
    const previewController = neroom.roomService.getPreviewRoomContext()
      .previewController;
    if (!videoPreviewWindow) {
      videoPreviewWindow = new BrowserWindow({
        titleBarStyle: 'hidden',
        closable: false,
        parent: parentWindow,
        roundedCorners: false,
        backgroundColor: '#000000',
        focusable: false,
        hasShadow: false,
        fullscreen: false,
        webPreferences: {
          offscreen: true,
        },
      });
      videoPreviewWindow.setIgnoreMouseEvents(true);
    }
    const { x, y, width, height } = mainWindow.getBounds();
    videoPreviewWindow.setBounds({
      x: Math.round(x + (width - width * 0.8) / 2),
      y: Math.round(y + (height - height * 0.8) / 2),
      width: Math.round(width * 0.8),
      height: Math.round(height * 0.8),
    });
    localWindowHandle = videoPreviewWindow.getNativeWindowHandle();
    previewController.setupLocalVideoCanvas(localWindowHandle, localMirror);
    previewController.startPreview();
  });
  ipcMain.on('stopPreview', (_, data) => {
    const neroom = neRoomObjectMap['neroom'];
    const previewController = neroom.roomService.getPreviewRoomContext()
      .previewController;
    previewController.stopPreview();
    if (videoPreviewWindow) {
      videoPreviewWindow.setParentWindow(null);
      videoPreviewWindow.destroy();
      videoPreviewWindow = null;
      localWindowHandle = null;
    }
  });
}

initNERoom();

function createAuthorizationWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  authorizationWindow = new BrowserWindow({
    width: 636,
    height: 573,
    x: Math.round(width / 2 - 636 / 2),
    y: Math.round(height / 2 - 545 / 2),
    resizable: false,
    title: '网易会议 Rooms',
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      enableRemoteModule: true,
      preload: path.join(__dirname, './preload.js'),
    },
  });
  if (isLocal) {
    authorizationWindow.loadURL(`https://localhost:8000/#/authorization`);
    authorizationWindow.webContents.openDevTools();
  } else {
    authorizationWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'authorization',
    });
    // authorizationWindow.webContents.openDevTools();
  }
  // fs.writeFile(hasShownDialogPath, 'true', (error) => {
  //   if (error) {
  //     console.log('Error writing hasShownDialog:', error);
  //   }
  // });
}

function createWindow() {
  // Create the browser window.
  if (!parentWindow) {
    parentWindow = new BrowserWindow({
      width: 0,
      height: 0,
      trafficLightPosition: {
        x: 10,
        y: 7,
      },
      titleBarStyle: 'hidden',
      resizable: false,
      minimizable: false,
      hasShadow: false,
      simpleFullscreen: true,
      roundedCorners: false,
      autoHideMenuBar: true,
      hiddenInMissionControl: true,
      title: '网易会议 Rooms',
      backgroundColor: '#000000',
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        preload: path.join(__dirname, './ipc.js'),
      },
    });
    parentWindow.setWindowButtonVisibility(false);
  }

  if (!mainWindow) {
    mainWindow = new BrowserWindow({
      parent: parentWindow,
      titleBarStyle: 'hidden',
      transparent: true,
      resizable: false,
      minimizable: false,
      hasShadow: false,
      fullscreen: true,
      simpleFullscreen: true,
      autoHideMenuBar: true,
      hiddenInMissionControl: true,
      title: '网易会议 Rooms',

      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        enableRemoteModule: true,
        preload: path.join(__dirname, './preload.js'),
      },
    });
    mainWindow.setWindowButtonVisibility(false);
  }

  if (isLocal) {
    mainWindow.loadURL(`https://localhost:8000/#/rooms`);
    mainWindow.webContents.openDevTools();
    parentWindow.loadURL('https://localhost:8000/#/parent');
  } else {
    mainWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'rooms',
    });
    parentWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'parent',
    });
  }
  parentWindow.on('close', () => {
    try {
      mainWindow.webContents.session.flushStorageData();
    } catch {}
    const neroom = neRoomObjectMap['neroom'];
    if (neroom.isInitialized) {
      neroom.release();
    }
    app.exit(0);
  });

  parentWindow.setBounds(mainWindow.getBounds());
}

if (isLocal) {
  app.commandLine.appendSwitch('ignore-certificate-errors');
}

// 每周六凌晨1点定时重启
schedule.scheduleJob('0 1 * * 6', function () {
  // schedule.scheduleJob('44 10 * * 4', function() {
  // 如果此时在会中则不重启
  if (!inMeeting) {
    restartApp();
  }
});

app.whenReady().then(() => {
  // 判断之前是否已经显示过权限弹窗
  // let hasShownDialog = false;
  // try {
  //   hasShownDialog = fs.readFileSync(hasShownDialogPath, 'utf-8') === 'true';
  // } catch (error) {
  //   console.log('Error reading hasShownDialog:');
  // }

  const neverAskMicAndCameraAccess =
    systemPreferences.getMediaAccessStatus('microphone') === 'not-determined' &&
    systemPreferences.getMediaAccessStatus('camera') === 'not-determined';

  // 没有询问过，创建权限询问窗口
  if (neverAskMicAndCameraAccess) {
    createAuthorizationWindow();
  } else {
    createWindow();
    parentWindow.setAlwaysOnTop(true, 'screen-saver');
    mainWindow.setAlwaysOnTop(true, 'screen-saver');
  }

  app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });

  ipcMain.handle('get-local-update-info', () => {
    const currentVersion = app.getVersion();
    return {
      versionName: currentVersion,
      versionCode: getVersionCode(currentVersion),
      platform: process.platform,
    };
  });
  ipcMain.handle('get-check-update-info', () => {
    const currentVersion = app.getVersion();
    return {
      versionCode: getVersionCode(currentVersion),
      clientAppCode: 2,
      // accountId: '',
      framework: 'Electron-native',
      osVer: os_ver,
      buildVersion: '',
    };
  });
  ipcMain.handle('decode-base64', (event, valStr) => {
    return valStr ? Buffer.from(valStr, 'base64').toString() : '';
  });
  ipcMain.handle('semver-lt', (event, { newVersion }) => {
    return semver.lt(app.getVersion(), newVersion);
  });
  ipcMain.handle('check-update', (event, { url, md5, forceUpdate }) => {
    // 判断当前版本是否大于需要下载版本, 如果大于则不做处理
    // if (semver.gt(currentVersion, '0.0.0')) {
    //   return;
    // }
    // downloadUrl = 'https://yx-web-nosdn.netease.im/package/rooms-electron.zip';
    const neroom = neRoomObjectMap['neroom'];
    checkMacUpdate(
      mainWindow,
      url,
      md5,
      neroom,
      `${app.name}/rooms`,
      forceUpdate,
    );
    return true;
  });
  // 权限弹窗
  ipcMain.on('askForMediaAccess', async (event, type) => {
    const micPrivilege = systemPreferences.getMediaAccessStatus(type);
    if (micPrivilege == 'not-determined') {
      await systemPreferences.askForMediaAccess(type);
    } else if (micPrivilege == 'denied') {
      const typeMap = {
        camera: {
          title: '摄像头',
          url:
            'x-apple.systempreferences:com.apple.preference.security?Privacy_Camera',
        },
        microphone: {
          title: '麦克风',
          url:
            'x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone',
        },
      };
      // 创建弹出窗口
      dialog
        .showMessageBox({
          type: 'warning',
          message: `请在“系统偏好设置”的“安全性与隐私”中允许“网易会议 rooms“使用${typeMap[type].title}`,
          buttons: ['打开系统偏好设置', '取消'],
          defaultId: 0,
          cancelId: 1,
        })
        .then((response) => {
          if (response.response === 0) {
            // 如果用户单击“打开系统设置”按钮，则打开系统设置页面
            shell.openExternal(typeMap[type].url);
          }
        });
    }
  });

  ipcMain.on('askForMediaAccessOnInit', async (event, type) => {
    try {
      const micPrivilege = systemPreferences.getMediaAccessStatus(type);
      if (micPrivilege == 'not-determined') {
        await systemPreferences.askForMediaAccess(type);
      }
    } catch (error) {
      console.log('========error=======', error);
    }
  });

  ipcMain.handle('getDeviceAccessStatus', (event) => {
    return {
      camera: systemPreferences.getMediaAccessStatus('camera'),
      microphone: systemPreferences.getMediaAccessStatus('microphone'),
    };
  });

  ipcMain.handle('get-theme-color', () => true);

  ipcMain.on('jump-authorization', () => {
    createWindow();
    parentWindow.setAlwaysOnTop(true, 'screen-saver');
    mainWindow.setAlwaysOnTop(true, 'screen-saver');
    authorizationWindow.close();
  });

  ipcMain.on('beforeEnterRoom', () => {
    inMeeting = false;
    const neroom = neRoomObjectMap['neroom'];
    const previewController = neroom.roomService.getPreviewRoomContext()
      .previewController;
    previewController.setupLocalVideoCanvas(Buffer.from([]), localMirror);
    /*
    videoWindows.forEach((item) => {
      const { window } = item;
      window.destroy();
    });
    videoWindows.splice(0, videoWindows.length);
    */
  });

  ipcMain.on('enterRoom', () => {
    parentWindow.setBounds(mainWindow.getBounds());
    inMeeting = true;
  });

  ipcMain.on('videoMirrorChange', (_, data) => {
    const { mirror } = data;
    localMirror = mirror;
    if (localWindowHandle) {
      const neroom = neRoomObjectMap['neroom'];
      const previewController = neroom.roomService.getPreviewRoomContext()
        .previewController;
      previewController.setupLocalVideoCanvas(localWindowHandle, localMirror);
    }
  });

  fs.copyFile(
    path.join(__dirname, './com.netease.nmc.rooms.agent.plist'),
    agentPath,
    () => {
      !isLocal && exec(`launchctl load ${agentPath}`);
    },
  );

  ipcMain.on('flushStorageData', () => {
    try {
      mainWindow.webContents.session.flushStorageData();
    } catch {}
  });

  ipcMain.on('exitApp', () => {
    try {
      mainWindow.webContents.session.flushStorageData();
    } catch {}
    const neroom = neRoomObjectMap['neroom'];
    if (neroom.isInitialized) {
      neroom.release();
    }
    exec(`launchctl unload ${agentPath}`);
    app.exit(0);
  });

  let restartAppDebounce = false;
  ipcMain.on('restartApp', () => {
    // 防止重复点击
    if (restartAppDebounce) return;
    restartAppDebounce = true;
    restartApp();
  });
  ipcMain.handle('get-system-info', async (event) => {
    return getSystemInfo();
  });
});

const id = powerSaveBlocker.start('prevent-display-sleep');

// 在应用程序退出时，需要停止 powerSaveBlocker 对象
app.on('will-quit', () => {
  try {
    mainWindow.webContents.session.flushStorageData();
  } catch {}
  powerSaveBlocker.stop(id);
});

function getSystemInfo() {
  return si
    .system()
    .then((data) => {
      const serial = data.serial;
      return { serial };
    })
    .catch((error) => {
      console.error(error);
    });
}
