import CaretUpOutlined from '@ant-design/icons/CaretUpOutlined'
import ExclamationCircleFilled from '@ant-design/icons/ExclamationCircleFilled'
import { Badge, Button, Popover } from 'antd'
import classNames from 'classnames'
import { NEDeviceBaseInfo } from 'neroom-web-sdk'
import React, { useCallback, useEffect, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../../app/src/types'
import waitingRoomBg from '../../../assets/waiting-room-bg.png'
import usePostMessageHandle from '../../../hooks/usePostMessagehandle'
import usePreviewHandler from '../../../hooks/usePreviewHandler'
import YUVCanvas from '../../../libs/yuv-canvas'
import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../store'
import { NEMeetingInfo } from '../../../types'
import {
  ActionType,
  EventType,
  MeetingDeviceInfo,
  MeetingEventType,
  MeetingSetting,
  UserEventType,
} from '../../../types/innerType'
import { NEMeetingLeaveType } from '../../../types/type'
import {
  checkIsDefaultDevice,
  debounce,
  formatDate,
  getDefaultDeviceId,
  setDefaultDevice,
} from '../../../utils'
import { closeWindow, getWindow, openWindow } from '../../../utils/windowsProxy'
import { getYuvFrame } from '../../../utils/yuvFrame'
import AudioIcon from '../../common/AudioIcon'
import Modal from '../../common/Modal'
import PCTopButtons from '../../common/PCTopButtons'
import Toast from '../../common/toast'
import Chatroom from '../Chatroom/Chatroom'
import Setting from '../Setting'
import { SettingTabType } from '../Setting/Setting'
import './index.less'
import { useWaitingRoom } from '../../../hooks/useWaitingRoom'
import useElectronInvite from '../../../hooks/useElectronInvite'
interface WaitRoomProps {
  className?: string
}

const WAITING_ROOM_MEMBER_MSG_KEY = 'WAITING_ROOM_MEMBER_MSG_KEY'
let closeModal: any
const WaitRoom: React.FC<WaitRoomProps> = ({ className }) => {
  const { t } = useTranslation()
  const [audioPopoverVisible, setAudioPopoverVisible] = useState<boolean>(false)
  const [selectedMicrophone, setSelectedMicrophone] = useState<string>('')
  const [selectedCamera, setSelectedCamera] = useState<string>('')
  const [selectedSpeaker, setSelectedSpeaker] = useState<string>('')
  const [videoDeviceList, setVideoDeviceList] = useState<NEDeviceBaseInfo[]>([])
  const [recordDeviceList, setRecordDeviceList] = useState<NEDeviceBaseInfo[]>(
    []
  )
  const yuvRef = useRef<any>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const [playoutDeviceList, setPlayoutDeviceList] = useState<
    NEDeviceBaseInfo[]
  >([])
  const [isDarkMode, setIsDarkMode] = useState(true)
  const { dispatch } = useMeetingInfoContext()
  const [settingOpen, setSettingOpen] = useState(false)
  const [settingModalTab, setSettingModalTab] =
    useState<SettingTabType>('normal')
  const {
    neMeeting,
    outEventEmitter,
    logger,
    eventEmitter,
    dispatch: globalDispatch,
    notificationApi,
  } = useGlobalContext()
  const { waitingRoomInfo } = useWaitingRoomContext()
  const closeModalRef = useRef<any>(null)
  const closeTimerRef = useRef<any>(null)
  const meetingCanvasDomWidthResizeTimer = useRef<number | NodeJS.Timeout>()
  const { handlePostMessage } = usePostMessageHandle()

  useElectronInvite({
    needOpenWindow: true,
  })
  usePreviewHandler()
  // useEventHandler()
  function closeModalHandle(data: {
    title: string
    content: string
    closeText: string
    reason: any
    notNeedAutoClose?: boolean
  }) {
    const { title, content, closeText, reason, notNeedAutoClose } = data
    let remainTime = 3
    closeModalRef.current = Modal.confirm({
      className: 'waiting-room-close-modal',
      title: title,
      width: 236,
      content: <div className="waiting-room-close-content">{content}</div>,
      footer: (
        <div
          onClick={() => handleCloseModal(reason)}
          className="waiting-room-footer"
        >
          {closeText}
          {!notNeedAutoClose && remainTime ? '(' + remainTime + 's)' : ''}
        </div>
      ),
    })
    if (notNeedAutoClose) {
      return
    }
    if (closeTimerRef.current) {
      clearInterval(closeTimerRef.current)
    }
    closeTimerRef.current = setInterval(() => {
      remainTime -= 1
      if (remainTime <= 0) {
        closeTimerRef.current && clearInterval(closeTimerRef.current)
        closeTimerRef.current = null
        closeModalRef.current?.destroy()
        closeModalRef.current = null
        handleCloseModal(reason)
        // setShowRecordTip(false)
        return
      }
      closeModalRef.current?.update((prevConfig) => ({
        ...prevConfig,
        footer: (
          <div
            onClick={() => handleCloseModal(reason)}
            className="waiting-room-footer"
          >
            {t('globalClose')}
            {remainTime ? '(' + remainTime + 's)' : ''}
          </div>
        ),
      }))
    }, 1000)
  }
  const {
    openAudio,
    openVideo,
    setOpenVideo,
    setOpenAudio,
    setting,
    unReadMsgCount,
    isOffLine,
    nickname,
    recordVolume,
    meetingInfo,
    meetingState,
    showChatRoom,
    handleOpenAudio,
    handleOpenVideo,
    handleOpenChatRoom,
    startPreview,
    stopPreview,
    openChatRoom,
    setSetting,
    formatMeetingTime,
    videoCanvasWrapRef,
    setOpenChatRoom,
    setUnReadMsgCount,
    setRecordVolume,
  } = useWaitingRoom({
    closeModalHandle,
    handleVideoFrameData,
  })
  const getDevices = useCallback(() => {
    let _setting = meetingInfo.setting
    const tmpSetting = localStorage.getItem('ne-meeting-setting')
    if (tmpSetting) {
      try {
        _setting = JSON.parse(tmpSetting) as MeetingSetting
      } catch (e) {
        console.log('parse setting error', e)
      }
    }
    const previewController = neMeeting?.previewController
    if (previewController) {
      //@ts-ignore
      previewController.enumCameraDevices().then(({ data }) => {
        data = setDefaultDevice(data)
        setVideoDeviceList(data)
        const deviceId = _setting?.videoSetting.deviceId
        let isDefaultDevice = _setting?.videoSetting.isDefaultDevice
        let selectedDeviceId = deviceId as string
        if (data.length > 0) {
          if (!deviceId) {
            selectedDeviceId = data[0].deviceId
            isDefaultDevice = data[0].default
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
            } else {
              const deviceId = data[0].deviceId
              // 如果当前正在播放视频，则判断移除的设备是否是当前选择的
              selectedDeviceId = data[0].deviceId
            }
          }
          // if (selectedDeviceId != _setting?.videoSetting.deviceId) {
          setSelectedCamera(selectedDeviceId)
          previewController
            ?.switchDevice({
              type: 'camera',
              deviceId: getDefaultDeviceId(selectedDeviceId),
            })
            .then(() => {
              if (openVideo) {
                stopPreview()
                startPreview(videoCanvasWrapRef.current as HTMLElement)
              }
            })
          onDeviceSelectedChange(
            'video',
            selectedDeviceId,
            //@ts-ignore
            isDefaultDevice
          )
          // }
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
              _audioSetting.isDefaultRecordDevice = data[0].defaultDevice
            }
          }
          // if (selectedDeviceId != _audioSetting.recordDeviceId) {
          setSelectedMicrophone(selectedDeviceId)
          previewController?.switchDevice({
            type: 'microphone',
            deviceId: getDefaultDeviceId(selectedDeviceId),
          })
          onDeviceSelectedChange(
            'record',
            selectedDeviceId,
            //@ts-ignore
            _audioSetting.isDefaultRecordDevice
          )
          // }
        } else {
          _audioSetting.recordDeviceId = ''
        }
      })
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
                console.log('currentDevice>>>>>>', currentDevice)
              } else {
                currentDevice = data.find(
                  (item) => item.deviceId == playoutDeviceId && !item.default
                )
              }
              if (currentDevice) {
                selectedDeviceId = currentDevice.deviceId
                _audioSetting.playoutDeviceId = playoutDeviceId
                _audioSetting = {
                  ..._audioSetting,
                  recordDeviceId: selectedDeviceId,
                  isDefaultRecordDevice: isDefaultDevice,
                }
              } else {
                selectedDeviceId = data[0].deviceId
                _audioSetting.playoutDeviceId = selectedDeviceId
                _audioSetting.isDefaultPlayoutDevice = data[0].defaultDevice
              }
            }
            // if (selectedDeviceId != _audioSetting.playoutDeviceId) {
            console.log('设置当前扬声器', selectedDeviceId)
            setSelectedSpeaker(selectedDeviceId)
            previewController?.switchDevice({
              type: 'speaker',
              deviceId: getDefaultDeviceId(selectedDeviceId),
            })
            onDeviceSelectedChange(
              'playout',
              selectedDeviceId,
              //@ts-ignore
              _audioSetting.isDefaultPlayoutDevice
            )
            // }
          } else {
            _audioSetting.playoutDeviceId = ''
          }
        })
    }
  }, [openVideo])

  function onDeviceSelectedChange(
    type: 'video' | 'playout' | 'record',
    deviceId: string,
    isDefault?: boolean
  ) {
    const setting = { ...meetingInfo.setting } as MeetingSetting | undefined
    if (setting) {
      if (type === 'video') {
        if (setting.videoSetting) {
          setting.videoSetting.deviceId = deviceId
          setting.videoSetting.isDefaultDevice = isDefault
        }
      } else if (type === 'record') {
        if (setting.audioSetting) {
          setting.audioSetting.recordDeviceId = deviceId
          setting.audioSetting.isDefaultRecordDevice = isDefault
        }
      } else {
        if (setting.audioSetting) {
          setting.audioSetting.playoutDeviceId = deviceId
          setting.audioSetting.isDefaultPlayoutDevice = isDefault
        }
      }
      if (window.isElectronNative) {
        const settingWindow = getWindow('settingWindow')
        settingWindow?.postMessage(
          {
            event: IPCEvent.changeSettingDeviceFromControlBar,
            payload: {
              type,
              deviceId,
            },
          },
          settingWindow.origin
        )
      }

      onSettingChange(setting)
    }
  }

  function windowLoadListener(childWindow) {
    const previewController = neMeeting?.previewController
    const previewContext = neMeeting?.roomService?.getPreviewRoomContext()
    function messageListener(e) {
      const { event, payload } = e.data
      if (event === 'previewContext' && previewController) {
        const { replyKey, fnKey, args } = payload
        const result = previewContext?.[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'previewController' && previewController) {
        const { replyKey, fnKey, args } = payload
        const result = previewController[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      }
    }
    childWindow?.addEventListener('message', messageListener)
  }
  function onSettingClick(type: SettingTabType) {
    if (window.isElectronNative) {
      const settingWindow = openWindow('settingWindow')
      windowLoadListener(settingWindow)
      const openSettingData = {
        event: 'openSetting',
        payload: {
          type,
        },
      }
      if (settingWindow?.firstOpen === false) {
        settingWindow.postMessage(openSettingData, settingWindow.origin)
      } else {
        settingWindow?.addEventListener('load', () => {
          settingWindow?.postMessage(openSettingData, settingWindow.origin)
        })
      }
    } else {
      neMeeting?.previewController?.stopRecordDeviceTest()
      setSettingOpen(true)
      setSettingModalTab(type)
    }
  }

  useEffect(() => {
    window.ipcRenderer?.invoke('get-theme-color').then((isDark) => {
      setIsDarkMode(isDark)
    })
    getDevices()
  }, [])

  useEffect(() => {
    const debounceHandle = debounce(getDevices, 1000)
    navigator.mediaDevices.addEventListener('devicechange', debounceHandle)
    return () => {
      navigator.mediaDevices.removeEventListener('devicechange', debounceHandle)
    }
  }, [getDevices])

  useEffect(() => {
    if (setting?.videoSetting.deviceId) {
      setSelectedCamera(setting.videoSetting.deviceId)
    }
  }, [setting?.videoSetting.deviceId])
  useEffect(() => {
    console.log('audioDeviceChange>>>', setting?.audioSetting.recordDeviceId)
    if (setting?.audioSetting.recordDeviceId) {
      setSelectedMicrophone(setting.audioSetting.recordDeviceId)
    }
  }, [setting?.audioSetting.recordDeviceId])
  useEffect(() => {
    if (setting?.audioSetting.playoutDeviceId) {
      setSelectedSpeaker(setting.audioSetting.playoutDeviceId)
    }
  }, [setting?.audioSetting.playoutDeviceId])
  useEffect(() => {
    if (meetingInfo.isUnMutedAudio) {
      handleOpenAudio(false)
    }
    if (neMeeting?.alreadyJoin) {
      if (meetingInfo.localMember.isVideoOn) {
        handleOpenVideo(false)
      }
      if (meetingInfo.localMember.isAudioOn) {
        handleOpenAudio(false)
      }
    } else {
      if (meetingInfo.isUnMutedVideo) {
        handleOpenVideo(false)
      }
      return () => {
        setOpenChatRoom(false)
      }
    }
  }, [])

  function leaveMeeting() {
    const handleLeave = async () => {
      closeModal.destroy()
      closeModal = null
      try {
        await neMeeting?.leave()
      } finally {
        dispatch?.({
          type: ActionType.RESET_MEETING,
          data: null,
        })
        outEventEmitter?.emit(
          EventType.RoomEnded,
          NEMeetingLeaveType.LEAVE_BY_SELF
        )
      }
    }
    closeModal = Modal.confirm({
      title: t('leave'),
      content: t('meetingLeaveConfirm'),
      focusTriggerAfterClose: false,
      transitionName: '',
      mask: false,
      width: 300,
      footer: (
        <div className="nemeeting-modal-confirm-btns">
          <Button
            onClick={() => {
              closeModal.destroy()
              closeModal = null
            }}
          >
            {t('globalCancel')}
          </Button>
          <Button type="primary" onClick={handleLeave}>
            {t('leave')}
          </Button>
        </div>
      ),
    })
  }

  //@ts-ignore
  function handleVideoFrameData(uuid, bSubVideo, data, type, width, height) {
    const canvas = canvasRef.current
    if (canvas && videoCanvasWrapRef.current) {
      canvas.style.height = `${videoCanvasWrapRef.current.clientHeight}px`
    }
    yuvRef.current?.drawFrame(getYuvFrame(data, width, height))
  }

  async function onDeviceChange(
    type: 'video' | 'speaker' | 'microphone',
    deviceId: string,
    deviceName?: string
  ) {
    logger?.debug('changeDevice', type, deviceId, deviceName)
    switch (type) {
      case 'video':
        // web 不需要重新切换使用同一个sdk
        window.isElectronNative
          ? neMeeting?.changeLocalVideo(deviceId)
          : setSelectedCamera(deviceId)
        break
      case 'speaker':
        window.isElectronNative
          ? neMeeting?.selectSpeakers(deviceId)
          : setSelectedSpeaker(deviceId)
        break
      case 'microphone':
        window.isElectronNative
          ? neMeeting?.changeLocalAudio(deviceId)
          : setSelectedMicrophone(deviceId)
        break
    }
  }
  function onSettingChange(setting: MeetingSetting) {
    localStorage.setItem('ne-meeting-setting', JSON.stringify(setting))
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        setting,
      },
    })
  }
  function handleCloseModal(reason: string) {
    closeModalRef.current?.destroy?.()
    outEventEmitter?.emit(EventType.RoomEnded, reason)
  }

  function formateMsg(message) {
    if (message?.type === 'text') {
      return message.text
    } else if (message?.type === 'image') {
      return t('imageMsg')
    } else {
      return t('fileMsg')
    }
  }
  function handleOpenChatroomOrMemberList(open: boolean) {
    window.ipcRenderer?.send(IPCEvent.openChatroomOrMemberList, open)
    const wrapDom = document.getElementById('nemeetingWaitingRoomWrapper')
    if (wrapDom) {
      const width = open ? wrapDom.clientWidth + 320 : wrapDom.clientWidth - 320
      wrapDom.style.width = `${width}px`
      wrapDom.style.flex = 'none'
      meetingCanvasDomWidthResizeTimer.current &&
        clearTimeout(meetingCanvasDomWidthResizeTimer.current)
      meetingCanvasDomWidthResizeTimer.current = setTimeout(() => {
        wrapDom.style.width = `auto`
        wrapDom.style.flex = '1'
      }, 60)
    }
  }

  useEffect(() => {
    if (window.isElectronNative) {
      handleOpenChatroomOrMemberList(openChatRoom)
    }
  }, [openChatRoom])

  function handleCloseSetting() {
    setSettingOpen(false)
    if (openVideo) {
      setTimeout(() => {
        startPreview(videoCanvasWrapRef.current as HTMLElement)
      }, 300)
    }
    if (openAudio) {
      setTimeout(() => {
        neMeeting?.previewController?.startRecordDeviceTest((level: number) => {
          setRecordVolume((level as number) * 10)
        })
      }, 300)
    }
  }
  const handleNewMessage = useCallback(
    (messages) => {
      if (openChatRoom || messages.length === 0) {
        return
      }
      const message = messages[0]
      if (!['text', 'file', 'image'].includes(message?.type)) {
        return
      }
      setUnReadMsgCount(unReadMsgCount + 1)
      notificationApi?.destroy(WAITING_ROOM_MEMBER_MSG_KEY)
      notificationApi?.info({
        className: 'nemeeing-waiting-room-notify',
        key: WAITING_ROOM_MEMBER_MSG_KEY,
        message: (
          <div className="waiting-room-notify-title">
            <div>{t('chatMessage')}</div>
            <div className="waiting-room-notify-btn">
              <Button
                size="small"
                style={{ fontSize: '12px' }}
                onClick={() => {
                  notificationApi?.destroy(WAITING_ROOM_MEMBER_MSG_KEY)
                  setUnReadMsgCount(0)
                  setOpenChatRoom(true)
                }}
                type="primary"
              >
                {t('viewMessage')}
              </Button>
            </div>
          </div>
        ),
        closeIcon: (
          <div className="waiting-room-notify-close">
            <svg
              className={classNames('icon iconfont icon-chat')}
              aria-hidden="true"
            >
              <use xlinkHref="#iconcross"></use>
            </svg>
          </div>
        ),
        icon: (
          <div className="nemeeting-waiting-room-member-manager">
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconchat1x"></use>
            </svg>
          </div>
        ),
        description: (
          <div className="notify-description">
            <div className="waiting-room-msg-name">{message.fromNick}</div>
            <div className="waiting-room-msg-des">{formateMsg(message)}</div>
          </div>
        ),
      })
    },
    [openChatRoom, unReadMsgCount]
  )
  useEffect(() => {
    const canvas = canvasRef.current
    if (canvas) {
      yuvRef.current = YUVCanvas.attach(canvas)
    }
    function closeWindowHandle() {
      if (closeModal) {
        closeModal.destroy()
        closeModal = null
      }
      leaveMeeting()
    }
    if (window.isElectronNative) {
      window.ipcRenderer?.on('main-close-before', closeWindowHandle)
      window.ipcRenderer?.send(IPCEvent.inWaitingRoom, true)
      closeWindow('settingWindow')
    }
    return () => {
      if (window.isElectronNative) {
        window.ipcRenderer?.off('main-close-before', closeWindowHandle)
        window.ipcRenderer?.send(IPCEvent.inWaitingRoom, false)
        closeWindow('settingWindow')
      }
      closeModal && closeModal.destroy?.()
    }
  }, [])
  useEffect(() => {
    eventEmitter?.on(EventType.ReceiveChatroomMessages, handleNewMessage)
    return () => {
      eventEmitter?.off(EventType.ReceiveChatroomMessages, handleNewMessage)
    }
  }, [handleNewMessage])

  useEffect(() => {
    function handleAcceptInvite(options, callback) {
      // 需要先离开当前会议
      globalDispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          waitingJoinOtherMeeting: true,
          joinLoading: true,
        },
      })
      // 在会中
      eventEmitter?.emit(UserEventType.JoinOtherMeeting, options, callback)
    }
    eventEmitter?.on(EventType.AcceptInvite, handleAcceptInvite)
    return () => {
      eventEmitter?.off(EventType.AcceptInvite, handleAcceptInvite)
    }
  }, [])

  return (
    <div
      className={classNames(`nemeeting-waiting-room ${className || ''}`, {
        ['light-theme']: !isDarkMode,
      })}
    >
      {window.isElectronNative && window.isWins32 && (
        <div className="electron-in-meeting-drag-bar">
          <div className="drag-region" />
          <span className="waiting-room-win-bar-title">
            {t('globalAppName')}
          </span>
          <PCTopButtons />
        </div>
      )}
      <div
        className="nemeeting-waiting-room-content-wrap"
        style={{ marginTop: window.isWins32 ? '28px' : '0' }}
      >
        <div
          className="nemeeting-waiting-room-wrapper"
          id="nemeetingWaitingRoomWrapper"
          style={{
            backgroundImage: `url(${
              waitingRoomInfo.backgroundImageUrl || waitingRoomBg
            })`,
          }}
        >
          {window.isElectronNative && !window.isWins32 && (
            <div className="electron-in-meeting-drag-bar electron-in-meeting-drag-mac-bar">
              <div className="drag-region" />
              <span className="waiting-room-bar-title">
                {t('globalAppName')}
              </span>
              <PCTopButtons />
            </div>
          )}
          {isOffLine ? (
            <div className="waiting-room-network-error">
              <ExclamationCircleFilled />
              <div className="waiting-room-alter-content">
                {t('networkErrorAndCheck')}
              </div>
            </div>
          ) : null}
          <div className="nemeeting-waiting-room-content">
            <div className="nemeeting-waiting-room-title">
              {meetingState === 2
                ? t('waitingForHost')
                : t('meetingWillBeginSoon')}
            </div>
            <div className="nemeeting-waiting-room-detail">
              <div>
                <svg className="icon iconfont iconfont-tip" aria-hidden="true">
                  <use xlinkHref="#iconbiaoti-mianxing"></use>
                </svg>
                <span>{t('inviteSubject')}: </span>
                <span className=" nemeeting-waiting-room-ml12">
                  {meetingInfo.subject}
                </span>
              </div>
              <div className="waiting-room-time">
                <svg className="icon iconfont iconfont-tip" aria-hidden="true">
                  <use xlinkHref="#iconshijian2"></use>
                </svg>
                <span>{t('inviteTime')}: </span>
                {formatMeetingTime(meetingInfo.startTime)
                  .split('_')
                  .map((item) => {
                    return (
                      <span key={item} className="nemeeting-waiting-room-ml12">
                        {item}
                      </span>
                    )
                  })}
              </div>
              <div className="waiting-room-time">
                <svg className="icon iconfont iconfont-tip" aria-hidden="true">
                  <use xlinkHref="#iconnicheng"></use>
                </svg>
                <span>{t('meetingNickname')}: </span>
                <span className="nemeeting-waiting-room-ml12">{nickname}</span>
              </div>
            </div>
            <div>
              <div className="operate-media-btn-content">
                <div className="operate-media-btn-wrapper">
                  <div className="operate-btn operate-media-btn">
                    <div
                      onClick={() => handleOpenAudio(openAudio)}
                      className="iconfont-operate"
                    >
                      {openAudio ? (
                        <AudioIcon
                          className="icon iconfont"
                          audioLevel={recordVolume || 0}
                        />
                      ) : (
                        <svg
                          className={classNames(
                            'icon iconfont iconfont-operate',
                            {
                              'icon-red': !openAudio,
                            }
                          )}
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconyx-tv-voice-offx"></use>
                        </svg>
                      )}
                    </div>
                    <Popover
                      trigger={['click']}
                      getPopupContainer={(triggerNode) => triggerNode}
                      destroyTooltipOnHide
                      rootClassName="waiting-room-device-popover"
                      placement="bottom"
                      getTooltipContainer={(node) => node}
                      onOpenChange={setAudioPopoverVisible}
                      afterOpenChange={setAudioPopoverVisible}
                      arrow={false}
                      content={
                        <>
                          <div className="device-list">
                            <div className="device-list-title">
                              {t('selectSpeaker')}
                            </div>
                            {playoutDeviceList.map((item) => {
                              const isSelected =
                                item.deviceId == selectedSpeaker
                              return (
                                <div
                                  className={`device-item ${
                                    isSelected ? 'device-selected' : ''
                                  }`}
                                  key={item.deviceName}
                                  onClick={() => {
                                    neMeeting?.previewController
                                      ?.switchDevice({
                                        type: 'speaker',
                                        deviceId: getDefaultDeviceId(
                                          item.deviceId
                                        ),
                                      })
                                      .then(() => {
                                        onDeviceSelectedChange?.(
                                          'playout',
                                          item.deviceId,
                                          //@ts-ignore
                                          item.default
                                        )
                                        setSelectedSpeaker(item.deviceId)
                                      })
                                  }}
                                >
                                  <div
                                    className={`device-item-label ${
                                      isSelected ? 'device-selected' : ''
                                    }`}
                                  >
                                    {item.deviceName}
                                  </div>
                                  {isSelected && (
                                    <svg
                                      className="icon iconfont"
                                      aria-hidden="true"
                                    >
                                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                                    </svg>
                                  )}
                                </div>
                              )
                            })}
                          </div>
                          <div className="device-list">
                            <div className="device-list-title">
                              {t('selectMicrophone')}
                            </div>
                            {recordDeviceList.map((item) => {
                              const isSelected =
                                item.deviceId == selectedMicrophone
                              return (
                                <div
                                  className={`device-item ${
                                    isSelected ? 'device-selected' : ''
                                  }`}
                                  key={item.deviceName}
                                  onClick={() => {
                                    neMeeting?.previewController
                                      ?.switchDevice({
                                        type: 'microphone',
                                        deviceId: getDefaultDeviceId(
                                          item.deviceId
                                        ),
                                      })
                                      .then(() => {
                                        onDeviceSelectedChange?.(
                                          'record',
                                          item.deviceId,
                                          //@ts-ignore
                                          item.default
                                        )
                                        setSelectedMicrophone(item.deviceId)
                                      })
                                  }}
                                >
                                  <div
                                    className={`device-item-label ${
                                      isSelected ? 'device-selected' : ''
                                    }`}
                                  >
                                    {item.deviceName}
                                  </div>
                                  {isSelected && (
                                    <svg
                                      className="icon iconfont"
                                      aria-hidden="true"
                                    >
                                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                                    </svg>
                                  )}
                                </div>
                              )
                            })}
                          </div>
                        </>
                      }
                    >
                      <div
                        className="audio-video-devices-button"
                        onClick={() => {
                          setAudioPopoverVisible(!audioPopoverVisible)
                        }}
                      >
                        <CaretUpOutlined />
                      </div>
                    </Popover>
                  </div>
                  <div className="waiting-room-device-title">
                    {t('microphone')}
                  </div>
                </div>
                <div className="operate-media-btn-wrapper">
                  <div className="operate-btn operate-media-btn">
                    <svg
                      className={classNames('icon iconfont iconfont-operate', {
                        'icon-red': !openVideo,
                      })}
                      onClick={() => handleOpenVideo(openVideo)}
                      aria-hidden="true"
                    >
                      <use
                        xlinkHref={`${
                          openVideo
                            ? '#iconyx-tv-video-onx'
                            : '#iconyx-tv-video-offx'
                        }`}
                      ></use>
                    </svg>
                    <Popover
                      trigger={['click']}
                      getPopupContainer={(triggerNode) => triggerNode}
                      destroyTooltipOnHide
                      rootClassName="waiting-room-device-popover"
                      placement="bottom"
                      getTooltipContainer={(node) => node}
                      onOpenChange={setAudioPopoverVisible}
                      afterOpenChange={setAudioPopoverVisible}
                      arrow={false}
                      content={
                        <>
                          <div className="device-list">
                            <div className="device-list-title">
                              {t('selectVideoSource')}
                            </div>
                            {videoDeviceList.map((item) => {
                              const isSelected =
                                selectedCamera === item.deviceId
                              return (
                                <div
                                  className={`device-item ${
                                    isSelected ? 'device-selected' : ''
                                  }`}
                                  key={item.deviceName}
                                  onClick={() => {
                                    neMeeting?.previewController
                                      ?.switchDevice({
                                        type: 'camera',
                                        deviceId: getDefaultDeviceId(
                                          item.deviceId
                                        ),
                                      })
                                      .then(() => {
                                        onDeviceSelectedChange?.(
                                          'video',
                                          item.deviceId,
                                          //@ts-ignore
                                          item.default
                                        )
                                        setSelectedCamera(item.deviceId)
                                      })
                                  }}
                                >
                                  <div
                                    className={`device-item-label ${
                                      isSelected ? 'device-selected' : ''
                                    }`}
                                  >
                                    {item.deviceName}
                                  </div>
                                  {isSelected && (
                                    <svg
                                      className="icon iconfont"
                                      aria-hidden="true"
                                    >
                                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                                    </svg>
                                  )}
                                </div>
                              )
                            })}
                          </div>
                        </>
                      }
                    >
                      <div
                        className="audio-video-devices-button"
                        onClick={() => {
                          setAudioPopoverVisible(!audioPopoverVisible)
                        }}
                      >
                        <CaretUpOutlined />
                      </div>
                    </Popover>
                  </div>
                  <div className="waiting-room-device-title">{t('camera')}</div>
                </div>
                <div className="operate-media-btn-wrapper">
                  <div className="operate-btn operate-setting-btn">
                    <svg
                      className={classNames(
                        'icon iconfont iconfont-operate icon-debug'
                      )}
                      aria-hidden="true"
                      onClick={() => onSettingClick('audio')}
                    >
                      <use xlinkHref="#icontiaoshi"></use>
                    </svg>
                  </div>
                  <div className="waiting-room-device-title">{t('debug')}</div>
                </div>
              </div>
              <div></div>
            </div>
          </div>
          {neMeeting?.previewController && (
            <Setting
              onDeviceChange={onDeviceChange}
              defaultTab={settingModalTab}
              destroyOnClose={true}
              setting={meetingInfo.setting}
              onSettingChange={onSettingChange}
              previewController={neMeeting.previewController}
              open={settingOpen}
              onCancel={() => handleCloseSetting()}
            />
          )}
          {/* 离开按钮 */}
          <div className="waiting-room-leave-btn" onClick={leaveMeeting}>
            {t('meetingLeaveFull')}
          </div>
          {/* 视频预览 */}
          <div
            className="waiting-room-canvas-wrap"
            style={{ display: openVideo ? 'block' : 'none' }}
          >
            <div
              className="icon-close-wrap"
              onClick={() => handleOpenVideo(true)}
            >
              <svg
                className={classNames('icon iconfont icon-close')}
                aria-hidden="true"
              >
                <use xlinkHref="#iconcross"></use>
              </svg>
            </div>
            <div
              ref={videoCanvasWrapRef}
              className={`waiting-room-canvas-content ${
                setting?.videoSetting.enableVideoMirroring ? 'video-mirror' : ''
              }`}
            >
              {window.isElectronNative && (
                <canvas
                  className="nemeeting-video-view-canvas"
                  ref={canvasRef}
                />
              )}
            </div>
          </div>
          {/* 聊天室消息按钮 */}
          {showChatRoom && (
            <div
              className="waiting-room-chat-wrap"
              onClick={() => handleOpenChatRoom(!openChatRoom)}
            >
              <Badge size="small" count={unReadMsgCount} offset={[-6, 8]}>
                <div className="waiting-room-chat-icon">
                  <svg
                    className={classNames('icon iconfont icon-chat')}
                    aria-hidden="true"
                  >
                    <use xlinkHref="#iconchat1x"></use>
                  </svg>
                </div>
              </Badge>
              <div className="waiting-room-chat-title">
                {t('chatRoomTitle')}
              </div>
            </div>
          )}
        </div>
        {/* 聊天室 */}
        {openChatRoom && window.isElectronNative && (
          <div style={{ width: 320 }} />
        )}
        <div
          className={classNames('nemeeting-waiting-room-bar-wrap', {
            'nemeeting-waiting-room-open': openChatRoom,
          })}
        >
          <div className={'nemeeting-waiting-room-bar'}>
            {t('chat')}
            <svg
              className={classNames(
                'icon iconfont nemeeting-waiting-room-bar-close'
              )}
              aria-hidden="true"
              onClick={() => handleOpenChatRoom(false)}
            >
              <use xlinkHref="#iconcross"></use>
            </svg>
          </div>
          <Chatroom visible={openChatRoom} isWaitingRoom />
        </div>
      </div>
    </div>
  )
}

export default React.memo(WaitRoom)
