import { useGlobalContext, useMeetingInfoContext } from '../store'
import { NEClientType, NEMember, NEMenuVisibility, Role } from '../kit'
import { useTranslation } from 'react-i18next'
import {
  NECheckableMenuItem,
  NESingleStateMenuItem,
  NEMeetingMenuItem,
} from '../kit/interface'
import { useMemo } from 'react'

export class NEActionMenuIDs {
  /// 内置"音频"菜单操作ID
  static audio = 100000
  /// 内置"视频"菜单操作ID，
  static video = 100001
  /// 内置"焦点视频"菜单操作ID，
  static focusVideo = 100002
  /// 内置"锁定视频"菜单操作ID，
  static lockVideo = 100003
  /// 内置"移交主持人"菜单操作ID，
  static changeHost = 100004
  /// 内置"收回主持人"菜单操作ID，
  static reclaimHost = 100005
  /// 内置"移除成员"菜单操作ID，
  static removeMember = 100006
  /// 内置"手放下"菜单操作ID，
  static rejectHandsUp = 100007
  /// 内置"白板互动"菜单操作ID，
  static whiteboardInteraction = 100008
  /// 内置"屏幕共享"菜单操作ID，
  static screenShare = 100009
  /// 内置"白板共享"菜单操作ID，
  static whiteBoardShare = 100010
  /// 内置"改名"菜单操作ID，
  static updateNick = 100011
  /// 内置"音视频"菜单操作ID，
  static audioAndVideo = 100012
  /// 内置"联席主持人"菜单操作ID，
  static coHost = 100013
  /// 内置"移至等候室"菜单操作ID，
  static putInWaitingRoom = 1000014
  /// 内置"私聊"菜单操作ID，
  static chatPrivate = 1000015
  /// 内置"本地录制"菜单操作ID，
  static localRecord = 1000016
}

function _isNESingleStateMenuItem(
  item: NEMeetingMenuItem
): item is NESingleStateMenuItem {
  return (<NESingleStateMenuItem>item).singleStateItem !== undefined
}

function _isNECheckableMenuItem(
  item: NEMeetingMenuItem
): item is NECheckableMenuItem {
  return (
    (<NECheckableMenuItem>item).checked !== undefined ||
    (<NECheckableMenuItem>item).checkedStateItem !== undefined ||
    (<NECheckableMenuItem>item).uncheckStateItem !== undefined
  )
}

