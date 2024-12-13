import { Button, Input } from 'antd'
import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import Toast from '../../common/toast'

interface AddOtherPlatformProps {
  onGoBack: () => void
  platformInfo?: PlatformInfo
  onSave: (info: PlatformInfo) => void
  className?: string
  containerStyle?: React.CSSProperties
}
interface PlatformInfo {
  platformName: string
  pushUrl: string
  pushSecretKey?: string
  id?: string
}

export const AddOtherPlatform: React.FC<AddOtherPlatformProps> = ({
  onGoBack,
  platformInfo,
  onSave,
  className,
  containerStyle,
}) => {
  const { t } = useTranslation()
  const [platformName, setPlatformName] = useState(
    platformInfo?.platformName || ''
  )
  const [pushUrl, setPushUrl] = useState(platformInfo?.pushUrl || '')
  const [pushSecretKey, setPushSecretKey] = useState(
    platformInfo?.pushSecretKey || ''
  )
  const [pushUrlStatus, setPushUrlStatus] = useState<'error' | ''>('')

  useEffect(() => {
    if (platformInfo) {
      setPlatformName(platformInfo.platformName)
      setPushSecretKey(platformInfo.pushSecretKey || '')
      setPushUrl(platformInfo.pushUrl || '')
    }
  }, [platformInfo])

  function handleSave() {
    if (pushUrlStatus === 'error') {
      return
    }

    if (!platformName) {
      Toast.info(t('platformNameTip'))
      return
    }

    if (!pushUrl) {
      Toast.info(t('pushUrlTip'))
      return
    }

    const _platformInfo: PlatformInfo = {
      platformName,
      pushUrl,
      pushSecretKey,
      id: platformInfo?.id,
    }

    onSave?.(_platformInfo)
  }

  function handlePushUrlChange(url: string) {
    if (!/^rtmp:\/\/[\w\d\S]+/.test(url)) {
      setPushUrlStatus('error')
    } else {
      setPushUrlStatus('')
    }

    setPushUrl(url)
  }

  return (
    <div className={`live-add-other-platform-container ${className || ''}`}>
      <div className="live-meeting-container" style={containerStyle}>
        <div className="add-other-platform">
          <div className="add-other-platform-header">
            <div className="add-other-platform-back" onClick={onGoBack}>
              <svg className={'back-icon icon'} aria-hidden="true">
                <use xlinkHref="#iconyx-returnx"></use>
              </svg>
              <span>{t('globalGoBack')}</span>
            </div>
            <div className="add-other-platform-title">
              {t('meetingLiveToOtherPlatformSetting')}
            </div>
          </div>
          <div className="add-other-platform-content">
            <div className="add-other-platform-content-item">
              <div className="live-meeting-title">{t('platformName')}</div>
              <div>
                <Input
                  value={platformName}
                  placeholder={t('platformNamePlaceholder')}
                  maxLength={30}
                  allowClear={true}
                  onChange={(e) => {
                    setPlatformName(e.target.value)
                  }}
                />
              </div>
            </div>
            <div className="add-other-platform-content-item">
              <div className="live-meeting-title">{t('pushUrl')}</div>
              <div>
                <Input
                  value={pushUrl}
                  status={pushUrlStatus}
                  placeholder={t('pushUrlPlaceholder')}
                  allowClear={true}
                  onChange={(e) => {
                    handlePushUrlChange(e.target.value)
                  }}
                />
                {pushUrlStatus === 'error' && (
                  <div className="nemeeting-push-url-error-tip">
                    {t('pushUrlErrorTip')}
                  </div>
                )}
              </div>
            </div>
            <div className="add-other-platform-content-item">
              <div className="live-meeting-title">{t('pushSecret')}</div>
              <div>
                <Input.Password
                  value={pushSecretKey}
                  placeholder={t('pushSecretTip')}
                  allowClear
                  onChange={(e) => {
                    setPushSecretKey(e.target.value)
                  }}
                  iconRender={(visible) =>
                    visible ? (
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconpassword-displayx"></use>
                      </svg>
                    ) : (
                      <svg className="icon iconfont" aria-hidden="true">
                        <use xlinkHref="#iconpassword-hidex"></use>
                      </svg>
                    )
                  }
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="nemeeting-live-third-footer">
        <div className="nemeeting-live-setting-footer-button">
          <Button
            style={{ width: '100%', height: '36px' }}
            type="primary"
            onClick={() => handleSave()}
          >
            {t('save')}
          </Button>
        </div>
      </div>
    </div>
  )
}
