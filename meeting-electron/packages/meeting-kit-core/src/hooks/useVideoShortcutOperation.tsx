// 快捷操作

import React, { useCallback, useEffect, useMemo, useRef } from 'react'
import { NEClientType, NEMember, Role } from '../types/type'
import { Checkbox, MenuProps } from 'antd'
import { useTranslation } from 'react-i18next'
import { useGlobalContext, useMeetingInfoContext } from '../store'
import {
  ActionType,
  hostAction,
  MeetingEventType,
  memberAction,
} from '../types'
import Toast from '../components/common/toast'
import { errorCodeMap } from '../config'
import CommonModal from '../components/common/CommonModal'
import { setLocalStorageSetting } from '../utils'
import { IPCEvent } from '../app/src/types'

enum ItemType {
  muteAudio = 'muteAudio',
  muteVideo = 'muteVideo',
  muteAudioAndVideo = 'muteAudioAndVideo',
  virtualBackground = 'virtualBackground',
  beauty = 'beauty',
  pinVideo = 'pinVideo',
  focusVideo = 'focusVideo',
  videoOffAttendees = 'videoOffAttendees',
  hideMyVideo = 'hideMyVideo',
  rename = 'rename',
  chatPrivate = 'chatPrivate',
  stopSharingScreen = 'stopSharingScreen',
  transferHost = 'transferHost',
  handsUpDown = 'handsUpDown',
  reclaimHost = 'reclaimHost',
  setCoHost = 'setCoHost',
  unSetCoHost = 'unSetCoHost',
  moveToWaitingRoom = 'moveToWaitingRoom',
  removeMember = 'removeMember',
}

