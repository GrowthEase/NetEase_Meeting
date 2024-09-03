import { Menu, MenuProps } from 'antd'
import { CheckboxChangeEvent } from 'antd/es/checkbox'
import EventEmitter from 'eventemitter3'
import {
  NEDeviceBaseInfo,
  NEPreviewController,
  NEPreviewRoomContext,
  NERoomCaptionTranslationLanguage,
} from 'neroom-types'
import React, { useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../app/src/types'
import { LOCALSTORAGE_USER_INFO } from '../../../config'
import { EventType, MeetingDeviceInfo, MeetingSetting } from '../../../types'
import {
  ASRTranslationLanguageToString,
  checkIsDefaultDevice,
  debounce,
  getDefaultDeviceId,
  getLocalStorageSetting,
  setDefaultDevice,
} from '../../../utils'
import BeautySetting from './BeautySetting'
import './index.less'
import MonitoringSetting from './MonitoringSetting'
import SecuritySetting from './SecuritySetting'
import VideoSetting from './VideoSetting'
import AudioSetting from './AudioSetting'
import NormalSetting from './NormalSetting'
import RecordSetting from './RecordSetting'
import CaptionSetting from './CaptionSetting'
import { useMount, useUpdateEffect } from 'ahooks'
import ScreenShareSetting from './ScreenShareSetting'
import { useGlobalContext } from '../../../store'

const eventEmitter = new EventEmitter()

export type SettingTabType =
  | 'normal'
  | 'video'
  | 'audio'
  | 'beauty'
  | 'virtual'
  | 'security'
  | 'monitoring'
  | 'record'
  | 'caption'
  | 'screenShare'

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
  onDeviceChange?: (
    type: 'video' | 'speaker' | 'microphone',
    deviceId: string,
    deviceName?: string // 只有electron c++时候需要，web和c++ deviceId不一致 需要通过name来辅助判断
  ) => void
  defaultTab?: SettingTabType
  open?: boolean
  inMeeting?: boolean
}

