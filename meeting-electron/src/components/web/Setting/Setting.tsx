import { Menu, MenuProps } from 'antd'
import { CheckboxChangeEvent } from 'antd/es/checkbox'
import EventEmitter from 'eventemitter3'
import {
  NEDeviceBaseInfo,
  NEPreviewController,
  NEPreviewRoomContext,
} from 'neroom-web-sdk'
import React, { useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../../app/src/types'
import {
  LOCALSTORAGE_USER_INFO,
  PLAYOUT_DEFAULT_VOLUME,
  RECORD_DEFAULT_VOLUME,
} from '../../../config'
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
import VideoSetting from './VideoSetting'
import AudioSetting from './AudioSetting'
import NormalSetting from './NormalSetting'

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

const defaultSetting: MeetingSetting = {
  normalSetting: {
    openVideo: false,
    openAudio: false,
    showDurationTime: false,
    showSpeakerList: true,
    showToolbar: true,
    enableTransparentWhiteboard: false,
    enableVoicePriorityDisplay: true,
    downloadPath: '',
    language: '',
  },
  videoSetting: {
    deviceId: '',
    resolution: 720,
    enableVideoMirroring: true,
    galleryModeMaxCount: 9,
  },
  audioSetting: {
    recordDeviceId: '',
    playoutDeviceId: '',
    enableUnmuteBySpace: true,
    recordVolume: 0,
    playoutVolume: 0,
    recordOutputVolume: RECORD_DEFAULT_VOLUME,
    playouOutputtVolume: PLAYOUT_DEFAULT_VOLUME,
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
  const settingRightRef = useRef<HTMLDivElement>(null)

  const [normalSetting, setNormalSetting] = useState(
    setting?.normalSetting || {
      openVideo: false,
      openAudio: false,
      showDurationTime: false,
      showSpeakerList: true,
      showToolbar: true,
      enableTransparentWhiteboard: false,
      enableVoicePriorityDisplay: true,
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
      recordOutputVolume: RECORD_DEFAULT_VOLUME, // 如果默认开启自动调节需要设置为70
      playouOutputtVolume: PLAYOUT_DEFAULT_VOLUME,
      enableAudioAI: true, // 智能降噪，默认开
      enableMusicMode: false, // 音乐模式，默认关
      enableAudioEchoCancellation: true, // 回声消除，默认开，依赖开启音乐模式
      enableAudioStereo: true, // 立体声，默认开，依赖开启音乐模式
      openAudio: false, // 入会打开麦克风
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
  }, [showBeauty, showSecurity, inMeeting, currenMenuKey, t])

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
      } catch (error) {
        console.error('error', error)
      }
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
    function handleDeviceChange() {
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
      } catch (error) {
        console.error('getPreMeetingSetting error', error)
      }
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
            _setting &&
              setVideoSetting({
                ..._setting.videoSetting,
                deviceId: selectedDeviceId,
                isDefaultDevice: data[0].defaultDevice,
              })
          } else {
            let currentDevice: MeetingDeviceInfo | undefined

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
              _setting &&
                setVideoSetting({
                  ..._setting.videoSetting,
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
                _setting &&
                  setVideoSetting({
                    ..._setting.videoSetting,
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
          _setting &&
            setVideoSetting({
              ..._setting.videoSetting,
              deviceId: selectedDeviceId,
              isDefaultDevice,
            })
        }
      })
      let _audioSetting = { ..._setting.audioSetting }

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
            let currentDevice: MeetingDeviceInfo | undefined

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
                let currentDevice: MeetingDeviceInfo | undefined

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

  function onEnableVoicePriorityDisplay(e: CheckboxChangeEvent) {
    setNormalSetting({
      ...normalSetting,
      enableVoicePriorityDisplay: e.target.checked,
    })
  }

  function onHandleMenuClick(e) {
    setCurrenMenuKey(e.key)
    const { current } = settingRightRef

    if (!current) {
      return
    }

    current.scrollTop = 0
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
    window.ipcRenderer?.invoke(IPCEvent.getVirtualBackground).then((list) => {
      console.log('getVirtualBackground', list)
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
    } catch (e) {
      console.error('onPlayoutOutputChange', e)
    }

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
        previewController._rtc?.localStream?.setCaptureVolume(value)
      }
    } catch (e) {
      console.error('onRecordOutputChange', e)
    }

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

      previewController?.startPreview(view)
    } else {
      previewController?.startPreview(view)
    }
  }

  async function stopPreview() {
    testVideoStateRef.current = false
    previewController?.stopPreview()
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
  }, [])

  useEffect(() => {
    if (['beauty', 'video'].includes(currenMenuKey)) {
      testVideoStateRef.current = true
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
      <div ref={settingRightRef} className="setting-content">
        {currenMenuKey === 'normal' && (
          <NormalSetting
            inMeeting={inMeeting}
            onEnableTransparentWhiteboardChange={
              onEnableTransparentWhiteboardChange
            }
            onEnableVoicePriorityDisplay={onEnableVoicePriorityDisplay}
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
            openVideo={normalSetting.openVideo}
            onOpenVideoChange={onOpenVideoChange}
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
            openAudio={normalSetting.openAudio}
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
            onOpenAudioChange={onOpenAudioChange}
            playoutDeviceList={playoutDeviceList}
            recordDeviceList={recordDeviceList}
            inMeeting={inMeeting}
            preMeetingSetting={preMeetingSetting}
            previewController={previewController}
          />
        )}
        {currenMenuKey === 'security' && <SecuritySetting />}
        {currenMenuKey === 'beauty' && (
          <BeautySetting
            inMeeting={inMeeting}
            eventEmitter={eventEmitter}
            previewController={previewController}
            startPreview={startPreview}
            stopPreview={stopPreview}
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
