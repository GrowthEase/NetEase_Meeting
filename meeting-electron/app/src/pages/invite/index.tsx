import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import { useEffect, useState } from 'react';
import { Invite } from '../../../../src/components/web/InviteModal';
import './index.less';
import { useTranslation } from 'react-i18next';

export default function InvitePage() {
  const { t } = useTranslation();

  const [meetingInfo, setMeetingInfo] = useState();

  useEffect(() => {
    // @ts-ignore
    window.ipcRenderer?.on('updateData', (_, data) => {
      const { meetingInfo } = data;
      setMeetingInfo(meetingInfo);
    });
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('inviteBtn');
    });
  }, [t]);

  return (
    <div className="invite-page">
      <Invite meetingInfo={meetingInfo} />
    </div>
  );
}
