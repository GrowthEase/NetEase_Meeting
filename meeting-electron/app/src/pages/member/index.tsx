import './index.less';
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import MemberList from '../../../../src/components/web/MemberList';
import { useEffect, useRef, useState } from 'react';
import {
  drawWatermark,
  stopDrawWatermark,
} from '../../../../src/utils/watermark';
import { NEMeetingInfo, WATERMARK_STRATEGY } from '../../../../src/types';
import { useTranslation } from 'react-i18next';
import NEMeetingService from '../../../../src/services/NEMeeting';

export default function MemberPage() {
  const { t } = useTranslation();

  const [memberList, setMemberList] = useState();
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();
  const [waitingRoomInfo, setWaitingRoomInfo] = useState();
  const [waitingRoomMemberList, setWaitingRoomMemberList] = useState();

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
      if (event === 'updateData') {
        const {
          meetingInfo,
          memberList,
          waitingRoomInfo,
          waitingRoomMemberList,
        } = payload;
        setMeetingInfo(meetingInfo);
        setMemberList(memberList);
        setWaitingRoomInfo(waitingRoomInfo);
        setWaitingRoomMemberList(waitingRoomMemberList);
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('participants');
    });
  }, [t]);

  return (
    <>
      <div className="member-page-header" />
      <MemberList
        neMeeting={neMeeting}
        waitingRoomInfo={waitingRoomInfo}
        waitingRoomMemberList={waitingRoomMemberList}
        memberList={memberList}
        meetingInfo={meetingInfo}
        open={true}
        width={400}
        closable={false}
        title={null}
      />
    </>
  );
}
