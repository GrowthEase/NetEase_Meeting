import React, { useEffect, useMemo, useState } from 'react'
import { useGlobalContext, useMeetingInfoContext } from '../../../../../store'
import {
  ActionType,
  CommonModal,
  EventType,
  hostAction,
  NEClientType,
  NEMember,
  Role,
  Toast,
  UserAvatar,
} from '../../../../../kit'
import { NEMeetingLeaveType } from '../../../../../types/type'
import { useTranslation } from 'react-i18next'

import './index.less'
import { IPCEvent } from '../../../../../app/src/types'

const EndDropdown: React.FC<React.PropsWithChildren> = () => {
  const { t } = useTranslation()
  const { neMeeting } = useGlobalContext()
  const { meetingInfo, memberList, dispatch } = useMeetingInfoContext()
  const [hostTransferOpen, setHostTransferOpen] = useState(false)
  const [hostTransferId, setHostTransferId] = useState('')
  const localMember = meetingInfo.localMember

  const isHost = localMember.role === Role.host

  const placementCls = useMemo(() => {
    switch (meetingInfo.endMeetingAction) {
      case 1:
        return meetingInfo.rightDrawerTabActiveKey
          ? 'nemeeting-end-bottom-left-open-drawer'
          : 'nemeeting-end-bottom-left'
      case 2:
        return 'nemeeting-end-center'
      case 3:
        return window.isWins32
          ? 'nemeeting-end-top-right'
          : 'nemeeting-end-top-left'
    }
  }, [meetingInfo.endMeetingAction, meetingInfo.rightDrawerTabActiveKey])

  const hostTransferMemberList = useMemo(() => {
    // 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
    const host: NEMember[] = []
    const coHost: NEMember[] = []
    const handsUp: NEMember[] = []
    const sharingWhiteboardOrScreen: NEMember[] = []
    const audioOn: NEMember[] = []
    const videoOn: NEMember[] = []
    const audioAndVideoOn: NEMember[] = []
    const other: NEMember[] = []

    memberList
      .filter(
        (member) =>
          member.uuid != meetingInfo.myUuid &&
          member.clientType !== NEClientType.SIP &&
          member.clientType !== NEClientType.H323
      )
      .forEach((member) => {
        if (member.role === Role.host) {
          host.push(member)
        } else if (member.role === Role.coHost) {
          coHost.push(member)
        } else if (member.isHandsUp) {
          handsUp.push(member)
        } else if (member.isSharingWhiteboard || member.isSharingScreen) {
          sharingWhiteboardOrScreen.push(member)
        } else if (member.isAudioOn && member.isVideoOn) {
          audioAndVideoOn.push(member)
        } else if (member.isVideoOn) {
          videoOn.push(member)
        } else if (member.isAudioOn) {
          audioOn.push(member)
        } else {
          other.push(member)
        }
      })
    other.sort((a, b) => {
      return a.name.localeCompare(b.name)
    })
    const members = [
      ...host,
      ...coHost,
      ...handsUp,
      ...sharingWhiteboardOrScreen,
      ...audioAndVideoOn,
      ...videoOn,
      ...audioOn,
      ...other,
    ]

    return members
  }, [memberList, meetingInfo.myUuid])

  const leaveAction = async () => {
    await neMeeting?.leave()
  }

  const onEnd = async () => {
    try {
      await neMeeting?.end()
    } catch (error) {
      Toast.fail(t('endFailed'))
    }
  }

  const onLeave = async (event) => {
    // 转移主持人
    if (
      hostTransferMemberList.length > 0 &&
      meetingInfo.localMember.role === Role.host
    ) {
      event.stopPropagation()
      setHostTransferOpen(true)
    } else {
      try {
        await leaveAction()
      } catch (error) {
        neMeeting?.eventEmitter?.emit(
          EventType.RoomEnded,
          NEMeetingLeaveType.LEAVE_BY_SELF
        )
      }
    }
  }

  const onMeetingAppointAndLeave = async () => {
    // 转移主持人
    try {
      await neMeeting?.sendHostControl(
        hostAction.transferHost,
        hostTransferId,
        true
      )
    } catch {
      Toast.fail(t('participantFailedToTransferHost'))
    }

    // 移交的时候需要延迟处理，否则会异常
    try {
      await leaveAction()
    } catch (error) {
      neMeeting?.eventEmitter?.emit(
        EventType.RoomEnded,
        NEMeetingLeaveType.LEAVE_BY_SELF
      )
    }
  }

  useEffect(() => {
    if (meetingInfo.endMeetingAction === undefined) {
      return
    }

    if (meetingInfo.endMeetingAction === 0) {
      setHostTransferOpen(false)
      setHostTransferId('')
      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
        method: 'closeDeviceList',
      })
    } else {
      if (!isHost) {
        if (
          meetingInfo.setting.normalSetting
            .leaveTheMeetingRequiresConfirmation === false
        ) {
          leaveAction().finally(() => {
            neMeeting?.eventEmitter?.emit(
              EventType.RoomEnded,
              NEMeetingLeaveType.LEAVE_BY_SELF
            )
          })
        } else {
          CommonModal.confirm({
            key: 'endMeetingActionLeave',
            title: t('leave'),
            content: t('meetingLeaveConfirm'),
            cancelText: t('globalCancel'),
            okText: t('leave'),
            onCancel: () => {
              dispatch?.({
                type: ActionType.UPDATE_MEETING_INFO,
                data: {
                  endMeetingAction: 0,
                },
              })
            },
            onOk: async () => {
              try {
                await leaveAction()
              } catch (error) {
                neMeeting?.eventEmitter?.emit(
                  EventType.RoomEnded,
                  NEMeetingLeaveType.LEAVE_BY_SELF
                )
              }
            },
          })
        }
      } else {
        CommonModal.destroy('endMeetingActionLeave')
        window.ipcRenderer?.send(IPCEvent.sharingScreen, {
          method: 'openDeviceList',
        })
      }
    }
  }, [
    meetingInfo.endMeetingAction,
    isHost,
    meetingInfo.setting.normalSetting.leaveTheMeetingRequiresConfirmation,
  ])

  useEffect(() => {
    if (hostTransferMemberList.length > 0) {
      setHostTransferId(hostTransferMemberList[0].uuid)
    }
  }, [hostTransferOpen])

  useEffect(() => {
    if (hostTransferOpen) {
      if (hostTransferMemberList.length === 0) {
        setHostTransferOpen(false)
        setHostTransferId('')
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            endMeetingAction: 0,
          },
        })
      } else {
        const index = hostTransferMemberList.findIndex(
          (item) => item.uuid === hostTransferId
        )

        if (index === -1) {
          setHostTransferId(hostTransferMemberList[0].uuid)
        }
      }
    }
  }, [hostTransferMemberList])

  return isHost && meetingInfo.endMeetingAction ? (
    <div
      className={`nemeeting-end-dropdown-container ${placementCls}`}
      onClick={() => {
        dispatch?.({
          type: ActionType.UPDATE_MEETING_INFO,
          data: {
            endMeetingAction: 0,
          },
        })
      }}
    >
      {meetingInfo.endMeetingAction === 1 ? (
        <div className="control-bar-end-button-cancel-container">
          <div className="control-bar-end-button-cancel">
            {t('globalCancel')}
          </div>
        </div>
      ) : null}
      {hostTransferOpen ? (
        <div
          className={`nemeeting-end-host-transfer-content`}
          onClick={(e) => e.stopPropagation()}
        >
          <div className="nemeeting-end-host-transfer-header">
            {t('meetingAppointNewHost')}
          </div>
          <div className="nemeeting-end-host-transfer-list">
            {hostTransferMemberList.map((item) => {
              return (
                <div
                  className="nemeeting-end-host-transfer-list-item"
                  key={item.uuid}
                  onClick={() => setHostTransferId(item.uuid)}
                >
                  <UserAvatar
                    size={24}
                    nickname={item.name}
                    avatar={item.avatar}
                  />
                  <div className="member-name-content">
                    <div className="member-name-text">{item.name}</div>
                    {item.role === Role.host && (
                      <div className="member-role">{`(${t('host')})`}</div>
                    )}
                    {item.role === Role.coHost && (
                      <div className="member-role">{`(${t('coHost')})`}</div>
                    )}
                  </div>
                  {hostTransferId === item.uuid ? (
                    <svg className="icon iconfont" aria-hidden="true">
                      <use xlinkHref="#iconcheck-line-regular1x"></use>
                    </svg>
                  ) : null}
                </div>
              )
            })}
          </div>
          <div className="nemeeting-end-host-transfer-footer">
            <div
              className="nemeeting-end-host-transfer-footer-button"
              onClick={onMeetingAppointAndLeave}
            >
              {t('meetingAppointAndLeave')}
            </div>
          </div>
        </div>
      ) : meetingInfo.endMeetingAction ? (
        <div
          className={`nemeeting-end-dropdown-content`}
          onClick={(e) => e.stopPropagation()}
        >
          <div className="nemeeting-end-dropdown-danger-button" onClick={onEnd}>
            {t('meetingQuit')}
          </div>
          <div className="nemeeting-end-dropdown-button" onClick={onLeave}>
            {t('leave')}
          </div>
          {meetingInfo.endMeetingAction !== 1 && (
            <div
              className="nemeeting-end-dropdown-button"
              onClick={() => {
                dispatch?.({
                  type: ActionType.UPDATE_MEETING_INFO,
                  data: {
                    endMeetingAction: 0,
                  },
                })
              }}
            >
              {t('globalCancel')}
            </div>
          )}
        </div>
      ) : null}
    </div>
  ) : null
}

const EndButton: React.FC = () => {
  const { t } = useTranslation()
  const { meetingInfo, dispatch } = useMeetingInfoContext()

  const { localMember } = meetingInfo

  const handleLeaveOrEnd = () => {
    dispatch?.({
      type: ActionType.UPDATE_MEETING_INFO,
      data: {
        endMeetingAction: 1,
      },
    })
  }

  return (
    <div className="control-bar-end-button" onClick={handleLeaveOrEnd}>
      {localMember.role === Role.host ? t('meetingQuit') : t('leave')}
    </div>
  )
}

export { EndButton, EndDropdown }
