import React, {
  useContext,
  useEffect,
  useImperativeHandle,
  useMemo,
  useState,
} from 'react'
import MemberList from '../MemberList'
import { NERoomChatMessage, EventType } from '../../../types/innerType'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import {
  AttendeeOffType,
  Role,
  memberAction,
  ActionType,
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
} from '../../../types'
import './index.less'
import NEChatRoom from '../NEChatRoom'
import Toast from '../../common/toast'
import Dialog from '../ui/dialog'

interface MeetingControllerProps {
  className?: string
  visible?: boolean
  onClick?: (e: any) => void
  onRef?: React.RefObject<unknown>
}

const MeetingController: React.FC<MeetingControllerProps> = ({
  className = '',
  visible = false,
  onClick,
  onRef,
}) => {
  const {
    meetingInfo: { localMember, audioOff, videoOff, screenUuid },
    memberList,
    dispatch,
  } = useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { neMeeting, eventEmitter } =
    useContext<GlobalContextInterface>(GlobalContext)
  const [showMember, setShowMember] = useState(false)
  const [showChatRoom, setShowChatRoom] = useState(false) // 打开聊天室
  const [unReadCount, setUnReadCount] = useState(0) // 聊天室未读消息
  const [receiveMsg, setReceiveMsg] = useState<NERoomChatMessage[]>() // 聊天室未读消息

  // 暴露外部ref能访问的属性
  useImperativeHandle(onRef, () => {
    return {
      checkNeedHandsUp: checkNeedHandsUp,
    }
  })

  useEffect(() => {
    console.log(localMember, memberList, 'memberList')
    eventEmitter?.on(EventType.ReceiveChatroomMessages, (msgs) => {
      setReceiveMsg(msgs)
    })
    eventEmitter?.on(
      EventType.NeedAudioHandsUp,
      (needAudioHandsUp: boolean) => {
        setIsShowAudioHandsUpDialog(needAudioHandsUp)
      }
    )
    eventEmitter?.on(
      EventType.NeedVideoHandsUp,
      (needVideoHandsUp: boolean) => {
        setIsShowVideoHandsUpDialog(needVideoHandsUp)
      }
    )
    eventEmitter?.on(
      EventType.CheckNeedHandsUp,
      (data: { type: 'video' | 'audio'; isOpen: boolean }) => {
        checkNeedHandsUp(data.type, data.isOpen)
      }
    )
    return () => {
      eventEmitter?.off(EventType.ReceiveChatroomMessages)
      eventEmitter?.off(EventType.NeedAudioHandsUp)
      eventEmitter?.off(EventType.NeedVideoHandsUp)
      eventEmitter?.off(EventType.CheckNeedHandsUp)
    }
  }, [])
  const [isShowVideoHandsUpDialog, setIsShowVideoHandsUpDialog] =
    useState(false)
  const [isShowAudioHandsUpDialog, setIsShowAudioHandsUpDialog] =
    useState(false)
  const [isShowHandsDownDialog, setIsShowHandsDownDialog] = useState(false)

  const isScreen = useMemo(() => {
    return !!screenUuid && screenUuid === localMember.uuid
  }, [screenUuid])
  // 判断用户是否需要举手
  const checkNeedHandsUp = (type: 'audio' | 'video', isOpen: boolean) => {
    // 如果是关闭则直接执行
    if (!isOpen) {
      if (type === 'audio') {
        operateLocalAudio(0)
      } else {
        operateLocalVideo(0)
      }
      return
    }
    const isHost =
      localMember.role === Role.host || localMember.role === Role.coHost
    if (type === 'video') {
      // 当前房间不允许自己打开，非主持人，当前非共享用户
      if (
        videoOff === AttendeeOffType.offNotAllowSelfOn &&
        !isHost &&
        !isScreen
      ) {
        // 当前已经在举手中
        if (localMember.isHandsUp) {
          Toast.info('您已举手，等待主持人处理')
        } else {
          setIsShowVideoHandsUpDialog(true)
        }
      } else {
        operateLocalVideo(1)
      }
    } else if (type === 'audio') {
      // 当前房间不允许自己打开，非主持人，当前非共享用户
      if (
        audioOff === AttendeeOffType.offNotAllowSelfOn &&
        !isHost &&
        !isScreen
      ) {
        if (localMember.isHandsUp) {
          Toast.info('您已举手，等待主持人处理')
        } else {
          setIsShowAudioHandsUpDialog(true)
        }
      } else {
        operateLocalAudio(1)
      }
    }
  }

  /**
   * 操作当前用户的音频
   * @param type 1开启0关闭
   */
  const operateLocalAudio = async (type: 0 | 1) => {
    console.log('操作本人音频 ', type)
    try {
      switch (type) {
        case 1:
          await neMeeting?.unmuteLocalAudio()
          break
        case 0:
          await neMeeting?.muteLocalAudio()
          break
        default:
          break
      }
    } catch (error) {
      console.log('operateLocalAudio ', error)
    }
  }

  // 举手操作
  const handleHandsUp = (
    actionType: memberAction.handsDown | memberAction.handsUp
  ) => {
    neMeeting
      ?.sendMemberControl(actionType, localMember.uuid)
      .then(() => {
        if (actionType === memberAction.handsUp) {
          Toast.info('举手成功，等待主持人处理')
        } else {
          Toast.info('取消举手成功')
        }
        dispatch &&
          dispatch({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: localMember.uuid,
              member: {
                isHandsUp: actionType === memberAction.handsUp,
              },
            },
          })
      })
      .finally(() => {
        if (actionType === memberAction.handsUp) {
          setIsShowVideoHandsUpDialog(false)
          setIsShowAudioHandsUpDialog(false)
        } else {
          setIsShowHandsDownDialog(false)
        }
      })
  }

  /**
   * 操作当前用户的视频
   * @param type 0关闭1开启
   */
  const operateLocalVideo = async (type: 0 | 1) => {
    console.log('操作本人视频 ', type)
    try {
      switch (type) {
        case 1:
          await neMeeting?.unmuteLocalVideo()
          break
        case 0:
          await neMeeting?.muteLocalVideo()
          break
        default:
          break
      }
    } catch (error) {
      console.log('operateLocalVideo ', error)
    }
  }

  // 打开聊天室
  const onNEChatClick = () => {
    setShowChatRoom(true)
    setUnReadCount(0)
  }

  function onCardClick(event: any) {
    onClick?.(event)
  }

  return (
    <>
      {visible && (
        <div
          className={`w-full meeting-controller absolute flex justify-around ${
            className || ''
          }`}
          onClick={(e) => onCardClick(e)}
        >
          <div
            onClick={() => {
              checkNeedHandsUp('audio', !localMember.isAudioOn)
            }}
            className="controller-item"
          >
            {localMember.isAudioOn ? (
              <i className="icon-tool iconfont iconyx-tv-voice-onx"></i>
            ) : (
              <i className="icon-red icon-tool iconfont iconyx-tv-voice-offx"></i>
            )}
            <div>{localMember.isAudioOn ? '静音' : '取消静音'}</div>
          </div>
          <div
            onClick={() => {
              checkNeedHandsUp('video', !localMember.isVideoOn)
            }}
            className="controller-item"
          >
            {localMember.isVideoOn ? (
              <i className="icon-tool iconfont iconyx-tv-video-onx"></i>
            ) : (
              <i className="icon-red icon-tool iconfont iconyx-tv-video-offx"></i>
            )}
            <div>{localMember.isVideoOn ? '停止视频' : '开启视频'}</div>
          </div>
          {/* <div>
          <svg className={`icon ${localMember.isSharingScreen ? 'icon-blue' : 'icon-white'}`} aria-hidden="true">
            <use xlinkHref="#iconyx-tv-sharescreen1x"></use>
          </svg>
          <div onClick={toggleMuteAudio}>{localMember.isSharingScreen ? '取消共享' : '共享屏幕'}</div>
        </div> */}
          <div className="relative controller-item">
            {/*举手图标显示`*/}
            {localMember.isHandsUp && (
              <span
                className="hands-up-tip"
                onClick={() => {
                  setIsShowHandsDownDialog(true)
                }}
              >
                <i className="icon-tool iconfont iconraisehands1x"></i>
                <span className="hands-arrow"></span>
                <span className="hands-arrow-text">举手中</span>
              </span>
            )}
            <div
              onClick={() => {
                setShowMember(!showMember)
              }}
            >
              <div className="absolute member-count">
                {memberList?.length > 99 ? '99+' : memberList?.length}
              </div>
              <i className="icon-tool iconfont iconyx-tv-attendeex"></i>
              <div>
                {localMember.role === Role.host ||
                localMember.role === Role.coHost
                  ? '管理参会者'
                  : '参会者'}
              </div>
            </div>
          </div>
          <div className="relative controller-item" onClick={onNEChatClick}>
            {unReadCount ? (
              <div className="unread-count">
                {unReadCount > 99 ? '99+' : unReadCount}
              </div>
            ) : (
              ''
            )}
            <i className="icon-tool iconfont iconshipin-liaotian"></i>
            <div>聊天</div>
          </div>
        </div>
      )}
      {/* dialog的显示不受visible影响 */}
      <Dialog
        visible={isShowVideoHandsUpDialog}
        title="提示"
        onCancel={() => {
          setIsShowVideoHandsUpDialog(false)
        }}
        onConfirm={() => {
          handleHandsUp(memberAction.handsUp)
        }}
      >
        <div style={{ color: '#000', fontSize: '13px' }}>
          主持人已将全体关闭视频，您可以举手申请发言
        </div>
      </Dialog>
      <Dialog
        visible={isShowAudioHandsUpDialog}
        title="提示"
        onCancel={() => {
          setIsShowAudioHandsUpDialog(false)
        }}
        onConfirm={() => {
          handleHandsUp(memberAction.handsUp)
        }}
      >
        <div style={{ color: '#000', fontSize: '13px' }}>
          主持人已将全体关闭音频，您可以举手申请发言
        </div>
      </Dialog>
      <Dialog
        visible={isShowHandsDownDialog}
        title="提示"
        onCancel={() => {
          setIsShowHandsDownDialog(false)
        }}
        onConfirm={() => {
          handleHandsUp(memberAction.handsDown)
        }}
      >
        <div style={{ color: '#000', fontSize: '13px' }}>
          确认取消举手申请吗？
        </div>
      </Dialog>
      <NEChatRoom
        visible={showChatRoom}
        onClose={() => setShowChatRoom(false)}
        unReadChange={(count) => setUnReadCount(count)}
        receiveMsg={receiveMsg}
      />
      <MemberList
        visible={showMember}
        onClose={() => {
          setShowMember(false)
        }}
      />
    </>
  )
}

export default MeetingController
