import React, { useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { ConfigProvider } from 'antd';
import '../../../src/locales/i18n';
import zhCN from 'antd/locale/zh_CN';
import enUs from 'antd/locale/en_US';
import jaJP from 'antd/locale/ja_JP';
import dayjs from 'dayjs';
import 'dayjs/locale/ja';
import 'dayjs/locale/zh-cn';
import 'dayjs/locale/en';

export default (props) => {
  const { i18n } = useTranslation();

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
      {props.children}
    </ConfigProvider>
  );
};
