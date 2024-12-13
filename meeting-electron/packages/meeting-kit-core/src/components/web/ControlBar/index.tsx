import CaretDownOutlined from '@ant-design/icons/CaretDownOutlined'
import CaretUpOutlined from '@ant-design/icons/CaretUpOutlined'
import {
  Badge,
  Button,
  Checkbox,
  Divider,
  Drawer,
  DrawerProps,
  Popover,
  Spin,
} from 'antd'
import classNames from 'classnames'
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import {
  NECommonError,
  NEDeviceBaseInfo,
  NERoomCaptionTranslationLanguage,
  VideoFrameRate,
} from 'neroom-types'
import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../store'
import {
  ActionType,
  EventType,
  hostAction,
  MeetingEventType,
  MeetingSetting,
  memberAction,
  NEClientType,
  NEMenuIDs,
  RecordState,
  Role,
  SecurityCtrlEnum,
  SecurityItem,
  tagNERoomScreenCaptureStatus,
  UserEventType,
  WATERMARK_STRATEGY,
} from '../../../types'
import {
  MoreBarList,
  NEMeetingInfo,
  NEMeetingLeaveType,
  ToolBarList,
} from '../../../types/type'
import {
  checkIsDefaultDevice,
  debounce,
  getDefaultDeviceId,
  getMeetingDisplayId,
  onInjectedMenuItemClick,
} from '../../../utils'
import AudioIcon from '../../common/AudioIcon'
import CommonModal from '../../common/CommonModal'
import Modal from '../../common/Modal'
import Toast from '../../common/toast'
import Network from '../../common/Network'
import './index.less'

import { useMount, useUpdateEffect, usePrevious } from 'ahooks'
import { IPCEvent } from '../../../app/src/types'
import MuteAudioIcon from '../../../assets/mute-audio.png'
import MuteSpeakIcon from '../../../assets/mute-speak.png'
import MuteVideoIcon from '../../../assets/mute-video.png'
import { errorCodeMap } from '../../../config'
import { getWindow } from '../../../utils/windowsProxy'
import UserAvatar from '../../common/Avatar'
import MemberNotify, { MemberNotifyRef } from '../MemberNotify'
import useMeetingPlugin from '../../../hooks/useMeetingPlugin'
import { createDefaultCaptionSetting } from '../../../services'
import useTranslationOptions from '../../../hooks/useTranslationOptions'
import reactStringReplace from 'react-string-replace'
import Emoji from '../../common/Emoji'
import useEmoticonsButton from './Buttons/useEmoticonsButton'
import { EndButton } from './Buttons/EndButton'

type ButtonType = {
  id: number | string
  key: string
  icon: React.ReactNode
  label: string
  onClick: () => void | Promise<void>
  sessionId?: string
  hidden?: boolean
  popover?: (children: React.ReactNode) => React.ReactNode
}

let closeModal

interface ControlBarProps extends DrawerProps {
  controlBarVisibleByMouse?: boolean
  onDefaultButtonClick?: (key: string) => void
  onSettingClick?: (
    type: 'video' | 'audio' | 'normal' | 'beauty' | 'record'
  ) => void
  onDeviceSelectedChange?: (type, deviceIad, isDefault?: boolean) => void
  onSettingChange: (setting: MeetingSetting) => void
}

