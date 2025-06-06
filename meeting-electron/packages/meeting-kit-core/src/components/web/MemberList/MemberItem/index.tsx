import { Button, Dropdown, MenuProps } from 'antd'
import classNames from 'classnames'
import React, { useMemo } from 'react'
import { useTranslation } from 'react-i18next'

import {
  ActionType,
  hostAction,
  memberAction,
  NEClientType,
  NEMeetingInfo,
  NEMember,
  Role,
  UserEventType,
} from '../../../../types'

import { errorCodeMap } from '../../../../config'
import NEMeetingService from '../../../../services/NEMeeting'
import { useGlobalContext, useMeetingInfoContext } from '../../../../store'
import { substringByByte3 } from '../../../../utils'
import AudioIcon from '../../../common/AudioIcon'
import UserAvatar from '../../../common/Avatar'
import Modal from '../../../common/Modal'
import Toast from '../../../common/toast'
import './index.less'
import CommonModal from '../../../common/CommonModal'
import Emoji from '../../../common/Emoji'
import useMemberActionMenuItems, {
  NEActionMenuIDs,
} from '../../../../hooks/useMemberActionMenuItems'
import { MenuClickType } from '../../../../kit/interface'
import { useMemberOperationHandle } from '../../../../hooks/useVideoShortcutOperation'
import useNetworkQuality from '../../../../hooks/useNetworkQuality'

interface MemberItemProps {
  data: NEMember
  meetingInfo: NEMeetingInfo
  neMeeting?: NEMeetingService
  isOverCohostLimitCount: boolean
  ownerUserUuid: string
  handleUpdateUserNickname: (
    uuid: string,
    nickname: string,
    roomType: 'room' | 'waitingRoom'
  ) => void
}

