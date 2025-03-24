import { EventType, MeetingDeviceInfo, MeetingSetting } from '../../../types'
import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined'

import {
  NECallback,
  NEDeviceBaseInfo,
  NEPreviewController,
  NEResult,
} from 'neroom-types'
import { CheckboxChangeEvent } from 'antd/es/checkbox'
import { useAudioSetting } from './useSetting'
import { useTranslation } from 'react-i18next'
import React, { useEffect, useMemo, useRef, useState } from 'react'
import { Button, Checkbox, Progress, Select, Slider, Tooltip } from 'antd'
import EventEmitter from 'eventemitter3'
import { checkIsDefaultDevice, getDefaultDeviceId } from '../../../utils'
import './index.less'
import { IPCEvent } from '../../../app/src/types'
import { useMount } from 'ahooks'

const eventEmitter = new EventEmitter()
const SLIDER_MAX = 100

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
    usingComputerAudio: boolean
  }
  previewController: NEPreviewController
  openAudio: boolean
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
  onOpenAudioChange: (e: CheckboxChangeEvent) => void
  onUsingComputerAudioChange: (e: CheckboxChangeEvent) => void
  preMeetingSetting?: MeetingSetting
}
const AudioSetting: React.FC<AudioSettingProps> = ({
  onRecordDeviceChange,
  onPlayoutDeviceChange,
  onOpenAudioChange,
  onUsingComputerAudioChange,
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
  openAudio,
  previewController,
}) => {
  const { t } = useTranslation()
  const [isStartRecordTest, setIsStartRecordTest] = useState(false)
  const [isStartPlayoutTest, setIsStartPlayoutTest] = useState(false)
  const [recordVolume, setRecordVolume] = useState(0)
  const [playoutVolume, setPlayoutVolume] = useState(0)
  const canvasRef = useRef<HTMLDivElement>(null)
  const playoutVolumeTimerRef = useRef<null | ReturnType<typeof setTimeout>>(
    null
  )
  const playoutTimerRef = useRef<null | ReturnType<typeof setTimeout>>()
  const playoutVolumeRef = useRef(0)
  const recordVolumeRef = useRef(0)
  const inMeetingRef = useRef(inMeeting)

  inMeetingRef.current = inMeeting

  playoutVolumeRef.current = setting.playouOutputtVolume ?? 70

  recordVolumeRef.current = setting.recordOutputVolume ?? 70
  const isTestRef = useRef({
    isRecordTesting: false,
    isPlayoutTesting: false,
  })

  useAudioSetting(eventEmitter)

  // 用于解决当接入耳机，但是设置中选中的其他设备。如果不强制设置一次，那rtc内部使用的是耳机，ui显示的是其他设备
  useMount(() => {
    const deviceId = getDefaultDeviceId(setting.playoutDeviceId)

    if (!inMeetingRef.current && deviceId && previewController) {
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
  })

  function onTestPlayout() {
    if (isStartPlayoutTest) {
      setPlayoutVolume(0)
      stopPlayTest()
    } else {
      const handler = () => {
        playoutVolumeTimerRef.current = setInterval(() => {
          // 输出音量是0时候不再设置
          const max = playoutVolumeRef.current

          const random = Math.floor(Math.random() * (max + 1))

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
        setRecordVolume(level as number)
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

  useEffect(() => {
    previewController?.getPlayoutDeviceVolume?.().then((volume) => {
      volume && onPlayoutOutputChange((volume / 255) * 100)
    })
  }, [setting.playoutDeviceId])

  return (
    <div className="setting-wrap audio-setting w-full h-full" ref={canvasRef}>
      <div className="video-setting-item">
        <div
          className="setting-title"
          style={{
            fontWeight: 'bold',
          }}
        >
          {t('speaker')}
        </div>
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
              onChange={onPlayoutDeviceChange}
              options={playoutDeviceList}
            />
            <Button
              disabled={inMeeting || isStartRecordTest}
              style={{ minWidth: '110px', marginLeft: '20px', borderRadius: 4 }}
              onClick={onTestPlayout}
              shape="round"
              className="test-btn"
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
              steps={10}
              size={[36, 8]}
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
                value={setting.playouOutputtVolume}
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
        <div
          style={{
            fontWeight: 'bold',
          }}
          className="setting-title setting-title-mic"
        >
          {t('microphone')}
        </div>
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
              onChange={onRecordDeviceChange}
              options={recordDeviceList}
            />
            <Button
              disabled={inMeeting || isStartPlayoutTest}
              style={{ minWidth: '110px', marginLeft: '20px', borderRadius: 4 }}
              onClick={onTestRecord}
              shape="round"
              className="test-btn"
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
              steps={10}
              size={[36, 8]}
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
                className="checkbox-space checkbox-space-top"
                checked={setting.enableAudioVolumeAutoAdjust}
                onChange={onEnableAudioVolumeAutoAdjust}
              >
                {t('autoAdjustMicVolume')}
              </Checkbox>
            </>
          ) : (
            <></>
          )}
          <Checkbox
            className="checkbox-space"
            checked={openAudio}
            onChange={onOpenAudioChange}
          >
            {t('openMicInMeeting')}
          </Checkbox>
          <Checkbox
            className="checkbox-space"
            checked={setting.usingComputerAudio}
            onChange={onUsingComputerAudioChange}
          >
            {t('usingComputerAudioInMeeting')}
          </Checkbox>
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
          <div
            style={{
              fontWeight: 'bold',
            }}
            className="setting-title"
          >
            {t('advancedSettings')}
          </div>
          <div className="video-setting-content">
            {/* 若会前未选择，则会中不可用 */}
            <Checkbox
              className=""
              checked={setting.enableAudioAI}
              onChange={onEnableAudioAIChange}
            >
              {t('audioNoiseReduction')}
            </Checkbox>
            <div className="voice-quality-content">
              <Checkbox
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
                      className="check-space"
                      checked={setting.enableAudioEchoCancellation}
                      onChange={onEnableAudioEchoCancellationChange}
                    >
                      {t('echoCancellation')}
                    </Checkbox>
                    <Checkbox
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

export default AudioSetting
