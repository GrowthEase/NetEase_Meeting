const {
  app,
  BrowserWindow,
  screen,
  ipcMain,
  desktopCapturer,
  systemPreferences,
  shell,
  globalShortcut,
  dialog,
  Menu,
  nativeTheme,
  crashReporter,
  powerSaveBlocker,
} = require('electron');
const log = require('electron-log/main');
const { initUpdateListener } = require('./utils/update');
const { getLogDate } = require('./utils/log');
const { promisify } = require('util');
const path = require('path');
const fs = require('fs');
const os = require('os');
const si = require('systeminformation');
const { exec } = require('child_process');
const {
  sharingScreen,
  closeScreenSharingWindow,
  addScreenSharingIpc,
} = require('./sharingScreen');
const {
  createBeforeMeetingWindow,
  beforeNewWins,
} = require('./beforeMeetingWindow');

const { initMonitoring } = require('./utils/monitoring');

initMonitoring();

const readFileAsync = promisify(fs.readFile);
const readDirAsync = promisify(fs.readdir);
// 窗口数量
app.commandLine.appendSwitch('--max-active-webgl-contexts', 1000);

const os_ver = os.release();
let virtualBackgroundList = [];

const isWin32 = process.platform === 'win32';
let userDataPath = app.getPath('userData');
// Windows直接用userPath还不行，要将路径改到local下
if (process.platform === 'win32') {
  userDataPath = path.join(userDataPath, '../../local/Netease/Meeting');
} else {
  userDataPath = path.join(userDataPath, '../Netease/Meeting');
}
app.setPath('userData', userDataPath);

if (!fs.existsSync(userDataPath)) {
  try {
    fs.mkdirSync(userDataPath, { recursive: true });
  } catch (err) {
    console.error(err);
  }
}
// 定义日志目录名称
const cacheDirectoryName = 'logs';

// 构建日志目录路径
const logPath = path.join(userDataPath, cacheDirectoryName);
log.initialize({ preload: true });
log.transports.console.format = '[{y}-{m}-{d} {h}:{i}:{s}.{ms}] {text}';
log.transports.file.maxSize = 1024 * 1024 * 10;
log.transports.file.fileName = `meeting_${getLogDate()}.log`;
log.errorHandler.startCatching();
log.eventLogger.startLogging();
log.transports.file.resolvePathFn = (variables) =>
  path.join(logPath, 'app', variables.fileName);
console.log = log.log;

app.setPath('crashDumps', path.join(logPath, 'app', 'crashDumps'));

crashReporter.start({
  uploadToServer: false,
});

// 处理 win SSO 登录，
if (isWin32) {
  const appLock = app.requestSingleInstanceLock();
  if (!appLock) {
    app.quit();
  }
}
const { downloadFileByUrl } = require('./utils');

const isLocal = process.env.MODE === 'local';

const agreement = 'nemeeting'; // 自定义协议名

const AGREEMENT_REGEXP = new RegExp(`^${agreement}://`);

const MEETING_HEADER_HEIGHT = isWin32 ? 31 : 28;

const MINI_WIDTH = 1150;
const MINI_HEIGHT = 690;

let beforeMeetingWindow;
let mainWindow;
let settingWindow;
let inMeeting = false;
let inWaitingRoom = false;
let alreadySetWidth = false;
let previewRoomListener = null;
let isOpenSettingWindow = false;
let powerSaveBlockerId = null;
let isOpenSettingDialog = false;
let inviteUrl = '';

const newWins = {};

//  创建日志文件夹
if (!fs.existsSync(logPath)) {
  fs.mkdirSync(logPath);
}