export function useMemberOperationHandle() {
  const { t } = useTranslation()
  const { neMeeting } = useGlobalContext()

  // 移入等候室
  const moveToWaitingRoom = useCallback(async (data: NEMember) => {
    try {
      await neMeeting?.putInWaitingRoom(data.uuid)
    } catch (err: unknown) {
      const knownError = err as { message: string; msg: string }

      Toast.fail(knownError?.msg || knownError?.message)
    }
  }, [])

  // 手放下
  const rejectHandsUp = useCallback(async (data: NEMember) => {
    try {
      await neMeeting?.sendHostControl(hostAction.rejectHandsUp, data.uuid)
    } catch {
      Toast.fail(t('participantFailedToLowerHand'))
    }
  }, [])

  // 静音
  const muteMemberAudio = useCallback(
    async (data: NEMember, isMySelf: boolean) => {
      try {
        if (isMySelf) {
          await neMeeting?.muteLocalAudio()
        } else {
          await neMeeting?.sendHostControl(
            hostAction.muteMemberAudio,
            data.uuid
          )
        }
      } catch (e) {
        const knownError = e as { message: string; msg: string }

        Toast.fail(
          knownError.message || knownError.msg || t('participantMuteAudioFail')
        )
      }
    },
    []
  )

  // 解除静音
  const unmuteMemberAudio = useCallback(
    async (data: NEMember, isMySelf: boolean) => {
      try {
        if (isMySelf) {
          await neMeeting?.unmuteLocalAudio()
        } else {
          await neMeeting?.sendHostControl(
            hostAction.unmuteMemberAudio,
            data.uuid
          )
        }
      } catch (err: unknown) {
        const knownError = err as {
          message: string
          msg: string
          code: number
        }

        Toast.fail(
          knownError?.msg ||
            t(errorCodeMap[knownError?.code] || 'unMuteAudioFail')
        )
      }
    },
    []
  )

  // 关闭视频
  const muteMemberVideo = useCallback(
    async (data: NEMember, isMySelf: boolean) => {
      try {
        if (isMySelf) {
          await neMeeting?.muteLocalVideo()
        } else {
          await neMeeting?.sendHostControl(
            hostAction.muteMemberVideo,
            data.uuid
          )
        }
      } catch {
        Toast.fail(t('participantMuteVideoFail'))
      }
    },
    []
  )

  // 开启视频
  const unmuteMemberVideo = useCallback(
    async (data: NEMember, isMySelf: boolean) => {
      try {
        if (isMySelf) {
          await neMeeting?.unmuteLocalVideo()
        } else {
          await neMeeting?.sendHostControl(
            hostAction.unmuteMemberVideo,
            data.uuid
          )
        }
      } catch (err: unknown) {
        const knownError = err as {
          message: string
          msg: string
          code: number
        }

        Toast.fail(
          knownError?.msg ||
            t(errorCodeMap[knownError?.code] || 'participantUnMuteVideoFail')
        )
      }
    },
    []
  )

  // 开启音视频
  const unmuteVideoAndAudio = useCallback(
    async (data: NEMember, isMySelf: boolean) => {
      try {
        if (isMySelf) {
          await neMeeting?.unmuteLocalAudio()
          await neMeeting?.unmuteLocalVideo()
        } else {
          await neMeeting?.sendHostControl(
            hostAction.unmuteVideoAndAudio,
            data.uuid
          )
        }
      } catch (error: unknown) {
        const knownError = error as {
          message: string
          msg: string
          code: number
        }

        Toast.fail(
          knownError?.msg ||
            t(errorCodeMap[knownError?.code] || knownError?.code)
        )
      }
    },
    []
  )

  // 关闭共享
  const closeScreenShare = useCallback((data: NEMember) => {
    CommonModal.confirm({
      key: 'screenShareStop',
      title: t('screenShareStop'),
      content: t('closeCommonTips') + t('closeScreenShareTips'),
      onOk: async () => {
        try {
          await neMeeting?.sendHostControl(
            data.isSharingSystemAudio
              ? hostAction.closeAudioShare
              : hostAction.closeScreenShare,
            data.uuid
          )
        } catch {
          Toast.fail(t('screenShareStopFail'))
        }
      },
    })
  }, [])

  // 移交主持人
  const transferHost = useCallback((data: NEMember) => {
    CommonModal.confirm({
      title: t('participantTransferHost'),
      content: t('participantTransferHostConfirm', {
        userName: data.name,
      }),
      onOk: async () => {
        try {
          await neMeeting?.sendHostControl(hostAction.transferHost, data.uuid)
        } catch {
          Toast.fail(t('participantFailedToTransferHost'))
        }
      },
    })
  }, [])

  // 撤回主持人
  const takeBackTheHost = useCallback(async (data: NEMember) => {
    try {
      await neMeeting?.sendMemberControl(
        memberAction.takeBackTheHost,
        data.uuid
      )
    } catch {
      Toast.fail(t('meetingReclaimHostFailed'))
    }
  }, [])

  // 撤销联席主持人
  const unSetCoHost = useCallback(async (data: NEMember) => {
    try {
      await neMeeting?.sendHostControl(hostAction.unSetCoHost, data.uuid)
    } catch (err: unknown) {
      const knownError = err as { message: string; msg: string }

      Toast.fail(knownError.message || knownError.msg)
    }
  }, [])

  // 设置联席主持人
  const setCoHost = useCallback(async (data: NEMember) => {
    try {
      await neMeeting?.sendHostControl(hostAction.setCoHost, data.uuid)
    } catch (err: unknown) {
      const knownError = err as {
        message: string
        msg: string
        code: number
      }

      if (knownError.code === 1002) {
        Toast.fail(t('coHostLimit'))
      } else {
        Toast.fail(knownError.message || knownError.msg)
      }
    }
  }, [])

  const removeDialog = useCallback(
    (data: NEMember, enableBlacklist: boolean) => {
      let isChecked = false

      CommonModal.confirm({
        title: t('participantRemove'),
        width: 400,
        content: (
          <>
            <div>{t('participantRemoveConfirm') + data.name}</div>
            {enableBlacklist && (
              <Checkbox
                className="close-checkbox-tip"
                onChange={(e) => (isChecked = e.target.checked)}
                style={{ marginTop: '10px' }}
              >
                {t('meetingNotAllowedToRejoin')}
              </Checkbox>
            )}
          </>
        ),
        onOk: async () => {
          try {
            await neMeeting?.sendHostControl(
              hostAction.remove,
              data.uuid,
              isChecked
            )
          } catch (err: unknown) {
            const knownError = err as { message: string; msg: string }

            Toast.fail(
              knownError?.msg ||
                knownError?.message ||
                t('participantFailedToRemove')
            )
          }
        },
      })
    },
    []
  )

  return {
    moveToWaitingRoom,
    rejectHandsUp,
    muteMemberAudio,
    unmuteMemberAudio,
    muteMemberVideo,
    unmuteMemberVideo,
    unmuteVideoAndAudio,
    closeScreenShare,
    transferHost,
    takeBackTheHost,
    unSetCoHost,
    setCoHost,
    removeDialog,
  }
}

