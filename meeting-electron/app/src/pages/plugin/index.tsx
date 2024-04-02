import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import { useEffect, useMemo, useRef, useState } from 'react';
import MeetingPlugin from '../../../../src/components/web/MeetingRightDrawer/MeetingPlugin';
import './index.less';
import { useLocation } from 'umi';
import { NEMeetingInfo } from '../../../../src/types';
import NEMeetingService from '../../../../src/services/NEMeeting';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';

export default function MeetingPluginPage() {
  const [pluginInfo, setPluginInfo] = useState<{
    title: string;
    url: string;
    pluginId: string;
    roomArchiveId: string;
    isInMeeting: boolean;
  }>();

  const replyCount = useRef(0);

  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();

  const showMeetingPlugin = useMemo(() => {
    if (!pluginInfo?.isInMeeting) {
      return true;
    }
    return meetingInfo?.meetingNum ? true : false;
  }, [pluginInfo?.isInMeeting, meetingInfo?.meetingNum]);

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
    // 设置页面标题
    setTimeout(() => {
      pluginInfo?.title && (document.title = pluginInfo?.title);
    });
  }, [pluginInfo?.title]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      if (event === 'updateData') {
        const {
          meetingInfo,
          pluginId,
          url,
          roomArchiveId,
          isInMeeting,
          title,
        } = payload;
        setMeetingInfo(meetingInfo);
        pluginId &&
          setPluginInfo({
            title,
            url,
            pluginId,
            roomArchiveId,
            isInMeeting,
          });
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return (
    <>
      {pluginInfo?.isInMeeting ? null : (
        <div className="electron-drag-bar">
          <div className="drag-region" />
          {pluginInfo?.title}
          <PCTopButtons minimizable={false} maximizable={false} />
        </div>
      )}
      <div
        className="plugin-wrapper"
        style={pluginInfo?.isInMeeting ? undefined : { top: 40 }}
      >
        {showMeetingPlugin && pluginInfo ? (
          <MeetingPlugin
            url={pluginInfo.url}
            isInMeeting={pluginInfo.isInMeeting}
            pluginId={pluginInfo.pluginId}
            roomArchiveId={pluginInfo.roomArchiveId}
            neMeeting={neMeeting}
            meetingInfo={meetingInfo}
          />
        ) : null}
      </div>
    </>
  );
}
