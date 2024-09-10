import React, { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import PCTopButtons from '@meeting-module/components/common/PCTopButtons';
import classNames from 'classnames';

import './index.less';
import useNEMeetingKitContextPageContext from '@/hooks/useNEMeetingKitContextPageContext';
import Transcription from '@/components/web/BeforeMeetingModal/Transcription';

const HistoryPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeetingKit } = useNEMeetingKitContextPageContext();
  const [meetingId, setMeetingId] = useState<number>();
  const [accountId, setAccountId] = useState<string | undefined>();

  const preMeetingService = useMemo(() => {
    return neMeetingKit.getPreMeetingService();
  }, [neMeetingKit]);

  const contactsService = useMemo(() => {
    return neMeetingKit.getContactsService();
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

      if (event === 'updateData') {
        const { meetingId } = payload;

        meetingId && setMeetingId(meetingId);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return (
    <>
      <div className={classNames('nemeeting-transcription-page')}>
        <div className="electron-drag-bar">
          <div className="drag-region" />
          <span
            className="title"
            style={{
              fontWeight: 'bold',
            }}
          >
            {t('transcription')}
          </span>
          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <Transcription
          accountId={accountId}
          meetingId={meetingId}
          preMeetingService={preMeetingService}
          meetingContactsService={contactsService}
        />
      </div>
    </>
  );
};

export default HistoryPage;
