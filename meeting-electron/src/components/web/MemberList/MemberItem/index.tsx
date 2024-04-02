import { Checkbox, Dropdown, MenuProps } from 'antd'
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

interface MemberItemProps {
  data: NEMember
  meetingInfo: NEMeetingInfo
  neMeeting?: NEMeetingService
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
}) => {
  const { t } = useTranslation()
  const { eventEmitter } = useGlobalContext()
  const { dispatch } = useMeetingInfoContext()

  const { localMember } = meetingInfo
  const isWhiteSharer = meetingInfo.whiteboardUuid === localMember.uuid
  const isHost = localMember.role === Role.host
  const isCoHost = localMember.role === Role.coHost
  const isFocus = meetingInfo.focusUuid === data.uuid
  const isScreen = !!meetingInfo.screenUuid
  const isMySelf = localMember.uuid === data.uuid

  const isElectronSharingScreen = useMemo(() => {
    return window.ipcRenderer && localMember.isSharingScreen
  }, [localMember.isSharingScreen])

  const name = useMemo(() => {
    const nickName = substringByByte3(data.name, 20)
    const remarks: string[] = []
    if (meetingInfo.showMemberTag && data.properties.tag?.value) {
      remarks.push(data.properties.tag.value)
    }
    if (data.role === Role.host) {
      remarks.push(t('host'))
    }
    if (data.role === Role.coHost) {
      remarks.push(t('coHost'))
    }
    if (localMember.uuid === data.uuid) {
      remarks.push(t('participantMe'))
    }
    return `${nickName} ${remarks.length ? `(${remarks.join(',')})` : ''}`
  }, [localMember, meetingInfo, data, t])

  const privateChatItemShow = useMemo(() => {
    // 自己不显示私聊
    if (data.uuid === localMember.uuid) {
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

  let items: {
    key: memberAction | hostAction
    label: string
    isShow?: boolean
    onClick?: MenuProps['onClick']
  }[] = [
    {
      key: memberAction.modifyMeetingNickName,
      label: t('noRename'),
      onClick: () => {
        handleUpdateUserNickname?.(data.uuid, data.name, 'room')
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
      isShow: isWhiteSharer && data.properties.wbDrawable?.value !== '1',
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
        meetingInfo.isWaitingRoomEnabled &&
        data.uuid !== localMember.uuid,
      onClick: async () => {
        try {
          await neMeeting?.putInWaitingRoom(data.uuid)
        } catch (e: any) {
          console.log('putInWaitingRoom error', e)
          Toast.fail(t(e?.message || e?.msg || e?.code))
        }
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
  const privateChatItems = [
    {
      key: memberAction.privateChat,
      label: t('chatPrivate'),
      isShow: privateChatItemShow,
      onClick: () => {
        neMeeting?.sendMemberControl(memberAction.privateChat, data.uuid)
      },
    },
  ]

  const removeDialog = () => {
    let isChecked = false
    Modal.confirm({
      title: t('participantRemove'),
      width: 270,
      content: (
        <>
          <div>{t('participantRemoveConfirm') + data.name}</div>
          {meetingInfo.enableBlacklist && (
            <Checkbox
              className="close-checkbox-tip"
              onChange={(e) => (isChecked = e.target.checked)}
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
        } catch (e: any) {
          console.log('remove error', e)
          Toast.fail(e.message || e.msg || t('participantFailedToRemove'))
        }
      },
    })
  }

  if (isHost || isCoHost) {
    items.push(
      ...[
        {
          key: hostAction.rejectHandsUp,
          label: t('lowerHand'),
          isShow: data.isHandsUp,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(
                hostAction.rejectHandsUp,
                data.uuid
              )
            } catch {
              Toast.fail(t('participantFailedToLowerHand'))
            }
          },
        },
        {
          key: hostAction.muteMemberAudio,
          label: t('participantMute'),
          isShow: data.isAudioOn && data.isAudioConnected,
          onClick: async () => {
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
          },
        },
        {
          key: hostAction.unmuteMemberAudio,
          label: t('participantUnmute'),
          isShow: !data.isAudioOn && data.isAudioConnected,
          onClick: async () => {
            try {
              if (isMySelf) {
                await neMeeting?.unmuteLocalAudio()
              } else {
                await neMeeting?.sendHostControl(
                  hostAction.unmuteMemberAudio,
                  data.uuid
                )
              }
            } catch (error: any) {
              Toast.fail(
                error?.msg || t(errorCodeMap[error?.code] || 'unMuteAudioFail')
              )
            }
          },
        },
        {
          key: hostAction.muteMemberVideo,
          label: t('participantStopVideo'),
          isShow: data.isVideoOn,
          onClick: async () => {
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
        },
        {
          key: hostAction.unmuteMemberVideo,
          label: t('participantStartVideo'),
          isShow: !data.isVideoOn,
          onClick: async () => {
            try {
              if (isMySelf) {
                await neMeeting?.unmuteLocalVideo()
              } else {
                await neMeeting?.sendHostControl(
                  hostAction.unmuteMemberVideo,
                  data.uuid
                )
              }
            } catch (error: any) {
              Toast.fail(
                error?.msg || t(errorCodeMap[error?.code] || 'unMuteVideoFail')
              )
            }
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
            } catch (error: any) {
              // TODO:
              Toast.fail(
                error?.msg || t(errorCodeMap[error?.code] || error?.code)
              )
            }
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
            meetingInfo.screenUuid === data.uuid &&
            localMember.uuid !== data.uuid,
          onClick: () => {
            Modal.confirm({
              title: t('screenShareStop'),
              content: t('closeCommonTips') + t('closeScreenShareTips'),
              onOk: async () => {
                try {
                  await neMeeting?.sendHostControl(
                    hostAction.closeScreenShare,
                    data.uuid
                  )
                } catch {
                  Toast.fail(t('screenShareStopFail'))
                }
              },
            })
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
            data.role !== Role.host && data.clientType !== NEClientType.SIP,
          onClick: () => {
            Modal.confirm({
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
          },
        },
        {
          key: hostAction.setCoHost,
          label: t('participantAssignCoHost'),
          isShow:
            data.role !== Role.host &&
            data.role !== Role.coHost &&
            data.clientType !== NEClientType.SIP,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(hostAction.setCoHost, data.uuid)
            } catch (e: any) {
              if (e.code === 1002) {
                Toast.fail(t('coHostLimit'))
              } else {
                Toast.fail(e.message || e.msg || e.code)
              }
            }
          },
        },
        {
          key: hostAction.unSetCoHost,
          label: t('participantUnassignCoHost'),
          isShow:
            data.role === Role.coHost && data.clientType !== NEClientType.SIP,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(
                hostAction.unSetCoHost,
                data.uuid
              )
            } catch (e: any) {
              Toast.fail(e.message || e.msg || e.code)
            }
          },
        },
        ...whiteBoardItems,
        ...waitingRoomItems,
        {
          key: hostAction.remove,
          label: t('participantRemove'),
          isShow: data.role !== Role.host,
          onClick: () => {
            removeDialog()
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
          isShow: data.role !== Role.host && data.uuid !== localMember.uuid,
          onClick: () => {
            removeDialog()
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
        try {
          await neMeeting?.sendMemberControl(
            memberAction.takeBackTheHost,
            data.uuid
          )
        } catch {
          Toast.fail(t('meetingReclaimHostFailed'))
        }
      },
      // 需要判断自己是否是主持人，是当前的会议拥有者
      isShow:
        meetingInfo.ownerUserUuid === localMember.uuid && data.role === 'host',
    })
  }

  items = items.filter((item) => {
    const { isShow } = item
    delete item.isShow
    return Boolean(isShow)
  })

  return (
    <div className="member-item">
      <UserAvatar
        className="member-item-avatar"
        nickname={data.name}
        avatar={data.avatar}
        size={24}
      />
      <div className="member-item-name">{name}</div>
      <div className={classNames('member-item-actions')}>
        {data.isHandsUp && (isHost || isCoHost) && (
          <svg
            className="icon iconfont icon-blue iconraisehands1x"
            aria-hidden="true"
          >
            <use xlinkHref="#iconraisehands1x" />
          </svg>
        )}
        {data.properties.phoneState?.value === '1' && (
          <svg
            className="icon iconfont icon-blue icon-green icondianhua-copy"
            aria-hidden="true"
          >
            <use xlinkHref="#icondianhua-copy" />
          </svg>
        )}
        {data.isSharingScreen && (
          <svg
            className="icon iconfont icon-blue icon-blue iconyx-tv-sharescreen1x"
            aria-hidden="true"
          >
            <use xlinkHref="#iconyx-tv-sharescreen1x" />
          </svg>
        )}
        {data.isSharingWhiteboard && (
          <svg
            className="icon iconfont icon-blue iconyx-baiban"
            aria-hidden="true"
          >
            <use xlinkHref="#iconyx-baiban" />
          </svg>
        )}
        {meetingInfo.focusUuid === data.uuid && (
          <svg className="icon iconfont" aria-hidden="true">
            <use xlinkHref="#iconjiaodian1" />
          </svg>
        )}
        <svg
          className={classNames('icon iconfont', {
            'icon-red': !data.isVideoOn,
          })}
          aria-hidden="true"
        >
          <use
            xlinkHref={`${
              data.isVideoOn ? '#iconyx-tv-video-onx' : '#iconyx-tv-video-offx'
            }`}
          />
        </svg>
        {data.isAudioConnected ? (
          data.isAudioOn ? (
            <AudioIcon memberId={data.uuid} className="icon iconfont" dark />
          ) : (
            <svg
              className={classNames('icon iconfont', {
                'icon-red': !data.isAudioOn,
              })}
              aria-hidden="true"
            >
              <use
                xlinkHref={`${
                  data.isAudioOn
                    ? '#iconyx-tv-voice-onx'
                    : '#iconyx-tv-voice-offx'
                }`}
              />
            </svg>
          )
        ) : null}
        {items.length > 0 ? (
          <Dropdown menu={{ items }} trigger={['click']}>
            <svg className="icon iconfont iconyx-tv-more1x" aria-hidden="true">
              <use xlinkHref="#iconyx-tv-more1x" />
            </svg>
          </Dropdown>
        ) : (
          <svg
            className="icon iconfont iconyx-tv-more1x"
            aria-hidden="true"
            style={{ opacity: 0 }}
          >
            <use xlinkHref="#iconyx-tv-more1x" />
          </svg>
        )}
      </div>
    </div>
  )
}
export default MemberItem
