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
  LocalRecordState,
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
import useDeviceChangeToast from '../../../hooks/useDeviceChangeToast'

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
let closeWhiteBoardModal
let closeScreenShareModal
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
  const { meetingInfo, memberList, inInvitingMemberList } =
    useMeetingInfoContext()
  const { dispatch: waitingRoomDispatch } = useWaitingRoomContext()
  const {
    neMeeting,
    outEventEmitter,
    eventEmitter,
    logger,
    showCloudRecordMenuItem,
    showLocalRecordMenuItem,
    showCloudRecordingUI,
    showLocalRecordingUI,
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
  const noMoreParticipantUpperLimitTipRef = useRef<boolean>(false)

  const lockButtonClickRef = useRef<Record<string, boolean>>({})
  const handUpModalRef = useRef<{
    destroy: () => void
    update: (configUpdate) => void
  }>()

  const muteTipsNeedShowRef = useRef(0)
  const stopScreenShareClickRef = useRef(false)

  const [securityPopoverOpen, setSecurityPopoverOpen] = useState(false)
  const [recordControlPopoverOpen, setRecordControlPopoverOpen] =
    useState(false)
  const [moreBtnOpen, setMoreBtnOpen] = useState(false)
  const [audioDeviceListOpen, setAudioDeviceListOpen] = useState(false)
  const [videoDeviceListOpen, setVideoDeviceListOpen] = useState(false)
  const [recordPopoverOpen, setRecordPopoverOpen] = useState(false)
  const [screenSharingPopoverOpen, setScreenSharingPopoverOpen] =
    useState(false)
  const [cameras, setCameras] = useState<NEDeviceBaseInfo[]>([])
  const [microphones, setMicrophones] = useState<NEDeviceBaseInfo[]>([])
  const [speakers, setSpeakers] = useState<NEDeviceBaseInfo[]>([])
  const [selectedCamera, setSelectedCamera] = useState<string>()
  const [selectedMicrophone, setSelectedMicrophone] = useState<string>()
  const [selectedSpeaker, setSelectedSpeaker] = useState<string>()
  const [isDarkMode, setIsDarkMode] = useState(true)
  const [handUpPopoverOpen, setHandUpPopoverOpen] = useState(false)
  const [openCaptionPopover, setOpenCaptionPopover] = useState(false)
  const [openLocalRecordPopover, setOpenLocalRecordPopover] = useState(false)
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
  const stopScreenShareRef = useRef<null | ReturnType<typeof setTimeout>>(null)
  const stopWhiteBoardRef = useRef<null | ReturnType<typeof setTimeout>>(null)

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

  const isLinux = useMemo(() => {
    return window.systemPlatform === 'linux'
  }, [])

  useDeviceChangeToast({
    microphones,
    speakers,
    selectedMicrophone,
    selectedSpeaker,
  })

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
          await neMeeting?.muteLocalAudio()
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
                error?.message ||
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
      console.info('lockButtonClick video', lockButtonClickRef.current['video'])
      return
    }

    lockButtonClickRef.current['video'] = true

    if (localMember.isVideoOn) {
      try {
        await neMeeting?.muteLocalVideo()
        // 本端断网情况也需要先关闭
      } finally {
        // 加下延迟，否则设置预览的时候预览会有问题
        if (window.isElectronNative) {
          setTimeout(() => {
            dispatch?.({
              type: ActionType.UPDATE_MEMBER,
              data: {
                uuid: localMember.uuid,
                member: { isVideoOn: false },
              },
            })
            lockButtonClickRef.current['video'] = false
          }, 1000)
        } else {
          dispatch?.({
            type: ActionType.UPDATE_MEMBER,
            data: {
              uuid: localMember.uuid,
              member: { isVideoOn: false },
            },
          })
          lockButtonClickRef.current['video'] = false
        }
      }

      return
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
              await neMeeting?.muteLocalVideo()
            } else {
              // web 下10223重复打开，不报错
              if (!window.isElectronNative && knownError.code === 10223) {
                lockButtonClickRef.current['video'] = false
                return
              }

              Toast.fail(
                knownError?.msg ||
                  knownError?.message ||
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
                ? isDarkMode
                  ? 'iconyinliang0'
                  : 'iconyinliang0hei'
                : isDarkMode
                ? '#iconkaiqimaikefeng-mianxing'
                : '#iconkaiqimaikefeng'
            }`}
          ></use>
        </svg>
      )
    ) : (
      <svg className="icon iconfont icon-red" aria-hidden="true">
        <use
          xlinkHref={`${
            isDarkMode ? '#iconkaiqiyinpin-mianxing' : '#iconkaiqiyinpin'
          }`}
        ></use>
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
              ? '#iconguanbishexiangtou-mianxing'
              : isDarkMode
              ? '#iconkaiqishexiangtou-mianxing'
              : '#iconkaiqishexiangtou'
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

  const localRecordPermissionItem = () => {
    return (
      <div className="device-list">
        <div
          className="device-item"
          key={t('localRecordPermissionForHost')}
          onClick={(event) => {
            event.stopPropagation()
            console.log('localRecordPermissionItem')
            setOpenLocalRecordPopover(false)
            neMeeting
              ?.securityControl({
                LOCAL_RECORD_PERMISSION_1: false,
                LOCAL_RECORD_PERMISSION_2: false,
              })
              .catch((e) => {
                Toast.fail(e.msg || e.message)
              })
          }}
        >
          <div className="device-item-label">
            {t('localRecordPermissionForHost')}
          </div>
          {!!meetingInfo?.localRecordPermission?.host && (
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
          key={t('localRecordPermissionForSome')}
          onClick={(event) => {
            event.stopPropagation()
            console.log('localRecordPermissionItem 发送录制权限请求')
            Toast.info(t('localRecordPermissionForSomeTip'))
            setOpenLocalRecordPopover(false)
            neMeeting
              ?.securityControl({
                LOCAL_RECORD_PERMISSION_1: false,
                LOCAL_RECORD_PERMISSION_2: true,
              })
              .catch((e) => {
                Toast.fail(e.msg || e.message)
              })
          }}
        >
          <div className="device-item-label">
            {t('localRecordPermissionForSome')}
          </div>
          {!!meetingInfo?.localRecordPermission?.some && (
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
          key={t('localRecordPermissionForAll')}
          onClick={(event) => {
            event.stopPropagation()
            console.log('localRecordPermissionItem')
            setOpenLocalRecordPopover(false)
            neMeeting
              ?.securityControl({
                LOCAL_RECORD_PERMISSION_1: true,
                LOCAL_RECORD_PERMISSION_2: true,
              })
              .catch((e) => {
                Toast.fail(e.msg || e.message)
              })
          }}
        >
          <div className="device-item-label">
            {t('localRecordPermissionForAll')}
          </div>
          {meetingInfo?.localRecordPermission?.all && (
            <svg
              className="icon iconfont iconcheck-line-regular1x-blue"
              aria-hidden="true"
            >
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          )}
        </div>
      </div>
    )
  }

  const securityItem = (key: SecurityItem) => {
    let action: SecurityCtrlEnum
    //console.log('securityItem key: ', key)
    let permission = !meetingInfo[key]
    let localRecordPermissionFlag = false

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
      case SecurityItem.localRecordPermission:
        localRecordPermissionFlag = true
        action = SecurityCtrlEnum.LOCAL_RECORD
        permission = !!meetingInfo[key]
        break
    }

    //console.log('securityItem localRecordPermissionFlag: ', localRecordPermissionFlag)
    const titleMap = {
      [SecurityItem.screenSharePermission]: t('screenShare'),
      [SecurityItem.unmuteAudioBySelfPermission]: t('unmuteAudioBySelf'),
      [SecurityItem.unmuteVideoBySelfPermission]: t('participantStartVideo'),
      [SecurityItem.updateNicknamePermission]: t('updateNicknameBySelf'),
      [SecurityItem.whiteboardPermission]: t('whiteboardShare'),
      [SecurityItem.annotationPermission]: t('annotation'),
      [SecurityItem.localRecordPermission]: t('localRecord'),
    }

    return (
      <div
        className="device-item"
        key={key}
        onClick={(event) => {
          event.stopPropagation()
          console.log(
            'securityControl localRecordPermissionFlag: ',
            localRecordPermissionFlag
          )
          console.log(
            'securityControl openLocalRecordPopover: ',
            openLocalRecordPopover
          )
          if (localRecordPermissionFlag) {
            setOpenLocalRecordPopover(!openLocalRecordPopover)
            return
          }

          neMeeting
            ?.securityControl({
              [action]: permission,
            })
            .catch((e) => {
              Toast.fail(e.msg || e.message)
            })
        }}
      >
        {key !== SecurityItem.localRecordPermission && (
          <div className="device-item-label">{titleMap[key]}</div>
        )}
        {!!meetingInfo[key] && !localRecordPermissionFlag && (
          <svg
            className="icon iconfont iconcheck-line-regular1x-blue"
            aria-hidden="true"
          >
            <use xlinkHref="#iconcheck-line-regular1x"></use>
          </svg>
        )}
        {localRecordPermissionFlag && (
          <Popover
            open={openLocalRecordPopover}
            onOpenChange={(open) => setOpenLocalRecordPopover(open)}
            autoAdjustOverflow={false}
            getTooltipContainer={(node) => node}
            arrow={false}
            trigger={['click']}
            rootClassName="security-popover device-popover"
            placement={'rightBottom'}
            title={t('localRecordPermissionSetting')}
            content={localRecordPermissionItem()}
          >
            <div className="local-record-popover-wrapper">
              <div
                className="device-item-label"
                style={{ marginLeft: 0, width: '100%' }}
              >
                {titleMap[key]}
              </div>
              <svg
                style={{
                  fontSize: '17px',
                  width: '17px',
                  color: '##8D90A0',
                }}
                className="icon iconfont device-item-label"
                aria-hidden="true"
              >
                <use xlinkHref="#iconyoujiantou-16px-2"></use>
              </svg>
            </div>
          </Popover>
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
                {securityItem(SecurityItem.localRecordPermission)}
              </div>
              <div
                onClick={stopMemberActivities}
                className="device-list-title suspend-participant-activity-title"
                style={{
                  color: '#f51d45',
                  justifyContent: 'center',
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
          <use xlinkHref="#iconanquan-mianxing"></use>
        </svg>
      </div>
    ),
    label: t('security'),
    onClick: () => {
      setSecurityPopoverOpen(!securityPopoverOpen)
    },
    hidden: localMember.hide || !isHostOrCoHost,
  }

  function isClearShareScreenAndAnnotationAvailble(): Promise<boolean>  {
    return new Promise((resolve) => {
      eventEmitter?.off(EventType.IsClearAnnotationAvailbleResult)
      eventEmitter?.on(EventType.IsClearAnnotationAvailbleResult, (data) => {
        console.warn('收到当前批注是否有绘制内容的结果: ', data)
        stopScreenShareRef.current && clearTimeout(stopScreenShareRef.current)
        resolve(data);
      })
      //增加一个定时器，超时5s认为获取失败
      stopScreenShareRef.current && clearTimeout(stopScreenShareRef.current)
      stopScreenShareRef.current = setTimeout(() => {
        stopScreenShareRef.current = null
        resolve(true)
      }, 5 * 1000)
      console.log('发送检查批注是否有绘制内容的指令')
      const annotationWindow = getWindow('annotationWindow')
      console.warn('发送批注是否有内容的指令 annotationWindow:', annotationWindow)
      annotationWindow?.postMessage({
        event: 'eventEmitter',
        payload: {
          key: EventType.IsClearAnnotationAvailble,
          args: [],
        },
      })
    })
  }

  function handleSaveShareScreenAndAnnotationPhoto(): Promise<{
    result: string,
    reason: string,
    openFileResult: boolean
  }> {
    return new Promise((resolve, reject) => {
      eventEmitter?.off(EventType.AnnotationSavePhotoDone)
      eventEmitter?.on(EventType.AnnotationSavePhotoDone, (data) => {
        console.warn('收到批注保存完成的通知: ', data)
        stopScreenShareRef.current && clearTimeout(stopScreenShareRef.current)
        if (data.result == 'failed') {
          reject(data);
        } else {
          resolve(data);
        }
      })
      stopScreenShareRef.current && clearTimeout(stopScreenShareRef.current)
      stopScreenShareRef.current = setTimeout(() => {
        stopScreenShareRef.current = null
        reject({
          result: 'failed',
          reason: 'save annotation timeout',
          openFileResult: false
        });
      }, 30 * 1000)
      const annotationWindow = getWindow('annotationWindow')
      console.warn('发送批注保存的指令 annotationWindow:', annotationWindow)
      annotationWindow?.postMessage({
        event: 'eventEmitter',
        payload: {
          key: EventType.AnnotationSavePhoto,
          args: [],
        },
      })
    })
  }

  const screenShareBtn = {
    id: 2,
    key: 'screenShare',
    icon: (
      <svg
        className={classNames('icon iconfont', {
          'icon-green': !localMember.isSharingScreen && isDarkMode,
          'icon-green-light': !localMember.isSharingScreen && !isDarkMode,
          'icon-red': localMember.isSharingScreen,
        })}
        aria-hidden="true"
      >
        <use
          xlinkHref={`${
            localMember.isSharingScreen
              ? '#icontingzhigongxiang'
              : '#icontouping-mianxing'
          }`}
        ></use>
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
          if (
            meetingInfoRef.current.setting.screenShareSetting
              ?.noMoreScreenShareMessage
          ) {
            shareScreen()
          } else {
            let notRemindMeAgain = false

            CommonModal.confirm({
              title: t('screenShare'),
              okText: t('yes'),
              cancelText: t('no'),
              content: (
                <>
                  <div>
                    {globalConfig?.appConfig?.APP_ROOM_RESOURCE?.screenShare
                      ?.message || t('screenShareWarning')}
                  </div>
                  <Checkbox
                    style={{
                      left: '24px',
                      bottom: '24px',
                      position: 'absolute',
                    }}
                    onChange={(e) => {
                      notRemindMeAgain = e.target.checked
                    }}
                  >
                    {t('notRemindMeAgain')}
                  </Checkbox>
                </>
              ),
              onOk: () => {
                const setting = meetingInfoRef.current.setting

                setting.screenShareSetting.noMoreScreenShareMessage =
                  notRemindMeAgain
                onSettingChange(setting)

                shareScreen()
              },
            })
          }
        }
      } else {
        shareScreen()
      }
    },
    hidden: localMember.hide || isElectronSharingScreen,
  }
  //停止白板共享
  const handleStopWhiteboard = async () => {
    try {
      closeWhiteBoardModal?.destroy()
      closeWhiteBoardModal = null
      try {
        await neMeeting?.whiteboardController?.logout()
      } catch (e) {
        console.warn('停止白板 logout失败: ', e)
      }
      await neMeeting?.whiteboardController?.stopWhiteboardShare()
      if (window.isElectronNative && meetingInfo.enableTransparentWhiteboard) {
        window.ipcRenderer
          ?.invoke(IPCEvent.whiteboardTransparentMirror, false)
          .catch((e) => {
            console.log('whiteboardTransparentMirror failed', e)
          })
      }
      neMeeting?.roomContext?.deleteRoomProperty('whiteboardConfig')
      console.warn('关闭白板后，检查cloudRecordState, whiteboardCloudRecord: ', meetingInfoRef.current.cloudRecordState, meetingInfoRef.current?.whiteboardCloudRecord)
      if (meetingInfoRef.current.cloudRecordState == RecordState.Recording && meetingInfoRef.current?.whiteboardCloudRecord) {
        whiteBoardStopPushStream()
      }
    } catch {
      Toast.fail(t('whiteBoardShareStopFail'))
    }
  }

  function isClearWhiteboardAvailble(): Promise<boolean>  {
    return new Promise((resolve) => {
      eventEmitter?.off(EventType.IsClearWhiteboardAvailbleResult)
      eventEmitter?.on(EventType.IsClearWhiteboardAvailbleResult, (data) => {
        console.warn('收到当前白板是否有绘制内容的结果: ', data)
        stopWhiteBoardRef.current && clearTimeout(stopWhiteBoardRef.current)
        resolve(data);
      })
      //增加一个定时器，超时5s认为获取失败
      stopWhiteBoardRef.current && clearTimeout(stopWhiteBoardRef.current)
      stopWhiteBoardRef.current = setTimeout(() => {
        stopWhiteBoardRef.current = null
        resolve(true)
      }, 5 * 1000)
      console.log('发送检查白板是否有绘制内容的指令')
      const dualMonitorsWindow = getWindow('dualMonitorsWindow')
      console.warn('当前是否存在双屏场景 dualMonitorsWindow:', dualMonitorsWindow)
      if (dualMonitorsWindow) {
        dualMonitorsWindow?.postMessage({
          event: 'eventEmitter',
          payload: {
            key: EventType.IsClearWhiteboardAvailble,
            args: [],
          },
        })
      }
      neMeeting?.eventEmitter?.emit(
        EventType.IsClearWhiteboardAvailble,
      )
    })
  }

  function handleSaveWhiteboardPhoto(): Promise<{
    result: string,
    reason: string,
    openFileResult: boolean
  }>  {
    return new Promise((resolve, reject) => {
      eventEmitter?.off(EventType.WhiteboardSavePhotoDone)
      eventEmitter?.on(EventType.WhiteboardSavePhotoDone, (data) => {
        console.warn('收到白板保存完成的通知')
        stopWhiteBoardRef.current && clearTimeout(stopWhiteBoardRef.current)
        if (data.result == 'failed') {
          reject(data);
        } else {
          resolve(data);
        }
      })
      //增加一个定时器，超时30s认为保存失败
      stopWhiteBoardRef.current && clearTimeout(stopWhiteBoardRef.current)
      stopWhiteBoardRef.current = setTimeout(() => {
        stopWhiteBoardRef.current = null
        reject({
          result: 'failed',
          reason: 'save whiteboard timeout',
          openFileResult: false
        });
      }, 30 * 1000)
      console.log('发送白板截图的指令')
      const dualMonitorsWindow = getWindow('dualMonitorsWindow')
      console.warn('当前是否存在双屏场景 dualMonitorsWindow:', dualMonitorsWindow)
      if (dualMonitorsWindow) {
        dualMonitorsWindow?.postMessage({
          event: 'eventEmitter',
          payload: {
            key: EventType.WhiteboardSavePhoto,
            args: [],
          },
        })
      }
      neMeeting?.eventEmitter?.emit(
        EventType.WhiteboardSavePhoto,
      )
    })
  }

  function whiteBoardStartPushStream(){
    if (window.isElectronNative) {
      return
    }
    //开启了云录制 && 加入房间时配置了白板云录制能力
    console.log('开启白板后，检查whiteboardCloudRecord: ', meetingInfo.cloudRecordState, meetingInfoRef.current?.whiteboardCloudRecord)
    console.log('开启白板后，检查isJoinedWhiteboard: ', neMeeting?.whiteboardController?.isJoinedWhiteboard)
    console.log('开启白板后，检查cloudRecordState: ', meetingInfoRef.current.cloudRecordState)
    if (meetingInfoRef.current.cloudRecordState == RecordState.Recording &&
      meetingInfoRef.current?.whiteboardCloudRecord &&
      neMeeting?.whiteboardController?.isJoinedWhiteboard) {

        //开始推流之前先停止推流，兼容重连场景
        whiteBoardStopPushStream()
      //获取到白板流，可以使用rtc推至服务器
      let limitFrameRate: VideoFrameRate = 5
      if (
        meetingInfoRef.current.setting.screenShareSetting
          ?.sharedLimitFrameRateEnable &&
        meetingInfoRef.current.setting.screenShareSetting
          ?.sharedLimitFrameRate
      ) {
        limitFrameRate = meetingInfoRef.current.setting.screenShareSetting
          .sharedLimitFrameRate as VideoFrameRate
      }
      const whiteBoardStream = neMeeting?.whiteboardController?.getStream?.({frameRate: limitFrameRate})
      console.log('获取白板流 whiteBoardStream: ', whiteBoardStream)
      if (whiteBoardStream && whiteBoardStream.getVideoTracks().length > 0) {
        neMeeting?.rtcController?.setEnableExternalScreenVideo?.(true)
        neMeeting?.rtcController?.pushExternalScreenVideoFrame?.(whiteBoardStream.getVideoTracks()[0])
        neMeeting?.unmuteLocalScreenShare({
          limitFrameRate,
          //白板使用音视频sdk的视频辅流通道传输白板数据，因此不需要通知服务器
          needRequestMeetingServerScreenShare: false
        })
      }
    } else if (
      meetingInfo.cloudRecordState != RecordState.Recording &&
      meetingInfoRef.current?.whiteboardCloudRecord &&
      neMeeting?.whiteboardController?.isJoinedWhiteboard
      ){
      //此时关闭了云录制，需要主动停止白板推流
      whiteBoardStopPushStream()
    }
  }

  function whiteBoardStopPushStream(){
    if (window.isElectronNative) {
      return
    }
    console.log('关闭白板推流')
    neMeeting?.muteLocalScreenShare({
      needRequestMeetingServerScreenShare: false
    })
    neMeeting?.whiteboardController?.stopStream?.()
  }

  //白板会控按钮
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
        <use xlinkHref="#iconbaiban-mianxing"></use>
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
        //关闭白板流程
        const isClearAvailble = await isClearWhiteboardAvailble()
        console.log('isClearAvailble: ', isClearAvailble)
        if (isClearAvailble) {
           // 停止白板需要增加二次确认弹框，用于提示是否保存白板截图
          // v4.11.0版本支持，需求稿:https://docs.popo.netease.com/lingxi/61ace73d775b42fdac74727bc7e5c381
          closeWhiteBoardModal?.destroy()
          closeWhiteBoardModal = null
          closeWhiteBoardModal = CommonModal.confirm({
            title: '',
            content: t('whiteBoardCloseModalContent'),
            focusTriggerAfterClose: false,
            transitionName: '',
            mask: false,
            afterClose: () => {
              closeWhiteBoardModal = null
            },
            width: 400,
            height: 200,
            wrapClassName: 'nemeeting-leave-or-end-meeting-modal',
            footer: (
              <div className="nemeeting-modal-confirm-btns">
                <Button
                  onClick={() =>{
                    closeWhiteBoardModal.destroy()
                    closeWhiteBoardModal = null
                    handleStopWhiteboard()
                  }}
                >
                  {t('whiteBoardCloseModalNotSaveButtonText')}
                </Button>
                <Button
                  onClick={() => {
                    closeWhiteBoardModal.destroy()
                    closeWhiteBoardModal = null
                  }}
                >
                  {t('globalCancel')}
                </Button>
                <Button type="primary"
                  onClick={() => {
                    console.log('点击导出白板')
                    closeWhiteBoardModal.destroy()
                    closeWhiteBoardModal = null
                    handleSaveWhiteboardPhoto().then((data)=>{
                      console.log('点击导出白板完成 data: ', data)
                      handleStopWhiteboard()
                    }).catch( (error) => {
                      console.log('点击导出白板完成 error: ', error)
                      if (error.result == 'failed') {
                        Toast.fail(error.reason)
                      }
                      handleStopWhiteboard()
                    })
                  }}
                >
                  {t('whiteBoardCloseModalSaveButtonText')}
                </Button>
              </div>
            ),
          })
        } else {
          handleStopWhiteboard()
        }
      } else {
        //开启白板流程
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

            if (neMeeting?.whiteboardController?.isJoinedWhiteboard) {
              whiteBoardStartPushStream()
            } else {
              eventEmitter?.off(EventType.OnWhiteboardConnected)
              eventEmitter?.on(EventType.OnWhiteboardConnected, () => {
                console.warn('收到白板加入房间成功的结果')
                whiteBoardStartPushStream()
              })
            }

            // setTimeout(() => {
            //   //开启了云录制 && 加入房间时配置了白板云录制能力
            //   console.error('开启白板后，检查cloudRecordState, whiteboardCloudRecord: ', meetingInfo.cloudRecordState, meetingInfoRef.current?.whiteboardCloudRecord)
            //   if (meetingInfo.cloudRecordState == RecordState.Recording && meetingInfoRef.current?.whiteboardCloudRecord) {
            //     //获取到白板流，可以使用rtc推至服务器
            //     let limitFrameRate: VideoFrameRate = 5
            //     if (
            //       meetingInfoRef.current.setting.screenShareSetting
            //         ?.sharedLimitFrameRateEnable &&
            //       meetingInfoRef.current.setting.screenShareSetting
            //         ?.sharedLimitFrameRate
            //     ) {
            //       limitFrameRate = meetingInfoRef.current.setting.screenShareSetting
            //         .sharedLimitFrameRate as VideoFrameRate
            //     }
            //     const whiteBoardStream = neMeeting?.whiteboardController?.getStream?.({frameRate: limitFrameRate})
            //     console.log('获取白板流whiteBoardStream: ', whiteBoardStream)
            //     if (whiteBoardStream && whiteBoardStream.getVideoTracks().length > 0) {
            //       neMeeting?.rtcController?.setEnableExternalScreenVideo?.(true)
            //       neMeeting?.rtcController?.pushExternalScreenVideoFrame?.(whiteBoardStream.getVideoTracks()[0])
            //       neMeeting?.unmuteLocalScreenShare({
            //         limitFrameRate,
            //         //白板使用音视频sdk的视频辅流通道传输白板数据，因此不需要通知服务器
            //         needRequestMeetingServerScreenShare: false
            //       })
            //     }
            //   }
            // }, 3000)
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
          <use xlinkHref="#iconguanlicanhuizhe-mianxing"></use>
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

  const localRecordAvailable = useMemo(() => {
    console.info(
      '是否要显示本地录制按钮 localRecordPermission:',
      meetingInfoRef.current.localRecordPermission
    )
    console.info(
      '是否要显示本地录制按钮 localMember:',
      meetingInfoRef.current.localMember
    )
    let isLocalRecordAvailable = true

    if (meetingInfoRef.current.localRecordPermission?.host) {
      //房间录制权限为host，此时自己不是主持人或者联席主持人，没有本地录制设置权限
      if (
        meetingInfoRef.current.localMember.role !== Role.host &&
        meetingInfoRef.current.localMember.role !== Role.coHost
      ) {
        isLocalRecordAvailable = false
      }
    } else if (meetingInfoRef.current.localRecordPermission?.some) {
      //房间录制权限为部分人可录制，此时判断自己的成员属性localRecordAvailable
      isLocalRecordAvailable =
        meetingInfoRef.current.localMember.localRecordAvailable
    } else if (meetingInfoRef.current.localRecordPermission?.all) {
      //房间录制权限全体人可录制
      isLocalRecordAvailable = true
    }

    console.info(
      '是否要显示本地录制按钮 isLocalRecordAvailable:',
      isLocalRecordAvailable
    )
    return isLocalRecordAvailable
  }, [
    meetingInfo.localMember.role,
    meetingInfo.localMember.localRecordAvailable,
    meetingInfo.localRecordPermission,
  ])

  const canShowRecordPopover = useMemo(() => {
    if (isHostOrCoHost) {
      return (
        window.isElectronNative &&
        ((meetingInfo.isCloudRecording && meetingInfo.isLocalRecording) ||
          (!meetingInfo.isCloudRecording && !meetingInfo.isLocalRecording))
      )
    } else {
      return false
    }
  }, [
    isHostOrCoHost,
    meetingInfo.isCloudRecording,
    meetingInfo.isLocalRecording,
  ])

  const needStopRecord = useMemo(() => {
    if (meetingInfo.isLocalRecording) {
      return true
    }

    // 云录制开启
    if (meetingInfo.isCloudRecording) {
      // 如果只是开了云录制，只有主持人才能停止
      if (isHostOrCoHost) {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }, [
    isHostOrCoHost,
    meetingInfo.isLocalRecording,
    meetingInfo.isCloudRecording,
  ])
  const recordBtn = {
    id: 27,
    key: 'record',
    popover: canShowRecordPopover
      ? (children) => {
          return (
            <Popover
              destroyTooltipOnHide
              align={
                isElectronSharingScreen
                  ? { offset: [0, 5] }
                  : { offset: [0, -5] }
              }
              arrow={false}
              trigger={['click']}
              rootClassName="record-popover device-popover"
              open={recordControlPopoverOpen}
              getTooltipContainer={(node) => node}
              onOpenChange={(open) => {
                setRecordControlPopoverOpen(open)
              }}
              autoAdjustOverflow={false}
              placement={isElectronSharingScreen ? 'bottom' : 'top'}
              content={
                <>
                  {isHostOrCoHost &&
                    showCloudRecordMenuItem &&
                    globalConfig?.appConfig?.APP_ROOM_RESOURCE.record && (
                      <div
                        onClick={() => {
                          onDefaultButtonClick?.('cloudRecord')
                        }}
                        className="device-list-title suspend-participant-activity-title-item"
                      >
                        {meetingInfo.isCloudRecording
                          ? t('stopCloudRecord')
                          : t('startCloudRecord')}
                      </div>
                    )}
                  {localRecordAvailable &&
                    showLocalRecordMenuItem &&
                    globalConfig?.appConfig?.APP_ROOM_RESOURCE.localRecord && (
                      <div
                        onClick={() => {
                          onDefaultButtonClick?.('localRecord')
                          setRecordControlPopoverOpen(false)
                        }}
                        className="device-list-title suspend-participant-activity-title-item"
                      >
                        {meetingInfo.isLocalRecording
                          ? t('stopLocalRecord')
                          : t('startLocalRecord')}
                      </div>
                    )}
                </>
              }
            >
              {children}
            </Popover>
          )
        }
      : null,
    icon: (
      <svg
        className={classNames('icon iconfont', {
          'icon-red': needStopRecord,
        })}
        aria-hidden="true"
      >
        <use
          xlinkHref={`${
            needStopRecord
              ? '#icontingzhiluzhi-mianxing'
              : '#iconluzhi-mianxing'
          }`}
        ></use>
      </svg>
    ),
    onClick: async () => {
      if (canShowRecordPopover) {
        setRecordControlPopoverOpen(!recordControlPopoverOpen)
      } else {
        if (window.isElectronNative) {
          if (isHostOrCoHostRef.current) {
            if (meetingInfo.isCloudRecording) {
              onDefaultButtonClick?.('cloudRecord')
            } else if (meetingInfo.isLocalRecording) {
              onDefaultButtonClick?.('localRecord')
            }
          } else {
            onDefaultButtonClick?.('localRecord')
          }
        } else {
          // web只有云录制
          onDefaultButtonClick?.('cloudRecord')
        }
      }
    },
    hidden: !(
      //云录制的要求
      (
        (showCloudRecordMenuItem &&
          globalConfig?.appConfig?.APP_ROOM_RESOURCE.record &&
          isHostOrCoHostRef.current) ||
        //本地录制的要求
        (localRecordAvailable &&
          showLocalRecordMenuItem &&
          window.isElectronNative &&
          globalConfig?.appConfig?.APP_ROOM_RESOURCE.localRecord)
      )
    ),
    label: needStopRecord ? t('stopRecord') : t('record'), //此时文案应该是录制（包含云录制和本地录制）
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
          <use xlinkHref="#iconliaotian-mianxing"></use>
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
        <use xlinkHref="#iconyaoqing-mianxing"></use>
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
          <use xlinkHref="#icontongzhi-mianxing"></use>
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

  const isMeetingLiveOfficialPushSupported =
    globalConfig?.appConfig?.APP_LIVE?.officialPushEnabled

  const isMeetingLiveThirdPartyPushSupported =
    globalConfig?.appConfig?.APP_LIVE?.thirdPartyPushEnabled

  const isMeetingLiveSupported = globalConfig?.appConfig.APP_ROOM_RESOURCE.live

  const isLiveBtnSupported =
    neMeeting?.liveController?.isSupported &&
    isHostOrCoHost &&
    isMeetingLiveSupported &&
    (isMeetingLiveOfficialPushSupported || isMeetingLiveThirdPartyPushSupported)

  const liveBtn = {
    id: 25,
    key: 'live',
    icon: (
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref="#iconzhibo-mianxing"></use>
      </svg>
    ),
    label: t('live'),
    onClick: async () => {
      onDefaultButtonClick?.('live')
    },
    hidden: !isLiveBtnSupported,
  }

  const settingBtn = {
    id: 28,
    key: 'setting',
    icon: (
      <svg className="icon iconfont" aria-hidden="true">
        <use xlinkHref="#iconshezhi-mianxing"></use>
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
        <use xlinkHref="#icontongshengchuanyi-mianxing"></use>
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
                setMoreBtnOpen(false)
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
          fresh
          content={translationOptionsContent}
          title={null}
          trigger="click"
          placement="right"
        >
          <div
            className="nemeeting-caption-enable-member-wrapper"
            onClick={(e) => {
              e.stopPropagation()
              e.preventDefault()
            }}
          >
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
    translationOptionsContent,
  ])
  // 字幕
  const captionBtn = {
    id: 32,
    key: 'caption',
    icon: (
      <div className="nemeeting-more-caption">
        <svg className="icon iconfont" aria-hidden="true">
          <use
            xlinkHref={
              meetingInfo.isCaptionsEnabled
                ? isDarkMode
                  ? '#iconguanbizimu-mianxing'
                  : '#iconguanbizimu'
                : '#iconkaiqizimu-mianxing'
            }
          ></use>
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
        <use xlinkHref="#iconshishizhuanxie-mianxing"></use>
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
        <use xlinkHref="#iconwentifankui-mianxing"></use>
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
        screenMember?.clientType === NEClientType.PC ||
        screenMember?.clientType === NEClientType.LINUX
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
    hidden:
      localMember.hide ||
      !isAnnotationBtnShow ||
      window.systemPlatform === 'linux',
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
        if (![3, 21, 20, 25, 29, 30, 31, 32, 33, 34].includes(item.id)) {
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
      <Badge
        dot={
          meetingInfo.notificationMessages.filter((msg) => msg.unRead).length >
          0
        }
      >
        <svg className="icon iconfont" aria-hidden="true">
          <use xlinkHref="#icongengduo-mianxing"></use>
        </svg>
      </Badge>
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
                  console.log('结束会议了00')
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
        meetingInfoRef.current.setting.videoSetting.isDefaultDevice

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
        meetingInfoRef.current.setting.audioSetting.recordDeviceId
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
        meetingInfoRef.current.setting.audioSetting.playoutDeviceId
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
              type === 'video' && !isLinux && (
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
        try {
          neMeeting?.annotationController?.logout()
        } catch (e) {
          console.log('停止批注 logout error: ', e)
        }
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'stop',
        })
        await neMeeting?.muteLocalScreenShare()
        stopScreenShareClickRef.current = true
        closeScreenShareModal?.destroy()
        closeScreenShareModal = null
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
          waitingRoomDispatch?.({
            type: ActionType.WAITING_ROOM_UPDATE_INFO,
            data: {
              info: {
                memberCount: memberCount,
              },
            },
          })
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

    eventEmitter?.on(UserEventType.HostCloseWhiteShareOrScreenShare, () => {
      closeWhiteBoardModal?.destroy()
      closeWhiteBoardModal = null
      closeScreenShareModal?.destroy()
      closeScreenShareModal = null
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
      const doms = document.querySelectorAll(
        '.nemeeting-sharing-screen .nemeeting-drawer-content .control-bar-button-list .control-bar-button-item-box'
      )

      let width = 340

      if (i18n.language === 'en-US') {
        width = 400
      } else if (i18n.language === 'ja-JP') {
        width = 420
      }

      width += doms.length * 70

      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
        method: 'controlBarVisibleChangeByMouse',
        data: {
          open: isElectronSharingScreenToolsShowRef.current,
          width: width,
        },
      })
    }
  }, [isElectronSharingScreen, isHostOrCoHost, i18n.language, recordBtn.hidden])

  //controlBar在屏幕共享场下，需要调整高度
  useEffect(() => {
    if (isElectronSharingScreen) {
      if (
        videoDeviceListOpen ||
        audioDeviceListOpen ||
        securityPopoverOpen ||
        moreBtnOpen ||
        screenSharingPopoverOpen ||
        recordControlPopoverOpen
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
    recordControlPopoverOpen,
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
  }, [isElectronSharingScreen, isHostOrCoHost, handUpCount])

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
    if (cloudRecord === RecordState.Recording) {
      whiteBoardStartPushStream()
    } else {
      whiteBoardStopPushStream()
    }
    return (
      (cloudRecord === RecordState.Recording ||
        cloudRecord === RecordState.Starting) &&
      showCloudRecordingUI
    )
  }, [meetingInfo.cloudRecordState, showCloudRecordingUI])

  const showLocalRecordUI = useMemo(() => {
    const localRecord = meetingInfo.localRecordState

    return (
      (localRecord === LocalRecordState.Recording ||
        localRecord === LocalRecordState.Starting) &&
      showLocalRecordingUI
    )
  }, [meetingInfo.localRecordState, showLocalRecordingUI])

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

        if (!noMoreParticipantUpperLimitTipRef.current) {
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
                      noMoreParticipantUpperLimitTipRef.current =
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
                <use xlinkHref="#iconguanbishexiangtou-mianxing"></use>
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
        <div
          className={classNames('control-bar-button-list', {
            ['screen-sharing-small-bar']:
              !isElectronSharingScreenToolsShow && isElectronSharingScreen,
          })}
        >
          {isElectronSharingScreen && (
            <div
              className={classNames('control-bar-meeting-info', {
                ['control-bar-meeting-info-small']:
                  !isElectronSharingScreenToolsShow,
                ['control-bar-meeting-info-border']:
                  isElectronSharingScreenToolsShow,
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
                        {meetingInfoRef.current.cloudRecordState === RecordState.Recording
                          ? t('recording')
                          : t('startingRecording')}
                      </span>
                    </div>
                  )}
                  {showLocalRecordUI && (
                    <div className="sharing-screen-record">
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconbendiluzhi1"></use>
                      </svg>
                      <span className="sharing-screen-record-title">
                        {meetingInfo.localRecordState ===
                        LocalRecordState.Recording
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
          {meetingInfo.endMeetingAction === 1 && isHost ? null : (
            <>
              {isObserver
                ? null
                : buttons.map((button) => {
                    const content = (
                      <>
                        <div
                          className={classNames('control-bar-button-item', {
                            'control-bar-button-item-display-none':
                              isElectronSharingScreen &&
                              !isElectronSharingScreenToolsShow,
                          })}
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
                            'control-bar-button-item-display-none':
                              isElectronSharingScreen &&
                              !isElectronSharingScreenToolsShow,
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
                <div
                  className={classNames('control-bar-stop-sharing-button', {
                    'control-bar-button-item-display-none':
                      isElectronSharingScreen &&
                      !isElectronSharingScreenToolsShow,
                  })}
                >
                  <span onClick={ async () => {
                    const isClearAvailble =  await isClearShareScreenAndAnnotationAvailble()
                    if (isClearAvailble) {
                      // 当存在批注时，停止屏幕共享需要增加二次确认弹框，用于提示是否保存批注内容
                      // v4.11.0版本支持，需求稿:https://docs.popo.netease.com/lingxi/61ace73d775b42fdac74727bc7e5c381
                      closeScreenShareModal?.destroy()
                      closeScreenShareModal = null
                      closeScreenShareModal = CommonModal.confirm({
                        title: '',
                        content: t('screenShareCloseModalContent'),
                        focusTriggerAfterClose: false,
                        transitionName: '',
                        mask: false,
                        afterClose: () => {
                          closeScreenShareModal = null
                        },
                        width: 400,
                        wrapClassName: 'nemeeting-leave-or-end-meeting-modal',
                        footer: (
                          <div className="nemeeting-modal-confirm-btns">
                            <Button
                              danger
                              onClick={() =>{
                                closeScreenShareModal.destroy()
                                closeScreenShareModal = null
                                shareScreen()
                              }}
                            >
                              {t('screenShareCloseModalExitButtonText')}
                            </Button>
                            <Button type="primary"
                              onClick={ () => {
                                console.warn('点击保存批注')
                                closeScreenShareModal.destroy()
                                closeScreenShareModal = null
                                handleSaveShareScreenAndAnnotationPhoto().then((data)=>{
                                  console.log('点击保存批注完成, data: ', data)
                                  shareScreen()
                                }).catch (error => {
                                  console.log('点击保存批注完成, error: ', error)
                                  if (error.result == 'failed') {
                                    Toast.fail(error.reason)
                                  }
                                  shareScreen()
                                })
                              }}
                            >
                              {t('screenShareCloseModalSaveButtonText')}
                            </Button>
                          </div>
                        ),
                      })
                    } else {
                      shareScreen()
                    }
                  }}>{t('screenShareStop')}</span>
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
                                startSystemAudioLoopbackCapture:
                                  !meetingInfo.startSystemAudioLoopbackCapture,
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
