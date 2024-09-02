import React, { useEffect } from 'react'
import './index.less'
import { useTranslation } from 'react-i18next'
import { IPCEvent } from '../../../../app/src/types'

const AnnotationTools: React.FC = () => {
  const { t } = useTranslation()

  useEffect(() => {
    window.ipcRenderer?.send(IPCEvent.sharingScreen, {
      method: 'openToast',
    })
    return () => {
      window.ipcRenderer?.send(IPCEvent.sharingScreen, {
        method: 'closeToast',
      })
    }
  }, [])

  return (
    <div className="annotation-tools">
      <div className="annotation-tools-item">{t('inAnnotation')}</div>
      <div className="annotation-tools-item">{t('saveAnnotation')}</div>
      <div className="annotation-tools-item">{t('stopAnnotation')}</div>
    </div>
  )
}

export default React.memo(AnnotationTools)
