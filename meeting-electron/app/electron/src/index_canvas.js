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
  clipboard,
  powerSaveBlocker,
} = require('electron');
const log = require('electron-log/main');
const {
  checkUpdate,
  getVersionCode,
  initUpdateListener,
} = require('./utils/update');
const { autoUpdater } = require('electron-updater');
const { initLog, getLogDate } = require('./utils/log');
const { promisify } = require('util');
const path = require('path');
const fs = require('fs');
const os = require('os');
const si = require('systeminformation');
const { exec } = require('child_process');
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

const {
  sharingScreen,
  closeScreenSharingWindow,
  addScreenSharingIpc,
} = require('./sharingScreen_canvas');

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

let beforeMeetingWindow;
let mainWindow;
let settingWindow;
let historyWindow;
let historyChatWindow;
let npsWindow;
let aboutWindow;
let inMeeting = false;
let inWaitingRoom = false;
let alreadySetWidth = false;
let previewRoomListener = null;
let isOpenSettingWindow = false;
let powerSaveBlockerId = null;
let isOpenSettingDialog = false;
let inviteUrl = '';

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

function createWindow(data) {
  // Create the browser window.
  const mousePosition = screen.getCursorScreenPoint();
  const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
  const { x, y, width, height } = nowDisplay.workArea;
  if (!mainWindow) {
    // 打开成员列表或者聊天室窗口宽度变宽
    const ext_w_h = isWin32 ? 8 : 0;
    mainWindow = new BrowserWindow({
      titleBarStyle: 'hidden',
      title: '网易会议',
      width: 1100 - 2 - ext_w_h * 2,
      height: 720 - MEETING_HEADER_HEIGHT - ext_w_h,
      x: Math.round(x + (width - 375) / 2),
      y: Math.round(y + (height - 670) / 2),
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
  }

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
    mainWindow.loadURL(`https://localhost:8000/#/meeting?${query}`);

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

  mainWindow.on('leave-full-screen', () => {
    mainWindow.setTitle('网易会议');
  });
  mainWindow.on('enter-full-screen', () => {
    mainWindow.setTitle('');
  });

  initMainWindowSize();
}

function createBeforeMeeting() {
  const mousePosition = screen.getCursorScreenPoint();
  const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
  const { x, y, width, height } = nowDisplay.workArea;
  beforeMeetingWindow = new BrowserWindow({
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
    title: '网易会议',
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      enableRemoteModule: true,
      preload: path.join(__dirname, './preload.js'),
    },
  });

  if (isLocal) {
    beforeMeetingWindow.loadURL('https://localhost:8000/');
    setTimeout(() => {
      beforeMeetingWindow?.webContents.openDevTools();
    }, 3000);
  } else {
    beforeMeetingWindow.loadFile(path.join(__dirname, '../build/index.html'));
  }
}

function createHistoryWindow() {
  if (historyWindow) return;
  historyWindow = new BrowserWindow({
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
    title: '历史会议',
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      preload: path.join(__dirname, './preload.js'),
    },
  });
  if (isLocal) {
    historyWindow.loadURL('https://localhost:8000/#/history');
  } else {
    historyWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'history',
    });
  }
  historyWindow.hide();
  historyWindow.on('closed', function () {
    historyWindow = null;
  });
}

function createHistoryChatWindow({ roomArchiveId, subject, startTime }) {
  if (historyChatWindow && !historyChatWindow.isDestroyed()) {
    historyChatWindow.show();
  } else {
    historyChatWindow = new BrowserWindow({
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
      title: '聊天记录',
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        preload: path.join(__dirname, './preload.js'),
      },
    });
    historyChatWindow.webContents.session.removeAllListeners('will-download');
    historyChatWindow.webContents.session.on('will-download', (event, item) => {
      item.on('done', (event, state) => {
        if (state === 'completed') {
          console.log('historyChatWindow will-download');
          // 文件下载完成，打开文件所在路径
          const path = event.sender.getSavePath();
          shell.showItemInFolder(path);
        }
      });
    });
  }

  if (isLocal) {
    historyChatWindow.loadURL(
      `https://localhost:8000/#/chat?roomArchiveId=${roomArchiveId}&subject=${subject}&startTime=${startTime}`,
    );
  } else {
    historyChatWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'chat',
      query: {
        roomArchiveId,
        subject,
        startTime,
      },
    });
  }

  historyChatWindow.on('closed', function () {
    historyChatWindow = null;
  });
}

