import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import {
  Input,
  Drawer,
  Button,
  Switch,
  Checkbox,
  DrawerProps,
  Dropdown,
  MenuProps,
} from 'antd'
import { useTranslation } from 'react-i18next'
import { useUpdateEffect } from 'ahooks'

import MemberItem from './MemberItem'
import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../store'
import {
  ActionType,
  AttendeeOffType,
  MeetingEventType,
  NEMeetingInfo,
  NEMember,
  Role,
  hostAction,
} from '../../../types'

import './index.less'
import Modal from '../../common/Modal'
import Toast from '../../common/toast'
import NEMeetingService from '../../../services/NEMeeting'
import WaitingRoomMemberItem from './WaitingRoomMemberItem'
import { NEWaitingRoomMember } from 'neroom-web-sdk/dist/types/types/interface'
import { AutoSizer, List } from 'react-virtualized'
import UpdateUserNicknameModal from '../BeforeMeetingModal/UpdateUserNicknameModal'

interface MemberListFooterProps {
  meetingInfo: NEMeetingInfo
  neMeeting?: NEMeetingService
}

const MemberListFooter: React.FC<MemberListFooterProps> = ({
  meetingInfo,
  neMeeting,
}) => {
  const { t } = useTranslation()
  const meetingInfoRef = useRef<NEMeetingInfo | null>(null)
  const muteAllAudioModalRef = useRef<any>(null)
  meetingInfoRef.current = meetingInfo

  const allowUnMuteVideoBySelfRef = useRef(true)
  const allowUnMuteAudioBySelfRef = useRef(true)

  const isElectronSharingScreen = useMemo(() => {
    return window.isElectronNative && meetingInfo.localMember?.isSharingScreen
  }, [meetingInfo.localMember?.isSharingScreen])

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
      title: t('muteVideoAllDialogTips'),
      content: (
        <Checkbox
          defaultChecked={allowUnMuteVideoBySelfRef.current}
          onChange={(e) =>
            (allowUnMuteVideoBySelfRef.current = e.target.checked)
          }
        >
          {t('muteAllVideoTip')}
        </Checkbox>
      ),
      afterClose: () => {
        muteAllAudioModalRef.current = null
      },
      okText: t('muteVideoAll'),
      onOk: async () => {
        const type = allowUnMuteVideoBySelfRef.current
          ? hostAction.muteAllVideo
          : hostAction.forceMuteAllVideo

        try {
          await neMeeting?.sendHostControl(type, '')
          Toast.success(t('muteAllVideoSuccess'))
        } catch (error) {
          Toast.fail(t('muteAllVideoFail'))
        }
      },
    })
  }
  function unmuteVideo() {
    neMeeting
      ?.sendHostControl(hostAction.unmuteAllVideo, '')
      .then(() => {
        Toast.success(t('unMuteAllVideoSuccess'))
      })
      .catch((error) => {
        Toast.fail(t('unMuteAllVideoFail'))
        throw error
      })
  }
  function muteAudio() {
    Modal.confirm({
      title: t('muteAudioAllDialogTips'),
      content: (
        <Checkbox
          defaultChecked={allowUnMuteAudioBySelfRef.current}
          onChange={(e) =>
            (allowUnMuteAudioBySelfRef.current = e.target.checked)
          }
        >
          {t('muteAllAudioTip')}
        </Checkbox>
      ),
      okText: t('muteAudioAll'),
      onOk() {
        const type = allowUnMuteAudioBySelfRef.current
          ? hostAction.muteAllAudio
          : hostAction.forceMuteAllAudio
        return neMeeting
          ?.sendHostControl(type, '')
          .then(() => {
            Toast.success(t('muteAllAudioSuccess'))
          })
          .catch((error) => {
            Toast.fail(t('muteAllAudioFail'))
            throw error
          })
      },
    })
  }
  function unmuteAudio() {
    neMeeting
      ?.sendHostControl(hostAction.unmuteAllAudio, '')
      .then(() => {
        Toast.success(t('unMuteAllAudioSuccess'))
      })
      .catch((error) => {
        Toast.fail(t('unMuteAllAudioFail'))
        throw error
      })
  }
  function toggleMeetingLock() {
    const enable = !meetingInfo.isLocked
    const type = enable ? hostAction.lockMeeting : hostAction.unlockMeeting
    const failMsg = enable
      ? t('lockMeetingByHostFail')
      : t('unLockMeetingByHostFail')

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
  }

  const buttons = [
    {
      key: 'muteAudio',
      label: t('muteAudioAll'),
      onClick: muteAudio,
      disabled: meetingInfo.muteBtnConfig?.showMuteAllAudio === false,
    },
    {
      key: 'unmuteAudio',
      label: t('unMuteAudioAll'),
      onClick: unmuteAudio,
      disabled: meetingInfo.muteBtnConfig?.showUnMuteAllAudio === false,
    },
    {
      key: 'muteVideo',
      label: t('muteVideoAll'),
      onClick: muteVideo,
      disabled: meetingInfo.muteBtnConfig?.showMuteAllVideo === false,
    },
    {
      key: 'unmuteVideo',
      label: t('unMuteVideoAll'),
      onClick: unmuteVideo,
      disabled: meetingInfo.muteBtnConfig?.showUnMuteAllVideo === false,
    },
  ].filter((item) => !item.disabled)

  const aheadButtons = buttons.splice(0, 2)

  const items: MenuProps['items'] = buttons

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
      {aheadButtons.length === 0 ? null : (
        <div
          className={`${
            isElectronSharingScreen ? 'member-List-footer-item-sharing' : ''
          } member-List-footer-item pd20`}
        >
          {aheadButtons.map((item) => {
            return (
              <Button
                key={item.key}
                className="member-List-footer-btn"
                type="primary"
                onClick={item.onClick}
              >
                {item.label}
              </Button>
            )
          })}
          {items.length > 0 ? (
            <Dropdown menu={{ items }} trigger={['click']} placement="topRight">
              <div className="member-list-footer-more-btn">
                <svg className="icon iconfont" aria-hidden="true">
                  <use xlinkHref="#icongengduo"></use>
                </svg>
              </div>
            </Dropdown>
          ) : null}
        </div>
      )}
    </>
  )
}

