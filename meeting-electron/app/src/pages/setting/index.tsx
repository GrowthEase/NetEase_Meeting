import { useEffect, useMemo, useState } from 'react';
import PCTopButtons from '../../../../src/components/common/PCTopButtons';
import SettingWeb from '../../../../src/components/electron/Setting/SettingWeb';
import Styles from './index.less';
import { ConfigProvider } from 'antd';
import { useTranslation } from 'react-i18next';
import { NEPreviewController, NEPreviewRoomContext } from 'neroom-web-sdk';
import { SettingTabType } from '../../../../src/components/web/Setting/Setting';
const antdPrefixCls = 'nemeeting';

ConfigProvider.config({ prefixCls: antdPrefixCls });

export default function IndexPage() {
  const { t } = useTranslation();
  // const { search } = useLocation();
  const [inMeeting, setInMeeting] = useState(false);
  const [defaultTab, setDefaultTab] = useState<SettingTabType>('normal');

  function proxyHandle(propKey: string | symbol) {
    return function (...args: any) {
      if (
        propKey === 'addPreviewRoomListener' ||
        propKey === 'removePreviewRoomListener'
      ) {
        return;
      }
      return new Promise((resolve, reject) => {
        const parentWindow = window.parent;
        const replyKey = `previewControllerReply_${Math.random()}`;
        args.forEach((arg: any, index: number) => {
          if (arg instanceof HTMLElement) {
            args[index] = {};
          } else if (typeof arg === 'object') {
            const obj: any = {};
            for (const key in arg) {
              const element = arg[key];
              if (typeof element === 'function') {
                obj[key] = '__LISTENER_FUNCTION__';
              } else {
                obj[key] = element;
              }
            }
            args[index] = obj;
          } else if (typeof arg === 'function') {
            args[index] = '__LISTENER_FUNCTION__';
          }
        });
        parentWindow?.postMessage(
          {
            event: 'previewController',
            payload: {
              replyKey,
              fnKey: propKey,
              args: args,
            },
          },
          parentWindow.origin,
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
  }
  const previewController = useMemo(() => {
    return new Proxy(
      {},
      {
        get: function (_, propKey) {
          return proxyHandle(propKey);
        },
      },
    ) as NEPreviewController;
  }, []);
  const previewContext = useMemo(() => {
    return new Proxy(
      {},
      {
        get: function (_, propKey) {
          return proxyHandle(propKey);
        },
      },
    ) as NEPreviewRoomContext;
  }, []);
  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      if (event === 'openSetting') {
        setDefaultTab(payload.type);
        setInMeeting(payload.inMeeting);
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return (
    <div className={Styles.settingWeb}>
      <div className={Styles.settingHeader}>
        <div className={Styles.electronDragBar} />
        {t('settings')}
        <PCTopButtons minimizable={false} maximizable={false} />
      </div>
      <SettingWeb
        inMeeting={inMeeting}
        previewContext={previewContext}
        previewController={previewController}
        defaultTab={defaultTab}
      />
    </div>
  );
}
