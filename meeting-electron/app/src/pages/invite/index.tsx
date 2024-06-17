import { EventEmitter } from 'eventemitter3';
import { useTranslation } from 'react-i18next';

import { InviteContent } from '../../../../src/components/web/InviteModal';
import useUserInfo from '../../../../src/hooks/useUserInfo';
import { useGlobalContext, useMeetingInfoContext } from '../../../../src/store';

import './index.less';
import React, { useEffect } from 'react';

const eventEmitter = new EventEmitter();

const InvitePage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeeting } = useGlobalContext();
  const { meetingInfo, memberList, inInvitingMemberList, dispatch } =
    useMeetingInfoContext();
  const { userInfo } = useUserInfo();

  useEffect(() => {
    setTimeout(() => {
      document.title = t('inviteBtn');
    });
  }, [t]);

  return (
    <div className="invite-page">
      {neMeeting && (
        <InviteContent
          meetingInfo={meetingInfo}
          neMeeting={neMeeting}
          inSipInvitingMemberList={inInvitingMemberList}
          memberList={memberList}
          myUuid={userInfo?.userUuid || ''}
          meetingInfoDispatch={dispatch}
          onCancel={() => window.close()}
          eventEmitter={eventEmitter}
        />
      )}
    </div>
  );
};

export default InvitePage;
