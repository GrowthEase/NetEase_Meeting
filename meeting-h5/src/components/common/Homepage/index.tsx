import React, { useCallback, useEffect, useMemo, useState } from 'react'
import { ConfigProvider, Spin } from 'antd'
import zhCN from 'antd/locale/zh_CN'
import qs from 'qs'
import './index.less'
import BeforeMeetingHome from '../../web/BeforeMeetingHome/index'
import BeforeLogin from '../../../../example/src/pages/login'
import Header from '../../../../example/src/components/layout/Header'
import Footer from '../../../../example/src/components/layout/Footer'
import eleIpc from '../../../services/electron/index'
import { IPCEvent } from '../../../../example/src/types'
import {
  LOCALSTORAGE_USER_INFO,
  WEBSITE_URL,
  LOCALSTORAGE_LOGIN_BACK,
} from '../../../../example/src/config'

let appKey = ''

const Homepage: React.FC = () => {
  const [isLogined, setIsLogined] = useState<boolean>(true)
  const [loginLoading, setLoginLoading] = useState(true)
  const eleIpcIns = useMemo(() => eleIpc.getInstance(), [])

  useEffect(() => {
    if (eleIpcIns) {
      eleIpcIns.on('electron-login-success', (url) => {
        console.log('页面获取到了 ', url)
        handleAuth(url)
      })
    }
  }, [eleIpcIns])

  useEffect(() => {
    if (eleIpcIns) {
      eleIpcIns.sendMessage(
        isLogined ? IPCEvent.beforeEnterRoom : IPCEvent.beforeLogin
      )
    }
  }, [isLogined])

  const handleAuth = (url) => {
    const user = JSON.parse(
      localStorage.getItem(LOCALSTORAGE_USER_INFO) as string
    )
    const query = qs.parse(url.split('?')[1]?.split('#/')[0])
    const backUrl = query?.backUrl || ''
    localStorage.removeItem(LOCALSTORAGE_LOGIN_BACK)
    if (query?.userUuid && query.userToken && (query.appKey || query.appId)) {
      // 直接处理url参数
      const { userUuid, userToken, appKey, appId } = query
      localStorage.setItem(
        LOCALSTORAGE_USER_INFO,
        JSON.stringify({ userUuid, userToken, appKey, appId })
      )
      if (backUrl) {
        window.location.href = backUrl as string
      } else {
        delete query.userUuid
        delete query.userToken
        delete query.appKey
        delete query.appId
        window.location.href = `${window.location.origin}${
          window.location.pathname
        }${qs.stringify(query, { addQueryPrefix: true })}`
      }
      return
    }
    if (user?.userUuid && user.userToken && (user.appKey || user.appId)) {
      if (backUrl) {
        window.location.href = backUrl as string
      } else {
        appKey = user.appKey || user.appId
        setIsLogined(true)
      }
    } else {
      setIsLogined(false)
    }
    setLoginLoading(false)
    document.title = '网易会议'
  }

  useEffect(() => {
    handleAuth(location.href)
  }, [])

  const logout = () => {
    localStorage.removeItem(LOCALSTORAGE_USER_INFO)
    localStorage.removeItem(LOCALSTORAGE_LOGIN_BACK)
    // 官网登录信息也干掉
    localStorage.removeItem('loginWayV2')
    localStorage.removeItem('loginAppNameSpaceV2')
    if (eleIpcIns) {
      setTimeout(() => {
        setIsLogined(false)
      }, 1000)
    } else {
      window.location.href = WEBSITE_URL
    }
  }

  const onLogged = () => {
    handleAuth(location.href)
  }

  const pageContent = useCallback(() => {
    if (loginLoading) return
    if (isLogined) {
      // @ts-ignore
      if (window.ipcRenderer) {
        // @ts-ignore
        window.ipcRenderer.sendSync('NERoomNodeProxyInit')
      }
      return <BeforeMeetingHome onLogout={logout} />
    }
    return (
      <>
        {/* @ts-ignore */}
        {!window.ipcRenderer && <Header />}
        <BeforeLogin onLogged={onLogged} />
        {
          /* @ts-ignore */
          !window.ipcRenderer && <Footer className="whiteTheme" logo={false} />
        }
      </>
    )
  }, [eleIpcIns, isLogined, loginLoading])

  return (
    <>
      <ConfigProvider
        prefixCls="nemeeting"
        locale={zhCN}
        theme={{
          token: {
            colorPrimary: '#337eff',
          },
          hashed: false,
        }}
      >
        {pageContent()}
      </ConfigProvider>
    </>
  )
}
export default Homepage
