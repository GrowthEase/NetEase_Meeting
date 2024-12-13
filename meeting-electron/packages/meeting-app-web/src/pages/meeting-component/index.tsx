import React, { useEffect, useState } from 'react';
import NEMeetingKit from '@meeting-module/kit/impl/meeting_kit';
import { css } from '@emotion/css';

import '../index.less';
import { IPCEvent } from '../../types';

export default function MeetingPage() {
  // win32 边框样式问题
  const [isMaximized, setIsMaximized] = useState(false);
  const isSharingScreen = false;

  useEffect(() => {
    function handleMaximizeWindow(_, value: boolean) {
      setIsMaximized(value);
    }

    function handleEnterFullscreen() {
      setIsMaximized(true);
    }

    function handleQuitFullscreen() {
      setIsMaximized(false);
    }

    // NEMeetingKit.actions.on('onScreenSharingStatusChange', setIsSharingScreen);
    window.ipcRenderer?.on(IPCEvent.maximizeWindow, handleMaximizeWindow);
    window.ipcRenderer?.on(IPCEvent.enterFullscreen, handleEnterFullscreen);
    window.ipcRenderer?.on(IPCEvent.quiteFullscreen, handleQuitFullscreen);
    return () => {
      window.ipcRenderer?.off(IPCEvent.maximizeWindow, handleMaximizeWindow);
      window.ipcRenderer?.off(IPCEvent.enterFullscreen, handleEnterFullscreen);
      window.ipcRenderer?.off(IPCEvent.quiteFullscreen, handleQuitFullscreen);
    };
  }, []);

  useEffect(() => {
    NEMeetingKit.getInstance();
  }, []);

  const winCls =
    window.isElectronNative &&
    window.isWins32 &&
    !isMaximized &&
    !isSharingScreen
      ? css`
          width: calc(100% - 4px);
          height: calc(100% - 4px);
          margin: 2px;
        `
      : css`
          width: 100%;
          height: 100%;
        `;

  return (
    <>
      <div className={winCls}>
        <div
          id="ne-web-meeting"
          style={
            !window.isElectronNative
              ? {
                  position: 'absolute',
                  top: 28,
                  left: 0,
                  right: 0,
                  width: '100%',
                  height: 'calc(100% - 28px)',
                }
              : {
                  width: '100%',
                  height: '100%',
                }
          }
        ></div>
      </div>
    </>
  );
}
