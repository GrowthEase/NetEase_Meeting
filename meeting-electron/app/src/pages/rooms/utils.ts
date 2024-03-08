import { DevicesInfo, SelectedDeviceInfo } from '@/types';
import NEMeetingKit from '../../../../src/index';
import req from './request';

let globalSerialNumber = ''; // 设备序列号

type Device = {
  id: string;
  name: string;
  selected: boolean; // 系统默认设备
  isDefault: boolean; // 控制台下发切换的设备 非默认设备意思相当于isSelected
};

type Devices = {
  cameraList: Device[];
  recordList: Device[];
  speakList: Device[];
};

export function getDevices(): Promise<Devices> {
  function formatDevices(data: any) {
    return data
      .filter((item: any) => !item.unavailable)
      .map((item: any) => ({
        id: item.deviceId,
        name: item.deviceName,
        isDefault: item.defaultDevice,
      }));
  }
  const previewController = NEMeetingKit.actions.neMeeting?.previewController;
  return Promise.all([
    //@ts-ignore
    previewController?.enumCameraDevices(),
    //@ts-ignore
    previewController?.enumRecordDevices(),
    //@ts-ignore
    previewController?.enumPlayoutDevices(),
  ]).then((res) => {
    const [cameraList, recordList, playoutList] = res;
    return {
      cameraList: formatDevices(cameraList?.data),
      recordList: formatDevices(recordList?.data),
      speakList: formatDevices(playoutList?.data),
    };
  });
}

// 获取设备序列号
async function getCurrentSerialNumber(): Promise<string> {
  return new Promise((resolve) => {
    window.ipcRenderer?.invoke('get-system-info').then((res) => {
      globalSerialNumber = res?.serial;
      resolve(res?.serial);
    });
  });
}

export function reportDevices(
  selectedDeviceInfo: SelectedDeviceInfo,
  setDeviceInfo: any,
): Promise<{ data: DevicesInfo; deviceInfo: SelectedDeviceInfo }> {
  return getDevices().then(async (res) => {
    const serialNumber =
      globalSerialNumber || (await getCurrentSerialNumber()) || '';
    const data = {
      name: serialNumber,
      model: '',
      video: {
        in: res.cameraList,
      },
      audio: {
        in: res.recordList,
        out: res.speakList,
      },
    };
    const tmpDeviceInfo = { ...selectedDeviceInfo };
    const videoDeviceList = data.video.in;
    const videoIndex = videoDeviceList.findIndex(
      (item) => item.id == tmpDeviceInfo.selectedVideoDeviceId,
    );
    // 当前选中的设备已不存在
    if (videoIndex < 0) {
      const defaultIndex = videoDeviceList.findIndex((item) => item.isDefault);
      tmpDeviceInfo.selectedVideoDeviceId =
        defaultIndex > -1
          ? videoDeviceList[defaultIndex].id
          : videoDeviceList[0]?.id || '';
      if (defaultIndex > -1) {
        videoDeviceList[defaultIndex].selected = true;
      } else if (videoDeviceList.length > 0) {
        videoDeviceList[0].selected = true;
      }
    } else {
      videoDeviceList[videoIndex].selected = true;
    }
    const audioInDeviceList = data.audio.in;
    const audioInIndex = audioInDeviceList.findIndex(
      (item) => item.id == tmpDeviceInfo.selectedMicDeviceId,
    );
    if (audioInIndex < 0) {
      const defaultIndex = audioInDeviceList.findIndex(
        (item) => item.isDefault,
      );
      tmpDeviceInfo.selectedMicDeviceId =
        defaultIndex > -1
          ? audioInDeviceList[defaultIndex].id
          : audioInDeviceList[0]?.id || '';
      if (defaultIndex > -1) {
        audioInDeviceList[defaultIndex].selected = true;
      } else if (audioInDeviceList.length > 0) {
        audioInDeviceList[0].selected = true;
      }
    } else {
      audioInDeviceList[audioInIndex].selected = true;
    }
    const audioOutDeviceList = data.audio.out;
    const audioOutIndex = audioOutDeviceList.findIndex(
      (item) => item.id == tmpDeviceInfo.selectedSpeakerDeviceId,
    );
    if (audioOutIndex < 0) {
      const defaultIndex = audioOutDeviceList.findIndex(
        (item) => item.isDefault,
      );
      tmpDeviceInfo.selectedSpeakerDeviceId =
        defaultIndex > -1
          ? audioOutDeviceList[defaultIndex].id
          : audioOutDeviceList[0]?.id || '';
      if (defaultIndex > -1) {
        audioOutDeviceList[defaultIndex].selected = true;
      } else if (audioOutDeviceList.length > 0) {
        audioOutDeviceList[0].selected = true;
      }
    } else {
      audioOutDeviceList[audioOutIndex].selected = true;
    }
    req.reportDevices(data);
    setDeviceInfo(tmpDeviceInfo);
    return { data, deviceInfo: tmpDeviceInfo };
  });
}

export function getVersionCode(version: string) {
  const verArr = version.split('.');
  let versionCode = 0;
  if (verArr[0]) {
    versionCode += parseInt(verArr[0]) * 10000;
  }
  if (verArr[1]) {
    versionCode += parseInt(verArr[1]) * 100;
  }
  if (verArr[2]) {
    versionCode += parseInt(verArr[2]);
  }
  return versionCode;
}