const Setting: React.FC<SettingProps> = ({
  previewController,
  previewContext,
  onSettingChange,
  onDeviceChange,
  defaultTab = 'normal',
  inMeeting,
  ...resProps
}) => {
  const { t, i18n } = useTranslation()
  const [showBeauty, setShowBeauty] = useState(false)
  const [showCaption, setShowCaption] = useState(false)
  const [showTranscript, setShowTranscript] = useState(false)
  const [showSecurity, setShowSecurity] = useState(false)
  const [showRecord, setShowRecord] = useState(false)
  const settingRightRef = useRef<HTMLDivElement>(null)

  const [setting, setSetting] = useState<MeetingSetting>()

  const [recordSetting, setRecordSetting] =
    useState<MeetingSetting['recordSetting']>()
  const [captionSetting, setCaptionSetting] =
    useState<MeetingSetting['captionSetting']>()
  const [normalSetting, setNormalSetting] =
    useState<MeetingSetting['normalSetting']>()
  const [videoSetting, setVideoSetting] =
    useState<MeetingSetting['videoSetting']>()
  const [audioSetting, setAudioSetting] =
    useState<MeetingSetting['audioSetting']>()
  const [beautySetting, setBeautySetting] =
    useState<MeetingSetting['beautySetting']>()
  const [screenShareSetting, setScreenShareSetting] =
    useState<MeetingSetting['screenShareSetting']>()
  const { neMeeting } = useGlobalContext()

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

  if (setting) {
    settingRef.current = setting
  }

  // 当前在哪个播放状态
  const testVideoStateRef = useRef(false)

  useUpdateEffect(() => {
    if (inMeeting) {
      return
    }

    neMeeting?.saveSettings({
      beauty: {
        level: beautySetting?.beautyLevel || 0,
      },
      asrTranslationLanguage: ASRTranslationLanguageToString(
        captionSetting?.targetLanguage
      ),
      captionBilingual: !!captionSetting?.showCaptionBilingual,
      transcriptionBilingual: !!captionSetting?.showTranslationBilingual,
    })
  }, [
    inMeeting,
    captionSetting?.targetLanguage,
    captionSetting?.showCaptionBilingual,
    captionSetting?.showTranslationBilingual,
    beautySetting?.beautyLevel,
  ])
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
      getItem(
        t('screenShare'),
        'screenShare',
        <svg className={'icon iconfont icon-menu'} aria-hidden="true">
          {currenMenuKey === 'screenShare' ? (
            <use xlinkHref="#icongongxiangpingmuxuanzhong"></use>
          ) : (
            <use xlinkHref="#icongongxiangpingmu1"></use>
          )}
        </svg>
      ),
    ]

    if (showRecord) {
      defaultMenus.push(
        getItem(
          t('record'),
          'record',
          <svg className={'icon iconfont icon-menu'} aria-hidden="true">
            {currenMenuKey === 'record' ? (
              <use xlinkHref="#iconluzhixuanzhong"></use>
            ) : (
              <use xlinkHref="#iconluzhi"></use>
            )}
          </svg>
        )
      )
    }

    if (showCaption) {
      defaultMenus.push(
        getItem(
          t('transcriptionCaptionAndTranslate'),
          'caption',
          <svg className={'icon iconfont icon-menu '} aria-hidden="true">
            <use xlinkHref="#iconshezhi-zimu"></use>
          </svg>
        )
      )
    }

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
  }, [
    showBeauty,
    showSecurity,
    showCaption,
    showRecord,
    inMeeting,
    currenMenuKey,
    t,
  ])

  const handleMenuItems = () => {
    const globalConfig = JSON.parse(
      localStorage.getItem('nemeeting-global-config') || '{}'
    )

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

    const appRoomConfig = globalConfig?.appConfig?.APP_ROOM_RESOURCE

    if (appRoomConfig?.caption) {
      setShowCaption(true)
    } else {
      setShowCaption(false)
    }

    if (appRoomConfig?.transcript) {
      setShowTranscript(true)
    } else {
      setShowTranscript(false)
    }

    if (appRoomConfig?.record) {
      setShowRecord(true)
    } else {
      setShowRecord(false)
    }
  }

  useUpdateEffect(() => {
    if (audioSetting) {
      const setting = getLocalStorageSetting()

      onSettingChange?.({
        ...setting,
        audioSetting: { ...audioSetting },
      })
    }
  }, [audioSetting])

  useUpdateEffect(() => {
    if (captionSetting) {
      const setting = getLocalStorageSetting()

      onSettingChange?.({
        ...setting,
        captionSetting: { ...captionSetting },
      })
    }
  }, [captionSetting])

  useUpdateEffect(() => {
    if (normalSetting) {
      const setting = getLocalStorageSetting()

      onSettingChange?.({
        ...setting,
        normalSetting: { ...normalSetting },
      })
    }
  }, [normalSetting])

  useUpdateEffect(() => {
    if (videoSetting) {
      const setting = getLocalStorageSetting()

      onSettingChange?.({
        ...setting,
        videoSetting: { ...videoSetting },
      })
    }
  }, [videoSetting])

  useUpdateEffect(() => {
    if (beautySetting) {
      const setting = getLocalStorageSetting()

      onSettingChange?.({
        ...setting,
        beautySetting: { ...beautySetting },
      })
    }
  }, [beautySetting])

  useUpdateEffect(() => {
    if (recordSetting) {
      const setting = getLocalStorageSetting()

      onSettingChange?.({
        ...setting,
        recordSetting: { ...recordSetting },
      })
    }
  }, [recordSetting])

  useUpdateEffect(() => {
    if (screenShareSetting) {
      const setting = getLocalStorageSetting()

      onSettingChange?.({
        ...setting,
        screenShareSetting: { ...screenShareSetting },
      })
    }
  }, [screenShareSetting])

  useMount(() => {
    getPreMeetingSetting()

    getDevices()
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
        getDevices()
      }
    }

    window.addEventListener('message', handleMessage)
    return () => {
      window.removeEventListener('message', handleMessage)
      navigator.mediaDevices.removeEventListener('devicechange', debounceHandle)
    }
  })

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

      previewContext.addPreviewRoomListener(previewRoomListener)

      return () => {
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

  function getDevices() {
    const _setting = settingRef.current || getLocalStorageSetting()

    if (previewController) {
      previewController.enumCameraDevices().then(({ data }) => {
        data = setDefaultDevice(data)
        setVideoDeviceList(data)
        const _setting = getLocalStorageSetting()
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
      let _audioSetting = { ..._setting?.audioSetting }

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
            _setting &&
              setAudioSetting({
                ..._setting.audioSetting,
                ..._audioSetting,
              })
          })
      })
    }
  }

  function onAutoCloudRecordChange(checked: boolean) {
    recordSetting &&
      setRecordSetting({
        ...recordSetting,
        autoCloudRecord: checked,
      })
  }

  function onCaptionSizeChange(size: number) {
    captionSetting &&
      setCaptionSetting({
        ...captionSetting,
        fontSize: size,
      })
  }

  function onCaptionShowBilingual(enable: boolean) {
    captionSetting &&
      setCaptionSetting({
        ...captionSetting,
        showCaptionBilingual: enable,
      })
  }

  function onTranslateShowBilingual(enable: boolean) {
    captionSetting &&
      setCaptionSetting({
        ...captionSetting,
        showTranslationBilingual: enable,
      })
  }

  function onTargetLanguageChange(lang: NERoomCaptionTranslationLanguage) {
    captionSetting &&
      setCaptionSetting({
        ...captionSetting,
        targetLanguage: lang,
      })
  }

  function onEnableCaptionWhenJoinMeetingChange(enable: boolean) {
    captionSetting &&
      setCaptionSetting({
        ...captionSetting,
        autoEnableCaptionsOnJoin: enable,
      })
  }

  function onAutoCloudRecordStrategyChange(value: number) {
    recordSetting &&
      setRecordSetting({
        ...recordSetting,
        autoCloudRecordStrategy: value,
      })
  }

  function onOpenVideoChange(e: CheckboxChangeEvent) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        openVideo: e.target.checked,
      })
  }

  function onOpenAudioChange(e: CheckboxChangeEvent) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        openAudio: e.target.checked,
      })
  }

  function onUsingComputerAudioChange(e: CheckboxChangeEvent) {
    audioSetting &&
      setAudioSetting({
        ...audioSetting,
        usingComputerAudio: e.target.checked,
      })
  }

  function onShowSpeakerListChange(e: CheckboxChangeEvent) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        showSpeakerList: e.target.checked,
      })
  }

  function onShowTimeChange(e: CheckboxChangeEvent) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        showDurationTime: e.target.checked,
      })
  }

  function onShowToolbarChange(e: CheckboxChangeEvent) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        showToolbar: e.target.checked,
      })
  }

  function onDownloadPathChange(path: string) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        downloadPath: path,
      })
  }

  function onChatMessageNotificationTypeChange(value: number) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        chatMessageNotificationType: value,
      })
  }

  function onLanguageChange(language: string) {
    i18n.changeLanguage(language)

    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        language,
      })
  }

  function onEnableTransparentWhiteboardChange(e: CheckboxChangeEvent) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        enableTransparentWhiteboard: e.target.checked,
      })
  }

  function onEnableVoicePriorityDisplay(e: CheckboxChangeEvent) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        enableVoicePriorityDisplay: e.target.checked,
      })
  }

  function onEnableShowNotYetJoinedMembers(e: CheckboxChangeEvent) {
    normalSetting &&
      setNormalSetting({
        ...normalSetting,
        enableShowNotYetJoinedMembers: !e.target.checked,
      })
  }

  function onHandleMenuClick(e) {
    console.log(e.key)
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
    videoSetting &&
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
    videoSetting &&
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
    audioSetting &&
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
    audioSetting &&
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
      if (window.isElectronNative) {
        // previewController.adjustPlaybackSignalVolume(value)
        previewController?.setPlayoutDeviceMute?.(value === 0)
        previewController?.setPlayoutDeviceVolume?.(value)
      } else {
        previewController._rtc?._client?.setPlaybackVolume(value)
      }
    } catch (e) {
      console.error('onPlayoutOutputChange', e)
    }

    audioSetting &&
      setAudioSetting({
        ...audioSetting,
        playouOutputtVolume: value,
      })
  }

  function setPlaybackVolume(volume: number) {
    previewController._rtc?._client?.setPlaybackVolume(volume)
  }

  function setCaptureVolume(volume: number) {
    previewController._rtc?.localStream?.setCaptureVolume(volume)
  }

  function onRecordOutputChange(value: number) {
    try {
      if (previewController.setRecordDeviceVolume) {
        previewController.setRecordDeviceVolume(value)
      } else {
        previewController._rtc?.localStream?.setCaptureVolume(value)
      }
    } catch (e) {
      console.error('onRecordOutputChange', e)
    }

    audioSetting &&
      setAudioSetting({
        ...audioSetting,
        recordOutputVolume: value,
      })
  }

  // 设置自动调节麦克风音量
  function onEnableAudioVolumeAutoAdjust(e: CheckboxChangeEvent) {
    if (e.target.checked && audioSetting) {
      onRecordOutputChange(70)
      audioSetting.recordOutputVolume = 70
    }

    audioSetting &&
      setAudioSetting({
        ...audioSetting,
        enableAudioVolumeAutoAdjust: e.target.checked,
      })
  }

  // 是否设置长按空格解除静音
  function onUnmuteAudioBySpaceChange(e: CheckboxChangeEvent) {
    audioSetting &&
      setAudioSetting({
        ...audioSetting,
        enableUnmuteBySpace: e.target.checked,
      })
  }

  function onEnableAudioAIChange(e: CheckboxChangeEvent) {
    const checked = e.target.checked

    audioSetting &&
      setAudioSetting({
        ...audioSetting,
        enableAudioAI: checked,
        enableMusicMode: checked ? false : audioSetting.enableMusicMode,
      })
  }

  function onEnableMusicModeChange(e: CheckboxChangeEvent) {
    const checked = e.target.checked

    audioSetting &&
      setAudioSetting({
        ...audioSetting,
        enableMusicMode: checked,
        enableAudioAI: checked ? false : audioSetting.enableAudioAI,
      })
  }

  function onEnableAudioStereoChange(e: CheckboxChangeEvent) {
    audioSetting &&
      setAudioSetting({
        ...audioSetting,
        enableAudioStereo: e.target.checked,
      })
  }

  function onEnableAudioEchoCancellationChange(e: CheckboxChangeEvent) {
    audioSetting &&
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
    videoSetting &&
      setVideoSetting({
        ...videoSetting,
        galleryModeMaxCount: value,
      })
  }

  function onShowMemberNameChange(e: CheckboxChangeEvent) {
    videoSetting &&
      setVideoSetting({
        ...videoSetting,
        showMemberName: e.target.checked,
      })
  }

  function onEnableVideoMirroringChange(e: CheckboxChangeEvent) {
    videoSetting &&
      setVideoSetting({
        ...videoSetting,
        enableVideoMirroring: e.target.checked,
      })
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
    previewController?.setRecordDeviceVolume?.(0)
    return previewController?.startRecordDeviceTest(callback).then((res) => {
      settingRef.current?.audioSetting.recordOutputVolume !== undefined &&
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
    if (resProps.open) {
      const setting = getLocalStorageSetting()

      setSetting(setting)
      setAudioSetting(setting.audioSetting)
      setNormalSetting(setting.normalSetting)
      setVideoSetting(setting.videoSetting)
      setRecordSetting(setting.recordSetting)
      setCaptionSetting(setting.captionSetting)
      setBeautySetting(setting.beautySetting)
      setScreenShareSetting(setting.screenShareSetting)
    }
  }, [resProps.open])

  useEffect(() => {
    getVirtualBackground()
  }, [])

  useEffect(() => {
    if (
      ![
        'normal',
        'video',
        'audio',
        'beauty',
        'security',
        'monitoring',
        'record',
        'caption',
        'screenShare',
      ].includes(currenMenuKey)
    ) {
      setCurrenMenuKey('normal')
      return
    }

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
        {currenMenuKey === 'normal' && normalSetting && (
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
            onEnableShowNotYetJoinedMembers={onEnableShowNotYetJoinedMembers}
            onChatMessageNotificationTypeChange={
              onChatMessageNotificationTypeChange
            }
          />
        )}
        {currenMenuKey === 'video' && normalSetting && videoSetting && (
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
            onShowMemberNameChange={onShowMemberNameChange}
          />
        )}
        {currenMenuKey === 'audio' && normalSetting && audioSetting && (
          <AudioSetting
            setPlaybackVolume={setPlaybackVolume}
            setCaptureVolume={setCaptureVolume}
            startPlayoutDeviceTest={startPlayoutDeviceTest}
            stopPlayoutDeviceTest={stopPlayoutDeviceTest}
            startRecordDeviceTest={startRecordDeviceTest}
            stopRecordDeviceTest={stopRecordDeviceTest}
            // 解决Electron会中同时打开设置，修改配置设置未及时同步问题
            setting={audioSetting}
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
            onUsingComputerAudioChange={onUsingComputerAudioChange}
            playoutDeviceList={playoutDeviceList}
            recordDeviceList={recordDeviceList}
            inMeeting={inMeeting}
            preMeetingSetting={preMeetingSetting}
            previewController={previewController}
          />
        )}
        {currenMenuKey === 'caption' && captionSetting && (
          <CaptionSetting
            showCaption={showCaption}
            showTranscript={showTranscript}
            onCaptionShowBilingual={onCaptionShowBilingual}
            onTargetLanguageChange={onTargetLanguageChange}
            onTranslateShowBilingual={onTranslateShowBilingual}
            onEnableCaptionWhenJoinMeetingChange={
              onEnableCaptionWhenJoinMeetingChange
            }
            onSizeChange={onCaptionSizeChange}
            captionSetting={captionSetting}
          />
        )}
        {currenMenuKey === 'record' && recordSetting && (
          <RecordSetting
            setting={recordSetting}
            onAutoCloudRecordStrategyChange={onAutoCloudRecordStrategyChange}
            onAutoCloudRecordChange={onAutoCloudRecordChange}
          />
        )}
        {currenMenuKey === 'screenShare' && (
          <ScreenShareSetting
            setting={screenShareSetting}
            onSettingChange={setScreenShareSetting}
          />
        )}
        {currenMenuKey === 'security' && <SecuritySetting />}
        {currenMenuKey === 'beauty' && videoSetting && beautySetting && (
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
