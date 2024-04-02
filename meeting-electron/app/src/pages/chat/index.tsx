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
const eventEmitter = new EventEmitter();

export default function ChatPage() {
  const { t } = useTranslation();

  const [memberList, setMemberList] = useState();
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();
  const [waitingRoomInfo, setWaitingRoomInfo] = useState();
  const [visible, setVisible] = useState(false);
  const chatControllerReplyCount = useRef(0);
  const roomServiceReplyCount = useRef(0);
  const [roomArchiveId, setRoomArchiveId] = useState<string>();

  const { search } = useLocation();
  const params = new URLSearchParams(window.location.search || search);
  const urlRoomArchiveId = params.get('roomArchiveId');
  const startTime = Number(params.get('startTime'));
  const subject = params.get('subject');

  const neMeeting: any = {
    imInfo: {},
    roomService: new Proxy(
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
              window.ipcRenderer?.once(replyKey, (_: any, value: any) => {
                const { fnKey, error, result } = value;
                console.log(fnKey, error, result);
                if (fnKey === propKey) {
                  error ? reject(error) : resolve(result);
                }
              });
              window.ipcRenderer?.send('NERoomSDKProxy', {
                method: 'roomService',
                data: {
                  fnKey: propKey,
                  args: args,
                  replyKey: `roomService-reply-${roomServiceReplyCount.current}`,
                  isInvoke: true,
                },
              });
            });
          };
        },
      },
    ),
    chatController: new Proxy(
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
              // @ts-ignore
              window.ipcRenderer?.once(replyKey, (_: any, value: any) => {
                const { fnKey, error, result } = value;
                console.log(fnKey, error, result);
                if (fnKey === propKey) {
                  error ? reject(error) : resolve(result);
                }
              });
              // @ts-ignore
              window.ipcRenderer?.send('nemeeting-sharing-screen', {
                method: 'chatController',
                data: {
                  fnKey: propKey,
                  args: args,
                  replyKey: `chatController-reply-${chatControllerReplyCount.current}`,
                },
              });
            });
          };
        },
      },
    ),
  };

  useEffect(() => {
    // @ts-ignore
    window.ipcRenderer?.on('updateData', (_, data) => {
      const { meetingInfo, memberList, waitingRoomInfo } = data;
      setMeetingInfo(meetingInfo);
      setMemberList(memberList);
      setWaitingRoomInfo(waitingRoomInfo);
    });
    // @ts-ignore
    window.ipcRenderer?.on('nemeeting-sharing-screen', (_, value) => {
      const { method, data } = value;
      if (method === 'chatListener') {
        console.log('chatListener', data);
        eventEmitter.emit.apply(eventEmitter, [data.key, ...data.args]);
      }
      if (method === 'openChatRoom') {
        setVisible(true);
      }
      if (method === 'closeChatRoom') {
        setVisible(false);
      }
    });
  }, []);

  useEffect(() => {
    setRoomArchiveId('');
    setTimeout(() => {
      setRoomArchiveId(urlRoomArchiveId || '');
    });
  }, [urlRoomArchiveId]);

  useEffect(() => {
    if (meetingInfo) {
      const localMember = meetingInfo?.localMember;
      const needDrawWatermark =
        meetingInfo.meetingNum &&
        meetingInfo.watermark &&
        (meetingInfo.watermark.videoStrategy === WATERMARK_STRATEGY.OPEN ||
          meetingInfo.watermark.videoStrategy ===
            WATERMARK_STRATEGY.FORCE_OPEN);

      if (needDrawWatermark && meetingInfo.watermark) {
        const { videoStyle, videoFormat } = meetingInfo.watermark;
        const supportInfo = {
          name: meetingInfo.watermarkConfig?.name || localMember.name,
          phone: meetingInfo.watermarkConfig?.phone || '',
          email: meetingInfo.watermarkConfig?.email || '',
          jobNumber: meetingInfo.watermarkConfig?.jobNumber || '',
        };
        function replaceFormat(format: string, info: Record<string, string>) {
          const regex = /{([^}]+)}/g;
          const result = format.replace(regex, (match, key) => {
            const value = info[key];
            return value ? value : match; // 如果值存在，则返回对应的值，否则返回原字符串
          });
          return result;
        }

        drawWatermark({
          container: document.body,
          content: replaceFormat(videoFormat, supportInfo),
          type: videoStyle,
        });
      } else {
        stopDrawWatermark();
      }
      return () => {
        stopDrawWatermark();
      };
    }
  }, [meetingInfo]);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('chat');
    });
  }, [t]);

  return (
    <>
      {urlRoomArchiveId ? (
        <div className={roomArchiveId ? 'history-chat-wrapper' : undefined}>
          {roomArchiveId && (
            <div className="electron-drag-bar">
              <div className="drag-region" />
              {t('chatHistory')}
              <PCTopButtons minimizable={false} maximizable={false} />
            </div>
          )}
          {!!roomArchiveId && (
            <ChatRoom
              startTime={startTime || 0}
              subject={subject || ''}
              roomArchiveId={roomArchiveId || undefined}
              isViewHistory={!!roomArchiveId}
              neMeeting={neMeeting}
              eventEmitter={eventEmitter}
              memberList={memberList}
              meetingInfo={meetingInfo}
              visible={visible}
            />
          )}
        </div>
      ) : !!meetingInfo?.ownerUserUuid && !!meetingInfo?.localMember.uuid ? (
        <ChatRoom
          startTime={startTime || 0}
          subject={subject || ''}
          roomArchiveId={roomArchiveId || undefined}
          isViewHistory={!!roomArchiveId}
          neMeeting={neMeeting}
          eventEmitter={eventEmitter}
          memberList={memberList}
          meetingInfo={meetingInfo}
          waitingRoomInfo={waitingRoomInfo}
          visible={visible}
        />
      ) : null}
    </>
  );
}