async function getVirtualBackground(forceUpdate = false, event) {
  if (
    virtualBackgroundList &&
    virtualBackgroundList.length > 0 &&
    !forceUpdate
  ) {
    return virtualBackgroundList;
  }
  virtualBackgroundList = [];
  const virtualBackgroundDirPath = path.join(userDataPath, 'virtualBackground');
  if (!fs.existsSync(virtualBackgroundDirPath)) {
    fs.mkdirSync(virtualBackgroundDirPath);
  }
  fs.readdirSync(virtualBackgroundDirPath).map((item) => {
    const filePath = path.join(virtualBackgroundDirPath, item);
    const isDefault = path.basename(filePath).includes('default');
    if (isDefault) {
      fs.unlinkSync(filePath);
    }
  });
  //  拷贝默认资源到用户目录
  const defaultVirtualBackgroundPath = path.join(
    __dirname,
    './assets/virtual/',
  );
  fs.readdirSync(defaultVirtualBackgroundPath).forEach((item) => {
    const filePath = path.join(defaultVirtualBackgroundPath, item);
    fs.copyFileSync(filePath, path.join(virtualBackgroundDirPath, item));
  });
  // const virtualBackgroundList = []
  let virtualBackgroundFileList = await readDirAsync(virtualBackgroundDirPath);
  virtualBackgroundFileList = virtualBackgroundFileList.filter((item) => {
    return ['.png', '.jpg', '.jpeg'].includes(path.extname(item));
  });
  for (let i = 0; i < virtualBackgroundFileList.length; i++) {
    const item = virtualBackgroundFileList[i];
    const filePath = path.join(virtualBackgroundDirPath, item);
    const isDefault = path.basename(filePath).includes('default');
    const base64Prefix = `data:image/${path
      .extname(filePath)
      .substring(1)};base64,`;
    const data = await readFileAsync(filePath, 'base64');
    base64Image = base64Prefix + data;
    virtualBackgroundList.push({
      src: base64Image,
      path: filePath,
      isDefault,
    });
  }
  event?.sender.send(
    'nemeeting-beauty-virtual-background',
    virtualBackgroundList,
  );
  return virtualBackgroundList;
}

function setExcludeWindowList() {
  mainWindow.webContents.send('setExcludeWindowList', [
    [...Object.values(newWins), mainWindow]
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

    const mainWindowPosition = mainWindow.getPosition();
    // 通过位置信息获取对应的屏幕
    const currentScreen = screen.getDisplayNearestPoint({
      x: mainWindowPosition[0],
      y: mainWindowPosition[1],
    });
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
  }
  if (url.includes('notification/card')) {
    newWin.setWindowButtonVisibility?.(false);
    // 获取主窗口的位置信息
    const mainWindowPosition = mainWindow.getPosition();
    // 通过位置信息获取对应的屏幕
    const currentScreen = screen.getDisplayNearestPoint({
      x: mainWindowPosition[0],
      y: mainWindowPosition[1],
    });
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
  }
}

function createWindow(data) {
  console.log('createWindow>>>>>>>>>', data);
  // Create the browser window.
  const mousePosition = screen.getCursorScreenPoint();
  const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
  const { x, y, width, height } = nowDisplay.workArea;
  // if (!mainWindow) {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.destroy();
  }
  // 打开成员列表或者聊天室窗口宽度变宽
  const ext_w_h = isWin32 ? 8 : 0;
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
      // nodeIntegrationInWorker: true,
      preload: path.join(__dirname, './preload.js'),
    },
  });

  mainWindow.on('maximize', () => {
    mainWindow?.webContents.send('maximize-window', true);
  });
  mainWindow.on('unmaximize', () => {
    mainWindow?.webContents.send('maximize-window', false);
  });
  mainWindow.webContents.session.removeAllListeners('will-download');
  mainWindow.webContents.session.on('will-download', (event, item) => {
    item.on('done', (event, state) => {
      if (state === 'completed') {
        console.log('mainWindow will-download');
        // 文件下载完成，打开文件所在路径
        const path = event.sender.getSavePath();
        shell.showItemInFolder(path);
      }
    });
  });
  // }

  const { joinType, meetingNum, password, openCamera, openMic, nickName } =
    data;
  if (isLocal) {
    const keys = Object.keys(data);
    // 对象的key value转换成 url的query参数
    const query = keys
      .map((key) => {
        return `${key}=${data[key] || ''}`;
      })
      .join('&');
    mainWindow.loadURL(`http://localhost:8000/#/meeting?${query}`);

    // Open the DevTools.
    mainWindow.webContents.openDevTools();
  } else {
    mainWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'meeting',
      query: {
        ...data,
      },
    });
  }

  setThemeColor();

  addScreenSharingIpc({
    mainWindow,
    initMainWindowSize,
  });

  mainWindow.on('close', function (event) {
    if (inMeeting) {
      event.preventDefault();
      mainWindow?.webContents.send('main-close-before');
    }
  });

  mainWindow.webContents.on(
    'did-create-window',
    (newWin, { url: originalUrl }) => {
      const url = originalUrl.replace(/.*?(?=#)/, '');
      newWins[url] = newWin;
      // 通过 openWindow 打开的窗口，需要在关闭时通知主窗口
      newWin.on('close', (event) => {
        mainWindow.webContents.send(`windowClosed:${url}`);
        if (url.includes('setting')) {
          mainWindow?.webContents.send('previewController', {
            method: 'stopPreview',
            args: [],
          });
        }
        // 通过隐藏处理关闭，关闭有一定概率崩溃
        newWin.hide();
        event.preventDefault();
      });
      openNewWindow(url);

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

      setExcludeWindowList();
      if (isLocal) {
        newWin.webContents.openDevTools();
      }
    },
  );

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
        preload: path.join(__dirname, './ipc.js'),
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
          height: 680,
          trafficLightPosition: {
            x: 10,
            y: 13,
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
    }
    return { action: 'deny' };
  });

  mainWindow.on('leave-full-screen', () => {
    mainWindow.setTitle('网易会议');
  });
  mainWindow.on('enter-full-screen', () => {
    mainWindow.setTitle('');
  });

  initMainWindowSize();
}

