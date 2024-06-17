import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import HistoryMeeting from '../../../../src/components/web/BeforeMeetingModal/HistoryMeeting';
import { useGlobalContext } from '../../../../src/store';
import EventEmitter from 'eventemitter3';
import classNames from 'classnames';
import HistoryMeetingBgImg from '../../assets/history-meeting-bg.png';

const eventEmitter = new EventEmitter();

import './index.less';
import { EventType } from '../../../../src/types';

const HistoryPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeeting } = useGlobalContext();
  const [meetingId, setMeetingId] = useState<string>();
  const [pageMode, setPageMode] = useState<'list' | 'detail'>('list');

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      console.log('event', event, payload);
      if (event === 'windowOpen') {
        console.log('windowOpen', payload);
        const { meetingId } = payload;

        setMeetingId(meetingId);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title =
        pageMode === 'detail' ? t('meetingDetails') : t('historyMeeting');
    });
  }, [t, pageMode]);

  useEffect(() => {
    eventEmitter.on(
      EventType.OnHistoryMeetingPageModeChanged,
      (mode: 'list' | 'detail') => {
        setPageMode(mode);
      },
    );
  }, []);

  return (
    <>
      <div
        className={classNames('history-meeting-page', {
          'meeting-history-bg': pageMode === 'detail',
        })}
        style={{
          backgroundImage:
            pageMode === 'detail' ? `url(${HistoryMeetingBgImg})` : 'none',
        }}
      >
        <div className="electron-drag-bar">
          <div className="drag-region" />
          <span
            className="title"
            style={{
              fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
            }}
          >
            {pageMode === 'detail' ? t('meetingDetails') : t('historyMeeting')}
          </span>
          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <HistoryMeeting
          open
          neMeeting={neMeeting}
          meetingId={meetingId}
          onBack={() => setMeetingId(undefined)}
          eventEmitter={eventEmitter}
        />
      </div>
    </>
  );
};

export default HistoryPage;
