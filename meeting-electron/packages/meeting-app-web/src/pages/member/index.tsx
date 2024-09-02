import React, { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import MemberList from '@meeting-module/components/web/MemberList';
import useWatermark from '@meeting-module/hooks/useWatermark';

import './index.less';

const MemberPage: React.FC = () => {
  useWatermark();

  const { t } = useTranslation();

  useEffect(() => {
    setTimeout(() => {
      document.title = t('participants');
    });
  }, [t]);

  return <MemberList />;
};

export default MemberPage;
