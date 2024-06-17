import { useGlobalContext, useMeetingInfoContext } from '../../../../src/store';
import './index.less';
import React, { useCallback, useEffect, useMemo, useState } from 'react';
import InterpretationWindow from '../../../../src/components/common/Interpretation/InterpreterWindow';
import { Role } from '../../../../src/types';
import { IPCEvent } from '../../types/index';

const InterpreterSettingPage: React.FC = () => {
  const { neMeeting, interpretationSetting } = useGlobalContext();
  const { meetingInfo } = useMeetingInfoContext();

  const [defaultMajorVolume, setDefaultMajorVolume] = useState(20);
  const [defaultListeningVolume, setDefaultListeningVolume] = useState(70);
  const [interFloatingWindow, setInterFloatingWindow] = useState(false);
  const [interMiniWindow, setInterMiniWindow] = useState(false);

  const isHostOrCoHost = useMemo(() => {
    const role = meetingInfo.localMember.role;

    return role === Role.host || role === Role.coHost;
  }, [meetingInfo.localMember.role]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      if (event === 'updateData') {
        const { defaultMajorVolume } = payload;

        setDefaultMajorVolume(defaultMajorVolume);
        defaultListeningVolume !== undefined &&
          setDefaultListeningVolume(defaultListeningVolume);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  const handleOpenInterpreterSetting = () => {
    const parentWindow = window.parent;

    parentWindow?.postMessage(
      {
        event: 'openControllerBarWindow',
        payload: 'interpretation',
      },
      parentWindow.origin,
    );
  };

  const handleClose = () => {
    if (meetingInfo.isInterpreter || isHostOrCoHost) {
      setInterFloatingWindow(true);
    } else {
      window.ipcRenderer?.send('childWindow:closed');
    }
  };

  const handleMiniOrMaxWindow = useCallback(
    (isMini: boolean, floatingWindow: boolean) => {
      let height = 350;
      let width = 220;

      // 浮动窗口
      if (floatingWindow) {
        width = 42;
        height = 42;
        // 最小化窗口
      } else if (isMini) {
        height = 42;
      } else {
        if (meetingInfo.isInterpreter) {
          if (isHostOrCoHost) {
            if (interpretationSetting?.isListenMajor) {
              height = 350;
            } else {
              height = 277;
            }
          } else {
            if (interpretationSetting?.isListenMajor) {
              height = 313;
            } else {
              height = 232;
            }
          }
        } else {
          if (isHostOrCoHost) {
            if (interpretationSetting?.isListenMajor) {
              height = 251;
            } else {
              height = 175;
            }
          } else {
            if (interpretationSetting?.isListenMajor) {
              height = 207;
            } else {
              height = 130;
            }
          }
        }
      }

      window.ipcRenderer?.send(IPCEvent.interpreterWindowChange, {
        width,
        height,
        floatingWindow,
      });
    },
    [
      meetingInfo.isInterpreter,
      isHostOrCoHost,
      interpretationSetting?.isListenMajor,
    ],
  );

  useEffect(() => {
    if (meetingInfo.interpretation?.started) {
      handleMiniOrMaxWindow(interMiniWindow, interFloatingWindow);
    }
  }, [
    meetingInfo.interpretation?.started,
    handleMiniOrMaxWindow,
    interMiniWindow,
    interFloatingWindow,
  ]);

  const onOpenSelectChange = (open: boolean) => {
    if (open) {
      setTimeout(() => {
        window.ipcRenderer?.send(
          IPCEvent.interpreterWindowChange,
          {
            width: 220,
            height: 390,
            floatingWindow: false,
          },
          300,
        );
      });
    } else {
      handleMiniOrMaxWindow(interMiniWindow, interFloatingWindow);
    }
  };

  return (
    <div className="interp-window-page">
      <div className="interp-window-page-drag"></div>
      {neMeeting && (
        <InterpretationWindow
          interpretation={meetingInfo.interpretation}
          interpretationSetting={interpretationSetting}
          isInterpreter={meetingInfo.isInterpreter}
          defaultMajorVolume={defaultMajorVolume}
          defaultListeningVolume={defaultListeningVolume}
          localMember={meetingInfo.localMember}
          floatingWindow={interFloatingWindow}
          isMiniWindow={interMiniWindow}
          onClickMiniWindow={(isMini) => setInterMiniWindow(isMini)}
          onClose={() => handleClose()}
          onMaxWindow={() => setInterFloatingWindow(false)}
          onClickManagement={() => handleOpenInterpreterSetting()}
          onOpenSelectChange={onOpenSelectChange}
          neMeeting={neMeeting}
        />
      )}
    </div>
  );
};

export default InterpreterSettingPage;
