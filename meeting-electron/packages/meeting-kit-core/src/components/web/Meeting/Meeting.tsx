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
  useGlobalContext,
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
  RecordState,
  LocalRecordState,
  tagNERoomRtcAudioProfileType,
  tagNERoomRtcAudioScenarioType,
} from '../../../types/innerType'
import MeetingCanvas from '../MeetingCanvas'
import MeetingRightDrawer from '../MeetingRightDrawer'

import Modal, { ConfirmModal } from '../../common/Modal'
import PluginAppModal from '../../common/PlugIn/MeetingPluginModal/index'

import { useMount, useUnmount, useUpdateEffect } from 'ahooks'
import { Button, MenuProps, message } from 'antd'
import {
  NECommonError,
  NECustomSessionMessage,
  NEMemberVolumeInfo,
  NERoomCaptionTranslationLanguage,
  VideoFrameRate,
  VideoResolution,
} from 'neroom-types'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../app/src/types'
import { useIsAudioMode } from '../../../hooks/useAudioMode'
import { useMeetingNotificationInMeeting } from '../../../hooks/useMeetingNotification'
import useMeetingPlugin from '../../../hooks/useMeetingPlugin'
import useNotificationHandle from '../../../hooks/useNotificationHandle'
import usePostMessageHandle from '../../../hooks/usePostMessagehandle'
import usePreviewHandler from '../../../hooks/usePreviewHandler'
import useMeetingPlaySound from '../../../hooks/useMeetingPlaySound'
import {
  closeAllWindows,
  closeWindow,
  getActiveWindows,
  getWindow,
  openWindow,
} from '../../../utils/windowsProxy'
import Network from '../../common/Network'
import MeetingNotification, {
  MeetingNotificationRef,
} from '../../common/Notification'
import PCTopButtons from '../../common/PCTopButtons'
import Record from '../../common/Record'
import LocalRecord from '../../common/LocalRecord'
import Toast from '../../common/toast'
import ScreenShareListModal, {
  ScreenShareModalRef,
} from '../../electron/ScreenShareListModal'
import ControlBar from '../ControlBar'
import InviteModal from '../InviteModal'
import Live from '../Live'
import LongPressSpaceUnmute from '../LongPressSpaceUnmute'
import MeetingDuration from '../MeetingDuration'
import MeetingInfo from '../MeetingInfo'
import MeetingLayout, { useMeetingViewOrder } from '../MeetingLayout'
import RoomsHeader from '../RoomsHeader'
import Setting from '../Setting'
import { SettingTabType } from '../Setting/Setting'
import SpeakerList from '../SpeakerList'
import './index.less'
import useWatermark from '../../../hooks/useWatermark'
import {
  getLocalStorageSetting,
  objectToQueryString,
  setLocalStorageSetting,
} from '../../../utils'
import {
  NEProps,
  NEMeetingInterpretationSettings,
  NEMeetingWebAppItem,
} from '../../../types/type'
import InterpreterSettingModal from '../../common/Interpretation/InterpreterSettingModal'
import InterpretationWindow from '../../common/Interpretation/InterpreterWindow'
import useInterpreter, { useMyLangList } from '../../../hooks/useInterpreter'
import { useDefaultLanguageOptions } from '../../../hooks/useInterpreterLang'
import { MAJOR_AUDIO, MAJOR_DEFAULT_VOLUME } from '../../../config'
import useInterpreterModal from './useInterpreterModal'
import CommonModal from '../../common/CommonModal'
import FeedbackModal from '../../common/Feedback/FeedBackModal'
import CaptionWrapper from '../Caption/CaptionWrapper'
import useSaveSetting from '../../../hooks/useSaveSetting'
import { useChatRoomContext } from '../../../hooks/useChatRoom'
import BulletScreenMessage from '../../common/BulletScreenMessage'
import ChatRoomModal from '../NEChatRoom/NEChatRoomModal'
import BackSharingViewButton from '../BackSharingViewButton'
import ConnectAudioModal from '../ConnectAudioModal'
import SharingComputerSound from '../SharingComputerSound'
import SharingScreenZoom from '../SharingScreenZoom'
import useScreenSharing from '../../../hooks/useScreenSharing'
import useWindowManage from '../../../hooks/useSetting'
import useCloudRecord from '../../../hooks/useCloudRecord'
import useLocalRecord from '../../../hooks/useLocalRecord'
import { EndDropdown } from '../ControlBar/Buttons/EndButton'
import useFullscreen from '../../../hooks/useFullscreen'
import FullScreenButton from '../FullScreenButton'
import usePreview from '../../../hooks/usePreview'
import useWebLocalAudioVolume from '../../../hooks/useWebLocalAudioVolume'
import { useElectronShortcutOperation } from '../../../hooks/useVideoShortcutOperation'
import useDualMonitors from '../../../hooks/useDualMonitors'
import NoSpeakerVolume from '../NoSpeakerVolume'
import useAudioHowling from '../../../hooks/useAudioHowling'

interface AppProps {
  width: number
  height: number
}
interface SpeakerListProps {
  memberList: NEMember[]
  isLocalScreen: boolean
}

// 说话者列表
const SpeakerListWrap: React.FC<SpeakerListProps> = ({ isLocalScreen }) => {
  const { memberList } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { eventEmitter } = useContext<GlobalContextInterface>(GlobalContext)
  // 是否隐藏到屏幕侧边
  const [speakerList, setSpeakerList] = useState<Speaker[]>([])

  // 说话者列表Timer
  const audioVolumeIndicationTimer = useRef<
    null | number | ReturnType<typeof setTimeout>
  >(null)

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

    setSpeakerList((per) =>
      per.filter((item) => {
        return memberList.find((member) => member.uuid === item.uid)
          ?.isAudioConnected
      })
    )

    eventEmitter?.on(EventType.RtcAudioVolumeIndication, handle)
    return () => {
      eventEmitter?.off(EventType.RtcAudioVolumeIndication, handle)
    }
  }, [memberList, eventEmitter])

  return speakerList.length && !isLocalScreen ? (
    <SpeakerList
      className={`speaker-list-content speaker-list-show`}
      speakerList={speakerList}
    />
  ) : (
    <></>
  )
}

type ModalType = {
  destroy: () => void
  update: (props) => void
}

const childWindowMessageListenerMap = new Map<Window, unknown>()

