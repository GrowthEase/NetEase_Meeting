import React, { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';

import './index.less';
import FeedbackContent from '../../../../src/components/web/Feedback';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import { useGlobalContext } from '../../../../src/store';

const FeedbackPage: React.FC = () => {
  const { t } = useTranslation();
  const [visible, setVisible] = useState<boolean>(false);
  const [meetingId, setMeetingId] = useState('');
  const [nickname, setNickname] = useState('');
  const [appKey, setAppKey] = useState('');
  const [systemAndManufacturer, setSystemAndManufacturer] = useState({
    manufacturer: '',
    version: '',
    model: '',
  });
  const [inMeeting, setInMeeting] = useState(false);
  const { neMeeting } = useGlobalContext();

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'setFeedbackData') {
        payload.meetingId && setMeetingId(payload.meetingId);
        payload.nickname && setNickname(payload.nickname);
        payload.appKey && setAppKey(payload.appKey);
        payload.inMeeting && setInMeeting(payload.inMeeting);
        payload.systemAndManufacturer &&
          setSystemAndManufacturer(payload.systemAndManufacturer);

        setVisible(true);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return (
    <>
      <div className={'feedback-page'}>
        <div className="electron-drag-bar">
          <div className="drag-region" />
          <span
            className="title"
            style={{
              fontWeight: window.systemPlatform === 'win32' ? 'bold' : '500',
            }}
          >
            {t('feedback')}
          </span>
          <PCTopButtons size="normal" minimizable={false} maximizable={false} />
        </div>
        <div className="feedback-meeting-content">
          <FeedbackContent
            visible={visible}
            meetingId={meetingId}
            nickname={nickname}
            appKey={appKey}
            neMeeting={neMeeting}
            systemAndManufacturer={systemAndManufacturer}
            inMeeting={inMeeting}
            onClose={() => {
              window.close();
            }}
            loadingChange={(flag) => {
              const parentWindow = window.parent;

              parentWindow?.postMessage(
                {
                  event: 'onFeedbackUpload',
                  payload: {
                    value: flag,
                  },
                },
                parentWindow.origin,
              );
            }}
            onFeedbackSuccess={() => {
              const parentWindow = window.parent;

              parentWindow?.postMessage(
                {
                  event: 'onFeedbackSuccess',
                  payload: {
                    value: 'success',
                  },
                },
                parentWindow.origin,
              );
            }}
          />
        </div>
      </div>
    </>
  );
};

export default FeedbackPage;
