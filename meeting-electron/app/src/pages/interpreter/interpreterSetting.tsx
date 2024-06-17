import { useTranslation } from 'react-i18next';
import { useGlobalContext, useMeetingInfoContext } from '../../../../src/store';
import './index.less';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import InterpreterSetting from '../../../../src/components/common/Interpretation/InterpreterSetting';
import {
  InterpretationRes,
  NEMeetingInterpreter,
  NEMeetingScheduledMember,
  NEMember,
} from '../../../../src/types/type';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import {
  GetMeetingConfigResponse,
  InterpreterSettingRef,
} from '../../../../src/types';

const InterpreterSettingPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeeting, globalConfig } = useGlobalContext();
  const {
    memberList,
    inInvitingMemberList: meetingInInvitingMemberList,
    meetingInfo,
  } = useMeetingInfoContext();
  const [interpretation, setInterpretation] = useState<InterpretationRes>();
  const [scheduleMembers, setScheduledMembers] =
    useState<NEMeetingScheduledMember[]>();
  const [inMeeting, setInMeeting] = useState<boolean>(true);
  const interpreterSettingRef = useRef<InterpreterSettingRef>(null);
  const [beforeGlobalConfig, setBeforeGlobalConfig] =
    useState<GetMeetingConfigResponse>();
  const [inInvitingMemberList, setInInvitingMemberList] = useState<NEMember[]>(
    [],
  );

  useEffect(() => {
    meetingInInvitingMemberList &&
      setInInvitingMemberList(meetingInInvitingMemberList);
  }, [meetingInInvitingMemberList]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'updateData') {
        const {
          interpretation,
          inMeeting,
          globalConfig,
          scheduledMembers,
          inInvitingMemberList,
          isOpen,
        } = payload;

        globalConfig && setBeforeGlobalConfig(globalConfig);
        isOpen && interpretation && setInterpretation(interpretation);
        setInMeeting(inMeeting);
        setScheduledMembers(scheduledMembers);
        inInvitingMemberList && setInInvitingMemberList(inInvitingMemberList);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    function ipcRenderer() {
      interpreterSettingRef.current?.handleCloseBeforeMeetingWindow();
    }

    window.ipcRenderer?.on('interpreterSettingWindow:close', ipcRenderer);
    return () => {
      window.ipcRenderer?.removeListener(
        'interpreterSettingWindow:close',
        ipcRenderer,
      );
    };
  }, []);
  const handleClose = () => {
    window.ipcRenderer?.send('childWindow:closed');
  };

  const onSaveInterpreters = (interpreters: NEMeetingInterpreter[]) => {
    const parentWindow = window.parent;

    parentWindow.postMessage(
      {
        event: 'onSaveInterpreters',
        payload: {
          interpreters,
        },
      },
      parentWindow.origin,
    );
    handleClose();
  };

  const enableCustomLang = useMemo(() => {
    if (inMeeting) {
      return !!globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
        ?.enableCustomLang;
    } else {
      return !!beforeGlobalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
        ?.enableCustomLang;
    }
  }, [
    inMeeting,
    globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation?.enableCustomLang,
    beforeGlobalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
      ?.enableCustomLang,
  ]);

  const maxCustomLanguageLength = useMemo(() => {
    if (inMeeting) {
      return globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
        ?.maxCustomLanguageLength;
    } else {
      return beforeGlobalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
        ?.maxCustomLanguageLength;
    }
  }, [
    inMeeting,
    globalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
      ?.maxCustomLanguageLength,
    beforeGlobalConfig?.appConfig.APP_ROOM_RESOURCE.interpretation
      ?.maxCustomLanguageLength,
  ]);

  function onDeleteScheduleMember(userUuid: string) {
    const parentWindow = window.parent;

    parentWindow.postMessage(
      {
        event: 'onDeleteScheduleMember',
        payload: {
          userUuid,
        },
      },
      parentWindow.origin,
    );
  }

  return (
    <div className="interp-setting-page">
      <div className="electron-drag-bar">
        <div className="drag-region" />
        {t('interpInterpreter')}
        <PCTopButtons minimizable={false} maximizable={false} />
      </div>
      {neMeeting && (!inMeeting || memberList.length > 0) && (
        <InterpreterSetting
          scheduleMembers={scheduleMembers}
          enableCustomLang={enableCustomLang}
          maxCustomLanguageLength={maxCustomLanguageLength}
          ref={interpreterSettingRef}
          interpretation={interpretation || meetingInfo.interpretation}
          isStarted={meetingInfo.interpretation?.started}
          onDeleteScheduleMember={onDeleteScheduleMember}
          onSaveInterpreters={onSaveInterpreters}
          onClose={() => handleClose()}
          inMeeting={inMeeting}
          neMeeting={neMeeting}
          memberList={memberList}
          inInvitingMemberList={inInvitingMemberList}
        />
      )}
    </div>
  );
};

export default InterpreterSettingPage;
