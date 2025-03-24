import React, {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import MeetingCanvas from '../MeetingCanvas'
import MeetingHeader from '../MeetingHeader'
import MeetingController from '../MeetingController'
import { useTranslation } from 'react-i18next'
import loading from '../../../assets/loading.png'
import useEventHandler from '../../../hooks/useEventHandler'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import {
  ActionType,
  EventType,
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
  MeetingSetting,
  RecordState,
  LocalRecordState,
  Role,
  UserEventType,
} from '../../../types'
import RemainTimeTip from '../../common/RemainTimeTip'
import Dialog from '../ui/dialog'
import MeetingNotification from '../../common/Notification'
import { useMeetingNotificationInMeeting } from '../../../hooks/useMeetingNotification'
import MeetingPluginPopup from '../MeetingPluginPopup'
import './AppH5.less'
import Record from '../../common/Record'
import LocalRecord from '../../common/LocalRecord'
import useWatermark from '../../../hooks/useWatermark'
import { MAJOR_AUDIO } from '../../../config'
import { setLocalStorageSetting } from '../../../utils'
import Toast from '../../../components/common/toast'
import useWebLocalAudioVolume from '../../../hooks/useWebLocalAudioVolume'

interface AppProps {
  width: number | string
  height: number | string
}

const Meeting: React.FC<AppProps> = ({ height, width }) => {
  useWatermark({
    zIndex: 9999,
    bottom: 80,
  })
  useMeetingNotificationInMeeting()

  const { meetingInfo, dispatch, memberList } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { localMember } = meetingInfo
  const {
    neMeeting,
    eventEmitter,
    waitingRejoinMeeting,
    interpretationSetting,
    dispatch: globalDispatch,
    online,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const toolTimer = useRef<null | ReturnType<typeof setTimeout>>(null)

  const meetingInfoRef = useRef(meetingInfo)
  const memberListRef = useRef(memberList)
  const myCanvasRef = useRef<HTMLDivElement>(null)

  memberListRef.current = memberList
  const interpretationSettingRef = useRef(interpretationSetting)

  const [showMeetingTool, setShowMeetingTool] = useState<boolean>(true)
  const showReplayVideoDialog = false
  const {
    joinLoading,
    showReplayDialog,
    showReplayScreenDialog,
    showStartPlayDialog,
    isShowAudioDialog,
    isShowVideoDialog,
    showReplayAudioSlaveDialog,
    setIsOpenVideoByHost,
    setIsShowVideoDialog,
    setIsOpenAudioByHost,
    setIsShowAudioDialog,
    confirmToReplay,
    confirmUnMuteMyAudio,
    confirmUnMuteMyVideo,
    showTimeTip,
    setShowTimeTip,
    timeTipContent,
  } = useEventHandler()

  meetingInfoRef.current = meetingInfo
  useWebLocalAudioVolume(localMember.isAudioOn)

  const { t } = useTranslation()

  const i18n = {
    hostOpenCameraTips: t('participantHostOpenCameraTips'),
    hostOpenMicroTips: t('participantHostOpenMicroTips'),
    openMicrophone: t('participantOpenMicrophone'),
    openCamera: t('participantOpenCamera'),
    beingMeetingRecorded: t('beingMeetingRecorded'),
    meetingLeaveFull: t('meetingLeaveFull'),
    gotIt: t('gotIt'),
    agreeInRecordMeeting: t('agreeInRecordMeeting'),
    startRecordTipByMember: t('startRecordTipByMember'),
    viewingLinkAfterMeetingEnd: t('viewingLinkAfterMeetingEnd'),
    cloudRecordingHasEnded: t('cloudRecordingHasEnded'),
    readyPlayOthersVideo: t('readyPlayOthersVideo'),
    readyPlayOthersShare: t('readyPlayOthersShare'),
    readyPlayOthersAudioAndVideo: t('readyPlayOthersAudioAndVideo'),
  }

  const isHostOrCoHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  const onSizeChange = useCallback((event: Event) => {
    if (event.target instanceof Window) {
      const { innerHeight, innerWidth } = event.target

      // 临时兼容竖屏键盘唤起导致的宽大于高事件
      if (innerWidth - innerHeight > 80) {
        // 横屏隐藏工具栏
        setShowMeetingTool(false)
      }
    }
  }, [])

  // 结束云录制弹窗提醒
  const [endMeetingRecordingModal, setEndMeetingRecordingModal] =
    useState(false)
  // 结束云录制弹窗倒计时
  const [countdownNumber, setCountdownNumber] = useState<number>(-1)

  const { showCloudRecordingUI, showLocalRecordingUI } =
    useContext<GlobalContextInterface>(GlobalContext)

  const showRecord = useMemo(() => {
    const cloudRecord = meetingInfo.cloudRecordState

    return (
      (cloudRecord === RecordState.Recording ||
        cloudRecord === RecordState.Starting) &&
      showCloudRecordingUI
    )
  }, [meetingInfo.cloudRecordState, showCloudRecordingUI])

  const showLocalRecordingUIRef = useRef<boolean>(true)

  showLocalRecordingUIRef.current = showLocalRecordingUI !== false
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
    console.log('memberList: ', memberListRef.current)

    const isOtherLocalRecording = memberListRef.current.find(
      (member) => member.isLocalRecording
    )

    return isLocalRecord || isOtherLocalRecording
  }, [
    meetingInfo.isLocalRecording,
    meetingInfo.localRecordState,
    showLocalRecordingUI,
    memberList,
  ])

  // 切换视图回调
  const onHandlerActionIndexChanged = (actionIndex: number) => {
    // 返回第一页，解决ios滑动到页面重新回来video标签遮挡。需要重新渲染
    console.log('onHandlerActionIndexChanged', actionIndex)
    if (actionIndex === 0) {
      setTimeout(() => {
        _onclickRoomBoard()
      }, 200)
    }
  }

  const onSettingChange = useCallback(
    (setting: MeetingSetting) => {
      setLocalStorageSetting(JSON.stringify(setting))
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          setting,
        },
      })
    },
    [dispatch]
  )

  useEffect(() => {
    myCanvasRef.current &&
      neMeeting?.rtcController?.setupLocalVideoCanvas(myCanvasRef.current)
  }, [neMeeting?.rtcController])

  useEffect(() => {
    window.addEventListener('resize', onSizeChange)
    return () => {
      window.removeEventListener('resize', onSizeChange)
    }
  }, [onSizeChange])

  useEffect(() => {
    if (endMeetingRecordingModal) {
      setCountdownNumber(3)
    } else {
      setCountdownNumber(-1)
    }
  }, [endMeetingRecordingModal])

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
  }, [isHostOrCoHost, eventEmitter])

  useEffect(() => {
    if (endMeetingRecordingModal) {
      if (countdownNumber !== -1) {
        const timer = setTimeout(() => {
          if (countdownNumber === 0) {
            setEndMeetingRecordingModal(false)
          } else {
            setCountdownNumber(countdownNumber - 1)
          }
        }, 1000)

        return () => {
          clearTimeout(timer)
        }
      }
    }
  }, [countdownNumber, endMeetingRecordingModal])

  useEffect(() => {
    if (showCloudRecordingUI) {
      // 收到录制弹框提醒确认
      eventEmitter?.on(EventType.roomCloudRecordStateChanged, (recordState) => {
        const isCloudRecording = recordState === 0

        if (!isCloudRecording) {
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

          setEndMeetingRecordingModal(true)
        }
      })
    }
  }, [showCloudRecordingUI, eventEmitter])

  useEffect(() => {
    const listenLanguageCurrent = interpretationSettingRef.current
    const meetingInfoCurrent = meetingInfoRef.current

    return () => {
      const listenLanguage = listenLanguageCurrent?.listenLanguage

      if (
        meetingInfoCurrent.interpretation?.started &&
        !meetingInfoCurrent.isInterpreter
      ) {
        if (listenLanguage && listenLanguage !== MAJOR_AUDIO) {
          const channel =
            meetingInfoCurrent.interpretation?.channelNames[listenLanguage]

          channel && neMeeting?.leaveRtcChannel(channel)
        }
      }
    }
  }, [neMeeting])

  // 5秒后隐藏操作栏
  function _setToolsHide() {
    if (toolTimer.current) {
      clearTimeout(toolTimer.current)
      toolTimer.current = null
    }

    toolTimer.current = setTimeout(() => {
      setShowMeetingTool(false)
    }, 5000)
  }

  function rejoinMeeting() {
    eventEmitter?.emit(UserEventType.RejoinMeeting, {
      isAudioOn: localMember.isAudioOn,
      isVideoOn: localMember.isVideoOn,
    })
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        waitingRejoinMeeting: false,
      },
    })
    // setIsShowRejoinDialog(false)
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

  // 点击空白区显示隐藏操作栏
  function _onclickRoomBoard() {
    setShowMeetingTool(!showMeetingTool)
    _setToolsHide()
  }

  // 点击操作栏
  function _onclickTools(event: React.MouseEvent<HTMLDivElement>) {
    event.stopPropagation()
    _setToolsHide()
  }

  // 点击头部
  function _onclickHeader(event: React.MouseEvent<HTMLDivElement>) {
    event.stopPropagation()
    if (toolTimer.current) {
      clearTimeout(toolTimer.current)
      toolTimer.current = null
    }
  }

  return (
    <div
      className="App flex flex-col h-full relative ne-meeting-app-h5"
      style={{
        width: `${!width ? '100%' : `${width}px`}`,
        height: `${!height ? '100%' : `${height}px`}`,
      }}
      onClick={_onclickRoomBoard}
    >
      {/* 本端默认渲染画布，纯音频模式没有画布情况第一次本端开启视频会报错*/}
      <div className="nemeeting-my-canvas" ref={myCanvasRef}></div>
      <Dialog
        visible={!!waitingRejoinMeeting}
        title={t('networkAbnormality')}
        cancelText={t('meetingLeaveFull')}
        confirmText={t('rejoin')}
        onCancel={() => {
          leaveMeeting()
        }}
        onConfirm={() => {
          rejoinMeeting()
        }}
      >
        {t('networkDisconnected')}
      </Dialog>
      {meetingInfo.meetingNum ? (
        <>
          <Dialog
            visible={isShowVideoDialog}
            title={i18n.openCamera}
            confirmText={t('yes')}
            cancelText={t('no')}
            onCancel={() => {
              setIsOpenVideoByHost(false)
              setIsShowVideoDialog(false)
            }}
            onConfirm={() => {
              confirmUnMuteMyVideo()
            }}
          >
            {i18n.hostOpenCameraTips}
          </Dialog>
          <Dialog
            visible={isShowAudioDialog}
            title={i18n.openMicrophone}
            confirmText={t('yes')}
            cancelText={t('no')}
            onCancel={() => {
              setIsOpenAudioByHost(false)
              setIsShowAudioDialog(false)
            }}
            onConfirm={() => {
              confirmUnMuteMyAudio()
            }}
          >
            {i18n.hostOpenMicroTips}
          </Dialog>
          {showTimeTip && (
            <RemainTimeTip
              className={'nemeeting-time-tip-wrap'}
              text={timeTipContent}
              onCloseHandler={() => {
                setShowTimeTip(false)
              }}
            />
          )}
          <MeetingNotification isH5 />
          <MeetingHeader
            className={''}
            visible={showMeetingTool}
            onClick={_onclickHeader}
          />
          <div className="nemeeting-record-wrapper">
            {meetingInfo.liveState === 2 && (
              <div className="living nemeeting-h5-top-tip">
                <span className="living-icon" />
                <span>{t('living')}</span>
              </div>
            )}
            {showRecord && (
              <Record
                className="nemeeting-h5-top-tip"
                recordState={meetingInfo.cloudRecordState}
                notShowRecordBtn={true}
              />
            )}
            {showLocalRecord && !showRecord && (
              <LocalRecord
                className="nemeeting-h5-top-tip"
                localRecordState={meetingInfo.localRecordState}
                notShowRecordBtn={true}
              />
            )}
          </div>
          <MeetingCanvas
            className={'flex-1 h-full'}
            onActiveIndexChanged={onHandlerActionIndexChanged}
          />
          {localMember.role !== Role.observer && (
            <MeetingController
              className={''}
              visible={showMeetingTool}
              onClick={_onclickTools}
              onSettingChange={onSettingChange}
            />
          )}

          <MeetingPluginPopup />
          <Dialog
            visible={showReplayDialog || showStartPlayDialog}
            onConfirm={() => confirmToReplay('audio', showStartPlayDialog)}
            ifShowCancel={false}
          >
            <span>{i18n.readyPlayOthersAudioAndVideo}</span>
          </Dialog>

          <Dialog
            visible={endMeetingRecordingModal}
            title={i18n.cloudRecordingHasEnded}
            confirmText={i18n.gotIt + '（' + countdownNumber + 's）'}
            ifShowCancel={false}
            width={305}
            onConfirm={() => {
              setEndMeetingRecordingModal(false)
            }}
          >
            <div className="end-meeting-record-modal">
              <div className="end-record-message">
                {i18n.viewingLinkAfterMeetingEnd}
              </div>
            </div>
          </Dialog>
          <Dialog
            visible={showReplayVideoDialog}
            onConfirm={() => confirmToReplay('video')}
            ifShowCancel={false}
          >
            <span>{i18n.readyPlayOthersVideo}</span>
          </Dialog>
          <Dialog
            visible={showReplayScreenDialog}
            onConfirm={() => confirmToReplay('screen')}
            ifShowCancel={false}
          >
            <span>{i18n.readyPlayOthersShare}</span>
          </Dialog>
          <Dialog
            visible={showReplayAudioSlaveDialog}
            onConfirm={() => confirmToReplay('audioSlave')}
            ifShowCancel={false}
          >
            <span>{i18n.readyPlayOthersAudioAndVideo}</span>
          </Dialog>

          {!online && !waitingRejoinMeeting && (
            <p className={'nemeeint-online'}>{t('disconnected')}</p>
          )}
        </>
      ) : joinLoading ? (
        <div className="meeting-loading">
          <div className="meeting-loading-content">
            <img className="meeting-loading-img" src={loading} alt="" />
            <div className="meeting-loading-text">{t('joining')}</div>
          </div>
        </div>
      ) : (
        ''
      )}
    </div>
  )
}

export default Meeting
