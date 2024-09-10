import { Button, Checkbox, Dropdown, Input, MenuProps } from 'antd'
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../store'
import {
  hostAction,
  MeetingEventType,
  memberAction,
  NEMeetingInfo,
  NEMember,
  Role,
  SecurityCtrlEnum,
} from '../../../types'
import MemberItem from './MemberItem'

import { AutoSizer, List } from 'react-virtualized'
import NEMeetingService from '../../../services/NEMeeting'
import { NEMeetingInviteStatus } from '../../../types/type'
import Modal from '../../common/Modal'
import CommonModal from '../../common/CommonModal'
import Toast from '../../common/toast'
import UpdateUserNicknameModal from '../UpdateUserNicknameModal'
import './index.less'
import InSipInvitingMemberItem from './InSipInvitingMemberItem'
import WaitingRoomMemberItem from './WaitingRoomMemberItem'
import classNames from 'classnames'

interface MemberListFooterProps {
  meetingInfo: NEMeetingInfo
  neMeeting?: NEMeetingService
  hostUuid?: string
  isOwner?: boolean
  isHostOrCoHost?: boolean
  tab: 'room' | 'waitingRoom' | 'invite'
}

const MemberListFooter: React.FC<MemberListFooterProps> = ({
  meetingInfo,
  neMeeting,
  hostUuid,
  isOwner,
  isHostOrCoHost,
  tab,
}) => {
  const { t } = useTranslation()
  const { inInvitingMemberList, memberList } = useMeetingInfoContext()
  const { waitingRoomInfo } = useWaitingRoomContext()
  const meetingInfoRef = useRef<NEMeetingInfo | null>(null)
  const notAllowJoinRef = useRef(false)
  const [allowUnMuteVideoBySelf, setAllowUnMuteVideoBySelf] = useState(false)
  const [allowUnMuteAudioBySelf, setAllowUnMuteAudioBySelf] = useState(false)

  const [showMuteAllAudioModal, setShowMuteAllAudioModal] = useState(false)
  const [showMuteAllVideoModal, setShowMuteAllVideoModal] = useState(false)

  const [
    memberJoinOrLeaveMeetingPlaySound,
    setMemberJoinOrLeaveMeetingPlaySound,
  ] = useState(false)

  meetingInfoRef.current = meetingInfo

  const allowUnMuteVideoBySelfRef = useRef(true)
  const allowUnMuteAudioBySelfRef = useRef(true)

  const isElectronSharingScreen = useMemo(() => {
    return window.isElectronNative && meetingInfo.localMember?.isSharingScreen
  }, [meetingInfo.localMember?.isSharingScreen])

  const meetingReclaimHost = isOwner && !isHostOrCoHost

  // 是否允许checkbox需要与当前整体会控状态一致
  useEffect(() => {
    allowUnMuteVideoBySelfRef.current =
      !!meetingInfoRef.current?.unmuteAudioBySelfPermission
    allowUnMuteAudioBySelfRef.current =
      !!meetingInfoRef.current?.unmuteVideoBySelfPermission
  }, [])

  useEffect(() => {
    setMemberJoinOrLeaveMeetingPlaySound(!!meetingInfoRef.current?.playSound)
  }, [meetingInfoRef.current?.playSound])

  useEffect(() => {
    console.log(
      'setAllowUnMuteAudioBySelf',
      meetingInfo.unmuteAudioBySelfPermission
    )
    setAllowUnMuteAudioBySelf(!!meetingInfo.unmuteAudioBySelfPermission)
  }, [meetingInfo.unmuteAudioBySelfPermission])

  useEffect(() => {
    setAllowUnMuteVideoBySelf(!!meetingInfo.unmuteVideoBySelfPermission)
  }, [meetingInfo.unmuteVideoBySelfPermission])

  function muteVideo() {
    setShowMuteAllVideoModal(true)
  }

  function unmuteVideo() {
    neMeeting
      ?.securityControl({
        [SecurityCtrlEnum.VIDEO_OFF]: false,
        [SecurityCtrlEnum.VIDEO_NOT_ALLOW_SELF_ON]: false,
      })
      .then(() => {
        Toast.success(t('participantUnMuteAllVideoSuccess'))
      })
      .catch((error) => {
        Toast.fail(t('unMuteAllVideoFail'))
        throw error
      })
  }

  function muteAudio() {
    setShowMuteAllAudioModal(true)
  }

  function unmuteAudio() {
    neMeeting
      ?.securityControl({
        [SecurityCtrlEnum.AUDIO_OFF]: false,
        [SecurityCtrlEnum.AUDIO_NOT_ALLOW_SELF_ON]: false,
      })
      .then(() => {
        Toast.success(t('participantUnMuteAllAudioSuccess'))
      })
      .catch((error) => {
        Toast.fail(t('participantUnMuteAllAudioFail'))
        throw error
      })
  }

  function changePlaySound(value) {
    console.log('changePlaySound', value)

    neMeeting
      ?.securityControl({
        [SecurityCtrlEnum.PLAY_SOUND]: value,
      })
      .catch((error) => {
        Toast.fail(t('settingUpdateFailed'))
        throw error
      })
  }

  // 按钮
  const buttons = [
    {
      key: 'muteAudio',
      label: t('participantMuteAudioAll'),
      onClick: muteAudio,
      disabled:
        meetingInfo.muteBtnConfig?.showMuteAllAudio === false ||
        meetingReclaimHost,
    },
    {
      key: 'unmuteAudio',
      label: t('participantUnmuteAll'),
      onClick: unmuteAudio,
      disabled:
        meetingInfo.muteBtnConfig?.showUnMuteAllAudio === false ||
        meetingReclaimHost,
    },
    {
      key: 'muteVideo',
      label: t('participantTurnOffVideos'),
      onClick: muteVideo,
      disabled:
        meetingInfo.muteBtnConfig?.showMuteAllVideo === false ||
        meetingReclaimHost,
    },
    {
      key: 'unmuteVideo',
      label: t('unMuteVideoAll'),
      onClick: unmuteVideo,
      disabled:
        meetingInfo.muteBtnConfig?.showUnMuteAllVideo === false ||
        meetingReclaimHost,
    },
    {
      key: 'meetingReclaimHost',
      label: t('meetingReclaimHost'),
      onClick: async () => {
        try {
          await neMeeting?.sendMemberControl(
            memberAction.takeBackTheHost,
            hostUuid
          )
        } catch {
          Toast.fail(t('meetingReclaimHostFailed'))
        }
      },
      disabled: !meetingReclaimHost,
    },
    // {
    //   key: 'autoMute',
    //   label: (
    //     <div
    //       style={{
    //         display: 'flex',
    //         justifyContent: 'space-between',
    //         alignItems: 'center',
    //       }}
    //     >
    //       <div> {t('autoMute')}</div>
    //       <svg
    //         className="icon iconfont iconcheck-line-regular1x-blue"
    //         aria-hidden="true"
    //         style={{
    //           color: '#337eff',
    //         }}
    //       >
    //         <use xlinkHref="#iconcheck-line-regular1x"></use>
    //       </svg>
    //     </div>
    //   ),
    //   onClick: () => {},
    //   disabled: false,
    // },
    {
      key: 'memberJoinOrLeaveMeetingTip',
      label: (
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}
        >
          <div>{t('memberJoinOrLeaveMeetingTip')}</div>
          {memberJoinOrLeaveMeetingPlaySound && (
            <svg
              className="icon iconfont iconcheck-line-regular1x-blue"
              aria-hidden="true"
              style={{
                color: '#337eff',
                marginLeft: '10px',
              }}
            >
              <use xlinkHref="#iconcheck-line-regular1x"></use>
            </svg>
          )}
        </div>
      ),
      onClick: () => {
        console.log('memberJoinOrLeaveMeetingTip')

        changePlaySound(!memberJoinOrLeaveMeetingPlaySound)
      },
      disabled: meetingReclaimHost,
    },
  ].filter((item) => !item.disabled)

  const aheadButtons = buttons.splice(0, 2)

  const items: MenuProps['items'] = buttons

  const handleAdmitAll = () => {
    const maxMembers = meetingInfo.maxMembers || 0
    const inInvitingMemberListLength = inInvitingMemberList?.length || 0
    const memberListLength = memberList.length
    const waitingRoomMemberListLength = waitingRoomInfo.memberCount

    if (
      memberListLength +
        inInvitingMemberListLength +
        waitingRoomMemberListLength >
      maxMembers
    ) {
      Modal.warning({
        title: t('commonTitle'),
        content: t('participantUpperLimitTipAdmitOtherTip'),
      })
      return
    }

    CommonModal.confirm({
      title: t('waitingRoomAdmitMember'),
      width: 400,
      cancelText: t('globalCancel'),
      okText: t('waitingRoomAdmitAll'),
      content: (
        <div className="nemeeting-waiting-room-all-tip">
          {t('waitingRoomAdmitAllMembersTip')}
        </div>
      ),
      onOk: async () => {
        try {
          await neMeeting?.admitAllMembers()
        } catch (err) {
          const knownError = err as { message: string; msg: string }

          Toast.fail(knownError?.msg || knownError?.message)
        }
      },
    })
  }

  const handleRemoveAll = () => {
    CommonModal.confirm({
      title: t('participantExpelWaitingMemberDialogTitle'),
      width: 400,
      content: (
        <>
          <div className="nemeeting-waiting-room-all-tip">
            {t('waitingRoomRemoveAllMemberTip')}
          </div>
          {meetingInfo.enableBlacklist ? (
            <Checkbox
              style={{
                marginTop: '10px',
              }}
              className="close-checkbox-tip"
              onChange={(e) => (notAllowJoinRef.current = e.target.checked)}
            >
              {t('notAllowJoin')}
            </Checkbox>
          ) : null}
        </>
      ),
      cancelText: t('globalCancel'),
      okText: t('waitingRoomRemoveAll'),
      onOk: async () => {
        try {
          await neMeeting?.expelAllMembers(notAllowJoinRef.current)
        } catch (err: unknown) {
          const knownError = err as { message: string; msg: string }

          Toast.fail(knownError?.msg || knownError?.message)
        }
      },
    })
  }

  return (
    <>
      {tab === 'room' || tab === 'invite' ? (
        aheadButtons.length === 0 ? null : (
          <div
            className={`${
              isElectronSharingScreen ? 'member-List-footer-item-sharing' : ''
            } member-List-footer-item`}
          >
            <Modal
              className="nemeeting-mute-media-modal"
              closeIcon={null}
              open={showMuteAllVideoModal}
              title={t('participantMuteVideoAllDialogTips')}
              width={416}
              okText={t('participantTurnOffVideos')}
              onCancel={() => setShowMuteAllVideoModal(false)}
              onOk={async () => {
                const type = allowUnMuteVideoBySelf
                  ? hostAction.muteAllVideo
                  : hostAction.forceMuteAllVideo

                try {
                  await neMeeting?.securityControl({
                    [SecurityCtrlEnum.VIDEO_OFF]: true,
                    [SecurityCtrlEnum.VIDEO_NOT_ALLOW_SELF_ON]:
                      type === hostAction.forceMuteAllVideo,
                  })
                  Toast.success(t('participantMuteAllVideoSuccess'))
                  setShowMuteAllVideoModal(false)
                } catch (error) {
                  Toast.fail(t('participantMuteAllVideoFail'))
                }
              }}
            >
              <>
                <Checkbox
                  checked={allowUnMuteVideoBySelf}
                  onChange={(e) => {
                    setAllowUnMuteVideoBySelf(e.target.checked)
                  }}
                >
                  {t('participantMuteAllVideoTip')}
                </Checkbox>
              </>
            </Modal>
            <Modal
              className="nemeeting-mute-media-modal"
              closeIcon={null}
              open={showMuteAllAudioModal}
              title={t('participantMuteAudioAllDialogTips')}
              width={416}
              okText={t('participantMuteAudioAll')}
              onCancel={() => setShowMuteAllAudioModal(false)}
              onOk={() => {
                const type = allowUnMuteAudioBySelf
                  ? hostAction.muteAllAudio
                  : hostAction.forceMuteAllAudio

                return neMeeting
                  ?.securityControl({
                    [SecurityCtrlEnum.AUDIO_OFF]: true,
                    [SecurityCtrlEnum.AUDIO_NOT_ALLOW_SELF_ON]:
                      type === hostAction.forceMuteAllAudio,
                  })
                  .then(() => {
                    Toast.success(t('participantMuteAllAudioSuccess'))
                    setShowMuteAllAudioModal(false)
                  })
                  .catch((error) => {
                    Toast.fail(t('participantMuteAllAudioFail'))
                    throw error
                  })
              }}
            >
              <>
                <Checkbox
                  checked={allowUnMuteAudioBySelf}
                  onChange={(e) => {
                    allowUnMuteAudioBySelfRef.current = e.target.checked
                    setAllowUnMuteAudioBySelf(e.target.checked)
                  }}
                >
                  {t('participantMuteAllAudioTip')}
                </Checkbox>
              </>
            </Modal>
            {aheadButtons.map((item, index) => {
              return (
                <Button
                  key={item.key}
                  className={classNames('member-List-footer-btn', {
                    'member-List-footer-btn-unmute-Audio':
                      item.key === 'unmuteAudio',
                    'meeting-reclaim-host-btn':
                      item.key === 'meetingReclaimHost',
                  })}
                  onClick={item.onClick}
                  title={item.label as string}
                  style={{
                    maxWidth: index === 1 ? '108px' : '80px',
                    padding: '10px 10px',
                  }}
                >
                  {item.label}
                </Button>
              )
            })}
            {items.length > 0 ? (
              <Dropdown
                menu={{ items }}
                trigger={['click']}
                placement="topRight"
                rootClassName="member-list-footer-more-btn-drop-down"
              >
                <Button className="member-list-footer-more-btn">
                  <span style={{ height: '16px', lineHeight: '16px' }}>
                    <span className="member-list-footer-more-btn-text">
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
            ) : null}
          </div>
        )
      ) : (
        <div
          className={`${
            isElectronSharingScreen ? 'member-List-footer-item-sharing' : ''
          } member-List-footer-item member-list-waiting-footer-item`}
        >
          <Button
            style={{ width: 124 }}
            className="member-List-footer-btn waiting-roomAdmit-all-btn"
            type="primary"
            onClick={handleAdmitAll}
            title={t('waitingRoomAdmitAll')}
          >
            {t('waitingRoomAdmitAll')}
          </Button>
          <Button
            style={{ width: 124 }}
            className="member-List-footer-btn"
            onClick={handleRemoveAll}
            title={t('waitingRoomRemoveAll')}
          >
            {t('waitingRoomRemoveAll')}
          </Button>
        </div>
      )}
    </>
  )
}

