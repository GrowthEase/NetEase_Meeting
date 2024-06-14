import NEMeetingKit from '../../../../src/index';
import { useEffect } from 'react';
import { Settings } from './request';
import { NERoomBeautyEffectType } from '../../../../src/types';
import { message } from 'antd';
import { getDevices } from './utils';
import { SelectedDeviceInfo } from '@/types';

export function useDevices(
  settings: Settings | undefined,
  inMeeting: boolean,
  deviceInfo: SelectedDeviceInfo,
): void {
  const previewController = NEMeetingKit.actions.neMeeting?.previewController;

  useEffect(() => {
    if (inMeeting) {
      getDevices().then((res) => {
        if (
          res.cameraList.length === 0 ||
          res.recordList.length === 0 ||
          res.speakList.length === 0
        ) {
          message.error('设备异常，请检查音视频设备');
        }
      });
    }
  }, [inMeeting]);

  useEffect(() => {
    if (deviceInfo?.selectedSpeakerDeviceId && inMeeting) {
      getDevices().then((res) => {
        const { speakList } = res;
        const device = speakList.find(
          (item) => item.id === deviceInfo?.selectedSpeakerDeviceId,
        );

        if (device) {
          message.info('当前扬声器设备：' + device.name);
        }
      });
    }
  }, [deviceInfo?.selectedSpeakerDeviceId, inMeeting]);

  useEffect(() => {
    if (deviceInfo?.selectedSpeakerDeviceId) {
      previewController?.switchDevice({
        type: 'speaker',
        deviceId: deviceInfo?.selectedSpeakerDeviceId,
      });
    }
  }, [deviceInfo?.selectedSpeakerDeviceId, previewController]);

  useEffect(() => {
    if (deviceInfo?.selectedMicDeviceId && inMeeting) {
      getDevices().then((res) => {
        const { recordList } = res;
        const device = recordList.find(
          (item) => item.id === deviceInfo?.selectedMicDeviceId,
        );

        if (device) {
          message.info('当前麦克风设备：' + device.name);
        }
      });
    }
  }, [deviceInfo?.selectedMicDeviceId, inMeeting]);

  useEffect(() => {
    if (deviceInfo?.selectedMicDeviceId) {
      previewController?.switchDevice({
        type: 'microphone',
        deviceId: deviceInfo?.selectedMicDeviceId,
      });
    }
  }, [deviceInfo?.selectedMicDeviceId, previewController]);

  useEffect(() => {
    if (deviceInfo?.selectedVideoDeviceId && inMeeting) {
      getDevices().then((res) => {
        const { cameraList } = res;
        const device = cameraList.find(
          (item) => item.id === deviceInfo?.selectedVideoDeviceId,
        );

        if (device) {
          message.info('当前摄像头设备：' + device.name);
        }
      });
    }
  }, [deviceInfo?.selectedVideoDeviceId, inMeeting]);

  useEffect(() => {
    if (deviceInfo?.selectedVideoDeviceId) {
      previewController?.switchDevice({
        type: 'camera',
        deviceId: deviceInfo?.selectedVideoDeviceId,
      });
    }
  }, [deviceInfo?.selectedVideoDeviceId, previewController]);

  useEffect(() => {
    if (settings?.speakerOutputVolume !== undefined) {
      // @ts-ignore
      previewController?.setPlayoutDeviceMute?.(
        settings?.speakerOutputVolume === 0,
      );
      // @ts-ignore
      previewController?.setPlayoutDeviceVolume(settings?.speakerOutputVolume);
    }
  }, [settings?.speakerOutputVolume, previewController]);

  useEffect(() => {
    if (settings?.micInputVolume !== undefined) {
      // @ts-ignore
      previewController?.setRecordDeviceMute?.(settings?.micInputVolume === 0);
      // @ts-ignore
      previewController?.setRecordDeviceVolume(settings?.micInputVolume);
    }
  }, [settings?.micInputVolume, previewController]);

  useEffect(() => {
    // @ts-ignore
    previewController?.enableAudioAINS(!!settings?.audioAINSEnabled);
  }, [settings?.audioAINSEnabled, previewController]);

  useEffect(() => {
    // @ts-ignore
    window.ipcRenderer?.send('videoMirrorChange', {
      mirror: !!settings?.videoMirrorEnabled,
    });
  }, [settings?.videoMirrorEnabled]);

  useEffect(() => {
    if (settings?.videoBeautyEnabled) {
      // @ts-ignore
      previewController?.startBeauty?.();
      // @ts-ignore
      previewController?.enableBeauty?.(true);
      // @ts-ignore
      previewController?.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautyWhiten,
        0.8,
      );
      // @ts-ignore
      previewController?.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautySmooth,
        0.65,
      );
      // @ts-ignore
      previewController?.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautyFaceRuddy,
        0.3,
      );
      // @ts-ignore
      previewController?.setBeautyEffect?.(
        NERoomBeautyEffectType.kNERoomBeautyFaceSharpen,
        0.1,
      );
    } else {
      // 兼容部分系统，先重置美颜参数，再关闭美颜
      // @ts-ignore
      previewController?.enableBeauty?.(false);
      // @ts-ignore
      previewController?.stopBeauty?.();
    }
  }, [settings?.videoBeautyEnabled, previewController]);
}