function closeSettingWindowHandle(type) {
  isOpenSettingWindow = false;
  settingWindow?.webContents.send('showSettingWindow', {
    isShow: false,
    type,
    inMeeting,
  });
  // ipcMain.removeAllListeners('nemeeting-beauty');

  if (
    isOpenSettingDialog &&
    settingWindow &&
    !settingWindow.isDestroyed() &&
    isWin32
  ) {
    const robot = require('robotjs');
    robot.keyTap('escape');
  }
  mainWindow?.webContents.send('closeSetting');
  beforeMeetingWindow?.webContents.send('closeSetting');
  // if (!settingWindow?.isDestroyed()) {
  //   settingWindow?.destroy();
  //   settingWindow = null;
  // }
  // 需要一个延迟，否则页面逻辑将卡在最后隐藏时候，重新打开页面会残留上次卡主位置
  setTimeout(() => {
    // 需要判断当前窗口是否已经销毁，否则会报错
    if (settingWindow?.isDestroyed()) return;
    settingWindow?.hide();
  }, 50);
}
function createSettingWindow(type) {
  // 窗口存在且未销毁情况不需要重新创建
  // if (settingWindow && !settingWindow.isDestroyed()) {
  //   settingWindow.show();
  //   isOpenSettingWindow = true;
  //   settingWindow.webContents.send('showSettingWindow', {
  //     isShow: true,
  //     type,
  //     inMeeting: !inWaitingRoom && inMeeting,
  //   });
  //   settingWindow.moveAbove(
  //     inMeeting
  //       ? mainWindow?.getMediaSourceId()
  //       : beforeMeetingWindow?.getMediaSourceId(),
  //   );
  //   return;
  // }
  // if (!settingWindow) {
  //   settingWindow = new BrowserWindow({
  //     width: 800,
  //     height: 560,
  //     titleBarStyle: 'hidden',
  //     trafficLightPosition: {
  //       x: 10,
  //       y: 13,
  //     },
  //     maximizable: false,
  //     minimizable: false,
  //     resizable: false,
  //     fullscreen: false,
  //     alwaysOnTop: true,
  //     show: false,
  //     title: '设置',
  //     webPreferences: {
  //       contextIsolation: false,
  //       nodeIntegration: true,
  //       preload: path.join(__dirname, './preload.js'),
  //     },
  //   });
  // }
  // settingWindow.hide();
  // getVirtualBackground();
  ipcMain.on('nemeeting-beauty', async (event, data) => {
    const { value } = data;
    if (data.event === 'open') {
      // previewController.startBeauty();
      // previewController.enableBeauty(true);
      // !inMeeting && previewController.startPreview();
      // getVirtualBackground();
    } else if (data.event === 'effect') {
      console.log('openSetting>>>>>>>>>>>>>>', value);
      const { beautyType, level } = value;
      // previewController.setBeautyEffect(beautyType, level);
    } else if (data.event === 'virtualBackground') {
      const { path } = value;
      // previewController.enableVirtualBackground(!!path, path);
    } else if (data.event === 'addVirtualBackground') {
      const { dialog } = require('electron');
      isOpenSettingDialog = true;

      dialog
        .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
          properties: ['openFile'],
          filters: [{ name: 'image', extensions: ['jpg', 'png', 'jpeg'] }],
        })
        .then(function (response) {
          if (!response.canceled) {
            // handle fully qualified file name
            const filePath = response.filePaths[0];
            const userVirtualBackgroundPath = path.join(
              userDataPath,
              'virtualBackground',
            );
            const toPath = path.join(
              userVirtualBackgroundPath,
              `user-${Date.now()}${path.extname(filePath)}`,
            );
            fs.copyFileSync(filePath, toPath);
            // previewController.enableVirtualBackground(true, toPath);
            getVirtualBackground(true, event);
            event.sender.send('addVirtualBackground-reply', toPath);
          } else {
            event.sender.send('addVirtualBackground-reply', '');
            console.log('no file selected');
          }
        })
        .finally(() => {
          isOpenSettingDialog = false;
        });
    } else if (data.event === 'removeVirtualBackground') {
      const { path } = value;
      try {
        fs.unlinkSync(path);
        getVirtualBackground(true, event);
      } catch (e) {
        console.log('removeVirtualBackground error', e);
      }
    } else if (data.event === 'close') {
      const { mirror } = value;
    }
  });
}

