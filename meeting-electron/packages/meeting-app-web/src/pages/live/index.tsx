import './index.less';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import { useTranslation } from 'react-i18next';
import React, { useEffect, useMemo, useState } from 'react';
import Live from '@meeting-module/components/web/Live';
import { NELiveMember } from '@meeting-module/types';
import { useMeetingInfoContext } from '@meeting-module/store';

const LivePage: React.FC = () => {
  const { t } = useTranslation();
  const { meetingInfo, memberList } = useMeetingInfoContext();
  const [isOpen, setIsOpen] = useState(false);

  const randomPassword = useMemo(() => {
    return Math.random().toString().slice(-6);
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('live');
    });
  }, [t]);

  console.log('meetingInfo', meetingInfo);
  useEffect(() => {
    return () => {
      setIsOpen(false);
    };
  }, []);
  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'updateData') {
        const { isOpen } = payload;
        isOpen && setIsOpen(isOpen);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);
  console.log('isOpen', isOpen);
  const liveMembers = useMemo(() => {
    const resultList: NELiveMember[] = [];

    memberList.forEach((member) => {
      if (
        member.isVideoOn ||
        member.isAudioOn ||
        member.isSharingScreen ||
        member.isSharingSystemAudio
      ) {
        resultList.push({
          nickName: member.name,
          accountId: member.uuid,
          isVideoOn: member.isVideoOn,
          isSharingScreen: member.isSharingScreen,
          isAudioOn: member.isAudioOn,
          isSharingSystemAudio: member.isSharingSystemAudio,
        });
      }
    });
    return resultList;
  }, [memberList]);

  return (
    <div className="live-meeting-page">
      <div className="electron-drag-bar">
        <div className="drag-region" />
        <span
          style={{
            fontWeight: 'bold',
          }}
        >
          {t('live')}
        </span>
        <PCTopButtons size="normal" minimizable={false} maximizable={false} />
      </div>
      <div className="live-meeting-content">
        <Live
          open={isOpen}
          members={liveMembers}
          title={meetingInfo.subject}
          state={meetingInfo.liveState}
          randomPassword={randomPassword}
        />
      </div>
    </div>
  );
};

export default LivePage;
