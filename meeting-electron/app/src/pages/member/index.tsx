import { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import MemberList from '../../../../src/components/web/MemberList';
import useWatermark from '../../../../src/hooks/useWatermark';

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