const MemberItem: React.FC<MemberItemProps> = ({
  data,
  meetingInfo,
  neMeeting,
  handleUpdateUserNickname,
  isOverCohostLimitCount,
  ownerUserUuid,
}) => {
  const { t, i18n } = useTranslation()
  const { dispatch } = useMeetingInfoContext()
  const { noChat, globalConfig, eventEmitter } = useGlobalContext()

  const { memberActionMenuItems } = useMemberActionMenuItems(data)

  const { localMember } = meetingInfo
  const isWhiteSharer = meetingInfo.whiteboardUuid === localMember.uuid
  const isHost = localMember.role === Role.host
  const isCoHost = localMember.role === Role.coHost
  const isFocus = meetingInfo.focusUuid === data.uuid
  const isScreen = !!meetingInfo.screenUuid
  const isMySelf = localMember.uuid === data.uuid
  const [isMemberItemHover, setIsMemberItemHover] = React.useState(false)
  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])
  const nickName = useMemo(() => {
    return substringByByte3(data.name, 20)
  }, [data.name])
  const name = useMemo(() => {
    const remarks: string[] = []

    if (meetingInfo.showMemberTag && data.properties.tag?.value) {
      remarks.push(data.properties.tag.value)
    }

    if (data.role === Role.host) {
      remarks.push(t('host'))
    } else if (data.role === Role.coHost) {
      remarks.push(t('coHost'))
    } else if (data.role === Role.guest) {
      remarks.push(t('meetingRoleGuest'))
    }

    const interpreters = meetingInfo.interpretation?.interpreters

    if (interpreters && interpreters[data.uuid]) {
      remarks.push(t('interpInterpreter'))
    }

    if (localMember.uuid === data.uuid) {
      remarks.push(t('participantMe'))
    }

    return `${remarks.length ? `${remarks.join(',')}` : ''}`
  }, [localMember, meetingInfo, data, t])
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
    setCoHost,
    removeDialog,
  } = useMemberOperationHandle()

  const { isNetworkQualityBad } = useNetworkQuality(data)
  const privateChatItemShow = useMemo(() => {
    // 自己不显示私聊
    if (data.uuid === localMember.uuid) {
      return false
    }

    if (
      data.clientType === NEClientType.SIP ||
      data.clientType === NEClientType.H323
    ) {
      return false
    }

    if (isHost || isCoHost) {
      return true
    }

    // 会议中的聊天权限
    if (meetingInfo.meetingChatPermission === 4) {
      return false
    }

    if (data.role === Role.host || data.role === Role.coHost) {
      return true
    }

    if (meetingInfo.meetingChatPermission === 1) {
      return true
    }

    return false
  }, [localMember, meetingInfo, data, isCoHost, isHost])

  function modifyMeetingNickName(data: NEMember) {
    handleUpdateUserNickname?.(data.uuid, data.name, 'room')
  }

  let items: {
    key: memberAction | hostAction | number
    label: string
    isShow?: boolean
    onClick?: MenuProps['onClick']
  }[] = [
    {
      key: memberAction.modifyMeetingNickName,
      label: t('noRename'),
      onClick: () => {
        modifyMeetingNickName(data)
      },
      isShow:
        (isCoHost || isHost || localMember.uuid === data.uuid) &&
        meetingInfo.noRename !== true,
    },
  ]
  const whiteBoardItems = [
    {
      key: memberAction.shareWhiteShare,
      label: t('whiteBoardInteract'),
      isShow:
        isWhiteSharer &&
        data.properties.wbDrawable?.value !== '1' &&
        data.clientType !== NEClientType.SIP &&
        data.clientType !== NEClientType.H323,
      onClick: async () => {
        try {
          await neMeeting?.sendMemberControl(
            memberAction.shareWhiteShare,
            data.uuid
          )
        } catch {
          Toast.fail(t('whiteBoardInteractFail'))
        }
      },
    },
    {
      key: memberAction.cancelShareWhiteShare,
      label: t('undoWhiteBoardInteract'),
      isShow:
        isWhiteSharer &&
        data.properties.wbDrawable?.value === '1' &&
        localMember.uuid !== data.uuid,
      onClick: async () => {
        try {
          await neMeeting?.sendMemberControl(
            memberAction.cancelShareWhiteShare,
            data.uuid
          )
        } catch {
          Toast.fail(t('undoWhiteBoardInteractFail'))
        }
      },
    },
  ]
  const waitingRoomItems = [
    {
      key: hostAction.moveToWaitingRoom,
      label: t('moveToWaitingRoom'),
      isShow:
        data.role !== Role.host &&
        data.role !== Role.coHost &&
        data.uuid !== ownerUserUuid &&
        meetingInfo.isWaitingRoomEnabled &&
        data.uuid !== localMember.uuid,
      onClick: async () => {
        moveToWaitingRoom(data)
      },
    },
  ]
  const pinViewItems = [
    {
      key: memberAction.pinView,
      label: t('meetingPinView'),
      isShow:
        data.isVideoOn &&
        data.uuid !== meetingInfo.pinVideoUuid &&
        !meetingInfo.focusUuid &&
        !isElectronSharingScreen,
      onClick: async () => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            pinVideoUuid: data.uuid,
          },
        })
      },
    },
    {
      key: memberAction.unpinView,
      label: t('meetingUnpinView'),
      isShow: data.uuid == meetingInfo.pinVideoUuid && !isElectronSharingScreen,
      onClick: async () => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            pinVideoUuid: '',
          },
        })
      },
    },
  ]
  const privateChatItems =
    globalConfig?.appConfig?.APP_ROOM_RESOURCE?.chatroom !== false
      ? [
          {
            key: memberAction.privateChat,
            label: t('chatPrivate'),
            isShow: privateChatItemShow && !noChat,
            onClick: () => {
              neMeeting?.sendMemberControl(memberAction.privateChat, data.uuid)
            },
          },
        ]
      : []

  if (isHost || isCoHost) {
    items.push(
      ...[
        {
          key: hostAction.rejectHandsUp,
          label: t('lowerHand'),
          isShow: data.isHandsUp,
          onClick: async () => {
            rejectHandsUp(data)
          },
        },
        {
          key: hostAction.muteMemberAudio,
          label: t('participantMute'),
          isShow: data.isAudioOn && data.isAudioConnected,
          onClick: async () => {
            muteMemberAudio(data, isMySelf)
          },
        },
        {
          key: hostAction.unmuteMemberAudio,
          label: t('participantUnmute'),
          isShow: !data.isAudioOn && data.isAudioConnected,
          onClick: async () => {
            unmuteMemberAudio(data, isMySelf)
          },
        },
        {
          key: hostAction.muteMemberVideo,
          label: t('participantStopVideo'),
          isShow: data.isVideoOn,
          onClick: async () => {
            muteMemberVideo(data, isMySelf)
          },
        },
        {
          key: hostAction.unmuteMemberVideo,
          label: t('participantStartVideo'),
          isShow: !data.isVideoOn,
          onClick: async () => {
            unmuteMemberVideo(data, isMySelf)
          },
        },
        {
          key: hostAction.muteVideoAndAudio,
          label: t('participantTurnOffAudioAndVideo'),
          isShow: data.isVideoOn && data.isAudioOn,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(
                hostAction.muteVideoAndAudio,
                data.uuid
              )
            } catch {
              // TODO:
            }
          },
        },
        {
          key: hostAction.unmuteVideoAndAudio,
          label: t('unmuteVideoAndAudio'),
          isShow: (!data.isVideoOn || !data.isAudioOn) && data.isAudioConnected,
          onClick: async () => {
            unmuteVideoAndAudio(data, isMySelf)
          },
        },
        ...privateChatItems,
        {
          key: hostAction.setFocus,
          label: t('participantAssignActiveSpeaker'),
          isShow: !isFocus && !isScreen,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(hostAction.setFocus, data.uuid)
            } catch {
              Toast.fail(t('participantFailedToAssignActiveSpeaker'))
            }
          },
        },
        {
          key: hostAction.unsetFocus,
          label: t('participantUnassignActiveSpeaker'),
          isShow: isFocus && !isScreen,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(hostAction.unsetFocus, data.uuid)
            } catch {
              Toast.fail(t('participantFailedToUnassignActiveSpeaker'))
            }
          },
        },
        ...pinViewItems,
        {
          key: hostAction.closeScreenShare,
          label: t('screenShareStop'),
          isShow:
            data.role !== Role.host &&
            (meetingInfo.screenUuid === data.uuid ||
              data.isSharingSystemAudio) &&
            localMember.uuid !== data.uuid,
          onClick: () => {
            closeScreenShare(data)
          },
        },
        {
          key: hostAction.closeWhiteShare,
          label: t('whiteBoardClose'),
          isShow:
            data.role !== Role.host && meetingInfo.whiteboardUuid === data.uuid,
          onClick: () => {
            Modal.confirm({
              title: t('whiteBoardClose'),
              content: t('closeCommonTips') + t('closeWhiteShareTips'),
              onOk: async () => {
                try {
                  await neMeeting?.sendHostControl(
                    hostAction.closeWhiteShare,
                    data.uuid
                  )
                } catch {
                  Toast.fail(t('whiteBoardShareStopFail'))
                }
              },
            })
          },
        },
        {
          key: hostAction.allowLocalReocrd,
          label: t('localRecordPermissionAllow'),
          isShow:
            data.role !== Role.host &&
            (data.clientType == NEClientType.PC || data.clientType == NEClientType.LINUX || data.clientType == NEClientType.MAC) &&
            !data.isLocalRecording,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(hostAction.unsetFocus, data.uuid)
            } catch {
              Toast.fail(t('participantFailedToUnassignActiveSpeaker'))
            }
          },
        },
        {
          key: hostAction.forbiddenLocalRecord,
          label: t('localRecordPermissionNotAllow'),
          isShow:
            data.role !== Role.host &&
            (data.clientType == NEClientType.PC ||
              data.clientType == NEClientType.MAC || data.clientType == NEClientType.LINUX) &&
            data.isLocalRecording == true,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(hostAction.unsetFocus, data.uuid)
            } catch {
              Toast.fail(t('participantFailedToUnassignActiveSpeaker'))
            }
          },
        },
      ]
    )
  }

  if (isHost) {
    items.push(
      ...[
        {
          key: hostAction.transferHost,
          label: t('participantTransferHost'),
          isShow:
            data.role !== Role.host &&
            data.clientType !== NEClientType.SIP &&
            data.clientType !== NEClientType.H323,
          onClick: () => {
            transferHost(data)
          },
        },
        {
          key: hostAction.setCoHost,
          label: t('participantAssignCoHost'),
          isShow:
            data.role !== Role.host &&
            data.role !== Role.coHost &&
            !isOverCohostLimitCount &&
            data.clientType !== NEClientType.SIP &&
            data.clientType !== NEClientType.H323,
          onClick: async () => {
            setCoHost(data)
          },
        },
        {
          key: hostAction.unSetCoHost,
          label: t('participantUnassignCoHost'),
          isShow:
            data.role === Role.coHost &&
            data.clientType !== NEClientType.SIP &&
            data.clientType !== NEClientType.H323,
          onClick: async () => {
            unSetCoHost(data)
          },
        },
        ...whiteBoardItems,
        ...waitingRoomItems,
        {
          key: hostAction.remove,
          label: t('participantRemove'),
          isShow: data.role !== Role.host && data.uuid !== ownerUserUuid,
          onClick: () => {
            removeDialog(data, !!meetingInfo.enableBlacklist)
          },
        },
      ]
    )
  }

  if (isCoHost) {
    items.push(
      ...whiteBoardItems,
      ...waitingRoomItems,
      ...[
        {
          key: hostAction.remove,
          label: t('participantRemove'),
          isShow:
            data.role !== Role.host &&
            data.role !== Role.coHost &&
            data.uuid !== localMember.uuid,
          onClick: () => {
            removeDialog(data, !!meetingInfo.enableBlacklist)
          },
        },
      ]
    )
  }

  if (!isCoHost && !isHost) {
    items.push(...privateChatItems, ...pinViewItems, ...whiteBoardItems)
  }

  // 收回主持人，
  if (!isHost) {
    items.push({
      key: memberAction.takeBackTheHost,
      label: t('meetingReclaimHost'),
      onClick: async () => {
        takeBackTheHost(data)
      },
      // 需要判断自己是否是主持人，是当前的会议拥有者
      isShow:
        meetingInfo.ownerUserUuid === localMember.uuid && data.role === 'host',
    })
  }

  items = memberActionMenuItems.map((item) => {
    let onClick = async () => {
      // 自定义
      eventEmitter?.emit(UserEventType.OnInjectedMenuItemClick, {
        itemId: item.key,
        state: item.checked ? 1 : 0,
        isChecked: item.checked ?? false,
        type:
          item.checked === undefined
            ? MenuClickType.Base
            : MenuClickType.Stateful,
      })
    }

    switch (item.key) {
      case NEActionMenuIDs.audio:
        onClick = async () => {
          if (item.checked) {
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
          } else {
            try {
              if (isMySelf) {
                await neMeeting?.muteLocalAudio()
              } else {
                await neMeeting?.sendHostControl(
                  hostAction.muteMemberAudio,
                  data.uuid
                )
              }
            } catch {
              Toast.fail(t('participantMuteAudioFail'))
            }
          }
        }

        break

      case NEActionMenuIDs.video:
        onClick = async () => {
          if (item.checked) {
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
                  t(
                    errorCodeMap[knownError?.code] ||
                      'participantUnMuteVideoFail'
                  )
              )
            }
          } else {
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
          }
        }

        break

      case NEActionMenuIDs.focusVideo:
        onClick = async () => {
          if (item.checked) {
            try {
              await neMeeting?.sendHostControl(hostAction.unsetFocus, data.uuid)
            } catch {
              Toast.fail(t('participantFailedToUnassignActiveSpeaker'))
            }
          } else {
            try {
              await neMeeting?.sendHostControl(hostAction.setFocus, data.uuid)
            } catch {
              Toast.fail(t('participantFailedToAssignActiveSpeaker'))
            }
          }
        }

        break

      case NEActionMenuIDs.lockVideo:
        onClick = async () => {
          if (item.checked) {
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
                pinVideoUuid: data.uuid,
              },
            })
          }
        }

        break

      case NEActionMenuIDs.changeHost:
        onClick = async () => {
          CommonModal.confirm({
            title: t('participantTransferHost'),
            content: t('participantTransferHostConfirm', {
              userName: data.name,
            }),
            onOk: async () => {
              try {
                await neMeeting?.sendHostControl(
                  hostAction.transferHost,
                  data.uuid
                )
              } catch {
                Toast.fail(t('participantFailedToTransferHost'))
              }
            },
          })
        }

        break

      case NEActionMenuIDs.reclaimHost:
        onClick = async () => {
          try {
            await neMeeting?.sendMemberControl(
              memberAction.takeBackTheHost,
              data.uuid
            )
          } catch {
            Toast.fail(t('meetingReclaimHostFailed'))
          }
        }

        break

      case NEActionMenuIDs.removeMember:
        onClick = async () => {
          removeDialog(data, !!meetingInfo.enableBlacklist)
        }

        break

      case NEActionMenuIDs.rejectHandsUp:
        onClick = async () => {
          try {
            await neMeeting?.sendHostControl(
              hostAction.rejectHandsUp,
              data.uuid
            )
          } catch {
            Toast.fail(t('participantFailedToLowerHand'))
          }
        }

        break

      case NEActionMenuIDs.whiteboardInteraction:
        onClick = async () => {
          if (item.checked) {
            try {
              await neMeeting?.sendMemberControl(
                memberAction.cancelShareWhiteShare,
                data.uuid
              )
            } catch {
              Toast.fail(t('undoWhiteBoardInteractFail'))
            }
          } else {
            try {
              await neMeeting?.sendMemberControl(
                memberAction.shareWhiteShare,
                data.uuid
              )
            } catch {
              Toast.fail(t('whiteBoardInteractFail'))
            }
          }
        }

        break

      case NEActionMenuIDs.screenShare:
        onClick = async () => {
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
        }

        break

      case NEActionMenuIDs.whiteBoardShare:
        onClick = async () => {
          CommonModal.confirm({
            title: t('whiteBoardClose'),
            content: t('closeCommonTips') + t('closeWhiteShareTips'),
            onOk: async () => {
              try {
                await neMeeting?.sendHostControl(
                  hostAction.closeWhiteShare,
                  data.uuid
                )
              } catch {
                Toast.fail(t('whiteBoardShareStopFail'))
              }
            },
          })
        }

        break

      case NEActionMenuIDs.updateNick:
        onClick = async () => {
          handleUpdateUserNickname?.(data.uuid, data.name, 'room')
        }

        break

      case NEActionMenuIDs.audioAndVideo:
        onClick = async () => {
          if (item.checked) {
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
          } else {
            try {
              await neMeeting?.sendHostControl(
                hostAction.muteVideoAndAudio,
                data.uuid
              )
            } catch {
              // TODO:
            }
          }
        }

        break

      case NEActionMenuIDs.coHost:
        onClick = async () => {
          if (item.checked) {
            try {
              await neMeeting?.sendHostControl(
                hostAction.unSetCoHost,
                data.uuid
              )
            } catch (err: unknown) {
              const knownError = err as { message: string; msg: string }

              Toast.fail(knownError.message || knownError.msg)
            }
          } else {
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
          }
        }

        break

      case NEActionMenuIDs.putInWaitingRoom:
        onClick = async () => {
          try {
            await neMeeting?.putInWaitingRoom(data.uuid)
          } catch (err: unknown) {
            const knownError = err as { message: string; msg: string }

            Toast.fail(knownError?.msg || knownError?.message)
          }
        }

        break

      case NEActionMenuIDs.chatPrivate:
        onClick = async () => {
          neMeeting?.sendMemberControl(memberAction.privateChat, data.uuid)
        }

        break
    }

    return {
      ...item,
      onClick,
    }
  })

  if (
    (isHost || isCoHost) &&
    data.role !== Role.host &&
    data.role !== Role.coHost &&
    (data.clientType == NEClientType.PC ||
      data.clientType == NEClientType.MAC || data.clientType == NEClientType.LINUX) &&
    meetingInfo.localRecordPermission?.some == true
  ) {
    if (data.localRecordAvailable == true) {
      items.push({
        key: hostAction.forbiddenLocalRecord,
        label: t('localRecordPermissionNotAllow'),
        onClick: async () => {
          try {
            await neMeeting?.sendMemberControl(
              memberAction.notAllowLocalRecord,
              data.uuid
            )
          } catch (e) {
            console.log('关闭该成员录制权限失败: ', e.message)
            Toast.fail(e.message)
          }
        },
      })
    } else {
      items.push({
        key: hostAction.allowLocalReocrd,
        label: t('localRecordPermissionAllow'),
        onClick: async () => {
          try {
            await neMeeting?.sendMemberControl(
              memberAction.allowLocalRecord,
              data.uuid
            )
          } catch (e) {
            console.log('开启该成员录制权限失败: ', e.message)
            Toast.fail(e.message)
          }
        },
      })
    }
  }

  return (
    <div
      className={classNames('nemeeting-member-item', {
        'nemeeting-member-item-hover': isMemberItemHover,
      })}
    >
      <div className="nemeeting-item-wrap">
        <UserAvatar
          className="member-item-avatar"
          nickname={data.name}
          avatar={data.avatar}
          size={32}
          showNetworkQuality={isNetworkQualityBad}
        />
        <div className="nemeeting-member-item-user">
          <div
            className={classNames('member-item-name', {
              'nemeeting-item-member-Jp': i18n.language === 'ja-JP',
            })}
          >
            {nickName}
          </div>
          <div
            className={classNames(
              'member-item-name nemeeting-item-member-role',
              {
                'nemeeting-item-member-role-Jp': i18n.language === 'ja-JP',
              }
            )}
          >
            {name}
          </div>
        </div>
      </div>

      <div className={classNames('member-item-actions')}>
        {data.isLocalRecording && (
          <svg
            className="icon iconfont icon-red iconbendiluzhi1 icon-hover"
            aria-hidden="true"
          >
            <use xlinkHref="#iconbendiluzhi1" />
          </svg>
        )}
        {data.isHandsUp && (isHost || isCoHost) && (
          <Emoji type={2} size={16} emojiKey="[举手]" />
        )}
        {data.properties.phoneState?.value == '1' && (
          <svg
            className="icon iconfont icon-green-light icondianhua-copy"
            aria-hidden="true"
          >
            <use xlinkHref="#icondianhua-copy" />
          </svg>
        )}
        {data.clientType == NEClientType.SIP && (
          <svg
            className="icon iconfont iconSIPwaihudianhua icon-blue"
            aria-hidden="true"
          >
            <use xlinkHref="#iconSIP1" />
          </svg>
        )}
        {data.clientType == NEClientType.H323 && (
          <svg
            className="icon iconfont iconSIPwaihudianhua icon-blue"
            aria-hidden="true"
          >
            <use xlinkHref="#icona-323" />
          </svg>
        )}
        {data.isSharingSystemAudio && (
          <svg
            className="icon iconfont icontouping-mianxing"
            aria-hidden="true"
          >
            <use xlinkHref="#icondiannaoshengyingongxiang" />
          </svg>
        )}
        {data.isSharingScreen && (
          <svg
            className="icon iconfont icon-green-light icontouping-mianxing"
            aria-hidden="true"
          >
            <use xlinkHref="#icontouping-mianxing" />
          </svg>
        )}
        {data.isSharingWhiteboard && (
          <svg
            className="icon iconfont icon-blue iconbaiban-mianxing"
            aria-hidden="true"
          >
            <use xlinkHref="#iconbaiban-mianxing" />
          </svg>
        )}
        {meetingInfo.focusUuid === data.uuid && (
          <svg className="icon iconfont iconjiaodian2" aria-hidden="true">
            <use xlinkHref="#iconjiaodian2" />
          </svg>
        )}
        <svg
          className={classNames(
            'icon member-iconyx-tv-video iconfont icon-hover',
            {
              'icon-red': !data.isVideoOn,
            }
          )}
          aria-hidden="true"
        >
          <use
            xlinkHref={`${
              data.isVideoOn ? '#iconguanbishexiangtou-mianxing' : '#iconkaiqishexiangtou'
            }`}
          />
        </svg>
        {data.isAudioConnected ? (
          data.isAudioOn ? (
            <AudioIcon
              memberId={data.uuid}
              className="icon iconfont icon-hover member-iconyx-tv-voice"
              dark
            />
          ) : (
            <svg
              className={classNames(
                'icon iconfont member-iconyx-tv-voice icon-hover',
                {
                  'icon-red': !data.isAudioOn,
                }
              )}
              aria-hidden="true"
            >
              <use
                xlinkHref={`${
                  data.isAudioOn ? '#iconyinliang0hei' : '#iconkaiqimaikefeng'
                }`}
              />
            </svg>
          )
        ) : (
          // 未连接音频,用于占位，不显示
          <svg
            className={classNames(
              'icon iconfont member-iconyx-tv-voice icon-hover'
            )}
            aria-hidden="true"
            style={{ opacity: 0 }}
          >
            <use
              xlinkHref={`${
                data.isAudioOn ? '#iconyinliang0hei' : '#iconkaiqimaikefeng'
              }`}
            />
          </svg>
        )}
        {items.findIndex((item) => item.key === NEActionMenuIDs.audio) !== -1 &&
        (isHost || isCoHost) &&
        data.isAudioConnected ? (
          !data.isAudioOn ? (
            <Button
              onClick={async () => {
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
              }}
              type="primary"
              className="audio-hover-button"
            >
              {t('participantUnmute')}
            </Button>
          ) : (
            <Button
              onClick={async () => {
                try {
                  if (isMySelf) {
                    await neMeeting?.muteLocalAudio()
                  } else {
                    await neMeeting?.sendHostControl(
                      hostAction.muteMemberAudio,
                      data.uuid
                    )
                  }
                } catch {
                  Toast.fail(t('participantMuteAudioFail'))
                }
              }}
              type="primary"
              className="audio-hover-button"
            >
              {t('participantMute')}
            </Button>
          )
        ) : null}
        {items.length > 0 ? (
          <Dropdown
            rootClassName="member-item-more-dropdown"
            menu={{ items }}
            onOpenChange={(open) => {
              setIsMemberItemHover(open)
            }}
            trigger={['hover']}
          >
            <Button className="member-list-footer-more-btn icon-member-more">
              <span
                style={{
                  display: 'flex',
                  alignItems: 'center',
                }}
              >
                <span className="member-item-footer-more-btn-text">
                  {t('more')}
                </span>
                <svg
                  className="icon iconfont iconxiajiantou-shixin"
                  aria-hidden="true"
                >
                  <use xlinkHref="#iconxiajiantou-shixin"></use>
                </svg>
              </span>
            </Button>
          </Dropdown>
        ) : (
          <svg
            className="icon iconfont icongengduo-mianxing"
            aria-hidden="true"
            style={{ opacity: 0 }}
          >
            <use xlinkHref="#icongengduo-mianxing" />
          </svg>
        )}
      </div>
    </div>
  )
}

export default MemberItem
