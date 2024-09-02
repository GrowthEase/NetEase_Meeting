import React, { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';

import useNEMeetingKitContextPageContext from '@/hooks/useNEMeetingKitContextPageContext';
import ImageCrop from '@meeting-module/components/common/ImageCrop';
import PCTopButtons from '@meeting-module/components/common/PCTopButtons';

import './index.less';

const ImageCropPage: React.FC = () => {
  const { t } = useTranslation();
  const { neMeetingKit } = useNEMeetingKitContextPageContext();
  const [image, setImage] = useState<string>('');

  const accountService = useMemo(() => {
    return neMeetingKit.getAccountService();
  }, [neMeetingKit]);

  function handleOk(url?: string) {
    const parentWindow = window.parent;

    parentWindow?.postMessage(
      {
        event: 'updateUserAvatar',
        payload: {
          url,
        },
      },
      parentWindow.origin,
    );
    window.close();
  }

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;

      console.log('setAvatarImage', event, payload);
      if (event === 'setAvatarImage') {
        setImage(payload.image);
      }
    }

    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    setTimeout(() => {
      document.title = t('settingAvatarTitle');
    });
  }, [t]);

  return (
    <>
      <div className="electron-drag-bar">
        <div className="drag-region" />
        {t('settingAvatarTitle')}
        <PCTopButtons minimizable={false} maximizable={false} />
      </div>
      <ImageCrop
        image={image}
        accountService={accountService}
        onCancel={() => window.close()}
        onOk={handleOk}
      />
    </>
  );
};

export default ImageCropPage;