function dealLoginSuccess(url) {
  beforeMeetingWindow?.webContents.send('electron-login-success', url);
  mainWindow?.focus();
}

// 注册自定义协议
function setDefaultProtocol() {
  let isSet = false; // 是否注册成功
  app.removeAsDefaultProtocolClient(agreement); // 每次运行都删除自定义协议 然后再重新注册
  // 开发模式下在window运行需要做兼容
  if (process.env.NODE_ENV === 'development' && process.platform === 'win32') {
    // 设置electron.exe 和 app的路径
    isSet = app.setAsDefaultProtocolClient(agreement, process.execPath, [
      path.resolve(process.argv[1]),
    ]);
  } else {
    isSet = app.setAsDefaultProtocolClient(agreement);
  }
}
function handleUrl(url) {
  const isInviteUrl = url.includes('invitation');
  if (isInviteUrl) {
    if (inMeeting) {
      mainWindow?.show();
      mainWindow?.focus();
      mainWindow?.webContents.send('already-in-meeting');
    } else {
      // 从url启动应用，这个时候beforeMeetingWindow还没有创建需要缓存url
      if (!beforeMeetingWindow && !isWin32) {
        inviteUrl = url;
      } else {
        beforeMeetingWindow?.show();
        beforeMeetingWindow?.focus();
        beforeMeetingWindow?.webContents.send('electron-join-meeting', url);
      }
    }
  } else {
    dealLoginSuccess(url);
  }
}
// 初始化监听自定义协议唤起
function watchProtocol() {
  // mac唤醒应用 会激活open-url事件 在open-url中判断是否为自定义协议打开事件
  // TODO：未启动应用情况下，通过链接唤起应用入会
  app.on('open-url', (event, url) => {
    const isProtocol = AGREEMENT_REGEXP.test(url);
    console.log('mac 自定义协议被唤起', url);
    if (isProtocol) {
      handleUrl(url);
    }
  });
  // window系统下唤醒应用会激活second-instance事件 它在ready执行之后才能被监听
  app.on('second-instance', (event, commandLine) => {
    console.log('second-instance', commandLine);
    // commandLine是一个数组，唤醒的链接作为数组的一个元素放在这里面
    commandLine.forEach((str) => {
      if (AGREEMENT_REGEXP.test(str)) {
        console.log('windows 自定义协议被唤起', str);
        handleUrl(str);
      }
    });
  });
}

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

// 设置主题色
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

function getThemeColor() {
  return nativeTheme.shouldUseDarkColors ?? true;
}

function getSystemAndManufacturer() {
  return si
    .system()
    .then((data) => {
      const manufacturer = data.manufacturer;
      const model = data.model;
      return { manufacturer, model, os_ver };
    })
    .catch((error) => {
      console.error(error);
    });
}

if (isLocal) {
  app.commandLine.appendSwitch('ignore-certificate-errors');
}
// 在ready事件回调之前监听自定义协议唤起
watchProtocol();

