import React from 'react'
import { useTranslation } from 'react-i18next'
import './index.less'
import { LocalRecordState } from '../../../types/innerType'
import classNames from 'classnames'

interface RecordProps {
  className?: string
  stopRecord?: () => void
  localRecordState?: LocalRecordState
  notShowRecordBtn: boolean
}

const LocalRecord: React.FC<RecordProps> = ({
  localRecordState,
  className,
  stopRecord,
  notShowRecordBtn,
}) => {
  const { t } = useTranslation()

  return (
    <div className={`nemeeting-record ${className || ''}`}>
      {
        <>
          <div className="nemeeting-record-left">
            <svg className="icon iconfont" aria-hidden="true">
              <use xlinkHref="#iconbendiluzhi1"></use>
            </svg>
            <span
              className={classNames('nemeeting-record-title', {
                'nemeeting-record-title-starting':
                localRecordState === LocalRecordState.Starting,
              })}
            >
              {localRecordState === LocalRecordState.Starting
                ? t('startingRecording')
                : t('recording')}
            </span>
          </div>
          {localRecordState === LocalRecordState.Recording && !notShowRecordBtn && (
            <div className="nemeeting-record-right" onClick={stopRecord}>
              <svg className="icon iconfont" aria-hidden="true">
                <use xlinkHref="#iconzanting"></use>
              </svg>
            </div>
          )}
        </>
      }
    </div>
  )
}

export default React.memo(LocalRecord)
