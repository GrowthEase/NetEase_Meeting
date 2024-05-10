import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { NEMember, Role, SearchAccountInfo } from '../../../types'
import { Checkbox, Dropdown, Input } from 'antd'
import type { MenuProps } from 'antd'
import { SearchOutlined } from '@ant-design/icons'
import EmptyImg from '../../../assets/empty-SIPCall.png'
import UserAvatar from '../../common/Avatar'
import { debounce } from '../../../utils'
import './index.less'
import Toast from '../../common/toast'
import NEMeetingService from '../../../services/NEMeeting'

interface SIPBatchCallProps {
  className?: string
  myUuid: string
  neMeeting?: NEMeetingService
  maxCount?: number
  maxCoHostCount?: number
  onChange?: (member: SearchAccountInfo, isChecked: boolean) => void
  onRoleChange?: (uuid: string, role?: Role) => void
  showMore?: boolean
  localMember?: SearchAccountInfo
  selectedMembers: SearchAccountInfo[]
  ownerUserUuid?: string
  sortByRole?: boolean
}
interface ConnectMemberListProps {
  className?: string
  options: SearchAccountInfo[]
  onChange: (member: SearchAccountInfo, isChecked: boolean) => void
  value: string[]
  myUuid: string
  showMore?: boolean
}
interface ConnectMemberItemProps {
  className?: string
  onDelete?: (uuid: string) => void
  member: SearchAccountInfo
  shoClose?: boolean
  showMore?: boolean
  onRoleChange?: (uuid: string, role: Role) => void
  myUuid: string
  ownerUserUuid?: string
}

const ConnectMemberItem: React.FC<ConnectMemberItemProps> = ({
  member,
  shoClose,
  showMore,
  onDelete,
  onRoleChange,
  myUuid,
  ownerUserUuid,
}) => {
  const { t } = useTranslation()
  const allItems = [
    {
      key: Role.host,
      label: t('participantSetHost'),
      isShow: member.role !== 'host',
    },
    {
      key: Role.coHost,
      label: t('participantSetCoHost'),
      isShow: member.role !== 'cohost',
    },
    {
      key: Role.member,
      label: t('participantCancelCoHost'),
      isShow: member.role === 'cohost',
    },
  ]
  const items = allItems
    .filter((item) => item.isShow)
    .map((item) => {
      return {
        key: item.key,
        label: item.label,
      }
    }) // 去除isShow字段否则dom有警告或者是小写isshow
  const onMenuClick: MenuProps['onClick'] = ({ key }) => {
    if (!onRoleChange) return
    onRoleChange(member.userUuid, key as Role)
  }
  const memberRole = useMemo(() => {
    const roleMap = {
      host: t('host'),
      cohost: t('coHost'),
    }
    return member.role ? roleMap[member.role] : ''
  }, [member.role])

  const isMySelf = useMemo(() => {
    return member.userUuid === myUuid
  }, [member.userUuid])

  return (
    <div className="nemeeting-connect-member-item">
      <div className="nemeeting-connect-member-item-avatar">
        <div style={{ position: 'relative' }}>
          <UserAvatar nickname={member.name} size={32} avatar={member.avatar} />
          {member.userUuid === ownerUserUuid && (
            <svg
              className="icon iconfont nemeeting-schedule-mySelf-icon"
              aria-hidden="true"
            >
              <use xlinkHref="#iconsetting-account-selected"></use>
            </svg>
          )}
        </div>
        <div className="nemeeting-connect-member-item-title">
          <div className="nemeeting-connect-member-item-name">
            {member.name}
          </div>
          {showMore
            ? memberRole && (
                <div
                  className="nemeeting-connect-member-item-title-tip"
                  title={memberRole}
                >
                  {memberRole}
                </div>
              )
            : member.dept && (
                <div
                  className="nemeeting-connect-member-item-title-tip"
                  title={member.dept}
                >
                  {member.dept}
                </div>
              )}
        </div>
      </div>
      {showMore && (
        <Dropdown
          menu={{ items, onClick: onMenuClick }}
          trigger={['hover']}
          placement="bottomRight"
        >
          <div className="nemeeting-address-book-more">{t('moreBtn')}</div>
        </Dropdown>
      )}
      {shoClose && !isMySelf && (
        <svg
          className="icon iconfont nemeeting-connect-member-item-close"
          aria-hidden="true"
          onClick={() => {
            console.log('onDelete', member)
            onDelete?.(member.userUuid)
          }}
        >
          <use xlinkHref="#iconguanbi"></use>
        </svg>
      )}
    </div>
  )
}
interface ConnectMemberListSelectedProps {
  className?: string
  options: SearchAccountInfo[]
  onDelete: (uuid: string) => void
  onRoleChange?: (uuid: string, role: Role) => void
  showMore?: boolean
  myUuid: string
  ownerUserUuid?: string
}
const ConnectMemberListSelected: React.FC<ConnectMemberListSelectedProps> = ({
  options,
  onDelete,
  onRoleChange,
  showMore,
  myUuid,
  ownerUserUuid,
}) => {
  return (
    <div>
      {options.map((item) => {
        return (
          <ConnectMemberItem
            ownerUserUuid={ownerUserUuid}
            myUuid={myUuid}
            showMore={showMore}
            shoClose={true}
            key={item.userUuid}
            member={item}
            onDelete={onDelete}
            onRoleChange={onRoleChange}
          />
        )
      })}
    </div>
  )
}

