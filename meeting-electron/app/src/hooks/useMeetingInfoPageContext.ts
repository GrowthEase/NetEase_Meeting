import { useEffect, useState } from 'react';
import { createMeetingInfoFactory } from '../../../src/services';
import { NEMeetingInfo, NEMember } from '../../../src/types';

type MeetingInfoPageContextValue = {
  meetingInfo: NEMeetingInfo;
  memberList: NEMember[];
  inInvitingMemberList?: NEMember[];
  dispatch: React.Dispatch<any>;
};

function useMeetingInfoPageContext(): MeetingInfoPageContextValue {
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>(
    createMeetingInfoFactory(),
  );
  const [memberList, setMemberList] = useState<NEMember[]>([]);
  const [inInvitingMemberList, setInInvitingMemberList] = useState<
    NEMember[]
  >();

  function dispatch(payload: any) {
    const parentWindow = window.parent;
    parentWindow?.postMessage(
      {
        event: 'meetingInfoDispatch',
        payload: payload,
      },
      parentWindow.origin,
    );
  }

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      switch (event) {
        case 'windowOpen':
        case 'updateData':
          payload.meetingInfo && setMeetingInfo(payload.meetingInfo);
          payload.memberList && setMemberList(payload.memberList);
          payload.inSipInvitingMemberList &&
            setInInvitingMemberList(payload.inSipInvitingMemberList);
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
