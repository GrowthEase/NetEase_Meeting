import React, {
  useCallback,
  useContext,
  useEffect,
  useImperativeHandle,
  useMemo,
  useState,
  useRef,
} from 'react'
import MemberList from '../MemberList'
import {
  NERoomChatMessage,
  EventType,
  NEMenuIDs,
  CustomButtonIdBoundaryValue,
  NEMenuVisibility,
} from '../../../types/innerType'
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
import { Popover } from 'antd-mobile'
import {
  AudioButton,
  ChatButton,
  MemberButton,
  VideoButton,
} from './builtInButton'
import CustomButton from '../../common/CustomButton'
import { defaultMenusInH5 } from '../../../services'

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
  const { neMeeting, eventEmitter, toolBarList, moreBarList } =
    useContext<GlobalContextInterface>(GlobalContext)
  const [showMember, setShowMember] = useState(false)
  const [showChatRoom, setShowChatRoom] = useState(false) // 打开聊天室
  const [unReadCount, setUnReadCount] = useState(0) // 聊天室未读消息
  const [receiveMsg, setReceiveMsg] = useState<NERoomChatMessage[]>() // 聊天室未读消息
  const [moreBtnVisible, setMoreBtnVisible] = useState<boolean>(false)
  // const toolBarList = globalConfig?.toolBarList
  // const moreBarList = globalConfig?.moreBarList
  const meetingControllerRef = useRef<HTMLDivElement | null>(null)

  // 暴露外部ref能访问的属性
  useImperativeHandle(onRef, () => {
    return {
      checkNeedHandsUp: checkNeedHandsUp,
    }
  })

  useEffect(() => {
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

  const isHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  // 根据角色配置菜单的展示与否
  const btnVisible = (visibility = 0) => {
    let result = false
    switch (true) {
      case NEMenuVisibility.VISIBLE_ALWAYS === visibility:
        result = true
        break
      case NEMenuVisibility.VISIBLE_EXCLUDE_HOST === visibility && isHost:
        result = true
        break
      case NEMenuVisibility.VISIBLE_TO_HOST_ONLY === visibility && !isHost:
        result = true
        break
      default:
        break
    }
    return result
  }

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
          await neMeeting?.muteLocalAudio().then(() => {
            dispatch?.({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: localMember.uuid,
                member: { isAudioOn: false },
              },
            })
          })
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
          await neMeeting?.muteLocalVideo().then(() => {
            dispatch?.({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: localMember.uuid,
                member: { isVideoOn: false },
              },
            })
          })
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
    setMoreBtnVisible(false)
    onClick?.(event)
  }

  const getBuiltInButtonContent = useCallback(
    (item) => {
      if (item.id === NEMenuIDs.mic && btnVisible(item.visibility)) {
        return (
          <AudioButton
            key={item.id}
            item={item}
            localMember={localMember}
            onClick={checkNeedHandsUp}
          />
        )
      } else if (item.id === NEMenuIDs.camera && btnVisible(item.visibility)) {
        return (
          <VideoButton
            key={item.id}
            item={item}
            localMember={localMember}
            onClick={checkNeedHandsUp}
          />
        )
      } else if (
        item.id === NEMenuIDs.participants &&
        btnVisible(item.visibility)
      ) {
        return (
          <MemberButton
            key={item.id}
            item={item}
            localMember={localMember}
            memberList={memberList}
            onClick={() => {
              setShowMember(!showMember)
            }}
            onClickHandsUpBtn={(status) => {
              setIsShowHandsDownDialog(status)
            }}
          />
        )
      } else if (item.id === NEMenuIDs.chat && btnVisible(item.visibility)) {
        return (
          <ChatButton
            key={item.id}
            unReadCount={unReadCount}
            onClick={onNEChatClick}
            item={item}
          />
        )
      } else {
        return <></>
      }
    },
    [
      toolBarList,
      moreBarList,
      localMember,
      memberList,
      btnVisible,
      checkNeedHandsUp,
      showMember,
      unReadCount,
    ]
  )

  return (
    <>
      {visible && (
        <div
          className={`w-full meeting-controller absolute flex justify-around ${
            className || ''
          }`}
          onClick={(e) => onCardClick(e)}
          ref={meetingControllerRef}
        >
          {toolBarList?.map((item, index) => {
            if (defaultMenusInH5?.some((menu) => menu.id === item.id)) {
              return getBuiltInButtonContent(item)
            } else if (item.id >= CustomButtonIdBoundaryValue) {
              if (btnVisible(item.visibility)) {
                return (
                  <CustomButton
                    key={item.id}
                    customData={item}
                    isSmallBtn={false}
                  />
                )
              } else {
                return <></>
              }
            } else {
              return <></>
            }
          })}
          {/* <div>
          <svg className={`icon ${localMember.isSharingScreen ? 'icon-blue' : 'icon-white'}`} aria-hidden="true">
            <use xlinkHref="#iconyx-tv-sharescreen1x"></use>
          </svg>
          <div onClick={toggleMuteAudio}>{localMember.isSharingScreen ? '取消共享' : '共享屏幕'}</div>
        </div> */}
          {moreBarList && moreBarList?.length > 0 && (
            <Popover
              trigger="click"
              visible={moreBtnVisible}
              mode="dark"
              getContainer={meetingControllerRef.current}
              content={
                <div
                  className="more-controller meeting-controller"
                  onClick={() => {
                    setMoreBtnVisible(false)
                  }}
                >
                  {moreBarList?.map((item) => {
                    if (defaultMenusInH5?.some((menu) => menu.id === item.id)) {
                      return getBuiltInButtonContent(item)
                    } else if (item.id >= CustomButtonIdBoundaryValue) {
                      if (btnVisible(item.visibility)) {
                        return (
                          <CustomButton
                            key={item.id}
                            customData={item}
                            isSmallBtn={false}
                          />
                        )
                      } else {
                        return <></>
                      }
                    } else {
                      return <></>
                    }
                  })}
                </div>
              }
              placement="top-end"
            >
              <div
                className="controller-item"
                onClick={(e) => {
                  e.stopPropagation()
                  setMoreBtnVisible(!moreBtnVisible)
                }}
              >
                <i className="icon-tool iconfont iconyx-tv-more1x"></i>
                {<div className="custom-text">更多</div>}
              </div>
            </Popover>
          )}
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
