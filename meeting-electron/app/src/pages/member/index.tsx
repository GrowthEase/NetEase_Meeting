import './index.less';
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import MemberList from '../../../../src/components/web/MemberList';
import { useEffect, useState } from 'react';
import {
  drawWatermark,
  stopDrawWatermark,
} from '../../../../src/utils/watermark';
import { NEMeetingInfo, WATERMARK_STRATEGY } from '../../../../src/types';
import { useTranslation } from 'react-i18next';

export default function MemberPage() {
  const { t } = useTranslation();

  const [memberList, setMemberList] = useState();
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();
  const [waitingRoomInfo, setWaitingRoomInfo] = useState();
  const [waitingRoomMemberList, setWaitingRoomMemberList] = useState();

  const neMeeting = new Proxy(
    {},
    {
      get: function (_, propKey) {
        return function (...args: any) {
          return new Promise((resolve, reject) => {
            window.ipcRenderer?.once('neMeetingReply', (_: any, value: any) => {
              const { fnKey, error } = value;
              if (fnKey === propKey) {
                error ? reject(error) : resolve('success');
              }
            });
            window.ipcRenderer?.send('nemeeting-sharing-screen', {
              method: 'neMeeting',
              data: {
                fnKey: propKey,
                args: args,
              },
            });
          });
        };
      },
    },
  );

  useEffect(() => {
    window.ipcRenderer?.on('updateData', (_, data) => {
      const {
        meetingInfo,
        memberList,
        waitingRoomInfo,
        waitingRoomMemberList,
      } = data;
      console.log('updateData', data);
      setMeetingInfo(meetingInfo);
      setMemberList(memberList);
      setWaitingRoomInfo(waitingRoomInfo);
      setWaitingRoomMemberList(waitingRoomMemberList);
    });
  }, []);

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
      document.title = t('memberListTitle');
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
