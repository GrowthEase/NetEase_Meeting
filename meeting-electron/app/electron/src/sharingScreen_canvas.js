const { BrowserWindow, ipcMain, screen, shell } = require('electron');
const path = require('path');

const isLocal = process.env.MODE === 'local';
const isWin32 = process.platform === 'win32';

const MEETING_HEADER_HEIGHT = 28;
const NOTIFY_WINDOW_WIDTH = 408;
const NOTIFY_WINDOW_HEIGHT = 122;
const WINDOW_WIDTH = 1130;
const COLLAPSE_WINDOW_WIDTH = 350;

let mY = 0;

let excludeWindowList = [];

let memberNotifyTimer = null;

const sharingScreen = {
  isSharing: false,
  screenSharingMemberListWindow: null,
  screenSharingChatRoomWindow: null,
  screenSharingVideoWindow: null,
  screenSharingInviteWindow: null,
  memberNotifyWindow: null,
};

const closeScreenSharingWindow = function () {
  ipcMain.removeAllListeners('nemeeting-sharing-screen');
  sharingScreen.screenSharingVideoWindow?.destroy();
  sharingScreen.screenSharingChatRoomWindow?.destroy();

  sharingScreen.screenSharingChatRoomWindow = null;

  sharingScreen.screenSharingVideoWindow = null;

  ipcMain.removeHandler('getMemberListWindowIsOpen');
  closeMemberNotifyWindow();
};

function closeTemScreenSharingWindow() {
  sharingScreen.screenSharingMemberListWindow?.destroy();
  sharingScreen.screenSharingInviteWindow?.destroy();
  sharingScreen.screenSharingInviteWindow = null;
  sharingScreen.screenSharingMemberListWindow = null;
}

function createTemScreenSharingWindow() {
  if (!sharingScreen.screenSharingMemberListWindow) {
    sharingScreen.screenSharingMemberListWindow = new BrowserWindow({
      width: 400,
      height: 600,
      maximizable: false,
      minimizable: false,
      resizable: false,
      autoHideMenuBar: true,
      fullscreenable: false,
      skipTaskbar: true,
      show: false,
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        preload: path.join(__dirname, './ipc.js'),
      },
    });
    if (isLocal) {
      sharingScreen.screenSharingMemberListWindow.loadURL(
        'https://localhost:8000/#/member',
      );
    } else {
      sharingScreen.screenSharingMemberListWindow.loadFile(
        path.join(__dirname, '../build/index.html'),
        {
          hash: 'member',
        },
      );
    }
    sharingScreen.screenSharingMemberListWindow.on('close', function (event) {
      event.preventDefault();
      sharingScreen.screenSharingMemberListWindow.hide();
    });
    sharingScreen.screenSharingMemberListWindow.webContents.on(
      'before-input-event',
      (event, input) => {
        if (input.alt) {
          event.preventDefault();
        }
      },
    );
  }
  if (!sharingScreen.screenSharingInviteWindow) {
    sharingScreen.screenSharingInviteWindow = new BrowserWindow({
      width: 520,
      height: 350,
      maximizable: false,
      minimizable: false,
      resizable: false,
      autoHideMenuBar: true,
      fullscreenable: false,
      skipTaskbar: true,
      show: false,
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        preload: path.join(__dirname, './ipc.js'),
      },
    });
    if (isLocal) {
      sharingScreen.screenSharingInviteWindow.loadURL(
        'https://localhost:8000/#/invite',
      );
    } else {
      sharingScreen.screenSharingInviteWindow.loadFile(
        path.join(__dirname, '../build/index.html'),
        {
          hash: 'invite',
        },
      );
    }
    sharingScreen.screenSharingInviteWindow.on('close', function (event) {
      event.preventDefault();
      sharingScreen.screenSharingInviteWindow.hide();
    });
    sharingScreen.screenSharingInviteWindow.webContents.on(
      'before-input-event',
      (event, input) => {
        if (input.alt) {
          event.preventDefault();
        }
      },
    );
  }
}

