import { EventEmitter } from 'eventemitter3';
import { useCallback, useEffect } from 'react';
import { useTranslation } from 'react-i18next';

import { InviteContent } from '../../../../src/components/web/InviteModal';
import useUserInfo from '../../../../src/hooks/useUserInfo';
import {
  useGlobalContext,
  useMeetingInfoContext,
  useWaitingRoomContext,
} from '../../../../src/store';
import { ActionType } from '../../../../src/types';

import './index.less';

const eventEmitter = new EventEmitter();

const InvitePage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeeting } = useGlobalContext();
  const {
    meetingInfo,
    memberList,
    inInvitingMemberList,
    dispatch,
  } = useMeetingInfoContext();
  const { userInfo } = useUserInfo();

  /*
  const dispatch = useCallback((payload: any) => {
    const parentWindow = window.parent;
    if (payload.type === ActionType.UPDATE_MEETING_INFO) {
      parentWindow?.postMessage(
        {
          event: 'openControllerBarWindow',
          payload: 'memberList',
        },
        parentWindow.origin,
      );
    } else {
      parentWindow?.postMessage(
        {
          event: 'meetingInfoDispatch',
          payload: payload,
        },
        parentWindow.origin,
      );
    }
  }, []);
  */

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
