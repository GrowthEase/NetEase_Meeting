import React, { useEffect, useMemo, useState } from 'react';

import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import MeetingPlugin from '@meeting-module/components/common/PlugIn/MeetingPlugin';
import { useMeetingInfoContext } from '@meeting-module/store';
import useWatermark from '@meeting-module/hooks/useWatermark';

import './index.less';

const MeetingPluginPage: React.FC = () => {
  useWatermark();
  const { meetingInfo } = useMeetingInfoContext();
  const [pluginInfo, setPluginInfo] = useState<{
    title: string;
    url: string;
    pluginId: string;
    roomArchiveId: number;
    isInMeeting: boolean;
  }>();

  const showMeetingPlugin = useMemo(() => {
    if (!pluginInfo?.isInMeeting) {
      return true;
    }

    return meetingInfo?.meetingNum ? true : false;
  }, [pluginInfo?.isInMeeting, meetingInfo?.meetingNum]);

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
        const { pluginId, url, roomArchiveId, isInMeeting, title } = payload;

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
        style={pluginInfo?.isInMeeting ? undefined : { top: 50 }}
      >
        {showMeetingPlugin && pluginInfo ? (
          <MeetingPlugin
            url={pluginInfo.url}
            isInMeeting={pluginInfo.isInMeeting}
            pluginId={pluginInfo.pluginId}
            roomArchiveId={pluginInfo.roomArchiveId}
          />
        ) : null}
      </div>
    </>
  );
};

export default MeetingPluginPage;
