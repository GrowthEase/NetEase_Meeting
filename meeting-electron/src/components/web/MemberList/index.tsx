import { Button, Checkbox, Dropdown, Input, MenuProps } from 'antd'
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'

import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../store'
import {
  AttendeeOffType,
  hostAction,
  MeetingEventType,
  memberAction,
  NEMeetingInfo,
  NEMember,
  Role,
} from '../../../types'
import MemberItem from './MemberItem'

import { AutoSizer, List } from 'react-virtualized'
import NEMeetingService from '../../../services/NEMeeting'
import { NEMeetingInviteStatus } from '../../../types/type'
import Modal from '../../common/Modal'
import Toast from '../../common/toast'
import UpdateUserNicknameModal from '../BeforeMeetingModal/UpdateUserNicknameModal'
import './index.less'
import InSipInvitingMemberItem from './InSipInvitingMemberItem'
import WaitingRoomMemberItem from './WaitingRoomMemberItem'

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
  const muteAllAudioModalRef = useRef<any>(null)
  const notAllowJoinRef = useRef(false)

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
      meetingInfoRef.current?.videoOff !== AttendeeOffType.offNotAllowSelfOn
    allowUnMuteAudioBySelfRef.current =
      meetingInfoRef.current?.audioOff !== AttendeeOffType.offNotAllowSelfOn
  }, [meetingInfoRef.current])

  function muteVideo() {
    if (muteAllAudioModalRef.current) {
      return
    }

    muteAllAudioModalRef.current = Modal.confirm({
      title: t('participantMuteVideoAllDialogTips'),
      content: (
        <Checkbox
          defaultChecked={allowUnMuteVideoBySelfRef.current}
          onChange={(e) =>
            (allowUnMuteVideoBySelfRef.current = e.target.checked)
          }
        >
          {t('participantMuteAllVideoTip')}
        </Checkbox>
      ),
      afterClose: () => {
        muteAllAudioModalRef.current = null
      },
      okText: t('participantTurnOffVideos'),
      onOk: async () => {
        const type = allowUnMuteVideoBySelfRef.current
          ? hostAction.muteAllVideo
          : hostAction.forceMuteAllVideo

        try {
          await neMeeting?.sendHostControl(type, '')
          Toast.success(t('participantMuteAllVideoSuccess'))
        } catch (error) {
          Toast.fail(t('participantMuteAllVideoFail'))
        }
      },
    })
  }

  function unmuteVideo() {
    neMeeting
      ?.sendHostControl(hostAction.unmuteAllVideo, '')
      .then(() => {
        Toast.success(t('participantUnMuteAllVideoSuccess'))
      })
      .catch((error) => {
        Toast.fail(t('unMuteAllVideoFail'))
        throw error
      })
  }

  function muteAudio() {
    Modal.confirm({
      title: t('participantMuteAudioAllDialogTips'),
      content: (
        <Checkbox
          defaultChecked={allowUnMuteAudioBySelfRef.current}
          onChange={(e) =>
            (allowUnMuteAudioBySelfRef.current = e.target.checked)
          }
        >
          {t('participantMuteAllAudioTip')}
        </Checkbox>
      ),
      okText: t('participantMuteAudioAll'),
      onOk() {
        const type = allowUnMuteAudioBySelfRef.current
          ? hostAction.muteAllAudio
          : hostAction.forceMuteAllAudio

        return neMeeting
          ?.sendHostControl(type, '')
          .then(() => {
            Toast.success(t('participantMuteAllAudioSuccess'))
          })
          .catch((error) => {
            Toast.fail(t('participantMuteAllAudioFail'))
            throw error
          })
      },
    })
  }

  function unmuteAudio() {
    neMeeting
      ?.sendHostControl(hostAction.unmuteAllAudio, '')
      .then(() => {
        Toast.success(t('participantUnMuteAllAudioSuccess'))
      })
      .catch((error) => {
        Toast.fail(t('participantUnMuteAllAudioFail'))
        throw error
      })
  }

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

    Modal.confirm({
      title: t('waitingRoomAdmitMember'),
      width: 270,
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
    Modal.confirm({
      title: t('participantExpelWaitingMemberDialogTitle'),
      width: 270,
      content: (
        <>
          <div className="nemeeting-waiting-room-all-tip">
            {t('waitingRoomRemoveAllMemberTip')}
          </div>
          {meetingInfo.enableBlacklist ? (
            <Checkbox
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
      {/* <div className="member-List-footer-item">
        <label>{t('lockMeeting')}</label>
        <Switch
          onChange={() => toggleMeetingLock()}
          checked={meetingInfo.isLocked}
          // @ts-ignore
          onKeyDown={(e) => e.preventDefault()}
        />
      </div> */}
      {tab === 'room' || tab === 'invite' ? (
        aheadButtons.length === 0 ? null : (
          <div
            className={`${
              isElectronSharingScreen ? 'member-List-footer-item-sharing' : ''
            } member-List-footer-item pd20`}
          >
            {aheadButtons.map((item, index) => {
              return (
                <Button
                  key={item.key}
                  className="member-List-footer-btn"
                  type="primary"
                  onClick={item.onClick}
                  title={item.label}
                  style={{ maxWidth: index === 1 ? '126px' : '102px' }}
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
              >
                <div className="member-list-footer-more-btn">
                  <svg className="icon iconfont" aria-hidden="true">
                    <use xlinkHref="#icongengduo"></use>
                  </svg>
                </div>
              </Dropdown>
            ) : null}
          </div>
        )
      ) : (
        <div
          className={`${
            isElectronSharingScreen ? 'member-List-footer-item-sharing' : ''
          } member-List-footer-item member-list-waiting-footer-item pd20`}
        >
          <Button
            style={{ width: 124 }}
            className="member-List-footer-btn"
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
  const { neMeeting, eventEmitter } = useGlobalContext()
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
  }, [waitingRoomInfo.memberCount, inSipInvitingMemberList?.length])

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
        //@ts-ignore
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
  }, [meetingInfo.activeMemberManageTab, waitingRoomMemberList.length])

  const handleUpdateUserNickname = (
    uuid: string,
    name: string,
    roomType: 'room' | 'waitingRoom'
  ) => {
    setUpdateUserNicknameInfo({
      oldName: name,
      uuid,
      roomType,
    })
    setUpdateUserNicknameModalOpen(true)
  }

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

    [waitingRoomMemberListFilter, meetingInfo.enableBlacklist]
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
  }, [inSipInvitingMemberList?.length])

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
                rowHeight={40}
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
                rowHeight={46}
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
