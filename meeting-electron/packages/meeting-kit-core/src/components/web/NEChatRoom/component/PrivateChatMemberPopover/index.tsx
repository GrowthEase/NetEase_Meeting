import React, { useEffect, useMemo, useState } from 'react'
import { Input, Popover, Tabs } from 'antd'
import { useTranslation } from 'react-i18next'
import { useMeetingInfoContext } from '../../../../../store'
import './index.less'
import MyIcon from '../Icon'
import { Role, UserAvatar } from '../../../../../kit'
import {
  useChatRoomContext,
  ChatRoomMember,
} from '../../../../../hooks/useChatRoom'
import { useUpdateEffect } from 'ahooks'

type PrivateChatMemberPopoverProps = {
  renderPrivateChatMember: (
    privateChatMemberId: string,
    privateChatMember?: ChatRoomMember
  ) => React.ReactNode | undefined
  getPopupContainer?: (triggerNode: HTMLElement) => HTMLElement
  onOpenChange?: (open: boolean) => void
  onPrivateChatMemberSelected?: (privateChatMemberId: string) => void
}

const PrivateChatMemberPopover: React.FC<PrivateChatMemberPopoverProps> = (
  props
) => {
  const { renderPrivateChatMember } = props

  const { t } = useTranslation()
  const { meetingInfo } = useMeetingInfoContext()
  const {
    disabled,
    chatRoomMemberList,
    chatWaitingRoomMemberList,
    onPrivateChatMemberSelected,
    privateChatMemberId,
  } = useChatRoomContext()

  const {
    localMember,
    meetingChatPermission,
    waitingRoomChatPermission,
    inWaitingRoom,
  } = meetingInfo

  const isHostOrCohost =
    localMember.role === Role.host || localMember.role === Role.coHost

  const onlyHostOrCohost =
    (!isHostOrCohost && meetingChatPermission === 3) ||
    (inWaitingRoom && waitingRoomChatPermission === 1)

  const onlyPublic = !isHostOrCohost && meetingChatPermission === 2

  const [privateChatTab, setPrivateChatTab] = useState('meeting')
  const [privateChatSearchName, setPrivateChatSearchName] = useState('')
  const [privateChatMemberPopoverOpen, setPrivateChatMemberPopoverOpen] =
    useState(false)
  const [privateChatMember, setPrivateChatMember] = useState<ChatRoomMember>()

  const searchInputPlaceholder = t('participantSearchMember')
  const tabItems = [
    { key: 'meeting', label: t('inMeeting') },
    { key: 'waitingRoom', label: t('waitingRoom') },
  ]
  const filterMembers = useMemo(() => {
    let filterMembers = chatRoomMemberList

    if (
      privateChatTab === 'waitingRoom' &&
      chatWaitingRoomMemberList.length > 0
    ) {
      filterMembers = chatWaitingRoomMemberList
    }

    return filterMembers.filter((item) =>
      item.nick.includes(privateChatSearchName)
    )
  }, [
    chatRoomMemberList,
    chatWaitingRoomMemberList,
    privateChatTab,
    privateChatSearchName,
  ])

  function renderRoleText(role?: Role) {
    switch (role) {
      case 'host':
        return (
          <div className="private-chat-member-role">{`(${t('host')})`}</div>
        )
      case 'cohost':
        return (
          <div className="private-chat-member-role">{`(${t('coHost')})`}</div>
        )
      default:
        return null
    }
  }

  function renderContent() {
    return (
      <div className="private-chat-member-content">
        <div className="private-chat-member-header">
          <Input
            placeholder={searchInputPlaceholder}
            className="private-chat-member-search-input"
            allowClear
            prefix={
              <MyIcon
                type="iconsearch2-line1x"
                color="#666"
                width="14"
                height="14"
              />
            }
            onChange={(e) => setPrivateChatSearchName(e.target.value)}
          />
          {chatWaitingRoomMemberList.length > 0 && (
            <Tabs
              activeKey={privateChatTab}
              centered
              items={tabItems}
              onChange={(key) => setPrivateChatTab(key)}
            />
          )}
          <div className="private-chat-member-list">
            {onlyHostOrCohost && !privateChatSearchName && !inWaitingRoom ? (
              <div className="private-chat-member-tips">
                {t('chatPrivateHostOnly')}
              </div>
            ) : null}
            {onlyPublic && !privateChatSearchName && !inWaitingRoom ? (
              <div className="private-chat-member-tips">
                {t('chatPublicOnly')}
              </div>
            ) : null}
            {privateChatSearchName && filterMembers.length === 0 ? (
              <div
                className="private-chat-member-tips"
                style={{ textAlign: 'center' }}
              >
                {t('participantNotFound')}
              </div>
            ) : null}
            {onlyHostOrCohost || privateChatSearchName ? null : (
              <div
                className="private-chat-member-item"
                onClick={() => {
                  const id =
                    privateChatTab === 'waitingRoom' &&
                    chatWaitingRoomMemberList.length > 0
                      ? 'waitingRoomAll'
                      : 'meetingAll'

                  onPrivateChatMemberSelected(id)
                  props.onPrivateChatMemberSelected?.(id)
                  setPrivateChatMemberPopoverOpen(false)
                }}
              >
                <MyIcon
                  type="iconsuoyouren-24px"
                  height={24}
                  width={24}
                  color="rgba(101, 106, 114, 1)"
                />
                <div className="private-chat-member-name">
                  {t('chatAllMembers')}
                </div>
                {privateChatTab === 'meeting' &&
                  privateChatMemberId === 'meetingAll' && (
                    <MyIcon
                      type="iconcheck-line-regular1x"
                      height={14}
                      width={14}
                      color="#337EFF"
                    />
                  )}
                {privateChatTab === 'waitingRoom' &&
                  privateChatMemberId === 'waitingRoomAll' && (
                    <MyIcon
                      type="iconcheck-line-regular1x"
                      height={14}
                      width={14}
                      color="#337EFF"
                    />
                  )}
              </div>
            )}
            {filterMembers.map((item) => (
              <div
                className="private-chat-member-item"
                key={item.account}
                onClick={() => {
                  onPrivateChatMemberSelected(item.account)
                  props.onPrivateChatMemberSelected?.(item.account)
                  // React.18 导致问题，需要延迟关闭
                  setTimeout(() => {
                    setPrivateChatMemberPopoverOpen(false)
                  })
                }}
              >
                <UserAvatar
                  size={22}
                  nickname={item.nick}
                  avatar={item.avatar}
                />
                <div className="private-chat-member-name">
                  <div className="private-chat-member-name-text">
                    {item.nick}
                  </div>
                  {renderRoleText(item.role)}
                </div>
                {privateChatMemberId === item.account ? (
                  <MyIcon
                    type="iconcheck-line-regular1x"
                    height={14}
                    width={14}
                    color="#337EFF"
                  />
                ) : (
                  <div />
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  useEffect(() => {
    let privateChatMember = chatRoomMemberList.find(
      (item) => item.account === privateChatMemberId
    )

    if (!privateChatMember) {
      privateChatMember = chatWaitingRoomMemberList.find(
        (item) => item.account === privateChatMemberId
      )
    }

    // 选中的人不在列表中
    if (!privateChatMember) {
      // 如果是主持人或者联席主持人
      if (isHostOrCohost) {
        // 如果选中的是等候室所有人
        if (
          privateChatMemberId === 'waitingRoomAll' &&
          chatWaitingRoomMemberList.length > 0
        ) {
          // do nothing
        } else {
          onPrivateChatMemberSelected?.('meetingAll', true)
        }
      } else {
        // 只可以私聊主持人&&联席主持人
        if (onlyHostOrCohost) {
          // 列表中有人
          if (filterMembers.length > 0) {
            privateChatMember = filterMembers[0]
            onPrivateChatMemberSelected?.(filterMembers[0].account, true)
          }
          // 列表中没有人
        } else {
          onPrivateChatMemberSelected?.('meetingAll', true)
        }
      }
    }

    setPrivateChatMember(privateChatMember)
  }, [
    privateChatMemberId,
    isHostOrCohost,
    chatRoomMemberList,
    chatWaitingRoomMemberList,
    onlyHostOrCohost,
    onlyPublic,
  ])

  useUpdateEffect(() => {
    if (disabled !== 0) {
      setPrivateChatMemberPopoverOpen(false)
    }
  }, [disabled])

  return (
    <Popover
      trigger={['click']}
      placement="top"
      overlayClassName="nemeeting-private-chat-member-popover"
      content={renderContent()}
      arrow={false}
      open={privateChatMemberPopoverOpen}
      onOpenChange={(open) => {
        setPrivateChatMemberPopoverOpen(open)
        props.onOpenChange?.(open)
      }}
      getPopupContainer={props.getPopupContainer}
    >
      {renderPrivateChatMember(privateChatMemberId, privateChatMember)}
    </Popover>
  )
}

export default PrivateChatMemberPopover
