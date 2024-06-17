import { NEWaitingRoomMember } from 'neroom-web-sdk/dist/types/types/interface';
import { useCallback, useEffect, useState } from 'react';

type WaitingRoomPageContextValue = {
  waitingRoomInfo: {
    memberCount: number;
    isEnabledOnEntry: boolean;
    unReadMsgCount?: number;
    backgroundImageUrl?: string;
  };
  memberList: NEWaitingRoomMember[];
  dispatch: React.Dispatch<any>;
};

function useWaitingRoomPageContext(): WaitingRoomPageContextValue {
  const [waitingRoomInfo, setWaitingRoomInfo] = useState({
    memberCount: 0,
    isEnabledOnEntry: false,
    unReadMsgCount: 0,
  });
  const [memberList, setMemberList] = useState([]);

  const dispatch = useCallback(() => {
    return (payload: any) => {
      const parentWindow = window.parent;

      parentWindow?.postMessage(
        {
          event: 'waitingRoomInfoDispatch',
          payload: payload,
        },
        parentWindow.origin,
      );
    };
  }, []);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      switch (event) {
        case 'windowOpen':
        case 'updateData':
          payload.waitingRoomInfo &&
            setWaitingRoomInfo(payload.waitingRoomInfo);
          payload.waitingRoomMemberList &&
            setMemberList(payload.waitingRoomMemberList);
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

  return { waitingRoomInfo, memberList, dispatch };
}

export default useWaitingRoomPageContext;
