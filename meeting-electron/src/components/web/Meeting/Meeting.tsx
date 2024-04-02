import classNames from 'classnames'
import React, {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import loading from '../../../assets/loading.png'
import useEventHandler from '../../../hooks/useEventHandler'
import {
  GlobalContext,
  MeetingInfoContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../store'
import {
  ActionType,
  CreateOptions,
  EventType,
  GlobalContext as GlobalContextInterface,
  LayoutTypeEnum,
  MeetingInfoContextInterface,
  MeetingSetting,
  NELiveMember,
  NEMember,
  Role,
  Speaker,
  UserEventType,
} from '../../../types'
import {
  MeetingEventType,
  memberAction,
  RecordState,
  tagNERoomRtcAudioProfileType,
  tagNERoomRtcAudioScenarioType,
  WATERMARK_STRATEGY,
} from '../../../types/innerType'
import MeetingCanvas from '../MeetingCanvas'
import MeetingRightDrawer from '../MeetingRightDrawer'

import Modal from '../../common/Modal'

import { useUpdateEffect } from 'ahooks'
import { Button, message } from 'antd'
import { NEMemberVolumeInfo } from 'neroom-web-sdk/dist/types/platform/web/type'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../../app/src/types'
import usePostMessageHandle from '../../../hooks/usePostMessagehandle'
import usePreviewHandler from '../../../hooks/usePreviewHandler'
import eleIpc from '../../../services/electron/index'
import { drawWatermark, stopDrawWatermark } from '../../../utils/watermark'
import {
  closeAllWindows,
  closeWindow,
  getActiveWindows,
  getWindow,
  openWindow,
} from '../../../utils/windowsProxy'
import PCTopButtons from '../../common/PCTopButtons'
import Toast from '../../common/toast'
import ScreenShareListModal, {
  ScreenShareModalRef,
} from '../../electron/ScreenShareListModal'
import { cacheMsgs, setCacheMsgs } from '../Chatroom/Chatroom'
import ControlBar from '../ControlBar'
import InviteModal from '../InviteModal'
import Live from '../Live'
import LongPressSpaceUnmute from '../LongPressSpaceUnmute'
import MeetingDuration from '../MeetingDuration'
import MeetingInfo from '../MeetingInfo'
import MeetingLayout from '../MeetingLayout'
import MeetingNotification from '../MeetingNotification'
import { useMeetingNotificationInMeeting } from '../MeetingNotification/useMeetingNotification'
import useMeetingPlugin from '../MeetingRightDrawer/MeetingPlugin/useMeetingPlugin'
import Network from '../Network'
import Record from '../Record'
import RoomsHeader from '../RoomsHeader'
import Setting from '../Setting'
import { SettingTabType } from '../Setting/Setting'
import SpeakerList from '../SpeakerList'
import './index.less'

const worker = new Worker(
  new URL('../../../libs/yuv-canvas/worker.js', import.meta.url)
)

export { worker }

interface AppProps {
  width: number
  height: number
}
interface SpeakerListProps {
  memberList: NEMember[]
  isLocalScreen: boolean
}
const { confirm } = Modal

// 说话者列表
const SpeakerListWrap: React.FC<SpeakerListProps> = ({ isLocalScreen }) => {
  const { dispatch, memberList } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { eventEmitter } = useContext<GlobalContextInterface>(GlobalContext)
  // 是否隐藏到屏幕侧边
  const [showSpeakerList, setShowSpeakerList] = useState(true)
  const [speakerList, setSpeakerList] = useState<Speaker[]>([])

  // 说话者列表Timer
  const audioVolumeIndicationTimer = useRef<any>(null)

  const onSpeakerClick = () => {
    setShowSpeakerList(!showSpeakerList)
  }

  useEffect(() => {
    const handle = (data: NEMemberVolumeInfo[]) => {
      const speakerList = data
        .map((item) => {
          const member = memberList.find(
            (member) => member.uuid == item.userUuid
          )
          let name = item.userUuid
          if (member) {
            name = member.name
          }
          return {
            uid: item.userUuid,
            nickName: name,
            level: item.volume,
            show:
              member &&
              member.role !== 'screen_sharer' &&
              member.isAudioConnected,
          }
        })
        .filter((item) => item.show)
      setSpeakerList(speakerList)
      if (audioVolumeIndicationTimer.current) {
        clearTimeout(audioVolumeIndicationTimer.current)
        audioVolumeIndicationTimer.current = null
      }
      // 4s未收到新数据表示没人说话 情况列表
      audioVolumeIndicationTimer.current = window.setTimeout(() => {
        setSpeakerList([])
      }, 4000)
    }
    setSpeakerList(
      speakerList.filter((item) => {
        return memberList.find((member) => member.uuid === item.uid)
          ?.isAudioConnected
      })
    )

    eventEmitter?.on(EventType.RtcAudioVolumeIndication, handle)
    return () => {
      eventEmitter?.off(EventType.RtcAudioVolumeIndication, handle)
    }
  }, [memberList])

  return speakerList.length && !isLocalScreen ? (
    <SpeakerList
      className={`speaker-list-content ${
        showSpeakerList ? 'speaker-list-show' : 'speaker-list-hide'
      }`}
      speakerList={speakerList}
      onClick={onSpeakerClick}
    />
  ) : (
    <></>
  )
}

const MeetingContent: React.FC<AppProps> = ({ height, width }) => {
  const { t } = useTranslation()

  const { dispatch, meetingInfo, memberList } = useMeetingInfoContext()
  const { waitingRoomInfo, memberList: waitingRoomMemberList } =
    useWaitingRoomContext()
  const {
    eventEmitter,
    outEventEmitter,
    neMeeting,
    logger,
    waitingRejoinMeeting,
    dispatch: globalDispatch,
    online,
    showCloudRecordingUI,
    globalConfig,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const [showLiveModel, setShowLiveModel] = useState(false)
  const showCloudRecordingUIRef = useRef<boolean>(true)
  const cloudRecordModalRef = useRef<any>(null)

  showCloudRecordingUIRef.current = showCloudRecordingUI !== false

  const {
    joinLoading,
    isShowAudioDialog,
    isShowVideoDialog,
    setIsOpenVideoByHost,
    setIsShowVideoDialog,
    setIsOpenAudioByHost,
    setIsShowAudioDialog,
    confirmUnMuteMyAudio,
    confirmUnMuteMyVideo,
    showTimeTip,
    setShowTimeTip,
    timeTipContent,
  } = useEventHandler()

  useMeetingNotificationInMeeting()

  const meetingCanvasDomWidthResizeTimer = useRef<number | NodeJS.Timeout>()

  const mouseMoveTimerRef = useRef<number | NodeJS.Timeout>()
  // 是否点击全屏共享按钮
  const [isFullSharingScreen, setIsFullSharingScreen] = useState(false)
  const [controlBarVisible, setControlBarVisible] = useState(false)
  const [inviteModalVisible, setInviteModalVisible] = useState(false)
  const [settingOpen, setSettingOpen] = useState(false)
  const [settingModalTab, setSettingModalTab] =
    useState<SettingTabType>('normal')
  const [screenShareModalOpen, setScreenShareModalOpen] =
    useState<boolean>(false)
  const [shareLocalComputerSound, setShareLocalComputerSound] =
    useState<boolean>(false)
  const screenShareModalRef = useRef<ScreenShareModalRef>(null)
  const meetingWebRef = useRef<HTMLDivElement>(null)
  const newMeetingWebRef = useRef<HTMLDivElement>(null)
  const toastIdRef = useRef<string>('')
  const [isDarkMode, setIsDarkMode] = useState(true)
  const { onClickPlugin } = useMeetingPlugin()

  const handUpCount = useMemo(() => {
    return memberList.filter((item) => item.isHandsUp).length
  }, [memberList])

  const [showRecordTip, setShowRecordTip] = useState(false)
  const showRecordTipModalRef = useRef<any>(null)
  const recordTipTimer = useRef<any>(null)
  const previewRoomListenerRef = useRef<any>(null)
  usePreviewHandler()

  const { localMember } = meetingInfo
  const meetingInfoRef = useRef(meetingInfo)
  meetingInfoRef.current = meetingInfo

  const eleIpcIns = useMemo(() => eleIpc?.getInstance() || null, [])
  // 是否在预览
  const [isStartPreview, setIsStartPreview] = useState(false)

  const openRightDrawer = useMemo(() => {
    return meetingInfo.rightDrawerTabs.length > 0
  }, [meetingInfo.rightDrawerTabs])

  const isAudioMode = useMemo(() => {
    // 如果都为开启过视频则为音频模式；
    return (
      !meetingInfo.screenUuid &&
      !meetingInfo.whiteboardUuid &&
      memberList.every(
        (item) =>
          !item.isVideoOn && !item.isSharingScreen && !item.isSharingWhiteboard
      )
    )
  }, [memberList, meetingInfo.whiteboardUuid, meetingInfo.screenUuid])

  const showLayout = useMemo(() => {
    if (isAudioMode) {
      return false
    }
    if (memberList.length === 1) {
      return false
    }
    if (localMember.isSharingScreen) {
      return false
    }
    if (meetingInfo.whiteboardUuid) {
      return false
    }
    return true
  }, [
    memberList.length,
    meetingInfo.whiteboardUuid,
    localMember.isSharingScreen,
    isAudioMode,
  ])

  const { handlePostMessage } = usePostMessageHandle()

  useEffect(() => {
    if (memberList.length == 1) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          layout: LayoutTypeEnum.Speaker,
          speakerLayoutPlacement: 'top',
        },
      })
    }
  }, [dispatch, memberList.length])

  useEffect(() => {
    if (meetingInfo.whiteboardUuid) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          layout: LayoutTypeEnum.Speaker,
          speakerLayoutPlacement: 'top',
        },
      })
    }
  }, [dispatch, meetingInfo.whiteboardUuid])

  useEffect(() => {
    if (toastIdRef.current) {
      Toast.destroy(toastIdRef.current)
      toastIdRef.current = ''
    }
    if (showTimeTip && timeTipContent) {
      toastIdRef.current = Toast.info(timeTipContent, 0, true, () => {
        setShowTimeTip(false)
      })
    }
  }, [showTimeTip, timeTipContent])

  useEffect(() => {
    if (
      meetingInfo.screenUuid &&
      meetingInfo.layout !== LayoutTypeEnum.Speaker
    ) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          layout: LayoutTypeEnum.Speaker,
          speakerLayoutPlacement: 'top',
        },
      })
    }
  }, [dispatch, meetingInfo.screenUuid, meetingInfo.layout])

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])

  // 是否演讲者模式
  const isSpeaker = useMemo(() => {
    return meetingInfo.layout === 'speaker'
  }, [meetingInfo.layout])

  const randomPassword = useMemo(() => {
    return Math.random().toString().slice(-6)
  }, [])

  // 是否本端在共享
  const isLocalScreen = useMemo<boolean>(() => {
    return meetingInfo.localMember.isSharingScreen
  }, [meetingInfo.localMember.isSharingScreen])

  // 主画面高度
  const mainHeight = useMemo(() => {
    let _height = (height === 0 ? document.body.clientHeight : height) - 60
    if (!isLocalScreen) {
      if (isSpeaker && memberList.length > 1) _height = _height - 95
    }
    return _height
  }, [isLocalScreen, isSpeaker, memberList.length])

  useEffect(() => {
    window.ipcRenderer?.send(IPCEvent.meetingStatus, {
      inMeeting: meetingInfo.meetingNum ? true : false,
    })
  }, [meetingInfo.meetingNum])

  function changeLayout() {
    if (memberList.length === 1) {
      return
    }
    if (meetingInfo.screenUuid) {
      Toast.info(t('notSupportScreenShareChange'))
      return
    } else if (meetingInfo.whiteboardUuid) {
      Toast.info(t('notSupportWhiteboardShareChange'))
      return
    }
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        layout:
          meetingInfo.layout === LayoutTypeEnum.Speaker
            ? LayoutTypeEnum.Gallery
            : LayoutTypeEnum.Speaker,
      },
    })
  }
  const liveMembers = useMemo(() => {
    const resultList: NELiveMember[] = []
    memberList.forEach((member) => {
      if (member.isVideoOn || member.isSharingScreen) {
        resultList.push({
          nickName: member.name,
          accountId: member.uuid,
          isVideoOn: member.isVideoOn,
          isSharingScreen: member.isSharingScreen,
        })
      }
    })
    return resultList
  }, [memberList])

  const handleRecord = useCallback(() => {
    if (cloudRecordModalRef.current) {
      return
    }
    cloudRecordModalRef.current = Modal.confirm({
      width: 390,
      title: meetingInfo.isCloudRecording
        ? t('endCloudRecording')
        : t('isStartCloudRecord'),
      content: meetingInfo.isCloudRecording
        ? t('syncRecordFileAfterMeetingEnd')
        : showCloudRecordingUIRef.current
        ? t('startRecordTip')
        : t('startRecordTipNoNotify'),
      afterClose: () => {
        cloudRecordModalRef.current = null
      },
      okText: t('sure'),
      cancelText: t('globalCancel'),
      onOk: () => {
        if (meetingInfo.isCloudRecording) {
          neMeeting
            ?.stopCloudRecord()
            .then(() => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  cloudRecordState: RecordState.NotStart,
                },
              })
              return true
            })
            .catch((e) => {
              // todo 需要翻译
              Toast.fail(e.msg || e.message || e.code || t('stopRecordFailed'))
              return Promise.reject(e)
            })
        } else {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              cloudRecordState: RecordState.Starting,
            },
          })
          neMeeting
            ?.startCloudRecord()
            .then(() => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  cloudRecordState: RecordState.Recording,
                },
              })
            })
            .catch((e) => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  cloudRecordState: RecordState.NotStart,
                },
              })
              Toast.fail(e.msg || e.message || e.code || t('startRecordFailed'))
              return Promise.reject(e)
            })
        }
        cloudRecordModalRef.current?.destroy()
      },
    })
  }, [meetingInfo.isCloudRecording])

  const showRecord = useMemo(() => {
    const cloudRecord = meetingInfo.cloudRecordState
    return (
      (cloudRecord === RecordState.Recording ||
        cloudRecord === RecordState.Starting) &&
      showCloudRecordingUI
    )
  }, [meetingInfo.cloudRecordState, showCloudRecordingUI])

  // 打开会中窗口
  function openMeetingWindow(payload: {
    name: string
    url?: string
    postMessageData?: { event: string; payload: any }
  }) {
    const newWindow = openWindow(payload.name, payload.url)
    const postMessage = () => {
      payload.postMessageData &&
        newWindow?.postMessage(payload.postMessageData, '*')
    }
    // 不是第一次打开
    if (newWindow?.firstOpen === false) {
      postMessage()
    } else {
      windowLoadListener(newWindow)
      newWindow?.addEventListener('load', () => {
        postMessage()
      })
    }
  }

  function windowLoadListener(childWindow) {
    const previewController = neMeeting?.previewController
    const previewContext = neMeeting?.roomService?.getPreviewRoomContext()
    const chatController = neMeeting?.chatController
    const rtcController = neMeeting?.rtcController
    const roomService = neMeeting?.roomService
    function messageListener(e) {
      const { event, payload } = e.data
      if (event === 'neMeeting' && neMeeting) {
        const { replyKey, fnKey, args } = payload
        const result = neMeeting[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'meetingInfoDispatch') {
        dispatch?.(payload)
      } else if (event === 'notificationClick') {
        const { action } = payload
        if (action.startsWith('meeting://open_plugin')) {
          onClickPlugin(action)
        }
      } else if (event === 'previewContext' && previewController) {
        const { replyKey, fnKey, args } = payload
        const result = previewContext?.[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'previewController' && previewController) {
        const { replyKey, fnKey, args } = payload
        const result = previewController[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'chatController' && chatController) {
        const { replyKey, fnKey, args } = payload
        const result = chatController[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'roomService' && roomService) {
        const { replyKey, fnKey, args } = payload
        const result = roomService[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'chatroomOnMsgs') {
        setCacheMsgs(payload)
      } else if (event === 'rtcController' && rtcController) {
        const { replyKey, fnKey, args } = payload
        const result = rtcController[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'openWindow') {
        openMeetingWindow(payload)
      }
    }
    childWindow?.addEventListener('message', messageListener)
  }

  const handleControlBarDefaultButtonClick = async (key: string) => {
    switch (key) {
      case 'memberList':
        if (isElectronSharingScreen) {
          openMeetingWindow({
            name: 'memberWindow',
            postMessageData: {
              event: 'updateData',
              payload: {
                memberList: JSON.parse(JSON.stringify(memberList)),
                meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
                waitingRoomInfo: JSON.parse(JSON.stringify(waitingRoomInfo)),
                waitingRoomMemberList: JSON.parse(
                  JSON.stringify(waitingRoomMemberList)
                ),
              },
            },
          })
        } else {
          const rightDrawerTabs = meetingInfo.rightDrawerTabs

          const item = rightDrawerTabs.find((item) => item.key === 'memberList')
          // 没有添加
          if (!item) {
            rightDrawerTabs.push({
              // label: t('memberListTitle'),
              key: 'memberList',
            })
          }
          // 只有一个，则关闭
          if (item && rightDrawerTabs.length === 1) {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                rightDrawerTabs: [],
                rightDrawerTabActiveKey: '',
              },
            })
          } else {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                rightDrawerTabs: [...rightDrawerTabs],
                rightDrawerTabActiveKey: 'memberList',
              },
            })
          }
        }
        break
      case 'chat':
        if (isElectronSharingScreen) {
          console.log('open chatWindow', cacheMsgs)
          openMeetingWindow({
            name: 'chatWindow',
            postMessageData: {
              event: 'updateData',
              payload: {
                memberList: JSON.parse(JSON.stringify(memberList)),
                meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
                waitingRoomInfo: JSON.parse(JSON.stringify(waitingRoomInfo)),
                waitingRoomMemberList: JSON.parse(
                  JSON.stringify(waitingRoomMemberList)
                ),
                cacheMsgs: cacheMsgs,
              },
            },
          })
        } else {
          const rightDrawerTabs = meetingInfo.rightDrawerTabs
          const item = rightDrawerTabs.find((item) => item.key === 'chatroom')
          if (!item) {
            rightDrawerTabs.push({
              key: 'chatroom',
              // label: t('chat'),
            })
          }
          // 只有一个，则关闭
          if (item && rightDrawerTabs.length === 1) {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                rightDrawerTabs: [],
                rightDrawerTabActiveKey: '',
              },
            })
          } else {
            console.log('open chatroom')
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                rightDrawerTabs: [...rightDrawerTabs],
                rightDrawerTabActiveKey: 'chatroom',
              },
            })
          }
        }
        break
      case 'notification':
        if (isElectronSharingScreen) {
          openMeetingWindow({
            name: 'notificationListWindow',
            postMessageData: {
              event: 'windowOpen',
              payload: {
                meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
                isInMeeting: true,
              },
            },
          })
        } else {
          const rightDrawerTabs = meetingInfo.rightDrawerTabs
          const item = rightDrawerTabs.find(
            (item) => item.key === 'notification'
          )
          if (!item) {
            rightDrawerTabs.push({
              key: 'notification',
            })
          }
          // 只有一个，则关闭
          if (item && rightDrawerTabs.length === 1) {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                rightDrawerTabs: [],
                rightDrawerTabActiveKey: '',
              },
            })
          } else {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                rightDrawerTabs: [...rightDrawerTabs],
                rightDrawerTabActiveKey: 'notification',
              },
            })
          }
        }
        break
      case 'invite':
        if (isElectronSharingScreen) {
          openMeetingWindow({
            name: 'inviteWindow',
            postMessageData: {
              event: 'updateData',
              payload: {
                meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
              },
            },
          })
        } else {
          setInviteModalVisible(!inviteModalVisible)
        }
        break
      case 'layout':
        changeLayout()
        break
      case 'live':
        setShowLiveModel(true)
        break
      case 'record':
        handleRecord()
        break
      case 'electronShareScreen':
        screenShareModalRef.current?.getShareList()
        setScreenShareModalOpen(true)
        break
      default:
        break
    }
  }

  function handleFullSharingScreen() {
    setIsFullSharingScreen(!isFullSharingScreen)
  }

  function handleOpenChatroomOrMemberList(open: boolean) {
    window.ipcRenderer?.send(IPCEvent.openChatroomOrMemberList, open)
    const wrapDom = document.getElementById('meeting-web')
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

  function handleAppMouseMove() {
    document.hasFocus() && setControlBarVisible(true)
    clearTimeout(mouseMoveTimerRef.current)
    mouseMoveTimerRef.current = setTimeout(
      () => {
        setControlBarVisible(false)
      },
      isElectronSharingScreen ? 60 * 1000 : 3000
    )
  }

  function handleNoPermission() {
    window.ipcRenderer?.send(IPCEvent.noPermission)
  }

  function handleDrawWatermark() {
    const needDrawWatermark =
      meetingInfo.meetingNum &&
      meetingInfo.watermark &&
      (meetingInfo.watermark.videoStrategy === WATERMARK_STRATEGY.OPEN ||
        meetingInfo.watermark.videoStrategy === WATERMARK_STRATEGY.FORCE_OPEN)

    if (
      needDrawWatermark &&
      meetingInfo.watermark &&
      !isElectronSharingScreen
    ) {
      const { videoStyle, videoFormat } = meetingInfo.watermark
      const supportInfo = {
        name: meetingInfo.watermarkConfig?.name || localMember.name,
        phone: meetingInfo.watermarkConfig?.phone || '',
        email: meetingInfo.watermarkConfig?.email || '',
        jobNumber: meetingInfo.watermarkConfig?.jobNumber || '',
      }
      // videoFormat: '{key}_{key2}'
      function replaceFormat(format, info) {
        const regex = /{([^}]+)}/g
        const result = format?.replace(regex, (match, key) => {
          const value = info[key]
          return value ? value : match // 如果值存在，则返回对应的值，否则返回原字符串
        })
        return result
      }
      setTimeout(() => {
        drawWatermark({
          container: document.getElementById('ne-web-meeting') as HTMLElement,
          content: replaceFormat(videoFormat, supportInfo),
          type: videoStyle,
        })
      }, 0)
    } else {
      stopDrawWatermark()
    }
  }

  useUpdateEffect(() => {
    if (isHostOrCoHost) {
      const successMsg = meetingInfo.isLocked
        ? t('meetingLockMeetingByHost')
        : t('meetingUnLockMeetingByHost')
      Toast.success(successMsg)
    }
  }, [meetingInfo.isLocked])

  useEffect(() => {
    return () => {
      globalDispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          online: true,
        },
      })
      Modal.destroyAll()
    }
  }, [])

  useEffect(() => {
    handleDrawWatermark()
    window.addEventListener('resize', handleDrawWatermark)
    return () => {
      window.removeEventListener('resize', handleDrawWatermark)
    }
  }, [
    meetingInfo?.meetingNum,
    localMember?.name,
    meetingInfo.watermark,
    isElectronSharingScreen,
  ])

  useEffect(() => {
    const _setting = localStorage.getItem('ne-meeting-setting')
    if (_setting) {
      localStorage.setItem('ne-meeting-pre-meeting-setting', _setting)
      try {
        const setting = JSON.parse(_setting) as MeetingSetting
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            setting,
          },
        })
      } catch (error) {}
    }
    // 收到录制弹框提醒确认
    eventEmitter?.on(MeetingEventType.needShowRecordTip, (isCloudRecording) => {
      // 如果不显示ui则不弹窗提醒
      if (!showCloudRecordingUIRef.current) {
        return
      }
      if (showRecordTipModalRef.current) {
        showRecordTipModalRef.current.destroy()
      }
      if (isCloudRecording) {
        recordTipTimer.current && clearInterval(recordTipTimer.current)
        showRecordTipModalRef.current = Modal.confirm({
          width: 370,
          title: t('beingMeetingRecorded'),
          content: (
            <>
              <div className="start-record-tip">
                {t('startRecordTipByMember')}
              </div>
              <div className="agree-in-record">{t('agreeInRecordMeeting')}</div>
            </>
          ),
          okText: t('gotIt'),
          cancelText: t('meetingLeaveFull'),
          onOk() {
            showRecordTipModalRef.current.destroy()
            showRecordTipModalRef.current = null
          },
          onCancel: async () => {
            showRecordTipModalRef.current.destroy()
            showRecordTipModalRef.current = null
            eventEmitter?.emit(MeetingEventType.leaveOrEndRoom)
          },
        })
      } else {
        let remainTime = 3
        showRecordTipModalRef.current = Modal.confirm({
          width: 300,
          title: t('beingMeetingRecorded'),
          closeIcon: null,
          content: (
            <>
              <div className="nemeeting-modal-record-title">
                {t('cloudRecordingHasEnded')}
              </div>
              <div className="start-record-tip">
                {t('viewingLinkAfterMeetingEnd')}
              </div>
            </>
          ),
          onCancel: () => {
            recordTipTimer.current && clearInterval(recordTipTimer.current)
          },
          footer: (
            <div className="nemeeting-modal-confirm-btns">
              <Button
                onClick={() => {
                  recordTipTimer.current &&
                    clearInterval(recordTipTimer.current)
                  showRecordTipModalRef.current?.destroy()
                  showRecordTipModalRef.current = null
                }}
                type="primary"
              >
                {t('gotIt')}
                {remainTime ? '(' + remainTime + 's)' : ''}
              </Button>
            </div>
          ),
        })
        if (recordTipTimer.current) {
          clearInterval(recordTipTimer.current)
        }
        recordTipTimer.current = setInterval(() => {
          remainTime -= 1
          if (remainTime <= 0) {
            recordTipTimer.current && clearInterval(recordTipTimer.current)
            recordTipTimer.current = null
            showRecordTipModalRef.current?.destroy()
            showRecordTipModalRef.current = null
            // setShowRecordTip(false)
            return
          }
          showRecordTipModalRef.current?.update((prevConfig) => ({
            ...prevConfig,
            footer: (
              <div className="nemeeting-modal-confirm-btns">
                <Button
                  onClick={() => {
                    recordTipTimer.current &&
                      clearInterval(recordTipTimer.current)
                    showRecordTipModalRef.current?.destroy()
                    showRecordTipModalRef.current = null
                  }}
                  type="primary"
                >
                  {t('gotIt')}
                  {remainTime ? '(' + remainTime + 's)' : ''}
                </Button>
              </div>
            ),
          }))
        }, 1000)
      }
    })
    eventEmitter?.on(MeetingEventType.noMicPermission, () => {
      const modal = Modal.confirm({
        closable: true,
        title: t('microphonePermission'),
        content: (
          <div className="nemeeting-permission-modal">
            <div>{t('microphonePermissionTips')}</div>
            <div className="permission-tips-step">
              {t('microphonePermissionTipsStep')}
            </div>
            <div className="nemeeting-permission-btn-wrap">
              <Button
                onClick={() => {
                  modal.destroy()
                  handleNoPermission()
                }}
                type="primary"
              >
                {t('openSystemPreferences')}
              </Button>
            </div>
          </div>
        ),
        footer: null,
      })
    })
    eventEmitter?.on(MeetingEventType.noCameraPermission, () => {
      const modal = Modal.confirm({
        closable: true,
        title: t('cameraPermission'),
        content: (
          <div className="nemeeting-permission-modal">
            <div>{t('cameraPermissionTips')}</div>
            <div className="permission-tips-step">
              {t('cameraPermissionTipsStep')}
            </div>
            <div className="nemeeting-permission-btn-wrap">
              <Button
                onClick={() => {
                  modal.destroy()
                  handleNoPermission()
                }}
                type="primary"
              >
                {t('openSystemPreferences')}
              </Button>
            </div>
          </div>
        ),
        footer: null,
      })
    })
    // 创建会议 会议已经存在
    eventEmitter?.on(
      EventType.MeetingExits,
      (data: { options: CreateOptions; callback: (e?: any) => void }) => {
        Modal.confirm({
          title: t('meetingExist'),
          content: t('joinTheExistMeeting'),
          onCancel: () => {
            eventEmitter.emit(UserEventType.CancelJoin)
          },
          onOk: () => {
            outEventEmitter?.emit(UserEventType.JoinMeeting, {
              options: data.options,
              callback: data.callback,
            })
          },
        })
      }
    )
    window.ipcRenderer?.on(IPCEvent.changeSetting, (event, setting) => {
      onSettingChange(setting)
    })
    // 设置页面切换音频或者视频设备 setting: {type: 'video'|'audio', deviceId: string, deviceName?: string}
    window.ipcRenderer?.on(IPCEvent.changeSettingDevice, (event, setting) => {
      onDeviceChange(setting.type, setting.deviceId, setting.deviceName)
    })

    window.ipcRenderer?.invoke('get-theme-color').then((isDark) => {
      setIsDarkMode(isDark)
    })
    window.ipcRenderer?.on('set-theme-color', (_, isDark) => {
      setIsDarkMode(isDark)
    })
    window.ipcRenderer?.on(IPCEvent.alreadyInMeeting, () => {
      message.info(t('alreadyInMeeting'))
    })
    // eslint-disable-next-line react-hooks/exhaustive-deps
    return () => {
      eventEmitter?.off(MeetingEventType.needShowRecordTip)
      eventEmitter?.off(MeetingEventType.noCameraPermission)
      eventEmitter?.off(MeetingEventType.noMicPermission)
      eventEmitter?.off(EventType.MeetingExits)
      window.ipcRenderer?.removeAllListeners(IPCEvent.alreadyInMeeting)
    }
  }, [])

  useEffect(() => {
    handleOpenChatroomOrMemberList(openRightDrawer)
  }, [openRightDrawer])

  // 重新加入会议
  const rejoinMeeting = () => {
    eventEmitter?.emit(UserEventType.RejoinMeeting, {
      isAudioOn: localMember.isAudioOn,
      isVideoOn: localMember.isVideoOn,
    })
  }

  useEffect(() => {
    if (!!waitingRejoinMeeting) {
      if (isElectronSharingScreen) {
        dispatch?.({
          type: ActionType.UPDATE_MEMBER,
          data: {
            uuid: localMember.uuid,
            member: { isSharingScreen: false },
          },
        })
      }
      Modal.confirm({
        title: t('networkAbnormality'),
        content: t('networkDisconnected'),
        cancelText: t('meetingLeaveFull'),
        okText: t('rejoin'),
        onCancel: () => {
          leaveMeeting()
        },
        onOk: () => {
          rejoinMeeting()
        },
      })
    }
  }, [waitingRejoinMeeting])

  useEffect(() => {
    if (!meetingInfo.meetingNum) {
      return
    }
    if (isShowAudioDialog) {
      if (!localMember.isAudioOn) {
        const modal = Modal.confirm({
          title: t('participantOpenMicrophone'),
          content: t('participantHostOpenMicroTips'),
          onCancel: () => {
            setIsOpenAudioByHost(false)
            setIsShowAudioDialog(false)
            eventEmitter?.emit(EventType.RoomsSendEvent, {
              cmdId: 337,
            })
          },
          onOk: () => {
            if (localMember.isAudioConnected) {
              confirmUnMuteMyAudio()
            }
          },
        })

        function handleRooms({ commandId }) {
          if (commandId === 312) {
            setIsOpenAudioByHost(false)
            setIsShowAudioDialog(false)
            modal.destroy()
          }
        }
        eventEmitter?.on(EventType.RoomsCustomEvent, handleRooms)
        return () => {
          eventEmitter?.on(EventType.RoomsCustomEvent, handleRooms)
          setIsOpenAudioByHost(false)
          setIsShowAudioDialog(false)
          modal.destroy()
        }
      }
    }
  }, [isShowAudioDialog, localMember.isAudioOn])

  const fullSharingScreen = useMemo(() => {
    return (
      !!meetingInfo.screenUuid &&
      (isFullSharingScreen || !!meetingInfo.isScreenSharingMeeting)
    )
  }, [
    meetingInfo.screenUuid,
    meetingInfo.isScreenSharingMeeting,
    isFullSharingScreen,
  ])

  useEffect(() => {
    if (!meetingInfo.meetingNum) {
      return
    }
    if (isShowVideoDialog) {
      if (!localMember.isVideoOn) {
        const modal = Modal.confirm({
          title: t('participantOpenCamera'),
          content: t('participantHostOpenCameraTips'),
          onCancel: () => {
            setIsOpenVideoByHost(false)
            setIsShowVideoDialog(false)
            eventEmitter?.emit(EventType.RoomsSendEvent, {
              cmdId: 338,
            })
          },
          onOk: () => {
            confirmUnMuteMyVideo()
          },
        })

        function handleRooms({ commandId }) {
          if (commandId === 313) {
            setIsOpenVideoByHost(true)
            setIsShowVideoDialog(false)
            modal.destroy()
          }
        }
        eventEmitter?.on(EventType.RoomsCustomEvent, handleRooms)
        return () => {
          eventEmitter?.off(EventType.RoomsCustomEvent, handleRooms)
          setIsOpenVideoByHost(false)
          setIsShowVideoDialog(false)
          modal.destroy()
        }
      }
    }
  }, [isShowVideoDialog, localMember.isVideoOn])

  // 解决本端画布没有时候，打开音频报错没有画布问题
  useEffect(() => {
    const view = document.getElementById('ne-web-meeting')
    view && neMeeting?.rtcController?.setupLocalVideoCanvas(view)
  }, [neMeeting?.rtcController])

  useEffect(() => {
    const resolution = meetingInfo.setting?.videoSetting.resolution
    if (resolution) {
      neMeeting?.setVideoProfile(resolution)
    }
  }, [meetingInfo.setting?.videoSetting.resolution])

  useEffect(() => {
    const audioSetting = meetingInfo.setting?.audioSetting
    if (!audioSetting || !window?.isElectronNative) {
      return
    }
    console.log('会中 开始处理高级音频设置 audioSetting', audioSetting)
    try {
      if (audioSetting.enableAudioAI) {
        // @ts-ignore
        neMeeting?.enableAudioAINS(true)
      } else {
        // @ts-ignore
        neMeeting?.enableAudioAINS(false)
        if (audioSetting.enableMusicMode) {
          neMeeting?.enableAudioEchoCancellation(
            audioSetting.enableAudioEchoCancellation as boolean
          )
          if (audioSetting.enableAudioStereo) {
            neMeeting?.setAudioProfileInEle(
              tagNERoomRtcAudioProfileType.kNEAudioProfileHighQualityStereo,
              tagNERoomRtcAudioScenarioType.kNEAudioScenarioMusic
            )
          } else {
            neMeeting?.setAudioProfileInEle(
              tagNERoomRtcAudioProfileType.kNEAudioProfileHighQuality,
              tagNERoomRtcAudioScenarioType.kNEAudioScenarioMusic
            )
          }
        } else {
          neMeeting?.setAudioProfileInEle(
            tagNERoomRtcAudioProfileType.kNEAudioProfileDefault,
            tagNERoomRtcAudioScenarioType.kNEAudioScenarioDefault
          )
        }
      }
    } catch (e) {
      console.log('会中 处理高级音频设置error', e)
    }
  }, [
    meetingInfo.setting?.audioSetting.enableAudioAI,
    meetingInfo.setting?.audioSetting.enableMusicMode,
    meetingInfo.setting?.audioSetting.enableAudioStereo,
    meetingInfo.setting?.audioSetting.enableAudioEchoCancellation,
  ])

  useEffect(() => {
    const audioSetting = meetingInfo.setting?.audioSetting
    if (!audioSetting || !window?.isElectronNative) {
      return
    }
    try {
      // @ts-ignore
      neMeeting?.enableAudioVolumeAutoAdjust(
        audioSetting.enableAudioVolumeAutoAdjust
      )
    } catch (e) {
      console.log('会中 设置是否自动调节麦克风音量error', e)
    }
  }, [meetingInfo.setting?.audioSetting.enableAudioVolumeAutoAdjust])

  // 设置扬声器输出音量变更
  useEffect(() => {
    const playouOutputtVolume =
      meetingInfo.setting?.audioSetting.playouOutputtVolume
    if (playouOutputtVolume || playouOutputtVolume === 0) {
      try {
        neMeeting?.rtcController?.adjustPlaybackSignalVolume(
          playouOutputtVolume
        )
      } catch (e) {}
    }
  }, [meetingInfo.setting?.audioSetting.playouOutputtVolume])

  // 设置麦克风采集音量变更
  useEffect(() => {
    const recordOutputVolume =
      meetingInfo.setting?.audioSetting.recordOutputVolume
    if (recordOutputVolume || recordOutputVolume === 0) {
      if (window.isElectronNative) {
        //@ts-ignore
        neMeeting?.previewController?.setRecordDeviceVolume(recordOutputVolume)
      } else {
        try {
          neMeeting?.rtcController?.adjustRecordingSignalVolume(
            recordOutputVolume
          )
        } catch (e) {}
      }
    }
  }, [meetingInfo.setting?.audioSetting.recordOutputVolume])

  function onSettingChange(setting: MeetingSetting) {
    localStorage.setItem('ne-meeting-setting', JSON.stringify(setting))
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        setting,
      },
    })
  }

  async function getDeviceIdFromWebDeviceName(
    type: 'video' | 'speaker' | 'microphone',
    deviceName: string
  ) {
    let deviceId = ''
    if (deviceName) {
      if (type === 'video') {
        const res = await neMeeting?.getCameras()
        const device = res?.find((device) =>
          deviceName.includes(device.deviceName)
        )
        device && (deviceId = device.deviceId)
      } else if (type === 'microphone') {
        const res = await neMeeting?.getMicrophones()
        const device = res?.find((device) =>
          deviceName.includes(device.deviceName)
        )
        device && (deviceId = device.deviceId)
      } else {
        const res = await neMeeting?.getSpeakers()
        const device = res?.find((device) =>
          deviceName.includes(device.deviceName)
        )
        device && (deviceId = device.deviceId)
      }
    }
    return deviceId
  }

  async function leaveMeeting() {
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingRejoinMeeting: false,
      },
    })
    eventEmitter?.emit(EventType.RoomEnded, 'LEAVE_BY_SELF')
  }
  async function onDeviceChange(
    type: 'video' | 'speaker' | 'microphone',
    deviceId: string,
    deviceName?: string
  ) {
    logger?.debug('changeDevice', type, deviceId, deviceName)
    // electron c++
    if (deviceName) {
      try {
        deviceId =
          (await getDeviceIdFromWebDeviceName(type, deviceName)) || deviceId
      } catch (e) {}
    }
    switch (type) {
      case 'video':
        neMeeting?.changeLocalVideo(deviceId)
        break
      case 'speaker':
        neMeeting?.selectSpeakers(deviceId)
        break
      case 'microphone':
        neMeeting?.changeLocalAudio(deviceId)
        break
    }
    eventEmitter?.emit(EventType.ChangeDeviceFromSetting, {
      type,
      deviceId,
    })
  }

  function onSettingClick(type: SettingTabType) {
    if (window.ipcRenderer) {
      openMeetingWindow({
        name: 'settingWindow',
        postMessageData: {
          event: 'openSetting',
          payload: {
            type,
            inMeeting: true,
          },
        },
      })
    } else {
      setSettingOpen(true)
      setSettingModalTab(type)
    }
  }

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
      const settingWindow = getWindow('settingWindow')
      settingWindow?.postMessage({
        event: IPCEvent.changeSettingDeviceFromControlBar,
        payload: {
          type,
          deviceId,
        },
      })
      onSettingChange(setting)
    }
  }

  const startShareInEle = async (shareItem) => {
    setScreenShareModalOpen(false)
    // 关闭侧边栏
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        rightDrawerTabs: [],
        rightDrawerTabActiveKey: '',
      },
    })
    window.ipcRenderer?.send('quiteFullscreen')
    try {
      await neMeeting?.unmuteLocalScreenShare({
        sourceId: shareItem?.id || shareItem?.displayId,
        isApp: shareItem?.isApp,
      })
      openShareVideoWindow()
    } catch (e: any) {
      if (e && e.code === 1012) {
        Toast.fail(t('functionalityLimitedByTheNumberOfPeople'))
      }
      if (e && e.code === 1024) {
        Toast.fail(t('screenShareNoPermission'))
      }
      //@ts-ignore
      neMeeting?.rtcController?.stopSystemAudioLoopbackCapture?.()
      console.warn('startShareInEle error', e)
    } finally {
      setScreenShareModalOpen(false)
    }
  }

  function openShareVideoWindow() {
    memberList.forEach((member) => {
      if (member.isVideoOn && member.uuid !== localMember.uuid) {
        neMeeting?.unsubscribeRemoteVideoStream(member.uuid, 1)
      }
    })
    openMeetingWindow({
      name: 'shareVideoWindow',
      postMessageData: {
        event: 'updateData',
        payload: {
          memberList: JSON.parse(JSON.stringify(memberList)),
          meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
        },
      },
    })
  }

  const getIsFullScreen = async () => {
    return new Promise((resolve) => {
      window.ipcRenderer?.send(IPCEvent.isMainFullscreen)
      window.ipcRenderer?.once(
        // 注意这里使用 `once` 而非 `on`
        IPCEvent.isMainFullscreenReply,
        (event, isFullScreen) => {
          resolve(isFullScreen) // 使用 resolve
        }
      )
    })
  }

  const isHostOrCoHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  useEffect(() => {
    if (isElectronSharingScreen && isHostOrCoHost && handUpCount > 0) {
      setControlBarVisible(true)
      clearTimeout(mouseMoveTimerRef.current)
      mouseMoveTimerRef.current = setTimeout(() => {
        setControlBarVisible(false)
      }, 5000)
    }
  }, [isHostOrCoHost, handUpCount, isElectronSharingScreen])
  useEffect(() => {
    if (!isHostOrCoHost && showLiveModel) {
      setShowLiveModel(false)
    }
  }, [isHostOrCoHost, showLiveModel])

  useEffect(() => {
    if (!meetingInfo.meetingNum) {
      setInviteModalVisible(false)
      setShowLiveModel(false)
      setScreenShareModalOpen(false)
      if (!waitingRejoinMeeting) {
        Modal.destroyAll()
      }
    }
  }, [meetingInfo.meetingNum, waitingRejoinMeeting])

  useEffect(() => {
    if (window.isElectronNative) {
      window.ipcRenderer?.on(IPCEvent.previewController, (_, data) => {
        const previewController = neMeeting?.previewController
        if (!previewController) {
          return
        }
        const { method, args } = data
        if (method === 'startPreview') {
          setIsStartPreview(true)
          return
        } else if (method === 'stopPreview') {
          setIsStartPreview(false)
          return
        }
        neMeeting?.previewController?.[method]?.(...args)
      })
    }
  }, [])

  useEffect(() => {
    if (isElectronSharingScreen) {
      closeWindow('settingWindow')
      function setExcludeWindowList(_, data) {
        // @ts-ignore
        neMeeting?.rtcController.setExcludeWindowList(...data)
      }
      window.ipcRenderer?.on('setExcludeWindowList', setExcludeWindowList)
      return () => {
        window.ipcRenderer?.off('setExcludeWindowList', setExcludeWindowList)
        closeAllWindows()
      }
    }
  }, [isElectronSharingScreen, neMeeting?.rtcController])

  useEffect(() => {
    if (meetingInfo.screenUuid === localMember.uuid) {
      getActiveWindows().forEach((window) => {
        window.postMessage({
          event: 'updateData',
          payload: {
            memberList: JSON.parse(JSON.stringify(memberList)),
            meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
            waitingRoomInfo: JSON.parse(JSON.stringify(waitingRoomInfo)),
            waitingRoomMemberList: JSON.parse(
              JSON.stringify(waitingRoomMemberList)
            ),
          },
        })
      })
    }
  }, [
    memberList,
    meetingInfo,
    waitingRoomInfo,
    waitingRoomMemberList,
    localMember.uuid,
  ])

  useEffect(() => {
    function handle(uuid, bSubVideo, data, type, width, height) {
      if (isStartPreview && uuid === localMember.uuid) {
        const settingWindow = getWindow('settingWindow')
        settingWindow?.postMessage(
          {
            event: 'onVideoFrameData',
            payload: {
              uuid,
              bSubVideo,
              data,
              type,
              width,
              height,
            },
          },
          '*',
          [data.bytes.buffer]
        )
      }
      if (meetingInfo.screenUuid === localMember.uuid) {
        const shareVideoWindow = getWindow('shareVideoWindow')
        shareVideoWindow?.postMessage(
          {
            event: 'onVideoFrameData',
            payload: {
              uuid,
              bSubVideo,
              data,
              type,
              width,
              height,
            },
          },
          '*',
          [data.bytes.buffer]
        )
      } else {
        const type = bSubVideo ? 'screen' : 'video'
        worker.postMessage(
          {
            frame: {
              width,
              height,
              data,
            },
            uuid,
            type,
          },
          [data.bytes.buffer]
        )
      }
    }
    eventEmitter?.on(EventType.onVideoFrameData, handle)
    return () => {
      eventEmitter?.off(EventType.onVideoFrameData, handle)
    }
  }, [meetingInfo.screenUuid, eventEmitter, isStartPreview, localMember.uuid])

  useEffect(() => {
    const properties = localMember.properties
    if (properties) {
      if (properties.viewLayout && properties.viewLayout.value) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            layout:
              localMember.properties.viewLayout.value === '1'
                ? LayoutTypeEnum.Gallery
                : LayoutTypeEnum.Speaker,
          },
        })
      }
      if (properties.speakerOn && properties.speakerOn.value) {
        if (properties.speakerOn.value === '0') {
          const speakerVolume =
            // @ts-ignore
            neMeeting?.previewController?.getPlayoutDeviceVolume()
          // @ts-ignore
          neMeeting?.previewController?.setPlayoutDeviceVolume(0)
          // @ts-ignore
          neMeeting?.previewController?.setPlayoutDeviceMute?.(true)
          return () => {
            if (speakerVolume) {
              // @ts-ignore
              neMeeting?.previewController?.setPlayoutDeviceMute?.(false)
              // @ts-ignore
              neMeeting?.previewController?.setPlayoutDeviceVolume(
                speakerVolume
              )
            }
          }
        }
      }
    }
  }, [localMember.properties, dispatch, neMeeting])

  useEffect(() => {
    if (!online) {
      setShowLiveModel(false)
    }
    if (!online && !waitingRejoinMeeting) {
      const loadingMask = document.querySelector('.loading-mask')
      loadingMask?.addEventListener('click', function (event) {
        event.stopPropagation()
        event.preventDefault()
      })
    }
  }, [online, waitingRejoinMeeting])

  useEffect(() => {
    if (!online && !waitingRejoinMeeting && isElectronSharingScreen) {
      const toastId = Toast.fail(t('disconnected'), 100000)
      return () => {
        Toast.destroy(toastId)
      }
    }
  }, [online, waitingRejoinMeeting, isElectronSharingScreen, t])

  const isShowControlBar = useMemo(() => {
    if (meetingInfo.hiddenControlBar === true) {
      return false
    }
    // 共享白板状态下需要展示控制栏
    if (
      meetingInfo.enableFixedToolbar === false &&
      !(meetingInfo.whiteboardUuid && !meetingInfo.screenUuid)
    ) {
      return false
    }
    return true
  }, [
    meetingInfo.enableFixedToolbar,
    meetingInfo.whiteboardUuid,
    meetingInfo.screenUuid,
    meetingInfo.hiddenControlBar,
  ])

  const meetingWebStyle = useMemo(() => {
    let top = window.isElectronNative ? 28 : 0
    if (meetingInfo.isScreenSharingMeeting || isElectronSharingScreen) {
      top = 0
    }
    if (meetingInfo.isRooms) {
      top = 50
    }
    return {
      top: top,
      height: height ? `${height}px` : `calc(100% - ${top}px)`,
    }
  }, [
    isElectronSharingScreen,
    height,
    meetingInfo.isRooms,
    meetingInfo.isScreenSharingMeeting,
  ])

  useEffect(() => {
    if (isHostOrCoHost) {
      neMeeting?.chatController?.joinChatroom(1)
    } else {
      neMeeting?.chatController?.leaveChatroom(1)
    }
  }, [isHostOrCoHost, neMeeting])

  // 举手状态下，先放下手
  useEffect(() => {
    if (localMember.isHandsUp && localMember.isSharingScreen) {
      neMeeting?.sendMemberControl(memberAction.handsDown, localMember.uuid)
    }
  }, [
    localMember.isHandsUp,
    localMember.isSharingScreen,
    neMeeting,
    localMember.uuid,
  ])

  useUpdateEffect(() => {
    const isLastChatroomTab =
      meetingInfo.rightDrawerTabs.length === 1 &&
      meetingInfo.rightDrawerTabs[0].key === 'chatroom'

    if (
      !isLastChatroomTab &&
      meetingInfo.rightDrawerTabActiveKey === 'chatroom'
    ) {
      handleControlBarDefaultButtonClick('chat')
    }
  }, [meetingInfo.rightDrawerTabActiveKey])

  // 通知组件是否正在共享屏幕
  useEffect(() => {
    const isSharingScreen = meetingInfo.screenUuid === localMember.uuid
    outEventEmitter?.emit(
      UserEventType.OnScreenSharingStatusChange,
      isSharingScreen
    )
  }, [meetingInfo.screenUuid, localMember.uuid, outEventEmitter])

  return (
    <div
      className={classNames('h-full relative meeting-web-wrapper flex', {
        ['light-theme']: !isDarkMode,
      })}
      style={{
        background: isElectronSharingScreen ? 'transparent' : undefined,
      }}
    >
      {!isElectronSharingScreen && window.isElectronNative && (
        <div className="electron-in-meeting-drag-bar">
          <div className="drag-region" />
          {t('appTitle')}
          <PCTopButtons />
        </div>
      )}
      {meetingInfo.isRooms && !meetingInfo.isScreenSharingMeeting && (
        <RoomsHeader style={{ right: openRightDrawer ? 320 : 0 }} />
      )}
      <div
        className="nemeeting flex flex-col h-full relative meeting-web"
        id="meeting-web"
        // ref={meetingWebRef}
        ref={newMeetingWebRef}
        style={{
          // background: window.isElectronNative ? 'transparent' : undefined,
          flex: 1,
          paddingBottom: `${isShowControlBar ? '60px' : '0'}`,
          transition: window.ipcRenderer ? 'none' : 'width 0.3s',
          ...meetingWebStyle,
        }}
        onClickCapture={() => {
          handleAppMouseMove()
        }}
        onMouseMove={() => {
          handleAppMouseMove()
        }}
        onMouseEnter={() => {
          setControlBarVisible(true)
        }}
        onMouseLeave={() => {
          clearTimeout(mouseMoveTimerRef.current)
          mouseMoveTimerRef.current = setTimeout(() => {
            setControlBarVisible(false)
          }, 3000)
        }}
      >
        {meetingInfo.meetingNum && !waitingRejoinMeeting ? (
          <>
            {/*<MeetingHeader open={true} getContainer={false} />*/}
            <ControlBar
              open={controlBarVisible || isShowControlBar !== false}
              controlBarVisibleByMouse={controlBarVisible}
              onSettingClick={onSettingClick}
              onDeviceSelectedChange={onDeviceSelectedChange}
              onDefaultButtonClick={handleControlBarDefaultButtonClick}
              getContainer={false}
            />
            {meetingInfo.enableUnmuteBySpace && <LongPressSpaceUnmute />}
            {!isElectronSharingScreen && (
              <>
                <InviteModal
                  open={inviteModalVisible}
                  onCancel={() => setInviteModalVisible(false)}
                />
                {!waitingRejoinMeeting && (
                  <div className="nemeeting-top-right-wrap">
                    {meetingInfo.showDurationTime && (
                      <MeetingDuration
                        className="nemeeting-top-right-item"
                        startTime={meetingInfo.rtcStartTime}
                      />
                    )}
                    {showLayout && (
                      <MeetingLayout className="nemeeting-top-right-item" />
                    )}
                  </div>
                )}
                {!meetingInfo.isRooms && !waitingRejoinMeeting && (
                  <Network
                    className={'nemeeting-network'}
                    onSettingClick={onSettingClick}
                  />
                )}
                {!meetingInfo.isRooms && !waitingRejoinMeeting && (
                  <MeetingInfo className={'nemeeting-info'} />
                )}
                <div className="nemeeting-top-left-reminds">
                  {/*直播中提示*/}
                  {!meetingInfo.isRooms && meetingInfo.liveState === 2 && (
                    <div className="living">
                      <span className="living-icon" />
                      <span>{t('living')}</span>
                    </div>
                  )}
                  {showRecord && (
                    <Record
                      className="nemeeting-record-wrap"
                      stopRecord={handleRecord}
                      recordState={meetingInfo.cloudRecordState}
                      notShowRecordBtn={!isHostOrCoHost}
                    />
                  )}
                </div>
                {meetingInfo.showSpeaker && (
                  <SpeakerListWrap
                    memberList={memberList}
                    isLocalScreen={isLocalScreen}
                  />
                )}
                {neMeeting?.previewController && (
                  <Setting
                    inMeeting={true}
                    onDeviceChange={onDeviceChange}
                    defaultTab={settingModalTab}
                    destroyOnClose={true}
                    setting={meetingInfo.setting}
                    onSettingChange={onSettingChange}
                    previewController={neMeeting.previewController}
                    open={settingOpen}
                    onCancel={() => setSettingOpen(false)}
                  />
                )}
                {isHostOrCoHost && (
                  <Modal
                    width={904}
                    wrapClassName="live-model-wrap"
                    open={showLiveModel}
                    maskClosable={false}
                    footer={null}
                    title={t('live')}
                    closable={true}
                    onCancel={() => setShowLiveModel(false)}
                    destroyOnClose={true}
                  >
                    <Live
                      members={liveMembers}
                      title={meetingInfo.subject}
                      state={meetingInfo.liveState}
                      randomPassword={randomPassword}
                    />
                  </Modal>
                )}

                <ScreenShareListModal
                  open={screenShareModalOpen}
                  shareSound={shareLocalComputerSound}
                  onShareSoundChanged={setShareLocalComputerSound}
                  onCancel={() => {
                    setScreenShareModalOpen(false)
                  }}
                  onStartShare={startShareInEle}
                  ref={screenShareModalRef}
                />
              </>
            )}
            <MeetingCanvas
              onHandleFullSharingScreen={handleFullSharingScreen}
              mainHeight={mainHeight}
              isSpeaker={isSpeaker}
              isAudioMode={isAudioMode}
              isFullSharingScreen={fullSharingScreen}
              isLocalScreen={isLocalScreen}
            />
          </>
        ) : joinLoading ? (
          <div className="meeting-loading">
            <div className="meeting-loading-content">
              <img className="meeting-loading-img" src={loading} alt="" />
              <div className="meeting-loading-text">{t('meetingJoinTips')}</div>
            </div>
          </div>
        ) : (
          ''
        )}
      </div>
      {meetingInfo.rightDrawerTabs.length > 0 && !isElectronSharingScreen ? (
        <div style={{ width: 320 }} />
      ) : null}
      {meetingInfo.meetingNum && <MeetingRightDrawer />}
      {/* {showTimeTip && (
        <RemainTimeTip
          className={
            isLocalScreen && window?.isElectronNative
              ? 'nemeeting-time-tip-wrap-share'
              : 'nemeeting-time-tip-wrap'
          }
          text={timeTipContent}
          onCloseHandler={() => {
            setShowTimeTip(false)
          }}
        />
      )} */}
      {!online && !waitingRejoinMeeting && !isElectronSharingScreen && (
        <div className="loading-mask">
          <p className={'nemeeint-online'}>{t('disconnected')}</p>
        </div>
      )}
      <MeetingNotification />
    </div>
  )
}

export default MeetingContent