function createScreenSharingWindow(mainWindow) {
  if (!sharingScreen.screenSharingChatRoomWindow) {
    sharingScreen.screenSharingChatRoomWindow = new BrowserWindow({
      width: 400,
      height: 600,
      maximizable: false,
      minimizable: false,
      resizable: false,
      autoHideMenuBar: true,
      fullscreenable: false,
      skipTaskbar: true,
      show: false,
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        preload: path.join(__dirname, './ipc.js'),
      },
    });
    if (isLocal) {
      sharingScreen.screenSharingChatRoomWindow.loadURL(
        'https://localhost:8000/#/chat',
      );
    } else {
      sharingScreen.screenSharingChatRoomWindow.loadFile(
        path.join(__dirname, '../build/index.html'),
        {
          hash: 'chat',
        },
      );
    }
    sharingScreen.screenSharingChatRoomWindow.on('close', function (event) {
      event.preventDefault();
      sharingScreen.screenSharingChatRoomWindow?.webContents.send(
        'nemeeting-sharing-screen',
        {
          method: 'closeChatRoom',
        },
      );
      mainWindow?.webContents.send('nemeeting-sharing-screen', {
        method: 'closeChatRoom',
      });
      sharingScreen.screenSharingChatRoomWindow.hide();
    });
    sharingScreen.screenSharingChatRoomWindow.webContents.on(
      'before-input-event',
      (event, input) => {
        if (input.alt) {
          event.preventDefault();
        }
      },
    );
    sharingScreen.screenSharingChatRoomWindow.webContents.session.removeAllListeners(
      'will-download',
    );
    sharingScreen.screenSharingChatRoomWindow.webContents.session.on(
      'will-download',
      (event, item) => {
        item.on('done', (event, state) => {
          if (state === 'completed') {
            // 文件下载完成，打开文件所在路径
            const path = event.sender.getSavePath();
            shell.showItemInFolder(path);
          }
        });
      },
    );
  }

  if (!sharingScreen.screenSharingVideoWindow) {
    const pW = 215;
    const pH = MEETING_HEADER_HEIGHT + 120;
    sharingScreen.screenSharingVideoWindow = new BrowserWindow({
      width: pW - 2,
      height: pH,
      titleBarStyle: 'hidden',
      maximizable: false,
      minimizable: false,
      fullscreenable: false,
      closable: false,
      resizable: false,
      title: '视频窗口',
      skipTaskbar: true,
      show: false,
      transparent: true,
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: true,
        preload: path.join(__dirname, './ipc.js'),
      },
    });
    if (isLocal) {
      sharingScreen.screenSharingVideoWindow.loadURL(
        'https://localhost:8000/#/screenSharing/video',
      );
    } else {
      sharingScreen.screenSharingVideoWindow.loadFile(
        path.join(__dirname, '../build/index.html'),
        {
          hash: 'screenSharing/video',
        },
      );
    }
    sharingScreen.screenSharingVideoWindow.on('close', function (event) {
      event.preventDefault();
      sharingScreen.screenSharingVideoWindow.hide();
    });
  }
}

