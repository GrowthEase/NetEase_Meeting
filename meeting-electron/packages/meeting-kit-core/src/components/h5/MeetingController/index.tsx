import { Badge, Modal } from 'antd-mobile/es'
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
  GlobalContext as GlobalContextInterface,
  MeetingInfoContextInterface,
  memberAction,
  Role,
} from '../../../types'
import {
  CustomButtonIdBoundaryValue,
  EventType,
  MeetingErrorCode,
  MeetingSetting,
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
import Interpretation from '../Interpretation'
import { MAJOR_AUDIO, MAJOR_DEFAULT_VOLUME } from '../../../config'
import useCaption from '../../../hooks/useCaption'
import Caption from '../Caption'
import Setting from '../Setting'
import { useUpdateEffect } from 'ahooks'

interface MeetingControllerProps {
  className?: string
  visible?: boolean
  onClick?: (e: React.MouseEvent<HTMLDivElement>) => void
  onRef?: React.RefObject<unknown>
  onSettingChange: (setting: MeetingSetting) => void
}

const MeetingController: React.FC<MeetingControllerProps> = ({
  className = '',
  visible = false,
  onClick,
  onRef,
  onSettingChange,
}) => {
  const { meetingInfo, memberList, dispatch } =
    useContext<MeetingInfoContextInterface>(MeetingInfoContext)
  const { localMember, screenUuid, notificationMessages } = meetingInfo
  const {
    neMeeting,
    eventEmitter,
    toolBarList,
    noChat,
    interpretationSetting,
    dispatch: globalDispatch,
  } = useContext<GlobalContextInterface>(GlobalContext)
  const [showMember, setShowMember] = useState(false)
  const [showChatRoom, setShowChatRoom] = useState(false) // 打开聊天室
  const [showInterpretation, setShowInterpretation] = useState(false) // 打开同传
  const [showSetting, setShowSetting] = useState(false) // 打开设置
  const [unReadCount, setUnReadCount] = useState(0) // 聊天室未读消息
  const [receiveMsg, setReceiveMsg] = useState<NERoomChatMessage[]>() // 聊天室未读消息
  const [moreBtnVisible, setMoreBtnVisible] = useState<boolean>(false)
  const [permissionVisible, setPermissionVisible] = useState<boolean>(false)
  const [notificationPopupVisible, setNotificationPopupVisible] =
    useState<boolean>(false)
  // const toolBarList = globalConfig?.toolBarList
  // const moreBarList = globalConfig?.moreBarList
  const meetingControllerRef = useRef<HTMLDivElement | null>(null)
  const interpretationSettingRef = useRef(interpretationSetting)

  interpretationSettingRef.current = interpretationSetting
  const listeningChannelRef = useRef('')
  const { t } = useTranslation()
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

  const { captionMessageList, enableCaption } = useCaption({
    neMeeting,
    dispatch,
    memberList,
    meetingNum: meetingInfo.meetingNum,
    canShowCaption: meetingInfo.canShowCaption,
  })

  function onMoreButtonClick(key: string) {
    switch (key) {
      case 'notification':
        setNotificationPopupVisible(true)
        break
      case 'interpretation':
        setShowInterpretation(true)
        break
      case 'caption':
        enableCaption(!meetingInfo.isCaptionsEnabled)
        break
      case 'setting':
        setShowSetting(true)
        break
      default:
        break
    }
  }

  // 暴露外部ref能访问的属性
  useImperativeHandle(onRef, () => {
    return {
      checkNeedHandsUp: checkNeedHandsUp,
    }
  })
  const defaultListeningVolume = useMemo(() => {
    const playouOutputtVolume =
      meetingInfo.setting.audioSetting.playouOutputtVolume

    if (playouOutputtVolume !== undefined) {
      return playouOutputtVolume
    } else {
      return 70
    }
  }, [meetingInfo.setting.audioSetting.playouOutputtVolume])

  function handleSwitchToMajorAudio() {
    listeningChannelRef.current &&
      neMeeting?.leaveRtcChannel(listeningChannelRef.current)
    setIsShowInterpretationTip(false)
    globalDispatch?.({
      type: ActionType.UPDATE_GLOBAL_CONFIG,
      data: {
        interpretationSetting: {
          listenLanguage: MAJOR_AUDIO,
          isListenMajor: false,
        },
      },
    })
  }

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
    eventEmitter?.on(EventType.OnInterpreterLeaveAll, (listeningChannel) => {
      listeningChannelRef.current = listeningChannel
      setIsShowInterpretationTip(true)
    })
    return () => {
      eventEmitter?.off(EventType.ReceiveChatroomMessages)
      eventEmitter?.off(EventType.NeedAudioHandsUp)
      eventEmitter?.off(EventType.NeedVideoHandsUp)
      eventEmitter?.off(EventType.CheckNeedHandsUp)
      eventEmitter?.off(EventType.OnInterpreterLeaveAll)
    }
  }, [eventEmitter])
  const [isShowVideoHandsUpDialog, setIsShowVideoHandsUpDialog] =
    useState(false)
  const [isShowInterpretationTip, setIsShowInterpretationTip] = useState(false)
  const [isShowAudioHandsUpDialog, setIsShowAudioHandsUpDialog] =
    useState(false)
  const [isShowHandsDownDialog, setIsShowHandsDownDialog] = useState(false)

  const isScreen = useMemo(() => {
    return !!screenUuid && screenUuid === localMember.uuid
  }, [screenUuid, localMember.uuid])

  const isHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  // 根据角色配置菜单的展示与否
  const btnVisible = useCallback(
    (visibility = 0) => {
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
    },
    [isHost]
  )

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
        !meetingInfoRef.current.unmuteVideoBySelfPermission &&
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
        !meetingInfoRef.current.unmuteAudioBySelfPermission &&
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

  function handleUnmuteAudioOrVideoFailed(error) {
    if (error?.code === MeetingErrorCode.NoPermission) {
      setPermissionVisible(true)
    } else {
      Toast.fail(error?.message)
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
          try {
            await neMeeting?.unmuteLocalAudio()
          } catch (error) {
            handleUnmuteAudioOrVideoFailed(error)
          }

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
          try {
            await neMeeting?.unmuteLocalVideo()
          } catch (error) {
            handleUnmuteAudioOrVideoFailed(error)
          }

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

  function onCardClick(event: React.MouseEvent<HTMLDivElement>) {
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
      } else if (
        item.id === NEMenuIDs.chat &&
        btnVisible(item.visibility) &&
        !noChat
      ) {
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

    [localMember, memberList, showMember, unReadCount, noChat, btnVisible]
  )

  useUpdateEffect(() => {
    if (!meetingInfo.interpretation?.started) {
      setShowInterpretation(false)
      const listenLanguage = interpretationSettingRef.current?.listenLanguage

      if (listenLanguage && listenLanguage !== MAJOR_AUDIO) {
        const channel =
          meetingInfoRef.current.interpretation?.channelNames[listenLanguage]

        channel && neMeeting?.leaveRtcChannel(channel)
      }

      globalDispatch?.({
        type: ActionType.UPDATE_GLOBAL_CONFIG,
        data: {
          interpretationSetting: {
            listenLanguage: MAJOR_AUDIO,
            isListenMajor: false,
          },
        },
      })
      neMeeting?.rtcController?.adjustChannelPlaybackSignalVolume('', 70)
    } else {
      Toast.info(t('interpStartNotification'))
    }
  }, [
    meetingInfo.interpretation?.started,
    t,
    neMeeting?.rtcController,
    globalDispatch,
    neMeeting,
  ])

  function handleHideRemoveLanguageTip() {
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        showLanguageRemovedInfo: {
          show: false,
          language: '',
        },
      },
    })
  }

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
          {toolBarList?.map((item) => {
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
                <svg className="icon-tool icon iconfont" aria-hidden="true">
                  <use xlinkHref="#iconyx-tv-more1x"></use>
                </svg>
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
        visible={!!meetingInfo.showLanguageRemovedInfo?.show}
        title={i18n.commonTitle}
        cancelText={t('gotIt')}
        confirmText={t('globalView')}
        onCancel={() => {
          handleHideRemoveLanguageTip()
        }}
        onConfirm={() => {
          handleHideRemoveLanguageTip()
          setShowInterpretation(true)
        }}
      >
        <div style={{ color: '#000', fontSize: '13px' }}>
          {t('interpLanguageRemoved', {
            language: meetingInfo.showLanguageRemovedInfo?.language,
          })}
        </div>
      </Dialog>
      <Dialog
        visible={isShowInterpretationTip}
        title={i18n.commonTitle}
        cancelText={t('globalCancel')}
        confirmText={t('interpSwitchToMajorAudio')}
        onCancel={() => {
          setIsShowInterpretationTip(false)
        }}
        onConfirm={() => {
          handleSwitchToMajorAudio()
        }}
      >
        <div style={{ color: '#000', fontSize: '13px' }}>
          {t('interpInterpreterOffline')}
        </div>
      </Dialog>
      <Modal
        visible={permissionVisible}
        content={
          <div className="ne-meeting-permission-modal">
            <div className="ne-meeting-permission-title">
              {t('noDevicePermissionTitle')}
            </div>
            <div className="ne-meeting-permission-wrapper">
              <div className="ne-meeting-permission-content">
                {t('noDevicePermissionTipContent')}
              </div>
              <div className="ne-meeting-permission-step">
                {t('noDevicePermissionTipStep1')}
              </div>
              <div className="ne-meeting-permission-step">
                {t('noDevicePermissionTipStep2')}
              </div>
            </div>
          </div>
        }
        closeOnAction
        onClose={() => {
          setPermissionVisible(false)
        }}
        actions={[
          {
            key: 'confirm',
            text: t('gotIt'),
          },
        ]}
      />
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
      {/* 同声传译 */}
      {
        <Interpretation
          defaultMajorVolume={MAJOR_DEFAULT_VOLUME}
          defaultListeningVolume={defaultListeningVolume}
          neMeeting={neMeeting}
          interpretation={meetingInfo.interpretation}
          interpretationSetting={interpretationSetting}
          visible={showInterpretation}
          onClose={() => setShowInterpretation(false)}
          localMember={localMember}
        />
      }
      {(meetingInfo.isCaptionsEnabled || meetingInfo.enableCaptionLoading) &&
        meetingInfo.canShowCaption && (
          <Caption
            className="nemeeting-caption-wrapper"
            captionMessageList={captionMessageList}
            enableCaptionLoading={!!meetingInfo.enableCaptionLoading}
            targetLanguage={meetingInfo.setting.captionSetting.targetLanguage}
            showCaptionBilingual={
              meetingInfo.setting.captionSetting.showCaptionBilingual
            }
            onClick={() => {
              setShowSetting(true)
            }}
          />
        )}
      {/* 设置 */}
      <Setting
        visible={showSetting}
        onClose={() => setShowSetting(false)}
        onSettingChange={onSettingChange}
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