app.whenReady().then(() => {
  beforeMeetingWindow = createBeforeMeetingWindow();

  initUpdateListener(beforeMeetingWindow, {}, `${app.name}/rooms`);

  app.on('render-process-gone', (event, webContents, details) => {
    if (webContents.id && !beforeMeetingWindow?.isDestroyed()) {
      // 会中窗口崩溃了
      if (webContents.id === mainWindow?.webContents.id) {
        if (mainWindow && !mainWindow.isDestroyed()) {
          inMeeting = false;
          mainWindow.destroy();
          mainWindow = null;
          closeScreenSharingWindow();
        }
        beforeMeetingWindow?.show();
        // 会前页面崩溃
      } else if (webContents.id == beforeMeetingWindow?.webContents.id) {
        beforeMeetingWindow?.reload();
      }
    }
  });

  // 通过 openWindow 打开的窗口，focusWindow 前置窗口
  ipcMain.on('focusWindow', (_, url) => {
    if (inMeeting) {
      if (newWins[url] && !newWins[url].isDestroyed()) {
        newWins[url].show();
      }
      openNewWindow(url);
      setExcludeWindowList();
    } else {
      if (beforeNewWins[url] && !beforeNewWins[url].isDestroyed()) {
        beforeNewWins[url].show();
      }
    }
  });

  ipcMain.handle('saveAvatarToPath', async (event, base64String) => {
    const base64Data = base64String.replace(/^data:image\/\w+;base64,/, '');
    const imageCacheDirPath = path.join(userDataPath, 'imageCache');
    if (!fs.existsSync(imageCacheDirPath)) {
      fs.mkdirSync(imageCacheDirPath);
    }
    const filePath = path.join(imageCacheDirPath, 'avatar.png');

    try {
      await fs.promises.writeFile(filePath, base64Data, 'base64');
      return { status: 'success', filePath };
    } catch (error) {
      console.error('Error saving image:', error);
      return { status: 'error', message: error.message };
    }
  });

  ipcMain.on('relaunch', () => {
    app.relaunch();
    app.exit(0);
  });
  ipcMain.on('maximize-window', () => {
    mainWindow.isMaximized() ? mainWindow.unmaximize() : mainWindow.maximize();
  });

  ipcMain.on('minimize-window', () => {
    // mainWindow.isMaximized() ? mainWindow.unmaximize() : mainWindow.maximize();
    if (inMeeting) {
      mainWindow?.minimize();
    }
  });

  // 打开侧边抽屉，显示成员列表或者聊天室等
  ipcMain.on('openChatroomOrMemberList', (event, isOpen) => {
    if (!mainWindow) {
      return;
    }
    if (isOpen) {
      mainWindow.setMinimumSize(MINI_WIDTH + 320, MINI_HEIGHT);
    } else {
      mainWindow.setMinimumSize(MINI_WIDTH, MINI_HEIGHT);
    }

    mainWindow?.webContents.send('openChatroomOrMemberList-reply', isOpen);
    // resize结束通知渲染进程
    if (mainWindow?.isFullScreen() || mainWindow?.isMaximized()) {
      return;
    }
    const mousePosition = screen.getCursorScreenPoint();
    const { x: displayX, width: displayW } =
      screen.getDisplayNearestPoint(mousePosition).workArea; // 鼠标所在屏幕的大小
    const { x: mainX, width: mainW } = mainWindow.getBounds(); // 当前窗口的大小
    if (isOpen && !alreadySetWidth) {
      alreadySetWidth = true;
      let newWidth = mainW + 320;
      const exceedW = newWidth + mainX - (displayX + displayW);
      if (exceedW > 0) {
        mainWindow.setBounds({
          x: Math.round(mainX - exceedW),
          width: Math.round(newWidth),
        });
      } else {
        mainWindow.setBounds({
          width: Math.round(newWidth),
        });
      }
    } else if (!isOpen && alreadySetWidth) {
      alreadySetWidth = false;
      // fix退出会议后宽度为375-320的问题
      mainWindow.setBounds({ width: Math.round(mainW - 320) });
    }
    // resize结束通知渲染进程
    event.sender.send('openChatroomOrMemberList-reply');
  });

  ipcMain.handle('exit-app', () => {
    app.exit(0);
  });
  ipcMain.handle('getLogPath', (event) => {
    return logPath;
  });

  ipcMain.handle('getDeviceAccessStatus', (event) => {
    return {
      camera: systemPreferences.getMediaAccessStatus('camera'),
      microphone: systemPreferences.getMediaAccessStatus('microphone'),
    };
  });

  // previewController 代理到mainWindow, data: {method: string, args: any[]}
  ipcMain.on('previewController', (event, data) => {
    if (inMeeting) {
      if (mainWindow?.isDestroyed()) return;
      mainWindow?.webContents.send('previewController', data);
    } else {
      if (beforeMeetingWindow?.isDestroyed()) return;
      beforeMeetingWindow?.webContents.send('previewController', data);
    }
  });

  ipcMain.on('previewControllerListener', (event, data) => {
    const { method, args } = data;
    if (!settingWindow?.isDestroyed() && isOpenSettingWindow) {
      settingWindow?.webContents.send(method, ...args);
    }
  });

  ipcMain.on('no-permission', () => {
    const command = 'open "x-apple.systempreferences:"';
    exec(command, (error) => {
      if (error) {
        console.error(`打开系统偏好设置时出错： ${error}`);
      }
    });
  });
  ipcMain.handle('get-system-manufacturer', () => {
    return getSystemAndManufacturer();
  });
  ipcMain.handle('download-file-by-url', (_, url) => {
    downloadFileByUrl(url);
    return true;
  });

  ipcMain.handle('get-theme-color', () => {
    return getThemeColor();
  });

  ipcMain.on('set-meeting-nps', (event, meetingId) => {
    beforeMeetingWindow?.webContents.send('set-meeting-nps', meetingId);
  });

  ipcMain.on('need-open-meeting-nps', () => {
    beforeMeetingWindow?.webContents.send('need-open-meeting-nps');
  });

  if (isWin32) {
    ipcMain.on('minimize-window', () => {
      if (!inMeeting) {
        beforeMeetingWindow?.minimize();
      }
    });
  }

  setDefaultProtocol();

  beforeMeetingWindow.on('focus', () => {
    globalShortcut.register('f5', function () {
      console.log('f5 is pressed');
      //mainWindow.reload()
    });
    globalShortcut.register('CommandOrControl+R', function () {
      console.log('CommandOrControl+R is pressed');
      //mainWindow.reload()
    });
  });

  beforeMeetingWindow?.on('close', function (event) {
    if (inMeeting) {
      event.preventDefault();
    } else {
      app.exit(0);
    }
  });
  beforeMeetingWindow.on('blur', () => {
    globalShortcut.unregister('f5', function () {
      console.log('f5 is pressed');
      //mainWindow.reload()
    });
    globalShortcut.unregister('CommandOrControl+R', function () {
      console.log('CommandOrControl+R is pressed');
      //mainWindow.reload()
    });
  });
  // 获取虚拟背景图片列表
  ipcMain.handle('getVirtualBackground', (event, data) => {
    return getVirtualBackground();
  });

  ipcMain.on('isStartByUrl', () => {
    console.log('isStartByUrl', process.argv, inviteUrl);
    if (inviteUrl && !isWin32) {
      handleUrl(inviteUrl);
      inviteUrl = '';
    } else {
      // windows 启动参数超过1个才可能是通过url schema启动
      if (process.argv.length > 1) {
        app.emit('second-instance', null, process.argv);
      }
    }
  });

  app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) createBeforeMeeting();
  });

  app.on('before-quit', (event) => {
    // mac 程序坞直接右键退出会先走这里。如果是在会中直接退出
    if (inMeeting && !isWin32) {
      app.exit(0);
    }
  });

  ipcMain.on('nemeeting-download-path', (event, value) => {
    if (value === 'get') {
      event.returnValue = app.getPath('downloads');
    }
    if (value === 'set') {
      const { dialog } = require('electron');
      isOpenSettingDialog = true;
      dialog
        .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
          properties: ['openDirectory'],
        })
        .then(function (response) {
          if (!response.canceled) {
            // handle fully qualified file name
            const filePath = response.filePaths[0];
            event.sender.send('nemeeting-download-path-reply', filePath);
          } else {
            console.log('no file selected');
          }
        })
        .finally(() => {
          isOpenSettingDialog = false;
        });
    }
  });

  ipcMain.on('nemeeting-file-save-as', (event, value) => {
    const { dialog } = require('electron');
    const { defaultPath, filePath } = value;
    dialog
      .showSaveDialog(BrowserWindow.fromWebContents(event.sender), {
        defaultPath: defaultPath,
        filters: [{ name: '', extensions: '*' }],
      })
      .then(function (response) {
        let resFilePath = '';
        if (!response.canceled) {
          // handle fully qualified file name
          if (filePath && fs.existsSync(filePath)) {
            fs.copyFileSync(filePath, response.filePath);
          } else {
            resFilePath = response.filePath;
          }
        }
        event.sender.send('nemeeting-file-save-as-reply', resFilePath);
      })
      .catch((err) => {
        event.sender.send('nemeeting-file-save-as-reply', '');
      });
  });

  ipcMain.on('nemeeting-open-file', (event, value) => {
    const { isDir, filePath } = value;
    fs.exists(filePath, (exists) => {
      if (exists) {
        if (isDir) {
          shell.showItemInFolder(filePath);
        } else {
          shell.openPath(filePath);
        }
      }
      event.sender.send('nemeeting-open-file-reply', exists);
    });
  });

  ipcMain.on('nemeeting-choose-file', (event, value) => {
    const { type, extensions, extendedData } = value;

    dialog
      .showOpenDialog(BrowserWindow.fromWebContents(event.sender), {
        properties: ['openFile'],
        filters: [{ name: type, extensions: extensions }],
      })
      .then(function (response) {
        log.info('nemeeting-choose-file response', response);
        if (!response.canceled) {
          // handle fully qualified file name
          const filePath = response.filePaths[0];
          fs.stat(filePath, (err, stats) => {
            if (err) {
              console.error(err);
            } else {
              let base64Image = '';
              let width = 0;
              let height = 0;
              if (type === 'image') {
                const base64Prefix = `data:image/${path
                  .extname(filePath)
                  .substring(1)};base64,`;
                base64Image =
                  base64Prefix + fs.readFileSync(filePath, 'base64');
                const sizeOf = require('image-size');
                try {
                  const dimensions = sizeOf(filePath);
                  width = dimensions.width;
                  height = dimensions.height;
                } catch (e) {
                  console.error(e);
                }
              }

              event.sender.send('nemeeting-choose-file-done', {
                type,
                file: {
                  url: filePath,
                  name: path.basename(filePath),
                  size: stats.size,
                  base64: base64Image,
                  width,
                  height,
                },
                extendedData,
              });
            }
          });
        } else {
          console.log('no file selected');
        }
      })
      .catch((err) => {
        log.info('nemeeting-choose-file error', err);
      });
  });

  ipcMain.on('open-browser-window', (event, url) => {
    // 打开新浏览器窗口
    shell.openExternal(url);
  });

  ipcMain.on('get-sources', (event) => {
    desktopCapturer
      .getSources({
        types: ['screen', 'window'],
        thumbnailSize: { width: 160, height: 100 },
        fetchWindowIcons: true,
      })
      .then(async (sources) => {
        if (process.platform === 'darwin') {
          const screenPrivilege =
            systemPreferences.getMediaAccessStatus('screen');
          // 未授权的情况
          if (screenPrivilege !== 'granted') {
            dialog.showMessageBox({
              type: 'info',
              title: '开启屏幕录制权限',
              buttons: ['知道了'],
              detail:
                '由于 macOS 系统安全控制，开始共享屏幕之前需要先开启系统屏幕录制权限\n\n打开 系统偏好设置 > 安全与隐私 授予访问权限',
            });
            event.sender.send('get-sources-reply', []);
            return;
          }
        }
        event.sender.send('get-sources-reply', sources);
      });
  });

  ipcMain.on('quiteFullscreen', () => {
    mainWindow.isFullScreen() && mainWindow.setFullScreen(false);
  });

  ipcMain.on('flushStorageData', () => {
    // 强制缓存
    try {
      beforeMeetingWindow.webContents.session.flushStorageData();
    } catch {}
  });

  ipcMain.on('beforeLogin', () => {
    mainWindow?.destroy();
    mainWindow = null;
    inMeeting = false;
    // 退出登录，关闭会前的窗口
    Object.keys(beforeNewWins).forEach((key) => {
      beforeNewWins[key]?.close();
    });
  });

  ipcMain.on('inMeeting', () => {
    inMeeting = true;
    beforeMeetingWindow?.webContents.send('beforeMeeting', false);
  });

  ipcMain.on('beforeEnterRoom', () => {
    inMeeting = false;
    beforeMeetingWindow?.showInactive();
    beforeMeetingWindow?.webContents.send('beforeMeeting', true);
    mainWindow?.destroy();
    mainWindow = null;
    powerSaveBlockerId && powerSaveBlocker.stop(powerSaveBlockerId);
    powerSaveBlockerId = null;
    if (settingWindow) {
      closeSettingWindowHandle();
    }
    // 清理videoWindows
    closeScreenSharingWindow();

    // 强制缓存
    try {
      beforeMeetingWindow.webContents.session.flushStorageData();
    } catch {}
  });

  ipcMain.on('in-waiting-room', (event, isInWaitingRoom) => {
    // 等候室关闭，需要同步关闭设置页面
    if (!isInWaitingRoom) {
      closeSettingWindowHandle();
    } else {
      // 需要关闭共享
      if (sharingScreen.isSharing) {
        closeScreenSharingWindow();
      }
    }
    inWaitingRoom = isInWaitingRoom;
  });

  ipcMain.on('enterRoom', (event, data) => {
    if (!data) {
      return;
    }
    console.log('enterRoom>>>>>>>>>>>>>>');
    // inMeeting = true;
    alreadySetWidth = false;

    createWindow(data);

    // 阻止屏幕休眠
    powerSaveBlockerId = powerSaveBlocker.start('prevent-display-sleep');

    Object.keys(beforeNewWins).forEach((key) => {
      beforeNewWins[key]?.close();
    });

    if (settingWindow) {
      closeSettingWindowHandle();
    }
    beforeMeetingWindow?.webContents.send('join-meeting-loading', true);
    mainWindow.webContents.once('dom-ready', () => {
      beforeMeetingWindow?.webContents.send('join-meeting-loading', false);
      beforeMeetingWindow?.hide();
      mainWindow?.show();
    });

    if (isWin32) {
      mainWindow.setBackgroundColor('rgba(255, 255, 255,0)');
    }

    mainWindow.webContents.send(
      'set-theme-color',
      nativeTheme.shouldUseDarkColors ?? true,
    );
    // 强制缓存
    try {
      mainWindow.webContents.session.flushStorageData();
    } catch {}
  });

  ipcMain.on('changeSetting', (event, setting) => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('changeSetting', setting);
    }
    if (beforeMeetingWindow && !beforeMeetingWindow.isDestroyed()) {
      beforeMeetingWindow.webContents.send('changeSetting', setting);
    }
    if (!inMeeting) {
      Object.values(beforeNewWins).forEach((win) => {
        win.webContents.send('changeSetting', setting);
      });
    }
  });

  // 设置页面切换音频或者视频设备 setting: {type: 'video' | 'speaker' | 'microphone', deviceId: string, deviceName: string}
  ipcMain.on('changeSettingDevice', (event, setting) => {
    console.log('changeSettingDevice', setting);
    mainWindow?.webContents.send('changeSettingDevice', setting);
    beforeMeetingWindow?.webContents.send('changeSettingDevice', setting);
  });

  // 菜单栏切换音频或者视频设备同步给设置界面 setting: {type: 'video' | 'speaker' | 'microphone', deviceId: string}
  ipcMain.on('changeSettingDeviceFromControlBar', (event, setting) => {
    console.log('changeSettingDeviceFromControlBar', setting);
    settingWindow?.webContents.send(
      'changeSettingDeviceFromControlBar',
      setting,
    );
  });

  ipcMain.on('openSetting', (event, type) => {
    console.log('openSetting>>>>', type);
    createSettingWindow(type);
  });

  ipcMain.on('meetingStatus', (_, value) => {
    settingWindow?.webContents.send('meetingStatus', value);
  });

  ipcMain.on('shareWindow', async (event, { targetName, targetId }) => {
    console.log('main shareWindow', { targetName, targetId }, process.platform);
    const windowId = +targetId.split(':')[1];
    switch (process.platform) {
      case 'darwin': {
        const { activateApplicationWindowByName } = require('./utils/mac');
        activateApplicationWindowByName(targetName);
        break;
      }
      case 'win32':
        {
          const {
            activateApplicationWindowByHandle,
          } = require('./utils/windows');
          activateApplicationWindowByHandle(windowId);
        }

        break;
      case 'linux':
        break;
      default:
        break;
    }
  });

  // 主窗口是否为全屏状态
  ipcMain.on('isMainFullScreen', async (event) => {
    const isFullscreen =
      mainWindow?.isFullScreen() || mainWindow?.isMaximized();
    event.sender.send('isMainFullscreen-reply', isFullscreen);
  });

  const template = [
    {
      role: 'appmenu',
      submenu: [
        {
          label: '关于网易会议',
          click: () => {
            if (inMeeting) {
              mainWindow?.webContents.send('open-meeting-about');
            } else {
              beforeMeetingWindow.webContents.send('open-meeting-about');
            }
          },
        },
        { type: 'separator' },
        { role: 'hide', label: '隐藏网易会议' },
        { role: 'hideothers', label: '隐藏其他' },
        { role: 'unhide', label: '显示全部' },
        { type: 'separator' },
        { role: 'quit', label: '退出网易会议' }, // 退出菜单项保持不变
      ],
    },
    {
      label: '编辑',
      submenu: [
        { role: 'cut', label: '剪切' },
        { role: 'copy', label: '复制' },
        { role: 'paste', label: '粘贴' },
        { role: 'delete', label: '删除' },
        { role: 'selectAll', label: '全选' },
      ],
    },
    {
      label: '窗口',
      submenu: [
        { role: 'minimize', label: '最小化' },
        { role: 'close', label: '关闭' },
        { role: 'zoom', label: '缩放' },
        { type: 'separator' },
        {
          label: '显示主窗口',
          click: () => {
            inMeeting
              ? mainWindow?.showInactive()
              : beforeMeetingWindow.showInactive();
          },
        },
        { type: 'separator' },
        { role: 'front', label: '前置所有窗口' },
      ],
    },
    {
      label: '帮助',
      submenu: [
        {
          label: '打开日志文件',
          click: () => {
            shell.openPath(logPath);
          },
        },
        {
          label: '意见反馈',
          click: () => {
            if (inMeeting) {
              mainWindow?.showInactive();
              mainWindow?.webContents.send('open-meeting-feedback');
            } else {
              beforeMeetingWindow.showInactive();
              beforeMeetingWindow.webContents.send('open-meeting-feedback');
            }
          },
        },
      ],
    },
  ];

  // 创建菜单
  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);

  // checkUpdate();

  // 捕获主进程报错
  process.on('uncaughtException', (error) => {
    console.error('\n process caught exception: ', error);
  });

  setTimeout(() => {
    createSettingWindow();
    getVirtualBackground();
  }, 1000);
});
