import React, { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import useUserInfo from '@meeting-module/hooks/useUserInfo';
import { Button } from 'antd';

import './index.less';
import AddressBook from '@meeting-module/components/common/AddressBook';
import { Role, SearchAccountInfo } from '@meeting-module/types';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import { useGlobalContext } from '@meeting-module/store';
import Modal from '@meeting-module/components/common/Modal';
import useNEMeetingKitContextPageContext from '@/hooks/useNEMeetingKitContextPageContext';
import Toast from '@meeting-module/components/common/toast';

export default function AddressBookPage() {
  const { t } = useTranslation();
  const { neMeetingKit } = useNEMeetingKitContextPageContext();

  const { userInfo } = useUserInfo();

  const { globalConfig } = useGlobalContext();
  const [selectedMembers, setSelectedMembers] = useState<SearchAccountInfo[]>(
    [],
  );

  const scheduleMemberConfig = useMemo(() => {
    return globalConfig?.appConfig.MEETING_SCHEDULED_MEMBER_CONFIG;
  }, [globalConfig?.appConfig.MEETING_SCHEDULED_MEMBER_CONFIG]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'updateData') {
        const { selectedMembers } = payload;

        setSelectedMembers(selectedMembers);
      } else if (event === 'showConfirmDeleteInterpreter') {
        console.log('confirmDeleteInterpreter', payload);
        Modal.confirm({
          title: t('commonTitle'),
          content: t('interpRemoveMemberInInterpreters'),
          cancelText: t('globalCancel'),
          okText: t('globalDelete'),
          onOk: () => {
            const parentWindow = window.parent;

            parentWindow.postMessage(
              {
                event: 'onDeleteInterpreterAndAddressBookMember',
                payload: {
                  userUuid: payload.userUuid,
                },
              },
              parentWindow.origin,
            );
          },
        });
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  const onCancelHandler = () => {
    const parentWindow = window.parent;

    parentWindow.postMessage(
      {
        event: 'onAddressBookCancelHandler',
      },
      parentWindow.origin,
    );
    window.close();
  };

  const onConfirmHandler = () => {
    const parentWindow = window.parent;

    parentWindow.postMessage(
      {
        event: 'onAddressBookConfirmHandler',
      },
      parentWindow.origin,
    );
    window.close();
  };

  const onMembersChangeHandler = (
    member: SearchAccountInfo,
    isChecked: boolean,
  ) => {
    const maxCount = Number(scheduleMemberConfig?.max) || 5000;

    if (isChecked && selectedMembers.length >= maxCount) {
      Toast.fail(
        t('sipCallMaxCount', {
          count: maxCount,
        }),
      );
      return;
    }

    const parentWindow = window.parent;

    parentWindow.postMessage(
      {
        event: 'onMembersChangeHandler',
        payload: {
          member,
          isChecked,
        },
      },
      parentWindow.origin,
    );
  };

  const onRoleChange = (uuid: string, role?: Role) => {
    const parentWindow = window.parent;

    parentWindow.postMessage(
      {
        event: 'onRoleChange',
        payload: {
          uuid,
          role,
        },
      },
      parentWindow.origin,
    );
  };

  return (
    <div className="addressBook-page">
      <div className="electron-drag-bar">
        <div className="drag-region" />
        <span
          className="meeting-attendees"
          style={{
            fontWeight: 'bold',
          }}
        >
          {t('meetingAttendees')}
        </span>
        <PCTopButtons size="normal" minimizable={false} maximizable={false} />
      </div>
      {neMeetingKit && (
        <div>
          <div className="address-book-wrap">
            <AddressBook
              sortByRole
              selectedMembers={selectedMembers}
              maxCount={scheduleMemberConfig?.max}
              maxCoHostCount={scheduleMemberConfig?.coHostLimit}
              myUuid={userInfo?.userUuid || ''}
              onChange={onMembersChangeHandler}
              onRoleChange={onRoleChange}
              meetingContactsService={neMeetingKit.getContactsService()}
              showMore={true}
            />
          </div>

          <div className="nemeeting-address-confirm-wrapper">
            <Button
              className="nemeeting-address-confirm-cancel"
              style={{
                width: '128px',
                fontSize: '16px',
                color: '#4096ff',
                borderColor: '#4096ff',
                background: '#ffffff',
                borderRadius: '4px',
              }}
              shape="round"
              size="large"
              onClick={onCancelHandler}
            >
              {t('globalCancel')}
            </Button>
            <Button
              style={{ width: '128px', fontSize: '16px', borderRadius: '4px' }}
              type="primary"
              shape="round"
              size="large"
              disabled={selectedMembers.length === 0}
              onClick={onConfirmHandler}
            >
              {t('globalSure')}
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