export function useElectronShortcutOperation() {
  const { meetingInfo } = useMeetingInfoContext()
  const { handleItemClick } = useHandleItemClick()
  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo

  useEffect(() => {
    if (window.isElectronNative) {
      window.ipcRenderer?.on(IPCEvent.popoverItemClick, (_, item) => {
        handleItemClick(
          item.key,
          item.member,
          meetingInfoRef.current.localMember.uuid === item.member.uuid
        )
      })
      return () => {
        window.ipcRenderer?.removeAllListeners(IPCEvent.popoverItemClick)
      }
    }
  }, [])
}

function useHandleItemClick() {
  const { meetingInfo, dispatch } = useMeetingInfoContext()
  const { neMeeting, eventEmitter } = useGlobalContext()
  const { t } = useTranslation()
  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo
  const {
    moveToWaitingRoom,
    rejectHandsUp,
    muteMemberAudio,
    unmuteMemberAudio,
    muteMemberVideo,
    unmuteMemberVideo,
    unmuteVideoAndAudio,
    closeScreenShare,
    transferHost,
    takeBackTheHost,
    unSetCoHost,
    removeDialog,
    setCoHost,
  } = useMemberOperationHandle()

  const handleItemClick = useCallback(
    async (key: ItemType, member: NEMember, isMySelf) => {
      console.log('handleItemClick', key)
      switch (key) {
        case ItemType.muteAudio:
          if (member.isAudioOn) {
            muteMemberAudio(member, isMySelf)
          } else {
            unmuteMemberAudio(member, isMySelf)
          }

          break
        case ItemType.muteVideo:
          if (member.isVideoOn) {
            muteMemberVideo(member, isMySelf)
          } else {
            unmuteMemberVideo(member, isMySelf)
          }

          break
        case ItemType.muteAudioAndVideo:
          if (member.isAudioOn && member.isVideoOn) {
            try {
              await neMeeting?.sendHostControl(
                hostAction.muteVideoAndAudio,
                member.uuid
              )
            } catch (e) {
              console.log('muteAudioAndVideo error', e)
            }
          } else {
            unmuteVideoAndAudio(member, isMySelf)
          }

          break
        case ItemType.virtualBackground:
          neMeeting?.openSettingsWindow('beauty', 'virtual')
          break
        case ItemType.beauty:
          neMeeting?.openSettingsWindow('beauty')
          break
        case ItemType.pinVideo:
          if (meetingInfoRef.current.pinVideoUuid === member.uuid) {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                pinVideoUuid: '',
              },
            })
          } else {
            dispatch?.({
              type: ActionType.UPDATE_MEETING_INFO,
              data: {
                pinVideoUuid: member.uuid,
              },
            })
          }

          break
        case ItemType.focusVideo:
          if (meetingInfoRef.current.focusUuid === member.uuid) {
            try {
              await neMeeting?.sendHostControl(
                hostAction.unsetFocus,
                member.uuid
              )
            } catch {
              Toast.fail(t('participantFailedToUnassignActiveSpeaker'))
            }
          } else {
            try {
              await neMeeting?.sendHostControl(hostAction.setFocus, member.uuid)
            } catch {
              Toast.fail(t('participantFailedToAssignActiveSpeaker'))
            }
          }

          break
        case ItemType.videoOffAttendees: {
          const setting = meetingInfoRef.current.setting

          setting.videoSetting.enableHideVideoOffAttendees = !setting
            .videoSetting.enableHideVideoOffAttendees
          setLocalStorageSetting(JSON.stringify(setting))
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              setting,
            },
          })
          break
        }

        case ItemType.hideMyVideo: {
          const setting = meetingInfoRef.current.setting

          setting.videoSetting.enableHideMyVideo = !setting.videoSetting
            .enableHideMyVideo
          setLocalStorageSetting(JSON.stringify(setting))
          dispatch?.({
            type: ActionType.UPDATE_MEETING_INFO,
            data: {
              setting,
            },
          })
          break
        }

        case ItemType.rename:
          eventEmitter?.emit(MeetingEventType.updateNickname, {
            uuid: member.uuid,
            name: member.name,
            roomType: 'room',
          })
          break
        case ItemType.chatPrivate:
          neMeeting?.sendMemberControl(memberAction.privateChat, member.uuid)
          break
        case ItemType.stopSharingScreen:
          closeScreenShare(member)
          break
        case ItemType.transferHost:
          transferHost(member)
          break
        case ItemType.handsUpDown:
          rejectHandsUp(member)
          break
        case ItemType.reclaimHost:
          takeBackTheHost(member)
          break
        case ItemType.setCoHost:
          setCoHost(member)
          break
        case ItemType.unSetCoHost:
          unSetCoHost(member)
          break
        case ItemType.moveToWaitingRoom:
          moveToWaitingRoom(member)
          break
        case ItemType.removeMember:
          removeDialog(member, !!meetingInfoRef.current.enableBlacklist)
          break
      }
    },
    [
      moveToWaitingRoom,
      rejectHandsUp,
      muteMemberAudio,
      unmuteMemberAudio,
      muteMemberVideo,
      unmuteMemberVideo,
      unmuteVideoAndAudio,
      closeScreenShare,
      transferHost,
      takeBackTheHost,
      unSetCoHost,
      setCoHost,
      removeDialog,
    ]
  )

  return {
    handleItemClick,
  }
}

