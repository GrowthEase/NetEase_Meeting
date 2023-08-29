import React, { useContext, useEffect, useRef, useState } from 'react'
import MeetingCanvas from './components/h5/MeetingCanvas'
import MeetingHeader from './components/h5/MeetingHeader'
import MeetingController from './components/h5/MeetingController'
import './AppH5.less'
import './assets/iconfont/iconfont.css'
import { GlobalContext, MeetingInfoContext } from './store'
import {
  ActionType,
  GlobalContext as GlobalContextInterface,
  MeetingEventType,
  MeetingInfoContextInterface,
  UserEventType,
} from './types'
import Dialog from './components/h5/ui/dialog'
//@ts-ignore
import loading from './assets/loading.png'
import RemainTimeTip from './components/common/RemainTimeTip'
import useEventHandler from './hooks/useEventHandler'
import { useTranslation } from 'react-i18next'
import Toast from './components/common/toast'

interface AppProps {
  width: number | string
  height: number | string
}

const AppH5: React.FC<AppProps> = ({ height, width }) => {
  const { meetingInfo, dispatch } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const {
    eventEmitter,
    neMeeting,
    waitingRejoinMeeting,
    dispatch: globalDispatch,
    online,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const { t } = useTranslation()
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

  const onSizeChange = (event: Event) => {
    if (event.target instanceof Window) {
      const { innerHeight, innerWidth } = event.target
      // 临时兼容竖屏键盘唤起导致的宽大于高事件
      if (innerWidth - innerHeight > 80) {
        console.log({ innerHeight, innerWidth })
        // 横屏隐藏工具栏
        setShowMeetingTool(false)
      }
    }
  }

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
    // eventEmitter?.on(MeetingEventType.rtcChannelError, () => {
    //   setIsShowRejoinDialog(true)
    // })
    return () => {
      window.removeEventListener('resize', onSizeChange)
    }
  }, [])

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
    eventEmitter?.emit(UserEventType.RejoinMeeting)
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
    await neMeeting?.leave()
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
      className="App flex flex-col h-full relative"
      style={{
        width: `${!width ? '100%' : `${width}px`}`,
        height: `${!height ? '100%' : `${height}px`}`,
      }}
      onClick={_onclickRoomBoard}
    >
      {meetingInfo.meetingNum ? (
        <>
          <Dialog
            visible={isShowVideoDialog}
            title="打开摄像头"
            onCancel={() => {
              setIsOpenVideoByHost(false)
              setIsShowVideoDialog(false)
            }}
            onConfirm={() => {
              confirmUnMuteMyVideo()
            }}
          >
            主持人已重新打开您的摄像头，确认打开？
          </Dialog>
          <Dialog
            visible={isShowAudioDialog}
            title="打开麦克风"
            onCancel={() => {
              setIsOpenAudioByHost(false)
              setIsShowAudioDialog(false)
            }}
            onConfirm={() => {
              confirmUnMuteMyAudio()
            }}
          >
            主持人已重新打开您的麦克风，确认打开？
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

          <MeetingHeader
            className={''}
            visible={showMeetingTool}
            onClick={_onclickHeader}
          />
          <MeetingCanvas
            className={'flex-1 h-full'}
            onActiveIndexChanged={onHandlerActionIndexChanged}
          />
          <MeetingController
            className={''}
            visible={showMeetingTool}
            onClick={_onclickTools}
          />
          <Dialog
            visible={showReplayDialog}
            onConfirm={() => confirmToReplay('audio')}
            ifShowCancel={false}
          >
            <span>{`即将开始播放其他成员的音视频`}</span>
          </Dialog>
          <Dialog
            visible={showReplayVideoDialog}
            onConfirm={() => confirmToReplay('video')}
            ifShowCancel={false}
          >
            <span>{`即将开始播放其他成员的视频`}</span>
          </Dialog>
          <Dialog
            visible={showReplayScreenDialog}
            onConfirm={() => confirmToReplay('screen')}
            ifShowCancel={false}
          >
            <span>{`即将开始播放其他成员的共享画面`}</span>
          </Dialog>
          <Dialog
            visible={showReplayAudioSlaveDialog}
            onConfirm={() => confirmToReplay('audioSlave')}
            ifShowCancel={false}
          >
            <span>{`即将开始播放其他成员的音频辅流`}</span>
          </Dialog>
          <Dialog
            visible={!!waitingRejoinMeeting}
            title={t('networkAbnormality')}
            cancelText={t('leaveMeeting')}
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
          {!online && !waitingRejoinMeeting && (
            <p className={'nemeeint-online'}>{t('disconnected')}</p>
          )}
        </>
      ) : joinLoading ? (
        <div className="meeting-loading">
          <div className="meeting-loading-content">
            <img className="meeting-loading-img" src={loading} alt="" />
            <div className="meeting-loading-text">正在进入会议...</div>
          </div>
        </div>
      ) : (
        ''
      )}
    </div>
  )
}

export default AppH5
