import React, { useEffect, useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { ConfigProvider } from 'antd';
import { NEMeetingInfo, WATERMARK_STRATEGY } from '../../../src/types';
import '../../../src/locales/i18n';
import zhCN from 'antd/locale/zh_CN';
import enUs from 'antd/locale/en_US';
import jaJP from 'antd/locale/ja_JP';
import dayjs from 'dayjs';
import 'dayjs/locale/ja';
import 'dayjs/locale/zh-cn';
import 'dayjs/locale/en';
import { drawWatermark, stopDrawWatermark } from '../../../src/utils/watermark';

export default (props) => {
  const hash = window.location.hash;
  const { i18n } = useTranslation();
  const [windowOpen, setWindowOpen] = React.useState(true);
  const [meetingInfo, setMeetingInfo] = useState<NEMeetingInfo>();

  const enableWatermark = useMemo(() => {
    if (
      hash.includes('#/member') ||
      hash.includes('#/chat') ||
      hash.includes('#/notification/list') ||
      hash.includes('#/screenSharing/video') ||
      hash.includes('#/plugin')
    ) {
      return true;
    }
    return false;
  }, [hash]);

  useEffect(() => {
    const settingStr = localStorage.getItem('ne-meeting-setting');
    let language =
      {
        zh: 'zh-CN',
        en: 'en-US',
        ja: 'ja-JP',
      }[navigator.language.split('-')[0]] || 'en-US';
    if (settingStr) {
      try {
        const setting = JSON.parse(settingStr);
        if (setting.normalSetting.language) {
          language = setting.normalSetting.language;
        }
        // i18n.changeLanguage(setting.normalSetting.language || defaultLanguage);
      } catch (error) {}
    }

    i18n.changeLanguage(language);
  }, []);

  useEffect(() => {
    function changeLanguage(event: any, data: any) {
      if (i18n.language === data.normalSetting.language) return;
      const defaultLanguage =
        {
          zh: 'zh-CN',
          en: 'en-US',
          ja: 'ja-JP',
        }[navigator.language.split('-')[0]] || 'en-US';
      i18n.changeLanguage(data.normalSetting.language || defaultLanguage);
    }
    window.ipcRenderer?.on('changeSetting', changeLanguage);
    return () => {
      window.ipcRenderer?.removeListener('changeSetting', changeLanguage);
    };
  }, [i18n.language]);

  useEffect(() => {
    function handleMessage(e: MessageEvent) {
      const { event, payload } = e.data;
      // 关闭统一处理页面重置逻辑
      switch (event) {
        case 'windowClosed':
          setWindowOpen(false);
          setTimeout(() => {
            setWindowOpen(true);
          });
          break;
        case 'windowOpen':
        case 'updateData':
          setMeetingInfo(payload.meetingInfo);
          break;
        default:
          break;
      }
    }
    window.addEventListener('message', handleMessage);
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  useEffect(() => {
    if (meetingInfo && enableWatermark) {
      const isScreenSharingVideo = hash.includes('#/screenSharing/video');

      const localMember = meetingInfo?.localMember;
      const needDrawWatermark =
        meetingInfo.meetingNum &&
        meetingInfo.watermark &&
        (meetingInfo.watermark.videoStrategy === WATERMARK_STRATEGY.OPEN ||
          meetingInfo.watermark.videoStrategy ===
            WATERMARK_STRATEGY.FORCE_OPEN);

      if (needDrawWatermark && meetingInfo.watermark) {
        const { videoStyle, videoFormat } = meetingInfo.watermark;
        const supportInfo = {
          name: meetingInfo.watermarkConfig?.name || localMember.name,
          phone: meetingInfo.watermarkConfig?.phone || '',
          email: meetingInfo.watermarkConfig?.email || '',
          jobNumber: meetingInfo.watermarkConfig?.jobNumber || '',
        };
        function replaceFormat(format: string, info: Record<string, string>) {
          const regex = /{([^}]+)}/g;
          const result = format.replace(regex, (match, key) => {
            const value = info[key];
            return value ? value : match; // 如果值存在，则返回对应的值，否则返回原字符串
          });
          return result;
        }
        if (isScreenSharingVideo) {
          drawWatermark({
            container: document.body,
            content: replaceFormat(videoFormat, supportInfo),
            type: videoStyle,
            offsetX: 20,
            offsetY: 30,
          });
        } else {
          drawWatermark({
            container: document.body,
            content: replaceFormat(videoFormat, supportInfo),
            type: videoStyle,
          });
        }
      } else {
        stopDrawWatermark();
      }
      return () => {
        stopDrawWatermark();
      };
    }
  }, [meetingInfo, enableWatermark]);

  return (
    <ConfigProvider
      prefixCls="nemeeting"
      locale={
        {
          'zh-CN': zhCN,
          'en-US': enUs,
          'ja-JP': jaJP,
        }[i18n.language]
      }
      theme={{ hashed: false }}
    >
      {windowOpen && props.children}
    </ConfigProvider>
  );
};