const MemberList: React.FC = () => {
  const { t } = useTranslation()
  const {
    meetingInfo,
    memberList,
    inInvitingMemberList: inSipInvitingMemberList,
  } = useMeetingInfoContext()
  const { neMeeting, eventEmitter, globalConfig } = useGlobalContext()
  const { waitingRoomInfo, memberList: waitingRoomMemberList } =
    useWaitingRoomContext()
  const scrollRef = useRef<HTMLDivElement>(null)
  const getWaitingRoomMemberRef = useRef(false)

  const [updateUserNicknameModalOpen, setUpdateUserNicknameModalOpen] =
    useState(false)

  const [updateUserNicknameInfo, setUpdateUserNicknameInfo] = useState({
    oldName: '',
    uuid: '',
    roomType: 'room',
  })

  useEffect(() => {
    eventEmitter?.on(
      MeetingEventType.changeMemberListTab,
      (tab: 'room' | 'waitingRoom' | 'invite') => {
        if (tab === 'waitingRoom' && waitingRoomInfo.memberCount > 0) {
          neMeeting?.updateMeetingInfo({
            activeMemberManageTab: tab,
          })
        } else if (
          tab === 'invite' &&
          inSipInvitingMemberList &&
          inSipInvitingMemberList.length > 0
        ) {
          neMeeting?.updateMeetingInfo({
            activeMemberManageTab: 'invite',
          })
        } else {
          neMeeting?.updateMeetingInfo({
            // activeMemberManageTab: 'room',
          })
        }
      }
    )
    return () => {
      eventEmitter?.off(MeetingEventType.changeMemberListTab)
    }
  }, [
    waitingRoomInfo.memberCount,
    inSipInvitingMemberList,
    eventEmitter,
    neMeeting,
  ])

  const { localMember } = meetingInfo

  const [searchName, setSearchName] = useState('')

  const isOwner = useMemo(
    () => localMember.uuid === meetingInfo.ownerUserUuid,
    [localMember.uuid, meetingInfo.ownerUserUuid]
  )

  const isHostOrCoHost = useMemo(
    () => localMember.role === Role.host || localMember.role === Role.coHost,
    [localMember.role]
  )

  const hostUuid = useMemo(() => {
    return memberList.find((item) => item.role === Role.host)?.uuid
  }, [memberList])

  useEffect(() => {
    // 如果是主持人或者联席主持人才有等候室tab
    if (localMember && localMember.role && !isHostOrCoHost) {
      neMeeting?.updateMeetingInfo({
        activeMemberManageTab: 'room',
      })
    }
  }, [isHostOrCoHost, localMember, neMeeting])

  const [showMemberList, setShowMemberList] = useState<NEMember[]>([])

  useEffect(() => {
    // 主持人->联席主持人->自己->举手->屏幕共享（白板）>音视频>视频->音频->昵称排序
    const host: NEMember[] = []
    const coHost: NEMember[] = []
    const handsUp: NEMember[] = []
    const sharingWhiteboardOrScreen: NEMember[] = []
    const audioOn: NEMember[] = []
    const videoOn: NEMember[] = []
    const audioAndVideoOn: NEMember[] = []
    const other: NEMember[] = []

    memberList.forEach((member) => {
      if (member.role === Role.host) {
        host.push(member)
      } else if (member.role === Role.coHost) {
        coHost.push(member)
      } else if (member.uuid === localMember.uuid) {
        // 本人永远排在主持和联席主持人之后
        return
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
    const hostOrCoHostWithMe =
      [...host, ...coHost]?.findIndex(
        (item) => item.uuid === localMember.uuid
      ) > -1
        ? [...host, ...coHost]
        : [...host, ...coHost, localMember]
    const res = [
      ...hostOrCoHostWithMe,
      ...handsUp,
      ...sharingWhiteboardOrScreen,
      ...audioAndVideoOn,
      ...videoOn,
      ...audioOn,
      ...other,
    ]

    setShowMemberList(res)
  }, [memberList, localMember])

  const memberListFilter = useMemo(() => {
    return showMemberList.filter((member) =>
      member.name.toLowerCase().includes(searchName.toLowerCase())
    )
  }, [searchName, showMemberList])

  const waitingRoomMemberListFilter = useMemo(() => {
    return searchName
      ? waitingRoomMemberList.filter((member) =>
          member.name.toLowerCase().includes(searchName.toLowerCase())
        )
      : waitingRoomMemberList
  }, [searchName, waitingRoomMemberList])

  // 需要进行呼叫中>等待呼叫（按照选择顺序排）>未接听/已拒接>待入会
  const inSipInvitingMemberListSort = useMemo(() => {
    if (!inSipInvitingMemberList) {
      return []
    }

    const calling: NEMember[] = []
    const waiting: NEMember[] = []
    const notAnswered: NEMember[] = []
    const toBeInvited: NEMember[] = []

    inSipInvitingMemberList.forEach((member) => {
      if (member.inviteState === NEMeetingInviteStatus.calling) {
        calling.push(member)
      } else if (member.inviteState === NEMeetingInviteStatus.waitingCall) {
        waiting.push(member)
      } else if (
        member.inviteState === NEMeetingInviteStatus.noAnswer ||
        member.inviteState === NEMeetingInviteStatus.rejected
      ) {
        notAnswered.push(member)
      } else {
        toBeInvited.push(member)
      }
    })
    return [...calling, ...waiting, ...notAnswered, ...toBeInvited]
  }, [inSipInvitingMemberList])

  const inSipInvitingMemberListFilter = useMemo(() => {
    if (!inSipInvitingMemberListSort) {
      return []
    }

    return searchName
      ? inSipInvitingMemberListSort?.filter((member) =>
          member.name.toLowerCase().includes(searchName.toLowerCase())
        )
      : inSipInvitingMemberListSort
  }, [searchName, inSipInvitingMemberListSort])

  function changeTab(tab: 'room' | 'waitingRoom' | 'invite') {
    neMeeting?.updateMeetingInfo({
      activeMemberManageTab: tab,
    })
  }

  // useUpdateEffect(() => {
  //   if (!waitingRoomInfo.isEnabledOnEntry || waitingRoomInfo.memberCount == 0) {
  //     if (meetingInfo.activeMemberManageTab === 'waitingRoom') {
  //       neMeeting?.updateMeetingInfo({
  //         activeMemberManageTab: 'room',
  //       })
  //     }
  //   }
  // }, [waitingRoomInfo.isEnabledOnEntry, waitingRoomInfo.memberCount])

  // useUpdateEffect(() => {
  //   if (!inSipInvitingMemberList || inSipInvitingMemberList?.length == 0) {
  //     if (meetingInfo.activeMemberManageTab === 'invite') {
  //       neMeeting?.updateMeetingInfo({
  //         activeMemberManageTab: 'room',
  //       })
  //     }
  //   }
  // }, [inSipInvitingMemberList?.length])

  useEffect(() => {
    if (meetingInfo.activeMemberManageTab === 'waitingRoom') {
      neMeeting?.updateWaitingRoomUnReadCount(0)
    }
  }, [meetingInfo.activeMemberManageTab, neMeeting])

  useEffect(() => {
    if (meetingInfo.activeMemberManageTab === 'waitingRoom') {
      const scrollElement = scrollRef.current

      if (!scrollElement) {
        return
      }

      const handleScroll = () => {
        if (
          scrollElement &&
          scrollElement.scrollTop + scrollElement.clientHeight >=
            scrollElement.scrollHeight
        ) {
          if (
            getWaitingRoomMemberRef.current ||
            waitingRoomMemberList.length === 0
          ) {
            return
          }

          const lastMember =
            waitingRoomMemberList[waitingRoomMemberList.length - 1]

          if (!lastMember) {
            return
          }

          getWaitingRoomMemberRef.current = true
          neMeeting
            ?.waitingRoomGetMemberList?.(lastMember?.joinTime, 20, true)
            ?.finally(() => {
              getWaitingRoomMemberRef.current = false
            })
          /*
          .then((res) => {
            const members = res.data
            waitingRoomDispatch?.({
              type: ActionType.WAITING_ROOM_SET_MEMBER_LIST,
              data: { memberList: [...waitingRoomMemberList, ...members] },
            })
          })
            */
          neMeeting?.waitingRoomController?.getMemberList(
            lastMember.joinTime,
            20,
            true
          )
        }
      }

      scrollElement.addEventListener('scroll', handleScroll)
      return () => {
        scrollElement.removeEventListener('scroll', handleScroll)
      }
    }
  }, [meetingInfo.activeMemberManageTab, waitingRoomMemberList, neMeeting])

  const handleUpdateUserNickname = (
    uuid: string,
    name: string,
    roomType: 'room' | 'waitingRoom'
  ) => {
    if (!meetingInfo.updateNicknamePermission && !isHostOrCoHost) {
      Toast.fail(t('updateNicknameNoPermission'))
      return
    }

    setUpdateUserNicknameInfo({
      oldName: name,
      uuid,
      roomType,
    })
    setUpdateUserNicknameModalOpen(true)
  }

  // 联席主持人数量是否超过限制
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
  const roomRowRenderer = useCallback(
    ({ index, key, style }) => {
      const member = memberListFilter[index]

      return (
        <div style={style} key={key}>
          <MemberItem
            neMeeting={neMeeting}
            meetingInfo={meetingInfo}
            key={member.uuid}
            data={member}
            isOverCohostLimitCount={isOverCohostLimitCount}
            ownerUserUuid={meetingInfo.ownerUserUuid}
            handleUpdateUserNickname={handleUpdateUserNickname}
          />
        </div>
      )
    },
    [memberListFilter, meetingInfo, neMeeting]
  )

  const waitingRoomRowRenderer = useCallback(
    ({ index, key, style }) => {
      const member = waitingRoomMemberListFilter[index]

      return (
        <div style={style} key={key}>
          <WaitingRoomMemberItem
            neMeeting={neMeeting}
            key={member.uuid}
            data={member}
            handleUpdateUserNickname={handleUpdateUserNickname}
          />
        </div>
      )
    },

    [waitingRoomMemberListFilter, neMeeting]
  )

  const inSipInvitingRowRenderer = useCallback(
    ({ index, key, style }) => {
      if (!inSipInvitingMemberListFilter) {
        return <div style={style} key={key}></div>
      }

      const member = inSipInvitingMemberListFilter[index]

      console.log('inSipInvitingRowRenderer', member)
      return (
        <div style={style} key={key}>
          <InSipInvitingMemberItem
            neMeeting={neMeeting}
            key={member.uuid}
            data={member}
          />
        </div>
      )
    },
    [inSipInvitingMemberListFilter, neMeeting]
  )
  const showWaitingTab = useMemo(() => {
    return waitingRoomMemberList.length > 0 && waitingRoomInfo.memberCount > 0
  }, [waitingRoomInfo.memberCount, waitingRoomMemberList.length])

  const showSipInviteTab = useMemo(() => {
    return inSipInvitingMemberList ? inSipInvitingMemberList.length > 0 : false
  }, [inSipInvitingMemberList])

  const footerTab = useMemo(() => {
    if (showWaitingTab && meetingInfo.activeMemberManageTab === 'waitingRoom') {
      return 'waitingRoom'
    } else if (
      showSipInviteTab &&
      meetingInfo.activeMemberManageTab === 'invite'
    ) {
      return 'invite'
    } else {
      return 'room'
    }
  }, [showWaitingTab, showSipInviteTab, meetingInfo.activeMemberManageTab])

  return (
    // <Drawer
    //   title={
    //     <span>
    //       {t('memberListTitle') + `(${memberList.length})`}
    //       {[
    //         AttendeeOffType.offAllowSelfOn,
    //         AttendeeOffType.offNotAllowSelfOn,
    //       ].includes(meetingInfo.audioOff) && (
    //         <i className="iconfont iconyx-tv-voice-offx icon-red" />
    //       )}
    //     </span>
    //   }
    //   placement="right"
    //   footer={
    //     isHostOrCoHost ? (
    //       <MemberListFooter meetingInfo={meetingInfo} neMeeting={neMeeting} />
    //     ) : null
    //   }
    //   width={320}
    //   mask={false}
    //   maskClosable={false}
    //   keyboard={false}
    //   rootClassName={`member-list-drawer ${
    //     window.ipcRenderer ? 'member-list-drawer-ele' : ''
    //   }`}
    //   {...restProps}
    // >

    // </Drawer>
    <div className="member-list-container">
      <div className="pd20">
        <Input
          className="member-list-search"
          placeholder={t('searchName')}
          prefix={
            <svg
              className="icon iconfont member-list-search-iconsousuo"
              aria-hidden="true"
            >
              <use xlinkHref="#iconsousuo"></use>
            </svg>
          }
          value={searchName}
          allowClear
          onChange={(e) => setSearchName(e.target.value)}
        />
      </div>

      {isHostOrCoHost && (showWaitingTab || showSipInviteTab) && (
        <div className="pd20">
          <div className="nemeeting-member-list-tabs">
            <div
              className={`nemeeting-member-list-tab ${
                meetingInfo.activeMemberManageTab == 'room' ||
                (meetingInfo.activeMemberManageTab == 'waitingRoom' &&
                  !showWaitingTab) ||
                (!showSipInviteTab &&
                  meetingInfo.activeMemberManageTab == 'invite')
                  ? 'nemeeting-member-list-tab-selected'
                  : ''
              }`}
              onClick={() => changeTab('room')}
              title={t('inMeeting')}
            >
              {t('inMeeting')}({memberList.length})
            </div>
            {showWaitingTab && (
              <div
                className={`nemeeting-member-list-tab ${
                  meetingInfo.activeMemberManageTab == 'waitingRoom'
                    ? 'nemeeting-member-list-tab-selected'
                    : ''
                }`}
                title={t('waitingRoom')}
                onClick={() => changeTab('waitingRoom')}
              >
                <span style={{ position: 'relative' }}>
                  {t('waitingRoom')}({waitingRoomInfo.memberCount})
                  {!!waitingRoomInfo.unReadMsgCount && (
                    <span className="waiting-room-unread-notify"></span>
                  )}
                </span>
              </div>
            )}

            {showSipInviteTab && (
              <div
                className={`nemeeting-member-list-tab ${
                  meetingInfo.activeMemberManageTab == 'invite'
                    ? 'nemeeting-member-list-tab-selected'
                    : ''
                }`}
                onClick={() => changeTab('invite')}
                title={t('participantNotJoined')}
              >
                {t('participantNotJoined')}({inSipInvitingMemberList?.length})
              </div>
            )}
          </div>
        </div>
      )}

      <div className="member-list-content" ref={scrollRef}>
        {(meetingInfo.activeMemberManageTab === 'room' ||
          (meetingInfo.activeMemberManageTab === 'invite' &&
            !showSipInviteTab) ||
          (meetingInfo.activeMemberManageTab === 'waitingRoom' &&
            !showWaitingTab)) && (
          <AutoSizer>
            {({ height, width }) => (
              <List
                height={height}
                overscanRowCount={10}
                rowCount={memberListFilter.length}
                rowHeight={48}
                rowRenderer={roomRowRenderer}
                width={width}
              />
            )}
          </AutoSizer>
        )}
        {meetingInfo.activeMemberManageTab === 'waitingRoom' &&
          showWaitingTab && (
            <AutoSizer>
              {({ height, width }) => (
                <List
                  height={height}
                  overscanRowCount={10}
                  rowCount={waitingRoomMemberListFilter.length}
                  rowHeight={46}
                  rowRenderer={waitingRoomRowRenderer}
                  width={width}
                />
              )}
            </AutoSizer>
          )}
        {meetingInfo.activeMemberManageTab === 'invite' && showSipInviteTab && (
          <AutoSizer>
            {({ height, width }) => (
              <List
                height={height}
                overscanRowCount={10}
                rowCount={inSipInvitingMemberListFilter?.length || 0}
                rowHeight={48}
                rowRenderer={inSipInvitingRowRenderer}
                width={width}
              />
            )}
          </AutoSizer>
        )}
        <UpdateUserNicknameModal
          nickname={updateUserNicknameInfo.oldName}
          open={updateUserNicknameModalOpen}
          onCancel={() => setUpdateUserNicknameModalOpen(false)}
          onSummit={(values) => {
            setUpdateUserNicknameModalOpen(false)
            if (!meetingInfo.updateNicknamePermission && !isHostOrCoHost) {
              Toast.fail(t('updateNicknameNoPermission'))
              return
            }

            if (updateUserNicknameInfo.roomType === 'room') {
              neMeeting
                ?.modifyNickName({
                  nickName: values.nickname,
                  userUuid: updateUserNicknameInfo.uuid,
                })
                .then(() => {
                  Toast.success(t('reNameSuccessToast'))
                })
                .catch((error) => {
                  Toast.fail(
                    t(error.message || error.msg || 'reNameFailureToast')
                  )
                  throw error
                })
            } else {
              neMeeting
                ?.waitingRoomChangeMemberName(
                  updateUserNicknameInfo.uuid,
                  values.nickname
                )
                ?.then(() => {
                  Toast.success(t('reNameSuccessToast'))
                })
                .catch((e) => {
                  Toast.fail(e.message || e.msg || t('reNameFailureToast'))
                  throw e
                })
            }
          }}
        />
      </div>
      {isHostOrCoHost || isOwner ? (
        <MemberListFooter
          tab={footerTab}
          meetingInfo={meetingInfo}
          neMeeting={neMeeting}
          isHostOrCoHost={isHostOrCoHost}
          isOwner={isOwner}
          hostUuid={hostUuid}
        />
      ) : null}
    </div>
  )
}

export default MemberList
