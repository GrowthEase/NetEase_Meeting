import { useUpdateEffect } from 'ahooks'
import { Button, Progress } from 'antd'
import axios from 'axios'
import qs from 'qs'
import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import Footer from '../../../../app/src/components/layout/Footer'
import Header from '../../../../app/src/components/layout/Header'
import {
  DOMAIN_SERVER,
  LOCALSTORAGE_INVITE_MEETING_URL,
  LOCALSTORAGE_LOGIN_BACK,
  LOCALSTORAGE_SSO_APP_KEY,
  LOCALSTORAGE_USER_INFO,
  UPDATE_URL,
  WEBSITE_URL,
} from '../../../../app/src/config'
import BeforeLogin from '../../../../app/src/pages/login'
import { IPCEvent } from '../../../../app/src/types'
import eleIpc from '../../../services/electron/index'
import { ClientType, ResUpdateInfo, UpdateType } from '../../../types/innerType'
import { getDeviceKey } from '../../../utils'
import H5BeforeMeetingHome from '../../h5/BeforeMeetingHome/index'
import BeforeMeetingHome from '../../web/BeforeMeetingHome/index'
import GuestBeforeMeeting from '../GuestBeforeMeeting'
import Modal from '../Modal'
import Toast from '../toast'
import './index.less'

let appKey = ''

