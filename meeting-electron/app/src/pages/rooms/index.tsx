import NEMeetingKit from '../../../../src/index';

import Styles from './index.less';
import { ConfigProvider, message, Progress, Spin, Button } from 'antd';
import antd_zh_CH from 'antd/locale/zh_CN';

import BeforeActivatePage from './BeforeActivatePage';
import RoomsBindPage from './RoomsBindPage';
import RoomsHomePage from './RoomsHomePage';
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import req, { QRCodeRes, RoomsInfo, Settings, domain } from './request';
import { EventType, NERoomBeautyEffectType } from '../../../../src/types';
import { useDevices } from './hooks';
import { getDevices, reportDevices } from './utils';
import axios from 'axios';
import {
  DeviceInfo,
  DevicesInfo,
  IPCEvent,
  ResUpdateInfo,
  SelectedDeviceInfo,
  UpdateInfo,
  UpdateType,
} from '@/types';
import Modal from '../../../../src/components/common/Modal';
import AuthorizationTip from '@/components/AuthorizationDialogTip';

import BackgroundImage from '../../assets/rooms-background.png';
import QuitImage from '../../assets/rooms-quit.png';
import PairedImage from '../../assets/rooms-paired.png';
import UnpairedImage from '../../assets/rooms-unpaired.png';
import ScreenSharing from './ScreenSharing';

message.config({
  top: 200,
  duration: 3,
  maxCount: 5,
});

interface LocalUpdateInfo {
  versionName: string;
  versionCode: number;
  platform: 'win32' | 'darwin';
}

const antdPrefixCls = 'nemeeting';

ConfigProvider.config({ prefixCls: antdPrefixCls });

