import { useLocation } from 'umi';
import { useEffect, useRef, useState } from 'react';

import MeetingNotificationList from '../../../../src/components/web/MeetingNotification/List';
import NEMeetingService from '../../../../src/services/NEMeeting';

import './index.less';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import { useTranslation } from 'react-i18next';
import { NEMeetingInfo } from '../../../../src/types';
import ImageCrop from '../../../../src/components/common/ImageCrop';

const ImageCropPage: React.FC = () => {
  const { t } = useTranslation();
  const i18n = {
    title: t('settingAvatarTitle'),
  };

  const [image, setImage] = useState<string>('');

  const replyCount = useRef(0);

  const neMeeting = new Proxy(
    {},
    {
      get: function (_, propKey) {
        return function (...args: any) {
          return new Promise((resolve, reject) => {
            const parentWindow = window.parent;
            const replyKey = `neMeetingReply_${replyCount.current++}`;
            parentWindow?.postMessage(
              {
                event: 'neMeeting',
                payload: {
                  replyKey,
                  fnKey: propKey,
                  args: args,
                },
              },
              '*',
            );
            const handleMessage = (e: MessageEvent) => {
              const { event, payload } = e.data;
              if (event === replyKey) {
                const { result, error } = payload;
                if (error) {
                  reject(error);
                } else {
                  resolve(result);
                }
                window.removeEventListener('message', handleMessage);
              }
            };
            window.addEventListener('message', handleMessage);
          });
        };
      },
    },
  ) as NEMeetingService;

  function handleOk(url?: string) {
    const parentWindow = window.parent;
    parentWindow?.postMessage(
      {
        event: 'updateUserAvatar',
        payload: {
          url,
        },
      },
      '*',
    );
    window.close();
  }

  useEffect(() => {
    // 设置页面标题
    setTimeout(() => {
      document.title = i18n.title;
    });

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
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <>
      <div className="electron-drag-bar">
        <div className="drag-region" />
        {i18n.title}
        <PCTopButtons minimizable={false} maximizable={false} />
      </div>
      <ImageCrop
        image={image}
        neMeeting={neMeeting}
        onCancel={() => window.close()}
        onOk={handleOk}
      />
    </>
  );
};

export default ImageCropPage;
