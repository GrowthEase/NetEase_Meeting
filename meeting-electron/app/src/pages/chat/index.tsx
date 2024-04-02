import ChatRoom from '../../../../src/components/web/Chatroom/Chatroom';
import { useEffect, useRef, useState } from 'react';
import { EventEmitter } from 'eventemitter3';
import { useTranslation } from 'react-i18next';

import './index.less';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import { useLocation } from 'umi';
import { NEMeetingInfo, WATERMARK_STRATEGY } from '../../../../src/types';
import {
  drawWatermark,
  stopDrawWatermark,
} from '../../../../src/utils/watermark';
import NEMeetingService from '../../../../src/services/NEMeeting';
const eventEmitter = new EventEmitter();

export default function ChatPage() {
  const { t } = useTranslation();

  const [memberList, setMemberList] = useState();
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();
  const [waitingRoomInfo, setWaitingRoomInfo] = useState();
  const [waitingRoomMemberList, setWaitingRoomMemberList] = useState();

  const [initMsgs, setInitMsgs] = useState<any[]>([]);
  const [visible, setVisible] = useState(false);
  const neMeetingReplyCount = useRef(0);
  const chatControllerReplyCount = useRef(0);
  const roomServiceReplyCount = useRef(0);

  const [chatInfo, setChatInfo] = useState<{
    roomArchiveId: string;
    startTime: number;
    subject: string;
  }>();

  const neMeeting = new Proxy(
    {},
    {
      get: function (_, propKey) {
        if (propKey === 'imInfo') {
          return {};
        }
        if (propKey === 'roomService') {
          return new Proxy(
            {},
            {
              get: function (_, propKey) {
                if (propKey === 'isSupported') {
                  return true;
                }
                return function (...args: any) {
                  return new Promise((resolve, reject) => {
                    roomServiceReplyCount.current += 1;
                    const replyKey = `roomService-reply-${roomServiceReplyCount.current}`;
                    const parentWindow = window.parent;
                    parentWindow?.postMessage(
                      {
                        event: 'roomService',
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
          );
        }
        if (propKey === 'chatController') {
          return new Proxy(
            {},
            {
              get: function (_, propKey) {
                if (propKey === 'isSupported') {
                  return true;
                }
                return function (...args: any) {
                  return new Promise((resolve, reject) => {
                    chatControllerReplyCount.current += 1;
                    const replyKey = `chatController-reply-${chatControllerReplyCount.current}`;
                    const parentWindow = window.parent;
                    parentWindow?.postMessage(
                      {
                        event: 'chatController',
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
          );
        }
        return function (...args: any) {
          return new Promise((resolve, reject) => {
            const parentWindow = window.parent;
            const replyKey = `neMeetingReply_${neMeetingReplyCount.current++}`;
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

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      if (event === 'updateData') {
        const {
          meetingInfo,
          memberList,
          waitingRoomInfo,
          waitingRoomMemberList,
          cacheMsgs,
          roomArchiveId,
          startTime,
          subject,
        } = payload;
        setMeetingInfo(meetingInfo);
        setMemberList(memberList);
        setWaitingRoomInfo(waitingRoomInfo);
        setWaitingRoomMemberList(waitingRoomMemberList);
        setInitMsgs(cacheMsgs);
        roomArchiveId && setChatInfo({ roomArchiveId, startTime, subject });
      } else if (event === 'chatroomEvent') {
        eventEmitter.emit.apply(eventEmitter, [payload.key, ...payload.args]);
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  console.log('chatInfo', chatInfo);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('chat');
    });
  }, [t]);

  return (
    <>
      {chatInfo && chatInfo?.roomArchiveId ? (
        <div className="history-chat-wrapper">
          <div className="electron-drag-bar">
            <div className="drag-region" />
            {t('chatHistory')}
            <PCTopButtons minimizable={false} maximizable={false} />
          </div>
          <ChatRoom
            startTime={chatInfo.startTime}
            subject={chatInfo.subject}
            roomArchiveId={chatInfo.roomArchiveId}
            isViewHistory={true}
            neMeeting={neMeeting}
            eventEmitter={eventEmitter}
            memberList={memberList}
            meetingInfo={meetingInfo}
            visible={visible}
          />
        </div>
      ) : !!meetingInfo?.ownerUserUuid && !!meetingInfo?.localMember.uuid ? (
        <ChatRoom
          neMeeting={neMeeting}
          eventEmitter={eventEmitter}
          memberList={memberList}
          meetingInfo={meetingInfo}
          waitingRoomInfo={waitingRoomInfo}
          waitingRoomMemberList={waitingRoomMemberList}
          visible={true}
          initMsgs={initMsgs}
          meetingInfoDispatch={dispatch}
        />
      ) : null}
    </>
  );
}