function createAboutWindow() {
  if (aboutWindow && !aboutWindow.isDestroyed()) {
    aboutWindow.show();
    return;
  }
  aboutWindow = new BrowserWindow({
    width: 375,
    height: 460,
    titleBarStyle: 'hidden',
    maximizable: false,
    minimizable: false,
    resizable: false,
    trafficLightPosition: {
      x: 10,
      y: 13,
    },
    title: '关于',
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      preload: path.join(__dirname, './ipc.js'),
    },
  });
  if (isLocal) {
    aboutWindow.loadURL('https://localhost:8000/#/about');
  } else {
    aboutWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'about',
    });
  }
  aboutWindow.show();
  aboutWindow.on('closed', function () {
    aboutWindow = null;
  });
}

// data: meetingId: string, appKey: string, nickname: string,
function createNPSWindow(data) {
  npsWindow = new BrowserWindow({
    width: 800,
    height: 380,
    titleBarStyle: 'hidden',
    maximizable: false,
    minimizable: false,
    resizable: false,
    title: 'NPS 评分',
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      preload: path.join(__dirname, './ipc.js'),
    },
  });
  if (isLocal) {
    npsWindow.loadURL(
      `https://localhost:8000/#/nps?meetingId=${data.meetingId}&appKey=${data.appKey}&nickname=${data.nickname}`,
    );
  } else {
    npsWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'nps',
      query: {
        ...data,
      },
    });
  }
  npsWindow.hide();
  npsWindow.on('closed', function () {
    npsWindow = null;
  });
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
  if (settingWindow && !settingWindow.isDestroyed()) {
    settingWindow.show();
    isOpenSettingWindow = true;
    settingWindow.webContents.send('showSettingWindow', {
      isShow: true,
      type,
      inMeeting: !inWaitingRoom && inMeeting,
    });
    settingWindow.moveAbove(
      inMeeting
        ? mainWindow?.getMediaSourceId()
        : beforeMeetingWindow?.getMediaSourceId(),
    );
    return;
  }
  if (!settingWindow) {
    settingWindow = new BrowserWindow({
      width: 800,
      height: 560,
      titleBarStyle: 'hidden',
      trafficLightPosition: {
        x: 10,
        y: 13,
      },
      maximizable: false,
      minimizable: false,
      resizable: false,
      fullscreen: false,
      alwaysOnTop: true,
      show: false,
      title: '设置',
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        preload: path.join(__dirname, './preload.js'),
      },
    });
  }
  settingWindow.hide();
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
        .showOpenDialog(settingWindow, {
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
      // if (inMeeting) {
      //   const video = videoWindows.find((item) => item.isMySelf);
      //   if (video) {
      //     previewController.setupLocalVideoCanvas(
      //       video.window.getNativeWindowHandle(),
      //       mirror,
      //     );
      //   }
      // }
    }
  });
  if (isLocal) {
    settingWindow.loadURL('https://localhost:8000/#/setting');
  } else {
    settingWindow.loadFile(path.join(__dirname, `../build/index.html`), {
      hash: 'setting',
    });
  }
  settingWindow.on('close', function (event) {
    event.preventDefault();
    isOpenSettingWindow = false;
    if (inMeeting) {
      mainWindow?.webContents.send('previewController', {
        method: 'stopPreview',
        args: [],
      });
    } else {
      beforeMeetingWindow?.webContents.send('previewController', {
        method: 'stopPreview',
        args: [],
      });
    }

    // ipcMain.removeAllListeners('nemeeting-beauty');
    closeSettingWindowHandle(type);
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

  const _height = 670;

  mainWindow.setBounds({
    width: Math.round(MINI_WIDTH),
    height: Math.round(_height),
    x: Math.round(x + (width - MINI_WIDTH) / 2),
    y: Math.round(y + (height - _height) / 2),
  });
  mainWindow.setMinimumSize(MINI_WIDTH, 670);
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
  createBeforeMeeting();
  initUpdateListener(beforeMeetingWindow, {}, `${app.name}/rooms`);

  app.on('render-process-gone', (event, webContents, details) => {
    if (webContents.id) {
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

  ipcMain.on('openChatroomOrMemberList', (event, isOpen) => {
    if (!mainWindow) {
      return;
    }
    if (isOpen) {
      mainWindow.setMinimumSize(MINI_WIDTH + 320, 670);
    } else {
      mainWindow.setMinimumSize(MINI_WIDTH, 670);
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
    console.log('set-meeting-nps>>>>>>', meetingId);
    beforeMeetingWindow?.webContents.send('set-meeting-nps', meetingId);
  });

  ipcMain.on('need-open-meeting-nps', () => {
    console.log('need-open-meeting-nps');
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
  ipcMain.on('changeMirror', (event, value) => {
    localMirror = !!value;
  });
  ipcMain.on('nemeeting-download-path', (event, value) => {
    if (value === 'get') {
      event.returnValue = app.getPath('downloads');
    }
    if (value === 'set') {
      const { dialog } = require('electron');
      isOpenSettingDialog = true;
      dialog
        .showOpenDialog(settingWindow, {
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

  ipcMain.on('open-chatroom', () => {
    mainWindow?.webContents.send('open-chatroom');
  });

  ipcMain.on('show-window', (event) => {
    const window = BrowserWindow.fromWebContents(event.sender);
    if (window && !window.isDestroyed()) {
      window.showInactive();
    }
  });

  ipcMain.on('nemeeting-file-save-as', (event, value) => {
    const { dialog } = require('electron');
    const { defaultPath, filePath } = value;
    dialog
      .showSaveDialog(
        sharingScreen.isSharing
          ? sharingScreen.screenSharingChatRoomWindow
          : mainWindow,
        {
          defaultPath: defaultPath,
          filters: [{ name: '', extensions: '*' }],
        },
      )
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
  // 全屏模式鼠标移出应用逻辑处理
  // ipcMain.on('mouseLeave', () => {
  //   // window 不用处理全屏遮挡问题
  //   if (isWin32 && isMouseLeave) {
  //     return;
  //   }
  //   // 判断当前是否全屏
  //   const isFullscreen = parentWindow?.isFullScreen();
  //   if (isFullscreen && mainWindow) {
  //     isMouseLeave = true;
  //     const { y: y_position, height } = mainWindow.getBounds();
  //     mainWindow.setResizable(true);
  //     mainWindow.setBounds({
  //       y: y_position + MEETING_HEADER_HEIGHT * 2,
  //       height: height - MEETING_HEADER_HEIGHT * 2,
  //     });
  //     isWin32 && mainWindow.setResizable(false);
  //   }
  // });
  // ipcMain.on('mouseEnter', () => {
  //   // window 不用处理全屏遮挡问题
  //   if (isWin32 || !isMouseLeave) {
  //     return;
  //   }
  //   const isFullscreen = parentWindow?.isFullScreen();
  //   // 如果在全屏状态下 主画面要恢复全屏
  //   if (isFullscreen && mainWindow) {
  //     isMouseLeave = false;
  //     const { y: y_position, height } = mainWindow.getBounds();
  //     mainWindow.setResizable(true);
  //     mainWindow.setBounds({
  //       y: y_position - MEETING_HEADER_HEIGHT * 2,
  //       height: height + MEETING_HEADER_HEIGHT * 2,
  //     });
  //   }
  // });

  ipcMain.on('NERoomSDKProxy', (event, value) => {
    if (inMeeting) {
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow?.webContents.send('NERoomSDKProxy', value);
      }
    } else {
      if (beforeMeetingWindow && !beforeMeetingWindow.isDestroyed()) {
        beforeMeetingWindow?.webContents.send('NERoomSDKProxy', value);
      }
    }
  });
  ipcMain.on('NERoomSDKProxyReply', (event, value) => {
    const { data } = value;
    if (historyChatWindow && !historyChatWindow.isDestroyed()) {
      historyChatWindow?.webContents.send(data.replyKey, value.data);
    }
    if (
      sharingScreen.isSharing &&
      sharingScreen.screenSharingChatRoomWindow &&
      !sharingScreen.screenSharingChatRoomWindow.isDestroyed()
    ) {
      sharingScreen.screenSharingChatRoomWindow?.webContents.send(
        data.replyKey,
        value.data,
      );
    }
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
  ipcMain.on('nemeeting-paste-image', (event, value) => {
    const imageCache = path.join(userDataPath, 'imageCache');
    const clipboardImage = clipboard.readImage('clipboard');
    if (!clipboardImage.isEmpty()) {
      // TODO: 保存图片到本地
      /*
      const imageBuffer = image.toPNG(); // 或者使用其他格式如 toJPEG
      // 将图片数据保存到本地文件
      const fs = require('fs');
      const imagePath = path.join(imageCache, `${Date.now()}.png`); // 保存图片的路径
      fs.writeFileSync(imagePath, imageBuffer);
      */
    }
  });

  ipcMain.on('nemeeting-choose-file', (event, value) => {
    const { type, extensions, extendedData } = value;
    log.info(
      'nemeeting-choose-file',
      type,
      extensions,
      sharingScreen.isSharing,
      mainWindow?.isDestroyed(),
    );
    let browserWindow;
    if (
      sharingScreen.isSharing &&
      sharingScreen.screenSharingChatRoomWindow &&
      !sharingScreen.screenSharingChatRoomWindow.isDestroyed()
    ) {
      browserWindow = sharingScreen.screenSharingChatRoomWindow;
    } else if (mainWindow && !mainWindow.isDestroyed()) {
      browserWindow = mainWindow;
    }
    dialog
      .showOpenDialog(browserWindow, {
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
    // mainWindow.unmaximize();
  });

  ipcMain.on('flushStorageData', () => {
    // 强制缓存
    try {
      beforeMeetingWindow.webContents.session.flushStorageData();
    } catch {}
  });

  ipcMain.on('beforeLogin', () => {
    // settingWindow?.destroy();
    // settingWindow = null;
    npsWindow?.destroy();
    npsWindow = null;
    historyWindow?.destroy();
    historyWindow = null;
    aboutWindow?.destroy();
    aboutWindow = null;
    mainWindow?.destroy();
    mainWindow = null;
    inMeeting = false;
  });

  ipcMain.on('beforeEnterRoom', () => {
    inMeeting = false;

    console.log('beforeEnterRoom>>>');
    beforeMeetingWindow?.showInactive();
    mainWindow?.destroy();
    mainWindow = null;
    powerSaveBlockerId && powerSaveBlocker.stop(powerSaveBlockerId);
    powerSaveBlockerId = null;
    if (settingWindow) {
      closeSettingWindowHandle();
    }
    historyWindow?.showInactive();
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
    console.log('enter>>>>>>', data);
    if (!data) {
      return;
    }

    inMeeting = true;
    alreadySetWidth = false;

    historyWindow?.close();
    historyChatWindow?.close();
    npsWindow?.close();
    aboutWindow?.close();

    createWindow(data);

    // 阻止屏幕休眠
    powerSaveBlockerId = powerSaveBlocker.start('prevent-display-sleep');

    // mainWindow.showInactive();
    if (settingWindow) {
      closeSettingWindowHandle();
    }
    mainWindow.setMinimumSize(MINI_WIDTH, 670 - MEETING_HEADER_HEIGHT);
    beforeMeetingWindow?.webContents.send('join-meeting-loading', true);
    mainWindow.webContents.once('dom-ready', () => {
      beforeMeetingWindow?.webContents.send('join-meeting-loading', false);
      beforeMeetingWindow?.hide();
      mainWindow?.show();
    });

    mainWindow.webContents.send(
      'set-theme-color',
      nativeTheme.shouldUseDarkColors ?? true,
    );

    // mainWindow.show();

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
    if (historyWindow && !historyWindow.isDestroyed()) {
      historyWindow.webContents.send('changeSetting', setting);
    }
    if (historyChatWindow && !historyChatWindow.isDestroyed()) {
      historyChatWindow?.webContents.send('changeSetting', setting);
    }
    if (aboutWindow && !aboutWindow.isDestroyed()) {
      aboutWindow.webContents.send('changeSetting', setting);
    }
    if (npsWindow && !npsWindow.isDestroyed()) {
      npsWindow.webContents.send('changeSetting', setting);
    }
    if (
      sharingScreen.screenSharingChatRoomWindow &&
      !sharingScreen.screenSharingChatRoomWindow.isDestroyed()
    ) {
      sharingScreen.screenSharingChatRoomWindow.webContents.send(
        'changeSetting',
        setting,
      );
    }
    if (
      sharingScreen.screenSharingMemberListWindow &&
      !sharingScreen.screenSharingMemberListWindow.isDestroyed()
    ) {
      sharingScreen.screenSharingMemberListWindow.webContents.send(
        'changeSetting',
        setting,
      );
    }
    if (
      sharingScreen.screenSharingInviteWindow &&
      !sharingScreen.screenSharingInviteWindow.isDestroyed()
    ) {
      sharingScreen.screenSharingInviteWindow.webContents.send(
        'changeSetting',
        setting,
      );
    }
    if (
      sharingScreen.screenSharingVideoWindow &&
      !sharingScreen.screenSharingVideoWindow.isDestroyed()
    ) {
      sharingScreen.screenSharingVideoWindow.webContents.send(
        'changeSetting',
        setting,
      );
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

  ipcMain.on('open-meeting-history', () => {
    createHistoryWindow();
    const bounds = beforeMeetingWindow.getBounds();
    historyWindow.setPosition(Math.round(bounds.x + 375), Math.round(bounds.y));
    historyWindow.webContents.send('open-meeting-history');
    historyWindow.show();
  });

  ipcMain.on('open-meeting-history-chat', (_, value) => {
    createHistoryChatWindow(value);
    const bounds = historyWindow.getBounds();
    historyChatWindow.setPosition(Math.round(bounds.x), Math.round(bounds.y));
  });

  ipcMain.on('open-meeting-about', () => {
    createAboutWindow();
    const mousePosition = screen.getCursorScreenPoint();
    const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
    const { x, y, width, height } = nowDisplay.workArea;

    aboutWindow?.setSize(375, 460);
    aboutWindow?.setPosition(
      Math.round(x + (width + 440) / 2),
      Math.round(y + (height - 620) / 2),
    );
    aboutWindow.webContents.send('open-meeting-history');
  });

  ipcMain.on('open-meeting-nps', (_, value) => {
    createNPSWindow(value);
    const mousePosition = screen.getCursorScreenPoint();
    const nowDisplay = screen.getDisplayNearestPoint(mousePosition);
    const { x, y, width, height } = nowDisplay.workArea;

    npsWindow.setPosition(
      Math.round(x + (width - 800) / 2),
      Math.round(y + (height - 400) / 2),
    );
    // npsWindow.webContents.send('open-meeting-nps', value);
    npsWindow.show();
  });

  ipcMain.on('meetingStatus', (_, value) => {
    settingWindow?.webContents.send('meetingStatus', value);
  });

  //   app.on('before-quit', (event) => {
  //     console.log('\n监听到quit');
  //     app.isQuiting = true;
  //   });
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
            createAboutWindow();
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
            }
            beforeMeetingWindow.showInactive();
            beforeMeetingWindow.webContents.send('open-meeting-feedback');
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

function checkUpdate_draft() {
  if (process.platform == 'darwin') {
    autoUpdater.setFeedURL('http://10.219.24.244:8822/electron-meeting/darwin'); //设置要检测更新的路径
  } else {
    autoUpdater.setFeedURL('http://10.219.24.244:8822/electron-meeting/win32');
  }
  //监听'error'事件
  autoUpdater.on('error', (err) => {
    console.log(err);
  });

  //监听'update-available'事件，发现有新版本时触发
  autoUpdater.on('update-available', () => {
    console.log('found new version');
  });

  //监听'update-downloaded'事件，新版本下载完成时触发
  autoUpdater.on('update-downloaded', () => {
    setTimeout(() => {
      dialog
        .showMessageBox({
          type: 'info',
          message: '发现新版本，是否更新？',
          buttons: ['是', '否'],
        })
        .then((buttonIndex) => {
          if (buttonIndex.response == 0) {
            //选择是，则退出程序，安装新版本
            autoUpdater.quitAndInstall();
            app.exit(0);
          }
        });
    }, 5000);
  });

  //检测更新
  autoUpdater.checkForUpdates();
}