// 通讯录成员列表
const ConnectMemberList: React.FC<ConnectMemberListProps> = ({
  className,
  onChange,
  myUuid,
  options,
  value,
  showMore,
}) => {
  const { t } = useTranslation()
  const onCheckChange = (member: SearchAccountInfo, isChecked: boolean) => {
    onChange?.(member, isChecked)
  }
  return options.length > 0 ? (
    <>
      {options.map((item) => {
        return (
          <Checkbox
            key={item.userUuid}
            disabled={item.userUuid == myUuid || item.disabled}
            onChange={(e) => onCheckChange(item, e.target.checked)}
            checked={value.includes(item.userUuid)}
          >
            <ConnectMemberItem member={item} myUuid={myUuid} />
          </Checkbox>
        )
      })}
    </>
  ) : (
    <div className="nemeeting-connect-member-list-empty">
      <img
        className="nemeeting-connect-member-empty-img"
        src={EmptyImg}
        alt={t('sipSearchContacts')}
      />
      <div>{t('sipSearchContacts')}</div>
    </div>
  )
}

const paeSize = 20
// 通讯录组件
const AddressBook: React.FC<SIPBatchCallProps> = ({
  className,
  maxCount,
  maxCoHostCount,
  myUuid,
  neMeeting,
  onChange,
  onRoleChange,
  showMore,
  selectedMembers,
  ownerUserUuid,
}) => {
  const { t } = useTranslation()
  const [connectMembers, setConnectMembers] = useState<SearchAccountInfo[]>([])
  const searchNameRef = useRef('')

  const scrollRef = useRef<HTMLDivElement>(null)
  const getConnectMemberRef = useRef(false)
  const currentPageRef = useRef(1)

  const selectedMemberUuids = useMemo(() => {
    return selectedMembers.map((item) => item.userUuid)
  }, [selectedMembers])
  // 通讯录选中变更
  const onConnectMembersChange = (member: SearchAccountInfo, isChecked) => {
    onChange?.(member, isChecked)
  }
  const onRoleChangeHandler = (uuid: string, role: Role) => {
    // 如果是联席主持人，不能超过4个
    if (
      role === Role.coHost &&
      selectedMembers.filter((item) => item.role === Role.coHost).length >=
        Number(maxCoHostCount)
    ) {
      Toast.fail(t('participantOverRoleLimitCount'))
      return
    }
    onRoleChange?.(uuid, role)
  }
  const onNameChange = (name: string) => {
    searchNameRef.current = name
    currentPageRef.current = 1
    searchName(name, 1)
  }
  const searchName = debounce((name: string, page: number) => {
    if (!name) {
      setConnectMembers([])
      return
    }
    neMeeting
      ?.searchAccount({
        name,
        pageSize: paeSize,
        pageNum: page,
      })
      .then((data) => {
        setConnectMembers(data)
      })
  }, 800)

  useEffect(() => {
    const scrollElement = scrollRef.current
    if (!scrollElement) {
      return
    }
    function handleScroll() {
      //@ts-ignore
      if (
        scrollElement &&
        scrollElement.scrollTop + scrollElement.clientHeight >=
          scrollElement.scrollHeight
      ) {
        if (getConnectMemberRef.current) {
          return
        }

        getConnectMemberRef.current = true
        if (searchNameRef.current === '') {
          return
        }
        neMeeting
          ?.searchAccount({
            name: searchNameRef.current,
            pageSize: paeSize,
            pageNum: currentPageRef.current + 1,
          })
          .then((data) => {
            setConnectMembers([...connectMembers, ...data])
            currentPageRef.current += 1
          })
          .finally(() => {
            getConnectMemberRef.current = false
          })
      }
    }
    scrollRef.current?.addEventListener('scroll', handleScroll)
    return () => {
      scrollRef.current?.removeEventListener('scroll', handleScroll)
    }
  }, [connectMembers])
  // @ts-ignore
  return (
    <div className={`nemeeting-address-book ${className || ''}`}>
      {/*左侧数据*/}
      <div className={'nemeeting-batch-left'}>
        <div style={{ paddingLeft: '24px', paddingRight: '16px' }}>
          <Input
            allowClear
            onChange={(e) => onNameChange(e.target.value)}
            prefix={<SearchOutlined style={{ color: '#B3B7BC' }} />}
            placeholder={t('sipSearch')}
          />
        </div>
        <div className={'nemeeting-batch-left-list'} ref={scrollRef}>
          <ConnectMemberList
            showMore={showMore}
            myUuid={myUuid}
            className={'nemeeting-connect-member-list-check'}
            onChange={onConnectMembersChange}
            options={connectMembers}
            value={selectedMemberUuids}
          />
        </div>
      </div>
      {/*右侧已选成员*/}
      <div className={'nemeeting-batch-right'}>
        <div className="nemeeting-batch-selected-count">
          {t('sipCallMemberSelected', {
            selectedCount: `${selectedMembers.length}/${maxCount || ''}`,
          })}
        </div>
        <div className={'nemeeting-batch-left-list'}>
          <ConnectMemberListSelected
            ownerUserUuid={ownerUserUuid}
            myUuid={myUuid}
            showMore={showMore}
            options={selectedMembers}
            onRoleChange={onRoleChangeHandler}
            onDelete={(uuid) => {
              // 删除selectedMembers中对应的成员
              const member = selectedMembers.find(
                (item) => item.userUuid === uuid
              )
              member && onChange?.(member, false)
            }}
          />
        </div>
      </div>
    </div>
  )
}

export default AddressBook
