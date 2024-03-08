import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import './index.less';
import { useEffect, useRef } from 'react';
import MemberNotify, {
  MemberNotifyRef,
} from '../../../../src/components/web/MemberNotify';
import { IPCEvent } from '@/types';

export default function MemberNotifyPage() {
  const memberNotifyRef = useRef<MemberNotifyRef>(null);
  function handleViewMsg() {
    window.ipcRenderer?.send(IPCEvent.memberNotifyViewMemberMsg);
  }
  function onClose() {
    console.log('close>>>>.');
    if (window.isWins32) {
      // windows 需要延迟，否则整个弹框渲染不会因此，等下次显示会有上一次的停留
      setTimeout(() => {
        window.ipcRenderer?.send(IPCEvent.memberNotifyClose);
      }, 200);
    } else {
      window.ipcRenderer?.send(IPCEvent.memberNotifyClose);
    }
  }
  function onNotNotify() {
    window.ipcRenderer?.send(IPCEvent.memberNotifyNotNotify);
  }
  useEffect(() => {
    window.ipcRenderer?.on(IPCEvent.notifyShow, (event, arg) => {
      const { memberCount } = arg;
      memberNotifyRef.current?.notify(memberCount);
    });
    window.ipcRenderer?.on(IPCEvent.notifyHide, (event, arg) => {
      memberNotifyRef.current?.destroy();
    });
    function handleMouseMove() {
      window.ipcRenderer?.send(IPCEvent.memberNotifyMourseMove);
    }
    window.addEventListener('mousemove', handleMouseMove);
    return () => {
      window.ipcRenderer?.removeAllListeners(IPCEvent.notifyShow);
      window.ipcRenderer?.removeAllListeners(IPCEvent.notifyHide);
      window.removeEventListener('mousemove', handleMouseMove);
    };
  }, []);
  return (
    <div className="nemtting-notify-page">
      <MemberNotify
        style={{
          top: 0,
          right: 0,
        }}
        ref={memberNotifyRef}
        onClose={onClose}
        onNotNotify={onNotNotify}
        handleViewMsg={handleViewMsg}
      />
    </div>
  );
}