const ControlBar: React.FC<ControlBarProps> = ({
  open,
  controlBarVisibleByMouse,
  onDefaultButtonClick,
  onSettingClick,
  onDeviceSelectedChange,
  onSettingChange,
  ...restProps
}) => {
  const { waitingRoomInfo } = useWaitingRoomContext()
  const { t, i18n } = useTranslation()
  const {
    meetingInfo,
    memberList,
    inInvitingMemberList,
  } = useMeetingInfoContext()
  const { dispatch: waitingRoomDispatch } = useWaitingRoomContext()
  const {
    neMeeting,
    outEventEmitter,
    eventEmitter,
    logger,
    showCloudRecordMenuItem,
    showCloudRecordingUI,
    globalConfig,
    noCaptions,
    noChat,
    noInvite,
    noTranscription,
    noWhiteboard,
  } = useGlobalContext()
  const { dispatch } = useMeetingInfoContext()
  const localMemberRef = useRef(meetingInfo.localMember)

  const { pluginList, onClickPlugin } = useMeetingPlugin()

  const memberNotifyRef = useRef<MemberNotifyRef>(null)

  const { localMember } = meetingInfo

  localMemberRef.current = meetingInfo.localMember

  // 超出人数限制，不再提示
  const nomoreParticipantUpperLimitTipRef = useRef<boolean>(false)

  const lockButtonClickRef = useRef<Record<string, boolean>>({})
  const handUpModalRef = useRef<{
    destroy: () => void
    update: (configUpdate) => void
  }>()

  const muteTipsNeedShowRef = useRef(0)
  const stopScreenShareClickRef = useRef(false)

  const [securityPopoverOpen, setSecurityPopoverOpen] = useState(false)
  const [moreBtnOpen, setMoreBtnOpen] = useState(false)
  const [audioDeviceListOpen, setAudioDeviceListOpen] = useState(false)
  const [videoDeviceListOpen, setVideoDeviceListOpen] = useState(false)
  const [recordPopoverOpen, setRecordPopoverOpen] = useState(false)
  const [screenSharingPopoverOpen, setScreenSharingPopoverOpen] = useState(
    false
  )
  const [cameras, setCameras] = useState<NEDeviceBaseInfo[]>([])
  const [microphones, setMicrophones] = useState<NEDeviceBaseInfo[]>([])
  const [speakers, setSpeakers] = useState<NEDeviceBaseInfo[]>([])
  const [selectedCamera, setSelectedCamera] = useState<string>()
  const [selectedMicrophone, setSelectedMicrophone] = useState<string>()
  const [selectedSpeaker, setSelectedSpeaker] = useState<string>()
  const [isDarkMode, setIsDarkMode] = useState(true)
  const [handUpPopoverOpen, setHandUpPopoverOpen] = useState(false)
  const [openCaptionPopover, setOpenCaptionPopover] = useState(false)
  const handUpPopoverOpenTimerRef = useRef<null | ReturnType<
    typeof setTimeout
  >>(null)
  const [newMsg, setNewMsg] = useState<{
    fromNick: string
    fromAvatar?: string
    text: string
    type: string
    isPrivate: boolean
    chatroomType: number
  }>()
  const [isAvatarHide, setIsAvatarHide] = useState(false)

  const selectedCameraRef = useRef(selectedCamera)
  const selectedMicrophoneRef = useRef(selectedMicrophone)
  const selectedSpeakerRef = useRef(selectedSpeaker)
  const notAllowJoinRef = useRef(false)
  // 是否进行等候室成加入提示
  const notNotifyRef = useRef(false)

  const leaveTimerRef = useRef<null | ReturnType<typeof setTimeout>>(null)

  selectedCameraRef.current = selectedCamera
  selectedMicrophoneRef.current = selectedMicrophone
  selectedSpeakerRef.current = selectedSpeaker
  const deviceAccessStatusRef = useRef<{
    camera: boolean
    microphone: boolean
  }>({ camera: true, microphone: true })
  const meetingInfoRef = useRef<NEMeetingInfo>(meetingInfo)

  meetingInfoRef.current = meetingInfo

  const isHostOrCoHost = useMemo(() => {
    return localMember.role === Role.host || localMember.role === Role.coHost
  }, [localMember.role])

  const isHost = localMemberRef.current.role === Role.host

  const isHostOrCoHostRef = useRef(isHostOrCoHost)

  const { emoticonsBtn } = useEmoticonsButton(open)

  isHostOrCoHostRef.current = isHostOrCoHost

  const handUpCount = useMemo(() => {
    return memberList.filter((item) => item.isHandsUp).length
  }, [memberList])

  const preHandUpCount = usePrevious(handUpCount)

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])

  const isElectronSharingScreenToolsShow = useMemo(() => {
    if (newMsg) {
      return true
    }

    return controlBarVisibleByMouse
  }, [controlBarVisibleByMouse, newMsg])

  const isElectronSharingScreenToolsShowRef = useRef(
    isElectronSharingScreenToolsShow
  )

  isElectronSharingScreenToolsShowRef.current = isElectronSharingScreenToolsShow

  const toolBarList = useMemo(() => {
    return meetingInfo.toolBarList
      .reduce((unique: ToolBarList, o) => {
        if (!unique.some((obj) => obj.id === o.id)) {
          unique.push(o)
        }

        return unique
      }, [])
      .filter((item) => {
        if (item.id === undefined) {
          return false
        }

        if (item.visibility === undefined || item.visibility === 0) {
          return true
        }

        if (isHostOrCoHost) {
          return item.visibility === 1
        } else {
          return item.visibility === 2
        }
      })
  }, [meetingInfo.toolBarList, isHostOrCoHost])

  const moreBarList = useMemo(() => {
    return meetingInfo.moreBarList
      .reduce((unique: MoreBarList, o) => {
        if (!unique.some((obj) => obj.id === o.id)) {
          unique.push(o)
        }

        return unique
      }, [])
      .filter((item) => {
        if (
          item.id === undefined ||
          item.id === 0 ||
          item.id === 1 ||
          item.id === 26
        ) {
          return false
        }

        if (toolBarList.find((toolBarItem) => toolBarItem.id === item.id)) {
          return false
        }

        if (item.visibility === undefined || item.visibility === 0) {
          return true
        }

        if (isHostOrCoHost) {
          return item.visibility === 1
        } else {
          return item.visibility === 2
        }
      })
  }, [meetingInfo.moreBarList, toolBarList, isHostOrCoHost])

  async function handleAudio() {
    await getDeviceAccessStatus()

    if (!deviceAccessStatusRef.current.microphone && window.isElectronNative) {
      eventEmitter?.emit(MeetingEventType.noMicPermission)
      return
    }

    if (lockButtonClickRef.current['audio']) {
      return
    }

    lockButtonClickRef.current['audio'] = true
    if (!localMember.isAudioConnected) {
      try {
        await neMeeting?.reconnectMyAudio()
        if (
          (!meetingInfo.unmuteAudioBySelfPermission ||
            meetingInfo.audioAllOff) &&
          localMember.isAudioOn &&
          !isHostOrCoHost
        ) {
          Toast.info(t('participantHostMuteAllAudio'))
          neMeeting?.muteLocalAudio()
        }
      } catch (e: unknown) {
        const error = e as NECommonError

        Toast.fail(
          error?.message ||
            error?.msg ||
            t(errorCodeMap[error?.code] || t('connectAudioFailed'))
        )
      }
    } else if (localMember.isAudioOn) {
      try {
        dispatch?.({
          type: ActionType.UPDATE_MEMBER,
          data: {
            uuid: localMember.uuid,
            member: { isAudioOn: false },
          },
        })
        await neMeeting?.muteLocalAudio()
      } catch {
        // Toast.fail(t('muteAudioFail'))
      }
    } else {
      if (!needHandUp('audio')) {
        if (microphones.length <= 0) {
          Toast.fail(t('participantUnMuteAudioFail'))
        } else {
          try {
            await neMeeting?.unmuteLocalAudio()
          } catch (e: unknown) {
            const error = e as NECommonError

            Toast.fail(
              error?.msg ||
                t(errorCodeMap[error?.code] || 'participantUnMuteAudioFail')
            )
          }
        }
      }
    }

    lockButtonClickRef.current['audio'] = false
  }

  async function handleWaitingRoom() {
    // 已开启等候室则关闭
    if (meetingInfo.isWaitingRoomEnabled) {
      if (waitingRoomInfo.memberCount <= 0) {
        try {
          await neMeeting?.waitingRoomController?.disableWaitingRoomOnEntry(
            notAllowJoinRef.current
          )
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              isWaitingRoomEnabled: false,
            },
          })
          Toast.success(t('disabledWaitingRoom'))
        } catch (e: unknown) {
          const error = e as NECommonError

          Toast.fail(error?.msg || error.message)
        }

        return
      }

      setSecurityPopoverOpen(false)
      CommonModal.confirm({
        title: t('closeWaitingRoom'),
        width: 400,
        content: (
          <>
            <div>{t('closeWaitingRoomTip')}</div>
            <Checkbox
              className="close-checkbox-tip"
              defaultChecked={notAllowJoinRef.current}
              onChange={(e) => (notAllowJoinRef.current = e.target.checked)}
              style={{
                marginTop: '10px',
              }}
            >
              {t('waitingRoomDisableDialogAdmitAll')}
            </Checkbox>
          </>
        ),
        okText: t('closeRightRow'),
        onOk: async () => {
          try {
            await neMeeting?.waitingRoomController?.disableWaitingRoomOnEntry(
              notAllowJoinRef.current
            )
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                isWaitingRoomEnabled: false,
              },
            })
            Toast.success(t('disabledWaitingRoom'))
          } catch (err: unknown) {
            const knownError = err as { message: string; msg: string }

            Toast.fail(knownError?.msg || knownError.message)
          }
        },
      })
    } else {
      try {
        await neMeeting?.waitingRoomController?.enableWaitingRoomOnEntry()
        Toast.success(t('enabledWaitingRoom'))
        neMeeting?.waitingRoomController
          ?.getMemberList(0, 20, true)
          .then((res) => {
            waitingRoomDispatch?.({
              type: ActionType.WAITING_ROOM_SET_MEMBER_LIST,
              data: { memberList: res.data },
            })
          })
      } catch (err: unknown) {
        const knownError = err as { message: string; msg: string }

        Toast.fail(knownError?.msg || knownError.message)
      }
    }
  }

  // 开关黑名单
  function enableRoomBlackList(enable) {
    neMeeting?.enableRoomBlackList?.(enable)?.catch((error) => {
      Toast.fail(error.msg || error.message || 'failed')
    })
  }

  // 处理点击开关黑名单
  async function handleEnableBlackList(event) {
    event.stopPropagation()
    // 如果是关闭黑名单需要弹框二次确认
    if (meetingInfo.enableBlacklist) {
      CommonModal.confirm({
        width: 370,
        title: t('unableMeetingBlacklistTitle'),
        content: (
          <>
            <div>{t('unableMeetingBlacklistTip')}</div>
          </>
        ),
        onOk: async () => {
          enableRoomBlackList(false)
        },
      })
      return
    }

    enableRoomBlackList(true)
  }

  // 处理点击开关访客入会
  async function handleEnableGuestJoin(event) {
    event.stopPropagation()
    // 如果是开启需要弹框二次确认
    if (!meetingInfo.enableGuestJoin) {
      CommonModal.confirm({
        key: 'enableGuestJoin',
        width: 370,
        title: t('meetingGuestJoinConfirm'),
        content: (
          <>
            <div>{t('meetingGuestJoinEnableTip')}</div>
          </>
        ),
        onOk: async () => {
          neMeeting?.sendHostControl(hostAction.changeGuestJoin, '', '1')
        },
      })
      return
    }

    neMeeting?.sendHostControl(hostAction.changeGuestJoin, '', '0')
  }

  async function handleVideo() {
    await getDeviceAccessStatus()

    if (!deviceAccessStatusRef.current.camera && window.isElectronNative) {
      eventEmitter?.emit(MeetingEventType.noCameraPermission)

      return
    }

    if (lockButtonClickRef.current['video']) {
      return
    }

    lockButtonClickRef.current['video'] = true

    if (localMember.isVideoOn) {
      try {
        await neMeeting?.muteLocalVideo()
        // 本端断网情况也需要先关闭
      } finally {
        // 加下延迟，否则设置预览的时候预览会有问题
        setTimeout(() => {
          dispatch?.({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: localMember.uuid,
              member: { isVideoOn: false },
            },
          })
        }, 1000)
      }
    } else {
      if (!needHandUp('video')) {
        if (cameras.length <= 0) {
          Toast.fail(t('participantUnMuteVideoFail'))
        } else {
          try {
            await neMeeting?.unmuteLocalVideo()
          } catch (err: unknown) {
            const knownError = err as {
              message: string
              msg: string
              code: number
            }

            logger?.error('unmuteLocalVideo error', knownError)
            if (knownError.code === 50000) {
              neMeeting?.muteLocalVideo()
            } else {
              Toast.fail(
                knownError?.msg ||
                  t(
                    errorCodeMap[knownError?.code] ||
                      'participantUnMuteVideoFail'
                  )
              )
            }
          }
        }
      }
    }

    lockButtonClickRef.current['video'] = false
  }

  const audioBtn = {
    id: 0,
    key: 'audio',
    icon: localMember.isAudioConnected ? (
      localMember.isAudioOn ? (
        <AudioIcon
          className="icon-image"
          dark={!isDarkMode}
          memberId={localMember.uuid}
        />
      ) : (
        <svg
          className={classNames('icon iconfont', {
            'icon-red': !localMember.isAudioOn,
          })}
          aria-hidden="true"
        >
          <use
            xlinkHref={`${
              localMember.isAudioOn
                ? '#iconyx-tv-voice-onx'
                : '#iconyx-tv-voice-offx'
            }`}
          ></use>
        </svg>
      )
    ) : (
      <svg className="icon iconfont icon-red" aria-hidden="true">
        <use xlinkHref="#icondisconnect-audio"></use>
      </svg>
    ),
    label: localMember.isAudioConnected
      ? localMember.isAudioOn
        ? t('participantMute')
        : t('participantUnmute')
      : t('connectAudioShort'),
    onClick: handleAudio,
    hidden: localMember.hide,
  }

  const videoBtn = {
    id: 1,
    key: 'video',
    icon: (
      <svg
        className={classNames('icon iconfont', {
          'icon-red': !localMember.isVideoOn,
        })}
        aria-hidden="true"
      >
        <use
          xlinkHref={`${
            localMember.isVideoOn
              ? '#iconyx-tv-video-onx'
              : '#iconyx-tv-video-offx'
          }`}
        ></use>
      </svg>
    ),
    label: localMember.isVideoOn
      ? t('participantStopVideo')
      : t('participantStartVideo'),
    onClick: handleVideo,
    hidden: localMember.hide,
  }

  useEffect(() => {
    setIsAvatarHide(!!meetingInfo.avatarHide)
  }, [meetingInfo.avatarHide])

  const securityItem = (key: SecurityItem) => {
    let action: SecurityCtrlEnum

    let permission = !meetingInfo[key]

    switch (key) {
      case SecurityItem.screenSharePermission:
        action = SecurityCtrlEnum.SCREEN_SHARE_DISABLE
        permission = !!meetingInfo[key]
        break
      case SecurityItem.unmuteAudioBySelfPermission:
        action = SecurityCtrlEnum.AUDIO_NOT_ALLOW_SELF_ON
        permission = !!meetingInfo[key]
        break
      case SecurityItem.unmuteVideoBySelfPermission:
        action = SecurityCtrlEnum.VIDEO_NOT_ALLOW_SELF_ON
        permission = !!meetingInfo[key]
        break
      case SecurityItem.updateNicknamePermission:
        action = SecurityCtrlEnum.EDIT_NAME_DISABLE
        permission = !!meetingInfo[key]
        break
      case SecurityItem.whiteboardPermission:
        action = SecurityCtrlEnum.WHILE_BOARD_SHARE_DISABLE
        permission = !!meetingInfo[key]
        break
      case SecurityItem.annotationPermission:
        action = SecurityCtrlEnum.ANNOTATION_DISABLE
        permission = !!meetingInfo[key]
        break
    }

    const titleMap = {
      [SecurityItem.screenSharePermission]: t('screenShare'),
      [SecurityItem.unmuteAudioBySelfPermission]: t('unmuteAudioBySelf'),
      [SecurityItem.unmuteVideoBySelfPermission]: t('participantStartVideo'),
      [SecurityItem.updateNicknamePermission]: t('updateNicknameBySelf'),
      [SecurityItem.whiteboardPermission]: t('whiteboardShare'),
      [SecurityItem.annotationPermission]: t('annotation'),
    }

    return (
      <div
        className="device-item"
        key={key}
        onClick={(event) => {
          event.stopPropagation()

          neMeeting
            ?.securityControl({
              [action]: permission,
            })
            .catch((e) => {
              Toast.fail(e.msg || e.message)
            })
        }}
      >
        <div className="device-item-label">{titleMap[key]}</div>
        {!!meetingInfo[key] && (
          <svg
            className="icon iconfont iconcheck-line-regular1x-blue"
            aria-hidden="true"
          >
            <use xlinkHref="#iconcheck-line-regular1x"></use>
          </svg>
        )}
      </div>
    )
  }

  const stopMemberActivities = () => {
    setSecurityPopoverOpen(false)
    CommonModal.confirm({
      title: t('stopMemberActivitiesTitle'),
      content: t('stopMemberActivitiesTip'),
      okText: t('stopText'),
      onOk: () => {
        neMeeting?.stopMemberActivities()
      },
    })
  }

  const changeAvatarStatus = (status: boolean) => {
    neMeeting
      ?.securityControl({
        [SecurityCtrlEnum.AVATAR_HIDE]: status,
      })
      .then(() => {
        if (status) {
          Toast.success(t('hostSetAvatarHide'))
        }
      })
      .catch((error) => {
        Toast.fail(t('settingUpdateFailed'))
        throw error
      })
  }

  const securityBtn = {
    id: 26,
    key: 'security',
    popover: (children) => {
      return (
        <Popover
          destroyTooltipOnHide
          align={
            isElectronSharingScreen ? { offset: [0, 5] } : { offset: [0, -5] }
          }
          arrow={false}
          trigger={['click']}
          rootClassName="security-popover device-popover"
          open={securityPopoverOpen}
          getTooltipContainer={(node) => node}
          onOpenChange={(open) => {
            setSecurityPopoverOpen(open)
          }}
          autoAdjustOverflow={false}
          placement={isElectronSharingScreen ? 'bottom' : 'top'}
          content={
            <>
              <div className="device-list">
                <div className="device-list-title">{t('securitySettings')}</div>
                {globalConfig?.appConfig?.APP_ROOM_RESOURCE?.waitingRoom && (
                  <>
                    <div
                      className="device-item"
                      key="waitingRoom"
                      onClick={(event) => {
                        event.stopPropagation()
                        handleWaitingRoom()
                      }}
                    >
                      <div className="device-item-label">
                        {t('waitingRoom')}
                      </div>
                      {meetingInfo.isWaitingRoomEnabled && (
                        <svg
                          className="icon iconfont iconcheck-line-regular1x-blue"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconcheck-line-regular1x"></use>
                        </svg>
                      )}
                    </div>
                  </>
                )}
                {meetingInfo.watermark?.videoStrategy ===
                WATERMARK_STRATEGY.FORCE_OPEN ? null : (
                  <div
                    className="device-item"
                    key="meetingWatermark"
                    onClick={(event) => {
                      event.stopPropagation()
                      const enable =
                        meetingInfo.watermark?.videoStrategy ===
                        WATERMARK_STRATEGY.OPEN
                      const type = enable
                        ? hostAction.closeWatermark
                        : hostAction.openWatermark

                      neMeeting?.sendHostControl(type, '')
                    }}
                  >
                    <div className="device-item-label">
                      {t('meetingWatermark')}
                    </div>
                    {meetingInfo.watermark?.videoStrategy ===
                      WATERMARK_STRATEGY.OPEN && (
                      <svg
                        className="icon iconfont iconcheck-line-regular1x-blue"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#iconcheck-line-regular1x"></use>
                      </svg>
                    )}
                  </div>
                )}
                <div
                  className="device-item"
                  key="lockMeeting"
                  onClick={(event) => {
                    event.stopPropagation()
                    const enable = !meetingInfo.isLocked
                    const type = enable
                      ? hostAction.lockMeeting
                      : hostAction.unlockMeeting
                    const failMsg = enable
                      ? t('meetingLockMeetingByHostFail')
                      : t('meetingUnLockMeetingByHostFail')

                    neMeeting
                      ?.sendHostControl(type, '')
                      .then(() => {
                        // 通过判断 meetingInfo.isLocked  来显示
                        // Toast.success(successMsg)
                      })
                      .catch((error) => {
                        Toast.fail(failMsg)
                        throw error
                      })
                  }}
                >
                  <div className="device-item-label">{t('meetingLock')}</div>
                  {meetingInfo.isLocked && (
                    <svg
                      className="icon iconfont iconcheck-line-regular1x-blue"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                    </svg>
                  )}
                </div>
                <div
                  className="device-item"
                  key="blackList"
                  onClick={handleEnableBlackList}
                >
                  <div className="device-item-label">
                    {t('meetingBlacklist')}
                    <Popover content={t('meetingBlacklistTip')}>
                      <svg
                        className="icon iconfont icona-45 nemeeting-blacklist-tip"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#icona-45"></use>
                      </svg>
                    </Popover>
                  </div>

                  {meetingInfo.enableBlacklist && (
                    <svg
                      className="icon iconfont iconcheck-line-regular1x-blue"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                    </svg>
                  )}
                </div>
                {globalConfig?.appConfig.APP_ROOM_RESOURCE.guest ? (
                  <div
                    className="device-item"
                    key="guestJoin"
                    onClick={handleEnableGuestJoin}
                  >
                    <div className="device-item-label">
                      {t('meetingGuestJoin')}
                      <Popover content={t('meetingGuestJoinEnableTip')}>
                        <svg
                          className="icon iconfont icona-45 nemeeting-blacklist-tip"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#icona-45"></use>
                        </svg>
                      </Popover>
                    </div>

                    {meetingInfo.enableGuestJoin && (
                      <svg
                        className="icon iconfont iconcheck-line-regular1x-blue"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#iconcheck-line-regular1x"></use>
                      </svg>
                    )}
                  </div>
                ) : null}
                <div
                  className="device-item"
                  key="avatar-hide"
                  onClick={(event) => {
                    event.stopPropagation()
                    changeAvatarStatus(!isAvatarHide)
                  }}
                >
                  <div className="device-item-label">{t('avatarHide')}</div>
                  {isAvatarHide && (
                    <svg
                      className="icon iconfont iconcheck-line-regular1x-blue"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                    </svg>
                  )}
                </div>
              </div>
              <div className="device-list">
                <div className="device-list-title">
                  {t('meetingAllowMembersTo')}
                </div>
                {globalConfig?.appConfig.APP_ROOM_RESOURCE.chatroom && (
                  <div
                    className="device-item"
                    key="meetingChat"
                    onClick={(event) => {
                      event.stopPropagation()
                      const chatPermission =
                        meetingInfo.meetingChatPermission !== 4 ? 4 : 1

                      neMeeting
                        ?.sendHostControl(
                          hostAction.changeChatPermission,
                          '',
                          chatPermission
                        )
                        .then(() => {
                          if (chatPermission === 4) {
                            Toast.info(t('meetingChatDisabled'))
                          } else {
                            Toast.success(t('meetingChatEnabled'))
                          }
                        })
                        .catch((error) => {
                          throw error
                        })
                    }}
                  >
                    <div className="device-item-label">{t('meetingChat')}</div>
                    {meetingInfo.meetingChatPermission !== 4 && (
                      <svg
                        className="icon iconfont iconcheck-line-regular1x-blue"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#iconcheck-line-regular1x"></use>
                      </svg>
                    )}
                  </div>
                )}
                {securityItem(SecurityItem.screenSharePermission)}
                {securityItem(SecurityItem.unmuteAudioBySelfPermission)}
                {securityItem(SecurityItem.unmuteVideoBySelfPermission)}
                {securityItem(SecurityItem.updateNicknamePermission)}
                {securityItem(SecurityItem.whiteboardPermission)}
                {globalConfig?.appConfig.APP_ROOM_RESOURCE.annotation &&
                  securityItem(SecurityItem.annotationPermission)}
              </div>
              <div
                onClick={stopMemberActivities}
                className="device-list-title suspend-participant-activity-title"
                style={{
                  color: '#f51d45',
                }}
              >
                {t('stopMemberActivities')}
              </div>
            </>
          }
        >
          {children}
        </Popover>
      )
    },
    icon: (
      <div>
        <svg className={classNames('icon iconfont')} aria-hidden="true">
          <use xlinkHref="#iconanquan"></use>
        </svg>
      </div>
    ),
    label: t('security'),
    onClick: () => {
      setSecurityPopoverOpen(!securityPopoverOpen)
    },
    hidden: localMember.hide || !isHostOrCoHost,
  }

  const screenShareBtn = {
    id: 2,
    key: 'screenShare',
    icon: (
      <svg
        className={classNames('icon iconfont', {
          'icon-blue': localMember.isSharingScreen,
        })}
        aria-hidden="true"
      >
        <use xlinkHref="#iconyx-tv-sharescreen1x"></use>
      </svg>
    ),
    label: !localMember.isSharingScreen
      ? t('screenShare')
      : t('screenShareStop'),
    onClick: () => {
      // 判断此时是否正在共享屏幕
      if (!localMember.isSharingScreen) {
        if (
          globalConfig?.appConfig?.APP_ROOM_RESOURCE?.screenShare?.enable ==
          false
        ) {
          CommonModal.confirm({
            title: t('screenShare'),
            icon: null, // 设置为null以隐藏图标
            footer: null, // 禁用默认底部按钮
            onOk() {
              Modal.destroyAll()
              CommonModal.destroyAll()
            },
            cancelButtonProps: { style: { display: 'none' } }, // 隐藏取消按钮
            content: (
              <div>
                <div>
                  {globalConfig?.appConfig?.APP_ROOM_RESOURCE?.screenShare
                    ?.message || t('screenShareDisabledWarning')}
                </div>
                <Button
                  style={{
                    margin: '20px',
                  }}
                  type="primary"
                  onClick={() => {
                    Modal.destroyAll()
                    CommonModal.destroyAll()
                  }}
                >
                  {t('IkonwIt')}
                </Button>
              </div>
            ),
          })
        } else {
          CommonModal.confirm({
            title: t('screenShare'),
            okText: t('yes'),
            cancelText: t('no'),
            content: (
              <div>
                {globalConfig?.appConfig?.APP_ROOM_RESOURCE?.screenShare
                  ?.message || t('screenShareWarning')}
              </div>
            ),
            onOk: () => {
              shareScreen()
            },
          })
        }
      } else {
        shareScreen()
      }
    },
    hidden: localMember.hide || isElectronSharingScreen,
  }

  const handleStopWhiteboard = async () => {
    try {
      await neMeeting?.whiteboardController?.stopWhiteboardShare()
      if (window.isElectronNative && meetingInfo.enableTransparentWhiteboard) {
        window.ipcRenderer
          ?.invoke(IPCEvent.whiteboardTransparentMirror, false)
          .catch((e) => {
            console.log('whiteboardTransparentMirror failed', e)
          })
      }

      neMeeting?.roomContext?.deleteRoomProperty('whiteboardConfig')
    } catch {
      Toast.fail(t('whiteBoardShareStopFail'))
    }
  }

  const whiteBoardBtn = {
    id: 22,
    key: 'whiteBoard',
    icon: (
      <svg
        className={classNames('icon iconfont', {
          'icon-blue': localMember.isSharingWhiteboard,
        })}
        aria-hidden="true"
      >
        <use xlinkHref="#iconyx-baiban"></use>
      </svg>
    ),
    label: !localMember.isSharingWhiteboard
      ? t('whiteboardShare')
      : t('whiteBoardClose'),
    onClick: async () => {
      if (lockButtonClickRef.current['whiteBoard']) {
        return
      }

      lockButtonClickRef.current['whiteBoard'] = true
      if (localMember.isSharingWhiteboard) {
        handleStopWhiteboard()
      } else {
        if (!meetingInfo.whiteboardPermission && !isHostOrCoHost) {
          Toast.fail(t('shareNoPermission'))
          lockButtonClickRef.current['whiteBoard'] = false
          return
        }

        if (meetingInfo.whiteboardUuid) {
          Toast.info(t('screenShareNotAllow'))
        } else if (
          meetingInfo.screenUuid ||
          meetingInfoRef.current.systemAudioUuid
        ) {
          Toast.info(t('meetingHasScreenShareShare'))
        } else {
          try {
            // 如果开启透明白板则先更新房间属性
            await neMeeting?.roomContext?.updateRoomProperty(
              'whiteboardConfig',
              JSON.stringify({
                isTransparent: meetingInfo.enableTransparentWhiteboard,
              })
            )
            await neMeeting?.whiteboardController?.startWhiteboardShare()
            if (
              window.isElectronNative &&
              meetingInfo.enableTransparentWhiteboard
            ) {
              window.ipcRenderer
                ?.invoke(IPCEvent.whiteboardTransparentMirror, true)
                .catch((e) => {
                  console.log('whiteboardTransparentMirror failed', e)
                })
            }

            // 防止多人同时操作时使用了他人设置的不透明白板
            await neMeeting?.roomContext?.updateRoomProperty(
              'whiteboardConfig',
              JSON.stringify({
                isTransparent: meetingInfo.enableTransparentWhiteboard,
              })
            )
          } catch (e: unknown) {
            const error = e as NECommonError

            if (error && error.code === 1006) {
              Toast.fail(t('functionalityLimitedByTheNumberOfPeople'))
            } else {
              Toast.fail(t('whiteBoardShareStartFail'))
            }
          }
        }
      }

      lockButtonClickRef.current['whiteBoard'] = false
    },
    hidden:
      localMember.hide ||
      isElectronSharingScreen ||
      noWhiteboard ||
      !globalConfig?.appConfig.APP_ROOM_RESOURCE.whiteboard,
  }

  const memberListBtn = {
    id: 3,
    key: 'memberList',
    popover: (children) => {
      return (
        <Popover
          destroyTooltipOnHide
          align={
            isElectronSharingScreen ? { offset: [0, 7] } : { offset: [0, -7] }
          }
          placement={isElectronSharingScreen ? 'bottom' : 'top'}
          autoAdjustOverflow={false}
          getTooltipContainer={(node) => node}
          open={handUpPopoverOpen && isHostOrCoHost && handUpCount > 0}
          rootClassName="host-hands-up-popover"
          arrow={false}
          content={
            <div
              className="hands-down-content"
              onClick={() => {
                onDefaultButtonClick?.('memberList')
              }}
            >
              <Emoji type={2} size={32} emojiKey="[举手]" />
              {t('handsUpCount', { count: handUpCount })}
            </div>
          }
        >
          {children}
        </Popover>
      )
    },
    icon: (
      <>
        <svg className="icon icon-tool iconfont" aria-hidden="true">
          <use xlinkHref="#iconyx-tv-attendeex"></use>
        </svg>
        {!!waitingRoomInfo.unReadMsgCount && !!waitingRoomInfo.memberCount && (
          <span className="waiting-room-unread-count-label"></span>
        )}
        <span className="member-list-count-label">
          {isHostOrCoHost
            ? memberList.length + waitingRoomInfo.memberCount
            : memberList.length}
        </span>
      </>
    ),
    label: isHostOrCoHost
      ? t('memberListBtnForHost')
      : t('memberListBtnForNormal'),
    onClick: debounce(() => {
      onDefaultButtonClick?.('memberList')
    }, 300),
    hidden: localMember.hide,
  }

  const recordBtn = {
    id: 27,
    key: 'record',
    icon: (
      <svg
        className={classNames('icon iconfont', {
          'icon-red': meetingInfo.isCloudRecording,
        })}
        aria-hidden="true"
      >
        <use
          xlinkHref={`${
            meetingInfo.isCloudRecording
              ? '#icontingzhiluzhi'
              : '#iconluzhizhong'
          }`}
        ></use>
      </svg>
    ),
    onClick: async () => {
      onDefaultButtonClick?.('record')
    },
    hidden: !(
      showCloudRecordMenuItem &&
      globalConfig?.appConfig?.APP_ROOM_RESOURCE.record &&
      isHostOrCoHostRef.current
    ),
    label: meetingInfo.isCloudRecording
      ? t('stopCloudRecord')
      : t('startCloudRecord'),
  }

  function newMsgsContent() {
    if (!newMsg) {
      return null
    }

    const { chatroomType, fromNick, isPrivate, fromAvatar } = newMsg
    let nickLabel

    if (isPrivate) {
      if (newMsg.chatroomType === 1) {
        nickLabel = (
          <>
            <span className={`new-message-name-text`}>{fromNick}</span>
            <span className={`new-message-name-private`}>
              &nbsp;{t('chatSaidToMe', { userName: '' })}
            </span>
            <span className="new-message-name-private-tips">
              ({t('chatPrivateInWaitingRoom')})
            </span>
          </>
        )
      } else {
        nickLabel = (
          <>
            <span className={`new-message-name-text`}>{fromNick}</span>
            <span className={`new-message-name-private`}>
              &nbsp;{t('chatSaidToMe', { userName: '' })}
            </span>
            <span className="new-message-name-private-tips">
              ({t('chatPrivate')})
            </span>
          </>
        )
      }
    } else {
      if (chatroomType === 1) {
        nickLabel = (
          <>
            <span className={`new-message-name-text`}>{fromNick}</span>
            <span className={`new-message-name-private`}>
              &nbsp;{t('chatSaidToWaitingRoom', { userName: '' })}
            </span>
          </>
        )
      } else {
        nickLabel = fromNick
      }
    }

    return (
      <div className="new-message-content">
        <div className="new-message-avatar">
          <UserAvatar
            size={32}
            nickname={fromNick || ''}
            avatar={fromAvatar || ''}
          />
        </div>
        <div>
          <div className="new-message-name"> {nickLabel}</div>
          {newMsg?.type === 'image' && (
            <div className="new-message-text">{t('imageMsg')}</div>
          )}
          {newMsg?.type === 'file' && (
            <div className="new-message-text">{t('fileMsg')}</div>
          )}
          {newMsg?.type === 'text' && (
            <div className="new-message-text">
              {reactStringReplace(newMsg.text, /(\[.*?\])/gi, (match, i) => {
                return <Emoji key={i} emojiKey={match} size={20} />
              })}
            </div>
          )}
        </div>
      </div>
    )
  }

  const chatBtn = {
    id: 21,
    key: 'chat',
    icon: (
      <Popover
        destroyTooltipOnHide
        align={
          isElectronSharingScreen ? { offset: [0, 35] } : { offset: [0, -15] }
        }
        open={!!newMsg && !meetingInfo.isRooms}
        placement={isElectronSharingScreen ? 'bottom' : 'top'}
        autoAdjustOverflow={false}
        getTooltipContainer={(node) => node}
        rootClassName="new-message-popover"
        arrow={false}
        content={newMsgsContent()}
      >
        <svg className="icon iconfont" aria-hidden="true">
          <use xlinkHref="#iconchat1x"></use>
        </svg>
        {!!meetingInfo.unReadChatroomMsgCount && (
          <span className="chat-unread-count-label">
            {meetingInfo.unReadChatroomMsgCount &&
            meetingInfo.unReadChatroomMsgCount > 99
              ? '99+'
              : meetingInfo.unReadChatroomMsgCount}
          </span>
        )}
      </Popover>
    ),
    label: t('chat'),
    onClick: debounce(async () => {
      setNewMsg(undefined)
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          unReadChatroomMsgCount: 0,
        },
      })
      onDefaultButtonClick?.('chatroom')
    }, 300),
    hidden: localMember.hide || !meetingInfo.isSupportChatroom || noChat,
  }

  const inviteBtn = {
    id: 20,
    key: 'invite',
    icon: (
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref="#iconyx-tv-invitex"></use>
      </svg>
    ),
    label: t('inviteBtn'),
    onClick: async () => {
      onDefaultButtonClick?.('invite')
    },
    hidden: localMember.hide || noInvite,
  }

  const notificationBtn = {
    id: 29,
    key: 'notification',
    icon: (
      <Badge
        count={
          meetingInfo.notificationMessages.filter((msg) => msg.unRead).length >
          99
            ? '99+'
            : meetingInfo.notificationMessages.filter((msg) => msg.unRead)
                .length
        }
      >
        <svg className="icon iconfont" aria-hidden="true">
          <use xlinkHref="#icontongzhizhongxinrukou"></use>
        </svg>
      </Badge>
    ),
    label: t('notification'),
    onClick: async () => {
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          notificationMessages: meetingInfo.notificationMessages.map((msg) => {
            return { ...msg, unRead: false }
          }),
        },
      })
      onDefaultButtonClick?.('notification')
    },
    hidden: localMember.hide || meetingInfo.noNotifyCenter === true,
  }

  const liveBtn = {
    id: 25,
    key: 'live',
    icon: (
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref="#iconlive-f"></use>
      </svg>
    ),
    label: t('live'),
    onClick: async () => {
      onDefaultButtonClick?.('live')
    },
    hidden: !(neMeeting?.liveController?.isSupported && isHostOrCoHost),
  }

  const settingBtn = {
    id: 28,
    key: 'setting',
    icon: (
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref="#iconyx-tv-settingx1"></use>
      </svg>
    ),
    label: t('settings'),
    onClick: async () => {
      onSettingClick?.('normal')
    },
    hidden: localMember.hide || isElectronSharingScreen,
  }

  // 同声传译
  const interpretationBtn = {
    id: 31,
    key: 'interpretation',
    icon: (
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref="#icontongshengchuanyi"></use>
      </svg>
    ),
    label: t('interpretation'),
    onClick: async () => {
      onDefaultButtonClick?.('interpretation')
    },
    hidden: !(
      globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation?.enable &&
      (isHostOrCoHost || meetingInfo.interpretation?.started)
    ),
  }

  const { translationMap, translationOptions } = useTranslationOptions()

  const targetTranslationLanguage = useMemo(() => {
    return meetingInfo.setting.captionSetting?.targetLanguage
  }, [meetingInfo.setting.captionSetting?.targetLanguage])

  const onCaptionShowBilingual = useCallback(
    (enable: boolean) => {
      const setting = meetingInfoRef.current.setting

      if (!setting.captionSetting) {
        setting.captionSetting = createDefaultCaptionSetting()
      } else {
        setting.captionSetting.showCaptionBilingual = enable
      }

      onSettingChange(setting)
    },
    [onSettingChange]
  )

  const onTargetLanguageChange = useCallback(
    (lang: NERoomCaptionTranslationLanguage) => {
      const setting = meetingInfoRef.current.setting

      if (!setting.captionSetting) {
        setting.captionSetting = createDefaultCaptionSetting()
      } else {
        setting.captionSetting.targetLanguage = lang
      }

      onSettingChange(setting)
    },
    []
  )

  const translationOptionsContent = useMemo(() => {
    return (
      <div
        onClick={(e) => {
          e.stopPropagation()
          e.preventDefault()
        }}
      >
        {translationOptions.map((item) => {
          return (
            <div
              key={item.value}
              className="nemeeting-caption-enable-member-wrapper"
              onClick={(e) => {
                e.stopPropagation()
                e.preventDefault()
                if (item.value === targetTranslationLanguage) {
                  return
                }

                setOpenCaptionPopover(false)
                onTargetLanguageChange(item.value)
              }}
            >
              <div>{item.label}</div>
              {item.value == targetTranslationLanguage && (
                <svg
                  className="icon iconfont"
                  aria-hidden="true"
                  style={{ color: '#337EFF' }}
                >
                  <use xlinkHref="#iconcheck-line-regular1x"></use>
                </svg>
              )}
            </div>
          )
        })}
      </div>
    )
  }, [translationOptions, targetTranslationLanguage, onTargetLanguageChange])
  const enableMemberContent = useMemo(() => {
    return (
      <>
        <Popover
          arrow={false}
          rootClassName={'nemeeting-web-caption-translation-options-pop'}
          content={translationOptionsContent}
          title={null}
          trigger="hover"
          placement="right"
        >
          <div className="nemeeting-caption-enable-member-wrapper">
            <div>
              {translationMap[targetTranslationLanguage || ''] ||
                t('transcriptionNotTranslated')}
            </div>
            <svg
              className="icon iconfont"
              aria-hidden="true"
              style={{ fontSize: '14px' }}
            >
              <use xlinkHref="#iconyx-allowx"></use>
            </svg>
          </div>
        </Popover>
        <div className="nemeeting-caption-translation-border"></div>
        <div
          className="nemeeting-caption-enable-member-wrapper"
          onClick={(e) => {
            e.stopPropagation()
            e.preventDefault()
            onCaptionShowBilingual(
              !meetingInfoRef.current.setting.captionSetting
                ?.showCaptionBilingual
            )
            setOpenCaptionPopover(false)
          }}
        >
          <div>{t('transcriptionShowBilingual')}</div>
          {meetingInfo.setting.captionSetting?.showCaptionBilingual && (
            <svg
              className="icon iconfont iconcheck-line-regular1x-blue"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          )}
        </div>
        {isHostOrCoHost && (
          <>
            <div className="nemeeting-caption-translation-border"></div>
            <div className="nemeeting-caption-translation-pop-title">
              {t('meetingAllowMembersTo')}
            </div>
            <div
              className="nemeeting-caption-enable-member-wrapper"
              onClick={(e) => {
                e.stopPropagation()
                e.preventDefault()
                neMeeting?.allowParticipantsEnableCaption(
                  !meetingInfoRef.current.isAllowParticipantsEnableCaption
                )
                setOpenCaptionPopover(false)
              }}
            >
              <div>{t('transcriptionAllowEnableCaption')}</div>
              {meetingInfo.isAllowParticipantsEnableCaption && (
                <svg
                  className="icon iconfont iconcheck-line-regular1x-blue"
                  aria-hidden="true"
                >
                  <use xlinkHref="#iconcheck-line-regular1x"></use>
                </svg>
              )}
            </div>
          </>
        )}
      </>
    )
  }, [
    t,
    meetingInfo.isAllowParticipantsEnableCaption,
    meetingInfo.setting.captionSetting?.showCaptionBilingual,
    neMeeting,
    translationMap,
    targetTranslationLanguage,
    isHostOrCoHost,
  ])
  // 字幕
  const captionBtn = {
    id: 32,
    key: 'caption',
    icon: (
      <div className="nemeeting-more-caption">
        <svg className="icon iconfont" aria-hidden="true">
          <use xlinkHref="#iconzimu"></use>
        </svg>
        <Popover
          open={openCaptionPopover}
          onOpenChange={(open) => setOpenCaptionPopover(open)}
          arrow={false}
          rootClassName={'nemeeting-web-caption-size-pop'}
          content={enableMemberContent}
          placement={isElectronSharingScreen ? 'bottom' : 'top'}
          title={t('transcriptionTargetLang')}
          trigger="click"
        >
          <div
            className="nemeeting-more-caption-arrow"
            onClick={(e) => e.stopPropagation()}
          >
            {isElectronSharingScreen ? (
              <CaretDownOutlined />
            ) : (
              <CaretUpOutlined />
            )}
          </div>
        </Popover>
      </div>
    ),
    label: meetingInfo.isCaptionsEnabled
      ? t('transcriptionDisableCaption')
      : t('transcriptionEnableCaption'),
    onClick: async () => {
      onDefaultButtonClick?.('caption')
    },
    hidden: !globalConfig?.appConfig.APP_ROOM_RESOURCE.caption || noCaptions,
  }

  // 转写
  const transcriptionBtn = {
    id: 33,
    key: 'transcription',
    icon: (
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref="#iconzhuanxie"></use>
      </svg>
    ),
    label: t('transcription'),
    onClick: () => {
      onDefaultButtonClick?.('transcription')
    },
    hidden:
      !globalConfig?.appConfig.APP_ROOM_RESOURCE.transcript || noTranscription,
  }

  const feedbackBtn = {
    id: NEMenuIDs.feedback,
    key: 'feedback',
    icon: (
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref="#iconwentifankui"></use>
      </svg>
    ),
    label: t('feedback'),
    onClick: () => {
      onDefaultButtonClick?.('feedback')
    },
    hidden: false,
  }

  const isAnnotationBtnShow = useMemo(() => {
    if (meetingInfo.screenUuid) {
      const screenMember = memberList.find(
        (item) => item.uuid === meetingInfo.screenUuid
      )

      if (
        screenMember?.clientType === NEClientType.MAC ||
        screenMember?.clientType === NEClientType.PC
      ) {
        if (
          meetingInfo.annotationPermission ||
          localMember.isSharingScreen ||
          isHostOrCoHost
        ) {
          return true
        }
      }
    }

    return false
  }, [
    meetingInfo.annotationEnabled,
    meetingInfo.screenUuid,
    meetingInfo.annotationPermission,
    localMember.isSharingScreen,
    memberList,
    isHostOrCoHost,
  ])

  const annotationBtn = {
    id: NEMenuIDs.annotation,
    key: 'annotation',
    icon: (
      <Spin spinning={!meetingInfo.annotationEnabled}>
        <svg
          className={classNames('icon iconfont', {
            ['icon-blue']: meetingInfoRef.current.annotationDrawEnabled,
          })}
          aria-hidden="true"
        >
          <use xlinkHref="#iconpizhu"></use>
        </svg>
      </Spin>
    ),
    label: meetingInfoRef.current.annotationDrawEnabled
      ? t('stopAnnotation')
      : t('startAnnotation'),
    onClick: async () => {
      if (!meetingInfo.annotationEnabled) {
        return
      }

      const annotationDrawEnabled = meetingInfoRef.current.annotationDrawEnabled

      const enable = !annotationDrawEnabled

      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
        method: enable ? 'startAnnotation' : 'stopAnnotation',
      })

      neMeeting?.setAnnotationEnableDraw(!annotationDrawEnabled)
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          annotationDrawEnabled: !annotationDrawEnabled,
        },
      })
    },
    hidden: localMember.hide || !isAnnotationBtnShow,
  }

  useEffect(() => {
    if (!isAnnotationBtnShow) {
      neMeeting?.setAnnotationEnableDraw(false)
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          annotationDrawEnabled: false,
        },
      })
    }
  }, [isAnnotationBtnShow, neMeeting])

  let moreButtons: ButtonType[] = []

  if (moreBarList.length > 0) {
    moreBarList.forEach((item) => {
      // 在屏幕共享下，过滤更多菜单的按钮
      if (isElectronSharingScreen) {
        if (![3, 21, 20, 29, 30, 31, 32, 33, 34].includes(item.id)) {
          return
        }
      }

      let btn = {
        [screenShareBtn.id]: screenShareBtn,
        [memberListBtn.id]: memberListBtn,
        [chatBtn.id]: chatBtn,
        [inviteBtn.id]: inviteBtn,
        [whiteBoardBtn.id]: whiteBoardBtn,
        [recordBtn.id]: recordBtn,
        [settingBtn.id]: settingBtn,
        [liveBtn.id]: liveBtn,
        [notificationBtn.id]: notificationBtn,
        [annotationBtn.id]: annotationBtn,
        [captionBtn.id]: captionBtn,
        [transcriptionBtn.id]: transcriptionBtn,
        [interpretationBtn.id]: interpretationBtn,
        [feedbackBtn.id]: feedbackBtn,
      }[item.id]

      // 用来更新按钮状态
      const proxyItem = new Proxy(item, {
        get: function (target, propKey, receiver) {
          return Reflect.get(target, propKey, receiver)
        },
        set: function (target, propKey, value, receiver) {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              moreBarList: [...moreBarList],
            },
          })
          return Reflect.set(target, propKey, value, receiver)
        },
      })

      let btnConfig

      if (Array.isArray(item.btnConfig)) {
        btnConfig = item.btnConfig.find((btn) => {
          return btn.status === item.btnStatus
        })
      } else {
        btnConfig = item.btnConfig
      }

      if (btnConfig) {
        if (btn) {
          btn.icon = (
            <img
              src={
                isDarkMode
                  ? btnConfig.icon
                  : btnConfig.lightIcon || btnConfig.icon
              }
              className="icon-image"
            />
          )
          btn.label = btnConfig.text
          const defaultClick = btn.onClick

          btn.onClick = () => {
            defaultClick()
            onInjectedMenuItemClick(item, eventEmitter)
            item.injectItemClick?.(proxyItem)
          }
        } else {
          btn = {
            id: item.id,
            key: `${item.id}`,
            icon: (
              <img
                src={
                  isDarkMode
                    ? btnConfig.icon
                    : btnConfig.lightIcon || btnConfig.icon
                }
                className="icon-image"
              />
            ),
            label: btnConfig.text,
            onClick: () => {
              onInjectedMenuItemClick(item, eventEmitter)
              item.injectItemClick?.(proxyItem)
            },
            hidden: localMember.hide,
          }
        }
      }

      btn && moreButtons.push(btn)
    })
  }

  if (pluginList.length > 0) {
    pluginList.forEach((plugin) => {
      const btn = {
        id: plugin.pluginId,
        key: plugin.pluginId,
        icon: (
          <img
            src={plugin.icon?.pcIcon?.icon_dark}
            className="icon-image plugin-icon-image"
          />
        ),
        label: plugin.name,
        sessionId: plugin.notifySenderAccid,
        onClick: () => {
          onClickPlugin?.(plugin)
        },
      }

      moreButtons.push(btn)
    })
  }

  moreButtons = moreButtons.filter((item) => item && Boolean(!item.hidden))
  const feedbackBtnIndex = moreButtons.findIndex(
    (item) => item.id === feedbackBtn.id
  )

  // 将反馈按钮放到最后
  if (feedbackBtnIndex !== -1) {
    const feedbackBtn = moreButtons.splice(feedbackBtnIndex, 1)[0]

    moreButtons.push(feedbackBtn)
  }

  let buttons: ButtonType[] = []

  if (toolBarList.length > 0) {
    toolBarList.forEach((item) => {
      let btn = {
        [NEMenuIDs.mic]: audioBtn,
        [NEMenuIDs.camera]: videoBtn,
        [NEMenuIDs.screenShare]: screenShareBtn,
        [NEMenuIDs.participants]: memberListBtn,
        [NEMenuIDs.chat]: chatBtn,
        [NEMenuIDs.invite]: inviteBtn,
        [NEMenuIDs.whiteBoard]: whiteBoardBtn,
        [NEMenuIDs.security]: securityBtn,
        [NEMenuIDs.record]: recordBtn,
        [NEMenuIDs.setting]: settingBtn,
        [NEMenuIDs.live]: liveBtn,
        [NEMenuIDs.emoticons]: emoticonsBtn,
      }[item.id]

      const proxyItem = new Proxy(item, {
        get: function (target, propKey, receiver) {
          return Reflect.get(target, propKey, receiver)
        },
        set: function (target, propKey, value, receiver) {
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              moreBarList: [...moreBarList],
            },
          })
          return Reflect.set(target, propKey, value, receiver)
        },
      })

      let btnConfig

      if (Array.isArray(item.btnConfig)) {
        btnConfig = item.btnConfig.find((btn) => {
          return btn.status === item.btnStatus
        })
      } else {
        btnConfig = item.btnConfig
      }

      if (btnConfig) {
        if (btn) {
          btn.icon = (
            <img
              src={
                isDarkMode
                  ? btnConfig.icon
                  : btnConfig.lightIcon || btnConfig.icon
              }
              className="icon-image"
            />
          )
          btn.label = btnConfig.text
          const defaultClick = btn.onClick

          btn.onClick = () => {
            defaultClick()
            onInjectedMenuItemClick(item, eventEmitter)
            item.injectItemClick?.(proxyItem)
          }
        } else {
          btn = {
            id: item.id,
            key: `${item.id}`,
            icon: (
              <img
                src={
                  isDarkMode
                    ? btnConfig.icon
                    : btnConfig.lightIcon || btnConfig.icon
                }
                className="icon-image"
              />
            ),
            label: btnConfig.text,
            onClick: () => {
              onInjectedMenuItemClick(item, eventEmitter)
              item.injectItemClick?.(proxyItem)
            },
            hidden: localMember.hide,
          }
        }
      }

      btn && buttons.push(btn)
    })
  }

  const moreBtn = {
    id: 'more',
    key: 'more',
    popover: (children) => {
      return (
        <Popover
          destroyTooltipOnHide
          align={
            isElectronSharingScreen ? { offset: [0, 5] } : { offset: [0, -5] }
          }
          arrow={false}
          trigger={['click']}
          rootClassName="more-button-popover"
          open={moreBtnOpen}
          getTooltipContainer={(node) => node}
          onOpenChange={setMoreBtnOpen}
          autoAdjustOverflow={false}
          placement={isElectronSharingScreen ? 'bottom' : 'top'}
          content={
            <div
              className="more-button-list"
              style={
                moreButtons.length > 3
                  ? {
                      flexWrap: 'wrap',
                      width: 176,
                    }
                  : undefined
              }
            >
              {moreButtons.map((item) => {
                return (
                  <div
                    key={item.id}
                    className="more-button-item"
                    onClick={() => {
                      setMoreBtnOpen(false)
                      item.onClick && item.onClick()
                    }}
                  >
                    <Badge
                      dot={
                        meetingInfo.notificationMessages.filter(
                          (msg) =>
                            msg.unRead && msg.sessionId === item.sessionId
                        ).length > 0
                      }
                    >
                      {item.icon}
                    </Badge>
                    <div className="more-button-item-text">{item.label}</div>
                  </div>
                )
              })}
            </div>
          }
        >
          {children}
        </Popover>
      )
    },
    icon: (
      <div>
        <Badge
          dot={
            meetingInfo.notificationMessages.filter((msg) => msg.unRead)
              .length > 0
          }
        >
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconyx-tv-more1x"></use>
          </svg>
        </Badge>
      </div>
    ),
    label: t('moreBtn'),
    hidden: localMember.hide || moreButtons.length === 0,
    onClick: () => {
      setMoreBtnOpen(!moreBtnOpen)
    },
  }

  buttons.push(moreBtn)
  buttons = buttons.filter((item) => Boolean(!item?.hidden))

  function needHandUp(type: 'audio' | 'video'): boolean {
    const attendeeOffType =
      type === 'audio'
        ? meetingInfoRef.current.unmuteAudioBySelfPermission
        : meetingInfoRef.current.unmuteVideoBySelfPermission
    const contentText =
      type === 'audio'
        ? t('muteAllAudioHandsUpTips')
        : t('muteAllVideoHandsUpTips')

    if (
      !attendeeOffType &&
      !isHostOrCoHostRef.current &&
      // 本端在共享
      localMember.uuid !== meetingInfo.screenUuid
    ) {
      if (localMember.isHandsUp) {
        Toast.info(t('handsUpSuccessAlready'))
      } else {
        // if(handUpModalRef.current?.destroy())
        if (!handUpModalRef.current) {
          handUpModalRef.current = CommonModal.confirm({
            title: '',
            content: contentText,
            okText: t('handsUpApply'),
            onOk: async () => {
              // 如果此时音视频已被打开，则不需要举手
              if (type === 'audio' && localMemberRef.current.isAudioOn) {
                return
              }

              if (type === 'video' && localMemberRef.current.isVideoOn) {
                return
              }

              try {
                await neMeeting?.sendMemberControl(
                  memberAction.handsUp,
                  localMember.uuid
                )
                Toast.info(t('handsUpSuccess'))
              } catch {
                Toast.fail(t('handsUpFail'))
              }

              handUpModalRef.current = undefined
            },
            onCancel: () => {
              handUpModalRef.current = undefined
            },
          })
        }
      }

      return true
    }

    return false
  }

  function handleLeaveOrEnd(): { destroy: () => void } {
    if (closeModal) return closeModal
    const handleLeave = async () => {
      closeModal.destroy()
      closeModal = null

      leaveTimerRef.current && clearTimeout(leaveTimerRef.current)
      leaveTimerRef.current = setTimeout(() => {
        leaveTimerRef.current = null
        neMeeting?.eventEmitter?.emit(
          EventType.RoomEnded,
          NEMeetingLeaveType.LEAVE_BY_SELF
        )
      }, 3000)

      try {
        await neMeeting?.leave()
      } catch (error) {
        neMeeting?.eventEmitter?.emit(
          EventType.RoomEnded,
          NEMeetingLeaveType.LEAVE_BY_SELF
        )
      } finally {
        leaveTimerRef.current && clearTimeout(leaveTimerRef.current)
        leaveTimerRef.current = null
      }
    }

    closeModal = CommonModal.confirm({
      title: isHost ? t('meetingQuit') : t('leave'),
      content: isHost ? t('hostExitTips') : t('meetingLeaveConfirm'),
      focusTriggerAfterClose: false,
      transitionName: '',
      mask: false,
      afterClose: () => {
        closeModal = null
      },
      width: 400,
      wrapClassName: 'nemeeting-leave-or-end-meeting-modal',
      footer: (
        <div className="nemeeting-modal-confirm-btns">
          <Button
            onClick={() => {
              closeModal.destroy()
              closeModal = null
            }}
          >
            {t('globalCancel')}
          </Button>
          <Button type="primary" onClick={handleLeave}>
            {t('leave')}
          </Button>
          {isHost && (
            <Button
              danger
              onClick={async () => {
                closeModal.destroy()
                closeModal = null
                try {
                  await neMeeting?.end()
                } catch (error) {
                  Toast.fail(t('endFailed'))
                }
              }}
            >
              {t('meetingQuit')}
            </Button>
          )}
        </div>
      ),
    })
    return closeModal
  }

  function getCameras(needChange = true) {
    neMeeting?.getCameras().then(async (res) => {
      res && setCameras([...res])
      // 如果当前选择的是跟随系统默认设备
      const isDefaultVideoDevice =
        meetingInfo.setting.videoSetting.isDefaultDevice

      if (isDefaultVideoDevice) {
        const defaultDevice = res?.find((item) => item.default)

        if (defaultDevice) {
          if (defaultDevice.deviceId != selectedCameraRef.current) {
            neMeeting?.changeLocalVideo(defaultDevice.deviceId).then(() => {
              setSelectedCamera(defaultDevice.deviceId)
              onDeviceSelectedChange?.('video', defaultDevice.deviceId, true)
            })
          }

          return
        }
      }

      if (!selectedCameraRef.current) {
        selectedCameraRef.current = meetingInfo.setting.videoSetting.deviceId
      }

      const findDevice = res?.find(
        (item) => item.deviceId === selectedCameraRef.current
      )

      if (findDevice) {
        const device = findDevice
        const deviceId = device.deviceId

        needChange &&
          neMeeting?.changeLocalVideo(deviceId).then(() => {
            onDeviceSelectedChange?.('video', deviceId, device.defaultDevice)
            setSelectedCamera(deviceId)
          })
      } else if (!findDevice && res?.[0]) {
        const device = res[0]
        const deviceId = res[0].deviceId

        needChange &&
          neMeeting
            ?.changeLocalVideo(deviceId)
            .then(() => {
              onDeviceSelectedChange?.('video', deviceId, device.defaultDevice)
              setSelectedCamera(deviceId)
            })
            .catch(() => {
              console.log('changeLocalVideo error')
            })
      } else {
        try {
          const selectedCamera = neMeeting?.getSelectedCameraDevice()

          setSelectedCamera(selectedCamera)
        } catch (error) {
          console.log('getSelectedCameraDevice error', error)
        }
      }

      // 如果只有一个摄像头，需要先关闭再打开，否则会出现黑屏
      if (
        localMemberRef.current.isVideoOn &&
        cameras.length === 0 &&
        res?.length === 1
      ) {
        needChange &&
          neMeeting?.muteLocalVideo().then(() => {
            neMeeting?.unmuteLocalVideo()
          })
      } else if (localMemberRef.current.isVideoOn && res && res.length === 0) {
        // 当新获取到的设备列表未空，并且当前是打开视频的则需要关闭视频
        neMeeting?.muteLocalVideo()
      }
    })
  }

  function getMicrophones() {
    neMeeting?.getMicrophones().then((res) => {
      res && setMicrophones([...res])
      // 如果当前选择的是跟随系统默认设备
      const isDefaultRecordDevice = checkIsDefaultDevice(
        meetingInfo.setting.audioSetting.recordDeviceId
      )

      if (isDefaultRecordDevice) {
        const defaultDevice = res?.find((item) => item.default)

        if (defaultDevice) {
          if (defaultDevice.deviceId != selectedMicrophoneRef.current) {
            neMeeting?.changeLocalAudio(defaultDevice.deviceId).then(() => {
              onDeviceSelectedChange?.('record', defaultDevice.deviceId, true)
              setSelectedMicrophone(defaultDevice.deviceId)
            })
          }

          return
        }
      }

      if (!selectedMicrophoneRef.current) {
        selectedMicrophoneRef.current =
          meetingInfo.setting.audioSetting.recordDeviceId
      }

      const findDevice = res?.find(
        (item) => item.deviceId === selectedMicrophoneRef.current
      )

      if (findDevice) {
        const device = findDevice
        const deviceId = device.deviceId

        neMeeting?.changeLocalAudio(deviceId).then(() => {
          onDeviceSelectedChange?.('record', deviceId, device.defaultDevice)
          setSelectedMicrophone(deviceId)
        })
      } else if (!findDevice && res?.[0]) {
        const device = res[0]
        const deviceId = device.deviceId

        neMeeting
          ?.changeLocalAudio(deviceId)
          .then(() => {
            onDeviceSelectedChange?.('record', deviceId, device.defaultDevice)
            setSelectedMicrophone(deviceId)
          })
          .catch(() => {
            // TODO:
          })
      } else {
        try {
          const selectedMicrophone = neMeeting?.getSelectedRecordDevice()

          setSelectedMicrophone(selectedMicrophone)
        } catch (error) {
          console.log('getSelectedRecordDevice error', error)
        }
      }

      if (localMemberRef.current.isAudioOn && res && res.length === 0) {
        // 当新获取到的设备列表未空，并且当前是打开音频的则需要关闭音频
        neMeeting?.muteLocalAudio()
      }
    })
  }

  function getSpeakers() {
    neMeeting?.getSpeakers().then((res) => {
      res && setSpeakers([...res])
      // 如果当前选择的是跟随系统默认设备
      const isDefaultPlayoutDevice = checkIsDefaultDevice(
        meetingInfo.setting.audioSetting.playoutDeviceId
      )

      if (isDefaultPlayoutDevice) {
        const defaultDevice = res?.find((item) => item.default)

        if (defaultDevice) {
          if (defaultDevice.deviceId != selectedSpeakerRef.current) {
            neMeeting?.selectSpeakers(defaultDevice.deviceId).then(() => {
              onDeviceSelectedChange?.('playout', defaultDevice.deviceId, true)
              setSelectedSpeaker(defaultDevice.deviceId)
            })
          }

          return
        }
      }

      if (!selectedSpeakerRef.current) {
        selectedSpeakerRef.current =
          meetingInfo.setting.audioSetting.playoutDeviceId
      }

      const findDevice = res?.find(
        (item) => item.deviceId === selectedSpeakerRef.current
      )

      if (findDevice) {
        const device = findDevice
        const deviceId = device.deviceId

        neMeeting?.selectSpeakers(deviceId).then(() => {
          onDeviceSelectedChange?.('playout', deviceId, device.defaultDevice)
          setSelectedSpeaker(deviceId)
        })
      } else if (
        !res?.find((item) => item.deviceId == selectedSpeakerRef.current) &&
        res?.[0]
      ) {
        const device = res[0]
        const deviceId = device.deviceId

        // 如果当前设备被拔出则重新选择默认设备
        neMeeting
          ?.selectSpeakers(deviceId)
          .then(() => {
            onDeviceSelectedChange?.('playout', deviceId, device.defaultDevice)
            setSelectedSpeaker(deviceId)
          })
          .catch(() => {
            // TODO:
          })
      } else {
        try {
          const selectedSpeaker = neMeeting?.getSelectedPlayoutDevice()

          setSelectedSpeaker(selectedSpeaker)
        } catch (error) {
          console.log('getSelectedPlayoutDevice error', error)
        }
      }
    })
  }

  function handleSettingClick(type: 'audio' | 'video' | 'beauty' | 'record') {
    type === 'audio' && setAudioDeviceListOpen(false)
    type === 'video' && setVideoDeviceListOpen(false)
    type === 'record' && setRecordPopoverOpen(false)

    onSettingClick?.(type)
  }

  function renderDevicePopoverContent(type: string) {
    if (!['audio', 'video'].includes(type)) return null

    const popoverOpen =
      type === 'audio' ? audioDeviceListOpen : videoDeviceListOpen

    return (
      <Popover
        destroyTooltipOnHide
        trigger={['click']}
        rootClassName={classNames('device-popover', {
          'device-popover-audio': type === 'audio' && !isElectronSharingScreen,
        })}
        open={popoverOpen}
        getTooltipContainer={(node) => node}
        autoAdjustOverflow={false}
        placement={
          isElectronSharingScreen
            ? 'bottom'
            : type === 'audio'
            ? 'topLeft'
            : 'top'
        }
        onOpenChange={
          type === 'audio' ? setAudioDeviceListOpen : setVideoDeviceListOpen
        }
        afterOpenChange={
          type === 'audio' ? setAudioDeviceListOpen : setVideoDeviceListOpen
        }
        arrow={false}
        content={
          <>
            {type === 'audio' && (
              <div className="device-list">
                <div
                  className="device-list-title"
                  style={{ color: '#8D90A0', fontSize: '12px' }}
                >
                  {t('selectSpeaker')}
                </div>
                <div className="device-list-content">
                  {speakers.map((item) => (
                    <div
                      className={classNames('device-item', {
                        ['disabled']: !localMember.isAudioConnected,
                      })}
                      key={item.deviceName}
                      onClick={() => {
                        if (!localMember.isAudioConnected) {
                          return
                        }
          
                        setAudioDeviceListOpen(false)
                        neMeeting
                          ?.selectSpeakers(getDefaultDeviceId(item.deviceId))
                          .then(() => {
                            onDeviceSelectedChange?.(
                              'playout',
                              item.deviceId,
                              item.default
                            )
                            setSelectedSpeaker(item.deviceId)
                          })
                          .catch(() => {
                            // TODO:
                          })
                      }}
                    >
                      <div className="device-item-label">{item.deviceName}</div>
                      {item.deviceId == selectedSpeaker && (
                        <svg
                          className="icon iconfont icongouxuan"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#icongouxuan"></use>
                        </svg>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {type === 'audio' && (
              <div className="device-list">
                <div
                  className="device-list-title"
                  style={{ color: '#8D90A0', fontSize: '12px' }}
                >
                  {t('selectMicrophone')}
                </div>
                <div className="device-list-content">
                  {microphones.map((item) => (
                    <div
                      className={classNames('device-item', {
                        ['disabled']: !localMember.isAudioConnected,
                      })}
                      key={item.deviceName}
                      onClick={() => {
                        if (!localMember.isAudioConnected) {
                          return
                        }

                        setAudioDeviceListOpen(false)
                        neMeeting
                          ?.changeLocalAudio(getDefaultDeviceId(item.deviceId))
                          .then(() => {
                            onDeviceSelectedChange?.(
                              'record',
                              item.deviceId,
                              item.default
                            )
                            setSelectedMicrophone(item.deviceId)
                          })
                          .catch(() => {
                            // TODO:
                          })
                      }}
                    >
                      <div className="device-item-label">{item.deviceName}</div>
                      {item.deviceId == selectedMicrophone && (
                        <svg
                          className="icon iconfont icongouxuan"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#icongouxuan"></use>
                        </svg>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}
            {type === 'video' && (
              <div className="device-list">
                <div
                  className="device-list-title"
                  style={{ color: '#8D90A0', fontSize: '12px' }}
                >
                  {t('selectVideoSource')}
                </div>
                {cameras.map((item) => (
                  <div
                    className="device-item"
                    key={item.deviceName}
                    onClick={() => {

                      setVideoDeviceListOpen(false)
                      neMeeting
                        ?.changeLocalVideo(getDefaultDeviceId(item.deviceId))
                        .then(() => {
                          onDeviceSelectedChange?.(
                            'video',
                            item.deviceId,
                            item.default
                          )
                          setSelectedCamera(item.deviceId)
                        })
                        .catch(() => {
                          // TODO:
                        })
                    }}
                  >
                    <div className="device-item-label">{item.deviceName}</div>
                    {item.deviceId == selectedCamera && (
                      <svg
                        className="icon iconfont icongouxuan"
                        aria-hidden="true"
                      >
                        <use xlinkHref="#icongouxuan"></use>
                      </svg>
                    )}
                  </div>
                ))}
              </div>
            )}
            {type === 'audio' ? (
              <div className="nesetting">
                <div
                  className="device-list-title"
                  onClick={async () => {
                    try {
                      localMember.isAudioConnected
                        ? await neMeeting?.disconnectMyAudio()
                        : await neMeeting?.reconnectMyAudio()
                      if (!localMember.isAudioConnected) {
                        if (
                          (!meetingInfo.unmuteAudioBySelfPermission ||
                            meetingInfo.audioAllOff) &&
                          localMember.isAudioOn &&
                          !isHostOrCoHost
                        ) {
                          Toast.info(t('participantHostMuteAllAudio'))
                          neMeeting?.muteLocalAudio()
                        }
                      }
                    } catch (err: unknown) {
                      const knownError = err as {
                        message: string
                        msg: string
                        code: number
                      }

                      const defaultError = localMember.isAudioConnected
                        ? t('disconnectAudioFailed')
                        : t('connectAudioFailed')

                      Toast.fail(
                        knownError?.msg ||
                          t(errorCodeMap[knownError?.code] || defaultError)
                      )
                    }
                  }}
                >
                  {localMember.isAudioConnected
                    ? t('disconnectAudio')
                    : t('connectAudio')}
                </div>
              </div>
            ) : null}
            {!isElectronSharingScreen && (
              <div
                className="nesetting"
                onClick={() => handleSettingClick(type as 'video' | 'audio')}
              >
                <div
                  className="device-list-title"
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                  }}
                >
                  {t(type === 'audio' ? 'audioSetting' : 'videoSetting')}
                  <div>
                    <svg
                      style={{
                        fontSize: '17px',
                        color: '##8D90A0',
                      }}
                      className="icon iconfont"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconyoujiantou-16px-2"></use>
                    </svg>
                  </div>
                </div>
              </div>
            )}

            {!isElectronSharingScreen &&
              window.ipcRenderer &&
              (!!globalConfig?.appConfig?.MEETING_VIRTUAL_BACKGROUND?.enable ||
                !!globalConfig?.appConfig?.MEETING_BEAUTY?.enable) &&
              type === 'video' && (
                <div
                  className="nesetting"
                  onClick={() => handleSettingClick('beauty')}
                >
                  <div className="device-list-title">{t('beautySetting')}</div>
                </div>
              )}
          </>
        }
      >
        <div
          className="audio-video-devices-button"
          onClick={() => {
            if (type === 'audio') {
              getMicrophones()
              getSpeakers()
              setAudioDeviceListOpen(!audioDeviceListOpen)
            } else {
              getCameras(false)
              setVideoDeviceListOpen(!videoDeviceListOpen)
            }
          }}
        >
          {isElectronSharingScreen ? (
            <CaretDownOutlined />
          ) : (
            <CaretUpOutlined />
          )}
        </div>
      </Popover>
    )
  }

  function renderRecordPopoverContent(type: string) {
    if (!['record'].includes(type) || isElectronSharingScreen) return null

    const popoverOpen = recordPopoverOpen

    return (
      <Popover
        destroyTooltipOnHide
        trigger={['click']}
        rootClassName="device-popover"
        open={popoverOpen}
        getTooltipContainer={(node) => node}
        autoAdjustOverflow={false}
        placement={isElectronSharingScreen ? 'bottom' : 'top'}
        onOpenChange={setRecordPopoverOpen}
        afterOpenChange={setRecordPopoverOpen}
        arrow={false}
        content={
          <>
            <div
              className="nesetting"
              onClick={() => handleSettingClick('record')}
            >
              <div className="device-list-title">{t('recordSetting')}</div>
            </div>
          </>
        }
      >
        <div
          className="audio-video-devices-button"
          onClick={() => {
            setRecordPopoverOpen(!recordPopoverOpen)
          }}
        >
          {isElectronSharingScreen ? (
            <CaretDownOutlined />
          ) : (
            <CaretUpOutlined />
          )}
        </div>
      </Popover>
    )
  }

  async function shareScreen() {
    if (localMemberRef.current.isSharingScreen) {
      try {
        dispatch?.({
          type: ActionType.UPDATE_MEMBER,
          data: {
            uuid: localMember.uuid,
            member: { isSharingScreen: false },
          },
        })
        await neMeeting?.muteLocalScreenShare()
        stopScreenShareClickRef.current = true
      } catch {
        Toast.fail(t('screenShareStopFail'))
      }
    } else {
      if (!meetingInfoRef.current.screenSharePermission && !isHostOrCoHost) {
        Toast.fail(t('shareNoPermission'))
        return
      }

      if (
        meetingInfoRef.current.screenUuid ||
        (meetingInfoRef.current.systemAudioUuid &&
          meetingInfoRef.current.systemAudioUuid !==
            meetingInfoRef.current.myUuid)
      ) {
        Toast.info(t('screenShareOverLimit'))
      } else if (meetingInfoRef.current.whiteboardUuid) {
        Toast.info(t('meetingHasWhiteBoardShare'))
      } else {
        // 如果是Electron则抛到上层处理
        if (window.ipcRenderer) {
          onDefaultButtonClick?.('electronShareScreen')
        } else {
          try {
            let limitFrameRate: VideoFrameRate = 30

            if (
              meetingInfoRef.current.setting.screenShareSetting
                ?.sharedLimitFrameRateEnable &&
              meetingInfoRef.current.setting.screenShareSetting
                ?.sharedLimitFrameRate
            ) {
              limitFrameRate = meetingInfoRef.current.setting.screenShareSetting
                .sharedLimitFrameRate as VideoFrameRate
            }

            await neMeeting?.unmuteLocalScreenShare({
              limitFrameRate,
            })
          } catch (err: unknown) {
            const knownError = err as {
              message: string
              msg: string
              code: number
            }

            // web共享弹窗点击取消不需要报错
            if (!window.isElectronNative && knownError?.code === 10212) {
              return
            }

            Toast.fail(knownError?.msg || knownError.message)
          }
        }
      }
    }
  }

  useEffect(() => {
    if (!open) {
      setMoreBtnOpen(false)
      setAudioDeviceListOpen(false)
      setVideoDeviceListOpen(false)
    }
  }, [open])

  function handleViewMsg() {
    memberNotifyRef.current?.destroy()
    if (window.isElectronNative) {
      window.ipcRenderer?.send(IPCEvent.notifyHide)
    }

    // setWaitingRoomUnReadCount(0)
    eventEmitter?.emit(MeetingEventType.changeMemberListTab, 'waitingRoom')
    neMeeting?.updateWaitingRoomUnReadCount(0)
    if (!isOpenMemberList) {
      onDefaultButtonClick?.('memberList')
    }
  }

  function onNotNotify() {
    notNotifyRef.current = true
  }

  const isOpenMemberList = useMemo(() => {
    const index = meetingInfo.rightDrawerTabs.findIndex(
      (item) => item.key === 'memberList'
    )

    return meetingInfo.rightDrawerTabActiveKey === 'memberList' && index > -1
  }, [meetingInfo.rightDrawerTabActiveKey, meetingInfo.rightDrawerTabs])

  const isOpenWaitingRoomMemberList = useMemo(() => {
    return (
      isOpenMemberList && meetingInfo.activeMemberManageTab === 'waitingRoom'
    )
  }, [meetingInfo.activeMemberManageTab, isOpenMemberList])

  useEffect(() => {
    function handleNotify() {
      // 如果没有设置不再显示，则显示通知
      if (!notNotifyRef.current) {
        const memberCount = waitingRoomInfo.memberCount + 1

        if (isElectronSharingScreen) {
          window.ipcRenderer?.send(IPCEvent.notifyShow, {
            memberCount: memberCount,
          })
        } else {
          memberNotifyRef.current?.notify(memberCount)
        }
      }

      // 判断是否需要红点
      if (isElectronSharingScreen) {
        const isOpen = !!getWindow('memberWindow')

        if (isOpen && meetingInfo.activeMemberManageTab == 'waitingRoom') {
          return
        }

        waitingRoomDispatch?.({
          type: ActionType.WAITING_ROOM_UPDATE_INFO,
          data: {
            info: {
              unReadMsgCount: (waitingRoomInfo.unReadMsgCount || 0) + 1,
            },
          },
        })
      } else {
        if (!isOpenWaitingRoomMemberList) {
          waitingRoomDispatch?.({
            type: ActionType.WAITING_ROOM_UPDATE_INFO,
            data: {
              info: {
                unReadMsgCount: (waitingRoomInfo.unReadMsgCount || 0) + 1,
              },
            },
          })
        }
      }
    }

    if (
      (localMember.role === Role.host || localMember.role === Role.coHost) &&
      waitingRoomInfo.isEnabledOnEntry
    ) {
      eventEmitter?.on(EventType.MemberJoinWaitingRoom, handleNotify)
      return () => {
        eventEmitter?.off(EventType.MemberJoinWaitingRoom, handleNotify)
      }
    }
  }, [
    localMember?.role,
    waitingRoomInfo.memberCount,
    waitingRoomInfo.isEnabledOnEntry,
    waitingRoomInfo.unReadMsgCount,
    isOpenWaitingRoomMemberList,
    isElectronSharingScreen,
    eventEmitter,
    meetingInfo.activeMemberManageTab,
    waitingRoomDispatch,
  ])
  useEffect(() => {
    if (!waitingRoomInfo.isEnabledOnEntry) {
      memberNotifyRef.current?.destroy()
      if (window.isElectronNative) {
        window.ipcRenderer?.send(IPCEvent.notifyHide)
      }
    }
  }, [waitingRoomInfo.isEnabledOnEntry])

  useEffect(() => {
    if (
      (meetingInfo.unmuteAudioBySelfPermission && !meetingInfo.audioAllOff) ||
      (meetingInfo.unmuteVideoBySelfPermission && !meetingInfo.videoAllOff)
    ) {
      handUpModalRef.current?.destroy()
      handUpModalRef.current = undefined
    }
  }, [
    meetingInfo.unmuteAudioBySelfPermission,
    meetingInfo.unmuteVideoBySelfPermission,
    meetingInfo.videoAllOff,
    meetingInfo.audioAllOff,
  ])

  useEffect(() => {
    // 外部用户触发点击共享按钮事件
    outEventEmitter?.on('enableShareScreen', () => {
      shareScreen()
    })

    let netMsgTimer

    eventEmitter?.on('newMsgs', (res) => {
      if (
        meetingInfoRef.current.setting.normalSetting
          .chatMessageNotificationType === 1
      ) {
        netMsgTimer && clearTimeout(netMsgTimer)
        setNewMsg(res[0])
        netMsgTimer = setTimeout(() => {
          setNewMsg(undefined)
          netMsgTimer = null
        }, 5000)
      }
    })

    eventEmitter?.on(
      EventType.CheckNeedHandsUp,
      (data: { type: 'video' | 'audio'; isOpen: boolean }) => {
        needHandUp(data.type)
      }
    )
    eventEmitter?.on(MeetingEventType.leaveOrEndRoom, () => {
      // handleLeaveOrEnd()
      dispatch?.({
        type: ActionType.UPDATE_MEETING_INFO,
        data: {
          endMeetingAction: 2,
        },
      })
    })

    eventEmitter?.on(
      EventType.NeedAudioHandsUp,
      (needAudioHandsUp: boolean) => {
        if (!needAudioHandsUp) {
          handUpModalRef.current?.destroy()
          handUpModalRef.current = undefined
        }
      }
    )
    eventEmitter?.on(
      EventType.NeedVideoHandsUp,
      (needVideoHandsUp: boolean) => {
        if (!needVideoHandsUp) {
          handUpModalRef.current?.destroy()
          handUpModalRef.current = undefined
        }
      }
    )
    outEventEmitter?.on(UserEventType.EndMeeting, async (callback) => {
      try {
        await neMeeting?.end()
        callback?.()
      } catch (error) {
        callback?.(error)
        neMeeting?.eventEmitter?.emit(
          EventType.RoomEnded,
          NEMeetingLeaveType.LEAVE_BY_SELF
        )
      }
    })

    outEventEmitter?.on(UserEventType.LeaveMeeting, async (callback) => {
      try {
        await neMeeting?.leave()
        callback?.()
      } catch (error) {
        // Toast.fail(t('leaveFailed'))
        callback?.(error)
        neMeeting?.eventEmitter?.emit(
          EventType.RoomEnded,
          NEMeetingLeaveType.LEAVE_BY_SELF
        )
      }
    })

    eventEmitter?.on(UserEventType.StopWhiteboard, () => {
      handleStopWhiteboard()
    })
    eventEmitter?.on(UserEventType.StopWhiteboard, () => {
      handleStopWhiteboard()
    })
    return () => {
      outEventEmitter?.off('enableShareScreen')
      outEventEmitter?.off(UserEventType.LeaveMeeting)
      outEventEmitter?.off(UserEventType.EndMeeting)
      eventEmitter?.off('newMsgs')
      eventEmitter?.off(EventType.CheckNeedHandsUp)
      eventEmitter?.off(MeetingEventType.leaveOrEndRoom)
      eventEmitter?.off(EventType.NeedAudioHandsUp)
      eventEmitter?.off(EventType.NeedVideoHandsUp)
      eventEmitter?.off(UserEventType.StopWhiteboard)
    }
  }, [])

  useEffect(() => {
    function handleDeviceChange() {
      getCameras()
      getMicrophones()
      getSpeakers()
    }

    const debounceHandle = debounce(handleDeviceChange, 1000)

    navigator.mediaDevices.addEventListener('devicechange', debounceHandle)

    return () => {
      navigator.mediaDevices.removeEventListener('devicechange', debounceHandle)
    }
  }, [cameras.length])

  const isObserver = useMemo(() => {
    return localMember.role === Role.observer
  }, [localMember.role])

  useEffect(() => {
    if (preHandUpCount && handUpCount < preHandUpCount) {
      return
    }

    handUpPopoverOpenTimerRef.current &&
      clearTimeout(handUpPopoverOpenTimerRef.current)
    if (isElectronSharingScreen) {
      setTimeout(() => {
        setHandUpPopoverOpen(
          (localMember.isHandsUp || (isHostOrCoHost && handUpCount > 0)) &&
            !meetingInfo.isRooms
        )
      }, 200)
    } else {
      setHandUpPopoverOpen(
        (localMember.isHandsUp || (isHostOrCoHost && handUpCount > 0)) &&
          !meetingInfo.isRooms
      )
    }

    handUpPopoverOpenTimerRef.current = setTimeout(() => {
      setHandUpPopoverOpen(false)
    }, 5000)
  }, [localMember.isHandsUp, isHostOrCoHost, handUpCount, meetingInfo.isRooms])

  useMount(() => {
    getCameras()
    getMicrophones()
    getSpeakers()
  })

  useEffect(() => {
    if (isHostOrCoHost && neMeeting?.isEnableWaitingRoom()) {
      neMeeting?.waitingRoomController
        ?.getMemberList(0, 20, true)
        .then((res) => {
          const memberList = res.data

          neMeeting?.updateWaitingRoomUnReadCount(memberList.length)
          waitingRoomDispatch?.({
            type: ActionType.WAITING_ROOM_SET_MEMBER_LIST,
            data: { memberList },
          })
        })
    } else {
      neMeeting?.updateWaitingRoomUnReadCount(0)
      waitingRoomDispatch?.({
        type: ActionType.WAITING_ROOM_SET_MEMBER_LIST,
        data: { memberList: [] },
      })
    }
  }, [isHostOrCoHost, neMeeting, waitingRoomDispatch])

  useEffect(() => {
    function handleDeviceChange(deviceInfo: {
      type: string
      deviceId: string
      deviceName: string
    }) {
      switch (deviceInfo.type) {
        case 'video':
          setSelectedCamera(deviceInfo.deviceId)
          break
        case 'speaker':
          setSelectedSpeaker(deviceInfo.deviceId)
          break
        case 'microphone':
          setSelectedMicrophone(deviceInfo.deviceId)
          break
      }
    }

    if (window.ipcRenderer) {
      window.ipcRenderer.on('main-close-before', (_, beforeQuit) => {
        // closeModal = handleLeaveOrEnd()
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            endMeetingAction: beforeQuit ? 2 : 3,
          },
        })
      })

      // 设置页面切换音频或者视频设备 setting: {type: 'video'|'audio', deviceId: string, deviceName?: string}
      window.ipcRenderer?.on(IPCEvent.changeSettingDevice, (event, setting) => {
        handleDeviceChange(setting)
      })
      // 非预加载需主动获取一次
      window.ipcRenderer?.invoke(IPCEvent.getThemeColor).then((isDark) => {
        setIsDarkMode(isDark)
      })
      window.ipcRenderer.on(IPCEvent.setThemeColor, (_, isDark) => {
        setIsDarkMode(isDark)
      })
      window.ipcRenderer.on(IPCEvent.memberNotifyNotNotify, () => {
        notNotifyRef.current = true
      })
    } else {
      // web端监听设置界面设备变更
      eventEmitter?.on(EventType.ChangeDeviceFromSetting, handleDeviceChange)
    }
  }, [])
  useEffect(() => {
    memberNotifyRef.current?.destroy()
    if (window.isElectronNative) {
      window.ipcRenderer?.on(IPCEvent.memberNotifyViewMemberMsg, handleViewMsg)
      return () => {
        window.ipcRenderer?.off(
          IPCEvent.memberNotifyViewMemberMsg,
          handleViewMsg
        )
      }
    }
  }, [isElectronSharingScreen])

  useEffect(() => {
    if (selectedMicrophone) {
      const deviceInfo = microphones.find(
        (item) =>
          item.deviceId == selectedMicrophone &&
          !!meetingInfo.setting.audioSetting.isDefaultRecordDevice ==
            !!item.default
      )

      deviceInfo &&
        Toast.info(`${t('currentMicDevice')}: ${deviceInfo.deviceName}`, 1000)
    }
  }, [selectedMicrophone])

  useEffect(() => {
    if (!localMember.isAudioConnected) {
      CommonModal.destroy('speakerVolumeMuteTips')
      return
    }

    if (selectedSpeaker) {
      const deviceInfo = speakers.find(
        (item) =>
          item.deviceId == selectedSpeaker &&
          !!meetingInfo.setting.audioSetting.isDefaultPlayoutDevice ==
            !!item.default
      )

      deviceInfo &&
        Toast.info(
          `${t('currentSpeakerDevice')}: ${deviceInfo.deviceName}`,
          1000
        )

      const mute = neMeeting?.rtcController?.getPlayoutDeviceMute?.()
      const volume = neMeeting?.rtcController?.getPlayoutDeviceVolume?.()
      const settingVolume = meetingInfo.setting.audioSetting.playouOutputtVolume

      if (mute || volume === 0 || settingVolume === 0) {
        CommonModal.warning({
          key: 'speakerVolumeMuteTips',
          title: t('commonTitle'),
          content: t('speakerVolumeMuteTips'),
        })
      }
    }
  }, [selectedSpeaker, localMember.isAudioConnected])

  useEffect(() => {
    if (isElectronSharingScreen) {
      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
        method: 'controlBarVisibleChangeByMouse',
        data: {
          open: isElectronSharingScreenToolsShow,
        },
      })
      if (!isElectronSharingScreenToolsShow) {
        setAudioDeviceListOpen(false)
        setVideoDeviceListOpen(false)
        setScreenSharingPopoverOpen(false)
      }
    }
  }, [isElectronSharingScreen, isElectronSharingScreenToolsShow])

  useEffect(() => {
    if (isElectronSharingScreen) {
      const dom = document.querySelector(
        '.nemeeting-sharing-screen .nemeeting-drawer-content .control-bar-button-list'
      )

      const resizeWidth = debounce(() => {
        {
          let width = 0
          const children = Array.from(dom?.children ?? [])

          children.forEach((item) => {
            width += item.clientWidth
          })

          width += 50

          if (isElectronSharingScreenToolsShowRef.current) {
            window.ipcRenderer?.send(IPCEvent.sharingScreen, {
              method: 'controlBarVisibleChangeByMouse',
              data: {
                open: isElectronSharingScreenToolsShowRef.current,
                width: width,
              },
            })
          }
        }
      }, 100)
      const observer = new ResizeObserver(() => {
        resizeWidth()
      })

      dom && observer.observe(dom)
      return () => {
        dom && observer.unobserve(dom)
        observer.disconnect()
      }
    }
  }, [isElectronSharingScreen])

  useEffect(() => {
    if (isElectronSharingScreen) {
      if (
        videoDeviceListOpen ||
        audioDeviceListOpen ||
        securityPopoverOpen ||
        moreBtnOpen ||
        screenSharingPopoverOpen
      ) {
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'openDeviceList',
        })
      } else {
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'closeDeviceList',
        })
      }
    }
  }, [
    videoDeviceListOpen,
    audioDeviceListOpen,
    screenSharingPopoverOpen,
    securityPopoverOpen,
    moreBtnOpen,
    isElectronSharingScreen,
  ])

  useEffect(() => {
    if (isElectronSharingScreen) {
      if (newMsg) {
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'openPopover',
        })
      } else {
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'closePopover',
        })
      }
    }
  }, [newMsg, isElectronSharingScreen])

  useEffect(() => {
    if (preHandUpCount && handUpCount < preHandUpCount) {
      return
    }

    if (isElectronSharingScreen) {
      if (isHostOrCoHost && handUpCount > 0 && !!controlBarVisibleByMouse) {
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'openPopover',
        })
      } else {
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'closePopover',
        })
      }
    }
  }, [
    isElectronSharingScreen,
    isHostOrCoHost,
    handUpCount,
    controlBarVisibleByMouse,
  ])

  useEffect(() => {
    if (meetingInfo.detectMutedMic !== false) {
      const handleRtcLocalAudioVolumeIndication = (volume, isChannel) => {
        // 子频道
        if (isChannel) {
          return
        }

        const MAX_COUNT = 10

        //  每 600 毫秒 回调一次，>= 30 说明已经显示过了
        if (muteTipsNeedShowRef.current >= MAX_COUNT) {
          return
        }

        if (!localMember.isAudioOn && volume !== undefined) {
          // 本地音量为 0 时，重置计数
          if (volume === 0) {
            muteTipsNeedShowRef.current = 0
          } else {
            muteTipsNeedShowRef.current++
          }

          if (
            muteTipsNeedShowRef.current >= MAX_COUNT &&
            !isElectronSharingScreen
          ) {
            Toast.info(t('audioMuteOpenTips'))
            eventEmitter?.off(
              EventType.RtcLocalAudioVolumeIndication,
              handleRtcLocalAudioVolumeIndication
            )
          }
        }
      }

      eventEmitter?.on(
        EventType.RtcLocalAudioVolumeIndication,
        handleRtcLocalAudioVolumeIndication
      )
      return () => {
        eventEmitter?.off(
          EventType.RtcLocalAudioVolumeIndication,
          handleRtcLocalAudioVolumeIndication
        )
      }
    }
  }, [
    eventEmitter,
    localMember.isAudioOn,
    t,
    isElectronSharingScreen,
    meetingInfo.detectMutedMic,
  ])

  useEffect(() => {
    if (isElectronSharingScreen) {
      let pauseToastId = ''
      let pauseTimer
      const handle = (status) => {
        switch (status) {
          case tagNERoomScreenCaptureStatus.kNERoomScreenCaptureStatusStop:
            pauseTimer && clearTimeout(pauseTimer)
            setTimeout(() => {
              // shareScreen()
              // 自己点击 不显示
              !stopScreenShareClickRef.current &&
                Toast.info(t('screenShareStop'))
              stopScreenShareClickRef.current = false
              Toast.destroy(pauseToastId)
            }, 500)
            break
          case tagNERoomScreenCaptureStatus.kNERoomScreenCaptureStatusPause:
            pauseTimer && clearTimeout(pauseTimer)
            pauseTimer = setTimeout(() => {
              if (pauseToastId) Toast.destroy(pauseToastId)
              pauseToastId = Toast.fail(
                t('pauseScreenShare'),
                1000000,
                false,
                undefined,
                undefined,
                true
              )
              pauseTimer = null
            }, 1000)
            break
          case tagNERoomScreenCaptureStatus.kNERoomScreenCaptureStatusResume:
            pauseTimer && clearTimeout(pauseTimer)
            Toast.destroy(pauseToastId)
            pauseToastId = ''
            break
        }
      }

      eventEmitter?.on(EventType.RtcScreenCaptureStatus, handle)
      return () => {
        pauseTimer && clearTimeout(pauseTimer)
        Toast.destroy(pauseToastId)
        eventEmitter?.off(EventType.RtcScreenCaptureStatus, handle)
      }
    }
  }, [eventEmitter, isElectronSharingScreen, t])

  async function getDeviceAccessStatus() {
    return window.ipcRenderer?.invoke(IPCEvent.getDeviceAccessStatus).then(
      (res) =>
        (deviceAccessStatusRef.current = {
          camera: res.camera !== 'denied',
          microphone: res.microphone !== 'denied',
        })
    )
  }

  useEffect(() => {
    getDeviceAccessStatus()
  }, [])

  const showRecordUI = useMemo(() => {
    const cloudRecord = meetingInfo.cloudRecordState

    return (
      (cloudRecord === RecordState.Recording ||
        cloudRecord === RecordState.Starting) &&
      showCloudRecordingUI
    )
  }, [meetingInfo.cloudRecordState, showCloudRecordingUI])

  const rootStyle = useMemo(() => {
    return { width: '100%' }
    /*
    if (!isElectronSharingScreen) {
      return { width: '100%' }
    }

    if (!isElectronSharingScreenToolsShow) {
      return { width: 350 }
    }

    if (!isHostOrCoHost) {
      if (isElectronSharingScreenToolsShow) {
        switch (i18n.language) {
          case 'zh-CN':
            return { width: '80%' }
          case 'en-US':
            return { width: '80%' }
          case 'ja-JP':
            return { width: '85%' }
          default:
            return { width: '100%' }
        }
      }
    } else {
      switch (i18n.language) {
        case 'zh-CN':
          return { width: '85%' }
        case 'en-US':
          return { width: '91%' }
        case 'ja-JP':
          return { width: '93%' }
        default:
          return { width: '100%' }
      }
    }

    return { width: '100%' }
    */
  }, [
    isElectronSharingScreen,
    i18n.language,
    isElectronSharingScreenToolsShow,
    isHostOrCoHost,
  ])

  // 人数上限提醒
  useUpdateEffect(() => {
    if (isHostOrCoHost) {
      const maxMembers = meetingInfo.maxMembers || 0
      const inInvitingMemberListLength = inInvitingMemberList?.length || 0
      const memberListLength = memberList.length

      if (memberListLength + inInvitingMemberListLength >= maxMembers) {
        if (globalConfig?.appConfig?.APP_ROOM_RESOURCE?.waitingRoom) {
          if (!meetingInfo.isWaitingRoomEnabled) {
            CommonModal.confirm({
              key: 'participantUpperLimitWaitingRoomTip',
              title: t('commonTitle'),
              content: t('participantUpperLimitWaitingRoomTip'),
              okText: t('openWaitingRoom'),
              onOk: async () => {
                try {
                  await neMeeting?.waitingRoomController?.enableWaitingRoomOnEntry()
                  Toast.success(t('enabledWaitingRoom'))
                  neMeeting?.waitingRoomController
                    ?.getMemberList(0, 20, true)
                    .then((res) => {
                      waitingRoomDispatch?.({
                        type: ActionType.WAITING_ROOM_SET_MEMBER_LIST,
                        data: { memberList: res.data },
                      })
                    })
                } catch (err: unknown) {
                  const knownError = err as { message: string; msg: string }

                  Toast.fail(knownError?.msg || knownError.message)
                }
              },
            })
            return
          }
        }

        if (!nomoreParticipantUpperLimitTipRef.current) {
          CommonModal.warning({
            key: 'participantUpperLimitReleaseSeatsTip',
            title: t('commonTitle'),
            content: (
              <div>
                <div>{t('participantUpperLimitReleaseSeatsTip')}</div>
                {!globalConfig?.appConfig?.APP_ROOM_RESOURCE.waitingRoom && (
                  <Checkbox
                    style={{ marginTop: '10px' }}
                    onChange={(e) => {
                      nomoreParticipantUpperLimitTipRef.current =
                        e.target.checked
                    }}
                  >
                    {t('notRemindMeAgain')}
                  </Checkbox>
                )}
              </div>
            ),
            okText: t('IkonwIt'),
          })
        }
      }
    }
  }, [memberList.length, inInvitingMemberList?.length, meetingInfo.maxMembers])

  return meetingInfo.endMeetingAction === 1 && isHost ? null : (
    <Drawer
      open={
        !meetingInfo.hiddenControlBar &&
        (isElectronSharingScreen ||
          open ||
          !!newMsg ||
          localMember.isHandsUp ||
          (isHostOrCoHost && handUpCount > 0))
      }
      placement={isElectronSharingScreen ? 'top' : 'bottom'}
      closable={false}
      mask={false}
      height={
        !open && !isElectronSharingScreen
          ? 0
          : isElectronSharingScreen && !isElectronSharingScreenToolsShow
          ? 40
          : 60
      }
      rootClassName={classNames('control-bar-container', {
        ['open-with-hidden']: !open && !isElectronSharingScreen,
        ['nemeeting-sharing-screen']: isElectronSharingScreen,
        ['whiteboard-open']:
          !!meetingInfo.whiteboardUuid && !meetingInfo.isWhiteboardTransparent,
      })}
      rootStyle={rootStyle}
      autoFocus={false}
      {...restProps}
    >
      {meetingInfo.isRooms ? (
        <div className="control-bar-rooms-container">
          <div
            className="control-bar-rooms-icon"
            onClick={() => {
              neMeeting?.roomContext?.updateMemberProperty(
                localMember.uuid,
                'speakerOn',
                JSON.stringify({
                  value:
                    localMember.properties.speakerOn?.value === '0' ? '1' : '0',
                })
              )
            }}
          >
            {localMember.properties.speakerOn?.value === '0' ? (
              <img className="icon-image" src={MuteSpeakIcon} />
            ) : (
              <svg className={classNames('icon iconfont')} aria-hidden="true">
                <use xlinkHref="#iconsound-loud"></use>
              </svg>
            )}
          </div>
          <div className="control-bar-rooms-icon" onClick={handleAudio}>
            {localMember.isAudioOn ? (
              <AudioIcon
                className="icon-image"
                dark={!isDarkMode}
                memberId={localMember.uuid}
              />
            ) : (
              <img className="icon-image" src={MuteAudioIcon} />
            )}
          </div>
          <div className="control-bar-rooms-icon" onClick={handleVideo}>
            {localMember.isVideoOn ? (
              <svg className={classNames('icon iconfont')} aria-hidden="true">
                <use xlinkHref="#iconyx-tv-video-onx"></use>
              </svg>
            ) : (
              <img className="icon-image" src={MuteVideoIcon} />
            )}
          </div>
          <div
            className="control-bar-rooms-end-button"
            onClick={handleLeaveOrEnd}
          >
            {isHostOrCoHost ? t('meetingQuit') : t('leave')}
          </div>
        </div>
      ) : (
        <div className="control-bar-button-list">
          {isElectronSharingScreen && (
            <div
              className={classNames('control-bar-meeting-info', {
                ['control-bar-meeting-info-small']: !isElectronSharingScreenToolsShow,
                ['control-bar-meeting-info-border']: isElectronSharingScreenToolsShow,
              })}
            >
              {isElectronSharingScreenToolsShow ? (
                <div className="coontrol-bar-meeting-info-num-wrap">
                  <div className="control-bar-meeting-info-num">
                    <Network onlyIcon />
                    <div className="control-bar-meeting-info-num-text">
                      {t('meetingId')}：
                      {getMeetingDisplayId(meetingInfo.meetingNum)}
                    </div>
                  </div>
                  {showRecordUI && (
                    <div className="sharing-screen-record">
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconyunluzhi"></use>
                      </svg>
                      <span className="sharing-screen-record-title">
                        {meetingInfo.cloudRecordState === RecordState.Recording
                          ? t('recording')
                          : t('startingRecording')}
                      </span>
                    </div>
                  )}
                </div>
              ) : (
                <>
                  <Network onlyIcon />
                  <div className="control-bar-meeting-info-num-text">
                    {t('meetingId')}：
                    {getMeetingDisplayId(meetingInfo.meetingNum)}
                  </div>
                </>
              )}
            </div>
          )}
          {(isElectronSharingScreen && !isElectronSharingScreenToolsShow) ||
          (meetingInfo.endMeetingAction === 1 && isHost) ? null : (
            <>
              {isObserver
                ? null
                : buttons.map((button) => {
                    const content = (
                      <>
                        <div
                          className="control-bar-button-item"
                          onClick={button.onClick}
                        >
                          {button.icon}
                          <div
                            className={classNames(
                              'control-bar-button-item-text',
                              {
                                ['audio-text']:
                                  button.key === 'audio' ||
                                  button.key === 'record',
                              }
                            )}
                          >
                            {button.label}
                          </div>
                        </div>
                      </>
                    )

                    return (
                      <div
                        key={button.key}
                        // audio video 按钮位置
                        className={classNames(
                          'control-bar-button-item-box control-bar-button-item-box-zh',
                          {
                            'control-bar-button-item-box-zh':
                              i18n.language === 'zh-CN',
                            'control-bar-button-item-box-audio':
                              button.key === 'audio' &&
                              !isElectronSharingScreen,
                            'control-bar-button-item-box-video':
                              button.key === 'video' &&
                              !isElectronSharingScreen,
                            'control-bar-button-item-box-video-en':
                              button.key === 'video' &&
                              !isElectronSharingScreen &&
                              i18n.language === 'en-US',
                            'control-bar-button-item-box-audio-jp':
                              button.key === 'audio' &&
                              !isElectronSharingScreen &&
                              i18n.language === 'ja-JP',
                          }
                        )}
                      >
                        {button.popover ? button.popover(content) : content}
                        {renderDevicePopoverContent(button.key)}
                        {renderRecordPopoverContent(button.key)}
                      </div>
                    )
                  })}
              {isElectronSharingScreen ? (
                <div className="control-bar-stop-sharing-button">
                  <span onClick={shareScreen}>{t('screenShareStop')}</span>
                  <Popover
                    destroyTooltipOnHide
                    getTooltipContainer={(node) => node}
                    autoAdjustOverflow={false}
                    placement={isElectronSharingScreen ? 'bottom' : 'top'}
                    rootClassName="screen-sharing-popover"
                    trigger={['hover']}
                    align={
                      i18n.language.startsWith('en')
                        ? { offset: [-50, 0] }
                        : i18n.language.startsWith('ja')
                        ? { offset: [-100, 0] }
                        : { offset: [-30, 0] }
                    }
                    arrow={false}
                    open={screenSharingPopoverOpen}
                    onOpenChange={setScreenSharingPopoverOpen}
                    afterOpenChange={setScreenSharingPopoverOpen}
                    content={
                      screenSharingPopoverOpen ? (
                        <div
                          className="screen-sharing-popover-item"
                          style={{
                            textAlign: 'center',
                            marginRight: '10px',
                          }}
                          onClick={(e) => {
                            e.stopPropagation()
                            if (meetingInfo.startSystemAudioLoopbackCapture) {
                              // 通过 hooks 处理
                            } else {
                              // 如果是译员 无法进行共享音频
                              if (
                                meetingInfo.isInterpreter &&
                                meetingInfo.interpretation?.started
                              ) {
                                Toast.info(
                                  t('interpAudioShareIsForbiddenDesktop')
                                )
                                return
                              }

                              // 通过 hooks 处理
                            }

                            dispatch?.({
                              type: ActionType.UPDATE_MEETING_INFO,
                              data: {
                                startSystemAudioLoopbackCapture: !meetingInfo.startSystemAudioLoopbackCapture,
                              },
                            })
                          }}
                        >
                          {t('shareComputerAudio')}
                          {!!meetingInfo.startSystemAudioLoopbackCapture && (
                            <svg
                              className="icon iconfont icongouxuan"
                              aria-hidden="true"
                            >
                              <use xlinkHref="#icongouxuan"></use>
                            </svg>
                          )}
                        </div>
                      ) : (
                        <div />
                      )
                    }
                  >
                    <span
                      className="screen-sharing-popover-button"
                      onClick={(e) => e.stopPropagation()}
                    >
                      <Divider
                        type="vertical"
                        style={{ borderColor: '#F51D45' }}
                      />
                      {screenSharingPopoverOpen ? (
                        <svg
                          style={{
                            color: '#F51D45',
                          }}
                          className="icon iconfont"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconjiantou-shang"></use>
                        </svg>
                      ) : (
                        <svg
                          style={{
                            color: '#F51D45',
                            transform: 'rotate(180deg)',
                          }}
                          className="icon iconfont"
                          aria-hidden="true"
                        >
                          <use xlinkHref="#iconjiantou-shang"></use>
                        </svg>
                      )}
                    </span>
                  </Popover>
                </div>
              ) : open ? (
                <EndButton />
              ) : null}
            </>
          )}
          <MemberNotify
            style={{
              top: '10px',
              right: '-15px',
            }}
            ref={memberNotifyRef}
            handleViewMsg={handleViewMsg}
            onNotNotify={onNotNotify}
          />
        </div>
      )}
    </Drawer>
  )
}

export default ControlBar
