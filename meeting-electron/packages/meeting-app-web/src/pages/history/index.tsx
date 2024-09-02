import React, { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import HistoryMeeting from '../../components/web/BeforeMeetingModal/HistoryMeeting';
import EventEmitter from 'eventemitter3';
import classNames from 'classnames';
import HistoryMeetingBgImg from '../../assets/history-meeting-bg.png';

const eventEmitter = new EventEmitter();

import './index.less';
import { EventType } from '@meeting-module/types';
import useNEMeetingKitContextPageContext from '@/hooks/useNEMeetingKitContextPageContext';

const HistoryPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeetingKit } = useNEMeetingKitContextPageContext();
  const [meetingId, setMeetingId] = useState<number>();
  const [pageMode, setPageMode] = useState<'list' | 'detail'>('list');
  const [accountId, setAccountId] = useState<string | undefined>();
  const [open, setOpen] = useState(false);

  const preMeetingService = useMemo(() => {
    return neMeetingKit.getPreMeetingService();
  }, [neMeetingKit]);

  const accountService = useMemo(() => {
    return neMeetingKit.getAccountService();
  }, [neMeetingKit]);

  useEffect(() => {
    accountService?.getAccountInfo().then((res) => {
      res?.data && setAccountId(res.data.userUuid);
    });
  }, [accountService]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'windowOpen') {
        const { meetingId } = payload;

        setMeetingId(Number(meetingId));
        setOpen(true);
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
              fontWeight: 'bold',
            }}
          >
            {pageMode === 'detail' ? t('meetingDetails') : t('historyMeeting')}
          </span>
          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <HistoryMeeting
          open={open}
          accountId={accountId}
          meetingId={meetingId}
          preMeetingService={preMeetingService}
          onBack={() => setMeetingId(undefined)}
          eventEmitter={eventEmitter}
        />
      </div>
    </>
  );
};

export default HistoryPage;