export default function useVideoShortcutOperation(param: {
  member: NEMember
  isMySelf: boolean
  isSecondMonitor?: boolean // 是否副屏
}): {
  operatorItems: MenuProps['items']
} {
  const { member, isMySelf, isSecondMonitor } = param
  const { t } = useTranslation()
  const { meetingInfo, memberList } = useMeetingInfoContext()
  const { noChat, globalConfig } = useGlobalContext()

  const { handleItemClick } = useHandleItemClick()

  const meetingInfoRef = useRef(meetingInfo)

  meetingInfoRef.current = meetingInfo

  const memberRef = useRef(member)

  memberRef.current = member

  const isHost = useMemo(() => {
    return meetingInfo.localMember.role === Role.host
  }, [meetingInfo.localMember.role])
  const isCoHost = useMemo(() => {
    return meetingInfo.localMember.role === Role.coHost
  }, [meetingInfo.localMember.role])

  const isHostOrCoHost = useMemo(() => {
    return isHost || isCoHost
  }, [isHost, isCoHost])

  const isLinux = useMemo(() => {
    return window.systemPlatform === 'linux'
  }, [])

  const privateChatItemShow = useMemo(() => {
    // 自己不显示私聊
    if (member.uuid === meetingInfo.localMember.uuid) {
      return false
    }

    if (
      member.clientType === NEClientType.SIP ||
      member.clientType === NEClientType.H323
    ) {
      return false
    }

    if (isHostOrCoHost) {
      return true
    }

    // 会议中的聊天权限
    if (meetingInfo.meetingChatPermission === 4) {
      return false
    }

    if (member.role === Role.host || member.role === Role.coHost) {
      return true
    }

    if (meetingInfo.meetingChatPermission === 1) {
      return true
    }

    return false
  }, [meetingInfo.localMember, meetingInfo.meetingChatPermission, member])

  const isOverCohostLimitCount = useMemo(() => {
    let count = 0

    const maxCount =
      globalConfig?.appConfig.MEETING_SCHEDULED_MEMBER_CONFIG?.coHostLimit || 5

    memberList.some((member) => {
      if (member.role === Role.coHost) {
        count++
      }

      return count >= maxCount
    })
    return count >= maxCount
  }, [
    memberList,
    globalConfig?.appConfig.MEETING_SCHEDULED_MEMBER_CONFIG?.coHostLimit,
  ])

  const operatorItems: MenuProps['items'] & {
    member: NEMember
  } = useMemo(() => {
    const muteAudioItem = {
      key: ItemType.muteAudio,
      label: member.isAudioOn ? t('participantMute') : t('participantUnmute'),
      show: isMySelf || isHostOrCoHost,
      onClick: () => handleItemClick(ItemType.muteAudio, member, isMySelf),
      member: member,
    }
    const muteVideoItem = {
      key: ItemType.muteVideo,
      label: member.isVideoOn
        ? t('participantStopVideo')
        : t('participantStartVideo'),
      show: isMySelf || isHostOrCoHost,
      onClick: () => handleItemClick(ItemType.muteVideo, member, isMySelf),
      member: member,
    }
    const muteAudioAndVideoItem = {
      key: ItemType.muteAudioAndVideo,
      label:
        member.isAudioOn && member.isVideoOn
          ? t('participantTurnOffAudioAndVideo')
          : t('unmuteVideoAndAudio'),
      show: isMySelf || isHostOrCoHost,
      onClick: () =>
        handleItemClick(ItemType.muteAudioAndVideo, member, isMySelf),
      member: member,
    }
    const virtualBackgroundItem = {
      key: ItemType.virtualBackground,
      label: t('meetingSetVirtualBackground'),
      show: window.isElectronNative && isMySelf && !isLinux,
      onClick: () =>
        handleItemClick(ItemType.virtualBackground, member, isMySelf),
      member: member,
    }

    const beautyItem = {
      key: ItemType.beauty,
      label: t('meetingSetBeauty'),
      show: window.isElectronNative && isMySelf && !isLinux,
      onClick: () => handleItemClick(ItemType.beauty, member, isMySelf),
      member: member,
    }
    const pinVideo = {
      key: ItemType.pinVideo,
      label:
        meetingInfo.pinVideoUuid === member.uuid
          ? t('meetingUnpin')
          : t('meetingPinView'),
      show: true,
      onClick: () => handleItemClick(ItemType.pinVideo, member, isMySelf),
      member: member,
    }

    const focusVideo = {
      key: ItemType.focusVideo,
      label:
        meetingInfo.focusUuid === member.uuid
          ? t('participantUnassignActiveSpeaker')
          : t('participantAssignActiveSpeaker'),
      show: !meetingInfo.screenUuid,
      onClick: () => handleItemClick(ItemType.focusVideo, member, isMySelf),
      member: member,
    }
    // 隐藏显示非视频画面
    const videoOffAttendees = {
      key: ItemType.videoOffAttendees,
      label: meetingInfo.setting.videoSetting.enableHideVideoOffAttendees
        ? t('meetingShowVideoOffAttendees')
        : t('settingHideVideoOffAttendees'),
      show: isMySelf,
      onClick: () =>
        handleItemClick(ItemType.videoOffAttendees, member, isMySelf),
      member: member,
    }
    const hideMyVideo = {
      key: ItemType.hideMyVideo,
      label: meetingInfo.setting.videoSetting.enableHideMyVideo
        ? t('meetingShowMyVideo')
        : t('settingHideMyVideo'),
      show: isMySelf,
      onClick: () => handleItemClick(ItemType.hideMyVideo, member, isMySelf),
      member: member,
    }

    const rename = {
      key: ItemType.rename,
      label: t('noRename'),
      show: (isMySelf || isHostOrCoHost) && !isSecondMonitor,
      onClick: () => handleItemClick(ItemType.rename, member, isMySelf),
      member: member,
    }

    const chatPrivate = {
      key: ItemType.chatPrivate,
      label: t('chatPrivate'),
      show: privateChatItemShow && !noChat,
      onClick: () => handleItemClick(ItemType.chatPrivate, member, isMySelf),
      member: member,
    }

    const stopSharingScreen = {
      key: ItemType.stopSharingScreen,
      label: t('screenShareStop'),
      show: meetingInfo.screenUuid === member.uuid,
      onClick: () =>
        handleItemClick(ItemType.stopSharingScreen, member, isMySelf),
      member: member,
    }

    const transferHost = {
      key: ItemType.transferHost,
      label: t('participantTransferHost'),
      show:
        member.role !== Role.host &&
        member.clientType !== NEClientType.SIP &&
        member.clientType !== NEClientType.H323,
      onClick: () => handleItemClick(ItemType.transferHost, member, isMySelf),
      member: member,
    }
    // 手放下
    const handsUpDown = {
      key: ItemType.handsUpDown,
      label: t('handsUpDown'),
      show: member.isHandsUp && !isMySelf && isHostOrCoHost,
      onClick: () => handleItemClick(ItemType.handsUpDown, member, isMySelf),
      member: member,
    }
    // 移交主持人
    const reclaimHost = {
      key: ItemType.reclaimHost,
      label: t('meetingReclaimHost'),
      // 需要判断自己是否是主持人，是当前的会议拥有者
      show:
        meetingInfo.ownerUserUuid === meetingInfo.localMember.uuid &&
        member.role === Role.host,
      onClick: () => handleItemClick(ItemType.reclaimHost, member, isMySelf),
      member: member,
    }

    // 设置联席主持人
    const setCoHost = {
      key: ItemType.setCoHost,
      label: t('participantAssignCoHost'),
      show:
        member.role !== Role.host &&
        member.role !== Role.coHost &&
        !isOverCohostLimitCount &&
        member.clientType !== NEClientType.SIP &&
        member.clientType !== NEClientType.H323,
      onClick: () => handleItemClick(ItemType.setCoHost, member, isMySelf),
      member: member,
    }

    const unSetCoHost = {
      key: ItemType.unSetCoHost,
      label: t('participantUnassignCoHost'),
      show:
        member.role === Role.coHost &&
        member.clientType !== NEClientType.SIP &&
        member.clientType !== NEClientType.H323,
      onClick: () => handleItemClick(ItemType.unSetCoHost, member, isMySelf),
      member: member,
    }

    const divider = {
      type: 'divider',
      show: true,
    }

    const moveToWaitingRoom = {
      key: ItemType.moveToWaitingRoom,
      label: t('moveToWaitingRoom'),
      show:
        member.role !== Role.host &&
        member.role !== Role.coHost &&
        member.uuid !== meetingInfo.ownerUserUuid &&
        meetingInfo.isWaitingRoomEnabled &&
        member.uuid !== meetingInfo.localMember.uuid,
      onClick: () =>
        handleItemClick(ItemType.moveToWaitingRoom, member, isMySelf),
      member: member,
    }
    const removeMember = {
      key: ItemType.removeMember,
      label: t('participantRemove'),
      show:
        member.role !== Role.host &&
        member.role !== Role.coHost &&
        !isMySelf &&
        member.uuid !== meetingInfo.ownerUserUuid,
      onClick: () => handleItemClick(ItemType.removeMember, member, isMySelf),
      member: member,
    }


    if (isHost) {
      if (isMySelf) {
        return [
          muteAudioItem,
          muteVideoItem,
          muteAudioAndVideoItem,
          divider,
          virtualBackgroundItem,
          beautyItem,
          pinVideo,
          focusVideo,
          videoOffAttendees,
          hideMyVideo,
          divider,
          rename,
        ].filter((item) => item.show)
      } else {
        return [
          muteAudioItem,
          handsUpDown,
          muteVideoItem,
          muteAudioAndVideoItem,
          stopSharingScreen,
          divider,
          chatPrivate,
          divider,
          pinVideo,
          focusVideo,
          divider,
          transferHost,
          setCoHost,
          unSetCoHost,
          divider,
          rename,
          divider,
          moveToWaitingRoom,
          removeMember,
        ].filter((item) => item.show)
      }
    } else if (isCoHost) {
      if (isMySelf) {
        return [
          muteAudioItem,
          muteVideoItem,
          muteAudioAndVideoItem,
          divider,
          virtualBackgroundItem,
          beautyItem,
          pinVideo,
          focusVideo,
          videoOffAttendees,
          hideMyVideo,
          divider,
          rename,
        ].filter((item) => item.show)
      } else {
        // 操作主持人
        if (member.role === Role.host) {
          return [
            muteAudioItem,
            handsUpDown,
            muteVideoItem,
            muteAudioAndVideoItem,
            divider,
            chatPrivate,
            divider,
            pinVideo,
            focusVideo,
            divider,
            reclaimHost,
            divider,
            rename,
          ].filter((item) => item.show)
        } else if (member.role === Role.coHost) {
          return [
            muteAudioItem,
            handsUpDown,
            muteVideoItem,
            muteAudioAndVideoItem,
            divider,
            chatPrivate,
            divider,
            pinVideo,
            focusVideo,
            divider,
            rename,
          ].filter((item) => item.show)
        } else if (member.uuid === meetingInfo.ownerUserUuid) {
          // 操作创会者
          return [
            muteAudioItem,
            handsUpDown,
            muteVideoItem,
            muteAudioAndVideoItem,
            divider,
            chatPrivate,
            divider,
            pinVideo,
            focusVideo,
            divider,
            transferHost,
            setCoHost,
            unSetCoHost,
            divider,
            rename,
          ].filter((item) => item.show)
        } else {
          // 操作普通参会者
          return [
            muteAudioItem,
            handsUpDown,
            muteVideoItem,
            muteAudioAndVideoItem,
            stopSharingScreen,
            divider,
            chatPrivate,
            divider,
            pinVideo,
            focusVideo,
            divider,
            rename,
            divider,
            moveToWaitingRoom,
            removeMember,
          ].filter((item) => item.show)
        }
      }
    } else {
      if (isMySelf) {
        return [
          muteAudioItem,
          muteVideoItem,
          muteAudioAndVideoItem,
          divider,
          virtualBackgroundItem,
          beautyItem,
          pinVideo,
          videoOffAttendees,
          hideMyVideo,
          divider,
          rename,
        ].filter((item) => item.show)
      } else {
        // 如果本端是创会者，操作人员是主持人的时候需要有收回主持人
        if (
          meetingInfo.ownerUserUuid === meetingInfo.localMember.uuid &&
          member.role === Role.host
        ) {
          return [chatPrivate, divider, pinVideo, divider, reclaimHost].filter(
            (item) => item.show
          )
        } else {
          return [chatPrivate, divider, pinVideo].filter((item) => item.show)
        }
      }
    }
  }, [
    isMySelf,
    member.isAudioOn,
    member.isVideoOn,
    member.isHandsUp,
    member.role,
    member.name,
    member.clientType,
    member.uuid,
    meetingInfo.pinVideoUuid,
    meetingInfo.focusUuid,
    meetingInfo.ownerUserUuid,
    meetingInfo.isWaitingRoomEnabled,
    privateChatItemShow,
    isHostOrCoHost,
    isHost,
    isCoHost,
    noChat,
    meetingInfo.screenUuid,
    meetingInfo.setting.videoSetting.enableHideMyVideo,
    meetingInfo.setting.videoSetting.enableHideVideoOffAttendees,
  ])

  return {
    operatorItems,
  }
}