const Homepage = () => {
  const { t, i18n } = useTranslation()
  const [isLogined, setIsLogined] = useState<boolean>(true)
  const [loginLoading, setLoginLoading] = useState(true)
  const eleIpcIns = useMemo(() => eleIpc.getInstance(), [])
  const [needUpdateType, setNeedUpdateType] = useState(UpdateType.noUpdate)
  const [showUpdateDialog, setShowUpdateDialog] = useState(false)
  const [showExitApp, setShowExitApp] = useState(false)
  const [updateProgress, setUpdateProgress] = useState(0)
  const [goGuest, setGoGuest] = useState(true) // 是否跳转到访客页面
  const [updateInfo, setUpdateInfo] = useState({
    title: '',
    description: '',
    version: '',
    md5: '',
    downloadUrl: '',
  })
  const [startUpdate, setStartUpdate] = useState(false)
  const [updateError, setUpdateError] = useState({
    showUpdateError: false,
    msg: '',
  })
  const localUpdateInfoRef = useRef({
    versionName: '',
    versionCode: -1,
    platform: 'darwin',
  })

  const isH5 = process.env.PLATFORM === 'h5' || window.h5App

  useEffect(() => {
    // electron环境
    const handleUpdateProgress = (_: any, progress: number) => {
      setUpdateProgress(progress)
      // if (progress === 100) {
      //   setStartUpdate(false)
      // }
    }
    const handleUpdateError = (_: any, error: any) => {
      setUpdateProgress(0)
      setUpdateError({
        showUpdateError: true,
        msg: error.message || error.msg || error.code || '未知错误',
      })
      setShowUpdateDialog(false)
      setStartUpdate(false)
    }
    if (window.isElectronNative) {
      const ipcRenderer = window.ipcRenderer
      ipcRenderer?.on(IPCEvent.updateProgress, handleUpdateProgress)
      ipcRenderer?.on(IPCEvent.updateError, handleUpdateError)
    }
    return () => {
      if (window.isElectronNative) {
        window.ipcRenderer?.off(IPCEvent.updateProgress, handleUpdateProgress)
        window.ipcRenderer?.off(IPCEvent.updateError, handleUpdateError)
      }
    }
  }, [])
  useEffect(() => {
    const handleLogin = function (url) {
      console.log('页面获取到了 ', url, isLogined)
      if (!isLogined) {
        handleAuth(url)
      }
    }
    if (eleIpcIns) {
      eleIpcIns.on('electron-login-success', handleLogin)
    }
    return () => {
      eleIpcIns?.off('electron-login-success', handleLogin)
    }
  }, [eleIpcIns, isLogined])

  useEffect(() => {
    if (eleIpcIns) {
      eleIpcIns.sendMessage(
        isLogined ? IPCEvent.beforeEnterRoom : IPCEvent.beforeLogin
      )
    }
  }, [isLogined])
  const handleSSOAuth = (query: any) => {
    const param = query.param
    const backUrl = query?.backUrl || ''
    const key = getDeviceKey()
    const appKey = localStorage.getItem(LOCALSTORAGE_SSO_APP_KEY)
    setLoginLoading(true)
    axios({
      url: `${DOMAIN_SERVER}/scene/meeting/v2/sso-account-info`,
      method: 'GET',
      headers: {
        appKey: appKey || '',
      },
      params: {
        param,
        key,
      },
    })
      .then((res) => {
        console.log(res.data)
        if (res.data.code != 0) {
          Toast.fail(res.data.msg)
        } else {
          let userInfo = res.data.data
          userInfo = Object.assign(
            {
              appKey,
              loginType: 'SSO',
            },
            userInfo
          )
          localStorage.setItem(LOCALSTORAGE_USER_INFO, JSON.stringify(userInfo))
          setIsLogined(true)
          if (backUrl) {
            window.location.href = backUrl as string
          } else {
            delete query.param
            window.location.href = `${window.location.origin}${
              window.location.pathname
            }${qs.stringify(query, { addQueryPrefix: true })}`
          }
        }
      })
      .finally(() => {
        setLoginLoading(false)
      })
  }
  const handleAuth = (url: string) => {
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
        JSON.stringify({ userUuid, userToken, appKey, appId, loginType: 'sso' })
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
    } else if (query.param) {
      // 企业sso登录
      handleSSOAuth(query)
    }
    if (user?.userUuid && user.userToken && (user.appKey || user.appId)) {
      if (backUrl) {
        window.location.href = backUrl as string
      } else {
        appKey = user.appKey || user.appId
        setIsLogined(true)
        // 处理访客登录，需要在登录后 destroy 现有的 NEMeetingKit
        // if (!window.isElectronNative) {
        //   NEMeetingKit.actions.destroy()
        // }
      }
    } else {
      setIsLogined(false)
    }
    setLoginLoading(false)
    document.title = '网易会议'
  }

  useEffect(() => {
    handleAuth(location.href)
    checkUpdate()
  }, [])

  const checkUpdate = () => {
    if (window.isElectronNative) {
      const ipcRenderer = window.ipcRenderer
      let userUuid = ''
      try {
        const user = JSON.parse(
          localStorage.getItem(LOCALSTORAGE_USER_INFO) as string
        )
        userUuid = user?.userUuid || ''
      } catch (error) {
        console.log('LOCALSTORAGE_USER_INFO Error', error)
      }
      ipcRenderer?.invoke(IPCEvent.getCheckUpdateInfo).then(async (res) => {
        console.log('getCheckUpdateInfo', res)
        const localUpdateInfo = await window.ipcRenderer?.invoke(
          IPCEvent.getLocalUpdateInfo
        )
        axios({
          url: UPDATE_URL,
          method: 'POST',
          headers: {
            clientType:
              localUpdateInfo.platform === 'darwin'
                ? ClientType.ElectronMac
                : ClientType.ElectronWindows,
            sdkVersion: res.versionCode,
          },
          data: {
            ...res,
            accountId: userUuid,
          },
        }).then(async (res) => {
          console.log('updateInfo>>>>', res.data)
          if (res.data.code != 200 && res.data.code != 0) {
            return
          }
          const tmpData = res.data.ret
          if (!tmpData || tmpData.notify == 0) {
            return
          }

          localUpdateInfoRef.current = localUpdateInfo
          if (localUpdateInfo.platform == 'darwin') {
            checkUpdateHandle({
              ...tmpData,
            })
          } else if (localUpdateInfo.platform == 'win32') {
            checkUpdateHandle({
              ...tmpData,
            })
          }
        })
      })
    }
  }
  const checkUpdateHandle = async (data: ResUpdateInfo) => {
    let needUpdate = false
    if (!localUpdateInfoRef.current.versionName) {
      try {
        localUpdateInfoRef.current = await window.ipcRenderer?.invoke(
          IPCEvent.getLocalUpdateInfo
        )
      } catch (e) {
        console.log('getLocalUpdateInfo Error', e)
      }
    }
    let forceUpdate = false
    if (data.forceVersionCode) {
      let currentVersionCode = data.forceVersionCode
      if (data.forceVersionCode < data.latestVersionCode) {
        currentVersionCode = data.latestVersionCode
      } else {
        forceUpdate = true
      }
      needUpdate = currentVersionCode > localUpdateInfoRef.current.versionCode
      console.log(
        'currentVersionCode',
        currentVersionCode,
        localUpdateInfoRef.current,
        needUpdate
      )
    } else if (data.latestVersionCode) {
      needUpdate =
        data.latestVersionCode > localUpdateInfoRef.current.versionCode
    }
    if (!needUpdate) {
      return
    }
    setNeedUpdateType(
      forceUpdate ? UpdateType.forceUpdate : UpdateType.normalUpdate
    )
    setShowUpdateDialog(true)
    let description = data.description
    try {
      description = await window.ipcRenderer?.invoke(
        IPCEvent.decodeBase64,
        data.description
      )
    } catch (e) {
      console.log('decodeBase64 Error', e)
    }
    setUpdateInfo({
      title: data.title || '--',
      description: description || '--',
      version: data.latestVersionName || '--',
      downloadUrl: data.downloadUrl || '',
      md5: data.checkCode || '',
    })
  }
  const logout = () => {
    localStorage.removeItem(LOCALSTORAGE_USER_INFO)
    localStorage.removeItem(LOCALSTORAGE_LOGIN_BACK)
    localStorage.removeItem(LOCALSTORAGE_INVITE_MEETING_URL)
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

  const exitApp = () => {
    window.ipcRenderer?.invoke(IPCEvent.exitApp)
  }
  const cancelUpdate = () => {
    setUpdateError({
      showUpdateError: false,
      msg: '',
    })
    setUpdateProgress(0)
    setStartUpdate(false)
    setShowUpdateDialog(needUpdateType === UpdateType.forceUpdate)
  }
  const cancelDownload = () => {
    cancelUpdate()
    window.ipcRenderer?.invoke(IPCEvent.cancelUpdate)
  }
  const onClickUpdate = () => {
    setShowUpdateDialog(true)
    setStartUpdate(true)
    setUpdateError({
      showUpdateError: false,
      msg: '',
    })
    window.ipcRenderer
      ?.invoke(IPCEvent.checkUpdate, {
        url: updateInfo.downloadUrl || '',
        md5: updateInfo.md5 || '',
        forceUpdate: needUpdateType === UpdateType.forceUpdate,
      })
      .catch((e: any) => {
        setStartUpdate(false)
        setShowUpdateDialog(false)
        setUpdateError({
          showUpdateError: false,
          msg: e.message || e.msg || e.code || '未知错误',
        })
        console.log('checkUpdate Error', e)
      })
  }

  useEffect(() => {
    function handleJoinMeeting(e, url) {
      // 把url存入localstorage
      localStorage.setItem(LOCALSTORAGE_INVITE_MEETING_URL, url)
    }
    if (!isLogined) {
      window.ipcRenderer?.on('electron-join-meeting', handleJoinMeeting)
      return () => {
        window.ipcRenderer?.off('electron-join-meeting', handleJoinMeeting)
      }
    }
  }, [isLogined])

  const pageContent = useCallback(() => {
    if (loginLoading) return
    if (isLogined) {
      // window.ipcRenderer?.sendSync('NERoomNodeProxyInit')
      return isH5 ? (
        <H5BeforeMeetingHome onLogout={logout} />
      ) : (
        <BeforeMeetingHome onLogout={logout} />
      )
    }
    if (!window.isElectronNative && goGuest) {
      // 创建URL对象
      const qsObj = qs.parse(window.location.href.split('?')[1]?.split('#/')[0])
      const guestJoinType = qsObj?.guestJoinType
      if (guestJoinType === '1' || guestJoinType === '2') {
        return (
          <GuestBeforeMeeting onLogin={() => setGoGuest(false)} isH5={isH5} />
        )
      }
    }

    return (
      <>
        {!window.isElectronNative && <Header />}
        <BeforeLogin onLogged={onLogged} />
        {!window.isElectronNative && (
          <Footer className="whiteTheme" logo={false} />
        )}
      </>
    )
  }, [eleIpcIns, isLogined, loginLoading, goGuest])

  useUpdateEffect(() => {
    const isChrome =
      /Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor)
    const isEdge = /Edge|Edg/.test(navigator.userAgent)
    if (!isChrome || isEdge) {
      Toast.info(t('authSuggestChrome'))
    }
  }, [i18n.language])

  return (
    <>
      <Modal
        className="nemeeting-update"
        open={updateError.showUpdateError}
        width={350}
        title=""
        closable={false}
        footer={null}
      >
        <div className="nemeeting-update-content">
          <div className="icon-wrap">
            <img
              className="nemeeting-icon"
              src={require('../../../../app/src/assets/error.png')}
            />
          </div>
          <div className="meeting-update-title">{t('settingUpdateFailed')}</div>
          <div className="version-info error-info">{updateError.msg}</div>
          <div className="button-wrap">
            {needUpdateType !== UpdateType.forceUpdate && (
              <Button
                className="not-update-btn"
                onClick={() => {
                  setUpdateError({
                    showUpdateError: false,
                    msg: '',
                  })
                }}
              >
                {t('settingTryAgainLater')}
              </Button>
            )}

            <Button
              className="update-btn"
              type="primary"
              onClick={onClickUpdate}
            >
              {t('settingRetryNow')}
            </Button>
          </div>
        </div>
      </Modal>
      <Modal
        className="nemeeting-update"
        open={showUpdateDialog}
        width={350}
        title=""
        closable={false}
        footer={null}
      >
        <div className="nemeeting-update-content">
          <div className="icon-wrap">
            <img
              className="nemeeting-icon"
              src={require('../../../../app/src/assets/rooms-icon.png')}
            />
          </div>
          <div className="meeting-update-title">
            {t('settingFindNewVersion')}V{updateInfo.version}
          </div>
          <pre className="version-info">{updateInfo.description}</pre>
          {startUpdate ? (
            <>
              <Progress
                className="update-progress"
                percent={updateProgress}
                showInfo={false}
              />
              <div className="progress-percent">
                {t('settingUpdating')} {updateProgress}%
              </div>
              <div className="button-wrap">
                <Button onClick={cancelDownload}>
                  {t('settingCancelUpdate')}
                </Button>
              </div>
            </>
          ) : (
            <div className="button-wrap">
              {needUpdateType == UpdateType.forceUpdate ? (
                <Button
                  className="not-update-btn"
                  onClick={() => {
                    setShowUpdateDialog(false)
                    setShowExitApp(true)
                  }}
                >
                  {t('settingExitApp')}
                </Button>
              ) : (
                <Button
                  className="not-update-btn"
                  onClick={() => {
                    cancelUpdate()
                  }}
                >
                  {t('settingNotUpdate')}
                </Button>
              )}

              <Button
                className="update-btn"
                type="primary"
                onClick={onClickUpdate}
              >
                {t('settingUPdateNow')}
              </Button>
            </div>
          )}
        </div>
      </Modal>
      <Modal
        className="nemeeting-update"
        open={showExitApp}
        width={350}
        title=""
        closable={false}
        footer={null}
      >
        <div className="nemeeting-update-content">
          <div className="exit-app-title">{t('settingConfirmExitApp')}？</div>
          <div className="button-wrap">
            <Button
              className="not-update-btn"
              onClick={() => {
                setShowUpdateDialog(true)
                setShowExitApp(false)
              }}
            >
              {t('globalCancel')}
            </Button>
            <Button className="update-btn" type="primary" onClick={exitApp}>
              {t('globalSure')}
            </Button>
          </div>
        </div>
      </Modal>
      {pageContent()}
    </>
  )
}
export default Homepage
