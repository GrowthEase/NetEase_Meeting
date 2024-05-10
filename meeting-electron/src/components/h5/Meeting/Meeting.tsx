import React, {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react'
import MeetingCanvas from '../MeetingCanvas'
import MeetingHeader from '..//MeetingHeader'
import MeetingController from '../MeetingController'
import { useTranslation } from 'react-i18next'
import '../../../assets/iconfont/iconfont.css'
import loading from '../../../assets/loading.png'
import useEventHandler from '../../../hooks/useEventHandler'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import {
  ActionType,
  EventType,
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
  RecordState,
  UserEventType,
} from '../../../types'
import RemainTimeTip from '../../common/RemainTimeTip'
import Dialog from '../ui/dialog'

import MeetingNotification from '../../common/Notification'
import { useMeetingNotificationInMeeting } from '../../../hooks/useMeetingNotification'
import MeetingPluginPopup from '../MeetingPluginPopup'
import './AppH5.less'
import Record from '../../common/Record'
import useWatermark from '../../../hooks/useWatermark'

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

  const { meetingInfo, dispatch } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { localMember } = meetingInfo
  const {
    eventEmitter,
    neMeeting,
    waitingRejoinMeeting,
    dispatch: globalDispatch,
    online,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const toolTimer = useRef<null | ReturnType<typeof setTimeout>>(null)

  const [showMeetingTool, setShowMeetingTool] = useState<boolean>(true)
  const [showReplayVideoDialog, setShowReplayVideoDialog] =
    useState<boolean>(false)
  const {
    joinLoading,
    showReplayDialog,
    showReplayScreenDialog,
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

  const { t, i18n: i18next } = useTranslation()

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

  const onSizeChange = useCallback((event: Event) => {
    if (event.target instanceof Window) {
      const { innerHeight, innerWidth } = event.target
      // 临时兼容竖屏键盘唤起导致的宽大于高事件
      if (innerWidth - innerHeight > 80) {
        console.log({ innerHeight, innerWidth })
        // 横屏隐藏工具栏
        setShowMeetingTool(false)
      }
    }
  }, [])

  // 开始录制弹窗提醒
  const [startMeetingRecordingModal, setStartMeetingRecordingModal] =
    useState(false)
  // 结束录制弹窗提醒
  const [endMeetingRecordingModal, setEndMeetingRecordingModal] =
    useState(false)
  // 结束录制弹窗倒计时
  const [countdownNumber, setCountdownNumber] = useState<number>(-1)

  const { showCloudRecordingUI } =
    useContext<GlobalContextInterface>(GlobalContext)

  const showRecord = useMemo(() => {
    const cloudRecord = meetingInfo.cloudRecordState
    return (
      (cloudRecord === RecordState.Recording ||
        cloudRecord === RecordState.Starting) &&
      showCloudRecordingUI
    )
  }, [meetingInfo.cloudRecordState, showCloudRecordingUI])

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

  useEffect(() => {
    window.addEventListener('resize', onSizeChange)
    return () => {
      window.removeEventListener('resize', onSizeChange)
    }
  }, [])

  useEffect(() => {
    if (meetingInfo?.isCloudRecording && showCloudRecordingUI) {
      setStartMeetingRecordingModal(true)
    }
  }, [showCloudRecordingUI])

  useEffect(() => {
    if (endMeetingRecordingModal) {
      setCountdownNumber(3)
    } else {
      setCountdownNumber(-1)
    }
  }, [endMeetingRecordingModal])

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
  }, [countdownNumber])

  useEffect(() => {
    if (showCloudRecordingUI) {
      // 收到录制弹框提醒确认
      eventEmitter?.on(
        EventType.roomCloudRecordStateChanged,
        (recordState, operatorMember) => {
          const isCloudRecording = recordState === 0
          if (isCloudRecording) {
            setStartMeetingRecordingModal(true)
          } else {
            setEndMeetingRecordingModal(true)
          }
        }
      )
    }
  }, [showCloudRecordingUI])

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
  function _onclickTools(event: any) {
    event.stopPropagation()
    _setToolsHide()
  }

  // 点击头部
  function _onclickHeader(event: any) {
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
          {showRecord && (
            <div className="nemeeting-record-wrapper">
              <Record
                recordState={meetingInfo.cloudRecordState}
                notShowRecordBtn={true}
              />
            </div>
          )}
          <MeetingCanvas
            className={'flex-1 h-full'}
            onActiveIndexChanged={onHandlerActionIndexChanged}
          />
          <MeetingController
            className={''}
            visible={showMeetingTool}
            onClick={_onclickTools}
          />
          <MeetingPluginPopup />
          <Dialog
            visible={showReplayDialog}
            onConfirm={() => confirmToReplay('audio')}
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
