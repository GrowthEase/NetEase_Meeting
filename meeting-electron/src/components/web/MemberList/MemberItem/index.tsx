import { Dropdown, MenuProps } from 'antd'
import classNames from 'classnames'
import React, { useMemo, useState } from 'react'
import { useTranslation } from 'react-i18next'

import {
  hostAction,
  memberAction,
  NEClientType,
  NEMeetingInfo,
  NEMember,
  Role,
} from '../../../../types'

import { errorCodeMap } from '../../../../config'
import NEMeetingService from '../../../../services/NEMeeting'
import { useGlobalContext } from '../../../../store'
import { substringByByte3 } from '../../../../utils'
import AudioIcon from '../../../common/AudioIcon'
import UserAvatar from '../../../common/Avatar'
import Modal from '../../../common/Modal'
import Toast from '../../../common/toast'
import UpdateUserNicknameModal from '../../BeforeMeetingModal/UpdateUserNicknameModal'
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

  const { localMember } = meetingInfo
  const isWhiteSharer = meetingInfo.whiteboardUuid === localMember.uuid
  const isHost = localMember.role === Role.host
  const isCoHost = localMember.role === Role.coHost
  const isFocus = meetingInfo.focusUuid === data.uuid
  const isScreen = !!meetingInfo.screenUuid
  const isMySelf = localMember.uuid === data.uuid

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
      remarks.push(t('me'))
    }
    return `${nickName} ${remarks.length ? `(${remarks.join(',')})` : ''}`
  }, [localMember, meetingInfo, data, t])

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
              Toast.fail(t('putMemberHandsDownFail'))
            }
          },
        },
        {
          key: hostAction.muteMemberAudio,
          label: t('muteAudio'),
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
              Toast.fail(t('muteAudioFail'))
            }
          },
        },
        {
          key: hostAction.unmuteMemberAudio,
          label: t('unMuteAudio'),
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
          label: t('muteVideo'),
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
              Toast.fail(t('muteVideoFail'))
            }
          },
        },
        {
          key: hostAction.unmuteMemberVideo,
          label: t('unMuteVideo'),
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
          label: t('muteVideoAndAudio'),
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
        {
          key: hostAction.setFocus,
          label: t('focusVideo'),
          isShow: !isFocus && !isScreen,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(hostAction.setFocus, data.uuid)
            } catch {
              Toast.fail(t('focusVideoFail'))
            }
          },
        },
        {
          key: hostAction.unsetFocus,
          label: t('unFocusVideo'),
          isShow: isFocus && !isScreen,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(hostAction.unsetFocus, data.uuid)
            } catch {
              Toast.fail(t('unFocusVideoFail'))
            }
          },
        },
        {
          key: hostAction.closeScreenShare,
          label: t('unScreenShare'),
          isShow:
            data.role !== Role.host &&
            meetingInfo.screenUuid === data.uuid &&
            localMember.uuid !== data.uuid,
          onClick: () => {
            Modal.confirm({
              title: t('unScreenShare'),
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
          label: t('closeWhiteBoard'),
          isShow:
            data.role !== Role.host && meetingInfo.whiteboardUuid === data.uuid,
          onClick: () => {
            Modal.confirm({
              title: t('closeWhiteBoard'),
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
          label: t('handOverHost'),
          isShow:
            data.role !== Role.host && data.clientType !== NEClientType.SIP,
          onClick: () => {
            Modal.confirm({
              title: t('handOverHost'),
              content: t('handOverHostTips') + data.name,
              onOk: async () => {
                try {
                  await neMeeting?.sendHostControl(
                    hostAction.transferHost,
                    data.uuid
                  )
                } catch {
                  Toast.fail(t('handOverHostFail'))
                }
              },
            })
          },
        },
        {
          key: hostAction.setCoHost,
          label: t('handSetCoHost'),
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
          label: t('handUnSetCoHost'),
          isShow:
            data.role === Role.coHost && data.clientType !== NEClientType.SIP,
          onClick: async () => {
            try {
              await neMeeting?.sendHostControl(
                hostAction.unSetCoHost,
                data.uuid
              )
            } catch {
              // TODO:
            }
          },
        },
        ...whiteBoardItems,
        ...waitingRoomItems,
        {
          key: hostAction.remove,
          label: t('removeMember'),
          isShow: data.role !== Role.host,
          onClick: () => {
            Modal.confirm({
              title: t('removeMember'),
              content: t('removeMemberTips') + data.name,
              onOk: async () => {
                try {
                  await neMeeting?.sendHostControl(hostAction.remove, data.uuid)
                } catch {
                  Toast.fail(t('removeMemberFail'))
                }
              },
            })
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
          label: t('removeMember'),
          isShow: data.role !== Role.host && data.uuid !== localMember.uuid,
          onClick: () => {
            Modal.confirm({
              title: t('removeMember'),
              content: t('removeMemberTips') + data.name,
              onOk: async () => {
                try {
                  await neMeeting?.sendHostControl(hostAction.remove, data.uuid)
                } catch {
                  Toast.fail(t('removeMemberFail'))
                }
              },
            })
          },
        },
      ]
    )
  }
  if (!isCoHost && !isHost) {
    items.push(...whiteBoardItems)
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
