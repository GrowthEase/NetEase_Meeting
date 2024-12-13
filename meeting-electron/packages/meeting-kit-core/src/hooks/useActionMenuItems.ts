import { useMeetingInfoContext } from '../store'
import { NEMember, NEMenuVisibility } from '../kit'
import { useTranslation } from 'react-i18next'
import { NECheckableMenuItem, NESingleStateMenuItem } from '../kit/interface'

class NEActionMenuIDs {
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
}

const useActionMenuItems = (member: NEMember) => {
  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()

  console.log('useActionMenuItems', member, meetingInfo)

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
      checked: false,
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
      checked: false,
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
      checked: false,
    }

    static lockVideo: NECheckableMenuItem = {
      itemId: NEActionMenuIDs.lockVideo,
      visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
      uncheckStateItem: {
        icon: '',
        text: t('meetingPinView'),
      },
      checkedStateItem: {
        icon: '',
        text: t('meetingUnpinView'),
      },
      checked: false,
    }

    static changeHost: NESingleStateMenuItem = {
      itemId: NEActionMenuIDs.changeHost,
      visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
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
        text: t('participantTransferHost'),
      },
    }

    static removeMember: NESingleStateMenuItem = {
      itemId: NEActionMenuIDs.removeMember,
      visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
      singleStateItem: {
        icon: '',
        text: t('participantTransferHost'),
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
      checked: false,
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
      visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
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
      checked: false,
    }

    static coHost: NECheckableMenuItem = {
      itemId: NEActionMenuIDs.coHost,
      visibility: NEMenuVisibility.VISIBLE_TO_HOST_ONLY,
      uncheckStateItem: {
        icon: '',
        text: t('participantAssignCoHost'),
      },
      checkedStateItem: {
        icon: '',
        text: t('participantUnassignCoHost'),
      },
      checked: false,
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

  return {
    actionMenuItems: NEActionMenuItems,
  }
}

export default useActionMenuItems
