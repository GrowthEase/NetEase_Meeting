import React, { useEffect, useRef, useState } from 'react';
import { SearchAccountInfo } from '@meeting-module/types';
import { NEMeetingScheduledMember, Role } from '@meeting-module/types/type';
import UserAvatar from '@meeting-module/components/common/Avatar';
import useMembers from './useMembers';
import { Button } from 'antd';
import { LOCALSTORAGE_USER_INFO } from '../../../../config';
import { useTranslation } from 'react-i18next';
import { getLocalUserInfo } from '@meeting-module/utils';
import NEContactsService from '@meeting-module/kit/interface/service/meeting_contacts_service';

interface PreviewMemberListProps {
  members?: NEMeetingScheduledMember[];
  ownerUserUuid?: string;
  myUuid?: string;
  meetingContactsService?: NEContactsService;
}

const pageSize = 10;
const PreviewMemberList: React.FC<PreviewMemberListProps> = ({
  members,
  ownerUserUuid,
  myUuid,
  meetingContactsService,
}) => {
  const { t } = useTranslation();
  const [selectedMembers, setSelectedMembers] = useState<SearchAccountInfo[]>(
    [],
  );
  const [isOpen, setIsOpen] = useState(false);
  const { getAccountInfoListByPage, sortMembers, getDefaultMembers } =
    useMembers({ meetingContactsService });

  const scrollRef = useRef<HTMLDivElement>(null);
  const getMembersRef = useRef(false);
  const currentPageRef = useRef(1);

  useEffect(() => {
    currentPageRef.current = 1;
    if (members && members.length > 0) {
      getAccountInfoListByPage(1, pageSize, members).then((res) => {
        const userString = localStorage.getItem(LOCALSTORAGE_USER_INFO);

        if (userString) {
          const user = JSON.parse(userString);
          const membersBySort = sortMembers(res, user.userUuid || '');

          setSelectedMembers(membersBySort);
        }
      });
    } else {
      const userInfo = getLocalUserInfo();

      userInfo && setSelectedMembers(getDefaultMembers(userInfo));
    }
  }, [members]);

  const getMemberRole = (role?: Role) => {
    const roleMap = {
      host: t('host'),
      cohost: t('coHost'),
    };

    return role ? roleMap[role] : '';
  };

  const onOpenHandler = () => {
    setIsOpen(!isOpen);
  };

  useEffect(() => {
    const scrollElement = scrollRef.current;

    if (!scrollElement) {
      return;
    }

    function handleScroll() {
      if (
        scrollElement &&
        scrollElement.scrollTop + scrollElement.clientHeight >=
          scrollElement.scrollHeight
      ) {
        if (getMembersRef.current) {
          return;
        }

        getMembersRef.current = true;
        getAccountInfoListByPage(currentPageRef.current + 1, pageSize, members)
          .then((data) => {
            setSelectedMembers([...selectedMembers, ...data]);
            currentPageRef.current += 1;
          })
          .finally(() => {
            getMembersRef.current = false;
          });
      }
    }

    if (isOpen) {
      scrollElement.addEventListener('scroll', handleScroll);
      return () => {
        scrollElement.removeEventListener('scroll', handleScroll);
      };
    }
  }, [selectedMembers, isOpen]);

  return (
    <div className="nemeeting-schedule-participant-preview">
      <div className="nemeeting-schedule-participant-preview-header">
        <div className="nemeeting-schedule-participant-meeting-attendees">
          <span>{t('meetingAttendees')}</span>
        </div>
        <div>
          <span className="nemeeting-schedule-participant-preview-count">
            {t('meetingAttendeeCount', {
              count: members?.length || 1,
            })}
          </span>
          <Button style={{ padding: '0' }} type="link" onClick={onOpenHandler}>
            {isOpen ? t('meetingClose') : t('meetingOpen')}
          </Button>
        </div>
      </div>
      {isOpen ? (
        <div
          className="nemeeting-schedule-participant-preview-content-h"
          ref={scrollRef}
        >
          {selectedMembers.map((item) => {
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
            );
          })}
        </div>
      ) : (
        <div className="nemeeting-schedule-participant-preview-content">
          {
            // 获取selectedMembers前面7个进展展示
            selectedMembers.slice(0, 8).map((item) => {
              return (
                <PreviewMemberItem
                  key={item.userUuid}
                  member={item}
                  ownerUserUuid={ownerUserUuid || ''}
                />
              );
            })
          }
        </div>
      )}
    </div>
  );
};

interface PreviewMemberItemProps {
  member: SearchAccountInfo;
  ownerUserUuid: string;
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
  );
};

export default PreviewMemberList;