const RoomsPage: React.FC = () => {
  const [inMeeting, setInMeeting] = useState(false);
  const [activeStep, setActiveStep] = useState(0);
  const [qrCodeRes, setQrCodeRes] = useState<QRCodeRes>();
  const [roomsInfo, setRoomsInfo] = useState<RoomsInfo>();
  const [settings, setSettings] = useState<Settings>();
  const [joiningMeeting, setJoiningMeeting] = useState(false);
  const [screenSharingVisible, setScreenSharingVisible] = useState(false);

  const [needUpdateType, setNeedUpdateType] = useState(UpdateType.noUpdate);
  const [updateInfo, setUpdateInfo] = useState({
    title: '',
    description: '',
    version: '',
  });
  const [updateProgress, setUpdateProgress] = useState(0);
  const [updateError, setUpdateError] = useState({
    showUpdateError: false,
    msg: '',
  });
  const [localUpdateInfo, setLocalUpdateInfo] = useState<LocalUpdateInfo>({
    versionName: '',
    versionCode: -1,
    platform: 'darwin',
  });
  const updateTimer = useRef<any>(null);
  const updateIntervalTierRef = useRef<any>(null);
  const isCheckingUpdateRef = useRef(false);
  const updateInfoRef = useRef<ResUpdateInfo | null>(null);

  const videoPreviewRef = useRef(false);
  const speakerTestTimerRef = useRef<NodeJS.Timeout>();
  const microphoneTestRef = useRef('');
  1;
  const [hasMicAuthorization, setHasMicAuthorization] = useState(true);
  const [hasCameraAuthorization, setHasCameraAuthorization] = useState(true);

  const [deviceInfo, setDeviceInfo] = useState<SelectedDeviceInfo>({
    selectedVideoDeviceId: '',
    selectedMicDeviceId: '',
    selectedSpeakerDeviceId: '',
  });
  const deviceInfoRef = useRef<SelectedDeviceInfo>(deviceInfo);
  const settingRef = useRef<Settings>();
  deviceInfoRef.current = deviceInfo;
  settingRef.current = settings;

  useDevices(settings, inMeeting, deviceInfo);

  const noControls = useMemo(() => {
    if (activeStep === 3) {
      if (!roomsInfo?.controls || roomsInfo?.controls.length === 0) {
        return true;
      }
    }
    return false;
  }, [activeStep, roomsInfo]);

  function initRooms() {
    if (activeStep === 0) {
      const res = req.getAccountInfo();
      if (res) {
        handleUserLogin({
          appKey: res.appKey,
          account: res.userUuid,
          token: res.userToken,
        });
        const activeStep = localStorage.getItem('NetEase-Rooms-ActiveStep');
        setActiveStep(Number(activeStep) || 2);
      } else {
        function getRoomQRCode() {
          req.getRoomsQRCode().then((res) => {
            setQrCodeRes(res);
            handleUserLogin({
              appKey: res.appKey,
              account: res.userUuid,
              token: res.userToken,
              isTemporary: true,
            });
            setTimeout(() => {
              getRoomQRCode();
            }, res.expireSeconds * 1000);
          });
        }
        getRoomQRCode();
      }
    }
  }

  function roomEndListener() {
    function handleEnd(reason?: number) {
      // 结束会议，更新信息
      req.getRoomsInfo().then((res) => {
        setRoomsInfo(res);
        setSettings(res.settings);
        if (reason === 2) {
          // 被踢出会议，通知控制器
          res.controls?.forEach((item) => {
            req.sendCustomMessage({
              cmdId: 335,
              toUserUuid: item.account,
              message: '{}',
            });
          });
        }
      });
      //  关闭屏幕共享弹窗
      setScreenSharingVisible(false);

      setInMeeting(false);
      // 暂存入会信息，用于重启恢复入会
      localStorage.removeItem('NetEase-Rooms-Current-Meeting');
      window.ipcRenderer?.send('beforeEnterRoom');
    }
    //@ts-ignore
    NEMeetingKit.actions.on('onMeetingStatusChanged', (status: number) => {
      // 会议状态变更如密码输入框点击取消返回到会前状态
      if (status === 3 || status === 2) {
        handleEnd();
      }
    });
    NEMeetingKit.actions.on('roomEnded', (reason: number) => {
      console.log('roomEnded', reason);
      // 结束会议，更新信息

      handleEnd(reason);
    });
  }

  function onLocalAudioVolumeIndication() {
    const previewRoomContext =
      // @ts-ignore
      NEMeetingKit.actions.neMeeting?.roomService?.getPreviewRoomContext();
    if (previewRoomContext) {
      previewRoomContext.addPreviewRoomListener({
        onPlayoutDeviceChanged: () => {
          reportDevices(deviceInfoRef.current, setDeviceInfo);
        },
        onRecordDeviceChanged: () => {
          reportDevices(deviceInfoRef.current, setDeviceInfo);
        },
        onCameraDeviceChanged: () => {
          reportDevices(deviceInfoRef.current, setDeviceInfo);
        },
        // @ts-ignore
        onLocalAudioVolumeIndication: (volume: number) => {
          if (microphoneTestRef.current !== '') {
            req.sendCustomMessage({
              cmdId: 332,
              toUserUuid: microphoneTestRef.current,
              message: JSON.stringify({ volume }),
            });
          }
        },
      });
    }
  }

  function handleResumeMeeting() {
    const meetingInfo = localStorage.getItem('NetEase-Rooms-Current-Meeting');
    if (meetingInfo) {
      try {
        const joinOptions = JSON.parse(meetingInfo);
        NEMeetingKit.actions.join(joinOptions, function (e: any) {
          setJoiningMeeting(false);
          if (!e) {
            setInMeeting(true);
            handleJoin();
          } else {
            localStorage.removeItem('NetEase-Rooms-Current-Meeting');
            setInMeeting(false);
          }
        });
      } catch {}
    }
  }

  async function getLocalUpdateInfo(): Promise<LocalUpdateInfo> {
    if (localUpdateInfo.versionName) {
      return localUpdateInfo;
    } else {
      return window.ipcRenderer?.invoke(IPCEvent.getLocalUpdateInfo);
    }
  }

  async function checkUpdateBySetting() {
    // 根据本地时区设置凌晨1点执行更新
    const now = new Date();
    const nowTime = now.getTime();
    // 凌晨1点到2点之间随机时间段更新
    const updateMinute = Math.floor(Math.random() * 60) + 1;
    const updateDate = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate(),
      1,
      updateMinute,
      0,
      0,
    );
    const updateDateTime = updateDate.getTime();
    let updateDelay = 0;
    if (updateDateTime > nowTime) {
      updateDelay = updateDateTime - nowTime;
    } else {
      // 如果已经超过今天的凌晨1点则等到第二天凌晨1点
      updateDelay = updateDateTime + 24 * 60 * 60 * 1000 - nowTime;
    }

    async function handleUpdate() {
      if (
        !settingRef.current?.enableAutoUpdate ||
        isCheckingUpdateRef.current
      ) {
        return;
      }
      const macVersion =
        settingRef.current?.updateVersion?.mac?.versionName || '';
      const winVersion =
        settingRef.current?.updateVersion?.pc?.versionName || '';
      // 更新到最新版本
      const updateInfoByCheck: UpdateInfo = await window.ipcRenderer?.invoke(
        IPCEvent.getCheckUpdateInfo,
      );
      const res: any = await axios({
        url: 'https://meeting.netease.im/client/latestVersion',
        method: 'POST',
        headers: {
          clientType: 8,
          sdkVersion: updateInfoByCheck.versionCode,
        },
        data: {
          ...updateInfoByCheck,
          targetVersion:
            localUpdateInfo.platform == 'darwin' ? macVersion : winVersion,
        },
      });
      if (res.data.code != 200 && res.data.code != 0) {
        return;
      }
      const tmpData = res.data.ret;
      if (!tmpData) {
        return;
      }
      updateInfoRef.current = tmpData;
      if (localUpdateInfo.platform == 'darwin') {
        checkUpdate({
          ...tmpData,
        });
      } else if (localUpdateInfo.platform == 'win32') {
        checkUpdate({
          ...tmpData,
        });
      }
    }
    // 测试时候设置延迟10s
    // updateDelay = 10000;
    updateTimer.current && clearTimeout(updateTimer.current);
    updateIntervalTierRef.current &&
      clearInterval(updateIntervalTierRef.current);
    updateTimer.current = setTimeout(() => {
      handleUpdate();
      updateIntervalTierRef.current &&
        clearInterval(updateIntervalTierRef.current);
      // 此后每天这个时间点检测一次
      updateIntervalTierRef.current = setInterval(async () => {
        handleUpdate();
      }, 24 * 60 * 60 * 1000);
    }, updateDelay);
  }

  function handleUserLogin(opts: {
    appKey: string;
    account: string;
    token: string;
    isTemporary?: boolean;
  }) {
    const { appKey, account, token, isTemporary } = opts;

    if (NEMeetingKit.actions.isInitialized) {
      NEMeetingKit.actions.destroy();
    }
    NEMeetingKit.actions.init(
      0,
      0,
      {
        appKey,
        // meetingServerDomain: domain,
        serverUrl: domain,
        useAssetServerConfig: false,
      },
      () => {
        NEMeetingKit.actions.login(
          {
            accountId: account,
            accountToken: token,
            isTemporary,
          },
          (e: any) => {
            console.log('登录结果', e, isTemporary);
            //  临时用户登录成功
            if (!e) {
              if (!isTemporary) {
                req.getRoomsInfo().then((res) => {
                  setRoomsInfo(res);
                  setSettings(res.settings);
                  settingRef.current = res.settings;
                  checkUpdateBySetting();
                  getDeviceAccessStatus(res);
                  getSelectedDeviceInfoFromDevice(res.device);
                });
                roomEndListener();
                onLocalAudioVolumeIndication();
                handleResumeMeeting();
                getLocalUpdateInfo().then((res) => {
                  setLocalUpdateInfo(res);
                });
              } else {
                setActiveStep(1);
              }
            } else {
              if (!isTemporary) {
                req.removeAccountInfo();
                setActiveStep(0);
              }
            }
          },
        );
      },
    );
  }

  function handleActivate(code: string) {
    req.activateRooms(code).then((res) => {
      req.setAccountInfo(res);
      setActiveStep(2);
      return handleUserLogin({
        appKey: res.appKey,
        account: res.userUuid,
        token: res.userToken,
      });
    });
  }

  function handleUnBind() {
    req.deactivateRooms().then(() => {
      req.removeAccountInfo();
      setActiveStep(0);
    });
  }

  function getDeviceAccessStatus(roomsInfo?: RoomsInfo) {
    window.ipcRenderer
      ?.invoke('getDeviceAccessStatus')
      .then(
        ({ camera, microphone }: { camera: string; microphone: string }) => {
          setHasCameraAuthorization(camera !== 'denied');
          setHasMicAuthorization(microphone !== 'denied');

          roomsInfo?.controls?.forEach((item) => {
            const message = JSON.stringify({
              camera: camera !== 'denied',
              microphone: microphone !== 'denied',
            });
            req.sendCustomMessage({
              // 反馈控制器应用权限情况
              cmdId: 339,
              toUserUuid: item.account,
              message,
            });
          });
        },
      );
  }

  function handleJoin() {
    const previewController = NEMeetingKit.actions.neMeeting?.previewController;
    const roomContext = NEMeetingKit.actions.neMeeting?.roomContext;
    window.ipcRenderer?.send('stopPreview');
    window.ipcRenderer?.send('enterRoom');
    // 关闭麦克风测试
    microphoneTestRef.current = '';
    previewController?.stopRecordDeviceTest();
    // 关闭扬声器测试
    clearInterval(speakerTestTimerRef.current);
    previewController?.stopPlayoutDeviceTest();

    // @ts-ignore
    previewController?.enableAudioVolumeIndication(true, 500);

    // @ts-ignore
    previewController?.setRecordDeviceVolume(settings?.micInputVolume ?? 100);

    // @ts-ignore
    previewController?.setPlayoutDeviceVolume(
      settings?.speakerOutputVolume ?? 100,
    );

    const localMember = roomContext?.localMember;
    if (localMember) {
      roomContext?.updateMemberProperty(localMember.uuid, 'rooms_node', '1');
    }
    //  入会后，状态改成 3
    setActiveStep(3);
  }

  async function getSelectedDeviceInfoFromDevice(device: DevicesInfo) {
    const res = await getDevices();
    const { speakList, recordList, cameraList } = res;
    let tmpDeviceInfo: SelectedDeviceInfo = { ...deviceInfo };
    // 当下发的设备本端没有的情况下需要重新上报下设备并切换默认设备
    let needToReport = false;
    const videoDeviceList = device?.video?.in;
    if (
      videoDeviceList &&
      Array.isArray(videoDeviceList) &&
      videoDeviceList.length > 0
    ) {
      const selectedDevice = videoDeviceList.find((item) => {
        return item.selected;
      });
      if (!selectedDevice) {
        needToReport = true;
      } else {
        const exitsIndex = cameraList.findIndex(
          (item) => item.id === selectedDevice?.id,
        );
        if (exitsIndex > -1) {
          tmpDeviceInfo.selectedVideoDeviceId = selectedDevice?.id;
        } else {
          needToReport = true;
        }
      }
    }
    const micDeviceList = device?.audio?.in;
    if (
      micDeviceList &&
      Array.isArray(micDeviceList) &&
      micDeviceList.length > 0
    ) {
      const selectedDevice = micDeviceList.find((item) => {
        return item.selected;
      });
      if (!selectedDevice) {
        needToReport = true;
      } else {
        const exitsIndex = recordList.findIndex(
          (item) => item.id === selectedDevice?.id,
        );
        if (exitsIndex > -1) {
          tmpDeviceInfo.selectedMicDeviceId = selectedDevice?.id;
        } else {
          needToReport = true;
        }
      }
    }
    const speakerDeviceList = device?.audio?.out;
    if (
      speakerDeviceList &&
      Array.isArray(speakerDeviceList) &&
      speakerDeviceList.length > 0
    ) {
      const selectedDevice = speakerDeviceList.find((item) => {
        return item.selected;
      });
      if (!selectedDevice) {
        needToReport = true;
      } else {
        const exitsIndex = speakList.findIndex(
          (item) => item.id === selectedDevice?.id,
        );
        if (exitsIndex > -1) {
          tmpDeviceInfo.selectedSpeakerDeviceId = selectedDevice?.id;
        } else {
          needToReport = true;
        }
      }
    }
    reportDevices(tmpDeviceInfo, setDeviceInfo);
    return tmpDeviceInfo;
  }

  useEffect(() => {
    let isJoining = false;
    const previewController = NEMeetingKit.actions.neMeeting?.previewController;
    function handelRoomsCustomEvent(res: any) {
      const { commandId, senderUuid, data } = res;
      const dataObj = JSON.parse(data);
      if (isCheckingUpdateRef.current) {
        return;
      }
      switch (commandId) {
        case 200:
          const _settings: Settings = dataObj.settings;
          // 设置更新
          if (_settings) {
            setSettings({
              ...settings,
              ..._settings,
            });
          }
          break;
        case 201:
          // 状态更新
          req.getRoomsInfo().then((res) => {
            setRoomsInfo(res);
            setSettings(res.settings);
          });
          break;
        case 203:
          // 控制器解绑
          req.getRoomsInfo().then((res) => {
            setRoomsInfo(res);
            setSettings(res.settings);
          });
          // 关闭扬声器测试
          clearInterval(speakerTestTimerRef.current);
          previewController?.stopPlayoutDeviceTest();

          // 关闭麦克风测试
          microphoneTestRef.current = '';
          previewController?.stopRecordDeviceTest();

          // 关闭视频预览
          window.ipcRenderer?.send('stopPreview');
          videoPreviewRef.current = false;

          break;
        case 204:
          //  反激活
          req.removeAccountInfo();
          setActiveStep(0);
          break;
        case 206:
          //  投屏入会
          if (inMeeting || isJoining || isCheckingUpdateRef.current) {
            return;
          }
          dataObj.video =
            !settings?.videoEnabled || !hasCameraAuthorization ? 2 : 1;
          dataObj.audio =
            !settings?.audioEnabled || !hasMicAuthorization ? 2 : 1;
          isJoining = true;
          setJoiningMeeting(true);
          let joinOptions = {
            ...dataObj,
            isRooms: true,
            enableFixedToolbar: false,
            nickName: roomsInfo?.nickname,
            videoProfile: {
              resolution: 1080,
              frameRate: 30,
            },
          };
          NEMeetingKit.actions.join(joinOptions, function (e: any) {
            isJoining = false;
            setJoiningMeeting(false);
            if (!e) {
              setInMeeting(true);
              handleJoin();
              // 暂存入会信息，用于重启恢复入会
              localStorage.setItem(
                'NetEase-Rooms-Current-Meeting',
                JSON.stringify(joinOptions),
              );
            } else {
              setInMeeting(false);
            }
          });
          break;
        case 207:
          //控制器绑定
          setActiveStep(3);
          // 重启获取RoomsInfo信息
          req.getRoomsInfo().then((res) => {
            setRoomsInfo(res);
            setSettings(res.settings);
          });
          break;
        case 208:
          if (inMeeting || isJoining) {
            return;
          }
          //Rooms检查版本更新指令
          const versionInfo = dataObj.versionInfo;
          updateInfoRef.current = versionInfo;
          setUpdateError({
            showUpdateError: false,
            msg: '',
          });
          checkUpdate(versionInfo, true);
          break;
        case 209:
          // 控制台下发设备切换
          getSelectedDeviceInfoFromDevice(dataObj);
          break;
        case 210:
          // 接收到激活码
          handleActivate(dataObj.code);
          break;
        case 301:
          // 退出应用
          //  延迟执行，是需要给控制器回复消息
          setTimeout(() => {
            window.ipcRenderer?.send('exitApp');
          }, 0);
          break;
        case 302:
          // 重启应用
          //  延迟执行，是需要给控制器回复消息
          setTimeout(() => {
            window.ipcRenderer?.send('restartApp');
          }, 0);
          break;
        case 303:
          // 会议开始
          if (inMeeting || isJoining || isCheckingUpdateRef.current) {
            return;
          }
          dataObj.video =
            dataObj.noVideo ||
            !settings?.videoEnabled ||
            !hasCameraAuthorization
              ? 2
              : 1;
          dataObj.audio =
            dataObj.noAudio || !settings?.audioEnabled || !hasMicAuthorization
              ? 2
              : 1;
          isJoining = true;
          setJoiningMeeting(true);
          joinOptions = {
            ...dataObj,
            isRooms: true,
            enableFixedToolbar: false,
            nickName: roomsInfo?.nickname,
            videoProfile: {
              resolution: 1080,
              frameRate: 30,
            },
          };
          NEMeetingKit.actions.join(joinOptions, function (e: any) {
            isJoining = false;
            setJoiningMeeting(false);
            if (!e) {
              setInMeeting(true);
              handleJoin();
              // 暂存入会信息，用于重启恢复入会
              localStorage.setItem(
                'NetEase-Rooms-Current-Meeting',
                JSON.stringify(joinOptions),
              );
            } else {
              setInMeeting(false);
            }
          });
          break;
        case 304:
          // 会议离开
          NEMeetingKit.actions.neMeeting?.leave();
          // 状态更新
          req.getRoomsInfo().then((res) => {
            setRoomsInfo(res);
            setSettings(res.settings);
          });
          //  强制回到会前页面
          setJoiningMeeting(false);
          setInMeeting(false);
          break;
        case 306:
          // 开始扬声器测试
          previewController?.stopPlayoutDeviceTest();
          previewController?.startPlayoutDeviceTest(
            'https://app.yunxin.163.com/webdemo/audio/rain.mp3',
          );
          clearInterval(speakerTestTimerRef.current);
          speakerTestTimerRef.current = setInterval(() => {
            previewController?.stopPlayoutDeviceTest();
            previewController?.startPlayoutDeviceTest(
              'https://app.yunxin.163.com/webdemo/audio/rain.mp3',
            );
          }, 9 * 1000);
          break;
        case 307:
          // 关闭扬声器测试
          clearInterval(speakerTestTimerRef.current);

          previewController?.stopPlayoutDeviceTest();
          break;
        case 308:
          // 开始麦克风测试
          microphoneTestRef.current = senderUuid;
          // @ts-ignore
          previewController?.startRecordDeviceTest();
          break;
        case 309:
          // 关闭麦克风测试
          microphoneTestRef.current = '';
          previewController?.stopRecordDeviceTest();
          break;
        case 310:
          // 打开视频预览
          window.ipcRenderer?.send('startPreview', {
            mirror: !!settings?.videoMirrorEnabled,
          });
          videoPreviewRef.current = true;
          break;
        case 311:
          // 关闭视频预览
          window.ipcRenderer?.send('stopPreview');
          videoPreviewRef.current = false;
          break;
        case 314:
          // 上传日志
          // @ts-ignore
          NEMeetingKit.actions.neMeeting.uploadLog().then((res) => {
            req.sendCustomMessage({
              //  回复日志
              cmdId: 334,
              toUserUuid: senderUuid,
              message: JSON.stringify({ url: res.data }),
            });
          });
          break;
        case 315:
          // 打开屏幕共享弹窗
          setScreenSharingVisible(true);
          break;
        case 316:
          //  关闭屏幕共享弹窗
          setScreenSharingVisible(false);
          break;
        case 317:
          sendControllerUpdateInfo(senderUuid, dataObj.seq);
          break;
        case 318:
          // 获取应用的设备（摄像头、麦克风）权限
          getDeviceAccessStatus(roomsInfo);
          break;
        case 319:
          // 设备切换 {deviceId: string, type: 'video'|'mic'|'speaker'}
          handleSwitchDevice(dataObj);
          break;
        default:
      }

      if (commandId > 300) {
        // ack 回复
        req.sendCustomMessage({
          cmdId: 300,
          toUserUuid: senderUuid,
          message: data,
        });
      }
    }

    function handleSwitchDevice(data: {
      deviceId: string;
      type: 'video' | 'mic' | 'speaker';
    }) {
      const res: DevicesInfo = {
        name: '',
        model: '',
        video: {
          in: [],
        },
        audio: {
          in: [],
          out: [],
        },
      };
      if (data.type === 'video') {
        res.video.in.push({
          id: data.deviceId,
          name: '',
          selected: true,
          isDefault: false,
        });
      } else if (data.type === 'mic') {
        res.audio.in.push({
          id: data.deviceId,
          name: '',
          selected: true,
          isDefault: false,
        });
      } else {
        res.audio.out.push({
          id: data.deviceId,
          name: '',
          selected: true,
          isDefault: false,
        });
      }
      getSelectedDeviceInfoFromDevice(res);
    }

    function handelRoomsSendEvent(data: { cmdId: number; message?: string }) {
      const { cmdId, message = '{}' } = data;
      roomsInfo?.controls?.forEach((item) => {
        req.sendCustomMessage({
          cmdId,
          toUserUuid: item.account,
          message,
        });
      });
    }

    NEMeetingKit.actions.neMeeting?.eventEmitter.on(
      EventType.RoomsCustomEvent,
      handelRoomsCustomEvent,
    );
    NEMeetingKit.actions.neMeeting?.eventEmitter.on(
      EventType.RoomsSendEvent,
      handelRoomsSendEvent,
    );
    return () => {
      NEMeetingKit.actions.neMeeting?.eventEmitter.off(
        EventType.RoomsCustomEvent,
        handelRoomsCustomEvent,
      );
      NEMeetingKit.actions.neMeeting?.eventEmitter.off(
        EventType.RoomsSendEvent,
        handelRoomsSendEvent,
      );
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [roomsInfo, settings, activeStep, inMeeting]);

  async function sendControllerUpdateInfo(toUserUuid: string, seq: number) {
    let _localUpdateInfo = localUpdateInfo;
    if (!_localUpdateInfo.versionName) {
      _localUpdateInfo = await getLocalUpdateInfo();
      setLocalUpdateInfo(_localUpdateInfo);
    }
    req.sendCustomMessage({
      // 更新controller版本
      cmdId: 336,
      toUserUuid,
      message: JSON.stringify({
        seq,
        ...localUpdateInfo,
      }),
    });
  }

  const checkUpdate = useCallback(
    async (data: ResUpdateInfo, forceUpdate = false) => {
      let updateInfo = localUpdateInfo;
      if (forceUpdate) {
        isCheckingUpdateRef.current = true;
      }
      if (!updateInfo.versionName) {
        try {
          updateInfo = await getLocalUpdateInfo();
          setLocalUpdateInfo(updateInfo);
        } catch (e) {
          //ignore
          console.log('getLocalUpdateInfo Error', e);
        }
      }
      const ipcRenderer = window.ipcRenderer;

      // 判断是否需要更新
      const needUpdate =
        (data?.latestVersionCode || 0) > updateInfo.versionCode;
      console.log('needUpdate', needUpdate);
      if (!needUpdate) {
        isCheckingUpdateRef.current = false;
        return;
      }
      async function handleUpdate(data: ResUpdateInfo) {
        if (needUpdate) {
          setNeedUpdateType(
            forceUpdate ? UpdateType.forceUpdate : UpdateType.normalUpdate,
          );
          let description = data.description;
          try {
            description = await ipcRenderer?.invoke(
              IPCEvent.decodeBase64,
              data.description,
            );
          } catch (e) {
            console.log('decodeBase64 Error', e);
          }
          setUpdateInfo({
            title: data.title || '--',
            description: description || '--',
            version: data.latestVersionName || '--',
          });
          console.log('更新信息', data);
          ipcRenderer
            ?.invoke(IPCEvent.checkUpdate, {
              url: data?.downloadUrl || '',
              md5: data?.checkCode || '',
              forceUpdate: forceUpdate,
            })
            .catch((e: any) => {
              isCheckingUpdateRef.current = false;
            });
        }
      }
      // 判断是否需要强制更新
      if (!inMeeting) {
        handleUpdate(data);
      }
    },
    [inMeeting],
  );

  // useEffect(() => {
  //   if (roomsInfo) {
  //     navigator.mediaDevices.addEventListener('devicechange', reportDevices);
  //     return () => {
  //       navigator.mediaDevices.removeEventListener(
  //         'devicechange',
  //         reportDevices,
  //       );
  //     };
  //   }
  // }, [roomsInfo]);

  useEffect(() => {
    if (roomsInfo && settings) {
      const key = 'NetEase-Rooms-Settings';
      settings.pairingCode = roomsInfo.pairingCode;
      localStorage.setItem(key, JSON.stringify(settings));
    }
  }, [roomsInfo, settings]);

  useEffect(() => {
    // 初始化
    if (navigator.onLine) {
      initRooms();
    }
    function handleOnline() {
      initRooms();
      message.destroy('offline');
    }
    function handleOffline() {
      if (!inMeeting) {
        message.error({
          content: '网络未连接，请检查网络',
          key: 'offline',
          duration: 10000,
        });
      }
    }
    if (!navigator.onLine) {
      handleOffline();
    }

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeStep, inMeeting]);

  useEffect(() => {
    localStorage.setItem('NetEase-Rooms-ActiveStep', activeStep.toString());
    /*
    if (activeStep > 1) {
      req.getRoomsInfo().then((res) => {
        setRoomsInfo(res);
        setSettings(res.settings);
      });
    }
    */
  }, [activeStep]);
  useEffect(() => {
    setUpdateProgress(0);
  }, [needUpdateType]);
  useEffect(() => {
    // electron环境
    const handleUpdateProgress = (_: any, progress: number) => {
      setUpdateProgress(progress);
      if (progress === 100) {
        isCheckingUpdateRef.current = false;
      }
    };
    const handleUpdateError = (_: any, error: any) => {
      // setNeedUpdateType(UpdateType.noUpdate);
      setUpdateProgress(0);
      setUpdateError({
        showUpdateError: true,
        msg: error.message || error.msg || error.code || '未知错误',
      });
      isCheckingUpdateRef.current = false;
    };

    const ipcRenderer = window.ipcRenderer;
    ipcRenderer?.on(IPCEvent.updateProgress, handleUpdateProgress);
    ipcRenderer?.on(IPCEvent.updateError, handleUpdateError);

    return () => {
      const ipcRenderer = window.ipcRenderer;
      ipcRenderer?.off(IPCEvent.updateProgress, handleUpdateProgress);
      ipcRenderer?.off(IPCEvent.updateError, handleUpdateError);
    };
  }, []);

  useEffect(() => {
    getDeviceAccessStatus();
    return () => {
      updateIntervalTierRef.current &&
        clearInterval(updateIntervalTierRef.current);
    };
  }, []);

  return (
    <ConfigProvider
      prefixCls={antdPrefixCls}
      locale={antd_zh_CH}
      theme={{ hashed: false }}
    >
      <>
        <Modal
          className={Styles.roomsUpdateError}
          open={updateError.showUpdateError && !inMeeting}
          title=""
          closable={false}
          width={400}
          footer={null}
        >
          <div className={Styles.errorContent}>
            <div className={Styles.iconWrap}>
              <img
                className={Styles.errorIcon}
                src={require('../../assets/error.png')}
              />
            </div>
            <div className={Styles.errorTitle}>更新失败</div>
            <div className={Styles.errorTip}>{updateError.msg}</div>
            <div className={Styles.retryButtonWrap}>
              {needUpdateType !== UpdateType.forceUpdate && (
                <Button
                  className={Styles.retryNextBtn}
                  onClick={() => {
                    setUpdateError({
                      showUpdateError: false,
                      msg: '',
                    });
                  }}
                >
                  下次再试
                </Button>
              )}

              <Button
                className={Styles.retryBtn}
                type="primary"
                onClick={() => {
                  setUpdateError({
                    showUpdateError: false,
                    msg: '',
                  });
                  updateInfoRef.current &&
                    checkUpdate(
                      updateInfoRef.current,
                      needUpdateType == UpdateType.forceUpdate,
                    );
                }}
              >
                重试
              </Button>
            </div>
          </div>
        </Modal>
        <Modal
          className={Styles.roomsUpdateError}
          closable={false}
          open={
            needUpdateType == UpdateType.forceUpdate &&
            !updateError.showUpdateError &&
            !inMeeting
          }
          footer={null}
        >
          <div className={Styles.errorContent}>
            <div className={Styles.iconWrap}>
              <img
                className={Styles.errorIcon}
                src={require('../../assets/rooms-icon.png')}
              />
            </div>
            <div className={Styles.errorTitle}>
              发现新版本V{updateInfo.version}
            </div>
            <pre className={Styles.versionInfo}>{updateInfo.description}</pre>
            <Progress
              className={Styles.updateProgress}
              percent={updateProgress}
              showInfo={false}
            />
            <div className={Styles.progressPercent}>
              更新中 {updateProgress}%
            </div>
          </div>
        </Modal>
        {inMeeting || joiningMeeting ? null : (
          <div className={Styles.roomsWrapper}>
            <img className={Styles.roomsBackground} src={BackgroundImage} />
            {!hasMicAuthorization || !hasCameraAuthorization ? (
              <AuthorizationTip />
            ) : null}
            <div className={Styles.roomsLeft}>
              {activeStep === 1 && (
                <BeforeActivatePage
                  qrcode={qrCodeRes?.qrcode ?? ''}
                  onActivate={handleActivate}
                />
              )}
              {activeStep === 2 && (
                <RoomsBindPage
                  onUnbind={handleUnBind}
                  onNext={() => setActiveStep(3)}
                  roomsInfo={roomsInfo}
                />
              )}
              {activeStep === 3 && (
                <RoomsHomePage
                  roomsInfo={roomsInfo}
                  screenSharingVisible={screenSharingVisible}
                />
              )}
            </div>
            {activeStep !== 0 && (
              <div className={Styles.roomsFooter}>
                <div className={Styles.footerTitle}>
                  {roomsInfo?.brandInfo?.brandName || '网易会议 Rooms'}
                </div>
                <div className={Styles.footerVersion}>
                  版本号：{localUpdateInfo.versionName}
                </div>
              </div>
            )}
            {activeStep === 3 && (
              <img
                className={Styles.roomsPaired}
                src={noControls ? UnpairedImage : PairedImage}
              />
            )}
            <div
              className={Styles.roomsQuit}
              onClick={() => {
                window.ipcRenderer?.send('exitApp');
              }}
            >
              返回系统桌面 <img src={QuitImage} />
            </div>
          </div>
        )}
      </>
      <div
        id="ne-web-meeting"
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          width: '100%',
          height: '100%',
          display: inMeeting || joiningMeeting ? 'block' : 'none',
        }}
      />
      {screenSharingVisible && (
        <ScreenSharing
          inMeeting={inMeeting}
          roomsInfo={roomsInfo}
          onClose={() => setScreenSharingVisible(false)}
        />
      )}
    </ConfigProvider>
  );
};

export default RoomsPage;