function createNotifyWindow(mainWindow) {
  if (
    sharingScreen.memberNotifyWindow &&
    !sharingScreen.memberNotifyWindow.isDestroyed()
  ) {
    return;
  }
  const nowDisplay = screen.getPrimaryDisplay();
  const { x, y, width, height } = nowDisplay.workArea;
  sharingScreen.memberNotifyWindow = new BrowserWindow({
    width: NOTIFY_WINDOW_WIDTH,
    height: NOTIFY_WINDOW_HEIGHT,
    x: Math.round(width + NOTIFY_WINDOW_WIDTH),
    y: Math.round(height + NOTIFY_WINDOW_HEIGHT),
    titleBarStyle: 'hidden',
    maximizable: false,
    minimizable: false,
    fullscreenable: false,
    closable: false,
    resizable: false,
    skipTaskbar: true,
    transparent: true,
    show: false,
    hasShadow: false,
    webPreferences: {
      contextIsolation: false,
      nodeIntegration: true,
      preload: path.join(__dirname, './ipc.js'),
    },
  });
  const notifyWindow = sharingScreen.memberNotifyWindow;
  if (isLocal) {
    notifyWindow.loadURL('https://localhost:8000/#/memberNotify');
    notifyWindow.webContents.openDevTools();
  } else {
    notifyWindow.loadFile(path.join(__dirname, '../build/index.html'), {
      hash: 'memberNotify',
    });
  }
  notifyWindow.setAlwaysOnTop(true, 'screen-saver');
  notifyWindow.show();
  setTimeout(() => {
    setNotifyWindowPosition(width, height);
  });
  if (isWin32) {
    ipcMain.on('member-notify-mousemove', () => {
      if (memberNotifyTimer) {
        clearNotifyWIndowTimeout();
      }
    });
  }
  ipcMain.on('notify-show', (event, arg) => {
    sharingScreen.memberNotifyWindow?.webContents.send('notify-show', arg);
    sharingScreen.memberNotifyWindow?.setPosition(
      Math.round(width - NOTIFY_WINDOW_WIDTH),
      Math.round(height - NOTIFY_WINDOW_HEIGHT),
    );
    if (isWin32) {
      clearNotifyWIndowTimeout();
      memberNotifyTimer = setTimeout(() => {
        setNotifyWindowPosition(width, height);
      }, 5000);
    }
  });

  ipcMain.on('notify-hide', (event, arg) => {
    sharingScreen.memberNotifyWindow?.webContents.send('notify-hide', arg);
    setNotifyWindowPosition(width, height);
  });
  ipcMain.on('member-notify-view-member-msg', (event, arg) => {
    mainWindow?.webContents.send('member-notify-view-member-msg');
  });
  ipcMain.on('member-notify-close', (event, arg) => {
    // mainWindow?.webContents.send('member-notify-close')
    setNotifyWindowPosition(width, height);
  });
  ipcMain.on('member-notify-not-notify', (event, arg) => {
    mainWindow?.webContents.send('member-notify-not-notify');
    setNotifyWindowPosition(width, height);
  });
  sharingScreen.memberNotifyWindow.on('destroyed', function (event) {
    removeMemberNotifyListener();
    sharingScreen.memberNotifyWindow = null;
  });
}
function setNotifyWindowPosition(width, height) {
  if (
    sharingScreen.memberNotifyWindow &&
    !sharingScreen.memberNotifyWindow.isDestroyed()
  ) {
    sharingScreen.memberNotifyWindow.setPosition(
      Math.round(width + NOTIFY_WINDOW_WIDTH),
      Math.round(height + NOTIFY_WINDOW_HEIGHT),
    );
  }
  clearNotifyWIndowTimeout();
}
function clearNotifyWIndowTimeout() {
  memberNotifyTimer && clearTimeout(memberNotifyTimer);
  memberNotifyTimer = null;
}
function removeMemberNotifyListener() {
  ipcMain.removeAllListeners('notify-show');
  ipcMain.removeAllListeners('notify-hide');
  ipcMain.removeAllListeners('member-notify-view-member-msg');
  ipcMain.removeAllListeners('member-notify-close');
  ipcMain.removeAllListeners('member-notify-not-notify');
  if (isWin32) {
    ipcMain.removeAllListeners('member-notify-mousemove');
  }
}

function closeMemberNotifyWindow() {
  sharingScreen.memberNotifyWindow?.destroy();
  sharingScreen.memberNotifyWindow = null;
  removeMemberNotifyListener();
  memberNotifyTimer && clearTimeout(memberNotifyTimer);
  memberNotifyTimer = null;
}