const useMemberActionMenuItems = (member: NEMember) => {
  const { t } = useTranslation()
  const { noChat, globalConfig } = useGlobalContext()
  const { meetingInfo } = useMeetingInfoContext()

  const localMember = meetingInfo.localMember
  const localMemberRole = meetingInfo.localMember.role
  const ownerUserUuid = meetingInfo.ownerUserUuid

  const noRename = useMemo(() => {
    return meetingInfo.noRename
  }, [meetingInfo.noRename])

  const isOwner = useMemo(() => {
    return localMember.uuid === meetingInfo.ownerUserUuid
  }, [localMember.uuid, meetingInfo.ownerUserUuid])

  const isSIP = useMemo(() => {
    return [NEClientType.SIP, NEClientType.H323].includes(member.clientType)
  }, [member.clientType])

  const isFocus = useMemo(() => {
    return meetingInfo.focusUuid === member.uuid
  }, [member.uuid, meetingInfo.focusUuid])

  const isLockVideo = useMemo(() => {
    return meetingInfo.pinVideoUuid === member.uuid
  }, [member.uuid, meetingInfo.pinVideoUuid])

  const isScreen = useMemo(() => {
    return !!meetingInfo.screenUuid
  }, [meetingInfo.screenUuid])

  const isWhiteBoardInteractChecked = useMemo(() => {
    return member.properties.wbDrawable?.value === '1'
  }, [member.properties.wbDrawable])

  const isMySelf = useMemo(() => {
    return localMember.uuid === member.uuid
  }, [member.uuid, localMember.uuid])

  const isWhiteSharer = useMemo(() => {
    return meetingInfo.whiteboardUuid === localMember.uuid
  }, [meetingInfo.whiteboardUuid, localMember.uuid])

  const privateChatItemShow = useMemo(() => {
    if (globalConfig?.appConfig?.APP_ROOM_RESOURCE?.chatroom !== false) {
      if (noChat) {
        return false
      }

      // 自己不显示私聊
      if (member.uuid === localMember.uuid) {
        return false
      }

      if (isSIP) {
        return false
      }

      if (localMemberRole === Role.host || localMemberRole === Role.coHost) {
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
    }

    return false
  }, [
    localMember,
    meetingInfo,
    localMemberRole,
    isSIP,
    member.role,
    noChat,
    globalConfig?.appConfig?.APP_ROOM_RESOURCE?.chatroom,
  ])

  const defaultMenuItemsMap = useMemo(() => {
    class NEActionMenuItems {
      static audio: NECheckableMenuItem = {
        itemId: NEActionMenuIDs.audio,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        uncheckStateItem: {
          icon: '',
          text: t('participantMute'),
        },
        checkedStateItem: {
          icon: '',
          text: t('participantUnmute'),
        },
        checked: !member.isAudioOn,
      }

      static video: NECheckableMenuItem = {
        itemId: NEActionMenuIDs.video,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        uncheckStateItem: {
          icon: '',
          text: t('participantStopVideo'),
        },
        checkedStateItem: {
          icon: '',
          text: t('participantStartVideo'),
        },
        checked: !member.isVideoOn,
      }

      static focusVideo: NECheckableMenuItem = {
        itemId: NEActionMenuIDs.focusVideo,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        uncheckStateItem: {
          icon: '',
          text: t('participantAssignActiveSpeaker'),
        },
        checkedStateItem: {
          icon: '',
          text: t('participantUnassignActiveSpeaker'),
        },
        checked: isFocus,
      }

      static lockVideo: NECheckableMenuItem = {
        itemId: NEActionMenuIDs.lockVideo,
        visibility: NEMenuVisibility.VISIBLE_ALWAYS,
        uncheckStateItem: {
          icon: '',
          text: t('meetingPinView'),
        },
        checkedStateItem: {
          icon: '',
          text: t('meetingUnpinView'),
        },
        checked: isLockVideo,
      }

      static changeHost: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.changeHost,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_EXCLUDE_COHOST,
        singleStateItem: {
          icon: '',
          text: t('participantTransferHost'),
        },
      }

      static reclaimHost: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.reclaimHost,
        visibility: NEMenuVisibility.VISIBLE_TO_OWNER_ONLY,
        singleStateItem: {
          icon: '',
          text: t('meetingReclaimHost'),
        },
      }

      static removeMember: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.removeMember,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        singleStateItem: {
          icon: '',
          text: t('participantRemove'),
        },
      }

      static rejectHandsUp: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.rejectHandsUp,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        singleStateItem: {
          icon: '',
          text: t('lowerHand'),
        },
      }

      static whiteboardInteraction: NECheckableMenuItem = {
        itemId: NEActionMenuIDs.whiteboardInteraction,
        visibility: NEMenuVisibility.VISIBLE_EXCLUDE_ROOM_SYSTEM_DEVICE,
        uncheckStateItem: {
          icon: '',
          text: t('whiteBoardInteract'),
        },
        checkedStateItem: {
          icon: '',
          text: t('undoWhiteBoardInteract'),
        },
        checked: isWhiteBoardInteractChecked,
      }

      static screenShare: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.screenShare,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        singleStateItem: {
          icon: '',
          text: t('screenShareStop'),
        },
      }

      static whiteBoardShare: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.whiteBoardShare,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        singleStateItem: {
          icon: '',
          text: t('whiteBoardClose'),
        },
      }

      static updateNick: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.updateNick,
        visibility: NEMenuVisibility.VISIBLE_ALWAYS,
        singleStateItem: {
          icon: '',
          text: t('noRename'),
        },
      }

      static audioAndVideo: NECheckableMenuItem = {
        itemId: NEActionMenuIDs.audioAndVideo,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        uncheckStateItem: {
          icon: '',
          text: t('participantTurnOffAudioAndVideo'),
        },
        checkedStateItem: {
          icon: '',
          text: t('unmuteVideoAndAudio'),
        },
        checked: !(member.isVideoOn && member.isAudioOn),
      }

      static coHost: NECheckableMenuItem = {
        itemId: NEActionMenuIDs.coHost,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_EXCLUDE_COHOST,
        uncheckStateItem: {
          icon: '',
          text: t('participantAssignCoHost'),
        },
        checkedStateItem: {
          icon: '',
          text: t('participantUnassignCoHost'),
        },
        checked: member.role === Role.coHost,
      }

      static putInWaitingRoom: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.putInWaitingRoom,
        visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
        singleStateItem: {
          icon: '',
          text: t('moveToWaitingRoom'),
        },
      }

      static chatPrivate: NESingleStateMenuItem = {
        itemId: NEActionMenuIDs.chatPrivate,
        visibility: NEMenuVisibility.VISIBLE_EXCLUDE_ROOM_SYSTEM_DEVICE,
        singleStateItem: {
          icon: '',
          text: t('chatPrivate'),
        },
      }
    }

    const defaultItemsMap = new Map<
      number,
      NEMeetingMenuItem | NESingleStateMenuItem | NECheckableMenuItem
    >()

    Object.values(NEActionMenuItems).forEach((item) => {
      defaultItemsMap.set(item.itemId, item)
    })

    return defaultItemsMap
  }, [
    member.isAudioOn,
    member.isVideoOn,
    member.role,
    isFocus,
    isLockVideo,
    isWhiteBoardInteractChecked,
  ])

  const memberActionMenuItems = useMemo(() => {
    const items = meetingInfo.memberActionMenuItems ?? [
      {
        itemId: NEActionMenuIDs.updateNick,
      },
      {
        itemId: NEActionMenuIDs.rejectHandsUp,
      },
      {
        itemId: NEActionMenuIDs.audio,
      },
      {
        itemId: NEActionMenuIDs.video,
      },
      {
        itemId: NEActionMenuIDs.audioAndVideo,
      },
      {
        itemId: NEActionMenuIDs.chatPrivate,
      },
      {
        itemId: NEActionMenuIDs.focusVideo,
      },
      {
        itemId: NEActionMenuIDs.lockVideo,
      },
      {
        itemId: NEActionMenuIDs.screenShare,
      },
      {
        itemId: NEActionMenuIDs.whiteBoardShare,
      },
      {
        itemId: NEActionMenuIDs.changeHost,
      },
      {
        itemId: NEActionMenuIDs.coHost,
      },
      {
        itemId: NEActionMenuIDs.whiteboardInteraction,
      },
      {
        itemId: NEActionMenuIDs.putInWaitingRoom,
      },
      {
        itemId: NEActionMenuIDs.reclaimHost,
      },
      {
        itemId: NEActionMenuIDs.removeMember,
      },
      {
        itemId: NEActionMenuIDs.localRecord,
      },
    ]

    return items
      .map((item) => {
        const defaultItem = defaultMenuItemsMap.get(item.itemId)

        return defaultItem ?? item
      })
      .filter((item) => {
        const isHostOrCohost = [Role.coHost, Role.host].includes(
          localMemberRole
        )
        let flag = false

        // 检查自己
        switch (item.visibility) {
          case undefined:
            flag = true
            break
          case NEMenuVisibility.VISIBLE_ALWAYS:
            flag = true
            break
          case NEMenuVisibility.VISIBLE_EXCLUDE_HOST:
            flag = !isHostOrCohost
            break
          case NEMenuVisibility.VISIBLE_TO_HOST_ONLY:
            flag = isHostOrCohost
            break
          case NEMenuVisibility.VISIBLE_EXCLUDE_ROOM_SYSTEM_DEVICE:
            flag = !isSIP
            break
          case NEMenuVisibility.VISIBLE_TO_OWNER_ONLY:
            flag = isOwner
            break
          case NEMenuVisibility.VISIBLE_TO_HOST_EXCLUDE_COHOST:
            flag = localMemberRole === Role.host
            break
          default:
            break
        }

        if (flag) {
          // 检查成员
          switch (item.itemId) {
            case NEActionMenuIDs.audio:
              flag = member.isAudioConnected
              break
            case NEActionMenuIDs.video:
              break
            case NEActionMenuIDs.focusVideo:
              flag = !isScreen
              break
            case NEActionMenuIDs.lockVideo:
              flag = member.isVideoOn || isLockVideo
              break
            case NEActionMenuIDs.changeHost:
              flag =
                member.role !== Role.host &&
                member.clientType !== NEClientType.SIP &&
                member.clientType !== NEClientType.H323
              break
            case NEActionMenuIDs.reclaimHost:
              flag = member.role === Role.host && !isMySelf
              break
            case NEActionMenuIDs.removeMember:
              flag =
                member.role !== Role.host &&
                member.role !== Role.coHost &&
                member.uuid !== ownerUserUuid
              break
            case NEActionMenuIDs.rejectHandsUp:
              flag = member.isHandsUp === true
              break
            case NEActionMenuIDs.whiteboardInteraction:
              flag = isWhiteSharer && !isMySelf
              break
            case NEActionMenuIDs.screenShare:
              flag =
                (member.isSharingScreen || member.isSharingSystemAudio) &&
                member.role !== Role.host &&
                !isMySelf
              break
            case NEActionMenuIDs.whiteBoardShare:
              flag =
                member.isSharingWhiteboard &&
                member.role !== Role.host &&
                !isMySelf
              break
            case NEActionMenuIDs.updateNick:
              flag = (isMySelf || isHostOrCohost) && noRename !== true
              break
            case NEActionMenuIDs.audioAndVideo:
              flag = member.isAudioConnected
              break
            case NEActionMenuIDs.coHost:
              flag =
                member.role !== Role.host &&
                member.clientType !== NEClientType.SIP &&
                member.clientType !== NEClientType.H323
              break
            case NEActionMenuIDs.putInWaitingRoom:
              flag =
                member.role !== Role.host &&
                member.role !== Role.coHost &&
                member.uuid !== ownerUserUuid &&
                meetingInfo.isWaitingRoomEnabled === true &&
                member.uuid !== localMember.uuid
              break
            case NEActionMenuIDs.chatPrivate:
              flag = privateChatItemShow
              break
            default:
              break
          }
        }

        if (flag) {
          if (_isNESingleStateMenuItem(item)) {
            if (!item.singleStateItem.text) {
              flag = false
            }
          } else if (_isNECheckableMenuItem(item)) {
            if (item.checked) {
              if (!item.checkedStateItem.text) {
                flag = false
              }
            } else {
              if (!item.uncheckStateItem.text) {
                flag = false
              }
            }
          } else {
            flag = false
          }
        }

        return flag
      })
      .map((item) => {
        if (_isNESingleStateMenuItem(item)) {
          return {
            key: item.itemId,
            label: item.singleStateItem.text,
          }
        } else if (_isNECheckableMenuItem(item)) {
          if (item.checked) {
            return {
              key: item.itemId,
              label: item.checkedStateItem.text,
              checked: item.checked,
            }
          } else {
            return {
              key: item.itemId,
              label: item.uncheckStateItem.text,
              checked: item.checked,
            }
          }
        } else {
          return {
            key: item.itemId,
            label: '',
          }
        }
      })
  }, [
    defaultMenuItemsMap,
    localMemberRole,
    isSIP,
    isScreen,
    noRename,
    isOwner,
    isMySelf,
    isLockVideo,
    isWhiteSharer,
    meetingInfo.isWaitingRoomEnabled,
    meetingInfo.memberActionMenuItems,
    privateChatItemShow,
    member,
  ])

  return {
    memberActionMenuItems,
  }
}

export default useMemberActionMenuItems
