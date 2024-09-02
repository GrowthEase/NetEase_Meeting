import { useCallback, useEffect, useState } from 'react';
import { createMeetingInfoFactory } from '@meeting-module/services';
import {
  Action,
  ActionType,
  Dispatch,
  NEMeetingInfo,
  NEMember,
} from '@meeting-module/types';

type MeetingInfoPageContextValue = {
  meetingInfo: NEMeetingInfo;
  memberList: NEMember[];
  inInvitingMemberList?: NEMember[];
  dispatch: Dispatch;
};

function useMeetingInfoPageContext(): MeetingInfoPageContextValue {
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>(
    createMeetingInfoFactory(),
  );
  const [memberList, setMemberList] = useState<NEMember[]>([]);
  const [inInvitingMemberList, setInInvitingMemberList] =
    useState<NEMember[]>();

  const dispatch = useCallback((payload: Action<ActionType>) => {
    const parentWindow = window.parent;

    parentWindow?.postMessage(
      {
        event: 'meetingInfoDispatch',
        payload: payload,
      },
      parentWindow.origin,
    );
  }, []);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      switch (event) {
        case 'windowOpen':
        case 'updateData':
          console.warn('updateData', payload);
          payload.meetingInfo && setMeetingInfo(payload.meetingInfo);
          payload.memberList && setMemberList(payload.memberList);
          payload.inSipInvitingMemberList &&
            setInInvitingMemberList(payload.inSipInvitingMemberList);
          payload.inInvitingMemberList &&
            setInInvitingMemberList(payload.inInvitingMemberList);
          break;
        default:
          break;
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return { meetingInfo, memberList, inInvitingMemberList, dispatch };
}

export default useMeetingInfoPageContext;
