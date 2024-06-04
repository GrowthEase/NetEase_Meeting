import { useEffect, useRef, useState } from 'react'
import { SearchAccountInfo } from '../../../../types'
import { NEMeetingScheduledMember, Role } from '../../../../types/type'
import UserAvatar from '../../../common/Avatar'
import useMembers from './useMembers'
import { Button } from 'antd'
import useUserInfo from '../../../../hooks/useUserInfo'
import { LOCALSTORAGE_USER_INFO } from '../../../../config'
import { useTranslation } from 'react-i18next'
import NEMeetingService from '../../../../services/NEMeeting'
import { LoginUserInfo } from '../../../../../app/src/types'
import { getLocalUserInfo } from '../../../../utils'
import { getDefaultConfig } from 'antd-mobile/es/components/config-provider'

interface PreviewMemberListProps {
  members?: NEMeetingScheduledMember[]
  neMeeting?: NEMeetingService
  ownerUserUuid?: string
  myUuid?: string
}

const pageSize = 10
const PreviewMemberList: React.FC<PreviewMemberListProps> = ({
  members,
  neMeeting,
  ownerUserUuid,
  myUuid,
}) => {
  const { t } = useTranslation()
  const [selectedMembers, setSelectedMembers] = useState<SearchAccountInfo[]>(
    []
  )
  const [isOpen, setIsOpen] = useState(false)
  const { getAccountInfoListByPage, sortMembers, getDefaultMembers } =
    useMembers({ neMeeting })

  const scrollRef = useRef<HTMLDivElement>(null)
  const getMembersRef = useRef(false)
  const currentPageRef = useRef(1)

  useEffect(() => {
    currentPageRef.current = 1
    if (members && members.length > 0) {
      getAccountInfoListByPage(1, pageSize, members).then((res) => {
        const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO)
        if (userString) {
          const user = JSON.parse(userString)
          const membersBySort = sortMembers(res, user.userUuid || '')
          setSelectedMembers(membersBySort)
        }
      })
    } else {
      const userInfo = getLocalUserInfo()
      userInfo && setSelectedMembers(getDefaultMembers(userInfo))
    }
  }, [members])

  const getMemberRole = (role?: Role) => {
    const roleMap = {
      host: t('host'),
      cohost: t('coHost'),
    }
    return role ? roleMap[role] : ''
  }

  const onOpenHandler = () => {
    setIsOpen(!isOpen)
  }

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
        if (getMembersRef.current) {
          return
        }

        getMembersRef.current = true
        getAccountInfoListByPage(currentPageRef.current + 1, pageSize, members)
          .then((data) => {
            setSelectedMembers([...selectedMembers, ...data])
            currentPageRef.current += 1
          })
          .finally(() => {
            getMembersRef.current = false
          })
      }
    }
    if (isOpen) {
      scrollRef.current?.addEventListener('scroll', handleScroll)
      return () => {
        scrollRef.current?.removeEventListener('scroll', handleScroll)
      }
    }
  }, [selectedMembers, isOpen])

  return (
    <div className="nemeeting-schedule-participant-preview">
      <div className="nemeeting-schedule-participant-preview-header">
        <div>
          <span>{t('meetingAttendees')}</span>
          <span className="nemeeting-schedule-participant-preview-count">
            {t('meetingAttendeeCount', {
              count: members?.length,
            })}
          </span>
        </div>
        <Button type="link" onClick={onOpenHandler}>
          {isOpen ? t('meetingClose') : t('meetingOpen')}
        </Button>
      </div>
      {isOpen ? (
        <div
          className="nemeeting-schedule-participant-preview-content-h"
          ref={scrollRef}
        >
          {selectedMembers.map((item, index) => {
            return (
              <div
                className="nemeeting-schedule-participant-preview-member"
                key={item.userUuid}
              >
                <div style={{ position: 'relative' }}>
                  <UserAvatar
                    nickname={item.name}
                    avatar={item.avatar}
                    size={32}
                  />
                  {item.userUuid == ownerUserUuid && (
                    <svg
                      className="icon iconfont nemeeting-schedule-mySelf-icon"
                      aria-hidden="true"
                    >
                      <use xlinkHref="#iconsetting-account-selected"></use>
                    </svg>
                  )}
                </div>
                <div className="nemeeting-schedule-participant-preview-info">
                  <span className="nemeeting-schedule-participant-preview-name">
                    {item.name}
                  </span>
                  <span className="nemeeting-schedule-participant-preview-dept">
                    {getMemberRole(item.role)}
                    {`${
                      item.userUuid === myUuid
                        ? (getMemberRole(item.role) ? '、' : '') +
                          t('participantMe')
                        : ''
                    }`}
                  </span>
                </div>
              </div>
            )
          })}
        </div>
      ) : (
        <div className="nemeeting-schedule-participant-preview-content">
          {
            // 获取selectedMembers前面7个进展展示
            selectedMembers.slice(0, 8).map((item, index) => {
              return (
                <PreviewMemberItem
                  key={item.userUuid}
                  member={item}
                  ownerUserUuid={ownerUserUuid || ''}
                />
              )
            })
          }
        </div>
      )}
    </div>
  )
}
interface PreviewMemberItemProps {
  member: SearchAccountInfo
  ownerUserUuid: string
}
export const PreviewMemberItem: React.FC<PreviewMemberItemProps> = ({
  member,
  ownerUserUuid,
}) => {
  return (
    <div className="nemeeting-schedule-member-item" key={member.userUuid}>
      <UserAvatar nickname={member.name} avatar={member.avatar} size={32} />
      {member.userUuid === ownerUserUuid && (
        <svg
          className="icon iconfont nemeeting-schedule-mySelf-icon"
          aria-hidden="true"
        >
          <use xlinkHref="#iconsetting-account-selected"></use>
        </svg>
      )}
    </div>
  )
}

export default PreviewMemberList
