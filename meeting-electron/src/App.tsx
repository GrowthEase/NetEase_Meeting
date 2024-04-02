import React from 'react'
import './AppH5.less'
import { ConfigProvider } from 'antd'
import zh_CH from 'antd/locale/zh_CN'
import en_US from 'antd/locale/en_US'
import ja_JP from 'antd/locale/ja_JP'
import MeetingContent from './components/web/Meeting/Meeting'
import { useTranslation } from 'react-i18next'

const antdPrefixCls = 'nemeeting'

ConfigProvider.config({ prefixCls: antdPrefixCls })

interface AppProps {
  width: number
  height: number
}

const App: React.FC<AppProps> = ({ height, width }) => {
  const { i18n } = useTranslation()
  return (
    <ConfigProvider
      prefixCls={antdPrefixCls}
      locale={
        {
          'zh-CN': zh_CH,
          'en-US': en_US,
          'ja-JP': ja_JP,
        }[i18n.language]
      }
      theme={{ hashed: false }}
    >
      <MeetingContent width={width} height={width} />
    </ConfigProvider>
  )
}

export default App