const MeetingContent: React.FC<AppProps> = ({ height }) => {
  const { t } = useTranslation()

  const { dispatch, meetingInfo, memberList, inInvitingMemberList } =
    useMeetingInfoContext()
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
    showMeetingInfo,
    showLocalRecordingUI,
    globalConfig,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const {
    notificationApi,
    interpretationSetting,
    noChat,
    pluginNotifyDuration,
  } = useGlobalContext()
  const {
    messages: chatRoomMessages,
    addEventListenerAtChatWindow,
    clearMessages,
  } = useChatRoomContext()

  const [showLiveModel, setShowLiveModel] = useState(false)
  const showCloudRecordingUIRef = useRef<boolean>(true)
  const showLocalRecordingUIRef = useRef<boolean>(true)
  const becomeInterpreterRef = useRef<ModalType | null>(null)
  const { languageMap } = useDefaultLanguageOptions()
  const { firstLanguage, secondLanguage } = useMyLangList()
  const { handleRecord } = useCloudRecord()
  const { handleLocalRecord } = useLocalRecord()
  const { localMember } = meetingInfo

  useAudioHowling()

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])
  const interpretationSettingRef = useRef<
    NEMeetingInterpretationSettings | undefined
  >(interpretationSetting)

  const replayModalRef = useRef<{
    destroy: () => void
  }>()

  interpretationSettingRef.current = interpretationSetting

  useWatermark({
    container: document.getElementById('ne-web-meeting') as HTMLElement,
    disabled: isElectronSharingScreen,
  })

  useMeetingPlaySound()

  const { isFullScreen } = useFullscreen()
  const { startPreview, stopPreview } = usePreview()

  showCloudRecordingUIRef.current = showCloudRecordingUI !== false

  showLocalRecordingUIRef.current = showLocalRecordingUI !== false

  useSaveSetting(meetingInfo.meetingNum)

  useInterpreter()

  useWebLocalAudioVolume(localMember.isAudioOn)

  useElectronShortcutOperation()

  const {
    joinLoading,
    showReplayDialog,
    confirmToReplay,
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
  const [pluginOpen, setPluginOpen] = useState(false)
  const [chatRoomModalOpen, setChatRoomModalOpen] = useState(false)
  const [feedbackOpen, setFeedbackOpen] = useState(false)
  const [pluginMeetingId, setPluginMeetingId] = useState<number>()
  const [chatRoomMeetingId, setChatRoomId] = useState<number>()
  const [pluginInfo, setPluginInfo] = useState<NEMeetingWebAppItem>()
  const [settingModalTab, setSettingModalTab] =
    useState<SettingTabType>('normal')
  const [screenShareModalOpen, setScreenShareModalOpen] =
    useState<boolean>(false)
  const [shareLocalComputerSound, setShareLocalComputerSound] =
    useState<boolean>(false)
  const screenShareModalRef = useRef<ScreenShareModalRef>(null)
  const newMeetingWebRef = useRef<HTMLDivElement>(null)
  const myCanvasRef = useRef<HTMLDivElement>(null)
  const canShowInterpreterModalRef = useRef(true)
  const toastIdRef = useRef<string>('')
  const [isDarkMode, setIsDarkMode] = useState(true)
  const { onClickPlugin } = useMeetingPlugin()
  const meetingNotificationRef = useRef<MeetingNotificationRef>(null)
  const transcriptionMsgCountRef = useRef(0)

  useMeetingViewOrder()
  useScreenSharing()
  useWindowManage()
  const { createSecondMonitorRenderer, removeSecondMonitorRenderer } =
    useDualMonitors({ isDarkMode })

  const handUpCount = useMemo(() => {
    return memberList.filter((item) => item.isHandsUp).length
  }, [memberList])
  const [interMiniWindow, setInterMiniWindow] = useState(false)

  const showRecordTipModalRef = useRef<ConfirmModal | null>(null)
  const showLocalRecordTipModalRef = useRef<ConfirmModal | null>(null)
  const showTranscriptionTipModalRef = useRef<ConfirmModal | null>(null)
  const isFirstTimeOpenTranscription = useRef(true)
  const recordTipTimer = useRef<number | NodeJS.Timeout | null>(null)
  const localRecordTipTimer = useRef<number | NodeJS.Timeout | null>(null)

  usePreviewHandler()

  useEffect(() => {
    if (!window.isElectronNative) {
      myCanvasRef.current &&
        neMeeting?.rtcController?.setupLocalVideoCanvas(myCanvasRef.current)
    }
  }, [neMeeting?.rtcController])

  useUpdateEffect(() => {
    // 解决关闭非视图参数者入会开启视频入会，没有画布情况下video中设置无效问题
    if (meetingInfo.localMember.isInRtcChannel) {
      if (
        meetingInfoRef.current.isUnMutedVideo &&
        ((meetingInfoRef.current.unmuteVideoBySelfPermission &&
          !meetingInfoRef.current.videoAllOff) ||
          meetingInfoRef.current.hostUuid ===
            meetingInfoRef.current.localMember.uuid)
      ) {
        neMeeting?.unmuteLocalVideo()
        // 后续设置为false
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            isUnMutedVideo: false,
          },
        })
      }
    }
  }, [meetingInfo.localMember.isInRtcChannel])
  const isHostOrCoHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  useEffect(() => {
    if (!isHostOrCoHost) {
      closeWindow('liveWindow')
    }
  }, [isHostOrCoHost])

  const getIsOpenRightDrawerTab = (tab: string) => {
    return meetingInfo.rightDrawerTabs.some((item) => item.key === tab)
  }

  const handleOpenRightDrawerTabs = (activeTab: string) => {
    const rightDrawerTabs = meetingInfoRef.current.rightDrawerTabs

    const item = rightDrawerTabs.find((item) => item.key === activeTab)

    // 没有添加
    if (!item) {
      rightDrawerTabs.push({
        // label: t('memberListTitle'),
        key: activeTab,
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
          rightDrawerTabActiveKey: activeTab,
        },
      })
    }
  }

  const openTranscriptionWindow = () => {
    if (isElectronSharingScreen) {
      neMeeting?.eventEmitter.emit(MeetingEventType.openTranscriptionWindow)
    } else {
      handleOpenRightDrawerTabs('transcription')
    }
  }

  const asrTargetLanguage = useMemo(() => {
    return meetingInfo.setting.captionSetting?.targetLanguage
  }, [meetingInfo.setting.captionSetting?.targetLanguage])

  useUpdateEffect(() => {
    ;(asrTargetLanguage ||
      asrTargetLanguage === NERoomCaptionTranslationLanguage.NONE) &&
      neMeeting?.setCaptionTranslationLanguage(asrTargetLanguage)
  }, [asrTargetLanguage])

  useEffect(() => {
    neMeeting?.eventEmitter.on(
      MeetingEventType.transcriptionMsgCountChange,
      (count) => {
        transcriptionMsgCountRef.current = count
      }
    )
    return () => {
      neMeeting?.eventEmitter.off(MeetingEventType.transcriptionMsgCountChange)
    }
  }, [neMeeting])

  const handleTranscription = async () => {
    // 如果已经打开，则关闭
    if (getIsOpenRightDrawerTab('transcription')) {
      openTranscriptionWindow()
    } else {
      if (meetingInfo.isTranscriptionEnabled) {
        openTranscriptionWindow()
      } else {
        if (!isHostOrCoHost) {
          Toast.fail(t('transcriptionNotStarted'))
          return
        }

        if (showTranscriptionTipModalRef.current) {
          return
        }

        if (
          !isFirstTimeOpenTranscription.current &&
          transcriptionMsgCountRef.current === 0
        ) {
          await neMeeting?.liveTranscriptionController
            ?.enableTranscription(true)
            .catch((e) => {
              Toast.fail(e.msg || e.message || e.code)
            })
          openTranscriptionWindow()
          return
        }

        if (transcriptionMsgCountRef.current > 0) {
          openTranscriptionWindow()
          return
        }

        showTranscriptionTipModalRef.current = CommonModal.confirm({
          width: 370,
          title: t('commonTitle'),
          content: (
            <>
              <div className="start-record-tip">
                {t('transcriptionStartConfirmMsg')}
              </div>
            </>
          ),
          okText: t('globalStart'),
          cancelText: t('globalCancel'),
          afterClose() {
            showTranscriptionTipModalRef.current = null
          },
          onOk: async () => {
            showRecordTipModalRef.current?.destroy()
            showRecordTipModalRef.current = null
            await neMeeting?.liveTranscriptionController
              ?.enableTranscription(true)
              .then(() => {
                isFirstTimeOpenTranscription.current = false
                meetingInfoRef.current.isTranscriptionEnabled = true
                openTranscriptionWindow()
              })
              .catch((e) => {
                Toast.fail(e.msg || e.message || e.code)
              })
          },
          onCancel() {
            showTranscriptionTipModalRef.current?.destroy()
            showTranscriptionTipModalRef.current = null
          },
        })
      }
    }
  }

  const handleControlBarDefaultButtonClick = async (key: string) => {
    const autoShare =
      !!meetingInfoRef.current.setting.screenShareSetting
        ?.screenShareOptionInMeeting

    // 如果是全屏共享，则重置
    if (meetingInfo.rightDrawerTabActiveKey && isElectronSharingScreen) {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          rightDrawerTabActiveKey: '',
        },
      })
    }

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
                inSipInvitingMemberList: JSON.parse(
                  JSON.stringify(inInvitingMemberList)
                ),
              },
            },
          })
        } else {
          handleOpenRightDrawerTabs('memberList')
        }

        break
      case 'transcription':
        handleTranscription()
        break
      case 'feedback':
        openFeedback()
        break
      case 'chatroom':
        if (isElectronSharingScreen) {
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
                globalConfig: JSON.parse(JSON.stringify(globalConfig)),
                chatRoomMessages: JSON.parse(JSON.stringify(chatRoomMessages)),
              },
            },
          })

          addEventListenerAtChatWindow?.()
        } else {
          handleOpenRightDrawerTabs('chatroom')
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
          handleOpenRightDrawerTabs('notification')
        }

        break
      case 'invite':
        if (isElectronSharingScreen) {
          let payload = {
            meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
            globalConfig: undefined,
            memberList: undefined,
            inSipInvitingMemberList: undefined,
          }

          if (
            localMember.role == Role.host ||
            localMember.role == Role.coHost
          ) {
            payload = {
              meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
              globalConfig: JSON.parse(JSON.stringify(globalConfig)),
              memberList: JSON.parse(JSON.stringify(memberList)),
              inSipInvitingMemberList: JSON.parse(
                JSON.stringify(inInvitingMemberList)
              ),
            }
          }

          openMeetingWindow({
            name: 'inviteWindow',
            postMessageData: {
              event: 'updateData',
              payload: payload,
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
        if (window.isElectronNative) {
          const payload = {
            meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
            memberList: JSON.parse(JSON.stringify(memberList)),
            isOpen: true,
          }

          openMeetingWindow({
            name: 'liveWindow',
            postMessageData: {
              event: 'updateData',
              payload: payload,
            },
          })
        } else {
          setShowLiveModel(true)
        }

        break
      case 'cloudRecord':
        handleRecord()
        break
      case 'localRecord':
        handleLocalRecord()
        break
      case 'electronShareScreen':
        screenShareModalRef.current?.getShareList(autoShare)
        !autoShare && setScreenShareModalOpen(true)
        break
      case 'interpretation':
        handleInterpretation()
        break
      case 'caption':
        handleCaption()
        break
      default:
        break
    }
  }

  const defaultListeningVolume = useMemo(() => {
    const playouOutputtVolume =
      meetingInfo.setting.audioSetting.playouOutputtVolume

    if (playouOutputtVolume !== undefined) {
      return playouOutputtVolume
    } else {
      return 70
    }
  }, [meetingInfo.setting.audioSetting.playouOutputtVolume])

  const {
    openInterpretationWindow,
    setOpenInterpretationWindow,
    interFloatingWindow,
    setInterFloatingWindow,
    setOpenInterpretationSetting,
    openInterpretationSetting,
  } = useInterpreterModal({
    isHostOrCoHost: isHostOrCoHost,
    handleControlBarDefaultButtonClick,
    defaultListeningVolume,
  })

  const memberListRef = useRef(memberList)
  const inInvitingMemberListRef = useRef(inInvitingMemberList)
  const meetingInfoRef = useRef(meetingInfo)

  inInvitingMemberListRef.current = inInvitingMemberList
  meetingInfoRef.current = meetingInfo
  memberListRef.current = memberList

  useNotificationHandle({
    neMeeting,
    notificationApi,
    meetingNum: meetingInfo.meetingNum,
    isLocalSharingScreen: localMember.isSharingScreen,
  })

  const openRightDrawer = useMemo(() => {
    return meetingInfo.rightDrawerTabs.length > 0
  }, [meetingInfo.rightDrawerTabs])
  const { isAudioMode } = useIsAudioMode({
    memberList,
    meetingInfo,
  })

  const showLayout = useMemo(() => {
    if (isAudioMode) {
      return false
    }

    if (
      memberList.length === 1 &&
      (!inInvitingMemberList || inInvitingMemberList.length === 0)
    ) {
      return false
    }

    if (localMember.isSharingScreen) {
      return false
    }

    return true
  }, [
    memberList.length,
    meetingInfo.whiteboardUuid,
    localMember.isSharingScreen,
    isAudioMode,
    inInvitingMemberList,
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
    if (toastIdRef.current) {
      Toast.destroy(toastIdRef.current)
      toastIdRef.current = ''
    }

    if (showTimeTip && timeTipContent) {
      toastIdRef.current = Toast.info(timeTipContent, 0, true, () => {
        setShowTimeTip(false)
      })
    }
  }, [showTimeTip, timeTipContent, setShowTimeTip])

  useEffect(() => {
    eventEmitter?.on(EventType.OnStopMemberActivities, () => {
      if (isHostOrCoHost) {
        Toast.info(t('hostStopActivitiesTip'))
      } else {
        Toast.info(t('memberStopActivitiesTip'))
      }
    })
    return () => {
      eventEmitter?.off(EventType.OnStopMemberActivities)
    }
  }, [isHostOrCoHost])

  useEffect(() => {
    if (meetingInfo.screenUuid) {
      if (
        meetingInfoRef.current.setting.screenShareSetting?.sideBySideModeOpen &&
        meetingInfo.screenUuid !== localMember.uuid
      ) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            layout: LayoutTypeEnum.Speaker,
            speakerLayoutPlacement: 'right',
          },
        })
        return
      }

      if (meetingInfo.layout !== LayoutTypeEnum.Speaker) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            layout: LayoutTypeEnum.Speaker,
            speakerLayoutPlacement: 'top',
          },
        })
      }
    }
  }, [dispatch, meetingInfo.screenUuid])

  useEffect(() => {
    if (meetingInfo.whiteboardUuid) {
      if (
        meetingInfoRef.current.setting.screenShareSetting?.sideBySideModeOpen
      ) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            layout: LayoutTypeEnum.Speaker,
            speakerLayoutPlacement: 'right',
          },
        })
        return
      }

      if (meetingInfo.layout !== LayoutTypeEnum.Speaker) {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            layout: LayoutTypeEnum.Speaker,
            speakerLayoutPlacement: 'top',
          },
        })
      }
    }
  }, [dispatch, meetingInfo.whiteboardUuid])

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
  }, [isLocalScreen, isSpeaker, memberList.length, height])

  useEffect(() => {
    window.ipcRenderer?.send(IPCEvent.meetingStatus, {
      inMeeting: meetingInfo.meetingNum ? true : false,
    })
    if (!meetingInfo.meetingNum) {
      const excludes =
        meetingInfo.notificationMessages.length > 0
          ? ['notificationCardWindow']
          : []

      closeAllWindows(excludes)
      isFirstTimeOpenTranscription.current = true
      transcriptionMsgCountRef.current = 0
    }
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
      if (
        member.isVideoOn ||
        member.isAudioOn ||
        member.isSharingScreen ||
        member.isSharingSystemAudio
      ) {
        resultList.push({
          nickName: member.name,
          accountId: member.uuid,
          isVideoOn: member.isVideoOn,
          isSharingScreen: member.isSharingScreen,
          isAudioOn: member.isAudioOn,
          isSharingSystemAudio: member.isSharingSystemAudio,
        })
      }
    })
    return resultList
  }, [memberList])

  const showRecord = useMemo(() => {
    const cloudRecord = meetingInfo.cloudRecordState
    const isCloudRecord =
      (cloudRecord === RecordState.Recording ||
        cloudRecord === RecordState.Starting) &&
      showCloudRecordingUI

    return isCloudRecord
  }, [meetingInfo.cloudRecordState, showCloudRecordingUI])

  const showLocalRecord = useMemo(() => {
    const localRecord = meetingInfo.localRecordState
    const isLocalRecord =
      (localRecord === LocalRecordState.Recording ||
        localRecord === LocalRecordState.Starting) &&
      showLocalRecordingUI

    console.warn(
      '是否展示本地录制UI localRecord: ',
      localRecord,
      ',showLocalRecordingUI: ',
      showLocalRecordingUI,
      'isLocalRecord: ',
      isLocalRecord
    )

    const isOtherLocalRecording = memberListRef.current.find(
      (member) => member.isLocalRecording && member.uuid !== meetingInfo.myUuid
    )

    return isLocalRecord || isOtherLocalRecording
  }, [
    meetingInfo.isLocalRecording,
    meetingInfo.localRecordState,
    showLocalRecordingUI,
    memberList,
  ])

  // 打开popover
  function handlePopoverWindow(payload: {
    items: MenuProps['items']
    type: 'open' | 'update' | 'hide'
  }) {
    const { items, type } = payload

    if (type === 'open') {
      window.electronPopover.show(items)
    } else if (type === 'update') {
      window.electronPopover.update(items)
    } else {
      window.electronPopover.hide()
    }
  }

  // 打开会中窗口
  function openMeetingWindow(payload: {
    name: string
    url?: string
    postMessageData?: { event: string; payload: NEProps }
  }) {
    const newWindow = openWindow(payload.name, payload.url)
    const postMessage = () => {
      payload.postMessageData &&
        newWindow?.postMessage(payload.postMessageData, newWindow.origin)
    }

    windowLoadListener(newWindow)
    // 不是第一次打开
    if (newWindow?.firstOpen === false) {
      postMessage()
    } else {
      newWindow?.addEventListener('load', () => {
        postMessage()
      })
    }
  }

  async function onNotificationClickHandler(
    action: string,
    message: NECustomSessionMessage & {
      /** 是否已读 */
      unRead: boolean
      /** 是否已经弹出通知 */
      beNotified: boolean
      /** 是否在通知中心展示 */
      noShowInNotificationCenter: boolean
    }
  ) {
    if (!message || !window.isElectronNative) return
    const data = message.data?.data
    const type = data?.type

    if (type === 'MEETING.INVITE') {
      if (action === 'reject') {
        neMeeting?.rejectInvite(data.roomUuid)
        notificationApi?.destroy(data?.roomUuid)
      } else if (action === 'join') {
        const setting = getLocalStorageSetting()

        joinOtherMeeting(
          {
            meetingNum: data.meetingNum,
            video: setting?.normalSetting.openAudio ? 1 : 2,
            audio: setting?.normalSetting.openVideo ? 1 : 2,
          },
          (e) => {
            // 房间已结束
            if (e && e.code === 3101) {
              leaveMeeting()
            }

            if (!e) {
              eventEmitter?.emit(
                EventType.AcceptInviteJoinSuccess,
                localMember.name
              )
            }
          }
        )
      }
    }
  }

  function windowLoadListener(childWindow) {
    function messageListener(e) {
      const previewController = neMeeting?.previewController
      const previewContext = neMeeting?.roomService?.getPreviewRoomContext()
      const chatController = neMeeting?.chatController
      const rtcController = neMeeting?.rtcController
      const roomService = neMeeting?.roomService
      const nosService = neMeeting?.nosService

      const { event, payload } = e.data

      if (!event) {
        return
      }

      if (event === 'createSecondMonitorRenderer') {
        createSecondMonitorRenderer()
      } else if (event === 'removeSecondMonitorRenderer') {
        removeSecondMonitorRenderer()
      } else if (event === 'neMeeting' && neMeeting) {
        const { replyKey, fnKey, args } = payload
        const result = neMeeting[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'meetingInfoDispatch') {
        dispatch?.(payload)
      } else if (event === 'globalDispatch') {
        globalDispatch?.(payload)
      } else if (event === 'notificationClick') {
        console.log('notificationClick', payload)
        const { action, message } = payload

        if (action.startsWith('meeting://no_more_remind')) {
          const pluginId = message.data?.data?.pluginId

          pluginId &&
            meetingNotificationRef.current?.addNoMoreRemindPluginIds(pluginId)
        } else if (action.startsWith('meeting://open_plugin')) {
          onClickPlugin(action)
        } else {
          onNotificationClickHandler(action, message)
        }
      } else if (event === 'previewContext' && previewController) {
        const { replyKey, fnKey, args } = payload
        const result = previewContext?.[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'previewController' && previewController) {
        const { replyKey, fnKey, args } = payload

        if (fnKey === 'stopPreview') {
          stopPreview()
        } else if (fnKey === 'startPreview') {
          startPreview()
        }

        if (fnKey !== 'setupLocalVideoCanvas') {
          const result = previewController[fnKey]?.(...args)

          handlePostMessage(childWindow, result, replyKey)
        }
      } else if (event === 'chatController' && chatController) {
        const { replyKey, fnKey, args } = payload
        const result = chatController[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'roomService' && roomService) {
        const { replyKey, fnKey, args } = payload
        const result = roomService[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'rtcController' && rtcController) {
        const { replyKey, fnKey, args } = payload
        const result = rtcController[fnKey]?.(...args)

        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'nosService' && nosService) {
        const { replyKey, fnKey, args } = payload
        const result = nosService[fnKey]?.(...args)
        handlePostMessage(childWindow, result, replyKey)
      } else if (event === 'openWindow') {
        openMeetingWindow(payload)
      } else if (event === 'openControllerBarWindow') {
        handleControlBarDefaultButtonClick(payload)
      } else if (event == 'electronScreenSharevideoLayoutChange') {
        console.warn('Electron屏幕共享是，视频layout发生了变化: ', payload)
        eventEmitter?.emit('electronScreenSharevideoLayoutChange', payload)
      } else if (event === 'popover') {
        handlePopoverWindow(payload)
      } else if (event === 'AnnotationSavePhotoDone') {
        //收到批注下载完成，可以关闭屏幕共享了
        eventEmitter?.emit('AnnotationSavePhotoDone', payload)
      } else if (event === 'IsClearAnnotationAvailbleResult') {
        console.log('收到批注是否存在绘制内容的通知: ', payload)
        //收到批注是否存在绘制内容的通知
        eventEmitter?.emit('IsClearAnnotationAvailbleResult', payload)
      } else if (event === 'WhiteboardLeaveResult') {
        console.log('收到批注离开房间的通知: ', payload)
        eventEmitter?.emit('WhiteboardLeaveResult', payload)
      } else if (event === 'IsClearWhiteboardAvailbleResult') {
        eventEmitter?.emit('IsClearWhiteboardAvailbleResult', payload)
      } else if (event === 'WhiteboardSavePhotoDone') {
        eventEmitter?.emit('WhiteboardSavePhotoDone', payload)
      }
    }

    const childWindowMessageListener =
      childWindowMessageListenerMap.get(childWindow)

    if (childWindowMessageListener) {
      childWindow?.removeEventListener?.('message', childWindowMessageListener)
    }

    childWindowMessageListenerMap.set(childWindow, messageListener)

    childWindow?.addEventListener?.('message', messageListener)
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

  function handleNoPermission(type: 'audio' | 'video') {
    window.ipcRenderer?.send(IPCEvent.noPermission, type)
  }

  useUpdateEffect(() => {
    if (isHostOrCoHost) {
      const successMsg = meetingInfo.isLocked
        ? t('meetingLockMeetingByHost')
        : t('meetingUnLockMeetingByHost')

      Toast.success(successMsg)
    }
  }, [meetingInfo.isLocked])

  useUnmount(() => {
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        online: true,
      },
    })
    CommonModal.destroyAll()
    setOpenInterpretationWindow(false)
    closeWindow('interpreterWindow')
    closeWindow('interpreterSettingWindow')

    if (meetingInfoRef.current.isTranscriptionEnabled) {
      neMeeting?.liveTranscriptionController?.enableTranscription(false)
    }

    if (meetingInfoRef.current.interpretation?.started) {
      const interpretation = meetingInfoRef.current.interpretation
      const listenLanguage = interpretationSettingRef.current?.listenLanguage

      if (meetingInfoRef.current?.isInterpreter && !window.isElectronNative) {
        // 离开对应rtc频道
        const langs =
          interpretation.interpreters[meetingInfoRef.current.localMember.uuid]

        const channelList = langs?.map((lang) => {
          return interpretation?.channelNames[lang] || ''
        })

        channelList?.forEach((channel) => {
          channel && neMeeting?.leaveRtcChannel(channel)
        })
        if (
          listenLanguage &&
          listenLanguage !== MAJOR_AUDIO &&
          !langs?.includes(listenLanguage)
        ) {
          const channel =
            meetingInfoRef.current.interpretation?.channelNames[listenLanguage]

          channel && neMeeting?.leaveRtcChannel(channel)
        }
      } else {
        if (listenLanguage && listenLanguage !== MAJOR_AUDIO) {
          const channel =
            meetingInfoRef.current.interpretation?.channelNames[listenLanguage]

          channel && neMeeting?.leaveRtcChannel(channel)
        }
      }

      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          interpretation: {
            ...meetingInfoRef.current.interpretation,
            started: false,
          },
        },
      })
    }
  })

  useEffect(() => {
    if (!meetingInfo.meetingNum) {
      setSettingOpen(false)
    }
  }, [meetingInfo.meetingNum])

  useEffect(() => {
    const _setting = getLocalStorageSetting()

    if (_setting) {
      localStorage.setItem(
        'ne-meeting-pre-meeting-setting',
        JSON.stringify(_setting)
      )

      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          setting: _setting,
        },
      })
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
        if (meetingInfoRef.current.isOtherCloudRecordingStartConfirmed) {
          return
        } else {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isOtherCloudRecordingStartConfirmed: true,
            },
          })
        }

        showRecordTipModalRef.current = CommonModal.confirm({
          width: 370,
          title: t('beingMeetingRecorded'),
          key: 'showRecordTipModal',
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
            showRecordTipModalRef.current?.destroy()
            showRecordTipModalRef.current = null
          },
          onCancel: async () => {
            showRecordTipModalRef.current?.destroy()
            showRecordTipModalRef.current = null
            eventEmitter?.emit(MeetingEventType.leaveOrEndRoom)
          },
        })
      } else {
        let remainTime = 3

        if (meetingInfoRef.current.isOtherCloudRecordingStopConfirmed) {
          return
        } else {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isOtherCloudRecordingStopConfirmed: true,
            },
          })
        }

        showRecordTipModalRef.current = CommonModal.confirm({
          width: 300,
          title: t('cloudRecordingHasEnded'),
          closeIcon: null,
          content: (
            <>
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
    // 收到本地录制弹框提醒确认
    eventEmitter?.on(
      MeetingEventType.needShowLocalRecordTip,
      (isLocalRecording) => {
        // 如果不显示ui则不弹窗提醒
        if (!showLocalRecordingUIRef.current) {
          return
        }

        if (meetingInfoRef.current.isOtherLocalRecordingConfirmed) {
          return
        } else {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isOtherLocalRecordingConfirmed: true,
            },
          })
        }

        if (showLocalRecordTipModalRef.current) {
          return
        }

        if (isLocalRecording) {
          localRecordTipTimer.current &&
            clearInterval(localRecordTipTimer.current)
          showLocalRecordTipModalRef.current = CommonModal.confirm({
            width: 370,
            title: t('beingMeetingRecorded'),
            key: 'showLocalRecordTipModal',
            content: (
              <>
                <div className="start-record-tip">
                  {t('startLocalRecordTipByMember')}
                </div>
                <div className="agree-in-record">
                  {t('agreeInRecordMeeting')}
                </div>
              </>
            ),
            okText: t('gotIt'),
            cancelText: t('meetingLeaveFull'),
            onOk() {
              showLocalRecordTipModalRef.current?.destroy()
              showLocalRecordTipModalRef.current = null
            },
            onCancel: async () => {
              showLocalRecordTipModalRef.current?.destroy()
              showLocalRecordTipModalRef.current = null
              eventEmitter?.emit(MeetingEventType.leaveOrEndRoom)
            },
          })
        }
      }
    )
    eventEmitter?.on(MeetingEventType.noMicPermission, () => {
      const modal = CommonModal.confirm({
        closable: true,
        title: t('microphonePermission'),
        wrapClassName: 'nemeeting-mic-permission-modal',
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
                  handleNoPermission('audio')
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
      const modal = CommonModal.confirm({
        closable: true,
        title: t('cameraPermission'),
        wrapClassName: 'nemeeting-camera-permission-modal',
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
                  handleNoPermission('video')
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
    eventEmitter?.on(EventType.AcceptInvite, joinOtherMeeting)
    window.ipcRenderer?.on(IPCEvent.changeSetting, (event, setting) => {
      onSettingChange(setting)
    })
    // 设置页面切换音频或者视频设备 setting: {type: 'video'|'audio', deviceId: string, deviceName?: string}
    window.ipcRenderer?.on(IPCEvent.changeSettingDevice, (event, setting) => {
      onDeviceChange(setting.type, setting.deviceId, setting.deviceName)
    })

    window.ipcRenderer?.invoke(IPCEvent.getThemeColor).then((isDark) => {
      setIsDarkMode(isDark)
    })
    window.ipcRenderer?.on(IPCEvent.setThemeColor, (_, isDark) => {
      setIsDarkMode(isDark)
    })
    window.ipcRenderer?.on(IPCEvent.openMeetingAbout, () => {
      openMeetingWindow({ name: 'aboutWindow' })
    })
    window.ipcRenderer?.on(IPCEvent.alreadyInMeeting, () => {
      message.info(t('alreadyInMeeting'))
    })

    return () => {
      eventEmitter?.off(MeetingEventType.needShowRecordTip)
      eventEmitter?.off(MeetingEventType.needShowLocalRecordTip)
      eventEmitter?.off(MeetingEventType.noCameraPermission)
      eventEmitter?.off(MeetingEventType.noMicPermission)
      eventEmitter?.off(EventType.MeetingExits)
      eventEmitter?.off(EventType.AcceptInvite, joinOtherMeeting)
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
      joinOption: meetingInfoRef.current.joinOption,
    })
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingRejoinMeeting: false,
      },
    })
  }

  const joinOtherMeeting = useCallback(
    async (
      options: CreateOptions | { meetingNum: string },
      callback?: (e?) => void
    ) => {
      // 需要先离开当前会议
      globalDispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          waitingJoinOtherMeeting: true,
          joinLoading: true,
        },
      })
      // 在会中
      if (meetingInfoRef.current?.meetingNum) {
        // 如果是已在邀请的会议则不处理
        if (options.meetingNum === meetingInfoRef.current.meetingNum) {
          return
        }

        if (meetingInfoRef.current?.localMember.isSharingScreen) {
          try {
            await neMeeting?.muteLocalScreenShare()
          } catch (error) {
            console.warn('muteLocalScreenShare', error)
          }
        }

        // 加入新的会议
        setTimeout(async () => {
          notificationApi?.destroy()
          try {
            await neMeeting?.leave()
          } catch (e: unknown) {
            console.error('leave meeting error', e)
          }

          CommonModal.destroyAll()
          globalDispatch?.({
            type: ActionType.JOIN_LOADING,
            data: false,
          })
          dispatch?.({
            type: ActionType.RESET_MEMBER,
            data: null,
          })
          dispatch &&
            dispatch({
              type: ActionType.RESET_MEETING,
              data: null,
            })
          eventEmitter?.emit(UserEventType.JoinOtherMeeting, options, callback)
          // 延迟，防止 waitingJoinOtherMeeting 状态未更新
        }, 300)
      } else {
        eventEmitter?.emit(UserEventType.JoinOtherMeeting, options, callback)
      }
    },

    [dispatch, globalDispatch, eventEmitter, neMeeting, notificationApi]
  )

  useUpdateEffect(() => {
    if (waitingRejoinMeeting) {
      if (isElectronSharingScreen) {
        dispatch?.({
          type: ActionType.UPDATE_MEMBER,
          data: {
            uuid: localMember.uuid,
            member: { isSharingScreen: false },
          },
        })
      }

      CommonModal.confirm({
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

  useUpdateEffect(() => {
    if (!meetingInfo.meetingNum) {
      return
    }

    if (isShowAudioDialog) {
      if (!localMember.isAudioOn) {
        const modal = CommonModal.confirm({
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

        const handleRooms = ({ commandId }) => {
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

  useUpdateEffect(() => {
    if (!meetingInfo.meetingNum) {
      return
    }

    if (isShowVideoDialog) {
      if (!localMember.isVideoOn) {
        const modal = CommonModal.confirm({
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

        const handleRooms = ({ commandId }) => {
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

  useEffect(() => {
    const resolution = meetingInfo.setting?.videoSetting.resolution

    if (resolution) {
      neMeeting?.setVideoProfile(resolution as VideoResolution)
    }
  }, [meetingInfo.setting?.videoSetting.resolution, neMeeting])

  useEffect(() => {
    const audioSetting = meetingInfo.setting?.audioSetting

    if (!audioSetting || !window?.isElectronNative) {
      return
    }

    console.log('会中 开始处理高级音频设置 audioSetting', audioSetting)
    try {
      if (audioSetting.enableAudioAI) {
        neMeeting?.enableAudioAINS(true)
      } else {
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
    meetingInfo.setting?.audioSetting?.enableAudioAI,
    meetingInfo.setting?.audioSetting?.enableMusicMode,
    meetingInfo.setting?.audioSetting?.enableAudioEchoCancellation,
    meetingInfo.setting?.audioSetting?.enableAudioStereo,
    neMeeting,
  ])

  useEffect(() => {
    const audioSetting = meetingInfo.setting?.audioSetting

    if (!audioSetting || !window?.isElectronNative) {
      return
    }

    try {
      neMeeting?.enableAudioVolumeAutoAdjust(
        audioSetting.enableAudioVolumeAutoAdjust
      )
    } catch (e) {
      console.log('会中 设置是否自动调节麦克风音量error', e)
    }
  }, [meetingInfo.setting?.audioSetting.enableAudioVolumeAutoAdjust, neMeeting])

  // 设置扬声器输出音量变更
  useEffect(() => {
    const playouOutputtVolume =
      meetingInfo.setting?.audioSetting.playouOutputtVolume

    if (playouOutputtVolume || playouOutputtVolume === 0) {
      try {
        neMeeting?.rtcController?.adjustPlaybackSignalVolume(
          playouOutputtVolume
        )
      } catch (e) {
        console.log('adjustPlaybackSignalVolume error', e)
      }
    }
  }, [
    meetingInfo.setting?.audioSetting.playouOutputtVolume,
    neMeeting?.rtcController,
  ])

  // 设置麦克风采集音量变更
  useEffect(() => {
    const recordOutputVolume =
      meetingInfo.setting?.audioSetting.recordOutputVolume

    if (recordOutputVolume || recordOutputVolume === 0) {
      if (window.isElectronNative) {
        neMeeting?.previewController?.setRecordDeviceVolume?.(
          recordOutputVolume
        )
      } else {
        try {
          neMeeting?.rtcController?.adjustRecordingSignalVolume(
            recordOutputVolume
          )
        } catch (e) {
          console.log('adjustRecordingSignalVolume error', e)
        }
      }
    }
  }, [
    meetingInfo.setting?.audioSetting.recordOutputVolume,
    neMeeting?.previewController,
    neMeeting?.rtcController,
  ])

  const onSettingChange = useCallback(
    (setting: MeetingSetting) => {
      setLocalStorageSetting(JSON.stringify(setting))
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          setting,
        },
      })
      // 强制缓存
      window.ipcRenderer?.send(IPCEvent.flushStorageData, true)
    },
    [dispatch]
  )

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
    setTimeout(() => {
      eventEmitter?.emit(EventType.RoomEnded, 'LEAVE_BY_SELF')
    }, 100)
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
      } catch (e) {
        console.log('getDeviceIdFromWebDeviceName error', e)
      }
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

  function onSettingClick(type: SettingTabType, subType?: string) {
    if (window.ipcRenderer) {
      openMeetingWindow({
        name: 'settingWindow',
        postMessageData: {
          event: 'updateData',
          payload: {
            type,
            subType,
            setting: meetingInfoRef.current.setting,
            inMeeting: meetingInfoRef.current.meetingNum ? true : false,
            globalConfig: JSON.parse(JSON.stringify(globalConfig)),
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
    const setting = { ...meetingInfoRef.current.setting } as
      | MeetingSetting
      | undefined

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
      onSettingChange(setting)
    }
  }

  const startShareInEle = async (shareItem, preferMotion) => {
    if (!meetingInfoRef.current.screenSharePermission && !isHostOrCoHost) {
      Toast.fail(t('shareNoPermission'))
      return
    }

    let videoProfile: string | undefined
    let limitFrameRate: VideoFrameRate = 30

    if (preferMotion) {
      videoProfile = 'HD720P'
      limitFrameRate = 30
    }

    console.log('startShareInEle', preferMotion)

    if (
      meetingInfoRef.current.setting.screenShareSetting
        ?.sharedLimitFrameRateEnable &&
      meetingInfoRef.current.setting.screenShareSetting?.sharedLimitFrameRate
    ) {
      limitFrameRate = meetingInfoRef.current.setting.screenShareSetting
        .sharedLimitFrameRate as VideoFrameRate
    }

    setScreenShareModalOpen(false)
    // 关闭侧边栏
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        rightDrawerTabs: [],
        rightDrawerTabActiveKey: '',
      },
    })
    window.ipcRenderer?.send(IPCEvent.quiteFullscreen)
    try {
      if (meetingInfoRef.current.localMember.isSharingSystemAudio) {
        await neMeeting?.stopShareSystemAudio()
      }
    } catch {
      //
    }

    try {
      await neMeeting?.unmuteLocalScreenShare({
        sourceId: shareItem?.id || shareItem?.displayId,
        isApp: shareItem?.isApp,
        videoProfile,
        limitFrameRate,
        preferMotion,
      })
    } catch (e: unknown) {
      const error = e as NECommonError

      if (error && error.code === 1012) {
        Toast.fail(t('functionalityLimitedByTheNumberOfPeople'))
      }

      if (error && error.code === 1024) {
        Toast.fail(t('screenShareNoPermission'))
      }

      console.warn('startShareInEle error', e)
    } finally {
      setScreenShareModalOpen(false)
    }
  }

  const startShareSystemAudio = async () => {
    if (window?.systemPlatform === 'darwin') {
      neMeeting?.previewController?.installAudioCaptureDriver?.()
    }

    await neMeeting?.startShareSystemAudio()
    setScreenShareModalOpen(false)
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
          meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
          globalConfig: JSON.parse(JSON.stringify(globalConfig)),
          noChat: noChat,
        },
      },
    })
    openMeetingWindow({
      name: 'annotationWindow',
      postMessageData: {
        event: 'windowOpen',
        payload: {
          meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
        },
      },
    })

    if (
      !meetingInfoRef.current.setting.normalSetting.chatMessageNotificationType
    ) {
      openMeetingWindow({
        name: 'bulletScreenMessageWindow',
        postMessageData: {
          event: 'updateData',
          payload: {
            memberList: JSON.parse(JSON.stringify(memberList)),
            meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
            waitingRoomInfo: JSON.parse(JSON.stringify(waitingRoomInfo)),
            waitingRoomMemberList: JSON.parse(
              JSON.stringify(waitingRoomMemberList)
            ),
            globalConfig: JSON.parse(JSON.stringify(globalConfig)),
            chatRoomMessages: JSON.parse(JSON.stringify(chatRoomMessages)),
          },
        },
      })

      addEventListenerAtChatWindow?.()
    }
  }

  const onNotificationCardWinOpen = (message) => {
    const type = message?.data?.data?.type

    // 配置会中插件通知弹窗持续时间，单位毫秒(ms)，默认5000ms；value=0时，不显示通知弹窗；
    if (type === 'PLUGIN.CUSTOM' && pluginNotifyDuration === 0) {
      return
    }

    openMeetingWindow({
      name: 'notificationCardWindow',
      postMessageData: {
        event: 'updateNotifyCard',
        payload: {
          message,
          pluginNotifyDuration,
        },
      },
    })
  }

  const defaultMajorVolume = useMemo(() => {
    return MAJOR_DEFAULT_VOLUME
  }, [])

  const handleCaption = () => {
    neMeeting?.eventEmitter.emit(MeetingEventType.openCaption)
  }

  const handleInterpretation = () => {
    const role = meetingInfoRef.current?.localMember.role

    // 如果是主持人打开设置页面
    if (role === Role.host || role === Role.coHost) {
      if (window.isElectronNative) {
        let interpretation = meetingInfoRef.current.interpretation

        interpretation = interpretation
          ? JSON.parse(JSON.stringify(interpretation))
          : undefined
        openMeetingWindow({
          name: 'interpreterSettingWindow',
          postMessageData: {
            event: 'updateData',
            payload: {
              interpretation,
              inMeeting: true,
              isOpen: true,
              globalConfig: JSON.parse(JSON.stringify(globalConfig)),
              memberList: JSON.parse(JSON.stringify(memberListRef.current)),
              inInvitingMemberList: inInvitingMemberListRef.current
                ? JSON.parse(JSON.stringify(inInvitingMemberListRef.current))
                : undefined,
              meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
            },
          },
        })
      } else {
        setOpenInterpretationSetting(true)
      }
    } else {
      if (window.isElectronNative) {
        openMeetingWindow({
          name: 'interpreterWindow',
          postMessageData: {
            event: 'updateData',
            payload: {
              defaultMajorVolume,
              defaultListeningVolume,
              memberList: JSON.parse(JSON.stringify(memberListRef.current)),
              inInvitingMemberList: inInvitingMemberListRef.current
                ? JSON.parse(JSON.stringify(inInvitingMemberListRef.current))
                : undefined,
              meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
              interpretationSetting: interpretationSettingRef.current
                ? JSON.parse(JSON.stringify(interpretationSettingRef.current))
                : undefined,
            },
          },
        })
      } else {
        setOpenInterpretationWindow(true)
        setInterFloatingWindow(false)
      }
    }
  }

  useEffect(() => {
    if (meetingInfo.interpretation?.started && window.isElectronNative) {
      const interpreterWindow = getWindow('interpreterWindow')

      interpreterWindow?.postMessage(
        {
          event: 'updateData',
          payload: {
            meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
            inMeeting: true,
            interpretationSetting: JSON.parse(
              JSON.stringify(interpretationSetting)
            ),
            defaultMajorVolume,
            defaultListeningVolume,
          },
        },
        interpreterWindow.origin
      )
    }
  }, [
    meetingInfo,
    meetingInfo.localMember.role,
    interpretationSetting,
    defaultMajorVolume,
    defaultListeningVolume,
  ])

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
      closeWindow('liveWindow')
      setScreenShareModalOpen(false)
      if (!waitingRejoinMeeting) {
        CommonModal.destroyAll()
      }
    }
  }, [meetingInfo.meetingNum, waitingRejoinMeeting])

  useEffect(() => {
    if (!isHostOrCoHost) {
      if (window.isElectronNative) {
        setOpenInterpretationSetting(false)
        closeWindow('interpreterSettingWindow')
      } else {
        setOpenInterpretationSetting(false)
      }
    }
  }, [isHostOrCoHost, setOpenInterpretationSetting])

  useEffect(() => {
    if (!meetingInfo.interpretation?.started) {
      setInterMiniWindow(false)
      setInterFloatingWindow(false)
    }
  }, [meetingInfo.interpretation?.started, setInterFloatingWindow])

  useEffect(() => {
    // 如果成为译员弹窗提醒
    if (
      meetingInfo.isInterpreter &&
      meetingInfo.interpretation?.started &&
      !meetingInfoRef.current.openInterpretationBySelf
    ) {
      becomeInterpreterRef.current && becomeInterpreterRef.current.destroy()
      canShowInterpreterModalRef.current = false
      becomeInterpreterRef.current = CommonModal.confirm({
        width: 400,
        keyboard: false,
        title: t('interpAssignInterpreter'),
        className: 'nemeeting-interp-tip-modal',
        footer: null,
        content: (
          <div>
            <div className="nemeeting-interp-modal-lang">
              {t('interpAssignLanguage')}
            </div>
            <div className="nemeeting-interp-modal-content">
              <div className="ne-preview-interp-item nemeeting-ellipsis">
                <div className="nemeeting-ellipsis">
                  {languageMap[firstLanguage] || firstLanguage}
                </div>
              </div>
              <svg
                className="icon iconfont ne-interpreter-switch"
                aria-hidden="true"
                style={{ margin: '0 12px', color: '#999999' }}
              >
                <use xlinkHref="#iconqiehuan"></use>
              </svg>
              <div className="ne-preview-interp-item nemeeting-ellipsis">
                <div className="nemeeting-ellipsis">
                  {languageMap[secondLanguage] || secondLanguage}
                </div>
              </div>
            </div>
            <div className="nemeeting-interp-modal-tip">
              {t('interpSettingTip')}
            </div>
            <div className="nemeeting-interp-modal-footer">
              <Button
                type="primary"
                onClick={() => {
                  becomeInterpreterRef.current?.destroy()
                  becomeInterpreterRef.current = null
                }}
              >
                {t('sure')}
              </Button>
            </div>
          </div>
        ),
      })
    } else {
      becomeInterpreterRef.current && becomeInterpreterRef.current.destroy()
      becomeInterpreterRef.current = null
      canShowInterpreterModalRef.current = true
    }
  }, [
    meetingInfo.isInterpreter,
    t,
    firstLanguage,
    secondLanguage,
    languageMap,
    meetingInfo.interpretation?.started,
  ])

  useEffect(() => {
    function setExcludeWindowList(_, data) {
      neMeeting?.rtcController?.setExcludeWindowList(...data)
    }

    if (isElectronSharingScreen) {
      closeWindow('settingWindow')

      window.ipcRenderer?.on(
        IPCEvent.setExcludeWindowList,
        setExcludeWindowList
      )
      console.warn('打开屏幕共享小窗口')
      openShareVideoWindow()
      return () => {
        window.ipcRenderer?.off(
          IPCEvent.setExcludeWindowList,
          setExcludeWindowList
        )
        closeAllWindows(['interpreterWindow', 'interpreterSettingWindow'])
      }
    }
  }, [isElectronSharingScreen])

  useEffect(() => {
    if (meetingInfo.screenUuid === localMember.uuid) {
      getActiveWindows().forEach((activeWindow) => {
        activeWindow.postMessage(
          {
            event: 'updateData',
            payload: {
              inMeeting: meetingInfoRef.current.meetingNum ? true : false,
              globalConfig: globalConfig
                ? JSON.parse(JSON.stringify(globalConfig))
                : globalConfig,
              noChat,
              memberList: JSON.parse(JSON.stringify(memberList)),
              meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
              interpretationSetting: interpretationSetting
                ? JSON.parse(JSON.stringify(interpretationSetting))
                : undefined,
              waitingRoomInfo: JSON.parse(JSON.stringify(waitingRoomInfo)),
              waitingRoomMemberList: JSON.parse(
                JSON.stringify(waitingRoomMemberList)
              ),
              inSipInvitingMemberList: inInvitingMemberList
                ? JSON.parse(JSON.stringify(inInvitingMemberList))
                : [],
            },
          },
          activeWindow.origin
        )
      })
    }
  }, [
    memberList,
    meetingInfo,
    waitingRoomInfo,
    globalConfig,
    noChat,
    waitingRoomMemberList,
    inInvitingMemberList,
    interpretationSetting,
    localMember.uuid,
  ])

  useEffect(() => {
    if (!isElectronSharingScreen) {
      const interpreterWindow = getWindow('interpreterWindow')
      const interpreterSettingWindow = getWindow('interpreterSettingWindow')
      const liveWindow = getWindow('liveWindow')
      const postData = {
        event: 'updateData',
        payload: {
          globalConfig,
          inMeeting: true,
          meetingInfo: JSON.parse(JSON.stringify(meetingInfo)),
          memberList: JSON.parse(JSON.stringify(memberList)),
          interpretationSetting: undefined,
        },
      }

      liveWindow?.postMessage(postData, liveWindow.origin)

      if (interpreterSettingWindow || interpreterWindow) {
        postData.payload.interpretationSetting = interpretationSetting
          ? JSON.parse(JSON.stringify(interpretationSetting))
          : undefined
        postData.payload.globalConfig = globalConfig
          ? JSON.parse(JSON.stringify(globalConfig))
          : globalConfig
      }

      interpreterWindow?.postMessage(postData, interpreterWindow.origin)
      interpreterSettingWindow?.postMessage(
        postData,
        interpreterSettingWindow.origin
      )
    }
  }, [
    globalConfig,
    interpretationSetting,
    meetingInfo,
    memberList,
    isElectronSharingScreen,
  ])

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
            neMeeting?.previewController?.getPlayoutDeviceVolume?.()

          neMeeting?.previewController?.setPlayoutDeviceVolume?.(0)
          neMeeting?.previewController?.setPlayoutDeviceMute?.(true)
          return () => {
            if (speakerVolume) {
              neMeeting?.previewController?.setPlayoutDeviceMute?.(false)
              neMeeting?.previewController?.setPlayoutDeviceVolume?.(
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

  useUpdateEffect(() => {
    if (!meetingInfo.meetingNum) {
      return
    }

    if (window.isElectronNative) {
      if (meetingInfo.interpretation?.started) {
        if (meetingInfo.isInterpreter || isHostOrCoHost) {
          const payloadData = {
            event: 'updateData',
            payload: {
              defaultMajorVolume,
              defaultListeningVolume,
              inMeeting: true,
              meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
              memberList: JSON.parse(JSON.stringify(memberListRef.current)),
              inInvitingMemberList: inInvitingMemberListRef.current
                ? JSON.parse(JSON.stringify(inInvitingMemberListRef.current))
                : undefined,
              interpretationSetting: JSON.parse(
                JSON.stringify(interpretationSetting)
              ),
            },
          }
          if (meetingInfo.isInterpreter) {
            if (interpretationSetting?.speakerLanguage) {
              openMeetingWindow({
                name: 'interpreterWindow',
                postMessageData: payloadData,
              })
            }
          } else {
            openMeetingWindow({
              name: 'interpreterWindow',
              postMessageData: payloadData,
            })
          }
        }
      } else {
        closeWindow('interpreterWindow')
      }
    } else {
      if (meetingInfo.interpretation?.started) {
        if (meetingInfo.isInterpreter || isHostOrCoHost) {
          setOpenInterpretationWindow(true)
        }
      } else {
        setOpenInterpretationWindow(false)
      }
    }

    if (!meetingInfo.interpretation?.started) {
      neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume(
        '',
        meetingInfoRef.current.setting.audioSetting.playouOutputtVolume || 70
      )
      setInterFloatingWindow(false)
    }
  }, [
    meetingInfo.meetingNum,
    meetingInfo.interpretation?.started,
    interpretationSetting,
    meetingInfo.isInterpreter,
    isHostOrCoHost,
    defaultMajorVolume,
    defaultListeningVolume,
    neMeeting,
    globalDispatch,
  ])

  useEffect(() => {
    if (!meetingInfo.interpretation?.started) {
      globalDispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          interpretationSetting: {
            listenLanguage: MAJOR_AUDIO,
          },
        },
      })
    }
  }, [meetingInfo.interpretation?.started])

  // 非主持人或者译员不主动显示浮窗
  useUpdateEffect(() => {
    if (!isHostOrCoHost && !meetingInfo.isInterpreter) {
      if (window.isElectronNative) {
        closeWindow('interpreterWindow')
      } else {
        setOpenInterpretationWindow(false)
      }
    }
  }, [isHostOrCoHost, meetingInfo.isInterpreter, setOpenInterpretationWindow])
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

  const topBarVisible = useMemo(() => {
    if (isShowControlBar !== false) {
      return true
    }

    return controlBarVisible
  }, [controlBarVisible, isShowControlBar])

  const meetingWebStyle = useMemo(() => {
    let top = !isFullScreen && window.isElectronNative ? 28 : 0

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
    isFullScreen,
  ])

  useUpdateEffect(() => {
    const activeKey = meetingInfo.rightDrawerTabActiveKey
    const isLastTab =
      meetingInfo.rightDrawerTabs.length === 1 &&
      meetingInfo.rightDrawerTabs[0].key === activeKey

    if (isLastTab) {
      return
    }

    if (
      activeKey === 'memberList' &&
      meetingInfo.activeMemberManageTab === 'invite' &&
      inInvitingMemberList?.length === 0
    ) {
      return
    }

    if (activeKey === 'chatroom') {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          unReadChatroomMsgCount: 0,
        },
      })
    }

    activeKey && handleControlBarDefaultButtonClick(activeKey)
  }, [meetingInfo.rightDrawerTabActiveKey])

  useUpdateEffect(() => {
    const activeKey = meetingInfo.rightDrawerTabActiveKey
    const rightDrawerTabs = meetingInfo.rightDrawerTabs

    if (
      activeKey === 'memberList' &&
      (isElectronSharingScreen || rightDrawerTabs.length === 0)
    ) {
      handleControlBarDefaultButtonClick(activeKey)
    }
  }, [inInvitingMemberList])

  // 通知组件是否正在共享屏幕
  useEffect(() => {
    const isSharingScreen = meetingInfo.screenUuid === localMember.uuid

    outEventEmitter?.emit(
      UserEventType.OnScreenSharingStatusChange,
      isSharingScreen
    )
  }, [meetingInfo.screenUuid, localMember.uuid, outEventEmitter])

  const handleCloseInterpretationWindow = () => {
    // 译员或者主持人点击关闭变成浮窗
    if (meetingInfo.isInterpreter || isHostOrCoHost) {
      setInterFloatingWindow(true)
    } else {
      setOpenInterpretationWindow(false)
    }
  }

  const onShareSoundChanged = (flag: boolean) => {
    if (
      meetingInfo.isInterpreter &&
      flag &&
      meetingInfo.interpretation?.started
    ) {
      Toast.info(t('interpAudioShareIsForbiddenDesktop'))
      setShareLocalComputerSound(false)
      return
    }

    setShareLocalComputerSound(flag)
  }

  const openFeedback = () => {
    if (window.isElectronNative) {
      openMeetingWindow({
        name: 'feedbackWindow',
        postMessageData: {
          event: 'updateData',
          payload: {
            meetingInfo: meetingInfoRef.current
              ? JSON.parse(JSON.stringify(meetingInfoRef.current))
              : meetingInfoRef.current,
          },
        },
      })
    } else {
      setFeedbackOpen(true)
    }
  }

  useEffect(() => {
    if (showReplayDialog && !replayModalRef.current) {
      replayModalRef.current = Modal.info({
        title: t('commonTitle'),
        keyboard: false,
        centered: true,
        content: <div>{t('readyPlayOthersAudioAndVideo')}</div>,
        afterClose() {
          replayModalRef.current = undefined
        },
        okText: t('globalSure'),
        onOk() {
          replayModalRef.current?.destroy()
          confirmToReplay('audio')
        },
      })
    }
  }, [showReplayDialog])

  useEffect(() => {
    if (meetingInfo.isInterpreter) {
      setShareLocalComputerSound(false)
      // 如果是web直接关闭音频共享
      if (
        meetingInfoRef.current.localMember.isSharingScreen &&
        !window.isElectronNative
      ) {
        neMeeting?.rtcController?.disableLocalSubStreamAudio()
      }
    } else {
      if (
        meetingInfoRef.current.localMember.isSharingScreen &&
        !window.isElectronNative
      ) {
        neMeeting?.rtcController?.enableLocalSubStreamAudio()
      }
    }
  }, [meetingInfo.isInterpreter])

  useMount(() => {
    outEventEmitter?.on(UserEventType.OpenSettingsWindow, (type, subType) => {
      onSettingClick(type, subType)
    })
    outEventEmitter?.on(UserEventType.OpenFeedbackWindow, () => {
      openFeedback()
    })
    outEventEmitter?.on(UserEventType.OpenChatWindow, (meetingId: number) => {
      clearMessages?.()
      if (window.isElectronNative) {
        openMeetingWindow({
          name: 'chatWindow',
          postMessageData: {
            event: 'updateData',
            payload: {
              meetingId,
              meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
            },
          },
        })
      } else {
        setChatRoomId(meetingId)
        setChatRoomModalOpen(true)
      }
    })
    outEventEmitter?.on(
      UserEventType.OpenPluginWindow,
      (meetingId: number, item: NEMeetingWebAppItem) => {
        console.log('OpenPluginWindow', meetingId, item)
        if (window.ipcRenderer) {
          openMeetingWindow({
            name: item.pluginId,
            url:
              '#/plugin?' +
              objectToQueryString({
                pluginId: item.pluginId,
              }),
            postMessageData: {
              event: 'updateData',
              payload: {
                pluginId: item.pluginId,
                title: item.name,
                url: item.homeUrl,
                roomArchiveId: meetingId,
                isInMeeting: meetingInfoRef.current.meetingNum ? true : false,
              },
            },
          })
        } else {
          setPluginOpen(true)
          setPluginMeetingId(meetingId)
          setPluginInfo(item)
        }
      }
    )
  })

  useEffect(() => {
    if (meetingInfo.dualMonitors) {
      openMeetingWindow({
        name: 'dualMonitorsWindow',
        postMessageData: {
          event: 'windowOpen',
          payload: {
            memberList: JSON.parse(JSON.stringify(memberList)),
            meetingInfo: JSON.parse(JSON.stringify(meetingInfoRef.current)),
          },
        },
      })
    }
  }, [meetingInfo.dualMonitors])

  return (
    <div
      className={classNames('h-full relative meeting-web-wrapper flex', {
        ['light-theme']: !isDarkMode,
        ['meeting-web-none-cursor']: !topBarVisible,
      })}
      style={{
        background: isElectronSharingScreen ? 'transparent' : undefined,
      }}
    >
      {!isElectronSharingScreen && window.isElectronNative && !isFullScreen && (
        <div className="electron-in-meeting-drag-bar">
          <div className="drag-region" />
          {t('appTitle')}
          <PCTopButtons />
        </div>
      )}
      {meetingInfo.meetingNum ? (
        <>
          <EndDropdown />
          <SharingComputerSound />
          <NoSpeakerVolume onSettingChange={onSettingChange} />
        </>
      ) : null}
      {meetingInfo.dualMonitors ? null : <SharingScreenZoom />}
      {meetingInfo.isRooms && !meetingInfo.isScreenSharingMeeting && (
        <RoomsHeader style={{ right: openRightDrawer ? 320 : 0 }} />
      )}
      <div
        className={classNames(
          'nemeeting flex flex-col h-full relative meeting-web',
          {
            'is-electron-sharing-screen': isElectronSharingScreen,
          }
        )}
        id="meeting-web"
        ref={newMeetingWebRef}
        style={{
          background: window.isElectronNative ? 'transparent' : '#292929',
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
              onSettingChange={onSettingChange}
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
                  destroyOnClose={true}
                />
                {!waitingRejoinMeeting && topBarVisible && (
                  <div className="nemeeting-top-right-wrap">
                    {meetingInfo.showSpeaker && (
                      <SpeakerListWrap
                        memberList={memberList}
                        isLocalScreen={isLocalScreen}
                      />
                    )}
                    <MeetingDuration className="nemeeting-top-right-item" />
                    {showLayout && (
                      <MeetingLayout
                        className="nemeeting-top-right-item"
                        onSettingClick={() => onSettingClick('video')}
                        onSettingChange={onSettingChange}
                      />
                    )}
                    <FullScreenButton
                      className="nemeeting-top-right-item"
                      isFullScreen={isFullScreen ?? false}
                    />
                  </div>
                )}
                {!meetingInfo.isRooms &&
                  topBarVisible &&
                  !waitingRejoinMeeting && (
                    <Network
                      className={'nemeeting-network'}
                      onSettingClick={onSettingClick}
                    />
                  )}
                {!meetingInfo.isRooms &&
                  topBarVisible &&
                  showMeetingInfo !== false &&
                  !waitingRejoinMeeting && (
                    <MeetingInfo className={'nemeeting-info'} />
                  )}
                {topBarVisible && (
                  <div className={classNames('nemeeting-top-left-reminds')}>
                    {/*直播中提示*/}
                    {!meetingInfo.isRooms && meetingInfo.liveState === 2 && (
                      <div className="living">
                        <span className="living-icon" />
                        <span>{t('living')}</span>
                      </div>
                    )}
                    {meetingInfo.isTranscriptionEnabled && (
                      <div className="living">
                        <svg
                          className="icon iconfont"
                          aria-hidden="true"
                          style={{
                            marginRight: '4px',
                            color: '#F51D45',
                            fontSize: '12px',
                          }}
                        >
                          <use xlinkHref="#iconzhuanxiezhong"></use>
                        </svg>
                        <span>{t('transcriptionRunning')}</span>
                      </div>
                    )}
                    {showRecord && (
                      <Record
                        className="nemeeting-record-wrap"
                        stopRecord={() => {
                          if (isHostOrCoHost) {
                            handleRecord()
                          } else if (meetingInfo.isLocalRecording) {
                            handleLocalRecord()
                          }
                        }}
                        recordState={meetingInfo.cloudRecordState}
                        notShowRecordBtn={
                          !isHostOrCoHost && !meetingInfo.isLocalRecording
                        }
                      />
                    )}
                    {showLocalRecord && !showRecord && (
                      <LocalRecord
                        className="nemeeting-record-wrap"
                        stopRecord={handleLocalRecord}
                        localRecordState={meetingInfo.localRecordState}
                        notShowRecordBtn={!meetingInfo.isLocalRecording}
                      />
                    )}
                    {!online &&
                      !waitingRejoinMeeting &&
                      !isElectronSharingScreen && (
                        <div className={'nemeeint-online'}>
                          {t('networkUnstableTip')}
                        </div>
                      )}
                  </div>
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
                {meetingInfo.interpretation?.started && (
                  <InterpretationWindow
                    style={{
                      display: openInterpretationWindow ? 'block' : 'none',
                    }}
                    className={` ${
                      interFloatingWindow
                        ? 'nemeeting-floating-window'
                        : 'nemeeting-interpreter-window-wrapper'
                    }`}
                    interpretation={meetingInfo.interpretation}
                    interpretationSetting={interpretationSetting}
                    isInterpreter={meetingInfo.isInterpreter}
                    isMiniWindow={interMiniWindow}
                    onClickMiniWindow={(isMini) => setInterMiniWindow(isMini)}
                    onClickManagement={() => setOpenInterpretationSetting(true)}
                    onClose={() => handleCloseInterpretationWindow()}
                    onMaxWindow={() => setInterFloatingWindow(false)}
                    defaultMajorVolume={defaultMajorVolume}
                    defaultListeningVolume={defaultListeningVolume}
                    localMember={localMember}
                    floatingWindow={interFloatingWindow}
                    neMeeting={neMeeting}
                  />
                )}
                <InterpreterSettingModal
                  inMeeting={true}
                  onClose={() => setOpenInterpretationSetting(false)}
                  className="nemeeting-interpreter-modal"
                  open={openInterpretationSetting}
                  onCancel={() => setOpenInterpretationSetting(false)}
                />
                <ScreenShareListModal
                  open={screenShareModalOpen}
                  shareSound={shareLocalComputerSound}
                  onShareSoundChanged={onShareSoundChanged}
                  onCancel={() => {
                    setScreenShareModalOpen(false)
                  }}
                  onStartShare={startShareInEle}
                  onStartShareSystemAudio={startShareSystemAudio}
                  ref={screenShareModalRef}
                />
              </>
            )}
            <CaptionWrapper
              openMeetingWindow={openMeetingWindow}
              isElectronSharingScreen={isElectronSharingScreen}
              isHostOrCoHost={isHostOrCoHost}
              onSettingChange={onSettingChange}
            />
            <MeetingCanvas
              isShowControlBar={isShowControlBar}
              onHandleFullSharingScreen={handleFullSharingScreen}
              mainHeight={mainHeight}
              isSpeaker={isSpeaker}
              isAudioMode={isAudioMode}
              isFullSharingScreen={fullSharingScreen}
              isLocalScreen={isLocalScreen}
            />
            {meetingInfo.dualMonitors ? null : <BackSharingViewButton />}
            <ConnectAudioModal onSettingChange={onSettingChange} />
            {!isElectronSharingScreen &&
            !meetingInfo.setting.normalSetting.chatMessageNotificationType &&
            meetingInfo.isSupportChatroom &&
            !noChat ? (
              <BulletScreenMessage
                className="nemeeting-bullet-screen-message"
                inputToolbarHidden={
                  !meetingInfo.enableFixedToolbar && !controlBarVisible
                }
              />
            ) : null}
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
      {meetingInfo.meetingNum && (
        <MeetingRightDrawer
          onSettingChange={onSettingChange}
          openMeetingWindow={openMeetingWindow}
          isElectronSharingScreen={isElectronSharingScreen}
        />
      )}
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
      <MeetingNotification
        ref={meetingNotificationRef}
        onNotificationCardWinOpen={onNotificationCardWinOpen}
        onClick={onNotificationClickHandler}
        neMeeting={neMeeting}
        noShowInvite={true}
        pluginNotifyDuration={pluginNotifyDuration}
      />
      {neMeeting?.previewController && (
        <Setting
          inMeeting={neMeeting.meetingNum ? true : false}
          onDeviceChange={onDeviceChange}
          defaultTab={settingModalTab}
          destroyOnClose={true}
          onSettingChange={onSettingChange}
          previewController={neMeeting.previewController}
          open={settingOpen}
          onCancel={() => setSettingOpen(false)}
        />
      )}
      {pluginInfo && (
        <PluginAppModal
          open={pluginOpen}
          name={pluginInfo.name}
          url={pluginInfo.homeUrl}
          pluginId={pluginInfo.pluginId}
          roomArchiveId={pluginMeetingId}
          isInMeeting={meetingInfo.meetingNum ? true : false}
          onCancel={() => {
            setPluginOpen(false)
          }}
        />
      )}

      <ChatRoomModal
        open={chatRoomModalOpen}
        meetingId={chatRoomMeetingId}
        onCancel={() => {
          setChatRoomModalOpen(false)
        }}
      />
      <FeedbackModal
        visible={feedbackOpen}
        onClose={() => setFeedbackOpen(false)}
      />

      {/* 本端默认渲染画布，纯音频模式没有画布情况第一次本端开启视频会报错*/}
      <div className="nemeeting-my-canvas" ref={myCanvasRef}></div>
    </div>
  )
}

export default MeetingContent
