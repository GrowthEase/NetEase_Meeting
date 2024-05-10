import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined'
import {
  Button,
  Checkbox,
  Menu,
  MenuProps,
  Popover,
  Progress,
  Radio,
  Select,
  Slider,
  Tooltip,
} from 'antd'
import { CheckboxChangeEvent } from 'antd/es/checkbox'
import EventEmitter from 'eventemitter3'
import {
  NECallback,
  NEDeviceBaseInfo,
  NEPreviewController,
  NEPreviewRoomContext,
  NEResult,
} from 'neroom-web-sdk'
import React, { useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../../app/src/types'
import { LOCALSTORAGE_USER_INFO } from '../../../config'
import { EventType, MeetingDeviceInfo, MeetingSetting } from '../../../types'
import {
  checkIsDefaultDevice,
  debounce,
  getDefaultDeviceId,
  setDefaultDevice,
} from '../../../utils'
import BeautySetting from './BeautySetting'
import './index.less'
import MonitoringSetting from './MonitoringSetting'
import SecuritySetting from './SecuritySetting'
import { useAudioSetting, useCanvasSetting } from './useSetting'

const eventEmitter = new EventEmitter()

export type SettingTabType =
  | 'normal'
  | 'video'
  | 'audio'
  | 'beauty'
  | 'virtual'
  | 'security'
  | 'monitoring'

type MenuItem = Required<MenuProps>['items'][number]

const SLIDER_MAX = 100

function getItem(
  label: React.ReactNode,
  key: React.Key,
  icon?: React.ReactNode,
  children?: MenuItem[],
  type?: 'group'
): MenuItem {
  return {
    key,
    icon,
    children,
    label,
    type,
  } as MenuItem
}

interface SettingProps {
  previewController: NEPreviewController
  previewContext?: NEPreviewRoomContext
  onSettingChange: (setting: MeetingSetting) => void
  setting?: MeetingSetting | null
  onDeviceChange?: (
    type: 'video' | 'speaker' | 'microphone',
    deviceId: string,
    deviceName?: string // 只有electron c++时候需要，web和c++ deviceId不一致 需要通过name来辅助判断
  ) => void
  defaultTab?: SettingTabType
  open?: boolean
  inMeeting?: boolean
}

interface NormalSettingProps {
  inMeeting?: boolean
  setting: {
    openVideo: boolean
    openAudio: boolean
    showDurationTime: boolean
    showSpeakerList: boolean
    showToolbar: boolean
    enableTransparentWhiteboard: boolean
    downloadPath: string
    language: string
  }
  onOpenVideoChange: (e: CheckboxChangeEvent) => void
  onOpenAudioChange: (e: CheckboxChangeEvent) => void
  onShowTimeChange: (e: CheckboxChangeEvent) => void
  onShowSpeakerListChange: (e: CheckboxChangeEvent) => void
  onShowToolbarChange: (e: CheckboxChangeEvent) => void
  onEnableTransparentWhiteboardChange: (e: CheckboxChangeEvent) => void
  onDownloadPathChange: (path: string) => void
  onLanguageChange: (value: string) => void
}

interface VideoSettingProps {
  onDeviceChange: (value: string, deviceInfo: MeetingDeviceInfo) => void
  onResolutionChange: (value: number) => void
  onEnableVideoMirroringChange: (e: CheckboxChangeEvent) => void
  onGalleryModeMaxCountChange: (value: number) => void
  videoDeviceList: (NEDeviceBaseInfo & { default?: boolean })[]
  startPreview: (canvas: HTMLElement) => void
  stopPreview: () => Promise<any>
  enableTransparentWhiteboard: boolean
  setting: {
    deviceId: string
    isDefaultDevice?: boolean
    resolution: number
    enableVideoMirroring: boolean
    galleryModeMaxCount: number
  }
}

interface AudioSettingProps {
  setting: {
    recordDeviceId: string
    isDefaultRecordDevice?: boolean
    playoutDeviceId: string
    isDefaultPlayoutDevice?: boolean
    enableUnmuteBySpace: boolean
    recordVolume: number
    playoutVolume: number
    recordOutputVolume?: number
    playouOutputtVolume?: number
    enableAudioAI: boolean
    enableAudioVolumeAutoAdjust: boolean
    enableMusicMode: boolean
    enableAudioEchoCancellation: boolean
    enableAudioStereo: boolean
  }
  inMeeting?: boolean
  onPlayoutOutputChange: (value: number) => void
  onRecordOutputChange: (value: number) => void
  onRecordDeviceChange: (value: string, deviceInfo: MeetingDeviceInfo) => void
  onPlayoutDeviceChange: (value: string, deviceInfo: MeetingDeviceInfo) => void
  recordDeviceList: (NEDeviceBaseInfo & { default?: boolean })[]
  playoutDeviceList: (NEDeviceBaseInfo & { default?: boolean })[]
  onUnmuteAudioBySpaceChange: (e: CheckboxChangeEvent) => void
  startPlayoutDeviceTest: (
    audioSource: string
  ) => Promise<NEResult<null> | undefined>
  stopPlayoutDeviceTest: () => Promise<NEResult<null> | undefined>
  startRecordDeviceTest: (
    callback: NECallback<null>
  ) => Promise<NEResult<null> | undefined>
  stopRecordDeviceTest: () => Promise<NEResult<null> | undefined>
  setCaptureVolume: (volume: number) => void
  setPlaybackVolume: (volume: number) => void
  onEnableAudioAIChange: (e: CheckboxChangeEvent) => void
  onEnableMusicModeChange: (e: CheckboxChangeEvent) => void
  onEnableAudioStereoChange: (e: CheckboxChangeEvent) => void
  onEnableAudioEchoCancellationChange: (e: CheckboxChangeEvent) => void
  onEnableAudioVolumeAutoAdjust: (e: CheckboxChangeEvent) => void
  preMeetingSetting?: MeetingSetting
}

const defaultSetting: MeetingSetting = {
  normalSetting: {
    openVideo: false,
    openAudio: false,
    showDurationTime: false,
    showSpeakerList: true,
    showToolbar: true,
    enableTransparentWhiteboard: false,
    downloadPath: '',
    language: '',
  },
  videoSetting: {
    deviceId: '',
    resolution: 1080,
    enableVideoMirroring: true,
    galleryModeMaxCount: 9,
  },
  audioSetting: {
    recordDeviceId: '',
    playoutDeviceId: '',
    enableUnmuteBySpace: true,
    recordVolume: 0,
    playoutVolume: 0,
    recordOutputVolume: 25,
    playouOutputtVolume: 25,
    enableAudioVolumeAutoAdjust: true, // 自动调节麦克风音量，默认开
    enableAudioAI: true, // 智能降噪，默认开
    enableMusicMode: false, // 音乐模式，默认关
    enableAudioEchoCancellation: true, // 回声消除，默认开，依赖开启音乐模式
    enableAudioStereo: true, // 立体声，默认开，依赖开启音乐模式
  },
  beautySetting: {
    beautyLevel: 0,
    virtualBackgroundPath: '',
  },
}

const NormalSetting: React.FC<NormalSettingProps> = ({
  inMeeting,
  setting,
  onShowSpeakerListChange,
  onShowTimeChange,
  onOpenAudioChange,
  onOpenVideoChange,
  onShowToolbarChange,
  onEnableTransparentWhiteboardChange,
  onDownloadPathChange,
  onLanguageChange,
}) => {
  const { t } = useTranslation()

  const defaultLanguage =
    {
      zh: 'zh-CN',
      en: 'en-US',
      ja: 'ja-JP',
    }[navigator.language.split('-')[0]] || 'en-US'

  const languageValue = setting.language || defaultLanguage

  function handleDownloadPathChange() {
    window.ipcRenderer?.send('nemeeting-download-path', 'set')
    window.ipcRenderer?.once('nemeeting-download-path-reply', (event, arg) => {
      onDownloadPathChange(arg)
    })
  }

  useEffect(() => {
    if (!setting.downloadPath) {
      onDownloadPathChange(
        window.ipcRenderer?.sendSync('nemeeting-download-path', 'get') || ''
      )
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [setting.downloadPath])

  return (
    <div className="setting-wrap normal-setting w-full h-full">
      <div>
        <div className="normal-setting-title">{t('meeting')}</div>
        <div className="normal-setting-item">
          <Checkbox checked={setting.openVideo} onChange={onOpenVideoChange}>
            {t('openCameraInMeeting')}
          </Checkbox>
        </div>

        <div className="normal-setting-item">
          <Checkbox checked={setting.openAudio} onChange={onOpenAudioChange}>
            {t('openMicInMeeting')}
          </Checkbox>
        </div>

        <div className="normal-setting-item">
          <Checkbox
            checked={setting.showDurationTime}
            onChange={onShowTimeChange}
          >
            {t('showMeetingTime')}
          </Checkbox>
        </div>
        <div className="normal-setting-item">
          <Checkbox
            checked={setting.showSpeakerList}
            onChange={onShowSpeakerListChange}
          >
            {t('showCurrentSpeaker')}
          </Checkbox>
        </div>
        <div className="normal-setting-item">
          <Checkbox
            checked={setting.showToolbar}
            onChange={onShowToolbarChange}
          >
            <span>{t('alwaysDisplayToolbar')}</span>
          </Checkbox>
          <Popover
            trigger={'hover'}
            placement={'top'}
            content={
              <div className="toolbar-tip">{t('alwaysDisplayToolbarTip')}</div>
            }
          >
            <svg
              className="icon iconfont icona-45 nemeeting-blacklist-tip"
              aria-hidden="true"
            >
              <use xlinkHref="#icona-45"></use>
            </svg>
          </Popover>
        </div>
        <div className="normal-setting-item">
          <Checkbox
            checked={setting.enableTransparentWhiteboard}
            onChange={onEnableTransparentWhiteboardChange}
          >
            <span>{t('setWhiteboardTransparency')}</span>
          </Checkbox>
          <Popover
            trigger={'hover'}
            placement={'top'}
            content={
              <div className="toolbar-tip">
                {t('setWhiteboardTransparencyTip')}
              </div>
            }
          >
            <svg
              className="icon iconfont icona-45 nemeeting-blacklist-tip"
              aria-hidden="true"
            >
              <use xlinkHref="#icona-45"></use>
            </svg>
          </Popover>
        </div>
      </div>
      {setting.downloadPath && (
        <div>
          <div className="normal-setting-title">{t('file')}</div>
          <div className="normal-setting-item">
            {t('downloadPath')}
            <Button
              type="primary"
              ghost
              style={{ marginLeft: 20 }}
              onClick={handleDownloadPathChange}
            >
              {t('chosePath')}
            </Button>
            <br />
            {setting.downloadPath}
          </div>
        </div>
      )}
      {inMeeting ? null : (
        <div>
          <div className="normal-setting-title">{t('language')}</div>
          <Select
            value={languageValue}
            className="video-device-select"
            suffixIcon={<CaretDownOutlined style={{ pointerEvents: 'none' }} />}
            onChange={onLanguageChange}
            options={[
              { value: 'zh-CN', label: '简体中文' },
              { value: 'en-US', label: 'English' },
              { value: 'ja-JP', label: '日本語' },
            ]}
          />
        </div>
      )}
    </div>
  )
}
const videoProfiles = [
  {
    value: 480,
    label: '480P',
  },
  {
    value: 720,
    label: '720P',
  },
  {
    value: 1080,
    label: '1080P',
  },
]
const VideoSetting: React.FC<VideoSettingProps> = ({
  onDeviceChange,
  onResolutionChange,
  videoDeviceList,
  startPreview,
  onEnableVideoMirroringChange,
  onGalleryModeMaxCountChange,
  stopPreview,
  setting,
}) => {
  const { t } = useTranslation()
  const { videoCanvas, canvasRef } = useCanvasSetting()
  function handleChange(
    deviceId: string,
    deviceInfo: MeetingDeviceInfo | MeetingDeviceInfo[]
  ) {
    onDeviceChange(deviceId, deviceInfo as MeetingDeviceInfo)
  }
  function handleResolutionChange() {
    onResolutionChange(Number(setting.resolution) === 720 ? 1080 : 720)
  }
  const videDeviceName = useMemo(() => {
    if (setting.isDefaultDevice) {
      return videoDeviceList.find((item) => item.default)?.deviceName
    } else {
      return videoDeviceList.find(
        (item) => item.deviceId === setting.deviceId && !item.default
      )?.deviceName
    }
  }, [setting.deviceId, setting.isDefaultDevice, videoDeviceList])
  useEffect(() => {
    if (window.isElectronNative) {
      videoCanvas.current && startPreview(videoCanvas.current)
    } else {
      stopPreview().finally(() => {
        videoCanvas.current && startPreview(videoCanvas.current)
      })
    }
  }, [])
  return (
    <div className="setting-wrap w-full h-full video-setting">
      <div
        ref={videoCanvas}
        className={`video-canvas ${
          setting.enableVideoMirroring ? 'video-mirror' : ''
        }`}
      >
        <canvas className="nemeeting-video-view-canvas" ref={canvasRef} />
      </div>
      <div className="video-setting-item">
        <div className="video-setting-title setting-title camera-label">
          {t('camera')}
        </div>
        <div className="video-setting-content">
          <Select
            value={videDeviceName}
            className="video-device-select"
            fieldNames={{
              label: 'deviceName',
              value: 'deviceName',
            }}
            suffixIcon={<CaretDownOutlined style={{ pointerEvents: 'none' }} />}
            onChange={handleChange}
            options={videoDeviceList}
          />
          <div className="video-mirror-check">
            <Checkbox
              checked={setting.enableVideoMirroring}
              onChange={onEnableVideoMirroringChange}
            >
              {t('mirrorVideo')}
            </Checkbox>
          </div>
          <div className="video-resolution-check">
            <Checkbox
              // disabled={enableTransparentWhiteboard}
              checked={Number(setting.resolution) === 1080}
              onChange={handleResolutionChange}
            >
              {t('HDMode')}{' '}
              <Popover content={t('HDModeTip')}>
                <svg className="icon iconfont icona-45" aria-hidden="true">
                  <use xlinkHref="#icona-45"></use>
                </svg>
              </Popover>
            </Checkbox>
          </div>
        </div>
      </div>
      <div className="video-setting-item">
        <div className="video-setting-title setting-title camera-label">
          {t('layoutSettings')}
        </div>
        <div className="video-setting-content">
          <div className="radio-title">{t('galleryModeMaxCount')}</div>
          <Radio.Group
            value={setting.galleryModeMaxCount}
            defaultValue={16}
            onChange={(e) => onGalleryModeMaxCountChange(e.target.value)}
          >
            <Radio value={9} className="radio-item">
              {t('galleryModeScreens', { count: 9 })}
            </Radio>
            <Radio value={16}>{t('galleryModeScreens', { count: 16 })}</Radio>
          </Radio.Group>
        </div>
      </div>
      {/* <div className="video-setting-item">
        <div className="video-setting-title setting-title">本端分辨率</div>
        <div className="video-setting-content">
          <Radio.Group
            onChange={handleResolutionChange}
            value={Number(setting.resolution)}
          >
            <Space>
              {videoProfiles.map((item) => (
                <Radio key={item.value} value={item.value}>
                  {item.label}
                </Radio>
              ))}
            </Space>
          </Radio.Group>
        </div>
      </div> */}
    </div>
  )
}

const AudioSetting: React.FC<AudioSettingProps> = ({
  onRecordDeviceChange,
  onPlayoutDeviceChange,
  recordDeviceList,
  playoutDeviceList,
  onEnableAudioVolumeAutoAdjust,
  onUnmuteAudioBySpaceChange,
  setting,
  inMeeting,
  startPlayoutDeviceTest,
  stopPlayoutDeviceTest,
  startRecordDeviceTest,
  stopRecordDeviceTest,
  onPlayoutOutputChange,
  onRecordOutputChange,
  setCaptureVolume,
  setPlaybackVolume,
  onEnableAudioAIChange,
  onEnableMusicModeChange,
  onEnableAudioStereoChange,
  onEnableAudioEchoCancellationChange,
  preMeetingSetting,
}) => {
  const { t } = useTranslation()
  const [isStartRecordTest, setIsStartRecordTest] = useState(false)
  const [isStartPlayoutTest, setIsStartPlayoutTest] = useState(false)
  const [recordVolume, setRecordVolume] = useState(0)
  const [playoutVolume, setPlayoutVolume] = useState(0)
  const canvasRef = useRef<HTMLDivElement>(null)
  const playoutVolumeTimerRef = useRef<any | null>(null)
  const playoutTimerRef = useRef<number | NodeJS.Timeout>()
  const playoutVolumeRef = useRef(0)
  const recordVolumeRef = useRef(0)
  playoutVolumeRef.current = setting.playouOutputtVolume || 25
  recordVolumeRef.current = setting.recordOutputVolume || 70
  const isTestRef = useRef({
    isRecordTesting: false,
    isPlayoutTesting: false,
  })
  useAudioSetting(eventEmitter)

  function onTestPlayout() {
    if (isStartPlayoutTest) {
      setPlayoutVolume(0)
      stopPlayTest()
    } else {
      const handler = () => {
        playoutVolumeTimerRef.current = setInterval(() => {
          // 输出音量是0时候不再设置
          const random = playoutVolumeRef.current
            ? Math.floor(Math.random() * (80 - 40 + 1) + 40)
            : 0
          setPlayoutVolume(random)
          // handler()
        }, 100)
      }
      startPlayoutDeviceTest('').then(() => {
        const playouOutputtVolume = playoutVolumeRef.current
        if (playouOutputtVolume || playouOutputtVolume === 0) {
          setPlaybackVolume(playouOutputtVolume)
        }
        setIsStartPlayoutTest(true)
        // if (playoutVolume === 0) {
        //   setPlayoutVolume(0)
        // }
        handler()
      })
      isTestRef.current.isPlayoutTesting = true
      playoutTimerRef.current && clearTimeout(playoutTimerRef.current)
      playoutTimerRef.current = setTimeout(() => {
        stopPlayTest()
      }, 9000)
    }
  }

  function stopPlayTest() {
    playoutTimerRef.current && clearTimeout(playoutTimerRef.current)
    stopPlayoutDeviceTest().then(() => {
      setIsStartPlayoutTest(false)
    })
    isTestRef.current.isPlayoutTesting = false
    if (playoutVolumeTimerRef.current) {
      clearInterval(playoutVolumeTimerRef.current)
      playoutVolumeTimerRef.current = null
      setPlayoutVolume(0)
    }
  }
  function onTestRecord() {
    if (isStartRecordTest) {
      stopRecordDeviceTest().then(() => {
        setIsStartRecordTest(false)
      })
      setRecordVolume(0)
      isTestRef.current.isRecordTesting = false
    } else {
      setRecordVolume(0)
      startRecordDeviceTest((code, level) => {
        setRecordVolume((level as number) / 100)
      }).then(() => {
        const recordOutputVolume = setting.recordOutputVolume
        if (recordOutputVolume || recordOutputVolume === 0) {
          setCaptureVolume(recordOutputVolume)
        }
        setIsStartRecordTest(true)
      })
      isTestRef.current.isRecordTesting = true
    }
  }
  function stopPlay() {
    isTestRef.current.isPlayoutTesting && stopPlayoutDeviceTest()
    isTestRef.current.isRecordTesting && stopRecordDeviceTest()
    playoutVolumeTimerRef.current &&
      clearInterval(playoutVolumeTimerRef.current)

    playoutTimerRef.current && clearTimeout(playoutTimerRef.current)
  }

  useEffect(() => {
    const audioVolumeHandle = (volume: number) => {
      if (isTestRef.current.isRecordTesting && recordVolumeRef.current > 0) {
        setRecordVolume(volume)
      }
    }
    eventEmitter.on(EventType.RtcLocalAudioVolumeIndication, audioVolumeHandle)
    return () => {
      eventEmitter.removeListener(
        EventType.RtcLocalAudioVolumeIndication,
        audioVolumeHandle
      )
      stopPlay()
    }
  }, [])
  useEffect(() => {
    if (setting.recordOutputVolume === 0) {
      setRecordVolume(0)
    }
  }, [setting.recordOutputVolume])
  const recordDeviceName = useMemo(() => {
    if (checkIsDefaultDevice(setting.recordDeviceId)) {
      return recordDeviceList.find((item) => item.default)?.deviceName
    } else {
      return recordDeviceList.find(
        (item) => item.deviceId === setting.recordDeviceId && !item.default
      )?.deviceName
    }
  }, [setting.recordDeviceId, recordDeviceList])
  const playoutDeviceName = useMemo(() => {
    if (checkIsDefaultDevice(setting.playoutDeviceId)) {
      return playoutDeviceList.find((item) => item.default)?.deviceName
    } else {
      return playoutDeviceList.find(
        (item) => item.deviceId === setting.playoutDeviceId && !item.default
      )?.deviceName
    }
  }, [setting.playoutDeviceId, playoutDeviceList])
  useEffect(() => {
    setIsStartPlayoutTest(false)
    setPlayoutVolume(0)
    setIsStartRecordTest(false)
    setRecordVolume(0)
    stopPlay()
  }, [recordDeviceList, playoutDeviceList])
  return (
    <div className="setting-wrap audio-setting w-full h-full" ref={canvasRef}>
      <div className="video-setting-item">
        <div className="setting-title">{t('speaker')}</div>
        <div className="video-setting-content">
          <div className="audio-select-wrap">
            <Select
              value={playoutDeviceName}
              className="audio-device-select"
              suffixIcon={
                <CaretDownOutlined style={{ pointerEvents: 'none' }} />
              }
              disabled={isStartRecordTest || isStartPlayoutTest}
              fieldNames={{
                label: 'deviceName',
                value: 'deviceName',
              }}
              //@ts-ignore
              onChange={onPlayoutDeviceChange}
              options={playoutDeviceList}
            />
            <Button
              disabled={inMeeting || isStartRecordTest}
              style={{ minWidth: '110px', marginLeft: '20px' }}
              onClick={onTestPlayout}
              shape="round"
              className="test-btn"
              type="primary"
            >
              {isStartPlayoutTest ? t('stopTest') : t('testSpeaker')}
            </Button>
          </div>
          <div className="output-level">
            <span className="output-level-title">{t('outputLevel')}</span>
            <Progress
              strokeColor={'#337EFF'}
              className="output-leve-progress"
              percent={playoutVolume}
              showInfo={false}
            />
          </div>
          <div className="output-level output-volume">
            <span className="output-level-title">{t('outputVolume')}</span>
            <div className="output-level-content">
              <svg
                width="9"
                height="14"
                viewBox="0 0 9 14"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M2.70929 4.0619H0.827344C0.385516 4.0619 0.0273437 4.42007 0.0273437 4.8619V8.92711C0.0273437 9.36894 0.385516 9.72711 0.827344 9.72711H2.70929L7.05487 13.5684C7.60477 13.9807 8.0434 13.7551 8.0434 13.0708V0.718249C8.0434 0.0426065 7.60075 -0.188691 7.05487 0.220699L2.70929 4.0619Z"
                  fill="#666666"
                />
              </svg>
              <Slider
                max={SLIDER_MAX}
                onChange={onPlayoutOutputChange}
                className="output-slider"
                defaultValue={setting.playouOutputtVolume}
              />
              <svg
                width="16"
                height="14"
                viewBox="0 0 16 14"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M2.70929 4.0619H0.827344C0.385516 4.0619 0.0273437 4.42007 0.0273437 4.8619V8.92711C0.0273437 9.36894 0.385516 9.72711 0.827344 9.72711H2.70929L7.05487 13.5684C7.60477 13.9807 8.0434 13.7551 8.0434 13.0708V0.718249C8.0434 0.0426065 7.60075 -0.188691 7.05487 0.220699L2.70929 4.0619Z"
                  fill="#666666"
                />
                <path
                  d="M10.3179 10C11.2806 9.33796 11.9119 8.22869 11.9119 6.97198C11.9119 5.75008 11.3151 4.66757 10.3971 4"
                  stroke="#666666"
                  strokeWidth="1.3"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
                <path
                  d="M12.6984 12.461C14.2956 11.178 15.318 9.20869 15.318 7.00057C15.318 4.78395 14.2877 2.80798 12.6799 1.52539"
                  stroke="#666666"
                  strokeWidth="1.3"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </div>
          </div>
        </div>
      </div>
      <div className="video-setting-item">
        <div className="setting-title">{t('microphone')}</div>
        <div className="video-setting-content">
          <div className="audio-select-wrap">
            <Select
              value={recordDeviceName}
              className="audio-device-select"
              suffixIcon={
                <CaretDownOutlined style={{ pointerEvents: 'none' }} />
              }
              fieldNames={{
                label: 'deviceName',
                value: 'deviceName',
              }}
              disabled={isStartRecordTest || isStartPlayoutTest}
              //@ts-ignore
              onChange={onRecordDeviceChange}
              options={recordDeviceList}
            />
            <Button
              disabled={inMeeting || isStartPlayoutTest}
              style={{ minWidth: '110px', marginLeft: '20px' }}
              onClick={onTestRecord}
              shape="round"
              className="test-btn"
              type="primary"
            >
              {isStartRecordTest ? t('stopTest') : t('testMicrophone')}
            </Button>
          </div>
          <div className="output-level">
            <span className="output-level-title">{t('InputLevel')}</span>
            <Progress
              strokeColor={'#337EFF'}
              className="output-leve-progress"
              percent={recordVolume}
              showInfo={false}
            />
          </div>
          <div className="output-level output-volume">
            <span className="output-level-title">{t('inputVolume')}</span>
            <div className="output-level-content">
              <svg
                width="9"
                height="14"
                viewBox="0 0 9 14"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M2.70929 4.0619H0.827344C0.385516 4.0619 0.0273437 4.42007 0.0273437 4.8619V8.92711C0.0273437 9.36894 0.385516 9.72711 0.827344 9.72711H2.70929L7.05487 13.5684C7.60477 13.9807 8.0434 13.7551 8.0434 13.0708V0.718249C8.0434 0.0426065 7.60075 -0.188691 7.05487 0.220699L2.70929 4.0619Z"
                  fill="#666666"
                />
              </svg>
              <Slider
                max={SLIDER_MAX}
                value={setting.recordOutputVolume}
                onChange={onRecordOutputChange}
                className="output-slider"
                defaultValue={setting.recordOutputVolume}
                disabled={
                  setting.enableAudioVolumeAutoAdjust && window.isElectronNative
                }
              />
              <svg
                width="16"
                height="14"
                viewBox="0 0 16 14"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M2.70929 4.0619H0.827344C0.385516 4.0619 0.0273437 4.42007 0.0273437 4.8619V8.92711C0.0273437 9.36894 0.385516 9.72711 0.827344 9.72711H2.70929L7.05487 13.5684C7.60477 13.9807 8.0434 13.7551 8.0434 13.0708V0.718249C8.0434 0.0426065 7.60075 -0.188691 7.05487 0.220699L2.70929 4.0619Z"
                  fill="#666666"
                />
                <path
                  d="M10.3179 10C11.2806 9.33796 11.9119 8.22869 11.9119 6.97198C11.9119 5.75008 11.3151 4.66757 10.3971 4"
                  stroke="#666666"
                  strokeWidth="1.3"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
                <path
                  d="M12.6984 12.461C14.2956 11.178 15.318 9.20869 15.318 7.00057C15.318 4.78395 14.2877 2.80798 12.6799 1.52539"
                  stroke="#666666"
                  strokeWidth="1.3"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </div>
          </div>
          {window.isElectronNative ? (
            <>
              <Checkbox
                className="checkbox-space"
                checked={setting.enableAudioVolumeAutoAdjust}
                onChange={onEnableAudioVolumeAutoAdjust}
              >
                {t('autoAdjustMicVolume')}
              </Checkbox>
              <br />
            </>
          ) : (
            <></>
          )}
          <Checkbox
            className="checkbox-space"
            checked={setting.enableUnmuteBySpace}
            onChange={onUnmuteAudioBySpaceChange}
          >
            {t('pressSpaceBarToMute')}
          </Checkbox>
        </div>
      </div>
      {window.isElectronNative ? (
        <div className="video-setting-item more-setting-item">
          <div className="setting-title">{t('advancedSettings')}</div>
          <div className="video-setting-content">
            {/* 若会前未选择，则会中不可用 */}
            <Checkbox
              disabled={
                inMeeting && !preMeetingSetting?.audioSetting?.enableAudioAI
              }
              className=""
              checked={setting.enableAudioAI}
              onChange={onEnableAudioAIChange}
            >
              {t('audioNoiseReduction')}
            </Checkbox>
            <div className="voice-quality-content">
              <Checkbox
                disabled={inMeeting}
                className="checkbox-space"
                checked={setting.enableMusicMode}
                onChange={onEnableMusicModeChange}
              >
                {t('musicModeAndProfessionalMode')}
              </Checkbox>
              <div className="sub-setting-quality">
                {setting.enableMusicMode ? (
                  <>
                    <Checkbox
                      disabled={
                        inMeeting &&
                        !preMeetingSetting?.audioSetting?.enableMusicMode
                      }
                      className="check-space"
                      checked={setting.enableAudioEchoCancellation}
                      onChange={onEnableAudioEchoCancellationChange}
                    >
                      {t('echoCancellation')}
                    </Checkbox>
                    <br />
                    <Checkbox
                      disabled={inMeeting}
                      className="check-space"
                      checked={setting.enableAudioStereo}
                      onChange={onEnableAudioStereoChange}
                    >
                      {t('activateStereo')}
                    </Checkbox>
                  </>
                ) : (
                  <Tooltip
                    arrow={false}
                    title={t('musicModeAndProfessionalModeTips')}
                    getPopupContainer={(triggerNode) =>
                      triggerNode.parentElement || triggerNode
                    }
                    overlayClassName="voice-quality-tooltip"
                    placement="bottom"
                  >
                    <Checkbox
                      disabled={true}
                      className="check-space"
                      checked={setting.enableAudioEchoCancellation}
                      onChange={onEnableAudioEchoCancellationChange}
                    >
                      {t('echoCancellation')}
                    </Checkbox>
                    <br />
                    <Checkbox
                      disabled={true}
                      className="check-space"
                      checked={setting.enableAudioStereo}
                      onChange={onEnableAudioStereoChange}
                    >
                      {t('activateStereo')}
                    </Checkbox>
                  </Tooltip>
                )}
              </div>
            </div>
          </div>
        </div>
      ) : (
        <></>
      )}
    </div>
  )
}

const Setting: React.FC<SettingProps> = ({
  previewController,
  previewContext,
  setting,
  onSettingChange,
  onDeviceChange,
  defaultTab = 'normal',
  inMeeting,
  ...resProps
}) => {
  const { t, i18n } = useTranslation()
  const [showBeauty, setShowBeauty] = useState(false)
  const [showSecurity, setShowSecurity] = useState(false)
  const [normalSetting, setNormalSetting] = useState(
    setting?.normalSetting || {
      openVideo: false,
      openAudio: false,
      showDurationTime: false,
      showSpeakerList: true,
      showToolbar: true,
      enableTransparentWhiteboard: false,
      downloadPath: '',
      language: '',
    }
  )

  const [videoSetting, setVideoSetting] = useState(
    setting?.videoSetting || {
      deviceId: '',
      isDefaultDevice: false,
      resolution: 720,
      enableVideoMirroring: true,
      galleryModeMaxCount: 9,
    }
  )

  const [audioSetting, setAudioSetting] = useState(
    setting?.audioSetting || {
      recordDeviceId: '',
      isDefaultRecordDevice: false,
      playoutDeviceId: '',
      isDefaultPlayoutDevice: false,
      enableAudioVolumeAutoAdjust: true, // 自动调节麦克风音量，默认开
      enableUnmuteBySpace: true,
      recordVolume: 0,
      playoutVolume: 0,
      recordOutputVolume: 70, // 如果默认开启自动调节需要设置为70
      playouOutputtVolume: 25,
      enableAudioAI: true, // 智能降噪，默认开
      enableMusicMode: false, // 音乐模式，默认关
      enableAudioEchoCancellation: true, // 回声消除，默认开，依赖开启音乐模式
      enableAudioStereo: true, // 立体声，默认开，依赖开启音乐模式
    }
  )

  const [beautySetting, setBeautySetting] = useState(
    setting?.beautySetting || {
      beautyLevel: 0,
      virtualBackgroundPath: '',
    }
  )

  const [currenMenuKey, setCurrenMenuKey] = useState<SettingTabType>(defaultTab)
  const [videoDeviceList, setVideoDeviceList] = useState<NEDeviceBaseInfo[]>([])
  const [recordDeviceList, setRecordDeviceList] = useState<NEDeviceBaseInfo[]>(
    []
  )
  const [playoutDeviceList, setPlayoutDeviceList] = useState<
    NEDeviceBaseInfo[]
  >([])
  const [virtualBackgroundList, setVirtualBackgroundList] = useState<
    {
      src: string
      path: string
      isDefault: boolean
    }[]
  >([])
  const [preMeetingSetting, setPreMeetingSetting] = useState<MeetingSetting>()
  const settingRef = useRef(setting)

  settingRef.current = setting

  // 当前在哪个播放状态
  const testVideoStateRef = useRef(false)

  const MenuItems: MenuItem[] = useMemo(() => {
    const defaultMenus = [
      getItem(
        t('general'),
        'normal',
        <svg className={'icon iconfont icon-menu '} aria-hidden="true">
          {currenMenuKey === 'normal' ? (
            <use xlinkHref="#iconsetting-basic-selected"></use>
          ) : (
            <use xlinkHref="#iconsetting-basic"></use>
          )}
        </svg>
      ),
      getItem(
        t('audio'),
        'audio',
        <svg className={'icon iconfont icon-menu'} aria-hidden="true">
          {currenMenuKey === 'audio' ? (
            <use xlinkHref="#iconsetting-audio-selected"></use>
          ) : (
            <use xlinkHref="#iconsetting-audio"></use>
          )}
        </svg>
      ),
      getItem(
        t('video'),
        'video',
        <svg className={'icon iconfont icon-menu '} aria-hidden="true">
          {currenMenuKey === 'video' ? (
            <use xlinkHref="#iconsetting-video-selected"></use>
          ) : (
            <use xlinkHref="#iconsetting-video"></use>
          )}
        </svg>
      ),
    ]
    if (showBeauty) {
      defaultMenus.push(
        getItem(
          <span title={t('beautySettingTitle')}>
            {t('beautySettingTitle')}
          </span>,
          'beauty',
          <svg className={'icon iconfont icon-menu '} aria-hidden="true">
            {currenMenuKey === 'beauty' ? (
              <use xlinkHref="#iconsetting-beauty-selected"></use>
            ) : (
              <use xlinkHref="#iconsetting-beauty"></use>
            )}
          </svg>
        )
      )
    }
    if (showSecurity) {
      defaultMenus.push(
        getItem(
          t('accountAndSecurity'),
          'security',
          <svg className={'icon iconfont icon-menu '} aria-hidden="true">
            {currenMenuKey === 'security' ? (
              <use xlinkHref="#iconsetting-account-selected"></use>
            ) : (
              <use xlinkHref="#iconsetting-account"></use>
            )}
          </svg>
        )
      )
    }
    if (window.isElectronNative && inMeeting) {
      defaultMenus.push(
        getItem(
          t('monitoring'),
          'monitoring',
          <svg className={'icon iconfont icon-menu '} aria-hidden="true">
            {currenMenuKey === 'monitoring' ? (
              <use xlinkHref="#iconsetting-monitoring-selected"></use>
            ) : (
              <use xlinkHref="#iconsetting-monitoring"></use>
            )}
          </svg>
        )
      )
    }
    return defaultMenus
  }, [showBeauty, showSecurity, i18n.language, inMeeting, currenMenuKey])

  const handleMenuItems = () => {
    const globalConfig = JSON.parse(
      localStorage.getItem('nemeeting-global-config') || '{}'
    )
    console.log('>>>>> localStorage globalConfig in setting', globalConfig)

    const userInfoStr = localStorage.getItem(LOCALSTORAGE_USER_INFO)
    if (userInfoStr) {
      try {
        const userInfo = JSON.parse(userInfoStr || '{}')
        setShowSecurity(userInfo?.loginType !== 'normal')
      } catch (error) {}
    }
    if (
      window.ipcRenderer &&
      (!!globalConfig?.appConfig?.MEETING_VIRTUAL_BACKGROUND?.enable ||
        !!globalConfig?.appConfig?.MEETING_BEAUTY?.enable)
    ) {
      setShowBeauty(true)
    } else {
      setShowBeauty(false)
    }
  }

  // useEffect(() => {
  //   if (recordDeviceList.length > 0 && !setting?.audioSetting.recordDeviceId) {
  //     setAudioSetting({
  //       ...audioSetting,
  //       recordDeviceId: recordDeviceList[0].deviceId,
  //     })
  //   }
  // }, [recordDeviceList])

  // useEffect(() => {
  //   if (
  //     playoutDeviceList.length > 0 &&
  //     !setting?.audioSetting.playoutDeviceId
  //   ) {
  //     console.log('设置1', setting?.audioSetting)
  //     setAudioSetting({
  //       ...audioSetting,
  //       playoutDeviceId: playoutDeviceList[0].deviceId,
  //     })
  //   }
  // }, [playoutDeviceList])

  // electron 当设置和会议页面同时打开，会议页面切换摄像头 设置页面需要同步
  useEffect(() => {
    if (setting && setting.videoSetting.deviceId != videoSetting.deviceId) {
      const deviceId = getDefaultDeviceId(setting.videoSetting.deviceId)
      previewController?.switchDevice({
        type: 'camera',
        deviceId,
      })
      if (window.isElectronNative) {
        window.ipcRenderer?.send(IPCEvent.previewController, {
          method: 'switchDevice',
          args: [
            {
              type: 'camera',
              deviceId,
            },
          ],
        })
      }
      setVideoSetting({
        ...videoSetting,
        deviceId: setting.videoSetting.deviceId,
      })
    }
  }, [setting?.videoSetting.deviceId])

  useEffect(() => {
    if (setting) {
      onSettingChange?.({
        ...setting,
        audioSetting: { ...audioSetting },
      })
    } else {
      onSettingChange?.({
        normalSetting,
        videoSetting,
        beautySetting,
        audioSetting: { ...audioSetting },
      })
    }
  }, [audioSetting])

  useEffect(() => {
    if (setting) {
      onSettingChange?.({
        ...setting,
        normalSetting: { ...normalSetting },
      })
    } else {
      onSettingChange?.({
        videoSetting,
        audioSetting,
        beautySetting,
        normalSetting: { ...normalSetting },
      })
    }
  }, [normalSetting])

  useEffect(() => {
    if (setting) {
      onSettingChange?.({
        ...setting,
        videoSetting: { ...videoSetting },
      })
    } else {
      onSettingChange?.({
        normalSetting,
        audioSetting,
        beautySetting,
        videoSetting: { ...videoSetting },
      })
    }
  }, [videoSetting])

  useEffect(() => {
    if (setting) {
      onSettingChange?.({
        ...setting,
        beautySetting: { ...beautySetting },
      })
    } else {
      onSettingChange?.({
        videoSetting,
        audioSetting,
        normalSetting,
        beautySetting: { ...beautySetting },
      })
    }
  }, [beautySetting])

  useEffect(() => {
    getPreMeetingSetting()
    // 新窗口模式需要延迟1s获取，否则会中页面会获取不到
    getDevices(true)
    function handleDeviceChange(e) {
      getDevices()
    }
    handleMenuItems()
    const debounceHandle = debounce(handleDeviceChange, 1000)
    navigator.mediaDevices.addEventListener('devicechange', debounceHandle)
    window.ipcRenderer?.on(
      'nemeeting-beauty-virtual-background',
      (_, value) => {
        setVirtualBackgroundList(value)
      }
    )
    function handleMessage(e: MessageEvent) {
      const { event } = e.data
      if (event === 'openSetting') {
        getDevices(true)
      }
    }
    window.addEventListener('message', handleMessage)
    return () => {
      window.removeEventListener('message', handleMessage)
      navigator.mediaDevices.removeEventListener('devicechange', debounceHandle)
    }
  }, [i18n.language])

  useEffect(() => {
    if (previewContext) {
      const virtualBackgroundPath =
        settingRef.current?.beautySetting.virtualBackgroundPath
      console.log('virtualBackgroundPath>>>>>', virtualBackgroundPath)
      if (virtualBackgroundPath) {
        //@ts-ignore
        // previewController?.enableVirtualBackground(
        //   !!virtualBackgroundPath,
        //   virtualBackgroundPath
        // )
      }

      const previewRoomListener = {
        onLocalAudioVolumeIndication: (volume) => {
          eventEmitter.emit(EventType.RtcLocalAudioVolumeIndication, volume)
        },
        onRtcVirtualBackgroundSourceEnabled: (enabled, reason) => {
          eventEmitter.emit(EventType.rtcVirtualBackgroundSourceEnabled, {
            enabled,
            reason,
          })
        },
        // onVideoFrameData: (uuid, bSubVideo, data, type, width, height) => {
        //   eventEmitter.emit(
        //     EventType.previewVideoFrameData,
        //     uuid,
        //     bSubVideo,
        //     data,
        //     type,
        //     width,
        //     height
        //   )
        // },
      }
      //@ts-ignore
      previewContext.addPreviewRoomListener(previewRoomListener)

      return () => {
        //@ts-ignore
        previewContext.removePreviewRoomListener(previewRoomListener)
      }
    }
  }, [previewContext])

  function getPreMeetingSetting() {
    const _setting = localStorage.getItem('ne-meeting-pre-meeting-setting')
    if (_setting) {
      try {
        const setting = JSON.parse(_setting) as MeetingSetting
        setPreMeetingSetting(setting)
      } catch (error) {}
    }
  }

  function getDevices(init = false) {
    let _setting = init ? undefined : settingRef.current
    if (!_setting) {
      const tmpSetting = localStorage.getItem('ne-meeting-setting')
      if (tmpSetting) {
        try {
          _setting = JSON.parse(tmpSetting) as MeetingSetting
          setAudioSetting(_setting.audioSetting)
          setVideoSetting(_setting.videoSetting)
          setNormalSetting(_setting.normalSetting)
        } catch (e) {
          _setting = defaultSetting
        }
      } else {
        _setting = defaultSetting
      }
    }
    if (previewController) {
      //@ts-ignore
      previewController.enumCameraDevices().then(({ data }) => {
        data = setDefaultDevice(data)
        setVideoDeviceList(data)
        const deviceId = _setting?.videoSetting.deviceId
        const isDefaultDevice = checkIsDefaultDevice(
          _setting?.videoSetting.deviceId
        )
        let selectedDeviceId = deviceId as string
        if (data.length > 0) {
          if (!deviceId) {
            selectedDeviceId = data[0].deviceId
            setVideoSetting({
              ..._setting!.videoSetting,
              deviceId: selectedDeviceId,
              isDefaultDevice: data[0].defaultDevice,
            })
          } else {
            let currentDevice: MeetingDeviceInfo
            // 如果当前选择的是默认设备,则需要根据当前系统设备
            if (isDefaultDevice) {
              currentDevice = data.find((item) => !!item.defaultDevice)
            } else {
              currentDevice = data.find(
                (item) => item.deviceId == deviceId && !item.default
              )
            }
            if (currentDevice) {
              selectedDeviceId = currentDevice.deviceId
              setVideoSetting({
                ..._setting!.videoSetting,
                deviceId: selectedDeviceId,
                isDefaultDevice,
              })
            } else {
              const deviceId = data[0].deviceId
              // 如果当前正在播放视频，则判断移除的设备是否是当前选择的
              if (testVideoStateRef.current) {
                onVideoDeviceChange(deviceId, data[0])
              } else {
                selectedDeviceId = data[0].deviceId
                setVideoSetting({
                  ..._setting!.videoSetting,
                  deviceId: data[0].deviceId,
                  isDefaultDevice,
                })
              }
            }
          }
          if (selectedDeviceId != _setting?.videoSetting.deviceId) {
            const defaultDeviceId = getDefaultDeviceId(selectedDeviceId)
            previewController?.switchDevice({
              type: 'camera',
              deviceId: defaultDeviceId,
            })
            if (window.isElectronNative) {
              window.ipcRenderer?.send(IPCEvent.previewController, {
                method: 'switchDevice',
                args: [
                  {
                    type: 'camera',
                    deviceId: defaultDeviceId,
                  },
                ],
              })
            }
          }
        } else {
          setVideoSetting({
            ..._setting!.videoSetting,
            deviceId: '',
          })
        }
      })
      let _audioSetting = { ..._setting!.audioSetting }
      //@ts-ignore
      previewController.enumRecordDevices().then(({ data }) => {
        data = setDefaultDevice(data)
        setRecordDeviceList(data)
        const recordDeviceId = _setting?.audioSetting.recordDeviceId
        const isDefaultDevice = checkIsDefaultDevice(recordDeviceId)
        let selectedDeviceId = recordDeviceId as string
        if (data.length > 0) {
          if (!recordDeviceId) {
            selectedDeviceId = data[0].deviceId
            _audioSetting.recordDeviceId = selectedDeviceId
            _audioSetting.isDefaultRecordDevice = data[0].defaultDevice
          } else {
            let currentDevice: MeetingDeviceInfo
            // 如果当前选择的是默认设备,则需要根据当前系统设备
            if (isDefaultDevice) {
              currentDevice = data.find((item) => !!item.defaultDevice)
            } else {
              currentDevice = data.find(
                (item) => item.deviceId == recordDeviceId && !item.default
              )
            }
            if (currentDevice) {
              selectedDeviceId = currentDevice.deviceId
              _audioSetting.recordDeviceId = selectedDeviceId
              _audioSetting = {
                ..._audioSetting,
                recordDeviceId: selectedDeviceId,
                isDefaultRecordDevice: isDefaultDevice,
              }
            } else {
              selectedDeviceId = data[0].deviceId
              _audioSetting.recordDeviceId = selectedDeviceId
              _audioSetting.isDefaultRecordDevice = isDefaultDevice
            }
          }
          if (selectedDeviceId != _audioSetting.recordDeviceId) {
            const defaultDeviceId = getDefaultDeviceId(selectedDeviceId)
            previewController?.switchDevice({
              type: 'microphone',
              deviceId: defaultDeviceId,
            })
            if (window.isElectronNative) {
              window.ipcRenderer?.send(IPCEvent.previewController, {
                method: 'switchDevice',
                args: [
                  {
                    type: 'microphone',
                    deviceId: defaultDeviceId,
                  },
                ],
              })
            }
          }
        } else {
          _audioSetting.recordDeviceId = ''
        }
        previewController
          //@ts-ignore
          .enumPlayoutDevices()
          .then(({ data }) => {
            data = setDefaultDevice(data)
            setPlayoutDeviceList(data)
            const playoutDeviceId = _setting?.audioSetting.playoutDeviceId
            const isDefaultDevice = checkIsDefaultDevice(
              _setting?.audioSetting.playoutDeviceId
            )
            let selectedDeviceId = playoutDeviceId as string
            if (data.length > 0) {
              if (!playoutDeviceId) {
                selectedDeviceId = data[0].deviceId
                _audioSetting.playoutDeviceId = selectedDeviceId
                _audioSetting.isDefaultPlayoutDevice = data[0].defaultDevice
              } else {
                let currentDevice: MeetingDeviceInfo
                // 如果当前选择的是默认设备,则需要根据当前系统设备
                if (isDefaultDevice) {
                  currentDevice = data.find((item) => !!item.defaultDevice)
                } else {
                  currentDevice = data.find(
                    (item) => item.deviceId == playoutDeviceId && !item.default
                  )
                }
                if (currentDevice) {
                  selectedDeviceId = playoutDeviceId
                  _audioSetting.playoutDeviceId = playoutDeviceId
                  _audioSetting.isDefaultPlayoutDevice = isDefaultDevice
                } else {
                  selectedDeviceId = data[0].deviceId
                  _audioSetting.playoutDeviceId = selectedDeviceId
                  _audioSetting.isDefaultPlayoutDevice = isDefaultDevice
                }
              }
              if (selectedDeviceId != _audioSetting.playoutDeviceId) {
                const defaultDeviceId = getDefaultDeviceId(selectedDeviceId)
                previewController?.switchDevice({
                  type: 'speaker',
                  deviceId: defaultDeviceId,
                })

                if (window.isElectronNative) {
                  window.ipcRenderer?.send(IPCEvent.previewController, {
                    method: 'switchDevice',
                    args: [
                      {
                        type: 'speaker',
                        deviceId: defaultDeviceId,
                      },
                    ],
                  })
                }
              }
            } else {
              _audioSetting.playoutDeviceId = ''
            }
          })
          .finally(() => {
            setAudioSetting(_audioSetting)
          })
      })
    }
  }
  function onOpenVideoChange(e: CheckboxChangeEvent) {
    setNormalSetting({
      ...normalSetting,
      openVideo: e.target.checked,
    })
  }
  function onOpenAudioChange(e: CheckboxChangeEvent) {
    setNormalSetting({
      ...normalSetting,
      openAudio: e.target.checked,
    })
  }
  function onShowSpeakerListChange(e: CheckboxChangeEvent) {
    setNormalSetting({
      ...normalSetting,
      showSpeakerList: e.target.checked,
    })
  }
  function onShowTimeChange(e: CheckboxChangeEvent) {
    setNormalSetting({
      ...normalSetting,
      showDurationTime: e.target.checked,
    })
  }
  function onShowToolbarChange(e: CheckboxChangeEvent) {
    setNormalSetting({
      ...normalSetting,
      showToolbar: e.target.checked,
    })
  }
  function onDownloadPathChange(path: string) {
    setNormalSetting({
      ...normalSetting,
      downloadPath: path,
    })
  }

  function onLanguageChange(language: string) {
    i18n.changeLanguage(language)
    setNormalSetting({
      ...normalSetting,
      language,
    })
  }

  function onEnableTransparentWhiteboardChange(e: CheckboxChangeEvent) {
    setNormalSetting({
      ...normalSetting,
      enableTransparentWhiteboard: e.target.checked,
    })
  }
  function onHandleMenuClick(e) {
    setCurrenMenuKey(e.key)
  }

  // 摄像头设备切换
  function onVideoDeviceChange(
    deviceName: string,
    deviceInfo: MeetingDeviceInfo
  ) {
    setVideoSetting({
      ...videoSetting,
      deviceId: deviceInfo.deviceId,
      isDefaultDevice: deviceInfo.default,
    })
    onDeviceChange?.('video', deviceInfo?.deviceId, deviceInfo?.deviceName)
    const deviceId = getDefaultDeviceId(deviceInfo?.deviceId)
    previewController?.switchDevice({
      type: 'camera',
      deviceId,
    })
    if (window.isElectronNative) {
      window.ipcRenderer?.send(IPCEvent.previewController, {
        method: 'switchDevice',
        args: [
          {
            type: 'camera',
            deviceId,
          },
        ],
      })
    }
  }

  // 分辨率变更
  function onResolutionChange(resolution: number) {
    console.log('onResolutionChange', resolution)
    setVideoSetting({
      ...videoSetting,
      resolution,
    })
  }

  function getVirtualBackground() {
    window.ipcRenderer?.invoke('getVirtualBackground').then((list) => {
      setVirtualBackgroundList(list)
    })
  }

  // 麦克风设备切换
  function onRecordDeviceChange(
    deviceName: string,
    deviceInfo: MeetingDeviceInfo
  ) {
    setAudioSetting({
      ...audioSetting,
      recordDeviceId: deviceInfo?.deviceId,
      isDefaultRecordDevice: deviceInfo?.default,
    })
    onDeviceChange?.('microphone', deviceInfo?.deviceId, deviceInfo?.deviceName)
    const deviceId = getDefaultDeviceId(deviceInfo?.deviceId)
    previewController?.switchDevice({
      type: 'microphone',
      deviceId,
    })
    if (window.isElectronNative) {
      window.ipcRenderer?.send(IPCEvent.previewController, {
        method: 'switchDevice',
        args: [
          {
            type: 'microphone',
            deviceId,
          },
        ],
      })
    }
  }

  // 扬声器设备切换
  function onPlayoutDeviceChange(
    deviceName: string,
    deviceInfo: MeetingDeviceInfo
  ) {
    console.log('onPlayoutDeviceChange', deviceInfo)
    setAudioSetting({
      ...audioSetting,
      playoutDeviceId: deviceInfo?.deviceId,
      isDefaultPlayoutDevice: deviceInfo?.default,
    })
    onDeviceChange?.('speaker', deviceInfo?.deviceId, deviceInfo?.deviceName)

    const deviceId = getDefaultDeviceId(deviceInfo?.deviceId)
    previewController?.switchDevice({
      type: 'speaker',
      deviceId,
    })
    if (window.isElectronNative) {
      window.ipcRenderer?.send(IPCEvent.previewController, {
        method: 'switchDevice',
        args: [
          {
            type: 'speaker',
            deviceId,
          },
        ],
      })
    }
  }
  function onPlayoutOutputChange(value: number) {
    try {
      // electron下需要调用
      // @ts-ignore
      if (window.isElectronNative) {
        // @ts-ignore
        previewController.adjustPlaybackSignalVolume(value)
      } else {
        // @ts-ignore
        previewController._rtc?._client?.setPlaybackVolume(value)
      }
    } catch (e) {}
    setAudioSetting({
      ...audioSetting,
      playouOutputtVolume: value,
    })
  }
  function setPlaybackVolume(volume: number) {
    // @ts-ignore
    previewController._rtc?._client?.setPlaybackVolume(volume)
  }

  function setCaptureVolume(volume: number) {
    // @ts-ignore
    previewController._rtc?.localStream?.setCaptureVolume(volume)
  }

  function onRecordOutputChange(value: number) {
    try {
      // @ts-ignore
      if (previewController.setRecordDeviceVolume) {
        // @ts-ignore
        previewController.setRecordDeviceVolume(value)
      } else {
        // @ts-ignore
        previewController._rtc?.localStream.setCaptureVolume(value)
      }
    } catch (e) {}
    setAudioSetting({
      ...audioSetting,
      recordOutputVolume: value,
    })
  }

  // 设置自动调节麦克风音量
  function onEnableAudioVolumeAutoAdjust(e: CheckboxChangeEvent) {
    const options = { ...audioSetting }
    if (e.target.checked) {
      onRecordOutputChange(70)
      options.recordOutputVolume = 70
    }
    setAudioSetting({
      ...options,
      enableAudioVolumeAutoAdjust: e.target.checked,
    })
  }

  // 是否设置长按空格解除静音
  function onUnmuteAudioBySpaceChange(e: CheckboxChangeEvent) {
    setAudioSetting({
      ...audioSetting,
      enableUnmuteBySpace: e.target.checked,
    })
  }

  function onEnableAudioAIChange(e: CheckboxChangeEvent) {
    const checked = e.target.checked
    setAudioSetting({
      ...audioSetting,
      enableAudioAI: checked,
      enableMusicMode: checked ? false : audioSetting.enableMusicMode,
    })
  }

  function onEnableMusicModeChange(e: CheckboxChangeEvent) {
    const checked = e.target.checked
    setAudioSetting({
      ...audioSetting,
      enableMusicMode: checked,
      enableAudioAI: checked ? false : audioSetting.enableAudioAI,
    })
  }
  function onEnableAudioStereoChange(e: CheckboxChangeEvent) {
    setAudioSetting({
      ...audioSetting,
      enableAudioStereo: e.target.checked,
    })
  }
  function onEnableAudioEchoCancellationChange(e: CheckboxChangeEvent) {
    setAudioSetting({
      ...audioSetting,
      enableAudioEchoCancellation: e.target.checked,
    })
  }

  function startPreview(view: HTMLElement) {
    testVideoStateRef.current = true
    if (window.isElectronNative) {
      !inMeeting && previewController?.setupLocalVideoCanvas(view)

      // if(window.isWins32) {
      // windows 如果设置页面和会中页面同时打开设备会占用，所以统一到会中渲染进程开启
      window.ipcRenderer?.send(IPCEvent.previewController, {
        method: 'startPreview',
        args: [null, videoSetting.enableVideoMirroring],
      })
      // }else {
      //   previewController?.startPreview({
      //     // @ts-ignore
      //     view,
      //     mirror: videoSetting.enableVideoMirroring,
      //   })
      // }
    } else {
      previewController?.startPreview(view)
    }
  }
  async function stopPreview() {
    testVideoStateRef.current = false
    if (window.isElectronNative) {
      window.ipcRenderer?.send(IPCEvent.previewController, {
        method: 'stopPreview',
        args: [videoSetting.enableVideoMirroring],
      })
      return true
    } else {
      //@ts-ignore electron 关闭时候需要用到mirror参数
      return previewController?.stopPreview(videoSetting.enableVideoMirroring)
    }
  }
  function onGalleryModeMaxCountChange(value: number) {
    setVideoSetting({
      ...videoSetting,
      galleryModeMaxCount: value,
    })
  }
  function onEnableVideoMirroringChange(e: CheckboxChangeEvent) {
    setVideoSetting({
      ...videoSetting,
      enableVideoMirroring: e.target.checked,
    })
    //@ts-ignore
    previewController.changeMirror?.(e.target.checked)
  }
  async function startPlayoutDeviceTest() {
    return previewController?.startPlayoutDeviceTest(
      'https://app.yunxin.163.com/webdemo/audio/rain.mp3'
    )
  }
  async function stopPlayoutDeviceTest() {
    return previewController?.stopPlayoutDeviceTest()
  }
  async function startRecordDeviceTest(callback) {
    // @ts-ignore
    previewController?.setRecordDeviceVolume?.(0)
    return previewController?.startRecordDeviceTest(callback).then((res) => {
      //Electron下需要设置一次否则入会后再打开设置界面监听到的音量为0
      //@ts-ignore
      previewController?.setRecordDeviceVolume?.(
        settingRef.current?.audioSetting.recordOutputVolume
      )
      return res
    })
  }
  async function stopRecordDeviceTest() {
    return previewController?.stopRecordDeviceTest()
  }

  useEffect(() => {
    setCurrenMenuKey(defaultTab)
  }, [resProps.open, defaultTab])

  useEffect(() => {
    getVirtualBackground()
    return () => {
      stopPreview()
    }
  }, [])

  useEffect(() => {
    if (['beauty', 'video'].includes(currenMenuKey)) {
      testVideoStateRef.current = true
    } else {
      if (window.isElectronNative) {
        stopPreview()
      }
    }
  }, [currenMenuKey])

  const getDisplayMenuItems = () => {
    return [...MenuItems]
  }

  return (
    <div className="nemeeting-setting-content">
      <div className={'menu-wrap'}>
        <Menu
          className="setting-menu"
          onClick={onHandleMenuClick}
          defaultSelectedKeys={[currenMenuKey]}
          selectedKeys={[currenMenuKey]}
          items={getDisplayMenuItems()}
        />
      </div>
      <div className="setting-content">
        {currenMenuKey === 'normal' && (
          <NormalSetting
            inMeeting={inMeeting}
            onEnableTransparentWhiteboardChange={
              onEnableTransparentWhiteboardChange
            }
            setting={normalSetting}
            onOpenAudioChange={onOpenAudioChange}
            onOpenVideoChange={onOpenVideoChange}
            onShowSpeakerListChange={onShowSpeakerListChange}
            onShowTimeChange={onShowTimeChange}
            onShowToolbarChange={onShowToolbarChange}
            onDownloadPathChange={onDownloadPathChange}
            onLanguageChange={onLanguageChange}
          />
        )}
        {currenMenuKey === 'video' && (
          <VideoSetting
            enableTransparentWhiteboard={
              normalSetting.enableTransparentWhiteboard
            }
            onEnableVideoMirroringChange={onEnableVideoMirroringChange}
            onGalleryModeMaxCountChange={onGalleryModeMaxCountChange}
            setting={videoSetting}
            startPreview={startPreview}
            stopPreview={stopPreview}
            videoDeviceList={videoDeviceList}
            onDeviceChange={onVideoDeviceChange}
            onResolutionChange={onResolutionChange}
          />
        )}
        {currenMenuKey === 'audio' && (
          <AudioSetting
            setPlaybackVolume={setPlaybackVolume}
            setCaptureVolume={setCaptureVolume}
            startPlayoutDeviceTest={startPlayoutDeviceTest}
            stopPlayoutDeviceTest={stopPlayoutDeviceTest}
            startRecordDeviceTest={startRecordDeviceTest}
            stopRecordDeviceTest={stopRecordDeviceTest}
            // 解决Electron会中同时打开设置，修改配置设置未及时同步问题
            setting={setting ? setting.audioSetting : audioSetting}
            onRecordDeviceChange={onRecordDeviceChange}
            onPlayoutDeviceChange={onPlayoutDeviceChange}
            onUnmuteAudioBySpaceChange={onUnmuteAudioBySpaceChange}
            onPlayoutOutputChange={onPlayoutOutputChange}
            onRecordOutputChange={onRecordOutputChange}
            onEnableAudioAIChange={onEnableAudioAIChange}
            onEnableMusicModeChange={onEnableMusicModeChange}
            onEnableAudioStereoChange={onEnableAudioStereoChange}
            onEnableAudioEchoCancellationChange={
              onEnableAudioEchoCancellationChange
            }
            onEnableAudioVolumeAutoAdjust={onEnableAudioVolumeAutoAdjust}
            playoutDeviceList={playoutDeviceList}
            recordDeviceList={recordDeviceList}
            inMeeting={inMeeting}
            preMeetingSetting={preMeetingSetting}
          />
        )}
        {currenMenuKey === 'security' && <SecuritySetting />}
        {currenMenuKey === 'beauty' && (
          <BeautySetting
            inMeeting={inMeeting}
            eventEmitter={eventEmitter}
            previewController={previewController}
            enableVideoMirroring={videoSetting.enableVideoMirroring}
            virtualBackgroundList={virtualBackgroundList}
            getVirtualBackground={getVirtualBackground}
            virtualBackgroundPath={beautySetting.virtualBackgroundPath}
            mirror={videoSetting.enableVideoMirroring}
            beautyLevel={beautySetting.beautyLevel}
            onBeautyLevelChange={(level) => {
              setBeautySetting({
                ...beautySetting,
                beautyLevel: level,
              })
            }}
            onVirtualBackgroundChange={(path) => {
              setBeautySetting({
                ...beautySetting,
                virtualBackgroundPath: path,
              })
            }}
          />
        )}
        {currenMenuKey === 'monitoring' && <MonitoringSetting />}
      </div>
    </div>
  )
}

export default Setting