function addScreenSharingIpc({ mainWindow, initMainWindowSize }) {
  createScreenSharingWindow(mainWindow);

  let meetingData = null;

  let shareScreen = null;

  // 用来改变工具栏视图的高度
  let mainHeight = [60];

  function removeMainHeight(height) {
    const index = mainHeight.findIndex((item) => item === height);
    if (index !== -1) {
      mainHeight.splice(index, 1);
    }
  }

  function setMainWindowHeight() {
    let height = Math.max.apply(null, mainHeight);
    // 如果高度没有超过 100 ， 说明是工具栏的高度，不需要改变主窗口的高度。 只有 40 ， 60  两种
    if (height < 100) {
      height = mainHeight[mainHeight.length - 1];
    }
    if (sharingScreen.isSharing) {
      mainWindow.setBounds({
        height,
      });
    }
    if (height === 60) {
      mainWindow.setBounds({
        width: WINDOW_WIDTH,
      });
    } else if (height === 40) {
      mainWindow.setBounds({
        width: COLLAPSE_WINDOW_WIDTH,
      });
    } else {
      mainWindow.setBounds({
        width: WINDOW_WIDTH,
      });
    }
    mainWindow.center();
    mainWindow.setBounds({
      y: mY,
    });
  }

  ipcMain.handle('getMemberListWindowIsOpen', (event) => {
    return !!sharingScreen.screenSharingMemberListWindow?.isVisible();
  });
  ipcMain.on('nemeeting-sharing-screen', (event, value) => {
    const { method, data } = value;

    switch (method) {
      case 'start':
        createTemScreenSharingWindow();
        createNotifyWindow(mainWindow);
        mainWindow.setOpacity(0);
        mainWindow.setBackgroundColor('rgba(255, 255, 255,0)');
        setTimeout(() => {
          mainWindow.setOpacity(1);
          mainWindow.setBackgroundColor('rgba(255, 255, 255,0)');
        }, 600);
        sharingScreen.isSharing = true;

        mainWindow.setMinimizable(false);
        mainWindow.setMinimumSize(1, 1);
        mainWindow.setWindowButtonVisibility?.(false);
        mainWindow.setHasShadow(false);
        mainWindow.setResizable(false);

        const nowDisplay = shareScreen || screen.getPrimaryDisplay();
        const { x, y, width } = nowDisplay.workArea;
        const mainWidth = 760;
        const mainX = x + width / 2 - mainWidth / 2;
        // 记录主窗口的y坐标
        mY = y;

        mainWindow.setBounds({
          x: mainX,
          y,
          width: WINDOW_WIDTH,
        });

        mainWindow.setMovable(true);

        mainHeight = [60];

        setMainWindowHeight();

        sharingScreen.screenSharingVideoWindow.show();

        const pX = x + width - 215;
        const pY = y;

        sharingScreen.screenSharingVideoWindow.setBounds({
          x: pX,
          y: pY,
        });

        excludeWindowList = [
          mainWindow,
          sharingScreen.screenSharingVideoWindow,
          sharingScreen.screenSharingInviteWindow,
          sharingScreen.screenSharingChatRoomWindow,
          sharingScreen.screenSharingMemberListWindow,
        ];
        mainWindow.webContents.send('nemeeting-sharing-screen', {
          method: 'rtcController',
          data: {
            fnKey: 'setExcludeWindowList',
            args: [
              excludeWindowList.map((item) =>
                isWin32
                  ? item.getNativeWindowHandle()
                  : Number(item.getMediaSourceId().split(':')[1]),
              ),
              isWin32,
            ],
          },
        });

        mainWindow.setAlwaysOnTop(true, 'screen-saver');
        sharingScreen.screenSharingVideoWindow.setAlwaysOnTop(
          true,
          'screen-saver',
        );

        sharingScreen.screenSharingVideoWindow.webContents.send(
          'nemeeting-sharing-screen',
          {
            method: 'startScreenShare',
          },
        );

        break;
      case 'share-screen':
        shareScreen = screen.getAllDisplays()[data];
        screen.on('display-removed', (_, data) => {
          const isSameDisplay = data.label === shareScreen?.label;
          if (isSameDisplay) {
            // TODO: 退出共享
          }
        });
        break;
      case 'stop':
        closeMemberNotifyWindow();
        if (sharingScreen.isSharing) {
          closeTemScreenSharingWindow();
          shareScreen = null;
          sharingScreen.isSharing = false;
          if (!data?.immediately) {
            mainWindow.setOpacity(0);
            setTimeout(() => {
              mainWindow.setOpacity(1);
              mainWindow.setBackgroundColor('#ffffff');
            }, 600);
          }
          mainWindow.setMinimizable(true);
          mainWindow.setWindowButtonVisibility?.(true);
          mainWindow.setHasShadow(true);
          mainWindow.setAlwaysOnTop(false);
          mainWindow.setResizable(true);

          sharingScreen.screenSharingVideoWindow.setAlwaysOnTop(false);

          initMainWindowSize();
          mainWindow.show();

          sharingScreen.screenSharingVideoWindow.webContents.send(
            'nemeeting-sharing-screen',
            {
              method: 'stopScreenShare',
            },
          );

          sharingScreen.screenSharingVideoWindow?.hide();
          sharingScreen.screenSharingMemberListWindow?.hide();
          sharingScreen.screenSharingChatRoomWindow?.hide();
          sharingScreen.screenSharingInviteWindow?.hide();
        }
        break;
      case 'controlBarVisibleChangeByMouse':
        if (sharingScreen.isSharing) {
          if (data) {
            mainWindow.setBounds({
              width: WINDOW_WIDTH,
            });
            removeMainHeight(60);
            mainHeight.push(60);
            setMainWindowHeight(true);
          } else {
            mainWindow.setBounds({
              width: COLLAPSE_WINDOW_WIDTH,
            });
            removeMainHeight(40);
            mainHeight.push(40);
            setMainWindowHeight(true);
          }
          mainWindow.center();
          mainWindow.setBounds({
            y: mY,
          });
        }
        break;
      case 'openDeviceList':
        mainHeight.push(800);
        setMainWindowHeight();
        break;
      case 'closeDeviceList':
        removeMainHeight(800);
        setMainWindowHeight(true);
        break;
      case 'openPopover':
        mainHeight.push(150);
        setMainWindowHeight(true);
        break;
      case 'closePopover':
        removeMainHeight(150);
        setMainWindowHeight(true);
        break;
      case 'openModal':
        if (sharingScreen.isSharing) {
          mainHeight.push(300);
          setMainWindowHeight();
        }
        break;
      case 'closeModal':
        if (sharingScreen.isSharing) {
          removeMainHeight(300);
          setMainWindowHeight(true);
        }
        break;
      case 'openToast':
        if (sharingScreen.isSharing) {
          mainHeight.push(120);
          setMainWindowHeight();
        }
        event.sender.send('nemeeting-sharing-screen', {
          method,
          data: sharingScreen.isSharing,
        });
        break;
      case 'closeToast':
        if (sharingScreen.isSharing) {
          removeMainHeight(120);
          setMainWindowHeight(true);
        }
        break;
      case 'updateData':
        meetingData = data;
        if (
          sharingScreen.screenSharingChatRoomWindow &&
          !sharingScreen.screenSharingChatRoomWindow.isDestroyed()
        ) {
          sharingScreen.screenSharingChatRoomWindow?.webContents.send(
            'updateData',
            data,
          );
        }
        if (
          sharingScreen.screenSharingMemberListWindow &&
          !sharingScreen.screenSharingMemberListWindow.isDestroyed()
        ) {
          sharingScreen.screenSharingMemberListWindow?.webContents.send(
            'updateData',
            data,
          );
        }
        if (
          sharingScreen.screenSharingVideoWindow &&
          !sharingScreen.screenSharingVideoWindow.isDestroyed()
        ) {
          sharingScreen.screenSharingVideoWindow?.webContents.send(
            'updateData',
            data,
          );
        }
        if (
          sharingScreen.screenSharingInviteWindow &&
          !sharingScreen.screenSharingInviteWindow.isDestroyed()
        ) {
          sharingScreen.screenSharingInviteWindow?.webContents.send(
            'updateData',
            data,
          );
        }
        break;
      case 'openInvite':
        sharingScreen.screenSharingInviteWindow?.webContents.send(
          'updateData',
          meetingData,
        );
        sharingScreen.screenSharingInviteWindow?.show();
        break;
      case 'openMemberList':
        sharingScreen.screenSharingMemberListWindow?.webContents.send(
          'updateData',
          meetingData,
        );
        sharingScreen.screenSharingMemberListWindow?.show();
        break;
      case 'neMeeting':
        mainWindow.webContents.send('nemeeting-sharing-screen', {
          method,
          data,
        });
        break;
      case 'neMeetingReply':
        sharingScreen.screenSharingMemberListWindow?.webContents.send(
          'neMeetingReply',
          data,
        );
        break;
      case 'openChatRoom':
        sharingScreen.screenSharingChatRoomWindow?.show();
        sharingScreen.screenSharingChatRoomWindow?.webContents.send(
          'nemeeting-sharing-screen',
          {
            method: 'openChatRoom',
          },
        );
        mainWindow?.webContents.send('nemeeting-sharing-screen', {
          method: 'openChatRoom',
        });
        break;
      case 'chatController':
        mainWindow.webContents.send('nemeeting-sharing-screen', {
          method,
          data,
        });
        break;
      case 'chatControllerReply':
        const { replyKey } = data;
        sharingScreen.screenSharingChatRoomWindow?.webContents.send(
          replyKey,
          data,
        );
        break;
      case 'chatListener':
        sharingScreen.screenSharingChatRoomWindow?.webContents.send(
          'nemeeting-sharing-screen',
          {
            method,
            data,
          },
        );
        break;
      case 'chatroomMyMessageList':
        if (sharingScreen.isSharing) {
          mainWindow.webContents.send('nemeeting-sharing-screen', {
            method,
            data,
          });
        } else {
          sharingScreen.screenSharingChatRoomWindow?.webContents.send(
            'nemeeting-sharing-screen',
            {
              method,
              data,
            },
          );
        }
        break;
      case 'chatroomRemoveMessage':
        if (sharingScreen.isSharing) {
          mainWindow.webContents.send('nemeeting-sharing-screen', {
            method,
            data,
          });
        } else {
          sharingScreen.screenSharingChatRoomWindow?.webContents.send(
            'nemeeting-sharing-screen',
            {
              method,
              data,
            },
          );
        }
        break;
      case 'videoCountModelChange':
        const { videoCount } = data;
        sharingScreen.screenSharingVideoWindow?.webContents.send(
          'nemeeting-sharing-screen',
          {
            method,
            data,
          },
        );
        switch (videoCount) {
          case 0:
            sharingScreen.screenSharingVideoWindow?.setBounds({
              height: MEETING_HEADER_HEIGHT + 35,
            });
            break;
          case 1:
            sharingScreen.screenSharingVideoWindow?.setBounds({
              height: MEETING_HEADER_HEIGHT + 120,
            });
            break;
          default:
            break;
        }
        break;
      case 'videoWindowHeightChange':
        const { height } = data;
        if (sharingScreen.screenSharingVideoWindow) {
          sharingScreen.screenSharingVideoWindow?.setBounds({
            height: Math.round(height + MEETING_HEADER_HEIGHT),
          });
        }
        break;
      case 'videoOpen':
        if (sharingScreen.isSharing) {
          if (!data.isMySelf) {
            mainWindow.webContents.send('nemeeting-sharing-screen', {
              method: 'rtcController',
              data: {
                fnKey: 'setupRemoteVideoCanvas',
                args: ['', data.uuid],
              },
            });
            mainWindow.webContents.send('nemeeting-sharing-screen', {
              method: 'rtcController',
              data: {
                fnKey: 'subscribeRemoteVideoStream',
                args: [data.uuid, 1],
              },
            });
          }
        }
        break;
      case 'videoClose':
        if (sharingScreen.isSharing) {
          if (!data.isMySelf) {
            mainWindow.webContents.send('nemeeting-sharing-screen', {
              method: 'rtcController',
              data: {
                fnKey: 'unsubscribeRemoteVideoStream',
                args: [data.uuid],
              },
            });
          }
        }
        break;
      case 'audioVolumeIndication':
        if (sharingScreen.isSharing) {
          sharingScreen.screenSharingVideoWindow?.webContents.send(
            'nemeeting-sharing-screen',
            {
              method,
              data,
            },
          );
        }
        break;
      case 'onVideoFrameData':
        if (sharingScreen.isSharing) {
          if (
            sharingScreen.screenSharingVideoWindow &&
            !sharingScreen.screenSharingVideoWindow.isDestroyed()
          ) {
            sharingScreen.screenSharingVideoWindow.webContents.send(
              'onVideoFrameData',
              ...data,
            );
          }
        }
        break;
      default:
        break;
    }
  });
}

module.exports = {
  sharingScreen,
  createScreenSharingWindow,
  closeScreenSharingWindow,
  addScreenSharingIpc,
};