interface MemberListProps extends DrawerProps {
  memberList?: NEMember[]
  meetingInfo?: NEMeetingInfo
  waitingRoomInfo?: {
    memberCount: number
    isEnabledOnEntry: boolean
    unReadMsgCount?: number
  }
  waitingRoomMemberList?: NEWaitingRoomMember[]
  neMeeting?: NEMeetingService
}

const MemberList: React.FC<MemberListProps> = ({
  memberList: initMemberList,
  meetingInfo: initMeetingInfo,
  waitingRoomInfo: initWaitingRoomInfo,
  waitingRoomMemberList: initWaitingRoomMemberList,
  neMeeting: initNeMeeting,
  ...restProps
}) => {
  const { t } = useTranslation()
  const { memberList: memberListContext } = useMeetingInfoContext()
  const { meetingInfo: meetingInfoContext } = useMeetingInfoContext()
  const { neMeeting: neMeetingContext, eventEmitter } = useGlobalContext()
  const {
    waitingRoomInfo: waitingRoomInfoContext,
    memberList: waitingRoomMemberListContext,
  } = useWaitingRoomContext()
  const scrollRef = useRef<HTMLDivElement>(null)
  const getWaitingRoomMemberRef = useRef(false)

  const neMeeting = initNeMeeting || neMeetingContext

  const [memberList, setMemberList] = useState(
    initMemberList || memberListContext
  )
  const [meetingInfo, setMeetingInfo] = useState(
    initMeetingInfo || meetingInfoContext
  )

  const [waitingRoomInfo, setWaitingRoomInfo] = useState(
    initWaitingRoomInfo || waitingRoomInfoContext
  )

  const [waitingRoomMemberList, setWaitingRoomMemberList] = useState(
    initWaitingRoomMemberList || waitingRoomMemberListContext
  )
  const [updateUserNicknameModalOpen, setUpdateUserNicknameModalOpen] =
    useState(false)

  const [updateUserNicknameInfo, setUpdateUserNicknameInfo] = useState({
    oldName: '',
    uuid: '',
    roomType: 'room',
  })

  useEffect(() => {
    setMemberList(initMemberList || memberListContext)
  }, [initMemberList, memberListContext])

  useEffect(() => {
    setMeetingInfo(initMeetingInfo || meetingInfoContext)
  }, [initMeetingInfo, meetingInfoContext])

  useEffect(() => {
    setWaitingRoomInfo(initWaitingRoomInfo || waitingRoomInfoContext)
  }, [initWaitingRoomInfo, waitingRoomInfoContext])

  useEffect(() => {
    setWaitingRoomMemberList(
      initWaitingRoomMemberList || waitingRoomMemberListContext
    )
  }, [initWaitingRoomMemberList, waitingRoomMemberListContext])

  useEffect(() => {
    eventEmitter?.on(
      MeetingEventType.changeMemberListTab,
      (tab: 'room' | 'waitingRoom') => {
        if (waitingRoomInfo.memberCount > 0) {
          neMeeting?.updateMeetingInfo({
            activeMemberManageTab: tab,
          })
        } else {
          neMeeting?.updateMeetingInfo({
            activeMemberManageTab: 'room',
          })
        }
      }
    )
    return () => {
      eventEmitter?.off(MeetingEventType.changeMemberListTab)
    }
  }, [waitingRoomInfo.memberCount])

  const { localMember } = meetingInfo

  const [searchName, setSearchName] = useState('')

  const isHostOrCoHost = useMemo(
    () => localMember.role === Role.host || localMember.role === Role.coHost,
    [localMember.role]
  )
  useEffect(() => {
    // 如果是主持人或者联席主持人才有等候室tab
    if (!isHostOrCoHost) {
      neMeeting?.updateMeetingInfo({
        activeMemberManageTab: 'room',
      })
    }
  }, [isHostOrCoHost])
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
    const tempMemberList: NEMember[] = []
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

  function changeTab(tab: 'room' | 'waitingRoom') {
    neMeeting?.updateMeetingInfo({
      activeMemberManageTab: tab,
    })
  }

  useEffect(() => {
    if (!waitingRoomInfo.isEnabledOnEntry || waitingRoomInfo.memberCount == 0) {
      neMeeting?.updateMeetingInfo({
        activeMemberManageTab: 'room',
      })
    }
  }, [waitingRoomInfo.isEnabledOnEntry, waitingRoomInfo.memberCount])
  useEffect(() => {
    if (meetingInfo.activeMemberManageTab === 'waitingRoom') {
      neMeeting?.updateWaitingRoomUnReadCount(0)
    }
  }, [meetingInfo.activeMemberManageTab])
  useEffect(() => {
    if (meetingInfo.activeMemberManageTab === 'waitingRoom') {
      const scrollElement = scrollRef.current
      if (!scrollElement) {
        return
      }
      function handleScroll() {
        console.log('scroll')
        //@ts-ignore
        if (
          scrollElement &&
          scrollElement.scrollTop + scrollElement.clientHeight >=
            scrollElement.scrollHeight
        ) {
          console.log(1, getWaitingRoomMemberRef.current, waitingRoomMemberList)
          if (
            getWaitingRoomMemberRef.current ||
            waitingRoomMemberList.length === 0
          ) {
            return
          }
          console.log(2)
          const lastMember =
            waitingRoomMemberList[waitingRoomMemberList.length - 1]
          if (!lastMember) {
            return
          }
          console.log(3)
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
      scrollRef.current?.addEventListener('scroll', handleScroll)
      return () => {
        scrollRef.current?.removeEventListener('scroll', handleScroll)
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
    ({ index, key, parent, style }) => {
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
    [memberListFilter, meetingInfo]
  )

  const waitingRoomRowRenderer = useCallback(
    ({ index, key, parent, style }) => {
      const member = waitingRoomMemberListFilter[index]
      return (
        <div style={style} key={key}>
          <WaitingRoomMemberItem
            neMeeting={neMeeting}
            meetingInfo={meetingInfo}
            key={member.uuid}
            data={member}
            handleUpdateUserNickname={handleUpdateUserNickname}
          />
        </div>
      )
    },
    [waitingRoomMemberListFilter]
  )

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

      {isHostOrCoHost && waitingRoomInfo.memberCount > 0 && (
        <div className="pd20">
          <div className="nemeeting-member-list-tabs">
            <div
              className={`nemeeting-member-list-tab ${
                meetingInfo.activeMemberManageTab == 'room'
                  ? 'nemeeting-member-list-tab-selected'
                  : ''
              }`}
              onClick={() => changeTab('room')}
            >
              {t('inMeeting')}({memberList.length})
            </div>
            <div
              className={`nemeeting-member-list-tab ${
                meetingInfo.activeMemberManageTab == 'waitingRoom'
                  ? 'nemeeting-member-list-tab-selected'
                  : ''
              }`}
              onClick={() => changeTab('waitingRoom')}
            >
              <span style={{ position: 'relative' }}>
                {t('waitingRoom')}({waitingRoomInfo.memberCount})
                {!!waitingRoomInfo.unReadMsgCount && (
                  <span className="waiting-room-unread-notify"></span>
                )}
              </span>
            </div>
          </div>
        </div>
      )}

      <div className="member-list-content pd20" ref={scrollRef}>
        {meetingInfo.activeMemberManageTab === 'room' && (
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
        {meetingInfo.activeMemberManageTab === 'waitingRoom' && (
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
                  if (updateUserNicknameInfo.uuid === localMember.uuid) {
                    //修改自己昵称 保存昵称，会议逻辑
                    localStorage.setItem(
                      'ne-meeting-nickname-' + localMember.uuid,
                      JSON.stringify({
                        [neMeeting.meetingNum]: values.nickname,
                        [neMeeting.shortMeetingNum]: values.nickname,
                      })
                    )
                  }
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
      {isHostOrCoHost ? (
        <MemberListFooter meetingInfo={meetingInfo} neMeeting={neMeeting} />
      ) : null}
    </div>
  )
}
export default MemberList
