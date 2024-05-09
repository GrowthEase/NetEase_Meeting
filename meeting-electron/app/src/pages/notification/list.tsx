import { useEffect, useRef, useState } from 'react';

import MeetingNotificationList from '../../../../src/components/web/MeetingNotification/List';
import NEMeetingService from '../../../../src/services/NEMeeting';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import { useTranslation } from 'react-i18next';
import { NEMeetingInfo } from '../../../../src/types';
import './index.less';
import { EventEmitter } from 'eventemitter3';

const eventEmitter = new EventEmitter();

const MeetingNotification: React.FC = () => {
  const { t } = useTranslation();

  const [sessionId, setSessionId] = useState<string>('');
  const [isInMeeting, setIsInMeeting] = useState<boolean>(false);

  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();

  const replyCount = useRef(0);

  const neMeeting = new Proxy(
    {},
    {
      get: function (_, propKey) {
        return function (...args: any) {
          return new Promise((resolve, reject) => {
            const parentWindow = window.parent;
            const replyKey = `neMeetingReply_${replyCount.current++}`;
            parentWindow?.postMessage(
              {
                event: 'neMeeting',
                payload: {
                  replyKey,
                  fnKey: propKey,
                  args: args,
                },
              },
              '*',
            );
            const handleMessage = (e: MessageEvent) => {
              const { event, payload } = e.data;
              if (event === replyKey) {
                const { result, error } = payload;
                if (error) {
                  reject(error);
                } else {
                  resolve(result);
                }
                window.removeEventListener('message', handleMessage);
              }
            };
            window.addEventListener('message', handleMessage);
          });
        };
      },
    },
  ) as NEMeetingService;

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      if (event === 'windowOpen') {
        const { meetingInfo, sessionId, isInMeeting } = payload;
        setMeetingInfo(meetingInfo);
        setSessionId(sessionId);
        setIsInMeeting(isInMeeting);
      } else if (event === 'eventEmitter') {
        eventEmitter.emit.apply(eventEmitter, [payload.key, ...payload.args]);
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  function dispatch(payload: any) {
    const parentWindow = window.parent;
    parentWindow?.postMessage(
      {
        event: 'meetingInfoDispatch',
        payload: payload,
      },
      '*',
    );
  }

  function handleClick(action?: string) {
    const parentWindow = window.parent;
    parentWindow?.postMessage(
      {
        event: 'notificationClick',
        payload: {
          action,
        },
      },
      '*',
    );
  }

  useEffect(() => {
    // 设置页面标题
    setTimeout(() => {
      document.title = t('notifyCenter');
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <>
      {isInMeeting ? null : (
        <div className="electron-drag-bar">
          <div className="drag-region" />
          {t('notifyCenter')}
          <PCTopButtons minimizable={false} maximizable={false} />
        </div>
      )}
      <div
        style={{
          height: isInMeeting ? '100%' : 'calc(100% - 40px)',
        }}
      >
        <MeetingNotificationList
          neMeeting={neMeeting}
          sessionIds={sessionId ? [sessionId] : []}
          meetingInfo={meetingInfo}
          eventEmitter={eventEmitter}
          meetingInfoDispatch={dispatch}
          onClick={handleClick}
        />
      </div>
    </>
  );
};

export default MeetingNotification;
