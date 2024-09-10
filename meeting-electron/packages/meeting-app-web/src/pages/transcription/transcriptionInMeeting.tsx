import React, { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';

import classNames from 'classnames';

import './index.less';
import { Transcription } from '@meeting-module/components/web/Transcription';
import { NERoomCaptionMessage } from 'neroom-types';
import { CaptionMessageUserInfo, MeetingSetting } from '@meeting-module/types';
import { setLocalStorageSetting } from '@meeting-module/utils';
import { IPCEvent } from '@meeting-module/app/src/types';

const HistoryPage: React.FC = () => {
  const { t } = useTranslation();
  const [transcriptionMessageList, setTranscriptionMessageList] = useState<
    NERoomCaptionMessage[]
  >([]);
  const messageUserInfosRef = useRef<Map<string, CaptionMessageUserInfo>>(
    new Map(),
  );

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'updateData') {
        const {
          transcriptionMessageList,
          messageUserInfosRef: messageUserInfos,
        } = payload;

        transcriptionMessageList &&
          setTranscriptionMessageList(transcriptionMessageList);
        messageUserInfos && (messageUserInfosRef.current = messageUserInfos);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);
  useEffect(() => {
    setTimeout(() => {
      document.title = t('transcription');
    });
  }, [t]);

  function onSettingChange(setting: MeetingSetting): void {
    setLocalStorageSetting(JSON.stringify(setting));
    window.ipcRenderer?.send(IPCEvent.changeSetting, setting);
  }

  return (
    <>
      <div className={classNames('nemeeting-transcription-page')}>
        <Transcription
          onSettingChange={onSettingChange}
          transcriptionMessageList={transcriptionMessageList}
          messageUserInfosRef={messageUserInfosRef}
          isElectronWindow={true}
        />
      </div>
    </>
  );
};

export default HistoryPage;
