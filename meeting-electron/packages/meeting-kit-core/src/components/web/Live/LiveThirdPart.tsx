import { Button } from 'antd'
import React, { useMemo, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { AddOtherPlatform } from './AddOtherPlatform'
import { useGlobalContext } from '../../../store'

interface LiveThirdPartProps {
  className?: string
  onCancel: () => void
  onSave: (platformInfoList: PlatformInfo[]) => void
  platformInfoList: PlatformInfo[]
}

interface PlatformInfo {
  platformName: string
  pushUrl: string
  pushSecretKey?: string
  id?: string
}

const LiveThirdPart: React.FC<LiveThirdPartProps> = ({
  className,
  onCancel,
  onSave,
  platformInfoList,
}) => {
  const { t } = useTranslation()
  const [showAddOtherPlatform, setShowOtherPlatform] = useState(false)
  const [currentPlatformInfo, setCurrentPlatformInfo] = useState<
    PlatformInfo | undefined
  >()
  const [localPlatformInfoList, setLocalPlatformInfoList] =
    useState(platformInfoList)
  const [saveLoading, setSaveLoading] = useState(false)
  const isEditPlatformInfoRef = useRef(false)
  const { neMeeting, globalConfig } = useGlobalContext()

  const maxCount = useMemo(() => {
    return globalConfig?.appConfig.MEETING_LIVE?.maxThirdPartyNum || 5
  }, [globalConfig?.appConfig.MEETING_LIVE?.maxThirdPartyNum])

  function addOtherPlatform() {
    isEditPlatformInfoRef.current = false
    setCurrentPlatformInfo(undefined)
    setShowOtherPlatform(true)
  }

  function editOtherPlatform(e: React.MouseEvent, index: number) {
    isEditPlatformInfoRef.current = true
    e.stopPropagation()
    e.preventDefault()
    const platformInfo = localPlatformInfoList[index]

    setCurrentPlatformInfo(platformInfo)
    setShowOtherPlatform(true)
  }

  function handleDeletePlatform(e: React.MouseEvent, index: number) {
    e.stopPropagation()
    e.preventDefault()
    const _platformInfoList = [...localPlatformInfoList]

    // 删除该项
    if (index > -1) {
      _platformInfoList.splice(index, 1)
      setLocalPlatformInfoList([..._platformInfoList])
    }
  }

  function onGoBack() {
    setShowOtherPlatform(false)
  }

  function onSavePlatform(platformInfo: PlatformInfo) {
    const _platformInfoList = [...localPlatformInfoList]

    // 编辑
    if (isEditPlatformInfoRef.current) {
      const index = _platformInfoList.findIndex(
        (item) => item.id === platformInfo.id
      )

      if (index > -1) {
        _platformInfoList[index] = platformInfo
      }
    } else {
      // 新增
      _platformInfoList.push(platformInfo)
    }

    setLocalPlatformInfoList([..._platformInfoList])
    setShowOtherPlatform(false)
  }

  function handleSave() {
    setSaveLoading(true)
    neMeeting
      ?.updateLive3PartInfo({
        thirdParties: localPlatformInfoList,
      })
      .then(() => {
        onSave?.(localPlatformInfoList)
      })
      .finally(() => {
        setSaveLoading(false)
      })
  }

  return (
    <div className={`nemeeting-live-third-part-wrapper ${className || ''}`}>
      {!showAddOtherPlatform ? (
        <>
          <div className="nemeeting-live-third-part">
            {localPlatformInfoList.map((item, index) => (
              <div
                key={index}
                className="nemeeting-live-setting-add-wrapper nemeeting-live-setting-platform-item"
              >
                <div className="nemeeting-live-setting-platform-item-name nemeeting-ellipsis">
                  {item.platformName}
                </div>
                <div>
                  <Button
                    type="link"
                    size="small"
                    onClick={(e) => editOtherPlatform(e, index)}
                  >
                    {t('globalEdit')}
                  </Button>
                  <Button
                    type="link"
                    danger
                    size="small"
                    onClick={(e) => handleDeletePlatform(e, index)}
                  >
                    {t('globalDelete')}
                  </Button>
                </div>
              </div>
            ))}
            {localPlatformInfoList.length < maxCount && (
              <div
                className="nemeeting-live-setting-add-wrapper"
                onClick={() => addOtherPlatform()}
              >
                <svg
                  style={{ marginRight: '12px' }}
                  viewBox="64 64 896 896"
                  focusable="false"
                  data-icon="plus"
                  width="1em"
                  height="1em"
                  fill="currentColor"
                  aria-hidden="true"
                >
                  <path d="M482 152h60q8 0 8 8v704q0 8-8 8h-60q-8 0-8-8V160q0-8 8-8z"></path>
                  <path d="M192 474h672q8 0 8 8v60q0 8-8 8H160q-8 0-8-8v-60q0-8 8-8z"></path>
                </svg>
                <div>{t('globalAdd')}</div>
              </div>
            )}
          </div>
          <div className="nemeeting-live-third-footer">
            <Button
              style={{ width: '164px', height: '36px' }}
              disabled={saveLoading}
              onClick={() => onCancel?.()}
            >
              {t('globalCancel')}
            </Button>
            <Button
              style={{ width: '164px', height: '36px' }}
              type="primary"
              loading={saveLoading}
              onClick={() => handleSave()}
            >
              {t('save')}
            </Button>
          </div>
        </>
      ) : (
        <AddOtherPlatform
          containerStyle={{
            height: '430px',
            padding: '0 20px 20px 20px',
            boxSizing: 'border-box',
          }}
          platformInfo={currentPlatformInfo}
          onGoBack={onGoBack}
          onSave={onSavePlatform}
        />
      )}
    </div>
  )
}

export default React.memo(LiveThirdPart)
