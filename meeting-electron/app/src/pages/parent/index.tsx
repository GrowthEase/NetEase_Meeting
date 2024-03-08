import { useEffect, useState } from 'react';
import classNames from 'classnames';
import './index.less';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import MacTopButtons from '../../../../src/components/common/MacTopButtons';

export default function ParentPage() {
  const [isOpenRightArea, setIsOpenRightArea] = useState(false);
  const [isFullScreen, setIsFullScreen] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);

  useEffect(() => {
    window.ipcRenderer?.on('openChatroomOrMemberList-reply', (_, isOpen) => {
      setIsOpenRightArea(isOpen);
    });
    window.ipcRenderer?.on('full-screen-reply', (_, fullscreen) => {
      setIsFullScreen(fullscreen);
    });
    window.ipcRenderer?.on('set-theme-color', (_, isDark) => {
      setIsDarkMode(isDark);
    });
  }, []);

  return (
    <div
      className={classNames('parent-page-container in-meeting', {
        ['light-theme']: !isDarkMode,
      })}
    >
      {isFullScreen ? (
        <div className="parent-page-title">
          网易会议
          <div className="drag-area" />
          {/* <MacTopButtons minimizable={true} fullscreenable={inMeeting} /> */}
          {/* <PCTopButtons minimizable={true} maximizable={true} /> */}
        </div>
      ) : null}
      {isOpenRightArea && <div className="parent-page-right-area" />}
      <div className="parent-page-content" />
    </div>
  );
}
