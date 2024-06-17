import './index.less'
import React, { useEffect, useState } from 'react'
import waitingRoomBg from '../../../assets/waigting-room-h5-bg.png'
import { useWaitingRoom } from '../../../hooks/useWaitingRoom'
import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../store'
import { useTranslation } from 'react-i18next'
import { Button, Switch, ActionSheet, Badge } from 'antd-mobile/es'
import type { Action } from 'antd-mobile/es/components/action-sheet'
import { ActionType, EventType } from '../../../types'
import { NEMeetingLeaveType } from '../../../types/type'
import { NERoomChatMessage } from '../../../types/innerType'
import Dialog from '../ui/dialog'
import classNames from 'classnames'
import NEChatRoom from '../NEChatRoom'

interface WaitRoomProps {
  className?: string
}

const WaitRoom: React.FC<WaitRoomProps> = ({ className }) => {
  const { t } = useTranslation()
  const { waitingRoomInfo } = useWaitingRoomContext()
  const [showExitAction, setShowExitAction] = useState(false)
  const { neMeeting, outEventEmitter, eventEmitter } = useGlobalContext()
  const [showCloseDialog, setShowCloseDialog] = useState(false)
  const [receiveMsg, setReceiveMsg] = useState<NERoomChatMessage[]>() // 聊天室未读消息
  const [chatroomVisible, setChatroomVisible] = useState(false)
  const [unReadCount, setUnReadCount] = useState(0)
  const [closeInfo, setCloseInfo] = useState({
    title: '',
    content: '',
    closeText: '',
    reason: '',
  })
  const closeModalHandle = (data: {
    title: string
    content: string
    closeText: string
    reason: any
  }) => {
    setCloseInfo(data)
    setShowCloseDialog(true)
  }

  const {
    isOffLine,
    meetingState,
    formatMeetingTime,
    nickname,
    openVideo,
    openAudio,
    videoCanvasWrapRef,
    handleOpenVideo,
    handleOpenAudio,
    showChatRoom,
  } = useWaitingRoom({
    closeModalHandle,
  })
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const onLeaveRoom = () => {
    setShowExitAction(true)
  }

  const onClickOpenAudio = (isOpen: boolean) => {
    handleOpenAudio(!isOpen)
  }

  useEffect(() => {
    const canvasView = document.getElementById('nemeetingWaitingRoomCanvas')
    const container = document.getElementById('neMeetingWaitingRoomH5')

    if (!canvasView || !container) {
      return
    }

    let disX = 0
    let disY = 0

    //拖动事件监听
    const move = (e: TouchEvent) => {
      const { clientX, clientY } = e.targetTouches[0]

      // 不能超过屏幕左右边界
      if (clientX - disX <= 2) {
        canvasView.style.left = '2px'
      } else if (clientX - disX >= container.clientWidth - 90) {
        canvasView.style.left = container.clientWidth - 90 + 'px'
      } else {
        canvasView.style.left = clientX - disX + 'px'
      }

      // 不能超过屏幕上下边界
      if (clientY - disY <= 2) {
        canvasView.style.top = '2px'
      } else if (clientY - disY >= container.clientHeight - 155) {
        canvasView.style.top = container.clientHeight - 155 + 'px'
      } else {
        canvasView.style.top = clientY - disY + 'px'
      }
    }

    // 停止拖动
    const up = () => {
      canvasView.removeEventListener('touchmove', move)
      canvasView.removeEventListener('touchend', up)
    }

    // 开始拖动
    const start = (e: TouchEvent) => {
      // 获取元素的宽高
      const { clientX, clientY } = e.targetTouches[0]
      const { left, top } = canvasView.getBoundingClientRect()

      disX = clientX - left
      disY = clientY - top
      canvasView.addEventListener('touchmove', move)
      canvasView.addEventListener('touchend', up)
    }

    // h5监听视频预览窗口touchstart touchmove touchend拖动事件进行拖动
    canvasView?.addEventListener('touchstart', start)
    return () => {
      canvasView.removeEventListener('touchmove', move)
      canvasView.removeEventListener('touchend', up)
      canvasView.removeEventListener('touchstart', start)
    }
  }, [])

  const handleCloseModal = (reason: string) => {
    setShowCloseDialog(false)
    setCloseInfo({
      title: '',
      content: '',
      closeText: '',
      reason: '',
    })
    outEventEmitter?.emit(EventType.RoomEnded, reason)
  }

  const onClickOpenVideo = (isOpen: boolean) => {
    handleOpenVideo(!isOpen)
  }

  const leaveMeetingRoom = async () => {
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

  const actions: Action[] = [
    {
      text: t('meetingLeaveFull'),
      key: 'leave',
      onClick: async () => {
        await leaveMeetingRoom()
      },
    },
  ]

  useEffect(() => {
    eventEmitter?.on(EventType.ReceiveChatroomMessages, (msgs) => {
      console.log('ReceiveChatroomMessages', msgs)
      setReceiveMsg(msgs)
    })
    return () => {
      eventEmitter?.off(EventType.ReceiveChatroomMessages)
    }
  }, [eventEmitter])

  return (
    <div
      className={classNames(
        'nemeeting-waiting-room-h5 ne-meeting-app-h5',
        className
      )}
      id="neMeetingWaitingRoomH5"
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
        <div className="nemeeting-waiting-room-title-wrapper">
          <span className="nemeeting-waiting-room-title">
            {t('globalAppName')}
          </span>
          <Button
            style={{ width: '50px' }}
            color="danger"
            size={'mini'}
            shape="rounded"
            className="nemeeting-waiting-exit-btn"
            onClick={onLeaveRoom}
          >
            {t('meetingLeave')}
          </Button>
        </div>
        {isOffLine ? (
          <div className="waiting-room-network-error">
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconwarning-y1x"></use>
            </svg>
            <div className="waiting-room-alter-content">
              {t('networkErrorAndCheck')}
            </div>
          </div>
        ) : null}
        <div className="nemeeting-waiting-room-content-wrapper">
          {/*会议信息*/}
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
                <span className="nemeeting-waiting-room-text">
                  {t('inviteSubject')}:{' '}
                </span>
                <span className="nemeeting-waiting-room-ml12 ">
                  {meetingInfo.subject}
                </span>
              </div>
              <div className="waiting-room-time">
                <svg className="icon iconfont iconfont-tip" aria-hidden="true">
                  <use xlinkHref="#iconshijian2"></use>
                </svg>
                <span className="nemeeting-waiting-room-text">
                  {t('inviteTime')}:{' '}
                </span>
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
                <span className="nemeeting-waiting-room-text">
                  {t('meetingNickname')}:{' '}
                </span>
                <span className="nemeeting-waiting-room-ml12">{nickname}</span>
              </div>
            </div>
          </div>
          {/*  入会选项*/}
          <div className="nemeeting-waiting-room-options">
            <div className="nemeeting-waiting-room-options-title">
              {t('waitingRoomJoinMeetingOption')}
            </div>
            <div className="nemeeting-waiting-room-options-item">
              <div>{t('waitingRoomTurnOnMicrophone')}</div>
              <Switch
                checked={openAudio}
                onChange={onClickOpenAudio}
                className="nemeeting-switch"
              />
            </div>
            <div className="nemeeting-waiting-room-options-item">
              <div>{t('waitingRoomTurnOnVideo')}</div>
              <Switch
                checked={openVideo}
                onChange={onClickOpenVideo}
                className="nemeeting-switch"
              />
            </div>
          </div>
          {/*聊天室按钮*/}
          {showChatRoom && (
            <div
              className="nemeeting-waiting-chat-btn"
              onClick={() => {
                setChatroomVisible(true)
                setUnReadCount(0)
              }}
            >
              <Badge
                className="waiting-chat-badge"
                content={
                  unReadCount > 0
                    ? unReadCount > 99
                      ? '99+'
                      : unReadCount
                    : null
                }
              >
                <svg className="icon iconfont icon-chat" aria-hidden="true">
                  <use xlinkHref="#iconchat1x"></use>
                </svg>
              </Badge>
              <span>{t('chat')}</span>
            </div>
          )}

          {/*视频预览*/}
          <div
            id="nemeetingWaitingRoomCanvas"
            style={{ zIndex: openVideo ? 10 : -10 }}
            className={'nemeeting-waiting-room-canvas'}
            ref={videoCanvasWrapRef}
          ></div>
        </div>
      </div>
      <Dialog
        title={closeInfo.title}
        visible={showCloseDialog}
        confirmText={closeInfo.closeText}
        onConfirm={() => handleCloseModal(closeInfo.reason)}
        ifShowCancel={false}
      >
        <div style={{ textAlign: 'center', fontSize: '14px' }}>
          {closeInfo.content}
        </div>
      </Dialog>
      <ActionSheet
        visible={showExitAction}
        actions={actions}
        extra={t('meetingLeaveConfirm')}
        cancelText={t('globalCancel')}
        getContainer={null}
        onClose={() => setShowExitAction(false)}
      />
      <NEChatRoom
        visible={chatroomVisible}
        onClose={() => setChatroomVisible(false)}
        unReadChange={(count) => setUnReadCount(count)}
        receiveMsg={receiveMsg}
        isWaitingRoom
      />
    </div>
  )
}

export default WaitRoom
