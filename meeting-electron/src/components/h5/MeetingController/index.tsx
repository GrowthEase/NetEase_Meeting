import { Badge } from 'antd-mobile/es'
import React, {
  useCallback,
  useContext,
  useEffect,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from 'react'
import { defaultMenusInH5 } from '../../../services'
import { GlobalContext, MeetingInfoContext } from '../../../store'
import {
  ActionType,
  AttendeeOffType,
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
  memberAction,
  Role,
} from '../../../types'
import {
  CustomButtonIdBoundaryValue,
  EventType,
  NEMenuIDs,
  NEMenuVisibility,
  NERoomChatMessage,
} from '../../../types/innerType'
import CustomButton from '../../common/CustomButton'
import Toast from '../../common/toast'
import MeetingNotificationListPopup from '../MeetingNotificationListPopup'
import MemberList from '../MemberList'
import NEChatRoom from '../NEChatRoom'
import Dialog from '../ui/dialog'
import {
  AudioButton,
  ChatButton,
  MemberButton,
  VideoButton,
} from './builtInButton'
import './index.less'
import MoreButtonsPopup from './MoreButtonsPopup'
import useMoreButtons from './MoreButtonsPopup/useMoreButtons'
import { useTranslation } from 'react-i18next'

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
  const { meetingInfo, memberList, dispatch } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { localMember, screenUuid, notificationMessages } = meetingInfo
  const { neMeeting, eventEmitter, toolBarList, moreBarList } =
    useContext<GlobalContextInterface>(GlobalContext)
  const [showMember, setShowMember] = useState(false)
  const [showChatRoom, setShowChatRoom] = useState(false) // 打开聊天室
  const [unReadCount, setUnReadCount] = useState(0) // 聊天室未读消息
  const [receiveMsg, setReceiveMsg] = useState<NERoomChatMessage[]>() // 聊天室未读消息
  const [moreBtnVisible, setMoreBtnVisible] = useState<boolean>(false)
  const [notificationPopupVisible, setNotificationPopupVisible] =
    useState<boolean>(false)
  // const toolBarList = globalConfig?.toolBarList
  // const moreBarList = globalConfig?.moreBarList
  const meetingControllerRef = useRef<HTMLDivElement | null>(null)
  const { t, i18n: i18next } = useTranslation()
  const i18n = {
    moreBtn: t('moreBtn'),
    commonTitle: t('commonTitle'),
  }
  const notificationUnReadCount = notificationMessages.filter(
    (msg) => msg.unRead
  ).length

  const meetingInfoRef = useRef(meetingInfo)
  meetingInfoRef.current = meetingInfo

  const moreButtons = useMoreButtons(onMoreButtonClick)

  function onMoreButtonClick(key: string) {
    if (key === 'notification') {
      setNotificationPopupVisible(true)
    }
  }

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
        meetingInfoRef.current.videoOff === AttendeeOffType.offNotAllowSelfOn &&
        !isHost &&
        !isScreen
      ) {
        // 当前已经在举手中
        if (localMember.isHandsUp) {
          Toast.info(t('handsUpSuccessAlready'))
        } else {
          setIsShowVideoHandsUpDialog(true)
        }
      } else {
        operateLocalVideo(1)
      }
    } else if (type === 'audio') {
      // 当前房间不允许自己打开，非主持人，当前非共享用户
      if (
        meetingInfoRef.current.audioOff === AttendeeOffType.offNotAllowSelfOn &&
        !isHost &&
        !isScreen
      ) {
        if (localMember.isHandsUp) {
          Toast.info(t('handsUpSuccessAlready'))
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
          Toast.info(t('handsUpSuccess'))
        } else {
          Toast.info(t('cancelHandUpSuccess'))
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
          {moreButtons.length > 0 && (
            <div
              className="controller-item"
              onClick={(e) => {
                e.stopPropagation()
                setMoreBtnVisible(!moreBtnVisible)
              }}
            >
              <Badge content={notificationUnReadCount ? Badge.dot : null}>
                <i className="icon-tool iconfont iconyx-tv-more1x"></i>
              </Badge>
              {<div className="custom-text">{i18n.moreBtn}</div>}
            </div>
          )}
        </div>
      )}
      {/* dialog的显示不受visible影响 */}
      <Dialog
        visible={isShowVideoHandsUpDialog}
        title={i18n.commonTitle}
        onCancel={() => {
          setIsShowVideoHandsUpDialog(false)
        }}
        onConfirm={() => {
          handleHandsUp(memberAction.handsUp)
        }}
      >
        <div style={{ color: '#000', fontSize: '13px' }}>
          {t('muteAllVideoHandsUpTips')}
        </div>
      </Dialog>
      <Dialog
        visible={isShowAudioHandsUpDialog}
        title={i18n.commonTitle}
        onCancel={() => {
          setIsShowAudioHandsUpDialog(false)
        }}
        onConfirm={() => {
          handleHandsUp(memberAction.handsUp)
        }}
      >
        <div style={{ color: '#000', fontSize: '13px' }}>
          {t('muteAllAudioHandsUpTips')}
        </div>
      </Dialog>
      <Dialog
        visible={isShowHandsDownDialog}
        title={i18n.commonTitle}
        onCancel={() => {
          setIsShowHandsDownDialog(false)
        }}
        onConfirm={() => {
          handleHandsUp(memberAction.handsDown)
        }}
      >
        <div style={{ color: '#000', fontSize: '13px' }}>
          {t('cancelHandUpTips')}
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
        onPrivateChatClick={() => {
          setShowChatRoom(true)
          // setShowMember(false)
        }}
        onClose={() => {
          setShowMember(false)
        }}
      />
      {/* more buttons */}
      <MoreButtonsPopup
        moreButtons={moreButtons}
        visible={moreBtnVisible}
        onMaskClick={() => {
          setMoreBtnVisible(false)
        }}
        onClose={() => {
          setMoreBtnVisible(false)
        }}
      />
      <MeetingNotificationListPopup
        visible={notificationPopupVisible}
        onMaskClick={() => {
          setNotificationPopupVisible(false)
        }}
        onClose={() => {
          setNotificationPopupVisible(false)
        }}
      />
    </>
  )
}

export default MeetingController
